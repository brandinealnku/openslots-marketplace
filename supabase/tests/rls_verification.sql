-- Run after creating two customers, one provider and one admin; replace UUID placeholders.
begin; set local role authenticated; select set_config('request.jwt.claim.sub','CUSTOMER_A_UUID',true);
select * from addresses where user_id='CUSTOMER_B_UUID'; -- expect 0
select * from bookings where customer_id='CUSTOMER_B_UUID'; -- expect 0
select * from provider_documents; -- expect 0 unless current user owns documents
rollback;
-- Concurrency: run create_booking for the same opening in two sessions. Exactly one succeeds;
-- the row lock plus one_live_booking_per_opening rejects the loser with opening_unavailable.
-- Review: inserting against a non-completed/unowned booking must raise review not eligible.
