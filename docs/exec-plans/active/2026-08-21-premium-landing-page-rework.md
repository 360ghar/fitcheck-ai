# Premium landing page rework

Status: done (2026-08-21)
Scope: `frontend/src/pages/public/LandingPage.tsx` + `frontend/src/components/landing/`

## What changed

Product-first hero, one dark showcase beat, merged filler sections, token cleanup. The direction is the 2026 premium SaaS pattern (Linear/Raycast: real product UI in the hero, bento features, dark strip) executed inside the existing Wardrobe Studio system (one red accent, warm neutrals, Manrope display, flat surfaces, radius 16/32/full).

1. **Hero** — right side is now a CSS-built app mockup in a device frame (Today screen: weather chip, outfit canvas from cropped garment photos, closet strip, "Today's outfit" card with the red Recommended pill). Left column gains a platform eyebrow chip and a "Free plan · No credit card" trust line; the three stat boxes moved out.
2. **ProofStrip (new)** — the free plan's real limits as one quiet stat row under the hero (numbers pulled from `PLAN_LIMITS.free`, no literals).
3. **PhotoshootShowcase (new)** — full-bleed warm near-black section (identical in both themes, like CTA/Footer) with before/after pair and red CTA to the feature page.
4. **Features absorbs AlsoInApp** — the standalone section folded in as a secondary block; `#also-in-app` anchor preserved on the inner block. `AlsoInApp.tsx` deleted.
5. **Testimonials compressed** to a slim proof band (outcomes row + pull quote, one glance).
6. **CTASection polish** — larger heading, more air.
7. **Token cleanup** — raw `stone-*`/`bg-white` page backgrounds across DemoSection, Features, FAQ, GuidesStrip, HowItWorks, Pricing, Testimonials, WhoItsFor replaced with theme tokens (`bg-background`, `bg-card`, `bg-surface-soft`, `border-border`, `text-foreground`, `text-body`, `text-muted-foreground`), so marketing matches the app at theme boundaries.

## Section order

Hero → ProofStrip → DemoSection → Features (+also-in-app) → HowItWorks → PhotoshootShowcase → WhoItsFor → Testimonials → GuidesStrip → Pricing → FAQ → CTASection

## Guardrails held

- No new image assets; reuses the four `/landing/*.webp` files with tuned `object-position` crops.
- One `<h1>`, JSON-LD (FAQ/HowTo/ItemList) and meta untouched.
- All anchors verified in the prerendered `dist/index.html`: `#demo #features #also-in-app #how-it-works #photoshoot-showcase #who-its-for #guides #pricing #faq #step-*`.
- LCP handling kept: hero image keeps `fetchpriority="high"` + the `prerender-html.mjs` preload.

## Verification

- `npm run lint` — clean
- `npm test` — 52 files / 277 tests passed
- `npm run build` (incl. prerender) — 42 routes rendered, anchors + hero markup verified in `dist/index.html`
- `python scripts/check_theme_tokens.py` — passed
- `npx tsc -b` — clean

## Follow-ups (not done)

- Real product screenshots would outperform the CSS mockup; the repo has none at hero resolution (see `docs/store/app-store-screenshots.md`).
- The photoshoot before/after pair reuses wardrobe/outfit art with honest captions ("One phone photo" / "Studio-style result"); swap for a real generation pair when available.
