# OpenSlot

**Get it done today. Turn open time into income.** OpenSlot is a polished front-end concept for discovering and booking *specific unused appointment slots* from trusted local service providers. The pilot market is lawn and outdoor home care in Cincinnati and Northern Kentucky.

> **This application is an early-stage product prototype. Payments, provider verification, mapping, routing, and identity checks are simulated.**

## The problem and differentiator

Customers call multiple businesses and still wait days for a quote, while providers lose revenue to cancellations and route gaps. OpenSlot sells appointment inventory—not a directory listing: every marketplace result has a date, time, fixed demo price, scope, and expiration.

## Screenshots

| Customer marketplace | Provider dashboard | Booking flow |
|---|---|---|
| _Add screenshot after deployment_ | _Add screenshot after deployment_ | _Add screenshot after deployment_ |

## Stack and architecture

- React, TypeScript, Vite, React Router (hash routing), Lucide icons, CSS
- Structured mock data and typed entities in `src/data` and `src/types.ts`
- React context plus LocalStorage persistence; no backend, API key, or environment variables
- Hash routes avoid GitHub Pages rewrite requirements. Vite uses `base: './'` so assets resolve from repository subdirectories.

## Local setup

```bash
npm install
npm run dev
```

Open the URL Vite prints. Run `npm test` for logic tests, `npm run build` for production, and `npm run preview` to inspect the build.

## Routes

`/`, `/search`, `/opening/:id`, `/book/:id`, `/booking-confirmation/:id`, `/customer/bookings`, `/customer/saved`, `/provider`, `/provider/onboarding`, `/provider/openings/new`, `/provider/schedule`, `/provider/earnings`, `/admin`, `/trust`, `/how-it-works`, and `/about` are available after `/#/` because the app uses hash routing.

## Demo guide

### Customer books lawn service
1. Select **Find an opening**, filter Lawn mowing, and open a listing.
2. Review scope and choose **Book**. Enter property details and add-ons.
3. Advance through mock photo and contact steps.
4. Submit the clearly labeled payment simulation and view confirmation.

### Provider posts an opening
1. Use **View as → Provider**, select **I Have an Opening**, enter details, and preview.
2. Publish. The opening persists in LocalStorage and appears at the top of customer search.

### Administrator approves a provider
1. Use **View as → Administrator**, open Admin, and find pending applications.
2. Select **Approve**; the locally persisted status updates immediately.

Use **Reset Demo Data** in the demo bar to restore fixtures after confirmation.

## Project structure

```text
src/App.tsx          Route screens and primary flows
src/components.tsx   Reusable marketplace components
src/store.tsx        Demo state/actions and persistence
src/data/            Fictional structured fixtures
src/utils/           Pricing, filtering, sorting, expiration, storage
src/config.ts        Replaceable brand and fee configuration
src/styles.css       Responsive design system
```

## GitHub Pages deployment

1. Set the repository's Pages source to **GitHub Actions**, or install dependencies locally.
2. Run `npm run deploy`. The `gh-pages` package builds and pushes `dist` to the `gh-pages` branch.
3. In repository Settings → Pages, select **Deploy from a branch**, `gh-pages`, `/ (root)`.

For Actions, run `npm ci && npm run build`, upload `dist` with `actions/upload-pages-artifact`, then deploy with `actions/deploy-pages`. No SPA fallback is required because routing uses URL hashes.

## Known limitations and roadmap

No authentication, real payments, geocoding, map tiles, live GPS, notification delivery, document verification, calendar sync, or server concurrency exists. Browser-local writes are device-specific and file uploads remain in memory. Read [NEXT_VERSION.md](NEXT_VERSION.md), [MVP_SCOPE.md](MVP_SCOPE.md), [DATA_MODEL.md](DATA_MODEL.md), [USER_STORIES.md](USER_STORIES.md), and [RISKS.md](RISKS.md) for the implementation and pilot roadmap.
