# Data model v0.2

The canonical, executable model is `supabase/migrations/202607290001_openslot_v2.sql`. Auth users own `profiles` plus role-specific `customer_profiles` or `provider_profiles`. Customers own addresses, saves, reviews, notifications, cases, and their side of bookings. Providers own services/add-ons, availability, openings, documents, and their booking side. Categories are shared reference data. Bookings snapshot all financial values and selected add-on names/prices. Photos store private Storage paths. Audit events preserve important workflow changes. Foreign keys, checks, partial uniqueness, triggers, indexes, transactional RPCs, and RLS provide integrity beyond browser validation.

## 0.3.4 workflow invariants
A published opening belongs to its authenticated approved provider. `create_booking` locks it and the partial unique booking index independently prevents two live bookings. Instant openings become `booked`/`confirmed`; approval openings become `reserved`/`requested`. Provider response updates booking/opening, notification and audit records atomically. See `BOOKING_STATUS_TRANSITIONS.md`.

## Provider subscription model (0.3.5A)
`subscription_plans` stores configurable entitlements and server-private Stripe Price mappings. `provider_subscriptions` is one-to-one with a provider/user and stores Stripe object identifiers plus canonical status/period timestamps—never payment-method payloads. `subscription_events` is a unique Stripe-event ledger/audit trail. Only `trialing` and `active` provide access; detailed quota enforcement is deferred to 0.3.5B. Legacy booking monetary columns are historical marketplace prototypes and do not represent a payment processor.

## Relationship entities
`provider_portfolio_items` contains public image metadata; `saved_providers` remains customer-private. `conversations` bind customer/provider and optionally request/booking; `messages` are participant text with an idempotency nonce. `custom_service_requests` stores preference/recurrence/address and status; `custom_request_proposals` stores one live revised time. Conversion links `converted_booking_id`. Recurrence never generates a series in 0.3.6.
