# Plan: mobile responsive sweep (Closet + Profile first)

Status: active
Started: 2026-09-13
Owner: agent

## Goal

Every app page renders without page-level horizontal scroll or crushed controls at 360/390/768px. Closet (`/wardrobe`) upload-review flow and Profile (`/profile`) panels are fixed first; the three riskiest cross-page spots (Recommendations rails, Dashboard grids, Calendar toolbar) are triaged with evidence. Round 3 added a runtime-level Closet pass (shell vars, masonry, input zoom, sheet composition) after the user reported the page still failing on device emulation.

## Non-goals

- Restyling desktop layouts or changing the mobile drill-down IA on Profile.
- Ripping out the sanctioned snap-rail pattern (`scroll-rail`) on Recommendations.
- Marketing/SEO page rework beyond the Hero note in deferred debt.

## Acceptance criteria

- [x] Closet review grid is 1-col at 360px, 2-col from 375px (`xs`).
- [x] Closet filter row keeps search + filter button on one row at 360px.
- [x] Review-card Include switch row is 44px tall; tag remove keeps 36px tap via `hit-expand`.
- [x] Style-tab selected chips stay compact pills (no 44px inflation).
- [x] Referral stats wrap at 360px; ticket badge never squeezes.
- [x] Calendar Week/Agenda/Month buttons have accessible names at all widths.
- [x] `cd frontend && npm run lint`, `npm test`, `npm run build` all green.
- [x] Item cards reserve height before image decode (`aspect-[3/4]` box) — no sliver collapse or CLS storm on slow networks.
- [x] Item detail sheet: no dead zone above the home indicator (was 88px, 156px notched).
- [x] Filter sheet Apply/Clear pinned outside the scroller — reachable without scrolling the body.
- [x] Review-dialog Save footer sticky — reachable without scrolling past every card.
- [x] 390px review cards: brand/material inputs single-column until `sm`; person badge absorbs leftover width; badge hit-zones cannot reach Regenerate/Delete.
- [x] Android sheets/dialogs shrink under the keyboard (`interactive-widget=resizes-content`).
- [x] Round 4 RCA closed: dev serves current CSS (all `xs:`/`md:` media, `aspect-ratio: 3/4` present), viewport meta correct end-to-end, no service worker, no <16px inputs, `useColumnCount` returns 2 at 360px, no element wider than 328px — the "desktop on mobile" report was fixed-geometry card chrome, not a breakpoint/pipeline fault.
- [x] Grid card chrome scales on phones: corner discs 36px + tighter strip/chip padding below `sm`, restored to 44px/`p-3` at `sm`+; mobile filter trigger is 48px beside the search pill. *(Superseded same-day by the pure-image tile rewrite: discs/strip/chip no longer exist on `ItemCard` — the density problem they solved is gone with the chrome itself. The 48px filter trigger stands.)*
- [x] Round 5: `AppLayout` `main` carries `min-w-0` — a flex item can no longer adopt its content's min-content width (the chip rail sums to ~778px) and render the page desktop-wide and clipped at 360px.
- [x] Round 5: closet masonry is dense on phones — 3 columns below 375px, 4 from `xs` through `md` (`useColumnCount`); grid-card chrome adapts to TILE width via `.tile-cq` container queries (discs 28px, chip hidden, strip tightened at ≤10rem). *(The `.tile-cq` half is superseded by the pure-image tile rewrite — no tile chrome left to compact, and the `.tile-cq` classes were removed with it. `useColumnCount` 3/4-column density stands.)*

## Context / links

- Related docs: `docs/FRONTEND.md`, `docs/DESIGN.md`, `ARCHITECTURE.md`
- Audits: round 1 = 4 parallel explorer agents (all routes, Closet, Profile tabs, layout infra) + 2 verification follow-ups. Round 3 = 4 runtime-level agents (shell CSS vars, masonry at 360px, input zoom + 390px card math, sheet/dialog composition) + direct reads. Reports live in-session; key evidence cited per change.
- Related code: `frontend/src/pages/wardrobe/WardrobePage.tsx`, `frontend/src/pages/settings/ProfilePage.tsx`, `frontend/src/components/layout/MasterDetailLayout.tsx`, `frontend/src/components/ui/scrollable-tabs.tsx`, `frontend/src/components/ui/bottom-sheet.tsx`, `frontend/src/components/wardrobe/ItemCard.tsx`

## Progress log

| Date | Note |
|------|------|
| 2026-09-13 | 4 audits + 2 verifications done. 30 routes mapped. |
| 2026-09-13 | Wave 1 Closet (5 edits) + Wave 2 Profile (4 edits) + Calendar labels (3 edits) applied. |
| 2026-09-13 | Recommendations rails + Dashboard 2-up grids verified as deliberate patterns, left as-is (see decisions). |
| 2026-09-14 | Self-review: found + fixed desktop regression from the FilterPanel search fix (`flex-[1_1_0%]` starved the shared search box at md+; now `flex-[1_1_0%] md:flex-[1_1_18rem]`). Full suite re-run: lint 0, 326/326 tests, build green. |
| 2026-09-14 | Review round 2: verified `xs: '375px'` in `tailwind.config.ts` screens; added sweep-test lock for the review grid contract. 327/327 green. |
| 2026-09-14 | Round 3 (user-reported still-broken): 4 runtime agents + direct reads. Root causes confirmed — cards collapse to ~2px pre-decode (backend ships image width/height null), sheet footers buried by broken CSS mechanics (mt-auto no-op, nav padding inside overlay). 11 fixes applied across 9 files; lint 0, 330/330 tests, build green. |
| 2026-09-14 | Round 4 RCA (user: "whole page is desktop at 360px"): eliminated every pipeline suspect with served-byte and DOM evidence (served CSS complete and current, viewport chain intact, clientWidth 360, 26-element width sweep max 328px, no SW/zoom/loop). Verdict: the mobile layout WAS rendering — `ItemCard`'s default variant had zero responsive modifiers, so fixed desktop chrome (two 44px discs ≈ 77% of a 156px tile, `p-3` overlay strip, full-size condition chip) rendered unchanged on phone tiles. Fix: compaction pass on `ItemCard` default variant (discs `h-9 w-9 sm:h-11 sm:w-11`, strip `p-2 sm:p-3`, chip scaled down) + `h-12 w-12` mobile filter trigger. Sweep locks +2. lint 0, 332/332 tests, build green. |
| 2026-09-14 | Round 5 (user: "shows desktop website on mobile + 1 card per row"): authed live repro at 360×800 found the REAL root cause Round 4 missed — `main.flex-1` in `AppLayout` lacked `min-w-0`, so flex `min-width: auto` adopted the wardrobe category-chip rail's min-content (~778px, a flex row sums its items) and laid `<main>` out at 810px inside a 345px client width, clipped by `body`'s `overflow-x-hidden`. Everything past the first masonry column is off-screen → "1 card per row"; the 810px layout → "desktop website". Fix: `min-w-0` on `main` (one line) + densified phones to 3/4 columns (`useColumnCount`: <375px→3, xs→md→4) + `.tile-cq` container-query chrome compaction (discs 28px ≤10rem tile, 24px ≤5.5rem) since viewport `sm:` classes can't see a column's real width. Regression locks: `useColumnCount.test.ts` (13 viewport cases), sweep locks +2 (`tile-cq` markers, `main.min-w-0`). lint 0, 349/349 tests, build green. |

| 2026-09-14 | Round 6 (review pass): the Round 4/5 grid-card chrome (corner discs, `p-2 sm:p-3` strip, condition chip, `.tile-cq` container queries) was REMOVED — `ItemCard` tiles became pure image with all actions on the detail surface (long-press bulk selection moved to `useLongPress`). The chrome-compaction criteria above are annotated as superseded rather than rewritten; `.tile-cq` classes and their sweep locks no longer exist. Density on phones now comes from `useColumnCount` (3/4 columns) alone. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-13 | Keep Recommendations `min-w-[200px]/[250px]` snap rails; no stacking change. | Rails are the sanctioned P2 mobile pattern (`scroll-rail` + snap + hidden scrollbar), parent is `grid-cols-1` on mobile so no sibling is pushed, `md:min-w-0` resets on desktop, body `overflow-x-hidden` blocks page-level scroll. Agent #1 over-flagged a working carousel. |
| 2026-09-13 | Keep Dashboard `grid-cols-2` stat/AI-tool tiles; no 1-col change. | 2-up stat tiles are standard at 360px (~158px); labels use deliberate `line-clamp-1` truncation, not breakage. 1-col would gut the dashboard density for no confirmed overflow. |
| 2026-09-13 | Tag remove uses `[--hit:-12px]` hit-expand, not `touch-target`. | `touch-target` (44px min) inside a `text-xs` pill inflates the pill, the same defect fixed in `chip-group.tsx`. 36px tap passes WCAG 2.5.8 (24px min) with zero layout shift. |
| 2026-09-13 | Profile mobile uses drill-down, not tabs; no tab-overflow work. | By design (`ProfilePage.tsx:380-405`); desktop strip fits 5x100px at 768px with `ScrollableTabs` backstop. |
| 2026-09-14 | ItemCard default img gets a CSS `aspect-[3/4]` box instead of relying on width/height attrs. | Backend writes `width`/`height: None` (`storage_service.py:484-485,565-566`), so no intrinsic ratio exists; without the box every card is ~2px tall until decode and `overflow-hidden` clips all controls. `bg-card` is the matting surface, so letterboxing is invisible. |
| 2026-09-14 | BottomSheet footer became a `footer` prop rendered outside the scroller. | `mt-auto` computes to 0 inside the block scroll wrapper, so `BottomSheetFooter` could never pin. Only one consumer (FilterPanel), so the API change is contained; a11y test updated. |
| 2026-09-14 | Review-card brand/material 2-col moved `xs:` → `sm:`; TouchBadge hit split per-axis; status-badge stack capped. | At 390px (most common phone) review cards are 167px: 2-col inputs collapsed to 68px (~4 visible chars); the `--hit:-10px` badge zone overlapped Regenerate/Delete by ~27px (burns a generation credit on mis-tap). |
| 2026-09-14 | No font-size/zoom remediation on /wardrobe. | R3 verified every focusable input on /wardrobe paths is 16px (`type-body-md`), all selects are Radix buttons; iOS auto-zoom cannot trigger there. |
| 2026-09-14 | Grid card chrome scales per-component instead of adding breakpoints or changing column counts. | RCA proved the mobile branch already engages at 360px (2 columns, correct CSS served); the complaint was desktop-sized chrome inside correctly-sized tiles. Only per-element `sm:` ladders change the perceived density; columns/viewport/pipeline stay untouched. |
| 2026-09-14 | Corner discs drop `touch-target` on phones; `sm:h-11 sm:w-11` restores the 44px target at sm+. | `touch-target`'s min-h/min-w would pin the phone disc at 44px and nullify the compaction; 36px still passes WCAG 2.5.8 (24px) and both discs stay clear of each other on a 156px tile. |
| 2026-09-14 | Mobile filter trigger is `h-12 w-12` while `size="icon"` stays. | The trigger sits beside the 48px search pill; the variant's 44px read as the small control in the row. Wrapper is `md:hidden`, desktop unaffected; `cn` (twMerge) lets className override the variant's h-11/w-11. |
| 2026-09-14 | Round 5 fixes the flex min-width propagation at the layout root (`main.min-w-0`), not per-page. | Round 4's width sweep measured rendered widths after the fact and missed that `main` itself was 810px — any page with a wide intrinsic child (chip rails, nowrap rows) would reproduce. `min-w-0` at the flex item is the canonical fix and covers every route. |
| 2026-09-14 | Densify by JS column count (`useColumnCount`), not CSS grid. | The masonry is JS-distributed (`MasonryGrid`); a CSS `grid-cols` ladder would desync from the placement engine. `xs: 4` keeps a no-down-step ladder (3 → 4 → 4 at md → 5 at lg). |
| 2026-09-14 | Tile chrome compacts via `.tile-cq` container queries with two-class specificity. | Viewport `sm:` classes cannot see a column's real width (the detail split changes it; 4-col tiles are 73–115px). Tailwind v3 emits utilities unlayered, so an equal-specificity unlayered rule does not reliably win the cascade — `.tile-cq .tile-cq-disc` (0,2,0) does. |

## Verification

```bash
cd frontend && npm run lint
cd frontend && npm test
cd frontend && npm run build
# viewport matrix: 360x740, 390x844, 768x1024 (split on/off), 1024x768
# closet specifics: slow-3G throttle on /wardrobe (no sliver band),
# /wardrobe?action=add review step (Save visible before scrolling),
# item detail sheet (no dead zone), filter sheet (Apply visible on open)
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- Hero mini-grid fixed 3-col at 360px (`Hero.tsx:194`).
- Leaderboard stats fixed 3-col (`Leaderboard.tsx:340`).
- Photoshoot result dialog missing `max-h`/`overflow-y-auto` (`PhotoshootResultsStep.tsx:194`).
- ThemeSelector icon-only below 640px (`AppSettingsPanel.tsx:40,61`).
- Batch progress 3-col thumbs at 360px (`BatchExtractionProgress.tsx:158,193`).
- Share dialog tabs fixed 3-col (`ShareOutfitDialog.tsx:295`).
- Gift claim stats fixed 2-col (`GiftClaimPage.tsx:239`).
- Backend: populate real image `width`/`height` at upload (`backend/app/services/storage_service.py:484-485,565-566`, PIL) so intrinsic-ratio attrs land for all consumers; frontend aspect box then becomes exact instead of assumed 3/4.
- iOS keyboard: sheet/dialog footers remain unreachable while typing on iOS (layout viewport does not shrink; `interactive-widget` is Android-only). Needs a `visualViewport` listener translating pinned footers.
- BottomSheet decorative drag handle promises drag-to-dismiss that is not implemented; remove it or wire a real gesture.
- Item detail Sheet is `w-full` on phones, leaving no overlay edge for tap-dismiss; consider `w-[calc(100%-1.5rem)]`.
