# OpenSlot v0.3 integration hardening

OpenSlot matches local providers' unused appointment inventory with customers. Version 0.3 preserves the polished React 19, TypeScript, Vite, hash-router, CSS prototype, and explicit demo mode while hardening the Supabase multi-user foundation.

> Payment, tax, payout, identity/insurance review, maps/routes, and delivery are simulations. No card data should be entered or stored.

## Setup and commands

```bash
npm install              # dependencies
npm run dev              # Vite development server
npm test                 # Vitest unit checks
npm run lint             # TypeScript check
npm run build            # production dist
npm run preview           # serve dist locally
npm run db:start          # local Supabase (CLI/Docker required)
npm run db:push           # apply linked migrations
npm run db:reset          # reset/migrate/seed local project
npm run db:types          # generate local database types
```

Copy `.env.example` to `.env.local`. Connected development/production requires `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`; only explicit `VITE_APP_MODE=demo` permits mock/localStorage data. Never use a service-role key in browser code. Follow [SUPABASE_SETUP.md](SUPABASE_SETUP.md) exactly.

## Architecture and deployment

Domain access is centralized under `src/services`; `src/lib/env.ts` fails clearly rather than silently using fake production records. The executable PostgreSQL/RLS/Storage design and atomic booking RPC are under `supabase/`. See [ARCHITECTURE.md](ARCHITECTURE.md), [DATA_MODEL.md](DATA_MODEL.md), [RISKS.md](RISKS.md), [MVP_SCOPE.md](MVP_SCOPE.md), and [NEXT_VERSION.md](NEXT_VERSION.md).

GitHub Pages remains `https://brandinealnku.github.io/openslots-marketplace/`. Vite's `/openslots-marketplace/` base and `HashRouter` mean refreshes request the repository `index.html`; GitHub Actions tests/builds and uploads only `dist`. Configure both local and Pages Auth URLs as documented.

The Pages repository must define Actions **variables** (not service-role secrets) named `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, and `VITE_APP_MODE`. Use `production` for a connected deployment and `demo` only for an intentionally isolated demonstration build.

## Connected authentication (0.3.1)
OpenSlot now has hash-routed connected account pages at `#/login`, `#/register`, `#/forgot-password`, and `#/reset-password`. `VITE_APP_MODE=demo` preserves the isolated Early Access prototype; `development` and `production` require real Supabase URL/anon-key values and never silently use demo identity data. See `SUPABASE_SETUP.md`, `AUTH_IMPLEMENTATION_REPORT.md`, and `MANUAL_TEST_PLAN_AUTH.md` before claiming live verification.

## Connected authentication (0.3.2)
Google and Apple buttons use Supabase OAuth and return through the hash-routed `#/auth/callback` page. A first-time social account must choose customer or provider at `#/choose-role`; the one-time choice is committed by the database RPC in `202607290006_social_auth_role_selection.sql`. Email/password registration, verification, recovery, and login remain available. Demo mode does not initialize or expose connected social identity.

See `V032_IMPLEMENTATION_REPORT.md` and `SUPABASE_SETUP.md` for provider configuration and verification boundaries.

## Version 0.3.3 mobile experience
The UI now uses a compact mobile header, role-aware safe-area bottom navigation, an accessible search filter sheet, phone agenda schedule, 16px controls, dynamic viewport sizing, and sticky booking/form actions. Use `MOBILE_UX_AUDIT.md`, `MOBILE_TEST_PLAN_V033.md`, and `V033_IMPLEMENTATION_REPORT.md` for the audit, physical-device matrix, and honest verification boundary.

## Version 0.3.4 live marketplace
Connected development/production modes now use Supabase services for public openings, bookings, provider workflows, administration and notifications; demo mode remains an isolated mock experience. Apply migrations `202607300007` through `202607300010`, then follow `MANUAL_TEST_PLAN_V034.md`. Distance is ZIP/service-area matching, and no payments are collected.
