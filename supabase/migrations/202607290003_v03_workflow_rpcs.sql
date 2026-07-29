-- OpenSlot v0.3 workflow RPCs. Kept separate so the new enum value is committed first.

alter table public.provider_profiles
  add column if not exists application_submitted_at timestamptz,
  add column if not exists approved_at timestamptz,
  add column if not exists approved_by uuid references public.profiles(id);

create or replace function public.submit_provider_application()
returns public.provider_profiles
language plpgsql security definer set search_path = public
as $$
declare result public.provider_profiles;
begin
  if not exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'provider' and account_status = 'active'
  ) then raise exception using errcode = '42501', message = 'provider_required'; end if;

  select * into result from public.provider_profiles where user_id = auth.uid() for update;
  if result.application_status = 'pending' then
    raise exception using errcode = '23505', message = 'application_already_pending';
  end if;
  if coalesce(result.business_name, '') = '' or coalesce(result.starting_postal_code, '') = ''
     or not exists (select 1 from public.provider_services where provider_id = auth.uid() and active)
  then raise exception using errcode = '23514', message = 'provider_onboarding_incomplete'; end if;

  update public.provider_profiles set application_status = 'pending', application_submitted_at = now(), updated_at = now()
  where user_id = auth.uid() returning * into result;
  insert into public.notifications(user_id,type,title,message)
  values(auth.uid(),'application_submitted','Application submitted','Your application is ready for manual administrator review.');
  insert into public.audit_events(actor_id,event_type,entity_type,entity_id)
  values(auth.uid(),'provider_application_submitted','provider',auth.uid());
  return result;
end $$;

create or replace function public.review_provider_application(p_provider_id uuid, p_action text, p_reason text default null)
returns public.provider_profiles
language plpgsql security definer set search_path = public
as $$
declare result public.provider_profiles; next_status application_status;
begin
  if not public.is_admin() then raise exception using errcode='42501', message='admin_required'; end if;
  if p_action in ('reject','request_information','suspend') and coalesce(trim(p_reason),'') = '' then
    raise exception using errcode='23514', message='reason_required';
  end if;
  next_status := case p_action when 'approve' then 'approved' when 'reject' then 'rejected'
    when 'request_information' then 'more_information' when 'pause' then 'paused'
    when 'suspend' then 'suspended' when 'reinstate' then 'approved'
    else null end;
  if next_status is null then raise exception using errcode='22023', message='invalid_admin_action'; end if;
  update public.provider_profiles
    set application_status=next_status, approved_at=case when next_status='approved' then now() else approved_at end,
        approved_by=case when next_status='approved' then auth.uid() else approved_by end, updated_at=now()
    where user_id=p_provider_id returning * into result;
  if result.user_id is null then raise exception using errcode='P0002', message='provider_not_found'; end if;
  insert into public.notifications(user_id,type,title,message)
    values(p_provider_id,'provider_'||p_action,'Provider application updated',
      case when p_reason is null then 'An administrator updated your application.' else p_reason end);
  insert into public.audit_events(actor_id,event_type,entity_type,entity_id,metadata)
    values(auth.uid(),'provider_'||p_action,'provider',p_provider_id,jsonb_build_object('reason',p_reason));
  return result;
end $$;

create or replace function public.recalculate_provider_rating(p_provider_id uuid)
returns void language sql security definer set search_path=public as $$
  update provider_profiles p set
    average_rating = coalesce((select round(avg(overall_rating),1) from reviews where provider_id=p_provider_id and status='active'),0),
    review_count = (select count(*) from reviews where provider_id=p_provider_id and status='active'), updated_at=now()
  where p.user_id=p_provider_id;
$$;
create or replace function public.review_rating_changed() returns trigger language plpgsql security definer set search_path=public as $$
begin perform public.recalculate_provider_rating(coalesce(new.provider_id,old.provider_id)); return coalesce(new,old); end $$;
create trigger review_rating_aggregate after insert or update or delete on public.reviews
for each row execute function public.review_rating_changed();

create or replace function public.expire_provider_requests()
returns integer language plpgsql security definer set search_path=public as $$
declare affected integer;
begin
  with expired as (update bookings set status='expired',updated_at=now()
    where status='requested' and provider_response_due_at < now() returning *)
  update appointment_openings o set status='published',updated_at=now()
    from expired e where o.id=e.opening_id and o.start_at>now() and o.expiration_at>now();
  get diagnostics affected = row_count; return affected;
end $$;

revoke all on function public.submit_provider_application() from public, anon;
revoke all on function public.review_provider_application(uuid,text,text) from public, anon;
revoke all on function public.recalculate_provider_rating(uuid) from public, anon, authenticated;
revoke all on function public.expire_provider_requests() from public, anon, authenticated;
grant execute on function public.submit_provider_application() to authenticated;
grant execute on function public.review_provider_application(uuid,text,text) to authenticated;

-- Browser users must use RPCs, never privileged direct updates.
revoke update(application_status, approved_at, approved_by, average_rating, review_count) on public.provider_profiles from authenticated;
