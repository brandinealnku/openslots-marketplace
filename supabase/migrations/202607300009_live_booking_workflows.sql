-- Harden the canonical booking transaction. A PostgreSQL function is itself atomic;
-- FOR UPDATE serializes contenders and the partial unique index is a second invariant.
create or replace function public.create_booking(p_opening_id uuid,p_service_address_id uuid,
 p_property_size text default null,p_grass_height text default null,p_gate_access text default null,
 p_pets_present boolean default false,p_special_instructions text default null,
 p_preferred_contact_method text default null,p_addon_ids uuid[] default '{}')
returns setof public.bookings language plpgsql security definer set search_path=public, pg_temp as $$
declare o appointment_openings; b bookings; addon_sum numeric:=0; valid_addons integer:=0; code text;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='session_expired'; end if;
 if not exists(select 1 from profiles p join customer_profiles cp on cp.user_id=p.id
   where p.id=auth.uid() and p.role='customer' and p.account_status='active')
   then raise exception using errcode='42501',message='customer_required'; end if;
 select * into o from appointment_openings where id=p_opening_id for update;
 if o.id is null then raise exception using errcode='P0002',message='record_not_found'; end if;
 if o.provider_id=auth.uid() then raise exception using errcode='42501',message='own_opening_forbidden'; end if;
 if o.status<>'published' or o.expiration_at<=now() or o.start_at<=now()
   then raise exception using errcode='P0001',message='opening_unavailable'; end if;
 if not exists(select 1 from provider_profiles pp join profiles p on p.id=pp.user_id
   where pp.user_id=o.provider_id and pp.application_status='approved' and p.account_status='active')
   then raise exception using errcode='P0001',message='opening_unavailable'; end if;
 if not exists(select 1 from addresses where id=p_service_address_id and user_id=auth.uid())
   then raise exception using errcode='22023',message='invalid_address'; end if;
 if p_preferred_contact_method not in('email','phone','text')
   then raise exception using errcode='22023',message='invalid_contact_preference'; end if;
 select count(*),coalesce(sum(price),0) into valid_addons,addon_sum from service_addons
   where id=any(coalesce(p_addon_ids,'{}')) and provider_service_id=o.provider_service_id and active;
 if valid_addons<>coalesce(array_length(p_addon_ids,1),0)
   then raise exception using errcode='22023',message='invalid_addon'; end if;
 code='OS-'||to_char(now(),'YYYY')||'-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,8));
 insert into bookings(confirmation_code,opening_id,customer_id,provider_id,service_address_id,status,
  service_subtotal,addon_total,booking_fee,estimated_tax,total,provider_payout_estimate,
  property_size,grass_height,gate_access,pets_present,special_instructions,preferred_contact_method,
  provider_response_due_at)
 values(code,o.id,auth.uid(),o.provider_id,p_service_address_id,
  case when o.booking_method='instant' then 'confirmed' else 'requested' end,
  o.fixed_price,addon_sum,4.99,round((o.fixed_price+addon_sum)*.06,2),
  o.fixed_price+addon_sum+4.99+round((o.fixed_price+addon_sum)*.06,2),
  round((o.fixed_price+addon_sum)*.88,2),p_property_size,p_grass_height,p_gate_access,p_pets_present,
  nullif(trim(p_special_instructions),''),p_preferred_contact_method,
  case when o.booking_method='provider_approval' then now()+interval '2 hours' end) returning * into b;
 update appointment_openings set status=case when o.booking_method='instant' then 'booked' else 'reserved' end,
  updated_at=now() where id=o.id;
 insert into booking_addons(booking_id,service_addon_id,name_snapshot,price_snapshot)
  select b.id,id,name,price from service_addons where id=any(coalesce(p_addon_ids,'{}'));
 insert into notifications(user_id,type,title,message,related_booking_id,related_opening_id) values
  (auth.uid(),'booking_created',case when b.status='confirmed' then 'Appointment confirmed' else 'Request sent' end,
   case when b.status='confirmed' then 'Your appointment is confirmed.' else 'Your request was sent to the provider.' end,b.id,o.id),
  (o.provider_id,case when b.status='confirmed' then 'opening_booked' else 'new_booking_request' end,
   case when b.status='confirmed' then 'Opening booked' else 'New booking request' end,
   'A customer reserved your opening.',b.id,o.id);
 insert into audit_events(actor_id,event_type,entity_type,entity_id,metadata)
  values(auth.uid(),'booking_created','booking',b.id,jsonb_build_object('status',b.status,'opening_id',o.id));
 return next b;
exception when unique_violation then
 raise exception using errcode='23505',message='opening_already_booked';
end$$;

create or replace function public.respond_to_booking_request(p_booking_id uuid,p_accept boolean,p_reason text default null)
returns public.bookings language plpgsql security definer set search_path=public, pg_temp as $$
declare b bookings; target booking_status;
begin
 select * into b from bookings where id=p_booking_id for update;
 if b.id is null then raise exception using errcode='P0002',message='record_not_found'; end if;
 if b.provider_id<>auth.uid() then raise exception using errcode='42501',message='permission_denied'; end if;
 if not exists(select 1 from profiles p join provider_profiles pp on pp.user_id=p.id
  where p.id=auth.uid() and p.role='provider' and p.account_status='active' and pp.application_status='approved')
  then raise exception using errcode='42501',message='provider_unapproved'; end if;
 if b.status<>'requested' then raise exception using errcode='22023',message='invalid_booking_transition'; end if;
 if b.provider_response_due_at<=now() then raise exception using errcode='22023',message='request_expired'; end if;
 if not p_accept and nullif(trim(p_reason),'') is null then raise exception using errcode='22023',message='decline_reason_required'; end if;
 target=case when p_accept then 'confirmed'::booking_status else 'declined'::booking_status end;
 update bookings set status=target,accepted_at=case when p_accept then now() end,
  declined_at=case when not p_accept then now() end,decline_reason=case when not p_accept then trim(p_reason) end,
  updated_at=now() where id=b.id returning * into b;
 update appointment_openings set status=case when p_accept then 'booked'::opening_status else
  case when start_at>now() and expiration_at>now() then 'published'::opening_status else 'expired'::opening_status end end,
  updated_at=now() where id=b.opening_id;
 insert into notifications(user_id,type,title,message,related_booking_id,related_opening_id)
 values(b.customer_id,case when p_accept then 'booking_confirmed' else 'booking_declined' end,
  case when p_accept then 'Booking confirmed' else 'Booking declined' end,
  case when p_accept then 'The provider accepted your request.' else 'The provider declined your request.' end,b.id,b.opening_id);
 insert into audit_events(actor_id,event_type,entity_type,entity_id,metadata)
 values(auth.uid(),'booking_status_changed','booking',b.id,jsonb_build_object('to',target,'reason',p_reason));
 return b;
end$$;

revoke all on function public.respond_to_booking_request(uuid,boolean,text) from public,anon;
grant execute on function public.respond_to_booking_request(uuid,boolean,text) to authenticated;

