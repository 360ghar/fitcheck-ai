# Design

Status: draft  
Last updated: 2026-07-26

Visual and interaction direction for FitCheck web (and guidance for mobile parity).

## Intent

FitCheck should feel like a **practical wardrobe studio**: calm, image-forward, fast to scan a closet and commit an outfit. Not a generic SaaS marketing template and not a noisy social feed.

## Foundations

- **Hierarchy:** photos and outfit canvases first; chrome second.  
- **Density:** list/grid browsing for wardrobe; more focus on single-item and generation review flows.  
- **Feedback:** long AI jobs need persistent, honest progress (SSE-backed UI, background job affordances)—never fake completion.  
- **Accessibility:** readable contrast, keyboard-reachable controls, labels on icon-only actions.  
- **Motion:** prefer subtle state changes; never hide primary content behind entrance animations that can strand opacity at 0.

### Processing status vocabulary

A concrete elaboration of the honest-progress rule above. Every flow that
waits on a backend job (batch upload, photoshoot, try-on, outfit generation,
social import, avatar upload) aligns its copy to this table instead of
inventing its own phrasing per component:

| Phase | When shown | Copy pattern |
|---|---|---|
| Uploading | Client is sending image bytes | "Uploading photo…" (+ real byte % if available, else indeterminate) — never fabricate a percentage |
| Queued | Backend genuinely queued the job (only for real job/queue flows: batch extract, photoshoot, social import) | "Queued…" |
| Processing (phase-specific) | Backend reports a real sub-phase via SSE | Use the backend's own phase strings/counters, e.g. "Extracting items…", "Generating photos…", "3 of 10 processed" |
| Processing (opaque) | Single synchronous call, no phases (try-on, outfit generation, avatar upload) | "Processing… (Ns elapsed)" — elapsed time only, never a fake percentage |
| Done | Terminal success | Brief confirmation |
| Failed | Terminal failure | Real error message + retry action |

## Implementation stack (web)

- Tailwind + Radix/shadcn-style primitives in `frontend/src/components/ui/`
- Feature components under `frontend/src/components/<feature>/`
- Avoid inventing a second design system ad hoc; extend existing primitives

## Agent guidance

- Match existing patterns in nearby components before introducing new spacing/color systems.  
- For marketing surfaces, follow product taste in this file and repo skills; do not dump large anti-pattern essays into feature PRs.  
- Screenshots for UI PRs when behavior is visual.

## Related

- `frontend/DESIGN.md` — token source of truth (theme tokens, contrast rules)
- `docs/FRONTEND.md`  
- `docs/references/frontend-components.md`  
- `docs/store/` for store listing imagery constraints  
