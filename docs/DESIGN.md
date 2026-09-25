# Design

Status: draft  
Last updated: 2026-09-25

Visual and interaction direction for FitCheck web (and guidance for mobile parity).

## Intent

FitCheck should feel like a **practical wardrobe studio**: calm, image-forward, fast to scan a closet and commit an outfit. Not a generic SaaS marketing template and not a noisy social feed.

## Visual direction: the clay system (2026-09-13)

The web app and landing page share a clay.com-grade "tactile" language, specced
in `docs/exec-plans/active/clay-rebuild.md` and tokenized in
`frontend/src/index.css` + `frontend/tailwind.config.ts`:

- **Color:** warm cream canvas (`40 33% 98%`), pure-white raised cards, a
  deeper-cream section tint (`bg-surface-room`, max one tinted room per
  viewport), oat borders (`#dad4c8` / `#ede8de`) — never a cool gray. Dark mode
  stays warm hue-60 near-black.
- **Depth:** resting `shadow-pressed` (stamped into clay) and the signature
  hard `shadow-offset` hover; ready-made patterns `.card-interactive` / `.lift`.
- **Radii:** 12px controls (`rounded-md`), 24px feature cards
  (`rounded-2xl`/`3xl`), 32px sections (`rounded-[2rem]`), 40px page containers
  (`rounded-[2.5rem]`).
- **Type:** Inter + Manrope (self-hosted, `@font-face` in `frontend/src/index.css`); display up to `clamp(3.5rem, 8vw, 5rem)`,
  tracking −0.03em, weight ≤600.

Token details and contrast tables live in `frontend/DESIGN.md`.

## Brand mark (2026-09-25)

One mark for every surface: three paper tees fanned from the hem, the front
collar cut as a check. Masters, colours and rules are in
`docs/brand/README.md`. Web (clay) and mobile (paper diorama) keep separate
visual systems; only the mark, the favicon and the app icon are shared. Set
the mark bare, never on a tile.

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

## Mobile layering & viewport conventions

Locked in by the 2026-08-31 responsive wave (regression tests in
`frontend/src/components/ui/__tests__/responsive-sweep.test.tsx`).

- **Z-ladder (never exceed your layer):** skip-link 200 > lightbox 100 = toast
  100 > Radix overlays 50 > header/sidebar/JobPill 40 > BottomNav 30. Pick the
  lowest rung that clears your neighbors; do not invent new values.
- **Viewport height:** `svh` for mobile app/auth shells, `dvh` for capped
  scroll regions inside overlays. Raw `vh` and `min-h-screen` are forbidden on
  mobile-visible surfaces (they jump when the URL bar shows/hides).
- **Overlay chrome uses safe-area vars:** dialogs and sheets pad and place
  close buttons with `var(--safe-area-top)` / `var(--safe-area-bottom)`, never
  bare fixed offsets.
- **44px touch targets:** reach the minimum via the `.touch-target` class or
  the `.hit-expand` utility (invisible `::after` hit-area; override the inset
  per side with the `--hit` / `--hit-x` / `--hit-y` vars) — not by visually
  enlarging it.
- **Horizontal rails:** use the `.scroll-rail` utility so rails scroll on the
  x-axis only (no page scroll chaining) and get a consistent affordance.
- **Dialogs are full-screen below `sm`:** mobile dialogs slide up edge-to-edge
  with safe-area padding; the centered modal is the `sm:` behavior.

## Agent guidance

- Match existing patterns in nearby components before introducing new spacing/color systems.  
- For marketing surfaces, follow product taste in this file and repo skills; do not dump large anti-pattern essays into feature PRs.  
- Screenshots for UI PRs when behavior is visual.

## Related

- `frontend/DESIGN.md` — token source of truth (theme tokens, contrast rules)
- `docs/FRONTEND.md`  
- `docs/references/frontend-components.md`  
- `docs/store/` for store listing imagery constraints  
