# Style: Neon / cinematic

**The look:** deep near-black space, light as the subject. Glowing lines and type, particles, lens flares, dramatic camera pushes and one colossal reveal. The feel is a movie-trailer title card crossed with synthwave, restrained and expensive rather than cheesy.

**Defaults:** `bg #05050a`, glow colours `#00e5ff` + `#ff2bd6` (or a single colour), white-hot cores, `grain 0.1`, `vignette 0.45`, 30 fps, 90–128 BPM.
**Fonts:** Tektur 500 (techno), Big Shoulders 700 (trailer), Gloock (elegant cinematic serif), Geist Mono for small data labels.

## Vocabulary
- **Light draws the shape:** `drawOn()` a path with a hot core (white, thin) inside a coloured stroke, wrapped in `bloom()`. A `sparkle` rides the drawing tip.
- **Glow type:** `text(..., {color: '#fff', glow: {color: C.cyan, r: 40*U}})`, or build it with `bloom(() => text(...))` for a stronger halo.
- **Particles:** `particles('dust', 160, (i, r) => ...)` drift slowly with `snoise`. On the drop they burst outward from the focal point (radius grows with `eOutExpo`, alpha fades).
- **Camera push:** a slow `camera` zoom 1 → 1.15 across the build (tension), then a fast punch (1.15 → 2.5, `eInExpo`, 0.4 s) into the reveal, then a cut. `camFit` targets an exact rect; `motionBlur` sells the punch. `bloom` works inside the camera. Draw headlines and labels *outside* the `camera()` call (screen space) so a push never crops them, especially in square and vertical formats.
- **Light sweep:** a diagonal `linGrad` band (white at 35%, `blend:'lighter'`) slides across the title once it has landed.
- **Scanline / data:** thin `line()`s, small Geist Mono numbers ticking, `ring()`s with ticks around the subject (a HUD feel).
- **Flash cut:** `flash(pulse(...))` in the glow colour on each hit, 1–2 frames long.

## Rules
- Darkness is the canvas: keep 70–85% of the frame near-black. Light only where the eye should go.
- One or two hues plus white. Additive (`'lighter'`) blending makes overlapping light glow naturally.
- Contrast in time: slow, quiet build, then a violent release. Silence right before the hit.
- Big reveal = title + `A.boom` + `flash` + particle burst + a small shake, all on the same frame.
- Keep glows soft and large: bloom radius 14–30 U, not hard-edged.

## Pattern
```js
const C = { bg: '#05050a', cyan: '#00e5ff', pink: '#ff2bd6', hot: '#ffffff' };
function neonLine(pts, u, col) {
  bloom(() => { drawOn(pts, u, col, 6 * U); drawOn(pts, u, C.hot, 2 * U); }, 20 * U, 1);
  if (u > 0 && u < 1) { const p = partial(pts, u).pop(); glow(p[0], p[1], 60 * U, col, 0.9); sparkle(p[0], p[1], 22 * U, C.hot, 1, CLK.T * 3); }
}
function dust(t, burstAt) {
  particles('dust', 140, (i, r) => {
    const x0 = r() * W, y0 = r() * H, sp = 0.3 + r();
    const b = eOutExpo(seg(t, burstAt, burstAt + 1.2)), ang = Math.atan2(y0 - CY, x0 - CX);
    const x = x0 + snoise(t * 0.2 * sp, i) * 40 * U + Math.cos(ang) * b * 500 * U;
    const y = y0 + snoise(t * 0.2 * sp, i + 99) * 40 * U + Math.sin(ang) * b * 500 * U;
    circle(x, y, (1 + r() * 2.5) * U, i % 3 ? C.cyan : C.pink, (0.25 + r() * 0.5) * (1 - b * 0.7));
  });
}
```

## Pitfalls
- Glow everywhere makes mush. Glow is for the focal element only.
- Saturated-on-saturated text is unreadable. Type is white with a coloured halo.
- Constant maximum energy. Build first, release once.
