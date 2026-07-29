-- OpenSlot v0.3 additive integration and privilege hardening.
-- This migration deliberately leaves the already-deployed v0.2 migration intact.

alter type public.booking_status add value if not exists 'expired';
