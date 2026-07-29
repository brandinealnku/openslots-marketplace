# Version 0.3 implementation report

## Version 0.2 audit

The v0.2 migration defines the core marketplace tables, private buckets, RLS, an Auth profile trigger, atomic `create_booking`, and guarded `transition_booking`. It is a compact architectural foundation rather than proof of completed browser workflows. The UI remains predominantly demo fixtures and `openslot-demo-state-v1` LocalStorage. Service modules expose partial HTTP calls; provider/admin/profile/review services are placeholders, there is no Auth provider or route guards, and no connected page owns loading/retry/realtime state.

## Status matrix

### Fully connected/database-enforced

* Core schema, participant reads, private bucket definitions, atomic booking price snapshots, and one-live-booking uniqueness originate in v0.2.
* v0.3 adds administrator-only provider decisions, provider self-submission validation, server-maintained published-review aggregates, and a scheduler-ready expiration function.
* Pages CI receives the three public Vite values from repository variables.

### Partially connected

* Auth, profile, opening search, booking RPC, review, private upload, and admin service facades exist, but the polished browser screens have not all been rewired to those facades.
* SQL verification is a project-dependent script and requires local Supabase plus distinct Auth sessions.

### Demo only

* Current routed marketplace, onboarding, dashboard, booking wizard, saved providers, and admin interface use fixtures/demo state. Demo prices and role switching are intentionally isolated and labelled.

### Simulated

* Payment, taxes, marketplace fees, payouts, identity/insurance review, maps, and distance are prototypes only. No card data is transmitted or stored.

### Deferred / known blocker

* The official `@supabase/supabase-js` package could not be installed in this execution environment because the package registry proxy returned HTTP 403. The interim adapter therefore remains in use and the official SDK acceptance criterion is not complete.
* End-to-end Auth context, all connected UI states, Realtime listeners, three-browser execution, live email recovery, deployment observation, and Cron activation require follow-up. This report deliberately does not claim them complete.

## Query/security notes

Search and participant queries must remain bounded and RLS-filtered; never subscribe to whole high-volume tables. Privileged provider statuses are changed only by the `review_provider_application` security-definer RPC, which checks `is_admin`, validates actions/reasons, notifies the provider, and audits the actor. Rating aggregates are trigger-controlled. Private object access still depends on both owner-prefixed paths and database associations.

See `MANUAL_TEST_PLAN_V03.md` for the exact multi-account, concurrency, privacy, responsive, recovery, and Realtime-degradation checks that must pass against the target project before production acceptance.
