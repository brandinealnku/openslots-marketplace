# OpenSlot 0.3.1 connected authentication manual test plan

Use distinct, non-committed emails for customer, provider, and administrator tests. Run every connected case with real development project variables; unit tests do not contact Supabase.

## Customer registration and session
1. Register at `#/register` as Customer and confirm email when enabled.
2. Verify the matching `auth.users`, `public.profiles` (customer role), and `public.customer_profiles` rows in Supabase.
3. Complete name, phone, contact preference, and note the address requirement at `#/customer/profile`.
4. Refresh and verify the session remains; sign out, sign back in, and verify customer routing.

## Provider registration
1. Register a separate Provider account; verify provider role and `provider_profiles.application_status = draft`.
2. Verify onboarding is shown, application status is available, and `#/provider/openings/new` redirects before approval.
3. Submit/review through the existing controlled workflow, then verify an approved provider can reach the dashboard.

## Administrator
1. Register a third account normally, copy its UUID, and promote it only with the owner SQL documented in `SUPABASE_SETUP.md`.
2. Sign out/in, verify admin access, then confirm customer/provider accounts cannot enter admin routes.

## Password recovery (requires real email/browser validation)
1. Request from `#/forgot-password`; confirm the response never discloses account existence.
2. Open the received link and record whether Supabase places credentials before the application hash.
3. Confirm routing to `#/reset-password`, set a strong password, and sign in with it.
4. Repeat with an expired link. Do not mark this flow browser-tested until all steps pass on localhost and GitHub Pages.

## Protection, statuses, and session
- Signed-out customer/provider/admin URLs redirect to login and retain the intended path.
- Customer cannot access provider; provider cannot access admin; unapproved provider cannot publish.
- Suspended/closed accounts reach account status, not a dashboard.
- Refresh retains a session; a separate browser profile does not; sign-out removes access; an expired session returns to login.

## Demo isolation and responsive checks
- In `VITE_APP_MODE=demo`, verify the Early Access banner, role switcher, reset control, and demo LocalStorage workflows.
- In development/production, verify no role switcher and no demo records are treated as account data.
- Check home/login/register/forgot/reset at 375, 768, 1024, and 1440 px for overflow, focus, labels, announcements, touch targets, header wrapping, and offline behavior.
