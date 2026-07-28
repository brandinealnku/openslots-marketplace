# OpenSlot: Next Functional Version

## A. Authentication
Use **Supabase Auth** because it pairs managed authentication with the recommended PostgreSQL store, Row Level Security, social OAuth, and a credible MVP price point. Support customer, provider, and admin accounts; verified email; reset; Google/Apple sign-in; MFA for admins; and server-enforced role claims. Never trust a client role switcher.

## B. Database
Use Supabase PostgreSQL with UUID keys, timestamps, soft-delete/audit fields, spatial indexes, RLS, migrations, and generated TypeScript types.

| Table | Purpose and important fields |
|---|---|
| `users` | Auth mirror: id, email, phone, role, status |
| `customer_profiles` | user_id, display_name, preferences |
| `provider_profiles` | user_id, business, bio, status, radius, rating aggregates |
| `provider_services` | provider_id, category_id, active, pricing rules |
| `provider_documents` | provider_id, kind, storage_key, review/expiry status |
| `service_categories` | name, risk class, active |
| `service_packages` | provider/category, scope, size limits, base price |
| `availability_slots` | provider schedule availability and recurrence |
| `appointment_openings` | provider, package, start/end, expiration, price, status, location |
| `bookings` | opening/customer, address, status, totals, version |
| `booking_addons` | booking, label, quantity, unit price snapshot |
| `booking_photos` | booking, owner, kind, storage key, moderation status |
| `reviews` | booking/customer/provider, five dimension scores, text |
| `payments` | booking, processor IDs, amount, status, idempotency key |
| `payouts` | provider/payment, gross, fee, net, transfer status |
| `disputes` | booking, reason, evidence, owner, resolution |
| `messages` | booking/thread/sender, body, attachment, moderation flags |
| `notifications` | user, event, channel, delivery/read status |
| `service_areas` | provider, geometry/ZIP, radius and active flag |
| `addresses` | user/booking, normalized address and coordinates |
| `route_suggestions` | provider, opening, score inputs, state, explanation |
| `audit_logs` | actor, action, entity, before/after, IP and timestamp |

## C. Real payment processing
Use **Stripe Connect Express** for connected provider accounts, customer PaymentIntents, configurable application fees, payouts, refunds, and disputes. Verify signed, idempotent webhooks. Evaluate authorization/delayed capture until provider acceptance, payout holds through completion, 1099/tax obligations, refund reserves, and state sales-tax treatment with qualified tax and legal advisers. Do not collect card data directly.

## D. Maps and geolocation
Start with **Mapbox** for autocomplete, geocoding, polished maps, travel matrices, and route estimation while retaining provider portability. Store PostGIS points/polygons for service areas. Add address validation, nearby discovery, driving—not straight-line—distance, distance pricing, and route optimization. Restrict precise customer coordinates until a booking is accepted.

## E. Real-time notifications
Use Resend for transactional email, Twilio for opt-in SMS, Firebase Cloud Messaging for push, and database-backed in-app notifications. Events: new booking, accepted/declined, en route, completed, either-party cancellation, new review, opening expiry warning, and payout processed. Add preferences, quiet hours, retries, delivery logs, unsubscribe/STOP handling, and templating.

## F. Provider verification
Combine identity vendor checks, business registry review, insurance-document validation, appropriate category/background/license checks, Stripe bank-account verification, and manual admin review. Track reviewer, evidence, expiry and renewal reminders. Consult counsel on category- and jurisdiction-specific requirements; never imply a check guarantees safety.

## G. Messaging
Create booking-scoped threads with signed photo uploads, masked contact details, automated safety reminders, abuse reporting, admin review with strict permissions, malware scanning, rate limits, and documented retention/deletion. Make moderation access auditable.

## H. Scheduling
Add recurring availability, Google Calendar and Microsoft Outlook OAuth sync, buffers, travel blocks, blackout periods, automatic gap detection, rescheduling, waitlists, time-zone handling, and transactional slot locks. Calendar webhooks and optimistic concurrency must prevent double bookings.

## I. AI and automation
**Practical automation:** deterministic gap detection, route-distance ranking, expiration reminders, configurable discounts, and rules-based fraud flags. **Later experiments:** demand/price suggestions, photo-assisted service classification and property-size anomaly flags, support drafting, review summaries, dispute-risk signals, and forecasting. Show reasons and confidence, measure bias, protect photos, require provider/customer confirmation, and keep humans responsible for adverse decisions. Never present suggestions as verified facts.

## J. Marketplace operations
Staff customer/provider support, documented triage and escalation, dispute/refund SLAs, evidence-based damage claims, fraud and chargeback controls, marketplace insurance review, proportionate suspension/appeals, immutable audit logs, and retention/deletion schedules. Engage marketplace counsel, tax advisers, and insurance professionals before accepting live transactions.
