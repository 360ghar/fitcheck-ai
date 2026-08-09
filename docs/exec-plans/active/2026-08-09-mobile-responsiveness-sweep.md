# Plan: Mobile responsiveness sweep (every page, three apps)

Status: active (implementation complete; verification done)  
Started: 2026-08-09  
Owner: droid (orchestrator) + 3 parallel agents

## Goal

Every routable page across the frontend web app (48 routes), the admin console (18 routes), and the Flutter app (35 screens) renders correctly at mobile viewports (320–430px) with no page-level horizontal overflow, usable touch targets, keyboard-safe inputs, and sensible tablet widths. Run as a parallel-agent mission: 4 research agents audited, 3 execution agents fixed, orchestrator reviewed diffs, found and fixed two real overflow bugs, and added lasting mobile e2e coverage.

## Non-goals

- Flutter orientation lock (`main.dart:61` portrait) stays — tablets remain portrait.
- No design-system/token changes; fixes use existing tokens (44px touch, safe-area vars, existing breakpoints).
- Backend, API contracts, gamification flag, and native platform dirs untouched.
- No Flutter `integration_test/` (tracked as TD-096/TD-037 instead).

## Acceptance criteria

- [x] Frontend: ShareOutfitDialog fits 320px (labels split, preview stacks); Navbar sheet scales; wizard labels hide below `xs`; blog search stacks; BatchExtractionFlow/ItemDetailBody/AuthLayout/Hero polish applied; structural mobile test added.
- [x] Admin: RichTextEditor toolbar scrolls; DialogContent scrolls (`max-h-[85dvh]`); filter popover + date filters fit 320px; DataTable gains column sizes, optional `pinnedColumnId` (wired on Users/Subscriptions), wrapping bulk bar, collapsed mobile pagination, truncating headers; promo form stacks; mobile search trigger opens CommandPalette; IAP/UserDetail rows truncate/wrap.
- [x] Admin dashboard: **real overflow bugs found by the new e2e guard and fixed** — grid cards lacked `min-w-0` (activity card rendered 595px on a 390px phone; charts pushed the trends card past the container) → `min-w-0` on dashboard cards, `[&>*]:min-w-0` on both chart grids, `min-w-0 flex-wrap` on the shared PageHeader actions wrapper, trends tabs scroll within available width.
- [x] Flutter: wardrobe filter sheet scrolls + keyboard-safe (verified GetX already pads insets); bottom-nav labels FittedBox; grid sweep to `SliverGridDelegateWithMaxCrossAxisExtent` (17 files); shared 720px max-width for tablets/web; batch screens scrollable; splash/calendar/outfit-builder fixes; empty-state overflow fixed.
- [x] Verification: frontend lint/tests/build green; admin lint/typecheck/229 unit tests/schema/bundle/e2e 14/14 (11 desktop + 3 mobile); flutter analyze clean + 225 tests; `check_all.sh` green.
- [x] Regression guard: admin e2e gained a `mobile-chromium` project (iPhone 13) with a no-document-overflow check on login/dashboard/trends, drawer navigation, pinned-column scroll, and mobile search journeys.

## Context / links

- Related docs: `docs/DESIGN.md`, `frontend/DESIGN.md` (§10 viewports), `flutter/DESIGN.md`, `docs/FRONTEND.md` (responsive-contract test pattern), `admin/README.md` (e2e + i18n).
- Related code: `frontend/src/components/social/ShareOutfitDialog.tsx`, `admin/src/shared/ui/DataTable.tsx`, `admin/src/features/dashboard/pages/DashboardPage.tsx`, `flutter/lib/core/widgets/app_ui.dart`, `flutter/lib/features/wardrobe/views/wardrobe_content.dart`.

## Progress log

| Date | Note |
|------|------|
| 2026-08-09 | Research phase: 4 parallel explorers audited frontend (48 routes), admin (18 routes), Flutter (35 screens), conventions+harness |
| 2026-08-09 | Execution phase: 3 parallel workers implemented per-app fix lists; all app harnesses green |
| 2026-08-09 | Orchestrator review: verified GetX insets claim in pub-cache source; confirmed Hero copy still backed by plan numbers elsewhere; added admin mobile e2e project |
| 2026-08-09 | E2E guard caught real overflow: dashboard cards 595px on 390px phone → min-w-0 fix; trends header pills 391px → PageHeader min-w-0 flex-wrap + scrollable TabsList; retested 390px clean |
| 2026-08-09 | Debt recorded (TD-094..TD-096); exec plan written; final `check_all.sh` |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-09 | Flutter filter sheet gets NO inner viewInsets padding | GetX 4.7.3 `GetModalBottomSheetRoute.buildPage` already pads insets; double-padding collapses the viewport on short screens (verified in pub-cache source + empirically) |
| 2026-08-09 | Hero stat labels shortened (dropped "free"/"on Pro" qualifiers) | Keeps the 3-col grid at 320px; the plan numbers with tier qualifiers still appear in Testimonials/FAQ sections |
| 2026-08-09 | Admin e2e mobile project runs only `mobile.e2e.ts`; desktop project ignores it | Desktop journeys' selectors (sidebar, ⌘K) don't exist on mobile; keeps both suites stable |
| 2026-08-09 | Dashboard/trends overflow fixed via `min-w-0` on grid items rather than `overflow-hidden` | `min-w-0` lets recharts ResponsiveContainer re-measure to the real width; `overflow-hidden` would clip |

## Verification

```bash
cd frontend && npm run lint && npm test && npm run build        # PASS (233 tests)
cd admin && npm run lint && npm run typecheck && npm test       # PASS (229 tests)
cd admin && npm run check:schema && npm run check:bundle        # PASS
cd admin && npm run e2e                                         # PASS 14/14 (chromium 11 + mobile-chromium 3)
cd flutter && flutter analyze && flutter test                   # PASS (225 tests)
./scripts/check_all.sh                                          # PASS
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- TD-094 `report_content_sheet.dart` double-pads keyboard insets (redundant under GetX 4.7.3)
- TD-095 `tryon_content.dart` dead code
- TD-096 No viewport/size-based widget tests in Flutter
- TD-037 note: admin mobile e2e landed; frontend/Flutter e2e still uncovered
