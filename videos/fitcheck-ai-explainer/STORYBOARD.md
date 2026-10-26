---
format: 1080x1920
duration: 93.6s
message: "FitCheck AI turns photos of your closet into a personal stylist that decides what you wear."
arc: story-explainer — Hook → Pain → Product intro → Feature tour → Proof → CTA → Closer
audience: fashion-conscious mobile-first users, 24–35, who own 100+ clothing items
mode: autonomous
music: upbeat playful fashion bed — light percussion, optimistic, modern pop energy
---

## Video direction

- **palette system** — frame.md (Capsule remixed onto brand): cream `#FCFAF8` ground with radial candy glows + 4% grain atmosphere on every frame; ink `#1A1A1A` type + the universal 2px stroke; candy accents from the frontmatter — jade `#078675` (the primary accent slot: accent-lines, stat numerals), brand mint `#74DEC0` (the title-pill slot), plus the teal/mint family for fills. Color touches pill fills + stat numerals only — never a Bodoni headline. Soft 8%-ink offset shadows on content-bearing pills only; floating pills flat.
- **motion grammar + reveal model** — `power3` long-tail settles (smooth over bouncy; overshoot only on explicitly playful pops). Every frame reveals sequentially across its back ~50%, timed to the spoken cue — nothing dumped at t=0. Entrances use fromTo. The only aliveness during a hold is subtle jitter (`sine-wave-loop`, low amplitude). No lazy breathing, no back-half pan/push, no `repeat`/`yoyo`, no `Math.random`/`Date.now`, no CSS keyframes — all motion inside the paused GSAP timeline.
- **mascot** — Finn, a folded-paper character: jade `#078675` body, mint `#74DEC0` middle arm (echoing the Facet F mark), 2px ink outline, triangular paper-fold facets, ~15% of frame height. Appears as a small host chip in Frames 1, 3, 6, 8, 13 — never the dominant element (the squint test belongs to type).
- **rhythm / held-frame allocation** — held reads at Frame 3 (brand name), Frame 11 (proof chain — the emotional turn), Frame 13 (closer). Everything else reveals to the VO.
- **portrait discipline** — stack vertically, never side-by-side; centered heroes anchor at y ≈ 0.42 × height (≈ 806px); short kinetic lines, larger type; content lives in the top ~83% — the bottom ~17% is the caption band.
- **negative list** — no purple-blue "AI" gradients, no nav bars/cursors/browser chrome, no blurred or gradient depth, no tenth accent color, no bouncy defaults, and both failure modes: slideshow (front-load then freeze) and screensaver (elements floating independently).

## Frame 1 — The morning panic

- scene: huge Bodoni line "two hundred clothes" swaps to "nothing to wear"; Finn pops in from the bottom edge
- voiceover: "Every morning — two hundred clothes… and nothing to wear."
- duration: 6.02s
- transition_in: cut
- status: outline
- src: compositions/frames/01-morning-panic.html
- type: hook
- persuasion: Rhetorical question + pain validation
- beat: curiosity + recognition
- blueprint: kinetic-type-beats (Reproduce)
- focal: the hero line "nothing to wear" (Bodoni display, ink, italic key word in jade)
- roles: hero line = foreground subject · floating-pill wallpaper = background · Finn = supporting host chip
- sfx: pop, whoosh-short

narrativeRole: Opens the cognitive gap — the viewer's own morning, in one line.
keyMessage: You own a lot; you wear little of it.

Scene 1 (0–0.9s): cream atmosphere + floating-pill wallpaper; "every" then "morning" slam in via **kinetic beat-slam** (`kinetic-beat-slam`), centered, y ≈ 0.42 × height; Finn pops in from the bottom edge on a **spring-pop entrance**, bottom-left corner, ~15% frame height.
Scene 2 (0.9–2s): on "two hundred clothes", the huge Bodoni display line reveals **per-word staggered**, ink, upper-third; three tilted floating pills drift in as wardrobe confetti (flat, no shadow).
Scene 3 (2–6.02s): **hard-cut word-swap** (`discrete-text-sequence`) — the line swaps to "nothing to wear", the key word in jade italic (candy hue on the italic key word), **scale-pop settle** (`power3`); Finn bobs once (finite bounded ambient, low amplitude); hold the read — stillness, no drift.

## Frame 2 — The cost of chaos

- scene: three stat-pills count up — 15 minutes, 3 impulse buys, 50% forgotten
- voiceover: "Fifteen minutes deciding. Three impulse buys a month. And half your closet, forgotten."
- duration: 7.19s
- transition_in: cut
- status: outline
- src: compositions/frames/02-cost-of-chaos.html
- type: pain_point
- persuasion: Statistical proof + concretization
- beat: recognition + concern
- blueprint: dataviz-countup (Adapt)
- focal: the three counting stat-numerals (Bodoni stat-number, colored)
- roles: stat-pill stack = foreground subject · cream atmosphere = background · bar-tracks = supporting
- sfx: click, click, click

Adapt: the count-up ring becomes a vertical stack of three Capsule stat-pills (portrait stack), each numeral counting up on its spoken cue; the push-through camera becomes a gentle settle.
Scene 1 (0–1.6s): cream atmosphere; the first white stat-pill (2px outline, soft shadow) enters upper-center on a **spring-pop entrance**; the Bodoni stat-number "15" **counts up** (`counting-dynamic-scale`) in jade, label "MINUTES DECIDING" in Space Grotesk pill-text; a jade accent bar beneath.
Scene 2 (1.6–3.4s): on "three impulse buys", a second stat-pill slides in below (**push**, `power3`); "3" counts up in brand mint `#74DEC0`, label "IMPULSE BUYS / MONTH"; a bar-track **fills** behind it (`stat-bars-and-fills`).
Scene 3 (3.4–7.19s): on "half your closet, forgotten", the third stat-pill enters; "50%" counts up in deep crease `#065B50`, label "OF YOUR CLOSET, FORGOTTEN"; the three-pill stack holds — **subtle jitter only**, no breathing.

## Frame 3 — Meet FitCheck AI

- scene: scattered paper pills assemble into the wordmark; Finn steps forward as host
- voiceover: "Meet FitCheck AI. Your closet — rebuilt by AI."
- duration: 5.79s
- transition_in: cut
- status: outline
- src: compositions/frames/03-meet-fitcheck.html
- type: product_intro
- persuasion: Concept announcement
- beat: clarity + anticipation
- blueprint: logo-assemble-lockup (Adapt)
- focal: the "FitCheck" wordmark assembling from paper pills (Bodoni display)
- roles: wordmark = foreground subject · scattered paper pills = background · Finn + "AI" title-pill = supporting
- sfx: sparkle, pop

Adapt: the brand-mark build becomes the wordmark assembling from scattered folded-paper pills (no mark asset here — the real Facet F lands in Frame 13); the camera push-through stays as a gentle settle.
Scene 1 (0–1s): cleared cream stage + atmosphere; scattered jade/mint paper pills tumble in from the edges (**depth-scatter-assemble**, `depth-scatter-assemble`) and assemble into "FitCheck" in Bodoni display, ink, centered at y ≈ 0.42 × height — the brand comes to exist (signature move).
Scene 2 (1.1–1.4s): an "AI" title-pill (brand mint `#74DEC0`, 2px outline) pops in above the wordmark (**spring-pop entrance**); Finn steps forward from the bottom and waves once (finite bounded ambient).
Scene 3 (1.5–5.8s): the sub-line "YOUR CLOSET, REBUILT BY AI" types in as Space Grotesk uppercase tracked pill-text beneath (**per-word staggered reveal**, `dynamic-content-sequencing`); hold — stillness, subtle jitter on Finn only.

## Frame 4 — Snap. Cataloged.

- scene: camera pill, photos cascade in, extraction status theater, item receipt checks off
- voiceover: "Snap photos of your clothes. The AI extracts every item — color, fabric, pattern — automatically."
- duration: 8.18s
- transition_in: push-slide UP
- status: outline
- src: compositions/frames/04-snap-catalog.html
- type: feature_showcase
- persuasion: Demonstration + progressive disclosure
- beat: comprehension + fascination
- blueprint: agent-progress-theater (Reproduce)
- focal: the white camera pill-card with its status header and checking receipt
- roles: camera pill-card = foreground subject · photo tiles = supporting · attribute chips + Finn = supporting
- sfx: click, chime, key-press

Scene 1 (0–2.1s): a big white pill-card (camera pill, 2px outline, soft shadow) centers in the upper third; a jade shutter pill-button springs in (**spring-pop entrance**); on "snap", a **press-release spring** (`press-release-spring`) fires and three photo tiles cascade into the card (**cluster→outward expansion**, `center-outward-expansion`).
Scene 2 (2.2–3.4s): the card's header swaps status phrases (**hard-cut token cycle**, `discrete-text-sequence`): "UPLOADING…" → "EXTRACTING ITEMS…" → "3 OF 6 PROCESSED" — honest phase theater in mono pill-text; a bar-track **fills** in jade (`stat-bars-and-fills`).
Scene 3 (3.5–8.2s): the receipt cascades — three item pills ("silk shirt", "denim jacket", "wool coat") check off in a **staggered cascade**, each sprouting a candy attribute chip (COLOR / FABRIC / PATTERN); Finn holds a checkmark badge bottom-left; hold the read.

## Frame 5 — Your wardrobe, alive

- scene: six-slot grid outline fills with wardrobe tiles; a mint quote-highlight wraps "your style"
- voiceover: "Your wardrobe, cataloged and searchable. Favorites, filters, and matches that learn your style."
- duration: 7.66s
- transition_in: push-slide UP
- status: outline
- src: compositions/frames/05-smart-wardrobe.html
- type: feature_showcase
- persuasion: Progressive disclosure + demonstration
- beat: comprehension + delight
- blueprint: grid-card-assemble (Reproduce)
- focal: the self-assembling wardrobe tile grid (white pill-cards, candy card-icons)
- roles: tile grid = foreground subject · "your wardrobe" headline = supporting · quote-highlight = accent
- sfx: key-press, sparkle

Scene 1 (0–0.9s): cream atmosphere; six empty pill-card slots exist as a hairline vertical grid outline; the Bodoni section-headline "your wardrobe" reveals **per-word** (`dynamic-content-sequencing`), top center.
Scene 2 (1–3.9s): on "cataloged and searchable", wardrobe tiles **self-assemble in a staggered cascade** (`center-outward-expansion`) into the grid — each a white pill-card with a circular candy card-icon and a Bodoni card-headline ("shirts", "denim", "dresses"); one tile's heart icon fills jade on "favorites".
Scene 3 (4–7.7s): on "matches that learn your style", two tiles slide together and a mint quote-highlight pill wraps "your style" (**scale-swap transition**, `scale-swap-transition`); hold — subtle jitter only.

## Frame 6 — One tap, one look

- scene: item chips stack into the builder; a jade generate pill fires; a paper-doll look blooms
- voiceover: "Mix and match — or let the AI dress you. One tap generates the look."
- duration: 6.45s
- transition_in: push-slide UP
- status: outline
- src: compositions/frames/06-outfit-builder.html
- type: feature_showcase
- persuasion: Demonstration + concretization
- beat: comprehension + anticipation
- blueprint: prompt-type-submit-generate (Adapt)
- focal: the jade "generate" pill-button and the blooming paper-doll outfit
- roles: generate pill + outfit bloom = foreground subject · item chips = supporting · Finn cameo = supporting
- sfx: click, sparkle

Adapt: the typed prompt becomes a tap on a physical pill-button (the keyboard is the product's own tap); the streaming answer becomes the outfit blooming. Signature move kept: command in → machine answers.
Scene 1 (0–2.5s): a centered white pill-card "the outfit builder"; three item chips (top / mid / bottom) drag into a stack (**cluster→outward expansion**, `center-outward-expansion`); Finn cameo taps the stack (**press-release spring**, `press-release-spring`).
Scene 2 (2.6–2.8s): a jade "GENERATE" pill-button springs in beneath (**spring-pop entrance**); on "one tap", **press-release spring** fires; a thinking row of three dots pulses (finite bounded ambient).
Scene 3 (2.9–6.5s): the generated look blooms — stacked pills assemble into a paper-doll outfit silhouette (**svg self-draw**, `svg-path-draw` + **scale-swap**); the words "the look" slam in as a Bodoni headline (**kinetic beat-slam**, `kinetic-beat-slam`); hold the read.

## Frame 7 — The week, planned

- scene: a vertical strip of seven day-stations; camera pans down; weather pills pop in
- voiceover: "Plan the week. It checks your calendar and the weather — so you never freeze in a meeting."
- duration: 6.51s
- transition_in: push-slide UP
- status: outline
- src: compositions/frames/07-calendar-weather.html
- type: feature_showcase
- persuasion: Signposting + demonstration
- beat: comprehension + foresight
- blueprint: spatial-pan-stations (Adapt)
- focal: the seven-station day strip with its weather pills
- roles: day strip = foreground subject · weather pills = supporting · Thursday consequence tile = focal payoff
- sfx: whoosh-short, pop

Adapt: the lateral station pan becomes a vertical pan down the portrait strip (portrait discipline); the stations are days, not milestones. Signature move kept: one camera traversing labeled stations.
Scene 1 (0–0.9s): a full-width vertical strip of seven day-stations (MON–SUN) as small pill-cards; the headline "plan the week" reveals **per-word** (`dynamic-content-sequencing`), top center.
Scene 2 (1–2.8s): the virtual camera **pans down the strip** (`viewport-change`), centering each station; weather pills (sun / cloud / rain candy icons) **pop into** each day (**spring-pop entrance**, staggered); "CALENDAR" and "WEATHER" labels glow on their cues (`asr-keyword-glow`).
Scene 3 (2.9–6.5s): the camera locks on a THU station where a meeting pill and a rain pill sit beside a styled outfit tile (the consequence); a jade quote-highlight wraps "never freeze"; hold the read — stillness.

## Frame 8 — Try it. Shoot it.

- scene: two paired pill-cards enter top and bottom with mirrored tilts; each dresses its paper figure
- voiceover: "See it before you wear it. Virtual try-on. Photoshoot-ready images, straight from your phone."
- duration: 7.58s
- transition_in: push-slide UP
- status: outline
- src: compositions/frames/08-tryon-photoshoot.html
- type: feature_showcase
- persuasion: Comparison of two options + demonstration
- beat: comprehension + delight
- blueprint: comparison-split (Adapt)
- focal: the two paired cards — "try it on" and "shoot it"
- roles: paired cards = foreground subject · paper figures = supporting · inner-edge badges = accent
- sfx: whoosh-short, click

Adapt: the side-by-side wings become a top/bottom stack (portrait discipline) with mirrored rotationY tilts; signature move kept — paired entry + inner-edge badge spring-pops.
Scene 1 (0–1.4s): two paired pill-cards enter from top and bottom wings with **mirrored split-tilt entry** (`split-tilt-cards`); the headline "see it before you wear it" reveals **per-word** (`dynamic-content-sequencing`), center.
Scene 2 (1.5–3.4s): on "virtual try-on", the top card's paper figure dresses itself — outfit pills drop onto a silhouette (**svg self-draw**, `svg-path-draw`); on "photoshoot-ready", the bottom card blooms into a three-frame photo strip (**cluster→outward expansion**) with a shutter pill (**press-release spring**).
Scene 3 (3.5–7.6s): inner-edge pill badges spring-pop on each card ("REALISTIC", "READY") (`spring-pop-entrance`); the pair holds — Finn peeks between the cards, bottom center; subtle jitter only.

## Frame 9 — The gap finder

- scene: a style hub; suggestion satellites spring into orbit; camera pushes in on the score
- voiceover: "It finds the gaps — the missing jacket, the better alternative — and scores what you already own."
- duration: 7.41s
- transition_in: push-slide UP
- status: outline
- src: compositions/frames/09-gap-finder.html
- type: feature_showcase
- persuasion: Concretization + progressive disclosure
- beat: comprehension + fascination
- blueprint: constellation-hub (Adapt)
- focal: the "your style" orbit-center with its suggestion satellites
- roles: orbit-center = foreground subject · satellites = supporting · wardrobe-score bar-track = supporting
- sfx: sparkle, whoosh-short

Adapt: the hub is a Capsule orbit (treatment 5) — a circular center with orbiting candy pills; the camera push-in collapses depth onto the center. Signature move kept: nodes spring into a ring around a center.
Scene 1 (0–0.6s): center stage: a large circular orbit-center labeled "your style" in Bodoni orbit-numeral; three satellite pills sit dim at their orbital positions.
Scene 2 (0.7–3.6s): on "finds the gaps", four suggestion satellites **spring into an elliptical orbit** (`orbit-3d-entry`) — "the missing jacket", "better alternative", "similar finds", "sustainability score"; the gap node pulses jade on its cue (`asr-keyword-glow`).
Scene 3 (3.7–7.4s): the camera **pushes in** (`multi-phase-camera`) collapsing **depth-of-field** onto the center (`depth-of-field-blur`); a bar-track fills beside it, labeled "WARDROBE SCORE" (`stat-bars-and-fills`, placeholder value — no numeral); hold — stillness.

## Frame 10 — Share. Streak. Climb.

- scene: a pinned streak pill anchors center; state pills cycle beneath; a leaderboard rail assembles
- voiceover: "Share the fit. Build streaks. Climb the leaderboard."
- duration: 5.30s
- transition_in: push-slide UP
- status: outline
- src: compositions/frames/10-social-gamification.html
- type: feature_showcase
- persuasion: Numbered enumeration + demonstration
- beat: momentum + delight
- blueprint: fixed-anchor-cycle (Adapt)
- focal: the pinned flame streak pill (jade, 2px outline)
- roles: streak anchor = foreground subject · cycling state pills = supporting · leaderboard rail = supporting
- sfx: chime, click

Adapt: the fixed anchor is a flame streak pill; the cycling region is a stack of state pills beneath it, hard-cut swapping on VO cues; the leaderboard rail assembles as the resolution. Signature move kept: the anchor's stillness is the claim.
Scene 1 (0–0.8s): a pinned anchor pill dead-center: a jade flame pill-card labeled "STREAK" (Bodoni card-headline + pill-text) — enters once, never moves (**spring-pop entrance**).
Scene 2 (0.9–1.6s): beneath the anchor, the adjacent region cycles through discrete states (**hard-cut token cycle**, `discrete-text-sequence`): "SHARE THE FIT" → "BADGE UNLOCKED" → "LEADERBOARD" — each a pill-card popping in on its VO cue (`dynamic-content-sequencing`).
Scene 3 (1.7–5.3s): a mini leaderboard rail (three ranked pill-rows, Bodoni ordinals 1 / 2 / 3 in candy numerals) assembles via **cluster→outward expansion**; the anchor holds still above — subtle jitter on the flame only.

## Frame 11 — Proof, three ways

- scene: three quote cards seamed by hard cuts — Emma, Marcus, Priya
- voiceover: "Emma found fifty new outfits in the clothes she already owned. Marcus saves two hours every week. Priya grew engagement forty percent."
- duration: 10.45s
- transition_in: crossfade
- status: outline
- src: compositions/frames/11-proof.html
- type: social_proof
- persuasion: Worked example with real numbers + social proof
- beat: conviction + satisfaction
- blueprint: titlecard-reveal (Adapt — card chain)
- focal: each card's colored stat-number with its mint quote-highlight phrase
- roles: quote card = foreground subject · attribution = supporting · quote-highlight = accent
- sfx: whoosh-short

Adapt: runs as the card-chain variant — three near-still monochrome pill-cards seamed by instant hard cuts, each with exactly one restrained move (slide-up crossfade). Signature move kept: one restrained reveal, then a still hold.
Scene 1 (0–3.3s): cream atmosphere; card 1 (white pill-card, soft shadow, 2px outline) wipes in via **slide-up crossfade**: Bodoni quote with a mint quote-highlight pill wrapping "fifty new outfits"; attribution "EMMA · WARDROBE REBUILT" in pill-text.
Scene 2 (3.4–5.6s): instant **hard cut** (`discrete-text-sequence` seam) to card 2: "two hours saved every week" highlight pill; attribution "MARCUS · BUSY EXECUTIVE".
Scene 3 (5.7–10.5s): hard cut to card 3: "engagement up forty percent" highlight; attribution "PRIYA · CONTENT CREATOR"; each card's numeral lands as a colored Bodoni stat-number (jade / mint / deep crease); hold — stillness, subtle jitter.

## Frame 12 — Start free

- scene: a resting free pill condenses into a jade CTA; checkmark pills cascade; a press lands
- voiceover: "Start free. Plus and Pro unlock try-on, analytics, and planning — yearly billing gets two months free."
- duration: 8.03s
- transition_in: cut
- status: outline
- src: compositions/frames/12-start-free.html
- type: cta
- persuasion: Question→answer pairing + demonstration
- beat: resolve + confidence
- blueprint: cta-morph-press (Reproduce)
- focal: the condensed jade "start free" CTA pill
- roles: CTA pill = foreground subject · plus/pro satellite pills + checkmark pills = supporting · confirm ripple = accent
- sfx: click, chime

Scene 1 (0–1.4s): a resting white pill-card centers: "free" in Bodoni headline; beneath, two satellite pills "plus" and "pro" spring in (**spring-pop entrance**, staggered).
Scene 2 (1.5–3.9s): on "unlock try-on, analytics, and planning", three checkmark pills cascade in (`dynamic-content-sequencing`): "VIRTUAL TRY-ON", "ANALYTICS", "CALENDAR PLANNING"; the resting pill **condenses at the same center into a brighter jade CTA** (**scale-swap transition**, `scale-swap-transition` — the signature move).
Scene 3 (4–8s): the condensed CTA reads "START FREE" in Bodoni; a "YEARLY = 2 MONTHS FREE" pill pops beneath (**spring-pop entrance**); a cursor-less **press** lands (`press-release-spring`) with a confirm ripple; hold — stillness.

## Frame 13 — The lockup

- scene: the real Facet F mark draws on; the wordmark resolves; Finn waves; the sign-off types in
- voiceover: "FitCheck AI. Worn yesterday. Decided in seconds."
- duration: 7.00s
- transition_in: crossfade
- status: outline
- src: compositions/frames/13-lockup.html
- type: branding
- persuasion: Distillation + callback
- beat: clarity + resolve
- blueprint: logo-assemble-lockup (Reproduce)
- focal: the Facet F mark (public/facet-f-mark.svg) drawing itself on
- roles: Facet F mark = foreground subject · "FitCheck AI" closing-display = supporting · sign-off + Finn = supporting
- sfx: impact-bass-1

Scene 1 (0–1.3s): the stage clears to cream atmosphere + floating-pill wallpaper; the real Facet F mark (`public/facet-f-mark.svg`) **draws itself in** (`svg-path-draw`), centered upper-third — the brand sting.
Scene 2 (1.4–2.2s): "FitCheck AI" resolves in Bodoni closing-display beneath the mark (**per-word staggered reveal**, `dynamic-content-sequencing`); Finn waves center-bottom (finite bounded ambient).
Scene 3 (2.3–7s): the sign-off "WORN YESTERDAY. DECIDED IN SECONDS." types in as Space Grotesk uppercase tracked pill-text, "decided in seconds" wrapped in a mint quote-highlight pill; a jade accent-line beneath; hold to the final frame — stillness, no exit motion (the harness transition owns the exit).
