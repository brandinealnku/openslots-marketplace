# Recommended v0.3.4

1. Extract route modules and apply `React.lazy` to provider/admin/informational pages, then set a measured bundle budget.
2. Add Playwright journeys and snapshots at 320/375/390/430/768/1024/1440, including automated overflow assertions and dialog focus tests.
3. Complete connected customer addresses/bookings and provider onboarding/opening persistence without weakening RLS.
4. Run the v0.3.3 checklist on physical iPhones and configured Google/Apple providers; fix measured Safari/keyboard issues.
5. Transform admin tables into semantic mobile card rows and add offline retry primitives for connected mutations.
6. Keep payments, live maps, SMS, background checks, and push notifications separately scoped.

## Recommended 0.3.5 priorities
Complete provider service/category and document onboarding UI; add opening edit/duplicate RPC/UI; deploy expiration scheduling; add integration test fixtures and multi-session concurrency automation; introduce route-level lazy chunks; and complete physical-iPhone/accessibility testing. Payments, GPS/maps and push remain outside this increment.

## After 0.3.5A
0.3.5B should enforce plan opening/publishing counters transactionally. Later work may add reviews, richer cancellation/support workflows, and trust tooling. It must not turn OpenSlot into the processor of customer service payments. Google and Apple provider configuration remains deferred.

## Recommended after 0.3.6
Add local-Supabase integration fixtures for full adversarial RLS tests, request proposal controls without prompt dialogs, secure moderated attachments, configurable contact-safety rules, real geospatial filtering, richer demo relationship fixtures, response metrics, and opt-in finite recurring booking generation.
