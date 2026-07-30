# OpenSlot 0.3.4 manual multi-account plan

## Preconditions
Apply migrations `202607300007`–`202607300010`; use one admin, one approved provider, one pending provider and customers A/B. Record database IDs and redact personal data.

## Provider and administration
1. Register the pending provider, complete and submit the real application; verify pending survives refresh.
2. As admin, review authorized details/documents, approve, then verify provider notification and audit row. Sign out/in and verify posting unlocks.
3. Repeat rejection with a required reason. Verify repeated/non-admin review fails.

## Opening lifecycle
1. Approved provider posts future instant and approval-required openings.
2. Verify provider list/schedule and public search; ensure network output has no email, phone, document path, address or audit fields.
3. Pause/disappear, reopen/reappear, then cancel/disappear. Attempt another provider's ID and a booked ID and expect rejection.

## Atomic booking and requests
1. Customer A books instant opening; verify `confirmed`, server total, both notifications, audit, booked opening, history and provider workspace.
2. Submit the same listing in A/B sessions as nearly simultaneously as possible. Exactly one succeeds; the loser sees unavailable, with one live booking and no orphan notification.
3. Book approval-required opening; verify `requested`/`reserved`. Owner accepts before deadline. Repeat with decline reason. Verify wrong-provider, repeat and expired responses fail.

## Notifications and RLS
Verify unread badge, single/all read and safe links. Attempt cross-user booking, notification and opening access using copied IDs; each must fail or return no row.

## Responsive browser matrix
Repeat search, detail, booking, history, provider request/posting and notifications at 320, 375, 390, 430, 768 and 1440 px. On physical iPhone Safari verify safe-area spacing, keyboard/zoom, sticky actions, 44 px targets, no horizontal scroll and announcements. Record browser/device/build and screenshots. This plan is not evidence that the tests were executed.
