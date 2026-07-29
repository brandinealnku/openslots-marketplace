# OpenSlot v0.3 multi-browser test plan

Use a fresh Supabase development project, apply migrations in order, and create four fictional Auth users: two customers, one provider, and one administrator. Promote only the administrator through the SQL Editor as described in `SUPABASE_SETUP.md`. Keep DevTools open and verify that private records never appear in another account's network responses.

## Customer browser

1. Register and confirm the email; sign in again after a refresh.
2. Complete the profile and create, edit, default, and delete an address.
3. Search by category, date, price, rating, method, provider, and ZIP; open a result.
4. Select add-ons, upload each supported property-photo type, submit once, and record the confirmation code.
5. Refresh and open a second browser with the same account; confirm the booking persists.
6. Save/unsave the provider, read notifications, cancel an eligible booking, review a completed booking, and create a support case.

## Provider browser

1. Register as provider; persist every onboarding step, one active service and add-on.
2. Upload a private document, verify the prototype-verification notice, and submit once.
3. After admin approval, create/publish/pause/resume/duplicate/cancel an opening.
4. Open an assigned request and its authorized photos; accept one and decline another with a reason.
5. Move a confirmed job through en-route, in-progress, and completed; verify notifications and estimated/simulated earnings.

## Administrator browser

1. Sign in directly; verify a normal account cannot open admin records or invoke the review RPC.
2. Review the application, services, prior actions, and a temporary signed document URL.
3. Test request-information, reject, approve, pause, suspend, and reinstate (using separate providers as needed).
4. Review bookings/support cases, moderate a review without deleting it, and compare every dashboard metric with SQL counts.

## Atomic concurrency

1. Publish one instant opening. In two isolated customer browsers, load its detail page before either books.
2. Submit both bookings as nearly simultaneously as possible.
3. Exactly one must succeed; the loser must see the friendly just-booked message. SQL must show one live booking, one final opening state, and one set of booking add-ons/price snapshots.

## Privacy/RLS

Attempt direct REST and Storage requests with each account's access token. Customer A cannot read Customer B's booking; Provider A cannot read Provider B's booking; customers cannot read provider documents; providers cannot read unrelated booking photos; and normal users cannot read audit/admin data or execute administrator actions.

## Responsive and recovery matrix

Repeat sign-in, search, booking, uploads, tables, and navigation at 375, 768, 1024, and 1440 px. Exercise keyboard-only use, visible focus, status announcements, offline/retry, expired recovery links, and reconnect after disabling Realtime. Realtime loss must never affect database correctness.
