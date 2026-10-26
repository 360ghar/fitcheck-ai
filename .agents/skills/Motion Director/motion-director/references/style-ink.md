# Style: Hand-drawn ink

**The look:** a flat 2D illustration with a hand-made finish. Warm paper, filled shapes with clipped hatching (light strokes top-left, cross-hatched shadow bottom-right) and a warm near-black ink outline that "boils" (redraws with a slight wobble) every 2 frames. Characters and objects have personality, and small construction-drawing overlays (dashed rings, ticks, speed lines) add charm. It feels like an indie animated short.

**Defaults:** `bg #e9e5da` (draw `drawPaper(C.paper)` first each frame), ink `#2e1a1b`, 24 fps, `twos: true`, `grain 0.35`, `vignette 0.15`, 96–112 BPM. Night scenes: `#06061e` to `#1e1e42` with cream outlines.
**Fonts:** hand-lettering with `hand()` (preferred, it boils with everything else), or `'Nothing You Could Do'` for handwritten notes, or `'Instrument Serif'` italic for a title card.

## Vocabulary
- **Every shape is `ink()`:** `ink(pts, { id: 'cup', fill: C.terracotta, hatch: hatchSet(cx, cy, r, C.terraHi, C.terraLo), stroke: C.ink, lw: 6*U })`. Build shapes from `rrect`, `ellipse`, `pathD` and `bez`, then `xform` them into place.
- **On twos:** use `CLK.TA` (the animation clock) for poses and character motion so they step every 2 frames. Use `t` for camera and effects (every frame). The boil comes automatically from `bseed` when `FILM.twos` is on.
- **Faces:** `face(x, y, size, mood, {look, talk, id})` gives instant expressions (happy, joy, calm, wired, tired, shocked, angry, smug, sad, wink, dizzy, determined, sleep). Change the mood on story beats. That's where the comedy lives.
- **Rotated objects:** when drawing inside `withT({rot})`, pass `hatchSet(cx, cy, r, hi, lo, {...lightFor(rot)})` so the light stays top-left on screen.
- **Squash and stretch:** scale a character's body `sx = 1 + k, sy = 1 - k` on landings and anticipation.
- **Construction overlays:** `ring()` with ticks around the focal object, `speedLines()` during pushes, `burst()` for surprise, `sparkle()` for magic.
- **Hatched shadows:** `hatchShadow()` under objects, never a solid black ellipse.
- **Push through an eye / window / dot:** `camera` zoom with `eInExpo` into a detail, then cut to the next world.
- **Lettering:** `hand('ONE PERCENT', x, y, 70*U, { u: seg(t, a, b), color: C.ink })` writes itself on.

## Rules
- Three layers per shape: fill, then hatch, then outline. Outlines are 5–8 U, uniform, round caps.
- Light always comes from the top-left. Keep it consistent.
- Palette: warm paper, terracotta `#d2725a`, mustard `#d9a528`, ink `#2e1a1b`, accent yellow `#f6d236`, night navy `#12122a`.
- Character motion on twos; camera and particles on ones. The paper texture never moves.
- Charm over detail: simple silhouettes, big readable poses, one gag or beat per 2 seconds.

## Pattern
```js
const C = { paper: '#e9e5da', ink: '#2e1a1b', terra: '#d2725a', terraHi: '#e8957a', terraLo: '#a8503c', sun: '#f6d236' };
function blob(cx, cy, r, t) {                       // a breathing character body
  const k = 0.04 * Math.sin(CLK.TA * TAU * 1.5);
  const body = xform(rrect(-r, -r * 0.9, 2 * r, 1.8 * r, r * 0.45), cx, cy, 1 + k, 1 - k);
  hatchShadow(cx, cy + r * 0.95, r * 0.9, r * 0.18, C.ink, 0.45, 'blobShadow');
  ink(body, { id: 'blob', fill: C.terra, hatch: hatchSet(cx, cy, r, C.terraHi, C.terraLo), stroke: C.ink, lw: 6 * U });
  const blink = (CLK.TA % 2.4) > 2.3;                // eyes: two dots, a blink every 2.4 s
  [-0.35, 0.35].forEach((dx) => blink ? strokePts([[cx + dx * r - 10 * U, cy - 0.15 * r], [cx + dx * r + 10 * U, cy - 0.15 * r]], C.ink, 5 * U) : circle(cx + dx * r, cy - 0.15 * r, 9 * U, C.ink));
}
function frame(t) { drawPaper(C.paper); blob(CX, CY, 170 * U, t); }
```

## Pitfalls
- Perfect geometry kills the style: always go through `ink()` (boil) or `wob()`.
- Hatching too dense or too dark: keep light hatch alpha around .5 and dark around .4.
- Moving on ones everywhere loses the hand-made cadence. Use `CLK.TA` for characters.
- Rendering is heavier (hatching). Keep shape counts reasonable (under about 40 inked shapes per frame).
