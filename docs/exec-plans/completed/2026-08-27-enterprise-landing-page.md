# Plan: Enterprise Wardrobe Studio landing page

Status: completed
Started: 2026-08-27
Completed: 2026-08-27
Owner: agent

## Goal

Replace the current landing page with a precise, product-led Wardrobe Studio experience for privacy-conscious professionals and creators. The page must use verified product, privacy, billing, and demo evidence while keeping the existing design tokens, typography, public routes, analytics, structured data, and plan constants.

## Non-goals

- No API, backend, database, route, font, dependency, or generated-image changes.
- No customer logos, certifications, testimonials, adoption metrics, or privacy claims that the repository does not verify.
- No changes to the foundational design system outside the landing-page guidance.

## Acceptance criteria

- [x] Navigation groups Guides, Blog, FAQ, and About in an accessible Resources menu while retaining all mobile destinations.
- [x] The hero uses one H1, the approved copy and actions, a responsive outfit decision canvas, and the flat-lay image as its LCP asset.
- [x] Verified trust facts, three live demos, the capability ledger, three-step workflow, photoshoot result, use cases, guides, pricing, FAQ, and final CTA retain all required anchors.
- [x] Desktop pricing uses a comparison matrix; mobile pricing uses snap cards; all numeric values come from `PLAN_LIMITS` and `PLAN_PRICES`.
- [x] The page has no document-level horizontal overflow at 320, 390, 768, 1024, or 1440 px in light, dark, or reduced-motion modes.
- [x] Focus, prerender, schema, theme-token, test, lint, and build checks pass.

## Context / links

- Related docs: `frontend/DESIGN.md`, `docs/DESIGN.md`, `docs/FRONTEND.md`, `docs/SECURITY.md`
- Related code: `frontend/src/components/landing/`, `frontend/src/pages/public/LandingPage.tsx`, `frontend/scripts/prerender-html.mjs`

## Progress log

| Date | Note |
|------|------|
| 2026-08-27 | Started from the existing dirty working-tree baseline. Confirmed the mobile hero created a 520 px implicit grid track inside narrow containers. |
| 2026-08-27 | Added the failing mobile regression first, then replaced the navigation, hero, trust bar, demos, middle sections, pricing, FAQ, final CTA, and footer. |
| 2026-08-27 | Visual inspection found reduced-motion root overflow from offscreen snap children. Paint containment kept each rail local and restored exact viewport-width documents. |
| 2026-08-27 | Production-source inspection found the generic no-JS shell duplicated the prerendered H1. Successful prerenders now remove that fallback; app-shell and skipped routes retain it. |
| 2026-08-27 | Completed the full test, lint, build, theme-token, documentation, structured-data, and responsive verification. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-27 | Use a wide flat outfit decision canvas as the signature element. | It shows real product reasoning without a fake device, invented controls, or obsolete screenshots. |
| 2026-08-27 | Use only repository-verified trust and billing statements. | Enterprise trust requires evidence discipline. |
| 2026-08-27 | Use locally scrolling snap rails below 1024 px and ruled desktop grids at 1024 px and above. | The interactive demos need more width than a three-column tablet layout provides. |
| 2026-08-27 | Keep landing motion transform-only. | Primary content and the flat-lay LCP stay fully painted, and reduced-motion becomes a static layout. |

## Verification

```bash
cd frontend && npm run lint                  # passed
cd frontend && npm test                      # passed: 57 files, 295 tests
cd frontend && npm run build                 # passed: 41 routes rendered, /blog skipped when data was unavailable
python scripts/check_theme_tokens.py         # passed
python scripts/check_docs_structure.py       # passed
```

Browser inspection passed at 320, 390, 768, 1024, and 1440 px. Each document matched its viewport width. The Resources menu opened from the keyboard with a visible focus outline. Light, dark, and reduced-motion modes passed. The production homepage contained one H1, all required anchors, the flat-lay preload, 13 synchronized FAQ schema entries, HowTo schema, and ItemList schema.

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None.
