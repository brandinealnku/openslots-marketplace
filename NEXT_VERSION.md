# Recommended v0.3

1. Replace the lightweight HTTP adapter with the official Supabase JavaScript SDK when registry access is available, including SDK-managed refresh and scoped Realtime subscriptions.
2. Finish wiring every polished v0.1 screen to the service layer and add full auth/profile/onboarding UI and accessible upload progress.
3. Deploy and test the reservation-expiry Cron function; add local pgTAP coverage in CI.
4. Add Playwright role journeys at 375/768/1024/1440 widths and visual snapshots.
5. Add production observability, rate limiting, abuse controls, verified SMTP, and retention/deletion workflows.
6. Later evaluate Stripe Connect, real geocoding, document vendors, calendars, and delivery channels; none are currently operational.

## Recommended task after authentication
Connect customer profiles and addresses, provider onboarding persistence, marketplace search, approved-provider opening publication, atomic booking, booking dashboards, reviews, notifications, and support cases. Keep payments/maps/SMS/background checks separately scoped.
