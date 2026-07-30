# OpenSlot 0.3.4 live marketplace audit

Audit performed on 2026-07-30 before implementation, at commit `4987f20`.

## Mode boundary

`App` selects `DemoShell` only for `VITE_APP_MODE=demo`; all other modes select
`ConnectedShell`. However, before 0.3.4 both shells rendered the same marketplace
components. `StoreProvider` was mounted globally, so connected pages read and mutated
the LocalStorage-backed mock store despite the connected banner.

## Connected mock dependencies found

| Connected surface | Previous source/action |
|---|---|
| Home, search, opening detail | `useStore().openings`, mock providers/reviews/services |
| Booking and confirmation | Mock opening plus `store.book`, random confirmation, LocalStorage |
| Customer bookings and saved providers | `useStore`, mock providers |
| Provider dashboard, post opening, schedule | Static/mock metrics and `store.post` |
| Provider onboarding | Non-functional prototype form |
| Administrator review | `useStore().applications` and `store.approve` |
| Cards/map | Mock provider lookup and simulated distance/map |

The authentication pages, guards, profile refresh, initial social role selection and
storage upload service were already connected. Demo role switching and reset were
correctly LocalStorage-backed and are retained.

## Existing database capabilities

Migrations through `202607290006` provide profiles, customer/provider profiles,
services, add-ons, openings, bookings, notifications, documents and audit events.
`create_booking` already locks an opening, calculates totals, creates participant
notifications and reserves/books the opening. `transition_booking`,
`submit_provider_application`, `review_provider_application`, and expiration functions
exist. RLS is enabled, but public marketplace browsing is unavailable to `anon`, direct
provider opening writes are too broad, notification mutation lacks a column constraint,
and admin UI code directly patches provider status.

## Gaps and 0.3.4 decisions

* Add a customer-safe, paginated search/detail RPC rather than exposing joined tables.
* Add identity-derived provider opening create/manage RPCs and remove unrestricted
  client writes for privileged fields.
* Harden booking role/account/provider checks, add a unique opening constraint, validate
  every requested add-on, and keep locking/notification/audit work in one transaction.
* Add explicit provider accept/decline wrappers and secure admin review usage.
* Add participant-safe booking list RPCs and notification services.
* Connected screens use dedicated services and explicit loading/empty/error states;
  they never fall back to mock records. Demo components remain unchanged.
* Distance, maps, payments, Realtime, payouts, reviews and live document verification
  are not claimed. Connected search uses ZIP/service-area matching.

## Reusable client pieces

The existing shell, guards, mobile bottom navigation, filter sheet, badges, responsive
styles, auth provider and single Supabase client remain useful. A connected-only page
module supplies live marketplace views; service modules centralize all network calls and
normalized errors. Refetch-after-mutation is used instead of Realtime.
