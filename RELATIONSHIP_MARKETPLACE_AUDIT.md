# Relationship marketplace audit (0.3.6)

## Implemented before 0.3.6
0.3.4 supplied connected opening search/detail, atomic instant and approval bookings, booking records, notifications, mobile navigation, Supabase auth/RLS, roles, provider approval, environment-mode isolation, and private provider documents. 0.3.5A supplied Stripe Billing subscriptions and server-side opening publication enforcement.

## Partially implemented before 0.3.6
Provider profiles held real business name, description, experience, radius, ratings and approval state, but had no safe rich public projection/editor. Services and reviews were real. Saved providers existed in schema with RLS but connected UI redirected to search. Notification records linked bookings/openings only. Storage supported private booking/application files, not a separate public portfolio bucket.

## Mock-only before 0.3.6
Demo mode had provider biographies, saved-provider behavior and provider cards. Connected mode correctly did not fall back to these records. The demo booking screens contain simulated contact/payment wording and remain isolated from Supabase.

## Missing before 0.3.6
Conversations, messages, inquiries, custom requests, proposals, recurring preference, request-to-book conversion, public profile images/portfolio, provider-mode discovery, and relationship dashboards were absent. The old demo opening page used unsupported “Identity verified” wording; connected pages did not expose email/phone.

## Implemented in 0.3.6
Additive public profile fields, public provider RPC/search, profile/editor routes, separate public-image bucket, portfolio metadata, saved-provider UI, participant-scoped conversations, idempotent message RPC, custom requests/proposals, atomic idempotent proposal conversion, notifications, audit events, subscription eligibility, mobile pages, and documentation.

## Deferred
Attachment messaging, automated recurring-series generation, exact distance/geospatial search, computed response metrics, invasive contact detection, end-to-end encryption, provider-facing saver identity, native iPhone Safari execution, and social provider setup. Demo relationship fixtures remain a future enhancement; demo makes no connected calls but its legacy screens do not simulate every new 0.3.6 route.
