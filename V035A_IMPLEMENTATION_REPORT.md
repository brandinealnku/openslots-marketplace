# OpenSlot 0.3.5A implementation report

This additive release establishes provider-paid Stripe Billing without processing customer-to-provider service payments. It adds a private configurable plan catalog, provider subscription record, idempotent event ledger, access RPC, publishing enforcement, three Edge Functions, explicit environment mode, Billing UI, tests, and operational documentation. Checkout accepts only plan code and authenticated identity. Portal customer ownership comes from the signed-in user's row. Webhooks use raw-body HMAC verification and unique event claims. Demo returns labeled simulated state and blocks actions.

Automated tests mock the browser-side Function client. A real Stripe account, test Prices, deployed Functions, webhook endpoint, and Supabase CLI-linked database are not available in repository-only testing, so end-to-end Stripe claims are intentionally not made. Limits beyond access eligibility are deferred to 0.3.5B. Google/Apple configuration is deferred.

## Baseline validation
Before editing: `npm ci` passed; `npm test` passed 30 tests in 7 files; `npm run lint` passed; `npm run build` passed with the existing >500 kB chunk-size warning.

## Validation limitation
The final clean install, 41-test suite, TypeScript lint, production build, and `git diff --check` pass. `npx supabase db push --dry-run` could not install the absent Supabase CLI because this environment returned HTTP 403 from npm; therefore migration application is not claimed as tested. Stripe test-mode end-to-end behavior also requires the manual setup above.
