# Supabase setup

1. Create a Supabase project and copy **Project URL** and the public **anon/publishable key** from Project Settings → API. Never use the service-role key in Vite.
2. Copy `.env.example` to `.env.local`, set both values, and use `VITE_APP_MODE=development`. Explicit mock mode is `demo`.
3. Install the Supabase CLI, run `supabase login`, `supabase link --project-ref YOUR_REF`, then `supabase db push`. For local development use `supabase start` and `supabase db reset`; reset applies migrations and `supabase/seed.sql`.
4. The migration creates private `avatars`, `booking-photos`, and `provider-documents` buckets and their policies. Do not make these public in the Dashboard.
5. Under Authentication → URL Configuration, set the production Site URL to `https://brandinealnku.github.io/openslots-marketplace/`. Allow `https://brandinealnku.github.io/openslots-marketplace/`, `https://brandinealnku.github.io/openslots-marketplace/#/reset-password`, `http://localhost:5173/`, and `http://localhost:5173/#/reset-password`. Supabase returns recovery credentials before the application's route hash, so the client must consume the Auth callback before navigating to the hash-routed reset form. Verify this against the configured project; do not enable wildcard production redirects.
6. Under Authentication → Providers → Email, enable email/password and choose whether confirmation is required. Configure a real SMTP provider before production; database notifications are in-app only.
7. Register a user normally. Create the first administrator only in SQL Editor while authenticated as the project owner: `update public.profiles set role='admin' where id='USER_UUID';`. Verify with `select id,email,role,account_status from public.profiles where id='USER_UUID';`. Never expose this operation to clients.
8. Seed categories with `supabase db reset`. Create fictional Auth users through local Studio, then add provider/service/opening fixtures; public seed credentials are intentionally omitted.
9. Run `psql "$DATABASE_URL" -f supabase/tests/rls_verification.sql` after replacing its UUID placeholders. Run its two-session concurrency scenario and verify private bucket reads with customer A, customer B, provider, and admin JWTs.
10. Generate TypeScript types when CLI is installed: `npm run db:types`. Apply remote migrations with `npm run db:push`; reset local data with `npm run db:reset`.

## Troubleshooting

A configuration error at startup means variables are absent/invalid. A 401 usually means an expired session; sign in again. A 403 is normally RLS, not a reason to weaken a policy. `opening_unavailable` means the opening expired or another transaction won. Inspect Supabase database/auth logs for technical detail without showing raw errors to users.

Reservation expiry is **not claimed as fully automated**: enable the Supabase Cron integration and schedule `select public.expire_provider_requests();` every five minutes. The function is intentionally unavailable to browser roles. Until that external schedule is configured and observed in production, overdue-request expiration remains only database-ready.

## OpenSlot 0.3.1 authentication URLs
Set the Supabase Auth **Site URL** to `https://brandinealnku.github.io/openslots-marketplace/` and allow:

- `https://brandinealnku.github.io/openslots-marketplace/`
- `https://brandinealnku.github.io/openslots-marketplace/#/reset-password`
- `http://localhost:5173/`
- `http://localhost:5173/#/reset-password`

GitHub Pages must define repository variables `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, and `VITE_APP_MODE=production`. Never use a service-role key in a browser variable.

The SDK requests recovery with the hash-route URL. Supabase can return credentials in a hash before the application route; this exact hosted callback remains a required manual browser test and is not claimed as verified by unit tests.

## Test accounts and administrator promotion
Register separate customer, provider, and administrator-candidate emails; never commit passwords. Administrator registration is intentionally absent. As project owner, register the candidate normally, copy its Authentication UUID, then run:

```sql
update public.profiles set role = 'admin' where id = 'USER_UUID';
select id, email, role, account_status from public.profiles where id = 'USER_UUID';
```

RLS/profile-protection prevents a normal browser user from performing this privilege change. Sign out and back in after promotion.

Apply `202607290005_auth_security_fixes.sql` through the normal linked workflow, then run the Supabase database linter. The migration fixes mutable search paths, restricts trigger functions, removes anonymous RPC execution, and preserves authenticated access only to browser RPCs that validate identity/role/ownership/status internally.

## OpenSlot 0.3.2 Google and Apple OAuth

1. Apply `supabase/migrations/202607290006_social_auth_role_selection.sql` with `supabase db push` (or `npm run db:push`). Do not run the role RPC with a service-role key from the browser.
2. In Authentication → URL Configuration, retain the Pages Site URL and add exact redirects for `https://brandinealnku.github.io/openslots-marketplace/#/auth/callback` and `http://localhost:5173/#/auth/callback`.
3. In Google Cloud, create an OAuth web client, configure the Supabase callback URL shown in Authentication → Providers → Google, configure the consent screen, then enter the client ID/secret in Supabase and enable Google.
4. In Apple Developer, create/verify the Services ID and web domain, configure Supabase's displayed callback URL, create a Sign in with Apple key/client secret, then enter those values in Authentication → Providers → Apple and enable Apple.
5. Keep Email enabled. Test email signup/login/recovery plus new and returning Google/Apple users on localhost and the deployed Pages URL. Verify a new social user is sent to `#/choose-role`, the choice works once, and dashboard access matches it.

Source code inclusion does not configure either third-party provider. Provider credentials and dashboard access are required before either flow can be browser-tested.

## Version 0.3.4 migration order
Run `npx supabase db push --dry-run`, review migrations `202607300007_live_marketplace_queries.sql`, `202607300008_live_opening_workflows.sql`, `202607300009_live_booking_workflows.sql`, and `202607300010_notifications_indexes_and_rls.sql`, then run `npx supabase db push`. The public RPC exposes only safe joined fields. Authenticated RPCs derive identity from `auth.uid()`. New indexes support provider/opening, participant booking, application and audit lookups. Documents remain private and signed-URL based. Configure a scheduler for `expire_provider_requests`; Realtime is not required. Run database lint and `supabase/tests/live_marketplace_verification.sql` locally. Never use `db reset` against a linked project.

## Provider Billing Functions
Apply migrations `202607300011` and `202607300012`, configure the secrets and Stripe event allowlist in `PROVIDER_BILLING_SETUP.md`, and deploy `create-provider-subscription-checkout`, `create-provider-billing-portal`, and `stripe-subscription-webhook`. Keep Price IDs and all secret keys server-side. Set the webhook function to use Stripe signature authentication, not a caller JWT. Checkout/Portal require a user JWT.

## 0.3.6 setup
Apply migration `202607310013_relationship_marketplace.sql`. It creates the public `provider-public-images` bucket (5 MB, JPEG/PNG/WebP) with owner-folder writes; never place private provider documents there. Existing providers need eligible `trialing`/`active` subscription rows, public profile fields, active services, and approved applications to appear or accept new requests.
