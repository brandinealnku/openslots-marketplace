# OpenSlot 0.3.2 implementation report

Version 0.3.2 restores a marketplace-first landing experience while preserving the explicitly isolated demo build and connected email/password flows. Connected accounts now offer Google and Apple OAuth through Supabase, use a hash-compatible callback route, and require social users to choose customer or provider once through a server-side RPC.

## Security boundary

The browser may request only `customer` or `provider`. `select_initial_role` derives identity from `auth.uid()`, accepts an active profile only while `role_selected_at` is null, recreates exactly one matching subtype row, and cannot assign `admin`. Existing users are backfilled as already selected. OAuth metadata is never trusted for authorization.

## Verification scope

Automated checks cover compilation, existing service behavior, account routing, and social-role routing. Provider enablement, consent-screen review, OAuth credentials, hosted redirects, Apple domain verification, and a real first login require dashboard credentials and manual browser testing; they are not represented as completed by source-level tests.

## Superseded presentation layer
Version 0.3.3 builds on this authentication/security work with mobile navigation, filter-dialog, safe-area, form, and agenda improvements. The v0.3.2 OAuth verification boundary remains unchanged: source presence is not evidence of a real provider login.
