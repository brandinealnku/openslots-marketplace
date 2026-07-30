-- Run after migrations in a disposable/local project.
begin;
select plan(10);
select has_table('public','subscription_plans','plan catalog exists');
select has_table('public','provider_subscriptions','provider state exists');
select has_table('public','subscription_events','event ledger exists');
select has_function('public','get_provider_marketplace_access',array[]::text[],'access RPC exists');
select is((select count(*)::int from public.subscription_plans),3,'development defaults exist');
select ok((select relrowsecurity from pg_class where oid='public.provider_subscriptions'::regclass),'subscription RLS enabled');
select ok((select relrowsecurity from pg_class where oid='public.subscription_events'::regclass),'event RLS enabled');
select is((select count(*)::int from pg_policies where tablename='provider_subscriptions' and cmd in ('INSERT','UPDATE','DELETE')),0,'no provider mutation policy');
select ok(has_table_privilege('anon','public.provider_subscriptions','select')=false,'anonymous cannot select subscriptions');
select ok(has_table_privilege('authenticated','public.subscription_events','insert')=false,'providers cannot create events');
select * from finish();
rollback;
