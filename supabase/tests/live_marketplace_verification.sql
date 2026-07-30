-- Run against a disposable local database after representative auth users are created.
begin;
do $$declare names text[];begin select array_agg(column_name order by ordinal_position) into names from information_schema.routine_columns where specific_schema='public' and routine_name='search_marketplace_openings';if names && array['email','phone','storage_path','application_reason','address_line_1'] then raise exception 'private public-query column';end if;end$$;
do $$begin if not exists(select 1 from pg_indexes where schemaname='public' and tablename='bookings' and indexname='one_live_booking_per_opening') then raise exception 'missing live-booking uniqueness';end if;if exists(select 1 from information_schema.role_table_grants where grantee in('anon','authenticated') and table_name in('bookings','appointment_openings','audit_events') and privilege_type in('INSERT','UPDATE','DELETE')) then raise exception 'privileged browser write grant';end if;end$$;
-- Actor-specific and two-session cases are in MANUAL_TEST_PLAN_V034.md because auth users are not portable fixtures.
rollback;
