# Plan: Mobile responsiveness — round 2

Status: active
Started: 2026-08-31
Owner: agent

## Goal

Make the web app behave predictably at phone widths: one z-index ladder for all
fixed chrome, safe-area-aware overlay controls, 44px touch targets on shared
primitives, correct viewport-height units, no iOS input zoom or tap artifacts,
and contained scrolling — with the whole wave locked down by jsdom class-contract
tests so future refactors cannot silently regress it.

## Root causes (8)

1. **No shared z-ladder.** Fixed chrome (nav, header, toasts, lightbox, Radix
   overlays) each picked ad-hoc z-indexes, so toasts hid under the header and
   sheets/nav overlapped unpredictably.
2. **Toast anchor ignored fixed mobile chrome.** The toast viewport pinned to
   the screen edge instead of clearing the mobile header plus its safe-area
   inset.
3. **Safe-area insets unhandled on overlay chrome.** Dialog/sheet close buttons
   and top/bottom padding sat under notches and home indicators.
4. **Touch targets below 44px.** Switch, checkbox, slider, wizard steps, tabs,
   and pills relied on the bare control size, failing thumb accuracy on
   small screens.
5. **Wrong viewport-height units.** Raw `vh` / `min-h-screen` jump when the
   mobile URL bar shows/hides; capped scroll regions need `dvh`, app shells
   `svh`.
6. **iOS input zoom + tap artifacts.** Sub-16px control text zoomed the
   viewport on focus; tap highlights and long-press image drag leaked through
   interactive surfaces.
7. **Uncontained scrolling.** Horizontal rails scrolled the page (scroll
   chaining), body overscroll bounced, and rails had no consistent affordance.
8. **Overflow and min-width bugs in text/grid.** Long words blew out blog/FAQ
   layouts; grid/flex children lacked `min-w-0`; wardrobe batch flow and
   calendar mis-measured under rotation/zoom.

## Change list

### Phase A — primitives + z-ladder

- `BottomNav` pinned to `z-30` (bottom rung of the ladder) and still `md:hidden`.
- Toast viewport offset to `top-[calc(var(--mobile-header-height)+var(--safe-area-top))]`.
- `ui/dialog.tsx` close button: `touch-target` + safe-area top offset; content
  closes safe-area and caps height with `dvh`-friendly full-screen mobile layout.
- `ui/sheet.tsx` close button: `touch-target` + safe-area top offset.
- `ui/textarea.tsx` on the `type-body-md` scale (16px+: no iOS focus zoom).
- `ui/bottom-sheet.tsx` heights moved to `dvh`.
- `ui/switch.tsx`, `ui/checkbox.tsx`, `ui/slider.tsx`, `ui/wizard-steps.tsx`:
  invisible `after:` hit-area extensions around small controls.
- Wizard bars container left-aligned (`justify-start`), not centered.
- `ui/dropdown-menu.tsx` items (incl. checkbox/radio) `min-h-[44px]`.
- `TabsList` height `h-11` (44px).
- `JobPill` offset clears fixed nav chrome.
- `index.css`: tap-highlight reset, body `overscroll-behavior: contain`,
  `img` user-drag none, `[role="button"]` select-none, `.scroll-rail` utility.

### Phase B — wardrobe

- Batch flow: hit targets, zoom/pan conflicts, and input zoom fixed.
- `CalendarView` rotation re-measure fix.

### Phase C — app pages

- Photoshoot preview dialog: close button, `dvh` sizing, safe-area padding.
- `min-h-svh` on the 10 standalone/auth shells (no `min-h-screen` jumps).
- Navbar mobile sheet body `overflow-y-auto` (long menus scroll, not clip).

### Phase D — public/blog

- Blog/FAQ/SEO pages: `overflow-wrap` for long words; input zoom fixes.
- Footer grid ladder for narrow widths.
- BlogIndex category pills at 44px; loading skeletons matched (`h-11`).

### Phase E — tests + docs

- `responsive-sweep.test.tsx`: new "app shell + primitive mobile contract"
  describe block, 8 class-contract tests (textarea, dialog/sheet close,
  wizard bars, BottomNav, toast viewport, dropdown item, slider).
- This plan doc; `docs/DESIGN.md` mobile layering/viewport conventions;
  tech-debt follow-ups TD-097..TD-103.

## Non-goals

- No new visual design; existing tokens and layouts are preserved.
- No mobile e2e automation in this wave (see TD-097).
- Flutter and admin consoles untouched.

## Acceptance criteria

- [x] `npm run lint` green (max-warnings 0)
- [x] `npm test` green for all wave-scope suites (324/325; the 1 failure,
  `GiftCardPreview > shows the claim deadline for a promotional gift`, is
  pre-existing uncommitted gift-vouchers WIP — component copy changed against
  its committed test — not wave-caused, left untouched)
- [x] `npm run build` green (includes typecheck)
- [x] `python3 scripts/check_architecture.py` green
- [x] `python3 scripts/check_docs_structure.py` green
- [ ] 375px manual browser pass (pending)

## Context / links

- Related docs: `docs/DESIGN.md` (Mobile layering & viewport conventions),
  `docs/FRONTEND.md`
- Related code: `frontend/src/components/ui/`, `frontend/src/index.css`,
  `frontend/src/components/navigation/BottomNav.tsx`
- Prior wave: `docs/exec-plans/active/2026-08-09-mobile-responsiveness-sweep.md`

## Progress log

| Date | Note |
|------|------|
| 2026-08-31 | Phases A–D landed (frontend sweep); Phase E tests + docs + validation |
| 2026-08-31 | Updated stale `BlogIndexPage.test.tsx` min-h assertions broken by the 44px pill wave (old 8.5rem ladder → 9.75rem ladder, incl. the failed-load `not.toHaveClass` guard) |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-31 | Class-contract jsdom tests instead of visual snapshots | Cheap, stable, and they lock the exact Tailwind classes the wave depends on |
| 2026-08-31 | Wizard bars container gets explicit `justify-start` | Locks the left-aligned contract against a future centered variant regression |

## Verification

```bash
cd frontend && npm run lint && npm test && npm run build
python3 scripts/check_architecture.py
python3 scripts/check_docs_structure.py
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:

- TD-097 No mobile-viewport e2e suite for the web app
- TD-098 Dead `ui/table.tsx` + `ui/pagination.tsx`
- TD-099 DeleteAccountDialog lacks type-to-confirm
- TD-100 OutfitCreatePage CTA ordering
- TD-101 Month-view quick-assign redesign
- TD-102 GiftCardPreview 320px render check
- TD-103 ProfilePage desktop tabs min-w (verified desktop-only, no action)
