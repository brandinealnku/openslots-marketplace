# OpenSlot 0.3.6 implementation report

This release adds a relationship marketplace alongside authoritative openings. Customers compare approved subscription-eligible public profiles, save providers, request unposted availability, and communicate in participant-scoped text conversations. Providers manage public presentation and requests. Proposal acceptance creates one confirmed booking atomically. Provider-listed service amounts are not collected by OpenSlot: customers and providers arrange payment independently. Provider subscriptions remain OpenSlot revenue.

Security uses a narrow public RPC, RLS, owner storage paths, fixed function search paths, `auth.uid()` identity, restricted grants, audit events and safe notifications. Public imagery is intentionally separate from private documents. Google/Apple setup, E2E encryption, robust contact scanning, attachments, exact distance, complete demo relationship fixtures, and recurring-series generation are deferred.
