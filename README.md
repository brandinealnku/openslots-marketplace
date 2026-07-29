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
