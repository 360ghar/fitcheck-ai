# Plan: outfits stability and protected-app density

Status: completed  
Started: 2026-07-31  
Owner: Codex

## Goal

Eliminate the Outfits maximum-update-depth error and make protected FitCheck product pages denser without changing public/editorial layouts, AI job truthfulness, or touch accessibility.

## Non-goals

- Change public, auth, SEO, blog, legal, or admin-editorial layouts.
- Add artificial AI progress or introduce image cropping.

## Acceptance criteria

- [x] Derived outfit selectors retain a stable snapshot when relevant source data has not changed.
- [x] Closet and Outfits use a shadow-free, responsive masonry grid with six columns at desktop width.
- [x] Protected product pages use the compact page rhythm without clipping controls or reducing touch targets.
- [x] Frontend tests, lint, build, and diff checks pass.

## Context / links

- Related docs: `docs/DESIGN.md`, `frontend/DESIGN.md`, `docs/FRONTEND.md`
- Related code: `frontend/src/stores/outfitStore.ts`, `frontend/src/pages/outfits/OutfitsPage.tsx`, `frontend/src/components/wardrobe/pin-grid.tsx`

## Progress log

| Date | Note |
|------|------|
| 2026-07-31 | Confirmed the derived `selectFilteredOutfits` returns a new array for every Zustand snapshot, matching React's maximum-update-depth failure. |
| 2026-07-31 | Added shallow selector memoization, focused store/page regressions, six-column masonry, shadow-free collection tiles, and compact protected-page spacing. |
| 2026-07-31 | `npm test`, `npm run lint`, `npm run build`, and `git diff --check` passed. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-31 | Use Zustand `useShallow` for allocation-producing outfit selectors. | It preserves selector ergonomics while preventing a new external-store snapshot when contents are unchanged. |
| 2026-07-31 | Limit density changes to protected AppLayout product routes. | Public and editorial routes have distinct marketing/content goals. |

## Verification

```bash
cd frontend && npm test
cd frontend && npm run lint
cd frontend && npm run build
git diff --check
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None.
