# Plan: Premium landing motion & polish (quiet-luxury pass)

Status: active
Started: 2026-08-21
Owner: agent

## Goal

Make `/` feel premium (Linear/Stripe-tier) via a **CSS-native motion system with zero new
dependencies**: hero load choreography, scroll-linked section reveals, hover micro-interactions,
a navbar scroll-progress hairline, FAQ height animation, and a grain texture on the dark
showcase beat. All motion is progressive enhancement — unsupported browsers and
`prefers-reduced-motion` users get the static, fully-visible page.

## Non-goals

- No framer-motion or any animation library (bundle + prerender-law reasons).
- No changes to `/features/*` template pages or SeoPageLayout (later pass if wanted).
- No fabricated motion on proof numbers (no count-ups on plan limits/prices).
- No changes to hero preloads, JSON-LD, meta, anchors, or the one-`<h1>` structure.

## Acceptance criteria

- [x] Motion engine lives in `src/index.css` ("Landing motion system" block), gated behind
      `@media (prefers-reduced-motion: no-preference)` and `@supports (animation-timeline: view())`.
- [x] `AnimatedSection` keeps its exact API; `delay` maps to `--reveal-step`; docblock updated.
- [x] Hero: eyebrow → h1 → subcopy → CTAs → trust line → device frame staggered rises (0–260ms).
- [x] Sections reveal on scroll (`.reveal`) and card grids cascade (`.reveal-steps`).
- [x] PhotoshootShowcase: counter-drift before/after + `.texture-grain` at 4% opacity.
- [x] Navbar: 1px scroll-progress hairline (`scroll(root)` timeline, `scale-x-0` fallback).
- [x] FAQ: Radix height animation via `animate-accordion-down/up`.
- [x] Micro: arrow nudges, `active:scale-[0.98]`, border/icon hover shifts (token colors only).
- [x] `frontend/DESIGN.md` §08 documents the scroll-reveal rules.
- [x] Verification suite green (lint, tsc, tests, build+prerender, theme tokens, backend,
      flutter, images-worker). Two pre-existing environment failures fixed en route:
      timezone-dependent promo-script assertion (backend) and stale flutter package graph.

## Context / links

- Related docs: `frontend/DESIGN.md` §08, `docs/DESIGN.md` (motion law),
  `docs/exec-plans/active/2026-08-21-premium-landing-page-rework.md` (structural predecessor).
- Related code: `frontend/src/index.css`, `frontend/src/components/landing/*`.
- Research basis: 2026 SaaS teardowns (real product UI, restraint, micro-interactions,
  performance-as-craft); CSS scroll-driven animations ≈85% browser support
  (Chrome/Edge 115+, Safari 26+, Firefox 157+).

## Progress log

| Date       | Note                                                              |
|------------|-------------------------------------------------------------------|
| 2026-08-21 | Engine + all landing components wired; DESIGN.md updated.        |

## Decision log

| Date       | Decision | Why |
|------------|----------|-----|
| 2026-08-21 | CSS-native scroll timelines instead of framer-motion | Zero JS, zero bundle, prerender-safe, honors the no-JS-gating law; ~85% support with static fallback. |
| 2026-08-21 | Reveal opacity floor 0.4 | Content never reads as missing mid-animation; complies with "never strand opacity at 0". |
| 2026-08-21 | `entry`-based animation ranges (not `cover`) | `cover` scales with element height; `entry 0% → entry N%` settles predictably for tall sections. |
| 2026-08-21 | Drift on inner wrappers in PhotoshootShowcase | Avoids transform clash with the existing `sm:translate-y-8` offset. |
| 2026-08-21 | No count-up stats | Honest-numbers brand rule; motion decorates structure, not claims. |
| 2026-08-21 | Device mockup animates via `.hero-in-frame` (transform-only, no opacity) | Chrome excludes fully transparent elements from LCP; an opacity fade on the frame would delay mobile LCP by its full 260ms delay. |
| 2026-08-21 | Buttons use `transition-[color,background-color,border-color,transform]`, not `transition-transform` | tailwind-merge keeps the last transition class, so `transition-transform` silently removed shadcn Button's built-in hover color fade. |

## Verification

```bash
cd frontend && npm run lint
cd frontend && npx tsc -b
cd frontend && unset NODE_ENV && npm test   # NODE_ENV=production breaks act() in vitest
cd frontend && npm run build                # build + prerender all public routes
python scripts/check_theme_tokens.py        # landing literal budget must hold at 8
grep -c "opacity: 0" frontend/dist/index.html  # expect 0 (prerender never hides content)
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:

- (none new; existing hero-screenshot and before/after-art debt unchanged)
