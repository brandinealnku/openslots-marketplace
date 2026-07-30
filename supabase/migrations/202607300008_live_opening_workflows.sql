create or replace function public.create_provider_opening(
 p_provider_service_id uuid, p_start_at timestamptz, p_duration_minutes integer,
 p_fixed_price numeric, p_starting_postal_code text, p_travel_radius_miles numeric,
 p_property_size_limit text, p_customer_requirements text, p_restrictions text,
 p_booking_method public.booking_method, p_expiration_at timestamptz
) returns public.appointment_openings language plpgsql security definer set search_path=public, pg_temp as $$
declare result appointment_openings;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='session_expired'; end if;
 if not exists(select 1 from profiles p join provider_profiles pp on pp.user_id=p.id
   where p.id=auth.uid() and p.role='provider' and p.account_status='active'
   and pp.application_status='approved') then raise exception using errcode='42501',message='provider_unapproved'; end if;
 if not exists(select 1 from provider_services where id=p_provider_service_id and provider_id=auth.uid() and active)
   then raise exception using errcode='22023',message='invalid_service'; end if;
 if p_start_at<=now()+interval '5 minutes' or p_duration_minutes not between 15 and 720
   or p_fixed_price not between 1 and 10000 or p_travel_radius_miles not between 0 and 100
   or nullif(trim(p_starting_postal_code),'') is null or p_starting_postal_code !~ '^[0-9]{5}(-[0-9]{4})?$'
   or p_expiration_at<=now() or p_expiration_at>p_start_at
   then raise exception using errcode='22023',message='opening_validation_failed'; end if;
 if exists(select 1 from appointment_openings where provider_id=auth.uid()
   and status in('published','reserved','booked') and tstzrange(start_at,end_at,'[)') &&
   tstzrange(p_start_at,p_start_at+make_interval(mins=>p_duration_minutes),'[)'))
   then raise exception using errcode='23505',message='duplicate_opening'; end if;
 insert into appointment_openings(provider_id,provider_service_id,status,booking_method,start_at,end_at,
  fixed_price,travel_radius_miles,starting_postal_code,property_size_limit,expiration_at,
  customer_requirements,restrictions,published_at)
 values(auth.uid(),p_provider_service_id,'published',p_booking_method,p_start_at,
  p_start_at+make_interval(mins=>p_duration_minutes),p_fixed_price,p_travel_radius_miles,
  trim(p_starting_postal_code),nullif(trim(p_property_size_limit),''),p_expiration_at,
  nullif(trim(p_customer_requirements),''),nullif(trim(p_restrictions),''),now()) returning * into result;
 insert into audit_events(actor_id,event_type,entity_type,entity_id) values(auth.uid(),'opening_created','opening',result.id);
 return result;
end$$;

create or replace function public.set_provider_opening_status(p_opening_id uuid,p_action text)
returns public.appointment_openings language plpgsql security definer set search_path=public, pg_temp as $$
declare o appointment_openings; next_status opening_status;
begin
 select * into o from appointment_openings where id=p_opening_id for update;
 if o.id is null then raise exception using errcode='P0002',message='record_not_found'; end if;
 if o.provider_id<>auth.uid() then raise exception using errcode='42501',message='permission_denied'; end if;
 if p_action='pause' and o.status='published' then next_status='paused';
 elsif p_action='reopen' and o.status='paused' and o.start_at>now() and o.expiration_at>now() then next_status='published';
 elsif p_action='cancel' and o.status in('published','paused','draft') then next_status='cancelled';
 else raise exception using errcode='22023',message='invalid_opening_transition'; end if;
 update appointment_openings set status=next_status,updated_at=now() where id=o.id returning * into o;
 insert into audit_events(actor_id,event_type,entity_type,entity_id,metadata)
 values(auth.uid(),'opening_status_changed','opening',o.id,jsonb_build_object('action',p_action,'to',next_status));
 return o;
end$$;

revoke all on function public.create_provider_opening(uuid,timestamptz,integer,numeric,text,numeric,text,text,text,public.booking_method,timestamptz) from public,anon;
revoke all on function public.set_provider_opening_status(uuid,text) from public,anon;
grant execute on function public.create_provider_opening(uuid,timestamptz,integer,numeric,text,numeric,text,text,text,public.booking_method,timestamptz) to authenticated;
grant execute on function public.set_provider_opening_status(uuid,text) to authenticated;

