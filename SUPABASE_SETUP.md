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
