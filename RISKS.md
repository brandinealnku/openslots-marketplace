# v0.2 risks

- The schema/RLS/RPC design has not been exercised against a live project in this environment; execute the representative SQL/JWT tests before production.
- The existing polished screens still primarily use explicit demo context; completing all connected UI wiring is outstanding and production must not enable demo mode.
- The lightweight REST/Auth adapter lacks official SDK refresh/realtime ergonomics. Session integration is not yet complete.
- Approval reservations need a deployed scheduler. No job is falsely claimed as active.
- Cancellation policy currently permits customer cancellation in the RPC without a time-window rule; configure the intended marketplace policy before launch.
- Client MIME/size checks are supplemental; Storage bucket constraints and RLS are authoritative, but malware scanning is absent.
- Payments, tax and payout estimates are simulations and are not accounting records.

## Version 0.3 integration audit (2026-07-29)

The database foundation does not by itself prove the browser workflows. The official Supabase SDK install was blocked by an HTTP 403 from this environment's registry proxy, so the interim adapter remains and connected Auth/session/Realtime UI acceptance is unresolved. Live three-browser, recovery-email, Cron, Storage, RLS, and concurrency checks require a configured Supabase project and must follow `MANUAL_TEST_PLAN_V03.md`. Never promote this build as fully connected until those checks and the official SDK migration pass.

The new administrator RPC uses a security-definer function with a fixed search path and an internal admin check. Reservation expiry is scheduler-ready but not active until Supabase Cron is configured. Payments, payouts, exact distance, maps, messaging, automated verification, calendar sync, and production observability remain deferred.

## Connected authentication risks (0.3.1)
- GitHub Pages/Supabase recovery hash ordering must be validated with a real email link; source configuration alone is not proof.
- A delayed/missing profile trigger produces an explicit account-status state, but linked-project trigger and grants require integration verification.
- Customer addresses and provider onboarding remain partially connected, so marketplace workflows must not be represented as production-ready.
- SDK installation and CI require npm registry availability; no service-role credential may be introduced to work around access failures.
