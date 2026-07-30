# Manual test plan — 0.3.5A

- In demo mode, switch mobile roles, open Billing, verify “simulated,” and confirm Network contains no Supabase Function or Stripe request.
- In connected Stripe test mode, verify unapproved/non-provider requests receive 403; inactive accounts receive 403; unknown and browser-supplied extra checkout fields receive 400.
- As an approved provider, start Starter Checkout with a Stripe test card; verify the return says confirmation is pending until the webhook persists `trialing`/`active`.
- Retry the same webhook event and verify one `subscription_events.stripe_event_id`, one state mutation, and no duplicate notification.
- Open Portal and verify it belongs to the signed-in provider; attempt a different customer and verify rejection.
- Exercise created, updated, deleted, invoice paid/failed, and trial ending fixtures with Stripe CLI. Verify invalid and stale signatures fail.
- Confirm trialing/active can publish; none/past_due/unpaid/canceled/paused cannot create or reopen published openings.
- Confirm customer booking surfaces show the direct-provider payment disclosure and contain no card inputs.
- Validate HashRouter success/cancel URLs on the deployed GitHub Pages base.
