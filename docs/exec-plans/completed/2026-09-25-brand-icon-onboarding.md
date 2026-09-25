# Plan: brand mark, app icon, and onboarding

Status: completed  
Started: 2026-09-25  
Owner: agent

## Goal

One shared brand mark (a layered paper garment) is used for the mobile app
icon, the launch screens, the web and admin favicons and the in-app logos.
Mobile gets three intro pages before sign-in. Web and mobile get a short
post-signup setup (gender, styles and occasions, first item).

## Non-goals

- Web and mobile keep their own visual systems (web clay, mobile paper
  diorama). Only the mark and the favicon are shared.
- The web dashboard "Getting started" checklist is not changed.
- No backend schema change.

## Acceptance criteria

- [x] SVG masters in `docs/brand/`; every raster comes from
      `scripts/render_brand_assets.sh`.
- [x] Mobile icon, adaptive icon (with monochrome) and iOS/Android launch
      screens use the new mark on the ink stock `#E3E9F1`.
- [x] Web and admin use one `favicon.svg`; web has `.ico`, apple-touch-icon,
      PWA icons and `site.webmanifest`; the indigo OG card is gone.
- [x] One web `Logo` component replaces the four inline marks.
- [x] Mobile `/intro` shows once for signed-out users.
- [x] `/welcome` setup on web and mobile shows once for new accounts.

## Context / links

- Related docs: `docs/DESIGN.md`, `docs/brand/README.md`,
  `docs/store/app-store-listing.md`, `docs/store/play-store-aso.md`
- Related code: `flutter/lib/app/router.dart`,
  `flutter/lib/features/onboarding/`, `frontend/src/components/brand/Logo.tsx`,
  `frontend/src/pages/WelcomePage.tsx`, `frontend/src/lib/activation.ts`

## Progress log

| Date | Note |
|------|------|
| 2026-09-25 | Started |
| 2026-09-25 | Mark, icon, launch screens, favicons, web Logo, mobile intro, web + mobile setup shipped. Verified: frontend lint/vitest/build, admin lint/typecheck/test, flutter test (454) + goldens, theme-token, docs and CSP checks, iPhone Air simulator run (icon, launch, intro). |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-25 | Setup gate: no gender, no preferred styles, account younger than 7 days, no local done-key | Catches email and OAuth signups with no backend column; keeps existing users out |
| 2026-09-25 | Mobile gate uses empty preferred styles, not gender | Mobile `UserModel` has no gender; adding it needs a freezed regen (TD-118) |
| 2026-09-25 | Launch screens are light-only | The in-app splash takes over after a few frames; add dark variants if users report a flash |

## Verification

```bash
./scripts/render_brand_assets.sh
(cd frontend && npm run lint && npm test && npm run build)
(cd admin && npm run lint && npm run typecheck && npm test)
(cd flutter && flutter test && flutter test --tags golden)
./scripts/check_all.sh
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- TD-117: the setup done flag is per device.
- TD-118: mobile `UserModel` has no `gender`.
