# OpenSlot v0.3.3 mobile test plan

## Devices and viewports
Test iPhone SE (320/375), iPhone 12/13/14 (390), iPhone 14/15 Pro (393), iPhone Pro Max (430), Android small (360), Android large (412), iPad portrait (768), iPad landscape (1024), and desktop regression (1440). Rotate every physical device once.

## Browsers
Run iPhone Safari, iPhone Chrome, Android Chrome, desktop Chrome, and desktop Safari where available.

## Route matrix
For signed out, customer, provider pending, provider approved, and administrator, cover: Home; Search; Filters; Opening detail; Booking; Login; Registration; OAuth callback; Choose role; Customer bookings; Saved providers; Account; Provider dashboard; Schedule; Post opening; Onboarding; Earnings; Admin; Trust; How it works. Repeat relevant screens in offline, loading, empty, error, expired, and suspended states.

At each width evaluate `document.documentElement.scrollWidth > document.documentElement.clientWidth`, text zoom need, 44px targets, focus order, active navigation, safe-area clearance, loading/error copy, back/scroll behavior, and reduced motion.

## Manual iPhone Safari checklist
- [ ] Load the live GitHub Pages site; verify no horizontal scrolling and no text requires zoom.
- [ ] Verify header and bottom navigation fit, content is not overlapped, and home-indicator/notch safe areas work.
- [ ] Use service, numeric ZIP keyboard, date input, search results, sort, filter sheet reset/apply/dismiss, and card targets.
- [ ] Verify detail sticky CTA, add-ons, readable reviews, and Back returning to useful results state.
- [ ] Complete booking; verify focused fields and errors remain above keyboard, sticky controls do not cover content, and photo upload opens the iOS picker.
- [ ] Verify login autofill, password manager, validation, password visibility, registration, and long Apple relay email wrapping.
- [ ] With configured credentials only: verify Google redirect, Apple redirect, callback messaging, role selection, returning-user routing, session persistence, and no loop/blank state.
- [ ] Verify customer bookings, saved providers, profile/account, sign out, and protected-route hard refresh.
- [ ] Verify pending-provider status, approved dashboard, agenda schedule, post-opening review/publish, onboarding uploads, earnings labels, and account navigation.
- [ ] Verify admin overview, provider/listing/support access, contained tables, and reachable actions.
- [ ] Rotate portrait/landscape; use browser Back; expand/collapse Safari chrome; verify safe-area layout.
- [ ] Disable network and simulate weak connection; verify message, retry/disabled actions, and no false completion or duplicate submit.

## Desktop regression and screenshots
At 768, 1024, and 1440 verify desktop navigation, filter sidebar, detail sidebar, calendar, tables, demo controls, connected routing, and GitHub Pages hash URLs. Capture homepage, search, detail, login, registration, booking, customer bookings, provider dashboard, schedule, and post opening at 375; tablet at 768; desktop at 1440. Record browser/commit beside artifacts. No physical-iPhone or OAuth result may be marked passed based only on emulation.
