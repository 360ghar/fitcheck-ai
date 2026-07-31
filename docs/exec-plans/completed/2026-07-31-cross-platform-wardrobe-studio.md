# Plan: cross-platform Wardrobe Studio refresh

Status: completed  
Started: 2026-07-31  
Owner: Codex

## Goal

Bring the React web client and Flutter client into the same calm, image-first
Wardrobe Studio system without changing routes, backend contracts, or truthful
AI job semantics. The first implementation pass prioritizes shared tokens,
visibility/accessibility primitives, and the core capture-to-outfit journey.

## Non-goals

- Change API payloads, Supabase schema, or backend job behavior.
- Publish unverified product, performance, or pricing claims.
- Replace Flutter's Home / Photoshoot / Closet / Outfits / More navigation
  model.

## Acceptance criteria

- [x] Flutter uses the red/warm-neutral token system and flat shared surfaces.
- [x] Web primary content is visible on first render and respects reduced motion.
- [x] Core web and Flutter navigation, controls, images, and async status states
      remain accessible and truthful.
- [x] Core wardrobe, outfit, recommendation, calendar, photoshoot, and try-on
      surfaces use consistent image-first patterns.
- [x] Relevant frontend and Flutter checks pass.

## Context / links

- Related docs: `docs/DESIGN.md`, `frontend/DESIGN.md`, `docs/FRONTEND.md`,
  `docs/FLUTTER.md`
- Earlier web baseline: `docs/exec-plans/completed/2026-07-31-pinterest-visual-system.md`

## Progress log

| Date | Note |
|------|------|
| 2026-07-31 | Started cross-platform refinement; preserving the existing uncommitted web visual-system work. |
| 2026-07-31 | Completed the shared token, primitive, landing, public-page, feature-template, and Flutter foundation pass without changing routes or backend contracts. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-31 | Use the red/warm-neutral Wardrobe Studio system on Flutter while retaining native Material interaction patterns. | It creates product parity without a web-like mobile UX. |
| 2026-07-31 | Keep Photoshoot as a primary Flutter tab. | User explicitly selected the existing mobile information architecture. |
| 2026-07-31 | Remove hidden-on-scroll content reveals. | Primary content must never rely on JavaScript animation to become visible. |

## Verification

```bash
cd frontend && npm test && npm run lint && npm run build
cd flutter && flutter test && flutter analyze
python scripts/check_architecture.py
python scripts/check_docs_structure.py
```

Completed 2026-07-31: `npm test`, `npm run lint`, `npm run build`, `flutter analyze`, `flutter test`, architecture, and docs checks pass.

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- Full authenticated browser/emulator review requires a non-production account
  with representative wardrobe and job data.
