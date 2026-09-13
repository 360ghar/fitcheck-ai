# clay-rebuild — clay.com-grade landing + webapp lift

Status: active
Started: 2026-09-13
Owner: orchestrator (dispatches parallel agents per wave)

## Goal

Rebuild the FitCheck AI design language to the quality bar of clay.com, then apply it to the
marketing landing page and the logged-in webapp. The previous flat-editorial system
(`landing-clay-lift`) is the starting point and stays in the working tree — this plan supersedes
its visual direction (its copy/structure/imagery work is kept where it doesn't conflict).

Three user decisions locked for this plan:
1. **Full clay-style rebuild** (not an evolution) — tokens, shadows, radii, illustration direction all change.
2. **Landing + webapp in parallel.**
3. **Nothing gets committed** — all work stays as working-tree changes.

## The clay system (design brief — every agent follows this)

Reference teardowns: clay.com live site; designkit.sh/getdesign/clay; shadcn.io/design/clay;
clay.com/blog/new-homepage-2026. FitCheck keeps its brand red as the conversion color; everything
else adopts clay's physicality.

### Color

| Role | Light mode | Notes |
|---|---|---|
| Page canvas | warm cream `#faf9f7` family (keep current HSL vars, shift to cream) | never cool gray |
| Raised surface | pure white cards | on cream canvas |
| Deeper cream section | `#f5f0e0`-family tint for alternating "rooms" | max 1 tinted room per viewport |
| Borders | oat `#dad4c8` / light oat `#eee9df` | never neutral gray #ccc/#ddd |
| Ink (headings) | near-black warm ink | existing dark-mode ink family |
| Body text | warm gray `#3a3a3a`-family | |
| Muted text | warm silver `#9f9b93`-family | |
| Primary CTA | existing brand red | conversion color only, not decoration |
| Accent tints | keep the 5 tint pairs (coral/amber/teal/violet/blue) | warm them if needed to sit on cream |

Rules: max 2 accent colors per section; never repeat the same accent in consecutive sections; no
cool grays anywhere; dark mode stays warm (current hue-60 near-black) and must keep working.

### Depth (the "pressed into clay" signature)

- Resting shadow `shadow-pressed`: 3-layer stack — cast shadow `0 1px 1px rgba(0,0,0,0.10)` +
  inset highlight `inset 0 -1px 1px rgba(0,0,0,0.04)` + `0 -0.5px 1px rgba(0,0,0,0.05)`. Cards feel
  stamped in, not floating. Apply to primary cards (pricing cards, demo panels, hero canvas,
  highlight tiles). NOT to every div.
- Hover shadow `shadow-offset`: hard offset `rgb(0,0,0) -7px 7px` (no blur) + small translate, on
  interactive cards/buttons. This is the signature interaction — visible, not subtle.
- Focus: 2px solid ring (keep existing focus token, ensure it works on cream).
- The old "all box-shadows are none" flat rule is revoked. `check_theme_tokens.py` must still pass.

### Radii

12px standard controls · 24px feature cards (`rounded-3xl` remap) · 32–40px section containers
(keep `rounded-[2rem]`, add `rounded-[2.5rem]` for page-width containers like footer/CTA).

### Typography

Keep self-hosted Inter + Manrope display. Display scale gets bigger and tighter for the hero
(~clamp 56–80px, tracking −0.03em, weight ≤600 — never extra-bold). Uppercase kicker labels stay
(SectionKicker). Body 18px/1.6 on marketing sections.

### Motion

CSS-only (no new animation libs). Keep scroll-driven `reveal` + reduced-motion kill-switch. Add:
press-then-offset hover pattern (translate + hard shadow, ~150ms ease-out), gentle card tilt or
lift on hover where playful, marquee allowed for logo/proof strips. Everything respects
`prefers-reduced-motion`.

### Illustration direction (anti-"AI-slop")

Hand-made, tactile, claymation-style 3D illustration: rounded organic shapes, matte clay
materials, warm cream/pastel backgrounds, playful contraption vignettes. Objects and scenes, NOT
human faces/hands. Photography stays for proof slots (examples of output), illustration carries
brand moments (hero, primitives, empty states).

### Copy patterns

- Verb-led, benefit-driven, short headlines ("Build systems to grow revenue" pattern).
- Dual CTA rhythm per section: one conversion ("Start free") + one exploration ("Explore …").
- Proof interleaved: every feature claim rides on a verifiable limit/stat from `plan-limits.ts` /
  `demo-limits.ts` — never fabricated metrics or testimonials.
- Thesis hero: FitCheck = "your wardrobe, working for you every morning" energy; subheads state
  capability plainly, no hype.

## Waves

- Wave 1 (parallel): Agent T (tokens+primitives), Agent G (Agnes illustration set).
- Wave 2 (parallel, after Wave 1): L1 top sections, L2 middle + demo panels, L3 bottom + copy,
  W webapp pass.
- Wave 3: full harness + visual judge loop, repairs.

## Non-goals

- Backend, flutter, admin console (tokens shared via CSS vars will not leak there — admin is a separate app).
- New marketing claims, pricing changes, analytics schema changes (existing events only).
- Committing to git.

## Acceptance criteria

- [x] Cream/oat/pressed-shadow token system live in `frontend/src/index.css` + `tailwind.config.ts`; `check_theme_tokens.py` passes; dark mode works.
- [x] `shadow-pressed` / `shadow-offset` utilities exist and are used on primary cards + interactive cards/buttons (verified emitting in built dist CSS).
- [x] ≥12 new illustration assets in `frontend/public/generated/` with manifest in this file; hero is illustration-led (hero-machine LCP).
- [x] Landing: all 14 sections rebuilt to the clay system; demo panels on-token; warm cream footer; dual CTAs present per section.
- [x] Webapp shell/cards/empty states align to the new system (~193 hardcoded utilities swept; EmptyState illustration prop; PageHeader/EmptyState migrations).
- [x] `npm run lint && npm test && npm run build` green in frontend (326/326); theme/architecture/docs checks green.
- [x] Visual judge pass on rendered landing (7 desktop slices + 3 mobile samples + login): 9/11 first pass; 2 fails (TrustBar avatar fixture, HowItWorks voids) repaired by Agent R1 and re-judged pass → 11/11 accepted. Logged-in webapp pages NOT visually judged (no test credentials available; verified via harness + token reasoning instead). Plan stays in active/ pending user review + commit.

## Asset manifest

Filled by Agent G. All files live in `frontend/public/generated/` (`.webp` full + `-640.webp`
variant, q82). Raw PNGs in `/tmp/agnes-raw/` (volatile). Generated via `scripts/gen-agnes.ts`,
model `agnes-image-2.5-flash`. 16:9 ratio confirmed working on the API.

| File | Dimensions | Size (full / 640) | Slot | Status |
|---|---|---|---|---|
| hero-machine.webp | 2624x1472 (16:9) | 187KB / 27KB | Landing hero centerpiece (illustration-led) | done — strong |
| primitive-catalog.webp | 1024x1024 | 65KB / 31KB | Primitive tile: catalog/wardrobe digitization | done — strong |
| primitive-plan.webp | 1024x1024 | 60KB / 31KB | Primitive tile: weekly planner | done — reworked (v1 had garbled pseudo-letter tiles; v2 regen is blank pastel capsules + garments, clean) |
| primitive-preview.webp | 1024x1024 | 51KB / 23KB | Primitive tile: outfit preview (mirror, silhouette only) | done — strong |
| primitive-create.webp | 1024x1024 | 59KB / 30KB | Primitive tile: outfit creation (gripper arms) | done — strong |
| primitive-understand.webp | 1024x1024 | 55KB / 27KB | Primitive tile: wardrobe analytics | done — strong |
| empty-closet.webp | 1024x1024 | 44KB / 21KB | Webapp wardrobe empty state | done — strong (2 hangers vs 1 in prompt; harmless) |
| empty-outfit.webp | 1024x1024 | 79KB / 32KB | Webapp outfit-canvas empty state | done — strong |
| doodle-stitch.webp | 1024x1024 | 43KB / 18KB | Accent graphic: stitched squiggle + button | done — strong |
| doodle-star.webp | 1024x1024 | 15KB / 7KB | Accent graphic: clay star + sparkle | done — usable (sparkle reads as glitter disc) |
| avatar-wardrobe-1.webp | 1024x1024 | 33KB / 16KB | Mascot / avatar placeholder (wardrobe, sunglasses on top, no facial features) | done — strong, on-policy |
| weather-sun-cloud.webp | 1024x1024 | 33KB / 16KB | Weather/planning motif accent | done — note: smiling sun face (cartoon kawaii, not human; QA-judge whether it passes the no-faces bar) |
| demo-strip-bg.webp | 1152x864 (4:3) | 28KB / 13KB | Demo strip section backdrop (low contrast) | done — first attempt had blurred human figures at edges (policy fail, discarded); retry is objects-only, slightly more visible than "faint" but calm |

Pre-existing assets (not regenerated): hero-wardrobe-16x9, outfit-flatlay-4x3, lifestyle-jaipur-3x4,
lifestyle-mumbai-3x4, photoshoot-studio-3x4, avatar-diverse-1x1, demo-beforeafter-base-4x3,
howitworks-wardrobe-4x3, outfit-carousel-{office,evening,festive}-4x3.

## Wave 2 assignments (locked after webapp audit)

Concurrency cap: **2 background agents max** (hard learned — a 3rd dispatch killed a running agent).

- **Agent L1 — top of landing:** Navbar, Hero (illustration-led with `hero-machine`), ProofBar, DemoStrip, TrustBar. Consume Agent T's cheat sheet (pressed/offset utilities, cream room tint).
- **Agent L2 — middle landing:** DemoSection + 3 demo panels on-token (ExtractionDemo/TryOnDemo/PhotoshootDemo use old `rounded-lg`/`bg-secondary`/`text-ash` vocabulary), Features (wire `primitive-*` illustrations), HowItWorks, PhotoshootShowcase, WhoItsFor.
- **Agent L3 — bottom landing:** GuidesStrip, Pricing, ProofBand, FAQ, CTASection, Footer → warm cream close (revokes dark stone-950 footer), copy pass: verb-led headlines + dual CTAs per section.
- **Agent W — webapp:** extend, never fork (frontend/DESIGN.md rule). Scope: `components/wardrobe/` gray/dark-hardcode sweep (102), `components/settings/` + `components/social/ShareOutfitDialog.tsx` + `components/outfits/OutfitCard.tsx` dark: sweep, migrate Photoshoot + Calendar bespoke headers → PageHeader and inline empty handling → EmptyState, wire `empty-closet` / `empty-outfit` illustrations into empty states, dashboard StatCard/ActivationChecklist polish, AppLayout/Sidebar/BottomNav chrome pass.

W-file conflicts: L1/L2/L3 touch only components/landing/** + landing tests. W must NOT touch components/ui primitives, index.css, or tailwind.config.ts (Agent T's); if EmptyState needs an illustration slot and it lacks one, coordinate via this file's progress log first.

### Webapp audit risk notes (Agent W must heed)

- `gray` maps to warm stone and indigo/pink/violet/purple map to brand hexes in tailwind.config — mechanical renames shift hues; check the map per class.
- Tests pin exact classes/copy: `pinterest-system.test.tsx`, `shared-ui-accessibility.test.tsx` (`h-11`, `h-[85dvh]`, `rounded-full`, `columns-*`), `states.test.tsx` (EmptyState copy), `responsive-sweep.test.tsx` (BottomNav `z-30 md:hidden`, Textarea `type-body-md`).
- Literal class maps (EmptyState tones, dashboard AI tiles) need complete class names — no string interpolation.
- 463 `dark:` hardcodes; the wardrobe batch flows' stone-950/800 cluster is the top breakage risk.

## Progress log

- 2026-09-13: Plan approved. Wave 1 dispatched (Agent T, Agent G).
- 2026-09-13: Agent G — 13 clay assets generated via Agnes (16:9 ratio confirmed accepted, zero HTTP-400 refusals, 1 policy-driven retry on demo-strip-bg after blurred human figures appeared at edges). 26 webp files in frontend/public/generated/; manifest below. primitive-plan flagged weak (pseudo-text tiles).
- 2026-09-13: Agent G rework — primitive-plan regenerated (attempt 1 clean): prompt rewritten to blank pastel capsules with explicit "no letters, no numbers, no characters" negatives; both webp variants reconverted. weather-sun-cloud approved as-is by orchestrator.
- 2026-09-13: Agent T first run killed by concurrency limit mid-diff (index.css/tailwind partial). Re-dispatched with continue-from-diff instructions. Webapp audit completed; wave 2 assignments locked above.

## Decision log

- 2026-09-13: Keep brand red as conversion color (identity), clay-ify its treatment — full palette swap risks brand recognition and check_theme_tokens enforcement.
- 2026-09-13: Photography kept for proof slots; illustration carries brand moments (clay's own pattern: calm product, playful brand).
- 2026-09-13: Previous visual-QA blocker (AI faces/hands) avoided by illustration prompt policy: no people.
- 2026-09-13: Agent T (second run) — clay token system live: cream canvas 40 33% 98%, white cards, surface-room/border-soft/silver vars + dark counterparts, shadow-pressed/shadow-offset utilities, .card-interactive/.lift patterns, radius remap 12/24/32/40, display clamp(3.5rem,8vw,5rem) at −0.03em weight ≤600. Primitives clay-ified (solid Button variants pressed/offset/flatten-on-active, Card default shadow-pressed + interactive offset hover, Badge/Input/Textarea/Select stamped). frontend/DESIGN.md + docs/DESIGN.md rewritten for new roles/scale/depth. lint/test/build + theme/arch/docs checks all green; no landing/* files touched.
- 2026-09-13: Agent L1 — landing top rebuilt: Hero now illustration-led (hero-machine LCP with fetchpriority+srcSet, headline "Put your wardrobe to work every morning", type-display-xl, 3 calm supporting-UI cards: weather/decision/saved-wardrobe proof); ProofBar → pressed stat tiles with amber/teal chips (data unchanged from PLAN_LIMITS/DEMO_RATE_LIMITS); DemoStrip → rounded-[2rem] pressed prompt card with doodle-stitch pill sticker, pill input gained focus ring, Generate rides Button offset hover; TrustBar → cream room (bg-surface-room, the viewport's one tint) with card-interactive pressed tiles + honest avatar row kept; Navbar → pill nav links, stamped logo mark, shadow-pressed dropdown, scroll hairline kept. landing-enterprise LCP test updated to hero-machine-640; responsive-sweep guarantees preserved unchanged. lint/test(326)/build + check_theme_tokens green; visually self-reviewed desktop+mobile via preview screenshots.
- 2026-09-13: Agent W (webapp pass) — ~193 hardcoded utility strings swept to tokens across components/wardrobe (Batch*/Extracted*/SocialImport*, 10 files), components/settings (3 panels), ShareOutfitDialog; every `dark:` patch in scope is now a comment. EmptyState gained additive `illustration` prop (rounded pressed tile, onError self-hides) wired to empty-closet-640 (wardrobe) and empty-outfit-640 (outfits, unfiltered state only). Photoshoot + Calendar headers migrated to PageHeader (Photoshoot aria-live step line kept as a sibling; calendar empty banner → EmptyState with Create-event action). Dashboard StatCard pressed+offset hover (no translate, per recorded lesson), AI-tool/quick-action tiles on .card-interactive, ActivationChecklist pressed, BottomNav FAB on .lift, Sidebar active item pressed. AI accents moved indigo/red → accent-purple/tint-violet per the DESIGN.md AI-voice rule (deliberate hue shift; gray→stone warm map respected). lint + 326 tests + build + check_theme_tokens all green; no commits.
- 2026-09-13: Agent L2 — middle landing rebuilt: EditorialPanel now rests shadow-pressed (all 3 demo panels stamp in); demo dropzones moved to oat `bg-secondary/40` washes with primary drag/hover edges + pressed white icon coins; `text-ash`/`border-ash` and raw Button color overrides replaced with Button-primitive CTAs (built-in pressed→offset hover); PhotoshootDemo amber literals → tint-amber token pair; garbled committed ExtractionDemo error block repaired; all demo functionality preserved (rate-limit copy, 2.5s polling + partial streaming, downloads, photoshoot_session_* events, demo-play, LoginPromptModal, mobile snap-rail classes untouched); Features ledger rows keep hairlines but each row now carries its primitive-* illustration tile (640 variant, 80/96px, rounded-2xl, onError-hide, descriptive alt) and the clay hover lives on the tile (resting shadow-pressed → group-hover shadow-offset + translate); HowItWorks → cream room (bg-surface-room) with pressed step coins + pressed image frame; PhotoshootShowcase stays the single dark break with the sanctioned white offset `7px 7px 0 0 rgba(255,255,255,0.9)` hover on the 2 example figures + Explore CTA (black offset invisible on dark); WhoItsFor icon tiles matched to TrustBar (border-soft, rounded-xl) + pressed Mumbai frame. Anchors, 2-figure/caption regexes, snap-rail pins all green: lint/test(326)/build + check_theme_tokens pass; no commits.
- 2026-09-13: Agent L3 (second run; first run died mid-task after partial Footer hash-nav/copy tweaks) — bottom landing rebuilt: GuidesStrip hairline rows → pressed `card-interactive` rounded-3xl cards (TrustBar-tile treatment, amber kicker, anchor `guides` + hrefs kept); Pricing → section on canvas (bg-background, ends the GuidesStrip/Pricing surface-soft doublet), pricing cards + desktop comparison table rest shadow-pressed, Plus column gains an "Everyday" pill to match the mobile card, Switch/snap-rail/plan-limits data untouched; ProofBand → pressed rounded-3xl tiles with one accent (teal icon squares matching the kicker, no fabricated metrics, "Example" pills kept) and a pressed CTA bar with a dual-CTA pair (new exploration CTA "Try the live demo" → scrollToSectionId('demo') + trackLandingCta('proof-demo'); conversion 'proof' event untouched); FAQ → hairline rows → pressed `card-interactive` rounded-2xl accordion cards (Radix Collapsible, accordion keyframes, sticky left, LANDING_FAQS/JSON-LD sync untouched; partial-run PLAN_LIMITS-derived copy kept); CTASection decision: made cream — the dark break stays reserved for PhotoshootShowcase, final CTA is now a page-width rounded-[2.5rem] pressed white card with the sanctioned gradient-primary button as the finale, waitlist column on a quiet bg-secondary/40 wash; waitlist mechanics (joinWaitlist, field ids/labels, error/success states, 'bottom' event, Android + Log-in links) byte-identical; error/success blocks moved to error-pale/success tokens; frontend/DESIGN.md §08 note updated (gradient CTA now "rides the final pressed white card", ink-strip wording revoked); Footer → warm cream close: bg-surface-room rounded-t-[2.5rem], foreground/muted ink, oat hairline column tops, red pressed logo coin; all hrefs, router-aware hash nav, and footer-demo/footer-pricing events kept. Copy pass: GuidesStrip H2 "Guides and comparisons" → "Learn how a digital wardrobe works"; other H2s already verb-led and kept. lint/test(326)/build + check_theme_tokens + check_docs_structure all green; no commits. Deferred to visual judge: Plus-card red header band vs a quieter highlight; footer surface-room rounded seam over canvas on non-home public pages.
- 2026-09-13: Agent R1 (visual-judge repairs) — TrustBar avatar row redesigned from orphaned divider row into a centered pressed honesty pill (rounded-full bg-card shadow-pressed, avatar 640w srcSet + onError-hide kept, copy "Avatars are AI-generated examples / Real member photos are never shown without consent"); HowItWorks steps 02/03 gained matching framed visuals (primitive-catalog-640 → Catalog, primitive-preview-640 → Wear, same rounded-2xl pressed frame + srcSet/onError/lazy as step 01, anchors/links/bg untouched); hero carousel-thumb watch-item closed as capture artifact (headless-Chromium scrolled-viewport check: all three lazy 640w variants load with zero failed requests; srcSet/files verified correct); lint + 326 tests + build green; no commits.
