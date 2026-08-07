# Blueprint: FitCheck AI wardrobe data study (GEO flagship asset)

Status: proposed — needs product sign-off before any numbers are published
Last updated: 2026-08-08

## Why

The Princeton GEO research (arXiv:2311.09735) measured the strongest
visibility levers for AI-generated answers: **citing sources (+40%)** and
**adding statistics (+37%)**. A data study built from FitCheck's own
anonymized wardrobe data is simultaneously:
- a **citable, linkable asset** (journalists, bloggers, and AI engines cite it),
- a **statistics mine** for every guide and comparison page,
- a **differentiator** no competitor can copy (proprietary data).

## Non-negotiables

- **No fabricated numbers.** Every figure must trace to a real, queryable
  dataset and a documented methodology.
- **Privacy first.** Only aggregate, anonymized statistics; no user-identifiable
  information; publish under the existing privacy policy scope.
- State sample size, period, and limitations prominently in the study.

## Candidate findings (query these — publish what is real)

1. **The real cost per wear**: distribution of cost-per-wear across
   categories (outerwear vs basics vs occasion wear).
2. **Utilization reality**: share of wardrobes worn in 30/90 days; most
   neglected categories.
3. **Seasonal rotation**: when festive/occasion items actually get worn.
4. **Extraction accuracy**: user-correction rate on AI-extracted item details.
5. **Weather impact**: how often recommendations change with weather context.

## Methodology template

1. Snapshot tables (items, outfits, wears, prices) for a fixed window;
   exclude test accounts; aggregate at category level.
2. Round aggressively, publish ranges ("~55–60%") not false precision.
3. Have a second reviewer re-run queries before publishing.
4. Note where data is sparse ("n too small to report" beats a bad number).

## Launch checklist

- [ ] Product owner approves dataset + numbers
- [ ] Study page (or blog post) with methodology, tables, and sources
- [ ] Summary infographic + OG image for social distribution
- [ ] Pitch to fashion/sustainability press and newsletter writers
- [ ] Link from `/guides/*`, `/best/*`, and the cost-per-wear calculator
- [ ] Add 2–3 headline stats to `llms.txt` + the landing stats block
- [ ] Track citations: Google (Search Console), ChatGPT/Perplexity/Gemini
      prompts from `docs/geo/measurement-and-monitoring.md` §2

## Related

- `docs/geo/measurement-and-monitoring.md`
- `frontend/public/llms.txt`
