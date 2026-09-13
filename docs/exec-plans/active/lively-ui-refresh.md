# Lively UI refresh — motion + editorial tints

Status: **implemented** (2026-08-31)
Spec: `.factory/specs/2026-09-01-lively-ui-refresh-motion-color-app-landing.md`
Scope: Web only (`frontend/`). No backend, route, or dependency changes.

## Why

The Wardrobe Studio system (one red accent, all-flat surfaces, color-swap-only
transitions) read as dull. This adds two sanctioned levers without breaking the
system: grounded motion and an editorial tint palette. `frontend/DESIGN.md`
§01/§08 are amended as the system of record.

## Phase 1 — Motion primitives

- `ui/button.tsx` — base gains transform press scale (`motion-safe:active:scale-[0.97]`); `icon-circular` hover scale.
- `ui/card.tsx` — `interactive` variant: grounded lift (border shift + 2px translate).
- `ui/skeleton.tsx` + `index.css` — `.skeleton` transform-only shimmer sweep replaces flat pulse; a UI test already asserted no `animate-pulse`.
- `ui/toast.tsx` — spring entrance (`animate-toast-in`, defined in `tailwind.config.ts`) + token-backed `success` variant.
- `navigation/BottomNav.tsx` — FAB press dip; active pill replays scale-in on activation.

## Phase 2 — Editorial tint palette

- `index.css` — 10 vars (`--tint-{coral,amber,teal,violet,blue}` + `-pale`), `:root` + `.dark` inverted pairs.
- `tailwind.config.ts` — `tint.*` color map.
- `scripts/check_theme_tokens.py` — 5 pairs added to `PAIRED_FILLS` (≥4.5:1 both themes; measured 4.85–8.91).
- `dashboard/StatCard.tsx` — coral/amber/teal/violet tones (bar = deep, icon chip = pale fill).
- `DashboardPage.tsx` — stats remapped to tints; AI tools grid gets tinted icon tiles.
- `ui/empty-state.tsx` — `tone` prop (default teal): tinted mark + 30%-alpha tint wash on the panel; `neutral` preserves the old plain-card look.
- `lib/toast-utils.ts` — `showSuccess` uses the `success` variant, replacing hardcoded green literals (a latent dark-mode defect).

## Review pass (same day)

- **Fixed:** toast entrance used `animation-fill-mode: both`, whose final
  transform outranks class transforms and would have permanently broken
  Radix swipe-to-dismiss. Changed to `backwards`.
- **Fixed:** gradient CTA had no hover feedback (the variant's
  `hover:bg-primary/90` is invisible under a background-image gradient);
  added `hover:brightness-110` on a `filter` transition.
- **Spec gap closed:** EmptyState wash added (was icon-tint only).

## Phase 3 — Landing

- `Hero.tsx` — one sanctioned warm radial wash (`--primary`/7%, var-backed, prerender-safe).
- `SectionKicker.tsx` — `tone` prop; sections rotate teal → coral → violet → blue → amber (Pricing keeps red).
- `TrustBar.tsx` / `WhoItsFor.tsx` — fact tiles use tint fills.
- `Features.tsx` — capability verbs tinted per row.
- `CTASection.tsx` — final CTA adopts the previously-unused `gradient-primary` (hex-locked brand red over the ink strip, per DESIGN.md §08).

## Explicitly not done

- No depth/shadow layer (Phase C of the options) — rejected for now to avoid
  the generic-SaaS look and a §07 reversal.
- Demo showcase cards did not get an extra hover lift: their interactive
  surfaces are dropzones/buttons, which already carry the press/scale motion.
- `showWarning` in `toast-utils.ts` still uses yellow literals (no warning
  token exists in the system). Separate follow-up: add a `--warning` pair.

## Verification (all green 2026-08-31)

- `cd frontend && npm run lint` — clean (`--max-warnings 0`)
- `npm test` — 326/326
- `npm run build` — tsc + vite + prerender 42 routes
- `python scripts/check_theme_tokens.py` — passed, tint pairs enforced
