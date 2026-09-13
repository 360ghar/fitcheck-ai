# Plan: landing-clay-lift (Agent A — P1 hero proof-bar demo)

Status: superseded 2026-09-13 by `clay-rebuild.md` (full clay.com-style token + visual rebuild; this plan's copy/structure/imagery groundwork is retained where not conflicting). Checklist below intentionally left unticked — verify against clay-rebuild acceptance criteria instead.
Started: 2026-09-13
Owner: Agent A (P1 hero)

## Goal

Hero lift without new hues or new motion libs: tighten H1 tracking, pill CTAs, LCP flatlay + 3 carousel frames (Agent C drops files), verifiable-only proof-bar under hero, above-fold demo strip (`What occasion?` + 3 chips + Generate → scroll/focus `#demo`), TrustBar avatar row with enterprise-safe captions, repeat `Start free` CTA via existing trial helper, dedupe WhoItsFor art (Mumbai, not Jaipur repeat).

## Non-goals

Pricing / FAQ / CTA / analytics-trial helper edits (Agent B). Image generation (Agent C — assume 7 agreed filenames exist). No new hues, no new animation lib, no PNG commits, no `dark:` in primitives, routes thin.

## Acceptance criteria

- [ ] Hero: H1 tracking -0.03em, pill CTAs (999px), H1 meaning + dual CTA + decision canvas kept, LCP img keeps `fetchpriority=high` only there, 3 carousel frames referenced by exact filenames with lazy/srcset/sizes
- [ ] Proof-bar directly under hero: 3 tiles, real verifiable stats only, metric + 1-line label each
- [ ] Demo strip above fold: text input + 3 chips + Generate → smooth scroll to `#demo` + focus heading, keyboard accessible, 44px targets
- [ ] TrustBar avatar row with `/generated/avatar-diverse-1x1-640.webp`, captions `Member avatar example` / `AI-generated example`, no fake testimonials
- [ ] WhoItsFor uses `lifestyle-mumbai-3x4` (not a Jaipur repeat); showcase keeps Jaipur
- [ ] Repeat `Start free` CTA after hero/proof/strip via existing trial helper (import only)
- [ ] Motion CSS-only (`AnimatedSection`/`hero-in`), `prefers-reduced-motion` intact
- [ ] `npm run lint`, `npm test -- --run`, `scripts/check_theme_tokens.py` green

## Context / links

- Related docs: `docs/FRONTEND.md`, `docs/DESIGN.md`, `ARCHITECTURE.md`
- Related code:
  - `frontend/src/pages/public/LandingPage.tsx`
  - `frontend/src/components/landing/Hero.tsx` (dirty — rebase, never revert)
  - `frontend/src/components/landing/TrustBar.tsx`
  - `frontend/src/components/landing/DemoSection.tsx`
  - `frontend/src/components/landing/WhoItsFor.tsx` (dirty — rebase)
  - `frontend/src/components/landing/PhotoshootShowcase.tsx` (dirty — rebase, keeps Jaipur)
  - `frontend/src/lib/plan-limits.ts`, `frontend/src/lib/trial-offer.ts` (import only)
  - `frontend/src/index.css` (hero/reveal system), `frontend/index.html` (homepage-only LCP preload)
  - Sources for stats: `backend/app/core/config.py` PLAN_*, `backend/app/core/ip_rate_limit.py` DEMO_RATE_LIMITS, `frontend/src/lib/plan-limits.ts`
- Related issues: pricing truth — use current helper values, flag if blocked

## Progress log

| Date | Note |
|------|------|
| 2026-09-13 | Started; verified dirty files, read LandingPage/Hero/TrustBar/DemoSection/index.css/template/plan-limits/trial-offer/WhoItsFor/Showcase/rate limits |
| 2026-09-13 | Done: Hero tracking/pills/carousel wiring, ProofBar, DemoStrip, TrustBar avatar row, WhoItsFor Mumbai-only, LandingPage order Hero/ProofBar/DemoStrip/TrustBar/DemoSection. Green: lint, 63 files/326 tests, tsc, theme tokens 8/8 |
| 2026-09-13 | Agent D finishing pass: (1) all 14 webp pairs exist incl. studio/howitworks/demo-base/carousels/avatar; (2) PhotoshootShowcase second figure = photoshoot-studio-3x4 (-640 src, 640/1728 srcset), caption "Example result, not before/after", dark stone tokens kept; (3) HowItWorks step 1 image howitworks-wardrobe-4x3 (-640, srcset 1152w) with onError hide; (4) TryOnDemo person-step "Demo input photo" thumb (demo-beforeafter-base-4x3-640), input-labeled, never output; ExtractionDemo skipped (no input-thumb slot — bare dropzone); (5) Hero carousel already -640-src + full srcset, no fix; (6) trackLandingCta('demo-play', {demo}) on ExtractionDemo drop + TryOnDemo outfit submit; PhotoshootDemo already covered (photoshoot_session_started/completed/failed), no dupe; (7) ProofBand moved out of Pricing fragment → LandingPage between Pricing and FAQ; Bar (verifiable limits) vs Band (example outcomes) copy distinct; aria-labelledby/SectionKicker/AnimatedSection kept; (8) visual QA BLOCKED — session model has no image input (Read rejects webp, PNG conversion viewable but not consumable); fallback: all 7 full-size decode cleanly at expected dims, tesseract psm-11 OCR shows only single-char texture noise, no coherent words/logos; all new imgs behind onError-hide guards — user spot-check of faces/hands still needed; (9) ORPHANS REPORT ONLY: texture-beige-21x9 (±640) unreferenced anywhere → recommend delete unless wanted as CTA backdrop; public/landing outfit-wide-1280/-640 + wardrobe-640/wardrobe unreferenced (flatlay/outfit still used by featurePageContent.ts) → recommend delete; no rm run. Green: lint, tsc, 63 files/326 tests, theme tokens pass. Test update: responsive-sweep photoshoot assertion now expects 2 example figures + no before/after claim. NOT committed/pushed per instructions. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-13 | Proof-bar = Free plan limits (50 extractions, 50 visualizations, 10 photoshoot/day) + demo IP quotas folded into tile 3 | All verifiable in config.py + plan-limits.ts + ip_rate_limit.py; omit user counts/ratings/speed (unverified, never fabricate) |
| 2026-09-13 | WhoItsFor → single full-width Mumbai tile, drop Jaipur repeat | Showcase keeps Jaipur; removes duplicate art per spec |
| 2026-09-13 | New files ProofBar.tsx + DemoStrip.tsx, LandingPage order Hero/ProofBar/DemoStrip/TrustBar | Routes thin, components small, existing motion/tokens only |

## Verification

```bash
cd frontend && npm run lint
cd frontend && npm test -- --run
python3 scripts/check_theme_tokens.py
# manual: 375px layout, keyboard tab through strip, prefers-reduced-motion static
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
-
