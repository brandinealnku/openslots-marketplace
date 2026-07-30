# Provider subscription audit — 0.3.5A

## Baseline and existing code
Version 0.3.4 is present (`package.json`, V034 report, live query/opening/booking migrations). Before this work, OpenSlot had no Stripe package, Billing code, Edge Functions, subscription schema, or subscription-specific RLS. Provider identity is the `provider_profiles.user_id`/`profiles.id`; approval is `provider_profiles.application_status = approved`, and account availability is `profiles.account_status = active`. Publishing was authorized only by those two states. Notifications and append-oriented audit events already existed. HashRouter and Vite's `/openslots-marketplace/` base provide GitHub Pages routing. Demo state is local; connected development/production uses Supabase.

## Incorrect payment assumptions found
The legacy prototype models booking fees, tax, provider payout estimates, refunds, “secure transaction,” and simulated customer payment. Those fields are historical applied-schema compatibility, not a supported payment flow. UI language implied a future marketplace processor. 0.3.5A replaces customer-facing payment claims with the direct-provider disclosure. No customer card form, Stripe Connect, payout, escrow, split payment, or service-refund behavior is introduced.

## Missing foundation and risks
Missing items were a server-controlled plan catalog, canonical subscription state, Stripe event ledger, authenticated Checkout/Portal functions, signature-verified webhook, server-authoritative access RPC, explicit billing mode, and a billing view. Key risks are forged browser state, arbitrary Price IDs, cross-provider Stripe customers, replayed webhooks, exposed secrets, granting access on a return URL, and demo traffic reaching Stripe.

## Recommendation implemented
Keep Price IDs behind RLS and service-role Edge Functions; accept only a plan code; derive identity from the bearer token/auth.uid(); synchronize only verified allowlisted Stripe events; claim unique event IDs before mutation; let the access RPC and publishing RPC rely on database state; keep billing explicitly disabled by default. Manual Stripe test-mode verification remains required.
