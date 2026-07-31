-- Run after reset with fixture UUIDs in a transaction. Assertions document the security contract.
begin;
select has_function_privilege('anon','public.search_provider_profiles(text,text,integer,integer)','execute');
select not has_table_privilege('anon','public.messages','select');
select not has_table_privilege('anon','public.custom_service_requests','select');
select proconfig from pg_proc where proname in('send_conversation_message','create_custom_service_request','respond_custom_request','propose_custom_request_time','accept_custom_request_proposal');
select policyname,tablename from pg_policies where tablename in('provider_portfolio_items','custom_service_requests','conversations','messages','custom_request_proposals','message_reports') order by tablename,policyname;
select bucket_id,name from storage.objects where false; -- storage schema is reachable without exposing rows
rollback;
