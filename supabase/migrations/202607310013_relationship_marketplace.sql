-- OpenSlot 0.3.6 relationship marketplace. Public presentation data is deliberately
-- separated from provider contact, billing, application notes, and private documents.
alter table public.provider_profiles
  add column headline text check (char_length(headline)<=160),
  add column public_biography text check (char_length(public_biography)<=3000),
  add column profile_image_path text,
  add column business_logo_path text,
  add column service_areas text[] not null default '{}',
  add column languages text[] not null default '{}',
  add column availability_summary text check (char_length(availability_summary)<=500),
  add column payment_policy text check (char_length(payment_policy)<=1500),
  add column cancellation_policy text check (char_length(cancellation_policy)<=1500),
  add column custom_requests_enabled boolean not null default true;

create table public.provider_portfolio_items(
 id uuid primary key default gen_random_uuid(), provider_id uuid not null references public.provider_profiles(user_id) on delete cascade,
 storage_path text not null unique, alt_text text not null check(char_length(alt_text)<=200), sort_order int not null default 0,
 created_at timestamptz not null default now(), unique(provider_id,sort_order));

create table public.custom_service_requests(
 id uuid primary key default gen_random_uuid(), customer_id uuid not null references public.customer_profiles(user_id),
 provider_id uuid not null references public.provider_profiles(user_id), provider_service_id uuid not null references public.provider_services(id),
 preferred_start_at timestamptz not null, preferred_end_at timestamptz not null, alternative_start_at timestamptz,
 recurrence text not null default 'one_time' check(recurrence in('one_time','weekly','biweekly','monthly','custom')),
 recurrence_detail text, service_address_id uuid not null references public.addresses(id), task_details text not null check(char_length(task_details) between 10 and 3000),
 customer_notes text check(char_length(customer_notes)<=2000), payment_policy_acknowledged_at timestamptz not null,
 status text not null default 'submitted' check(status in('draft','submitted','viewed','needs_information','proposed','accepted','declined','expired','canceled','converted_to_booking')),
 expires_at timestamptz not null default(now()+interval '7 days'), converted_booking_id uuid references public.bookings(id),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(), check(preferred_end_at>preferred_start_at));

create table public.conversations(
 id uuid primary key default gen_random_uuid(), customer_id uuid not null references public.customer_profiles(user_id), provider_id uuid not null references public.provider_profiles(user_id),
 booking_id uuid references public.bookings(id), custom_request_id uuid references public.custom_service_requests(id),
 kind text not null check(kind in('inquiry','custom_request','booking')), status text not null default 'active' check(status in('active','archived','closed')),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(), last_message_at timestamptz,
 check(booking_id is not null or custom_request_id is not null or kind='inquiry'));
alter table public.custom_service_requests add column conversation_id uuid references public.conversations(id);

create table public.messages(
 id uuid primary key default gen_random_uuid(), conversation_id uuid not null references public.conversations(id) on delete cascade,
 sender_id uuid not null references public.profiles(id), body text not null check(char_length(btrim(body)) between 1 and 4000),
 message_type text not null default 'text' check(message_type in('text','system')), moderation_state text not null default 'unreviewed',
 client_nonce uuid not null, created_at timestamptz not null default now(), edited_at timestamptz, read_at timestamptz,
 unique(conversation_id,sender_id,client_nonce));
create table public.custom_request_proposals(
 id uuid primary key default gen_random_uuid(), request_id uuid not null references public.custom_service_requests(id) on delete cascade,
 provider_id uuid not null references public.provider_profiles(user_id), start_at timestamptz not null, duration_minutes int not null check(duration_minutes between 15 and 1440),
 listed_service_amount numeric(10,2) not null check(listed_service_amount>=0), notes text check(char_length(notes)<=1500), expires_at timestamptz not null,
 status text not null default 'pending' check(status in('pending','accepted','declined','expired')), created_at timestamptz not null default now());
create unique index one_pending_custom_proposal on public.custom_request_proposals(request_id) where status='pending';
create table public.message_reports(id uuid primary key default gen_random_uuid(),message_id uuid not null references public.messages(id),reported_by uuid not null references public.profiles(id),reason text not null check(char_length(reason) between 3 and 500),status text not null default 'open',created_at timestamptz not null default now(),unique(message_id,reported_by));

alter table public.notifications add column conversation_id uuid references public.conversations(id), add column custom_request_id uuid references public.custom_service_requests(id);

create or replace function public.search_provider_profiles(p_service text default null,p_postal_code text default null,p_limit int default 20,p_offset int default 0) returns table(provider_id uuid,display_name text,headline text,biography text,years_experience int,profile_image_path text,business_logo_path text,service_areas text[],travel_radius_miles numeric,languages text[],availability_summary text,payment_policy text,cancellation_policy text,custom_requests_enabled boolean,average_rating numeric,review_count int,completed_booking_count int,member_since timestamptz,services jsonb,portfolio jsonb,earliest_opening timestamptz,total_count bigint) language sql stable security definer set search_path=public as $$
 with eligible as(select p.*,count(*) over() total from provider_profiles p where p.application_status='approved' and exists(select 1 from provider_subscriptions s where s.user_id=p.user_id and s.status in('trialing','active')) and (p_postal_code is null or p_postal_code='' or p_postal_code=any(p.service_areas)) and (p_service is null or p_service='' or exists(select 1 from provider_services ps join service_categories sc on sc.id=ps.service_category_id where ps.provider_id=p.user_id and ps.active and sc.name ilike '%'||p_service||'%')) order by p.average_rating desc,p.created_at desc limit least(greatest(p_limit,1),50) offset greatest(p_offset,0))
 select e.user_id,coalesce(nullif(e.business_name,''),'Local provider'),e.headline,e.public_biography,e.years_experience,e.profile_image_path,e.business_logo_path,e.service_areas,e.travel_radius_miles,e.languages,e.availability_summary,e.payment_policy,e.cancellation_policy,e.custom_requests_enabled,e.average_rating,e.review_count,e.completed_job_count,e.created_at,
 coalesce((select jsonb_agg(jsonb_build_object('id',ps.id,'name',sc.name,'description',ps.description,'starting_rate',ps.base_price,'rate_unit','service') order by sc.name) from provider_services ps join service_categories sc on sc.id=ps.service_category_id where ps.provider_id=e.user_id and ps.active),'[]'),
 coalesce((select jsonb_agg(jsonb_build_object('id',pi.id,'storage_path',pi.storage_path,'alt_text',pi.alt_text) order by pi.sort_order) from provider_portfolio_items pi where pi.provider_id=e.user_id),'[]'),
 (select min(a.start_at) from appointment_openings a where a.provider_id=e.user_id and a.status='published' and a.start_at>now() and a.expiration_at>now()),e.total from eligible e$$;
revoke all on function public.search_provider_profiles(text,text,int,int) from public;grant execute on function public.search_provider_profiles(text,text,int,int) to anon,authenticated;
alter table public.provider_portfolio_items enable row level security; alter table public.custom_service_requests enable row level security;
alter table public.conversations enable row level security; alter table public.messages enable row level security;
alter table public.custom_request_proposals enable row level security; alter table public.message_reports enable row level security;

create or replace function public.is_conversation_participant(cid uuid) returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from conversations where id=cid and (customer_id=auth.uid() or provider_id=auth.uid())) or is_admin()$$;
revoke all on function public.is_conversation_participant(uuid) from public; grant execute on function public.is_conversation_participant(uuid) to authenticated;
create policy portfolio_public_read on public.provider_portfolio_items for select using(exists(select 1 from provider_profiles p where p.user_id=provider_id and p.application_status='approved'));
create policy portfolio_owner_write on public.provider_portfolio_items for all to authenticated using(provider_id=auth.uid()) with check(provider_id=auth.uid());
create policy request_participants_read on public.custom_service_requests for select to authenticated using(customer_id=auth.uid() or provider_id=auth.uid() or is_admin());
create policy conversation_participants_read on public.conversations for select to authenticated using(customer_id=auth.uid() or provider_id=auth.uid() or is_admin());
create policy messages_participants_read on public.messages for select to authenticated using(is_conversation_participant(conversation_id));
create policy proposals_participants_read on public.custom_request_proposals for select to authenticated using(exists(select 1 from custom_service_requests r where r.id=request_id and (r.customer_id=auth.uid() or r.provider_id=auth.uid())) or is_admin());
create policy reports_create on public.message_reports for insert to authenticated with check(reported_by=auth.uid() and is_conversation_participant((select conversation_id from messages where id=message_id)));
create policy reports_admin_read on public.message_reports for select to authenticated using(is_admin() or reported_by=auth.uid());
revoke insert,update,delete on public.custom_service_requests,public.conversations,public.messages,public.custom_request_proposals from anon,authenticated;

create or replace function public.send_conversation_message(p_conversation_id uuid,p_body text,p_client_nonce uuid) returns public.messages language plpgsql security definer set search_path=public as $$declare c conversations;m messages;begin
 select * into c from conversations where id=p_conversation_id and status='active' for update;
 if c.id is null or auth.uid() not in(c.customer_id,c.provider_id) then raise exception using errcode='42501',message='conversation_forbidden'; end if;
 if char_length(btrim(p_body)) not between 1 and 4000 then raise exception using errcode='22023',message='invalid_message'; end if;
 insert into messages(conversation_id,sender_id,body,client_nonce) values(c.id,auth.uid(),btrim(p_body),p_client_nonce) on conflict(conversation_id,sender_id,client_nonce) do update set body=excluded.body returning * into m;
 update conversations set last_message_at=m.created_at,updated_at=now() where id=c.id;
 insert into notifications(user_id,type,title,message,conversation_id) values(case when auth.uid()=c.customer_id then c.provider_id else c.customer_id end,'new_message','New OpenSlot message','A conversation has a new message.',c.id);
 return m;end$$;

create or replace function public.create_custom_service_request(p_provider_id uuid,p_provider_service_id uuid,p_preferred_start_at timestamptz,p_preferred_end_at timestamptz,p_alternative_start_at timestamptz,p_recurrence text,p_recurrence_detail text,p_service_address_id uuid,p_task_details text,p_customer_notes text) returns public.custom_service_requests language plpgsql security definer set search_path=public as $$declare r custom_service_requests;c conversations;begin
 if not exists(select 1 from profiles where id=auth.uid() and role='customer' and account_status='active') then raise exception using errcode='42501',message='customer_required'; end if;
 if not exists(select 1 from addresses where id=p_service_address_id and user_id=auth.uid()) then raise exception using errcode='42501',message='address_forbidden'; end if;
 if not exists(select 1 from provider_services s join provider_profiles p on p.user_id=s.provider_id join provider_subscriptions ps on ps.user_id=p.user_id where s.id=p_provider_service_id and s.provider_id=p_provider_id and s.active and p.application_status='approved' and p.custom_requests_enabled and ps.status in('trialing','active')) then raise exception using errcode='42501',message='provider_unavailable'; end if;
 insert into custom_service_requests(customer_id,provider_id,provider_service_id,preferred_start_at,preferred_end_at,alternative_start_at,recurrence,recurrence_detail,service_address_id,task_details,customer_notes,payment_policy_acknowledged_at) values(auth.uid(),p_provider_id,p_provider_service_id,p_preferred_start_at,p_preferred_end_at,p_alternative_start_at,p_recurrence,p_recurrence_detail,p_service_address_id,p_task_details,p_customer_notes,now()) returning * into r;
 insert into conversations(customer_id,provider_id,custom_request_id,kind) values(auth.uid(),p_provider_id,r.id,'custom_request') returning * into c; update custom_service_requests set conversation_id=c.id where id=r.id returning * into r;
 insert into notifications(user_id,type,title,message,conversation_id,custom_request_id) values(p_provider_id,'custom_request_received','New custom request','Review the requested service details and reply on OpenSlot.',c.id,r.id);
 insert into audit_events(actor_id,event_type,entity_type,entity_id) values(auth.uid(),'custom_request_submitted','custom_request',r.id); return r;end$$;

create or replace function public.respond_custom_request(p_request_id uuid,p_action text,p_reason text default null) returns public.custom_service_requests language plpgsql security definer set search_path=public as $$declare r custom_service_requests;begin select * into r from custom_service_requests where id=p_request_id for update;
 if r.provider_id<>auth.uid() or r.status not in('submitted','viewed','needs_information','proposed') then raise exception using errcode='42501',message='invalid_request_transition'; end if;
 if p_action not in('accepted','declined','needs_information') then raise exception using errcode='22023',message='invalid_request_transition'; end if;
 update custom_service_requests set status=p_action,updated_at=now() where id=r.id returning * into r;
 insert into notifications(user_id,type,title,message,conversation_id,custom_request_id) values(r.customer_id,'custom_request_'||p_action,'Custom request updated','Your provider updated the request.',r.conversation_id,r.id);
 insert into audit_events(actor_id,event_type,entity_type,entity_id,metadata) values(auth.uid(),'custom_request_'||p_action,'custom_request',r.id,jsonb_build_object('reason',p_reason));return r;end$$;

create or replace function public.propose_custom_request_time(p_request_id uuid,p_start_at timestamptz,p_duration_minutes int,p_listed_service_amount numeric,p_notes text,p_expires_at timestamptz) returns public.custom_request_proposals language plpgsql security definer set search_path=public as $$declare r custom_service_requests;q custom_request_proposals;begin select * into r from custom_service_requests where id=p_request_id for update;
 if r.provider_id<>auth.uid() or r.status not in('submitted','viewed','needs_information','proposed') then raise exception using errcode='42501',message='invalid_request_transition'; end if;
 insert into custom_request_proposals(request_id,provider_id,start_at,duration_minutes,listed_service_amount,notes,expires_at) values(r.id,auth.uid(),p_start_at,p_duration_minutes,p_listed_service_amount,p_notes,p_expires_at) returning * into q;update custom_service_requests set status='proposed',updated_at=now() where id=r.id;
 insert into notifications(user_id,type,title,message,conversation_id,custom_request_id) values(r.customer_id,'revised_time_proposed','A different time was proposed','Review the proposed appointment in OpenSlot.',r.conversation_id,r.id);return q;end$$;

create or replace function public.accept_custom_request_proposal(p_proposal_id uuid) returns public.bookings language plpgsql security definer set search_path=public as $$declare q custom_request_proposals;r custom_service_requests;o appointment_openings;b bookings;begin
 select * into q from custom_request_proposals where id=p_proposal_id for update; select * into r from custom_service_requests where id=q.request_id for update;
 if r.customer_id<>auth.uid() then raise exception using errcode='42501',message='proposal_forbidden'; end if;
 if r.converted_booking_id is not null then select * into b from bookings where id=r.converted_booking_id; return b; end if;
 if q.status<>'pending' or r.status<>'proposed' or q.expires_at<=now() then raise exception using errcode='22023',message='proposal_unavailable'; end if;
 if exists(select 1 from bookings x join appointment_openings a on a.id=x.opening_id where x.provider_id=r.provider_id and x.status in('requested','confirmed','provider_en_route','in_progress') and tstzrange(a.start_at,a.end_at,'[)') && tstzrange(q.start_at,q.start_at+make_interval(mins=>q.duration_minutes),'[)')) then raise exception using errcode='23P01',message='time_conflict'; end if;
 insert into appointment_openings(provider_id,provider_service_id,status,booking_method,start_at,end_at,fixed_price,expiration_at,published_at) values(r.provider_id,r.provider_service_id,'booked','instant',q.start_at,q.start_at+make_interval(mins=>q.duration_minutes),q.listed_service_amount,q.start_at,now()) returning * into o;
 insert into bookings(confirmation_code,opening_id,customer_id,provider_id,service_address_id,status,service_subtotal,addon_total,booking_fee,estimated_tax,total,provider_payout_estimate,special_instructions,requested_at,accepted_at) values('OS-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),o.id,r.customer_id,r.provider_id,r.service_address_id,'confirmed',q.listed_service_amount,0,0,0,q.listed_service_amount,q.listed_service_amount,r.task_details,now(),now()) returning * into b;
 update custom_request_proposals set status='accepted' where id=q.id; update custom_service_requests set status='converted_to_booking',converted_booking_id=b.id,updated_at=now() where id=r.id; update conversations set booking_id=b.id,kind='booking',updated_at=now() where id=r.conversation_id;
 insert into notifications(user_id,type,title,message,related_booking_id,conversation_id,custom_request_id) values(r.provider_id,'booking_created_from_request','Custom request booked','The proposed appointment was accepted.',b.id,r.conversation_id,r.id),(r.customer_id,'booking_created_from_request','Appointment confirmed','Your custom request is now a booking.',b.id,r.conversation_id,r.id);
 insert into audit_events(actor_id,event_type,entity_type,entity_id,metadata) values(auth.uid(),'custom_request_converted','custom_request',r.id,jsonb_build_object('booking_id',b.id)); return b;end$$;

grant execute on function public.send_conversation_message(uuid,text,uuid),public.create_custom_service_request(uuid,uuid,timestamptz,timestamptz,timestamptz,text,text,uuid,text,text),public.respond_custom_request(uuid,text,text),public.propose_custom_request_time(uuid,timestamptz,int,numeric,text,timestamptz),public.accept_custom_request_proposal(uuid) to authenticated;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('provider-public-images','provider-public-images',true,5242880,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
create policy provider_images_public_read on storage.objects for select using(bucket_id='provider-public-images');
create policy provider_images_owner_insert on storage.objects for insert to authenticated with check(bucket_id='provider-public-images' and (storage.foldername(name))[1]=auth.uid()::text);
create policy provider_images_owner_change on storage.objects for update to authenticated using(bucket_id='provider-public-images' and owner_id=auth.uid()::text) with check(bucket_id='provider-public-images' and (storage.foldername(name))[1]=auth.uid()::text);
create policy provider_images_owner_delete on storage.objects for delete to authenticated using(bucket_id='provider-public-images' and owner_id=auth.uid()::text);
