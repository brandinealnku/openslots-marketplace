# Data model v0.2

The canonical, executable model is `supabase/migrations/202607290001_openslot_v2.sql`. Auth users own `profiles` plus role-specific `customer_profiles` or `provider_profiles`. Customers own addresses, saves, reviews, notifications, cases, and their side of bookings. Providers own services/add-ons, availability, openings, documents, and their booking side. Categories are shared reference data. Bookings snapshot all financial values and selected add-on names/prices. Photos store private Storage paths. Audit events preserve important workflow changes. Foreign keys, checks, partial uniqueness, triggers, indexes, transactional RPCs, and RLS provide integrity beyond browser validation.

## 0.3.4 workflow invariants
A published opening belongs to its authenticated approved provider. `create_booking` locks it and the partial unique booking index independently prevents two live bookings. Instant openings become `booked`/`confirmed`; approval openings become `reserved`/`requested`. Provider response updates booking/opening, notification and audit records atomically. See `BOOKING_STATUS_TRANSITIONS.md`.
