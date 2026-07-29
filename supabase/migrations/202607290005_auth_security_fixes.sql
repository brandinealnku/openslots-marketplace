-- OpenSlot 0.3.1 authentication hardening. Additive and safe for linked projects.
alter function public.protect_profile_privileges() set search_path = public, pg_temp;
alter function public.validate_booking_provider() set search_path = public, pg_temp;
alter function public.validate_review() set search_path = public, pg_temp;

-- Only customer/provider are accepted from untrusted signup metadata. Admin remains owner-managed.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
declare requested public.user_role := case when new.raw_user_meta_data->>'requested_role' = 'provider' then 'provider'::public.user_role else 'customer'::public.user_role end;
begin
  insert into public.profiles(id,email,role,display_name)
  values(new.id,new.email,requested,nullif(trim(new.raw_user_meta_data->>'full_name'),''));
  if requested='provider' then insert into public.provider_profiles(user_id) values(new.id);
  else insert into public.customer_profiles(user_id) values(new.id); end if;
  insert into public.notifications(user_id,type,title,message) values(new.id,'registration','Welcome to OpenSlot','Your in-app account is ready.');
  return new;
end$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.review_rating_changed() from public, anon, authenticated;
revoke execute on function public.validate_booking_provider() from public, anon, authenticated;
revoke execute on function public.validate_review() from public, anon, authenticated;
revoke execute on function public.protect_profile_privileges() from public, anon, authenticated;
revoke execute on function public.is_admin() from public, anon;
revoke execute on function public.create_booking(uuid,uuid,text,text,text,boolean,text,text,uuid[]) from public, anon;
revoke execute on function public.transition_booking(uuid,public.booking_status,text) from public, anon;
revoke execute on function public.submit_provider_application() from public, anon;
revoke execute on function public.review_provider_application(uuid,text,text) from public, anon;

grant execute on function public.create_booking(uuid,uuid,text,text,text,boolean,text,text,uuid[]) to authenticated;
grant execute on function public.transition_booking(uuid,public.booking_status,text) to authenticated;
grant execute on function public.submit_provider_application() to authenticated;
-- This RPC performs its own active-admin check before mutation.
grant execute on function public.review_provider_application(uuid,text,text) to authenticated;
