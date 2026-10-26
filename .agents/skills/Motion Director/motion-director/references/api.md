# Motion Director engine reference

This page is complete: **don't read the engine source** (`engine/*.js`), because everything you need is here. If something truly isn't covered, write it yourself with plain Canvas 2D in your film.

A project is a folder:
```
film.html            preview in Chrome (scrub/play; no sound in preview)
engine/              motion.js, audio.js, fonts/  (copied from the skill; don't edit)
film/config.js       window.FILM_CONFIG = { w, h, fps, seconds, bpm, bg, grain, vignette, twos, font, ... }
film/scenes.js       function frame(t) { ... }   (+ optional async function setup() { ... }, const QC_AT = [...])
film/score.js        function score(A) { ... }
assets/              optional user files (logo.png ...)
qc/                  QC output: sheet.png (evenly spaced moments + up to 8 QC_AT key moments, ≤ 16 tiles), tNNN.NNs.png (e.g. t004.20s.png), audio.wav; qc/at/ for --at checks
```
Scripts are plain globals (no imports) that share one scope with the engine. `frame(t)` is called once per frame with `t` in seconds. The canvas is already cleared to `FILM.bg`. Draw with the global `ctx` (CanvasRenderingContext2D) and the helpers below. Grain and vignette are added after `frame` if set in config.

**Reserved names.** Don't declare any of these yourself; a clash is a `SyntaxError: Identifier 'x' has already been declared` and the film won't start. Give your own helpers distinctive names (e.g. `drawMug`, `sceneHook`) or put them inside one object (`const F = { ... }`):
`W H U CX CY FPS FRAMES DUR TAU BEAT BAR SAFE FILM CLK PORTRAIT LANDSCAPE SQUARE ctx canvas TEX IMG ICONS GLYPHS SR` and every function listed on this page, plus these internals: `hashInts hashStr seedOf mulberry32 vnoise side hatchIn wob glyphPolys charLayout tabularText tabularW fontStr realWeight setCtx setClock scratch makeCanvas paperTex buildGrain post boot loadFonts renderFrame renderAudio audioWav lufs kWeight limit truePeakAbs wavFloat32 midi mtof chord CHORD_IV NOTE_IX OS_TAPS FONT_FILES FONT_WEIGHTS _col _glyphCache _iconPaths _scratch`. Common traps: `line`, `ring`, `rect`, `circle`, `text`, `words`, `wrap`, `chord`, `limit`, `pick`, `side`, `bars`, `beats`, `keys`, `seg`, `face`, `image`, `icon`, `flash`, `wipe`, `layer`.

## Globals
- **Canvas:** `W, H` (canvas px), `CX, CY` (centre), and `U`, the design unit: 1 U = 1 px when the short side is 1080. Size everything in U.
- **Time:** `FPS, FRAMES, DUR`, plus `BEAT, BAR` in seconds at `FILM.bpm`.
- **Format:** `PORTRAIT, LANDSCAPE, SQUARE`.
- **`SAFE {x0,y0,x1,y1,w,h,cx,cy,wc}`**, the title-safe box:
  - vertical: x 8–86%, y 13–78% (asymmetric, to avoid the app UI);
  - square, landscape and 4:5: x 6–94%, y 8–90%.

  For centred layouts, centre on `CX` and use `SAFE.wc` (the widest box centred on CX that stays safe) as the max width.
- **Default layout per format** (use it instead of planning positions by hand; adjust after the QC sheet):
  - **vertical:** stack top to bottom. Headline block at `SAFE.y0 + SAFE.h*0.12`, hero/character centred at `SAFE.y0 + SAFE.h*0.55` (height ≤ `SAFE.h*0.5`), tagline/CTA at `SAFE.y1 - SAFE.h*0.06`. Below `SAFE.y1` is only background (app UI covers it).
  - **square / 4:5:** the same stack, compressed. Headline at `SAFE.y0 + SAFE.h*0.12`, hero at `CY + SAFE.h*0.08` (height ≤ `SAFE.h*0.5`), tagline at `SAFE.y1 - SAFE.h*0.05`.
  - **landscape:** side by side. Hero centred at `SAFE.x0 + SAFE.w*0.3`, words left-aligned from `SAFE.x0 + SAFE.w*0.58` with `maxW = SAFE.x1 - that x`. Or one big centred line for slams.
- **`FILM`:** the config object.
- **`CLK {F, T, TA, BOIL}`:** the frame number, the time, the animation time (stepped every 2 frames when `FILM.twos` is on), and the drawing index. Also `TAU`.

## Time and easing
| | |
|---|---|
| `seg(t, t0, t1)` | 0..1 progress through [t0, t1], clamped |
| `inout(t, a, b, rin=.3, rout=.3, ease=eOut)` | 0 → 1 (by a+rin), hold, → 0 (at b). "On screen from a to b" |
| `pulse(t, t0, dur=.3)` | 1 at t0, decaying to ~0 after dur. Beat hits: scale bumps, flashes, shakes |
| `keys(t, [[t0,v0],[t1,v1,easeFn?],...], ease=eInOut)` | keyframes. The optional 3rd item of a key is the easing *into* that key. Values may be arrays (`[x,y]`) |
| `beats(n)`, `bars(n)` | beats/bars → seconds. `beatPhase(t, per=1)` 0..1 within the current beat |
| `spring(t, f=2.2, z=.32)` | 0 → 1 with natural overshoot (0 for t ≤ 0, so no guard needed). `t` = seconds since the start; `f` = wobbles per second (higher is snappier); `z` = damping 0..1 (lower = more overshoot; .3 lively, .6 barely overshoots) |
| `clamp(x, a=0, b=1)`, `lerp`, `smooth`, `sstep(a,b,x)` | |
| easings | the full standard family: `e{In,Out,InOut}{Sine,Quad,Cubic,Quart,Quint,Expo,Circ,Back,Elastic}` (e.g. `eOutQuint`, `eInOutBack`; the Back ones take `(t, s)`), plus the short `eIn eOut eInOut` (= Cubic) and `eInOutQ` (= Quart) |

Beat times rarely land exactly on frames (at 96 BPM and 30 fps a beat is 9.375 frames). That's fine: always compute from seconds.

## Randomness (deterministic)
`rng('id', i)` → function returning floats in [0,1) · `h01('id', i)` one float · `snoise(x, seed)` smooth noise in [-1,1] · `vnoise2(x,y,seed)` in [0,1] · `pick(arr, 'id', i)` · `particles('id', n, (i, r) => ...)` calls back once per particle with a stable `r()`.

## Colour
`rgba(hex, a)` · `mixHex(h1, h2, t)` · `shade(hex, amt)` (+ lightens, − darkens) · `linGrad(x0,y0,x1,y1,[[0,c],[1,c]])` · `radGrad(x,y,r0,r1,stops)` (gradients return a fillStyle).

## Transform, camera, composition
| | |
|---|---|
| `withT({x, y, rot, scale, sx, sy, alpha, blend}, fn)` | save → translate → rotate → scale → fn → restore. Inside `fn`, coordinates are relative to `(x, y)`: draw the thing at `0, 0`. `alpha` multiplies the current alpha |
| `camera({x, y, zoom, rot, shake, shakeFreq, seed}, fn)` | the world point (x,y) lands at screen centre. `shake` in px (use `12*U*pulse(t, hit)`) |
| `camFit({x, y, w, h}, u, from={x:CX,y:CY,zoom:1}, mode='fill'\|'fit', ease)` | returns camera params that go from `from` to filling the frame with that rect (top-left + size). **Push-through transitions:** `camera(camFit(rect, seg(t, a, b)), draw)` |
| `masked(maskFn, contentFn)` | content only where the mask paints (text-shaped reveals, shape wipes) |
| `layer(fn, {filter:'blur(12px)', blend, alpha})` | draw into an offscreen layer, composite with a CSS filter |
| `bloom(fn, radius=18U, strength=.9)` | sharp + blurred additive copy (neon glow); radius scales with zoom |
| `motionBlur(drawAt, t, n=12, shutter=.6)` | `drawAt(tt)` draws the **whole frame** at time tt; n sub-frames are averaged. Only for the fastest 0.2–0.5 s (whip pans, punches): it costs n frames |
| `curScale()` | the current zoom factor |

`masked`, `layer` and `bloom` respect the current camera/withT transform and alpha. Each costs a full-frame composite, so use them for focal elements.

## Shapes
- **Draw directly:**
  - `rect(x,y,w,h,col)` · `circle(x,y,r,col,alpha)` · `roundRect(x,y,w,h,r,fill,stroke,lw)`
  - `line(x0,y0,x1,y1,col,lw,u=1)` and `arrow(x0,y0,x1,y1,col,lw,u=1,head)` — `u` draws them on. All engine strokes use round caps and joins
  - `ringStroke(x,y,r,col,lw,u=1,a0=-π/2)` — an arc that draws on
- **Point lists (arrays of `[x,y]`):**
  - `rrect(x,y,w,h,r)` · `ellipse(cx,cy,rx,ry,n=64,rot)` · `circlePts(cx,cy,r,n=64)` · `regular(cx,cy,r,n,rot)` · `starPts(cx,cy,r1,r2,n)`
  - `bez(p0,p1,p2,p3,n)` · `qbez(p0,p1,p2,n)` · `pathD('M x y L x y Q cx cy x y C ... Z')` → an array of polylines
  - `xform(pts,ox,oy,sx,sy=sx,rot=0)` (scale about the origin, rotate, then move to ox,oy) · `resample(pts,closed,step)` (points every `step` px) · `resampleN(pts,n,closed=false)` (exactly `n` points) · `partial(pts,u)` · `bbox(pts)` → [x0,y0,x1,y1] · `polyLen(pts,closed)`
- **Draw point lists:** `fillPts(pts,col,alpha)` · `strokePts(pts,col,lw,closed,alpha)` · `drawOn(pts,u,col,lw,closed)` · `tracePath(pts,closed)` (path only, then use ctx).
- **Morph:** `morph(shapeA, shapeB, u, n=120, closed=true)` → the in-between point list (both resampled to `n` points, then blended). Start both shapes at a similar point (e.g. the top) or the morph twists.

## Hand-drawn ink (ink style)
- **`ink(pts, {id, fill, hatch, stroke, lw=6U, boil=1.2U, wl=70U, closed=true, alpha, fx, seed})`:** fill → hatching → clipped `fx(pts)` → wobbly outline. Returns the wobbled points. With `FILM.twos` the outline "boils" every 2 frames. Give every shape a unique `id` (the boil seed comes from it; `seed` overrides it). `boil: 0` gives a clean outline; `wl` is the wobble wavelength.
  - **Custom hatch:** `hatch` is a list of `{id, color, alpha=.5, ang (degrees), gap, len: [min, max], lw, dens 0..1, where?(x, y) → 0..1}`, all lengths in px (multiply by `U`). `hatchSet` builds a good default list.
- **`hatchSet(cx, cy, r, lightHex, darkHex, {lx, ly, la, da, scale})`:** the hatch list for `ink`. Light top-left strokes plus a cross-hatched shadow; `lx, ly` set the light direction. For an object drawn rotated by `rot` inside `withT`, pass `...lightFor(rot)` (returns `{lx, ly}`) so the light stays top-left on screen.
- **`hatchShadow(cx, cy, rx, ry, col, alpha=.5, id)`:** a hatched ground shadow; use a unique `id` per shadow.
- **`face(x, y, size, mood, {color, lw, blush, look:[dx,dy], talk:0..1, id})`:** an expressive cartoon face: eyes, brows, mouth and blush only, with no head outline (draw the head yourself with `ink`). Size ≈ face width. The eyes sit at `(x ± 0.36·size, y − 0.08·size)` with radius `0.075·size` (use this for tears, glasses and sweat drops); the mouth is centred below `y`.
  - moods: `happy joy calm wired tired shocked angry smug sad wink dizzy determined sleep`
  - `look` moves the pupils (−1..1) and `talk` opens the mouth.
- **`hand(str, x, y, capH, {color, lw, alpha, align, u, id, boil, track=1.1})`:** hand-lettered stroke font; `y` is the baseline. Covers A–Z (lowercase is drawn as capitals), 0–9 and `. , ! ? : - + = * / ' " # $ % & ( )`. `u` draws it on stroke by stroke. Returns the width.
- **`handW(str, capH, track=1.1)`:** measures hand lettering without drawing. To fit a width: `capH * maxW / handW(str, capH)`.
- **Also:** `drawPaper(baseHex)` fills the frame with mottled paper · `wob(pts, closed, seed, amp, wl=70)` (wobble a point list; `wl` = wavelength in px) · `bseed('id')`.

## Real-font typography
Bundled fonts (`font:` option; available weights). The engine uses the nearest real weight, so it never fakes a bold:
`'Bricolage Grotesque'` (400, 700) · `'Instrument Serif'` (400, italic 400) · `'Instrument Sans'` (400, 700) · `'Outfit'` (400, 700) · `'Big Shoulders'` (400, 700; condensed display) · `'Boldonse'` (400; ultra-heavy display with giant caps: cap height ≈ 1.2× `size`, about 1.7× other faces, so size it by height with `capH`, not by width alone) · `'Gloock'` (400; display serif) · `'Geist Mono'` (400, 700) · `'Tektur'` (500; techno) · `'Nothing You Could Do'` (400; handwriting). Default weight 700, default font `FILM.font`.

Symbols (verified against the font files):
- **In every font:** `$ % & @ # * + = ! ? ( ) ' " , . : ; -`, plus `¢ € £ © ® ™ ° • … – —` and curly quotes.
- **In no font** (only ✓, and only in Outfit): `★ ♥ ✓`.
- **Missing in some fonts:** arrows `→ ← ↑ ↓` are missing in Boldonse, Instrument Serif and Nothing You Could Do; `≈ ≥ ≤` are missing in Instrument Sans/Serif, Outfit and Nothing You Could Do.
- **Emoji:** never.

Draw checks, stars, hearts and arrows with `icon()` / `arrow()` instead.

| | |
|---|---|
| `text(str, x, y, size, o)` | one line. `o`: `font, weight, italic, color, align('left'\|'center'\|'right'), base('alphabetic'\|'middle'\|'top'), tracking` (em, e.g. −0.03), `alpha, maxW` (auto-shrink to fit), `stroke, lw, glow:{color, r}, shadow:{color, blur, y}, tabular` (fixed-width digits so counters don't jitter; works with `maxW`. Best in Geist Mono, Bricolage or Outfit. Never tabular in Boldonse: "412" becomes "4 1 2". For a Boldonse number that doesn't tick, leave `tabular` off). Outline-only: `{color: null, stroke: '#fff', lw: 3*U}`. Returns `{x, w, size}` |
| `metrics(str, size, o)` | `{w, asc, desc, capH, fontAsc, fontDesc}`: the measured ink box of the string above/below the baseline. Use it to size backing pills and masks exactly |
| `capH(size, o)` | cap height. Optical centring: `text(s, x, cy + capH(size, o)/2, size, o)` |
| `textW(str, size, o)`, `fitSize(str, size, maxW, o)`, `wrap(str, size, maxW, o)` → lines | measuring (all honour `tracking` and `tabular`) |
| `words(str, x, y, size, o)` | per-word layout `[{word, i, line, x, y, w}]` (x = left edge, y = baseline), honouring `maxW` wrapping, `lh` (line height × size, default 1.08), `align`, `valign:'middle'`. Animate each word yourself |
| `reveal(str, x, y, size, u, o)` | one-call kinetic text. `u` 0..1. `by: 'word'\|'char'`; `mode: 'rise'\|'fade'\|'scale'\|'slam'\|'mask'\|'blur'\|'type'`; `stagger` (0..1, default .6); `ease`; `colors: [...]` (per item) or `colorOf(label, i)`; `wrap: true` + `maxW` for multi-line; plus any `text()` option |
| `counter(a, b, u, fmt)`, `fmtNum(v, dp=0)` (adds thousands separators: 1,745) | animated numbers: `text(counter(0, 12400, u, v => '$' + fmtNum(v)), ..., {tabular: true})` |

## Icons, charts, images, waveform
- **`icon(name, x, y, size, {color, lw, fill, alpha, u})`:** a stroked icon centred at (x,y); `u` draws it on. Names: `check x plus arrowRight arrowUp arrowDown play pause heart star bolt lock user chat bell chart clock globe search code cursor spark trendUp dollar mail eye`.
- **Charts:**
  - `barsChart(x, y, w, h, values, u, {color, colors, gap, r, max})` — (x,y) is the top-left of the chart box
  - `lineChart(x, y, w, h, values, u, {color, lw, fill, dot, max, min})` — returns the data points
  - `donut(x, y, r, frac, u, {color, track, lw})`
- **`waveform(x, y, w, h, t, {bars, color, energy, gap, id})`:** animated equaliser bars centred on y (music, voice, podcasts). `energy` can be a function of t.
- **Images:** in `async function setup() { await loadImg('logo', 'assets/logo.png'); }`, then `image('logo', x, y, width, {alpha, rot, h})`, centred at (x,y).

## Effects
- **Light:** `glow(x,y,r,col,a=1,mode='lighter')` · `sparkle(x,y,r,col,a,rot)` (4-point star) · `wash(x0,y0,x1,y1,col,a0,a1,mode)` (gradient over everything, e.g. a light sweep with mode `'lighter'`).
- **Lines and overlays:**
  - `ring(x,y,r,{color,alpha=.5,lw,dash,dashOff,ticks=8,tickLen,rot,a0,a1})` — a dashed construction ring with ticks
  - `speedLines(cx,cy,r0,r1,n,'id',col,a,lw)` · `burst(x,y,r0,r1,n,rot,col,lw,a)`
  - `streaks(x0,y0,w,h,{count,len,ang,speed,color,alpha,lw,id})` — rain or data streaks
- **Transitions:** `flash(a, col, mode='source-over')` (full frame; `'lighter'` for a glow flash), `wipe(u, 'left'|'right'|'up'|'down', col)`, `iris(u, x, y, col)` (circle cover).

## Structure and practices
```js
'use strict';
const C = { bg: '#0d0d0d', fg: '#f4f1ea', acc: '#ff4d2e' };        // palette in one place
const S = { hook: 0, set: bars(1), drop: bars(4), end: bars(7) };   // scene times on the beat grid (shared with score.js)
const QC_AT = [S.set, S.drop, S.drop + 0.3, S.end + 1];             // key moments the QC sheet must include

function sceneHook(lt) { /* lt = local time */ }
function frame(t) {
  camera({ shake: 12 * U * pulse(t, S.drop, 0.25) }, () => {
    if (t < S.set) sceneHook(t);
    else if (t < S.drop) sceneSet(t - S.set);
    else if (t < S.end) sceneDrop(t - S.drop);
    else sceneEnd(t - S.end);
  });
  flash(pulse(t, S.drop, 0.18) * 0.7, C.fg);
}
```
- **Local time:** pass it into each scene (`t - start`). For transitions, draw both scenes over the overlap, with the outgoing one masked, faded or pushed through.
- **Frame 0 is the thumbnail:** start the hook's animation slightly before 0 (`seg(t, -0.15, 0.25)`) so frame 0 already reads.
- **One source of timing:** keep all sync times in `S` (and arrays like `const HITS = [...]`) in scenes.js. score.js can read them directly, because it's the same global scope.
- **Performance:** 450 frames per 15 s. No per-pixel loops in `frame`; precompute heavy geometry at the top level or in `setup()`.
