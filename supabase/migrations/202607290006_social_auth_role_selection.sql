-- OpenSlot 0.3.2 social authentication role selection.
-- Additive: existing profiles keep their role; new OAuth profiles must explicitly choose once.
alter table public.profiles add column if not exists role_selected_at timestamptz;

-- All profiles created before this migration already made an explicit registration choice.
update public.profiles set role_selected_at = coalesce(role_selected_at, created_at, now());

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  requested public.user_role;
  selected_at timestamptz;
begin
  if new.raw_user_meta_data->>'requested_role' in ('customer','provider') then
    requested := (new.raw_user_meta_data->>'requested_role')::public.user_role;
    selected_at := now();
  else
    -- OAuth providers do not get to assign authorization data through user metadata.
    requested := 'customer'::public.user_role;
    selected_at := null;
  end if;

  insert into public.profiles(id,email,role,display_name,role_selected_at)
  values(new.id,new.email,requested,
    nullif(trim(coalesce(new.raw_user_meta_data->>'full_name',new.raw_user_meta_data->>'name','')),''),
    selected_at);

  if selected_at is not null and requested='provider' then
    insert into public.provider_profiles(user_id) values(new.id);
  elsif selected_at is not null then
    insert into public.customer_profiles(user_id) values(new.id);
  end if;
  insert into public.notifications(user_id,type,title,message)
  values(new.id,'registration','Welcome to OpenSlot','Your in-app account is ready.');
  return new;
end$$;

create or replace function public.select_initial_role(requested_role public.user_role)
returns public.user_role
language plpgsql security definer set search_path = public, pg_temp as $$
declare chosen public.user_role;
begin
  if auth.uid() is null then raise exception 'authentication_required'; end if;
  if requested_role not in ('customer','provider') then raise exception 'invalid_role'; end if;

  update public.profiles
     set role=requested_role, role_selected_at=now(), updated_at=now()
   where id=auth.uid() and role_selected_at is null and account_status='active'
   returning role into chosen;
  if chosen is null then raise exception 'role_already_selected_or_account_inactive'; end if;

  delete from public.customer_profiles where user_id=auth.uid();
  delete from public.provider_profiles where user_id=auth.uid();
  if chosen='provider' then insert into public.provider_profiles(user_id) values(auth.uid());
  else insert into public.customer_profiles(user_id) values(auth.uid()); end if;
  return chosen;
end$$;

revoke execute on function public.select_initial_role(public.user_role) from public, anon;
grant execute on function public.select_initial_role(public.user_role) to authenticated;
revoke execute on function public.handle_new_user() from public, anon, authenticated;
