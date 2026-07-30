# OpenSlot v0.3.3 mobile UX audit

## Method and baseline
The source, responsive CSS, route shells, authentication pages, service boundaries, deployment workflow, database types, and recent Git history were reviewed before implementation. Baseline on 2026-07-30: `npm ci` passed; 22 tests passed; TypeScript lint passed; production build passed at 525.10 kB JS (151.74 kB gzip) with Vite's 500 kB chunk warning. The checkout contained only a local `work` branch and no configured remote, so `main` could not be checked out or pulled.

## Strengths retained
- Existing cards, badges, forms, role guards, HashRouter, explicit demo isolation, and desktop two-column layouts are reusable.
- A mobile bottom bar, responsive breakpoint, focus outlines, reduced-motion rule, and horizontally contained tables already existed.
- Authentication already used provider-labelled social buttons, autocomplete, password visibility, readable callback status, and one-time server-backed role selection.

## Problems found
- The connected signed-out experience had no bottom navigation, customer/provider navigation omitted Account, and admin navigation lacked the requested operational destinations.
- The filter sidebar became a dense two-column block rather than a dismissible mobile control. It lacked focus trapping, background scroll lock, reset/apply actions, and persisted search-query initialization.
- The five-column provider calendar forced an internal 1,000px-wide calendar on phones. Cards, account tabs, charts, stats, and long identity strings were vulnerable to crowding.
- Fixed bottom navigation used a fixed 68px body offset without the iPhone home-indicator inset. Sticky header/actions did not consistently account for the notch, Safari controls, or the mobile navigation.
- The document lacked a complete HTML/head and `viewport-fit=cover`. Inputs inherited type sizes and could trigger Safari zoom.
- Hero copy and spacing were desktop-led; primary actions could compete and search controls occupied a cramped grid.
- Detail booking remained a desktop sidebar moved into normal flow, rather than a reachable sticky mobile action. Booking actions could be separated from the user's thumb and keyboard.
- Several controls were smaller than 44px. Long names/emails lacked universal wrapping/truncation protection. Page-level overflow protection and dynamic viewport sizing were incomplete.
- Admin tables remain information-dense; table scrolling was contained but mobile card transformation is deferred.

## Route risk summary
| Area | Primary risk before v0.3.3 | v0.3.3 treatment |
|---|---|---|
| Home | oversized hero, competing CTAs | compact typography, stacked actions/search |
| Search | permanent dense filters | sticky summary + accessible filter sheet |
| Cards/detail | price/name collision, distant CTA | wrapping, nonshrinking price, sticky booking card |
| Booking/forms | small inherited inputs, action overlap | 16px inputs, safe sticky actions, dynamic viewport |
| Auth/OAuth | long identity/error strings | global safe wrapping and mobile single-column sizing |
| Customer | tabs and rows crowd | contained tabs, two-column booking row |
| Provider | five-column calendar | phone agenda cards; desktop calendar retained |
| Admin | wide tables | contained table overflow; card conversion deferred |

## Manual verification boundary
Source and automated checks do not prove iPhone Safari, Google/Apple redirects, real keyboard behavior, orientation, or a live Supabase session. Those checks remain explicitly pending in `MOBILE_TEST_PLAN_V033.md`.
