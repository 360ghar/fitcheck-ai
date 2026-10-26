# Craft: how a 15-second video gets watched twice

## Finding the twist
The literal version of any brief is the one everyone else makes. Before building, run the idea through these lenses and take the one that makes you smile or lean in:

| Lens | Move | Example (brief: "our app saves you time") |
|---|---|---|
| **Metaphor** | Show the idea as a physical thing | Hours pour out of a clock like sand; the app is a lid that stops the leak |
| **Reversal** | Start with the opposite and flip it | A calendar packed solid, then blocks slide out one by one until it's a clean week |
| **Scale jump** | Zoom from tiny to huge (or back) | One saved minute zooms out into a year of saved minutes: 6,000 dots form a shape |
| **The number** | One number, animated so it lands | "4h 12m", counting up, then shown as a sunset you actually got to see |
| **Personify** | Give the object a personality | The notification badge is tired, sighs, and falls asleep |
| **Before / after** | Split the screen, or wipe between the two | Chaos left, calm right; a wipe drags the calm across |
| **Stakes** | Show what's at risk in 1 second | The battery at 1%, the unsaved doc, the cursor hovering |
| **Pattern break** | Repeat something 3 times, break it on the 4th | Three identical grey days, and the fourth explodes in colour |

Pick one twist and commit to it. A single clear twist beats three clever ones.

## Hooks (0.0–0.5 s)
The first frame is the thumbnail of the scroll. Something is already on screen, already moving, already making a sound.
- **Slam:** a single huge word or number slams in on frame 0, with an impact and a flash.
- **Mid-action:** open with the thing already happening (falling, spinning, counting).
- **Tension object:** one charged object dead centre (a red 1%, a lit fuse, a cursor over "Delete").
- **Question:** 2–4 words that demand an answer ("Guess the price."), set big.
- **Impossible motion:** a camera push that feels too fast, a shape that folds into another.

Never fade from black, never open on a logo, never start with a slow build and nothing on screen.

## Structures

**10 s (4–6 bars):** hook (bar 1) → one turn (bars 2–3) → payoff and end card (last 1–2 bars).

**15 s (6–8 bars):** hook (bar 1) → set-up (bars 2–3) → build or riser (bar 4) → drop, the signature move (bars 5–6) → end card (bars 7–8).

**20 s (8–10 bars):** hook → set-up → complication → silence → drop → payoff → end card.

The drop, the moment of highest energy and the signature move, sits at about 50–65% of the runtime (the start of bar 5 of 8 is 50%). Put 0.2–0.5 s of near-silence and stillness right before it.

## Tempo and length (whole bars)
| Length | BPM options (bars) |
|---|---|
| 10 s | 96 (4 bars) · 120 (5) · 144 (6) |
| 15 s | 96 (6) · 112 (7) · 128 (8) · 144 (9) |
| 20 s | 84 (7) · 96 (8) · 108 (9) · 120 (10) · 132 (11) |
`BAR = 240 / bpm` seconds. Set `FILM.bpm` and `--seconds` so they match, then put scene boundaries on bars and hits on beats. The whole-bar rule beats a style's usual BPM range: pick the table value nearest to it (ink at 10 s → 96).

## Signature moves (pick one, make it perfect)
- **Through-the-object transition:** push the camera into a letter's counter, a dot or an eye, and come out in the next scene (`camera` zoom with `eInExpo`, plus `iris`).
- **Morph:** a shape becomes the next shape (`morph(a, b, u)`).
- **Type as architecture:** words stack, rotate and lock together into one composition on the drop.
- **Number to image:** a counter finishes and its digits break apart into particles that form a picture or icon.
- **Mask reveal:** the next scene is revealed through the shape of a word (`masked`).
- **Grid cascade:** a grid of tiles flips or colours in a wave timed to 16th notes.
- **Match cut:** the same shape or position carries across two scenes (a circle becomes the sun, then a coin, then a button).
- **The pause:** everything freezes for half a beat of silence, then the drop hits.

## Motion rules
- **Easing:** entrances use `eOutQuint`/`eOutExpo`, exits use `eInExpo`, camera moves use `eInOutExpo`, bouncy things use `spring`/`eOutBack`. Never linear, except for constant drift and particles.
- **Timing:** small things 0.2–0.35 s, big moves 0.5–0.9 s, holds at least 0.6 s. Stagger 30–70 ms per word or item.
- **Anticipation:** a small reverse move (5–10%) before a big one. **Overshoot and settle** on arrival.
- **Everything alive:** during holds keep a slow drift (1–3% scale, subtle `snoise` float) so the frame never goes dead. The final end-card hold is the exception: nearly still.
- **Beat sync:** accent hits with `pulse(t, hitTime)` driving a scale bump (1 → 1.06), a flash or a shake. Hit on the beat, not near it.
- **Depth:** foreground moves faster than background (parallax). Blur or dim what isn't the focus.

## Typography
- **Size:** in vertical 9:16, headlines are 110–220 U (short words up to 320 U) and body is at least 56 U. In 16:9, headlines are 120–240 U. If it feels big, it's right.
- **Words:** at most about 6 on screen at once, 1–3 lines. Cut every word that isn't needed.
- **Tracking:** big display type gets tight tracking (−0.02 to −0.04). Small labels, uppercase, get wide tracking (+0.08 to +0.15).
- **Pairing:** one display face plus one supporting face at most. Good pairs: Boldonse + Geist Mono · Big Shoulders + Instrument Sans · Instrument Serif (italic) + Bricolage Grotesque · Gloock + Outfit · Tektur + Geist Mono.
- **Hierarchy:** one word gets the accent colour or the weight, never several.
- **Contrast:** light on dark or dark on light, with at least a 4.5:1 feel. No text over busy texture without a backing shape.

## Composition
- **Vertical 9:16:** stack elements vertically, centred on `CX` within `SAFE.wc`. Keep key content between 15% and 75% of the height. The bottom quarter is under captions and UI, and the right edge under the like/share buttons.
- **16:9:** use thirds. Text left with the visual right, or a centred hero.
- **Square / 4:5:** centred, bold, fewer elements.
- One focal point per moment. Use empty space on purpose.

## Colour recipes (bg · fg · accent · support)
| Mood | Palette |
|---|---|
| Bold launch | `#0d0d0d` · `#f4f1ea` · `#ff4d2e` · `#2b2b2b` |
| Clean product | `#f4f1ea` · `#141414` · `#3a5bff` · `#d9d4c7` |
| Money / growth | `#07140e` · `#e9f5ec` · `#2fe07a` · `#123525` |
| Night neon | `#05050a` · `#e8f0ff` · `#00e5ff` · `#ff2bd6` |
| Warm story | `#e9e5da` · `#2e1a1b` · `#d2725a` · `#f6d236` |
| Editorial | `#efe9df` · `#1b1b1b` · `#c1121f` · `#b9ad9b` |
| Calm tech | `#0e1726` · `#dfe8f5` · `#7aa2ff` · `#1e2d45` |
| Candy pop | `#ffe8f0` · `#2a1030` · `#ff3d8b` · `#ffd23f` |
Use the brand colours if the user gives them. Keep one accent, used sparingly.

## Transitions
Cut on the beat (best, and free) · `wipe` in the direction of motion · `iris` from the focal point · `flash` on a hit · a push through an object · a match cut · a whip pan (fast camera x-move with `speedLines`). Use the same transition language throughout the film.

## The end card
The last 1.5–2.5 s: the name or claim, plus at most one line (the CTA or URL), perfectly still after it lands. Use it to echo the hook, visually or in words, so the loop feels intentional.

## QC checklist (read the contact sheet like a director)
1. Would frame 0 stop your thumb?
2. Can you tell what each tile is about in 1 second?
3. Is any text clipped, crowded, too small, or in the UI zones?
4. Is there exactly one focal point per moment?
5. Does the drop look like the biggest moment?
6. Is the last frame clean enough to be the thumbnail?
