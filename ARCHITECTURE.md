# OpenSlot v0.2 architecture

The React/Vite/hash-router design is retained. `src/lib` validates public browser configuration and provides a typed Supabase HTTP boundary; domain modules in `src/services` own auth, profile, opening, booking, review, storage, and admin operations. Mock context remains only for explicit `VITE_APP_MODE=demo`; connected records must never silently mix with it.

Supabase Auth identities map one-to-one to `profiles`; an `auth.users` trigger creates the base customer/provider record. A trigger blocks self-promotion and account-status edits. Admins are bootstrapped out of band. UI route guards should use the database role, while RLS remains authoritative.

The migration normalizes accounts, services, availability, openings, bookings and snapshots, photos, saves, reviews, notifications, documents, support, and audit events. Every user-facing table has RLS. Policies isolate private customer/provider records; published openings expose only eligible inventory. Storage buckets are private and booking-photo reads join through booking participants.

`create_booking` locks the opening row, validates published/unexpired inventory and address ownership, snapshots prices/add-ons, inserts one booking, changes opening state, and creates notifications in one transaction. A partial unique index is defense in depth. `transition_booking` validates actor-specific transitions, timestamps the action, updates inventory, and audits it. Review eligibility is enforced by trigger.

Payments, fees, payouts, tax, identity/insurance review, and notification delivery remain simulated. There is no Stripe, live geocoding/maps, GPS/routing, SMS, SMTP delivery, background-check integration, calendar sync, or chat. Approval-request expiration requires a configured scheduled job. The checked-in database verification file is a manual harness and requires a running Supabase project.

GitHub Pages still builds `dist`, uses `/openslots-marketplace/`, and uses hash routes. Only public URL/anon credentials are Vite variables; authorization never depends on key secrecy.

## 0.3.1 authentication boundary
`src/lib/supabase.ts` owns the single typed SDK client. UI calls `authService`/`profileService` through `AuthProvider`; protected routes evaluate the restored session, server-backed profile role/status, and provider approval. Demo mode does not mount `AuthProvider`, keeping LocalStorage mock state isolated. Hash routing remains mandatory for GitHub Pages, while RLS and validated database functions remain the security boundary.

## 0.3.3 responsive presentation boundary
`src/mobile.ts` is the testable source for role-aware mobile destinations. `BottomNav` consumes it in both isolated demo and connected shells; it does not grant authorization. Guards and Supabase RLS remain authoritative. `MobileSheet` centralizes dialog semantics, Escape handling, focus containment/restoration, and body scroll lock. CSS safe-area/dynamic viewport behavior is presentation-only and preserves desktop routes and HashRouter deployment.

## 0.3.4 connected data boundary
`App` selects demo or connected shells. Connected routes call the centralized opening, booking, provider, admin and notification services, all backed by the sole client in `src/lib/supabase.ts`. Public reads use a safe RPC; identity/status mutations use fixed-search-path workflow RPCs. Correctness uses refetch-after-mutation and does not depend on Realtime.

## 0.3.5A billing boundary
The browser reads safe plan/access RPCs and asks authenticated Edge Functions for Stripe-hosted URLs. It never sends a provider/customer/Price ID or subscription state. Stripe webhook signature verification precedes a unique event claim and service-role state update. `get_provider_marketplace_access()` and publishing RPCs are authoritative. Hash-based return URLs preserve GitHub Pages routing. Demo mode blocks billing calls.

## 0.3.6 relationship boundary
`RelationshipPages` is route-lazy and calls typed profile, save, conversation, and request services. Public discovery uses a narrow security-definer projection; private interaction uses RLS plus fixed-search-path RPCs. Proposal conversion locks request/proposal rows, checks conflicts, creates a booked synthetic opening and confirmed booking, then links conversation/audit/notifications in one transaction.
