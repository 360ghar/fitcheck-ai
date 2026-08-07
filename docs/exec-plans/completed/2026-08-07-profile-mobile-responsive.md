# Plan: Profile page mobile responsiveness (drill-down, fixes, density)

Status: completed  
Started: 2026-08-07  
Owner: agent

## Goal

Make `/profile` on the web frontend genuinely mobile-responsive. On phones
(<md) the page becomes an iOS-Settings-style drill-down: an avatar hero + a
vertical section list on the root, and each section opens as a full-screen
subpage with a sticky back bar. Desktop (≥md) keeps the tab strip with inline
panels. Alongside the restructure, fix concrete mobile issues found in review
(tab-switch scroll position, tab-edge fade colors, sub-44px chip targets,
inconsistent `md:`/`sm:` breakpoints, non-full-width submit) and tighten mobile
spacing density.

## Non-goals

- No backend or API changes; no new routes (the drill-down is one page, two
  presentations driven by `useMediaQuery`).
- No change to `?tab=` deep-link semantics (legacy values still resolve).
- Flutter app is out of scope.

## Acceptance criteria

- [x] Mobile (<768px): root shows avatar hero + 5-row section list + Sign Out;
      each row opens a full-screen subpage with a back bar; back returns to
      root; panels stay mounted (unsaved edits survive back-navigation).
- [x] `?tab=style` deep link opens the Style subpage on mobile and the inline
      panel on desktop; legacy `?tab=` values still resolve.
- [x] Desktop (≥768px): unchanged tab strip + inline panels behavior.
- [x] Section switch scrolls to top (no mid-panel drops).
- [x] Chip suggestion pills meet the 44px touch-target rule.
- [x] Responsive-contract tests cover mobile root/subpage/back, deep link,
      URL push/pop, scroll reset, and desktop tab layout.
- [x] Frontend lint, build, and full vitest suite pass.

## Context / links

- Page: `frontend/src/pages/settings/ProfilePage.tsx` (+ panels in
  `pages/settings/`, `components/settings/`)
- Breakpoints/tokens: `frontend/tailwind.config.ts` (`xs` 375px … `md` 768px),
  `frontend/src/index.css` (`--mobile-header-height`, safe-area vars)
- Media-query hook: `frontend/src/hooks/useMediaQuery.ts` (jsdom-guarded)
- Design language: `frontend/DESIGN.md` (44px touch targets, card surfaces,
  dialog = full-screen sheet on mobile)

## Progress log

| Date | Note |
|------|------|
| 2026-08-07 | Implemented drill-down + fixes + density; added ProfilePage mobile/desktop contract tests. |
| 2026-08-07 | Review pass: fixed stale account-drill state, Stripe ack-param resurrection, plan-panel stale data, focus management, Escape-to-back, SupportPanel touch targets. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-07 | Subpage URLs use `push` for row taps, `replace` everywhere else; in-page back pops history when a push exists, else resets state | Browser back closes a subpage after a row tap, but a deep link must not pop the app out of settings |
| 2026-08-07 | Mobile root keeps the account form inside the Account subpage (pure state, no URL) | Root default is already `tab=account`, so the drill has no URL form; hero on the root covers quick profile view |
| 2026-08-07 | One stable content container shared by desktop inline panels and mobile subpages | CSS-hiding instead of remounting preserves unsaved panel edits across root ⇄ subpage switches |
| 2026-08-07 | Row layouts/buttons swept `md:` → `sm:` (640px) | Matches LocationInput/SubscriptionPanel; landscape phones and small tablets get roomier layouts |
| 2026-08-07 | Review pass fixes: solid `bg-card` sticky bar (repo precedent), `ul/li` section list, `isActive`-gated plan refetch, URL ack-param hygiene | Focus, data freshness, and URL correctness found in post-implementation review. |

## Verification

```bash
cd frontend && npm run lint && npm run build && npm test
python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- none
