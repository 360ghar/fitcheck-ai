# Plan: Paper studio landing

Status: active  
Started: 2026-10-01  
Owner: agent

## Goal

The public landing page (`/`) uses the mobile paper-cut system: Basteleur
display type, paper stocks per section, torn edges, grain and tinted slabs.
The hero is one signature, "Snap your closet once". It is a scroll-driven
sequence that shows FitCheck output: a pile photo, cut-outs with labels, a
closet grid, then one outfit. The 14 landing sections become 9.

## Non-goals

- The logged-in web app keeps the clay system.
- No new npm dependencies. No JS motion library.
- No change to pricing, limits or promo logic.

## Acceptance criteria

- [x] `#root` and `body` use `overflow-x: clip`. Sticky elements and view timelines work.
- [x] Paper tokens have light and dark pairs; they apply through `.stock-*` on the landing, Navbar and Footer (`.paper-landing` sets the body face).
- [x] Basteleur is self-hosted (Latin subset WOFF2 + OFL licence), with a metric-matched fallback.
- [x] The signature renders its end frame by default (no JS, reduced motion, Firefox, prerender).
- [x] No landing element starts at `opacity: 0` (the one inline match in `dist/index.html` is Radix Switch's hidden native checkbox; shared overlay CSS keeps `--tw-enter-opacity: 0`).
- [x] These anchors stay: `demo`, `features`, `also-in-app`, `how-it-works`, `step-*`, `photoshoot-showcase`, `who-its-for`, `guides`, `pricing`, `faq`.
- [x] The LCP preload in `scripts/prerender-html.mjs` matches the hero image. `/` also preloads Basteleur Bold and drops the unused Inter/Manrope preloads.
- [x] Lint, tests (394), the theme-token check, the architecture check and the docs check pass.
- [x] Browser QA passes at 1440, 1024 and 390 px, in light and dark (Chrome). Open: real-phone scroll check; logged-in sticky pages (needs a login).

## Context / links

- Related docs: `frontend/DESIGN.md` §08, `flutter/DESIGN.md` §01-§03, `docs/DESIGN.md`
- Related code: `frontend/src/pages/public/LandingPage.tsx`, `frontend/src/components/landing/`, `frontend/src/index.css`
- Supersedes for the landing: `clay-rebuild.md`

## Progress log

| Date | Note |
|------|------|
| 2026-10-01 | Started. Found the `#root` overflow bug: sticky elements and view timelines were inactive on the live site. |
| 2026-10-01 | Signature assets made with the real pipeline (scratchpad script, not committed): extraction found 6 items in an agnes-generated pile photo; cut-outs from `generate_product_image`; tee, striped top and trousers re-rendered on a chroma backdrop and keyed (white-backdrop matte keeps white backgrounds and cast shadows); outfit from `generate_outfit`. |
| 2026-10-01 | 14 sections became 9; ProofBar, DemoStrip, TrustBar, ProofBand, HowItWorks, SectionKicker and 17 orphaned clay image pairs deleted (TD-105 closed). Landing fonts on `/`: 2 Basteleur files (50 KB) instead of Inter + Manrope (72 KB). CLS 0. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-10-01 | Paper system on the landing only | User choice. One brand look across the landing and the mobile app. The app UI stays clay. |
| 2026-10-01 | Keep the "First month free" copy | The user extended TRYPRO. |
| 2026-10-01 | Pure CSS scroll timeline | Repo rule: no JS motion libs on the landing. The end frame is the fallback. |

## Verification

```bash
cd frontend && npx tsc && npx vite build && node scripts/prerender-meta.mjs && node scripts/prerender-html.mjs  # no IndexNow ping
npm run lint && npm test
cd .. && python3 scripts/check_theme_tokens.py && python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- none. Open checks (not debt): scroll the signature on a real phone and a mid-range Android; walk the 5 logged-in pages whose `sticky` now engages (ExtractedItemsGrid footer, MasterDetailLayout pane, Profile back bar, Wardrobe toolbar, Gifts aside).
