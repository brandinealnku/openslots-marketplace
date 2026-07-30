# Provider Billing setup

1. Create Stripe **test-mode** recurring Prices for Starter and Pro (and choose whether Trial uses a zero/test Price with a trial period).
2. Put each `price_...` value in `subscription_plans.stripe_price_id` using an administrator/server-side SQL workflow; never ship it to the browser.
3. Set Edge Function secrets: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SIGNING_SECRET`, `APP_BASE_URL` (GitHub Pages site root), `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY`.
4. Deploy the three functions. Configure the Stripe endpoint for only the seven documented event types. The webhook endpoint must be deployed without Supabase JWT verification because Stripe authenticates with its signature; Checkout and Portal must retain function-level JWT verification.
5. Set frontend `VITE_PROVIDER_BILLING_MODE=test` and a publishable test key. The current REST redirect flow does not actually require the publishable key, but it is reserved for Stripe-hosted client features. Keep `disabled` in production until live configuration is deliberately reviewed.

Use no Connect settings. Customer service payment occurs independently with the provider. Google and Apple authentication setup remains deferred.
