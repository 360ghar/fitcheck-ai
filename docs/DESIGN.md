# Design

Status: draft  
Last updated: 2026-07-22

Visual and interaction direction for FitCheck web (and guidance for mobile parity).

## Intent

FitCheck should feel like a **practical wardrobe studio**: calm, image-forward, fast to scan a closet and commit an outfit. Not a generic SaaS marketing template and not a noisy social feed.

## Foundations

- **Hierarchy:** photos and outfit canvases first; chrome second.  
- **Density:** list/grid browsing for wardrobe; more focus on single-item and generation review flows.  
- **Feedback:** long AI jobs need persistent, honest progress (SSE-backed UI, background job affordances)—never fake completion.  
- **Accessibility:** readable contrast, keyboard-reachable controls, labels on icon-only actions.  
- **Motion:** prefer subtle state changes; never hide primary content behind entrance animations that can strand opacity at 0.

## Implementation stack (web)

- Tailwind + Radix/shadcn-style primitives in `frontend/src/components/ui/`
- Feature components under `frontend/src/components/<feature>/`
- Avoid inventing a second design system ad hoc; extend existing primitives

## Agent guidance

- Match existing patterns in nearby components before introducing new spacing/color systems.  
- For marketing surfaces, follow product taste in this file and repo skills; do not dump large anti-pattern essays into feature PRs.  
- Screenshots for UI PRs when behavior is visual.

## Related

- `docs/FRONTEND.md`  
- `docs/references/frontend-components.md`  
- `docs/store/` for store listing imagery constraints  
