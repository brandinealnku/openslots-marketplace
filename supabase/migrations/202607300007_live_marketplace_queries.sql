-- Public-safe marketplace projection. This invoker function deliberately returns no
-- provider contact, document, address, customer, audit, or moderation columns.
create or replace function public.search_marketplace_openings(
  p_service text default null, p_postal_code text default null, p_date date default null,
  p_time_of_day text default null, p_max_price numeric default null,
  p_min_rating numeric default null, p_booking_method public.booking_method default null,
  p_sort text default 'soonest', p_limit integer default 20, p_offset integer default 0
) returns table (
  id uuid, service text, start_at timestamptz, end_at timestamptz,
  duration_minutes integer, price numeric, service_area text, provider_name text,
  average_rating numeric, review_count integer, booking_method public.booking_method,
  scope text[], excluded_scope text[], addons jsonb, expiration_at timestamptz,
  property_size_limit text, customer_requirements text, restrictions text,
  provider_verified boolean, total_count bigint
) language sql stable security definer set search_path = public, pg_temp as $$
  select o.id, c.name, o.start_at, o.end_at,
    extract(epoch from (o.end_at-o.start_at))::integer/60, o.fixed_price,
    o.starting_postal_code, coalesce(nullif(pp.business_name,''), pr.display_name, 'OpenSlot provider'),
    pp.average_rating, pp.review_count, o.booking_method, ps.included_work,
    ps.excluded_work,
    coalesce((select jsonb_agg(jsonb_build_object('id',a.id,'name',a.name,'description',a.description,'price',a.price)
      order by a.name) from service_addons a where a.provider_service_id=ps.id and a.active),'[]'::jsonb),
    o.expiration_at, o.property_size_limit, o.customer_requirements, o.restrictions,
    (pp.verification_status='verified'), count(*) over()
  from appointment_openings o
  join provider_profiles pp on pp.user_id=o.provider_id
  join profiles pr on pr.id=o.provider_id
  join provider_services ps on ps.id=o.provider_service_id and ps.provider_id=o.provider_id
  join service_categories c on c.id=ps.service_category_id
  where o.status='published' and o.expiration_at>now() and o.start_at>now()
    and pp.application_status='approved' and pr.account_status='active' and ps.active and c.active
    and (p_service is null or p_service='' or lower(c.name)=lower(p_service))
    and (p_postal_code is null or p_postal_code='' or o.starting_postal_code=p_postal_code)
    and (p_date is null or o.start_at::date=p_date)
    and (p_max_price is null or (p_max_price between 0 and 100000 and o.fixed_price<=p_max_price))
    and (p_min_rating is null or (p_min_rating between 0 and 5 and pp.average_rating>=p_min_rating))
    and (p_booking_method is null or o.booking_method=p_booking_method)
    and (p_time_of_day is null or p_time_of_day='any'
      or (p_time_of_day='morning' and extract(hour from o.start_at)<12)
      or (p_time_of_day='afternoon' and extract(hour from o.start_at) between 12 and 16)
      or (p_time_of_day='evening' and extract(hour from o.start_at)>=17))
  order by
    case when p_sort='price' then o.fixed_price end asc,
    case when p_sort='rating' then pp.average_rating end desc,
    case when p_sort='newest' then extract(epoch from o.created_at) end desc,
    o.start_at asc
  limit least(greatest(coalesce(p_limit,20),1),50)
  offset greatest(coalesce(p_offset,0),0)
$$;

revoke all on function public.search_marketplace_openings(text,text,date,text,numeric,numeric,public.booking_method,text,integer,integer) from public;
grant execute on function public.search_marketplace_openings(text,text,date,text,numeric,numeric,public.booking_method,text,integer,integer) to anon, authenticated;

create or replace function public.get_marketplace_opening(p_opening_id uuid)
returns setof record language sql stable security definer set search_path=public, pg_temp as $$
  select * from public.search_marketplace_openings(null,null,null,null,null,null,null,'soonest',50,0)
  where id=p_opening_id
$$;
-- PostgREST cannot infer anonymous record output; detail uses the search RPC with a
-- bounded page until a typed detail function is needed. No grant is made here.
revoke all on function public.get_marketplace_opening(uuid) from public, anon, authenticated;

