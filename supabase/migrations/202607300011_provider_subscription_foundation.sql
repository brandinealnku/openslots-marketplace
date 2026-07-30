-- OpenSlot 0.3.5A: provider-paid Stripe Billing only. No customer service payments.
create type public.subscription_status as enum ('none','trialing','active','past_due','unpaid','canceled','incomplete','incomplete_expired','paused');
create type public.billing_interval as enum ('trial','month','year');

create table public.subscription_plans(
 id uuid primary key default gen_random_uuid(), code text unique not null check(code ~ '^[a-z0-9_]+$'), display_name text not null,
 description text not null default '', billing_interval public.billing_interval not null, trial_days int not null default 0 check(trial_days between 0 and 365),
 active_opening_limit int not null check(active_opening_limit > 0), monthly_publishing_limit int check(monthly_publishing_limit is null or monthly_publishing_limit > 0),
 stripe_price_id text unique, is_active boolean not null default true, sort_order int not null default 0,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.provider_subscriptions(
 id uuid primary key default gen_random_uuid(), provider_profile_id uuid not null references public.provider_profiles(user_id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade, plan_id uuid references public.subscription_plans(id),
 stripe_customer_id text unique, stripe_subscription_id text unique, stripe_price_id text,
 status public.subscription_status not null default 'none', trial_start timestamptz, trial_end timestamptz,
 current_period_start timestamptz, current_period_end timestamptz, cancel_at_period_end boolean not null default false,
 canceled_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(provider_profile_id), unique(user_id), check(provider_profile_id=user_id)
);
create table public.subscription_events(
 id bigint generated always as identity primary key, stripe_event_id text unique, provider_subscription_id uuid references public.provider_subscriptions(id) on delete set null,
 user_id uuid references public.profiles(id) on delete set null, event_type text not null, source text not null check(source in ('checkout','portal','webhook','system')),
 outcome text not null default 'processed', metadata jsonb not null default '{}', created_at timestamptz not null default now()
);
create index provider_subscriptions_user on public.provider_subscriptions(user_id);
create index subscription_events_subscription on public.subscription_events(provider_subscription_id,created_at desc);

insert into public.subscription_plans(code,display_name,description,billing_interval,trial_days,active_opening_limit,monthly_publishing_limit,sort_order) values
 ('trial','Trial','30-day development trial','trial',30,3,5,10),
 ('starter','Starter','Basic marketplace access','month',0,10,null,20),
 ('pro','Pro','Higher limits and future advanced tools','month',0,50,null,30);

alter table public.subscription_plans enable row level security;
alter table public.provider_subscriptions enable row level security;
alter table public.subscription_events enable row level security;
-- Price IDs are intentionally not selectable by browser roles. Safe plans are exposed by RPC.
-- Providers read a safe projection through get_provider_marketplace_access; raw Stripe IDs remain admin-only.
create policy subscription_admin_read on public.provider_subscriptions for select to authenticated using(public.is_admin());
create policy subscription_events_admin_read on public.subscription_events for select to authenticated using(public.is_admin());

create function public.list_provider_subscription_plans()
returns table(code text,display_name text,description text,billing_interval public.billing_interval,trial_days int,active_opening_limit int,monthly_publishing_limit int,sort_order int)
language sql stable security definer set search_path=public as $$
 select p.code,p.display_name,p.description,p.billing_interval,p.trial_days,p.active_opening_limit,p.monthly_publishing_limit,p.sort_order
 from subscription_plans p where p.is_active order by p.sort_order,p.code
$$;

create function public.get_provider_marketplace_access()
returns table(provider_approval_status text,account_status text,subscription_status public.subscription_status,current_plan text,trial_end timestamptz,current_period_end timestamptz,cancel_at_period_end boolean,can_publish boolean,billing_required boolean,required_next_action text)
language sql stable security definer set search_path=public as $$
 select coalesce(pp.application_status::text,'not_provider'),coalesce(pr.account_status,'unknown'),coalesce(ps.status,'none'::subscription_status),sp.code,
 ps.trial_end,ps.current_period_end,coalesce(ps.cancel_at_period_end,false),
 (pr.role='provider' and pr.account_status='active' and pp.application_status='approved' and ps.status in ('trialing','active')),
 not (ps.status in ('trialing','active')),
 case when pr.id is null then 'sign_in' when pr.role<>'provider' then 'become_provider' when pr.account_status<>'active' then 'contact_support'
 when pp.application_status<>'approved' then 'complete_approval' when ps.status not in ('trialing','active') then 'choose_plan' when ps.cancel_at_period_end then 'review_cancellation' else 'none' end
 from (select auth.uid() id) me left join profiles pr on pr.id=me.id left join provider_profiles pp on pp.user_id=me.id
 left join provider_subscriptions ps on ps.user_id=me.id left join subscription_plans sp on sp.id=ps.plan_id
$$;
revoke all on function public.list_provider_subscription_plans() from public;
revoke all on function public.get_provider_marketplace_access() from public;
grant execute on function public.list_provider_subscription_plans() to authenticated;
grant execute on function public.get_provider_marketplace_access() to authenticated;
revoke all on public.subscription_plans,public.provider_subscriptions,public.subscription_events from anon;
revoke insert,update,delete on public.subscription_plans,public.provider_subscriptions,public.subscription_events from authenticated;
