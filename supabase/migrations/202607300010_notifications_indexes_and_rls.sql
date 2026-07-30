create index if not exists openings_provider_status_date on appointment_openings(provider_id,status,start_at);
create index if not exists bookings_customer_status_created on bookings(customer_id,status,created_at desc);
create index if not exists bookings_provider_status_created on bookings(provider_id,status,created_at desc);
create index if not exists applications_status_created on provider_profiles(application_status,created_at desc);
create index if not exists audit_entity_created on audit_events(entity_type,entity_id,created_at desc);

-- Providers must use workflow RPCs for opening mutations. Admin operations also use RPCs.
drop policy if exists openings_manage on appointment_openings;
create policy openings_owner_read on appointment_openings for select to authenticated
 using(provider_id=auth.uid() or public.is_admin());

drop policy if exists notifications_mark_read on notifications;
create policy notifications_mark_read on notifications for update to authenticated
 using(user_id=auth.uid()) with check(user_id=auth.uid());

-- Explicitly constrain browser table privileges; SECURITY DEFINER workflows remain the
-- only mutation path for bookings, openings, notifications and audit events.
revoke insert,update,delete on appointment_openings,bookings,notifications,audit_events from anon,authenticated;
grant select on bookings,notifications to authenticated;
grant update(read_at) on notifications to authenticated;

