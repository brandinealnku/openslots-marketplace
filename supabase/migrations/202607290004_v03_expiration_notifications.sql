-- Make request expiry atomic, observable, and safe to invoke from a trusted scheduler.
create or replace function public.expire_provider_requests()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  expired_count integer;
begin
  with expired as (
    update public.bookings
       set status = 'expired', updated_at = now()
     where status = 'requested'
       and provider_response_due_at < now()
     returning id, opening_id, customer_id, provider_id
  ), restored as (
    update public.appointment_openings opening
       set status = 'published', updated_at = now()
      from expired booking
     where opening.id = booking.opening_id
       and opening.start_at > now()
       and opening.expiration_at > now()
     returning opening.id
  ), notices as (
    insert into public.notifications (user_id, type, title, message, related_booking_id)
    select participant.user_id, 'request_expired', 'Booking request expired',
           'The provider response window ended before the request was accepted.',
           booking.id
      from expired booking
      cross join lateral (values (booking.customer_id), (booking.provider_id)) participant(user_id)
    returning 1
  ), audits as (
    insert into public.audit_events (event_type, entity_type, entity_id, metadata)
    select 'booking_request_expired', 'booking', id,
           jsonb_build_object('opening_id', opening_id)
      from expired
    returning 1
  )
  select count(*) into expired_count from expired;

  return expired_count;
end;
$$;

revoke all on function public.expire_provider_requests() from public, anon, authenticated;
comment on function public.expire_provider_requests() is
  'Expires overdue approval bookings. Invoke only from a trusted pg_cron job or server-side scheduler.';
