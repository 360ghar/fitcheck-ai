'use strict';
// ============================================================================
// motion.js — deterministic 2D motion toolkit for canvas films.
//
// A film is three small files in film/: config.js (FILM_CONFIG), scenes.js
// (defines `frame(t)` and optionally `setup()`), score.js (defines `score(A)`).
// This file gives them everything else: clocks, easing, colour, camera, shapes,
// hand-drawn ink, real-font kinetic type, effects, icons, charts, textures.
//
// Determinism rule: never call Math.random, Date.now or performance.now.
// Every random value comes from rng()/h01() seeded by stable ids, so rendering
// frame n twice gives the same pixels.
// ============================================================================

// ---------------------------------------------------------------- config
const FILM = Object.assign({
  w: 1080, h: 1920, fps: 30, seconds: 15,
  bg: '#0c0c10',          // cleared every frame
  twos: false,            // true: poses/boil update every 2 frames (hand-drawn look)
  grain: 0,               // 0..1 film grain overlay strength
  vignette: 0,            // 0..1
  bpm: 120,               // shared by scenes (beat sync) and score
  font: 'Bricolage Grotesque',
}, window.FILM_CONFIG || {});
const W = FILM.w, H = FILM.h, FPS = FILM.fps;
const FRAMES = Math.round(FILM.seconds * FPS), DUR = FRAMES / FPS;
const TAU = Math.PI * 2;
const U = Math.min(W, H) / 1080;              // design unit: 1 U = 1 px on a 1080-short-side canvas
const PORTRAIT = H > W, LANDSCAPE = W > H, SQUARE = W === H;
const CX = W / 2, CY = H / 2;
const BEAT = 60 / FILM.bpm, BAR = BEAT * 4;
// Title-safe area. Vertical video loses the top ~12% and bottom ~20% to app UI.
const SAFE = PORTRAIT
  ? { x0: W * 0.08, y0: H * 0.13, x1: W * 0.86, y1: H * 0.78 }
  : { x0: W * 0.06, y0: H * 0.08, x1: W * 0.94, y1: H * 0.9 };
SAFE.w = SAFE.x1 - SAFE.x0; SAFE.h = SAFE.y1 - SAFE.y0; SAFE.cx = (SAFE.x0 + SAFE.x1) / 2; SAFE.cy = (SAFE.y0 + SAFE.y1) / 2;
// For centred layouts: the widest box centred on CX that stays inside SAFE (vertical SAFE is asymmetric).
SAFE.wc = 2 * Math.min(CX - SAFE.x0, SAFE.x1 - CX);

// ---------------------------------------------------------------- hash / PRNG / noise
function hashInts(...xs) {
  let h = 0x811c9dc5 | 0;
  for (let x of xs) {
    x = Math.floor(x) | 0;
    h = Math.imul(h ^ (x & 0xff), 16777619);
    h = Math.imul(h ^ ((x >>> 8) & 0xff), 16777619);
    h = Math.imul(h ^ ((x >>> 16) & 0xff), 16777619);
    h = Math.imul(h ^ (x >>> 24), 16777619);
  }
  h ^= h >>> 13; h = Math.imul(h, 0x5bd1e995); h ^= h >>> 15;
  return h >>> 0;
}
function hashStr(s) { let h = 7; for (let i = 0; i < s.length; i++) h = hashInts(h, s.charCodeAt(i)); return h; }
function seedOf(id) { return typeof id === 'string' ? hashStr(id) : (id | 0); }
function mulberry32(a) {
  return function () {
    a |= 0; a = a + 0x6D2B79F5 | 0;
    let t = Math.imul(a ^ a >>> 15, 1 | a);
    t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
    return ((t ^ t >>> 14) >>> 0) / 4294967296;
  };
}
/** rng('id', 3) -> a function returning deterministic floats in [0,1). */
function rng(...xs) { return mulberry32(hashInts(...xs.map(seedOf))); }
/** h01('id', i) -> one deterministic float in [0,1). */
function h01(...xs) { return hashInts(...xs.map(seedOf)) / 4294967296; }
function vnoise(x, seed = 0) { const i = Math.floor(x), f = x - i, a = h01(i, seed), b = h01(i + 1, seed), u = f * f * (3 - 2 * f); return a + (b - a) * u; }
/** smooth 1D noise in [-1,1] */
function snoise(x, seed = 0) { return vnoise(x, seed) * 2 - 1; }
function vnoise2(x, y, seed = 0) {
  const ix = Math.floor(x), iy = Math.floor(y), fx = x - ix, fy = y - iy;
  const ux = fx * fx * (3 - 2 * fx), uy = fy * fy * (3 - 2 * fy);
  const a = h01(ix, iy, seed), b = h01(ix + 1, iy, seed), c = h01(ix, iy + 1, seed), d = h01(ix + 1, iy + 1, seed);
  return (a + (b - a) * ux) + ((c + (d - c) * ux) - (a + (b - a) * ux)) * uy;
}

// ---------------------------------------------------------------- math / easing / timing
const clamp = (x, a = 0, b = 1) => x < a ? a : x > b ? b : x;
const lerp = (a, b, t) => a + (b - a) * t;
/** 0..1 progress of t through [t0, t1] */
const seg = (t, t0, t1) => clamp((t - t0) / (t1 - t0));
const smooth = (t) => t * t * (3 - 2 * t);
const sstep = (a, b, x) => smooth(clamp((x - a) / (b - a)));
const eIn = (t) => t * t * t;
const eOut = (t) => 1 - Math.pow(1 - t, 3);
const eInOut = (t) => t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
const eInOutQ = (t) => t < 0.5 ? 8 * t * t * t * t : 1 - Math.pow(-2 * t + 2, 4) / 2;
const eOutQuint = (t) => 1 - Math.pow(1 - t, 5);
const eOutExpo = (t) => t >= 1 ? 1 : 1 - Math.pow(2, -10 * t);
const eInExpo = (t) => t <= 0 ? 0 : Math.pow(2, 10 * t - 10);
const eInOutExpo = (t) => t <= 0 ? 0 : t >= 1 ? 1 : t < 0.5 ? Math.pow(2, 20 * t - 10) / 2 : (2 - Math.pow(2, -20 * t + 10)) / 2;
const eInOutSine = (t) => -(Math.cos(Math.PI * t) - 1) / 2;
const eOutBack = (t, s = 1.70158) => 1 + (s + 1) * Math.pow(t - 1, 3) + s * Math.pow(t - 1, 2);
const eOutElastic = (t) => t === 0 ? 0 : t === 1 ? 1 : Math.pow(2, -9 * t) * Math.sin((t * 10 - 0.75) * (TAU / 3)) + 1;
// the full standard family, so any conventional name works: e{In,Out,InOut}{Sine,Quad,Cubic,Quart,Quint,Expo,Circ,Back,Elastic}
const eInSine = (t) => 1 - Math.cos(t * Math.PI / 2), eOutSine = (t) => Math.sin(t * Math.PI / 2);
const eInQuad = (t) => t * t, eOutQuad = (t) => 1 - (1 - t) * (1 - t), eInOutQuad = (t) => t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
const eInCubic = eIn, eOutCubic = eOut, eInOutCubic = eInOut;
const eInQuart = (t) => t * t * t * t, eOutQuart = (t) => 1 - Math.pow(1 - t, 4), eInOutQuart = eInOutQ;
const eInQuint = (t) => t * t * t * t * t, eInOutQuint = (t) => t < 0.5 ? 16 * Math.pow(t, 5) : 1 - Math.pow(-2 * t + 2, 5) / 2;
const eInCirc = (t) => 1 - Math.sqrt(1 - Math.pow(clamp(t), 2)), eOutCirc = (t) => Math.sqrt(1 - Math.pow(clamp(t) - 1, 2));
const eInOutCirc = (t) => t < 0.5 ? (1 - Math.sqrt(1 - Math.pow(2 * t, 2))) / 2 : (Math.sqrt(1 - Math.pow(-2 * t + 2, 2)) + 1) / 2;
const eInBack = (t, s = 1.70158) => (s + 1) * t * t * t - s * t * t;
const eInOutBack = (t, s = 1.70158 * 1.525) => t < 0.5 ? (Math.pow(2 * t, 2) * ((s + 1) * 2 * t - s)) / 2 : (Math.pow(2 * t - 2, 2) * ((s + 1) * (t * 2 - 2) + s) + 2) / 2;
const eInElastic = (t) => t === 0 ? 0 : t === 1 ? 1 : -Math.pow(2, 10 * t - 10) * Math.sin((t * 10 - 10.75) * (TAU / 3));
const eInOutElastic = (t) => t === 0 ? 0 : t === 1 ? 1 : t < 0.5 ? -(Math.pow(2, 20 * t - 10) * Math.sin((20 * t - 11.125) * (TAU / 4.5))) / 2 : (Math.pow(2, -20 * t + 10) * Math.sin((20 * t - 11.125) * (TAU / 4.5))) / 2 + 1;
/** damped spring 0 -> 1 with overshoot. f = oscillations/sec, z = damping */
function spring(t, f = 2.2, z = 0.32) { if (t <= 0) return 0; const w = TAU * f; return 1 - Math.exp(-z * w * t) * Math.cos(w * Math.sqrt(1 - z * z) * t); }
/** keyframes: keys(t, [[t0, v0], [t1, v1, easeFn?], ...]) — values may be numbers or arrays */
function keys(t, ks, ease = eInOut) {
  if (t <= ks[0][0]) return ks[0][1];
  for (let i = 0; i < ks.length - 1; i++) {
    const [t0, v0] = ks[i], [t1, v1, e] = ks[i + 1];
    if (t <= t1) {
      const u = (e || ease)(seg(t, t0, t1));
      return Array.isArray(v0) ? v0.map((v, j) => lerp(v, v1[j], u)) : lerp(v0, v1, u);
    }
  }
  return ks[ks.length - 1][1];
}
/** in-hold-out envelope: 0 before a, ramps to 1 over rin, holds, ramps to 0 ending at b */
function inout(t, a, b, rin = 0.3, rout = 0.3, ease = eOut) { return Math.min(ease(seg(t, a, a + rin)), 1 - eIn(seg(t, b - rout, b))); }
/** decaying pulse starting at t0 (for beat hits): 1 at t0, ~0 after dur */
function pulse(t, t0, dur = 0.3) { if (t < t0) return 0; return Math.exp(-5 * (t - t0) / dur); }
/** beat helpers (shared tempo with the score) */
const beats = (n) => n * BEAT;
const bars = (n) => n * BAR;
function beatPhase(t, per = 1) { return ((t / (BEAT * per)) % 1 + 1) % 1; }

// ---------------------------------------------------------------- colour
const _col = {};
function rgb(hex) {
  if (_col[hex]) return _col[hex];
  let h = hex.replace('#', ''); if (h.length === 3) h = h.split('').map((c) => c + c).join('');
  return (_col[hex] = [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16)]);
}
function rgba(hex, a) { const c = rgb(hex); return `rgba(${c[0]},${c[1]},${c[2]},${a})`; }
function mixHex(h1, h2, t) { const a = rgb(h1), b = rgb(h2); return '#' + a.map((v, i) => Math.round(lerp(v, b[i], clamp(t))).toString(16).padStart(2, '0')).join(''); }
/** amt > 0 lightens toward white, < 0 darkens toward black */
function shade(hex, amt) { return amt >= 0 ? mixHex(hex, '#ffffff', amt) : mixHex(hex, '#000000', -amt); }
function linGrad(x0, y0, x1, y1, stops) { const g = ctx.createLinearGradient(x0, y0, x1, y1); stops.forEach(([o, c]) => g.addColorStop(o, c)); return g; }
function radGrad(x, y, r0, r1, stops) { const g = ctx.createRadialGradient(x, y, r0, x, y, r1); stops.forEach(([o, c]) => g.addColorStop(o, c)); return g; }

// ---------------------------------------------------------------- canvas + clocks
let ctx = null, canvas = null;
function setCtx(c) { ctx = c; ctx.lineJoin = 'round'; ctx.lineCap = 'round'; }
// F: frame, T: seconds (ones), TA: animation clock (twos if FILM.twos), BOIL: drawing index
const CLK = { F: 0, T: 0, TA: 0, BOIL: 0 };
function setClock(n) {
  CLK.F = n; CLK.T = n / FPS;
  CLK.BOIL = FILM.twos ? Math.floor(n / 2) : n;
  CLK.TA = FILM.twos ? (CLK.BOIL * 2) / FPS : CLK.T;
}
/** run fn inside save/restore with an optional transform: {x, y, rot, scale, sx, sy, alpha, blend} */
function withT(o, fn) {
  ctx.save();
  if (o.x != null || o.y != null) ctx.translate(o.x || 0, o.y || 0);
  if (o.rot) ctx.rotate(o.rot);
  if (o.scale != null || o.sx != null) ctx.scale(o.sx ?? o.scale, o.sy ?? o.scale);
  if (o.alpha != null) ctx.globalAlpha *= clamp(o.alpha);
  if (o.blend) ctx.globalCompositeOperation = o.blend;
  fn();
  ctx.restore();
}
/** camera: world point (x, y) lands at screen centre, zoomed and rotated. shake in px. */
function camera(o, fn) {
  const z = o.zoom ?? 1, sh = o.shake || 0, sd = seedOf(o.seed || 'cam'), f = o.shakeFreq ?? 9;
  const sx = sh ? snoise(CLK.T * f, sd) * sh : 0, sy = sh ? snoise(CLK.T * f, sd + 99) * sh : 0;
  ctx.save();
  ctx.translate(CX + sx, CY + sy); if (o.rot) ctx.rotate(o.rot); ctx.scale(z, z);
  ctx.translate(-(o.x ?? CX), -(o.y ?? CY));
  fn();
  ctx.restore();
}
/** camFit: camera params that move from `from` ({x, y, zoom}) to filling the frame with rect {x, y, w, h}
 *  (top-left + size, world coords) as u goes 0..1. For "push through the object" transitions:
 *  camera(camFit({ x: bx, y: by, w: bw, h: bh }, u), () => drawScene()). mode 'fill' (cover) or 'fit' (contain). */
function camFit(r, u, from = { x: CX, y: CY, zoom: 1 }, mode = 'fill', ease = eInOutExpo) {
  const zt = mode === 'fit' ? Math.min(W / r.w, H / r.h) : Math.max(W / r.w, H / r.h), e = ease(clamp(u));
  const zoom = Math.exp(lerp(Math.log(from.zoom), Math.log(zt), e));
  const k = Math.abs(zt - from.zoom) < 1e-6 ? e : (zoom - from.zoom) / (zt - from.zoom);
  return { x: lerp(from.x, r.x + r.w / 2, k), y: lerp(from.y, r.y + r.h / 2, k), zoom };
}
/** light direction for hatchSet when an object is drawn rotated by `rot` (keeps light coming from the top-left of the screen) */
function lightFor(rot) { const c = Math.cos(-rot), s = Math.sin(-rot), lx = -0.55, ly = -0.85; return { lx: lx * c - ly * s, ly: lx * s + ly * c }; }
const _scratch = [];
/** cached full-frame offscreen canvas i (for masks / layers). */
function scratch(i = 0) {
  if (!_scratch[i]) { const c = document.createElement('canvas'); c.width = W; c.height = H; _scratch[i] = c; }
  const c = _scratch[i], g = c.getContext('2d'); g.setTransform(1, 0, 0, 1, 0, 0); g.clearRect(0, 0, W, H); g.globalAlpha = 1; g.globalCompositeOperation = 'source-over'; g.filter = 'none';
  return c;
}
/** current transform scale (how much the camera/withT has zoomed) */
function curScale() { const m = ctx.getTransform(); return Math.hypot(m.a, m.b); }
/** draw `content` only where `mask` paints (both are functions drawing with ctx). Respects camera/withT. */
function masked(mask, content) {
  const outer = ctx, m = outer.getTransform(), ga = outer.globalAlpha, a = scratch(0), b = scratch(1);
  const g1 = a.getContext('2d'), g2 = b.getContext('2d'); g1.setTransform(m); g2.setTransform(m);
  setCtx(g1); content(); setCtx(g2); mask();
  g1.setTransform(1, 0, 0, 1, 0, 0); g1.globalAlpha = 1; g1.globalCompositeOperation = 'destination-in'; g1.drawImage(b, 0, 0);
  setCtx(outer); ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.globalAlpha = ga; ctx.drawImage(a, 0, 0); ctx.restore();
}
/** draw fn into a layer, then composite it with a CSS filter (e.g. 'blur(12px)'), blend mode and alpha.
 *  Respects the current camera/withT transform and multiplies with the current alpha. */
function layer(fn, o = {}) {
  const outer = ctx, m = outer.getTransform(), ga = outer.globalAlpha, a = scratch(2), g = a.getContext('2d');
  g.setTransform(m); setCtx(g); fn(); setCtx(outer);
  ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0);
  if (o.filter) ctx.filter = o.filter; if (o.blend) ctx.globalCompositeOperation = o.blend; ctx.globalAlpha = ga * (o.alpha ?? 1);
  ctx.drawImage(a, 0, 0); ctx.restore();
}
/** bloom: draw fn sharp, then add a blurred copy on top (neon look). Radius scales with camera zoom. */
function bloom(fn, radius = 18 * U, strength = 0.9) {
  fn();
  layer(fn, { filter: `blur(${radius * curScale()}px)`, blend: 'lighter', alpha: strength });
}

/** motion blur: drawAt(tt) draws the WHOLE frame at time tt; n sub-frames across `shutter` of a frame are averaged.
 *  Use it only for the fastest moments (whip pans, punches): it costs n full frames. */
function motionBlur(drawAt, t, n = 12, shutter = 0.6) {
  const outer = ctx, acc = scratch(3), gA = acc.getContext('2d'), smp = scratch(4), gS = smp.getContext('2d');
  for (let k = 0; k < n; k++) {
    const tk = t + ((n === 1 ? 0.5 : k / (n - 1)) - 0.5) * shutter / FPS;
    gS.setTransform(1, 0, 0, 1, 0, 0); gS.globalAlpha = 1; gS.globalCompositeOperation = 'source-over'; gS.fillStyle = FILM.bg; gS.fillRect(0, 0, W, H);
    setCtx(gS); drawAt(tk); setCtx(outer);
    gA.setTransform(1, 0, 0, 1, 0, 0); gA.globalAlpha = 1 / (k + 1); gA.drawImage(smp, 0, 0);
  }
  ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.globalAlpha = 1; ctx.drawImage(acc, 0, 0); ctx.restore();
}

// ---------------------------------------------------------------- geometry
function polyLen(pts, closed) {
  let L = 0;
  for (let i = 1; i < pts.length; i++) L += Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]);
  if (closed) L += Math.hypot(pts[0][0] - pts[pts.length - 1][0], pts[0][1] - pts[pts.length - 1][1]);
  return L;
}
function resample(pts, closed, step) {
  const src = closed ? pts.concat([pts[0]]) : pts, out = [src[0].slice()];
  let carry = 0;
  for (let i = 1; i < src.length; i++) {
    const [x0, y0] = src[i - 1], [x1, y1] = src[i], d = Math.hypot(x1 - x0, y1 - y0);
    let s = step - carry;
    while (s <= d) { const u = s / d; out.push([x0 + (x1 - x0) * u, y0 + (y1 - y0) * u]); s += step; }
    carry = d - (s - step);
  }
  if (!closed) { const l = src[src.length - 1], o = out[out.length - 1]; if (Math.hypot(l[0] - o[0], l[1] - o[1]) > step * 0.3) out.push(l.slice()); }
  else if (out.length > 2) { const o = out[out.length - 1]; if (Math.hypot(o[0] - src[0][0], o[1] - src[0][1]) < step * 0.5) out.pop(); }
  return out;
}
/** exactly n points evenly spaced along a path (for morphs: both shapes get the same count) */
function resampleN(pts, n, closed = false) {
  const L = polyLen(pts, closed), step = L / (closed ? n : n - 1), out = resample(pts, closed, step * 0.9999);
  while (out.length > n) out.pop(); while (out.length < n) out.push(out[out.length - 1].slice());
  return out;
}
/** in-between of two shapes: both resampled to n points, then blended by u (0..1) */
function morph(a, b, u, n = 120, closed = true) {
  const A = resampleN(a, n, closed), B = resampleN(b, n, closed);
  return A.map((p, i) => [p[0] + (B[i][0] - p[0]) * u, p[1] + (B[i][1] - p[1]) * u]);
}
/** first fraction u (0..1) of a polyline, by length — for draw-on animation */
function partial(pts, u, closed = false) {
  const src = closed ? pts.concat([pts[0]]) : pts;
  if (u >= 1) return src; if (u <= 0) return [src[0], src[0]];
  const target = polyLen(src, false) * u, out = [src[0]];
  let acc = 0;
  for (let i = 1; i < src.length; i++) {
    const d = Math.hypot(src[i][0] - src[i - 1][0], src[i][1] - src[i - 1][1]);
    if (acc + d >= target) { const k = (target - acc) / d; out.push([lerp(src[i - 1][0], src[i][0], k), lerp(src[i - 1][1], src[i][1], k)]); return out; }
    acc += d; out.push(src[i]);
  }
  return out;
}
function rrect(x, y, w, h, r, n = 6) {
  r = Math.min(r, w / 2, h / 2); const pts = [];
  const corner = (cx, cy, a0) => { for (let i = 0; i <= n; i++) { const a = a0 + (i / n) * (Math.PI / 2); pts.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); } };
  corner(x + w - r, y + r, -Math.PI / 2); corner(x + w - r, y + h - r, 0); corner(x + r, y + h - r, Math.PI / 2); corner(x + r, y + r, Math.PI);
  return pts;
}
function ellipse(cx, cy, rx, ry, n = 64, rot = 0) {
  const pts = [], c = Math.cos(rot), s = Math.sin(rot);
  for (let i = 0; i < n; i++) { const a = (i / n) * TAU, x = Math.cos(a) * rx, y = Math.sin(a) * ry; pts.push([cx + x * c - y * s, cy + x * s + y * c]); }
  return pts;
}
function circlePts(cx, cy, r, n = 64) { return ellipse(cx, cy, r, r, n); }
function regular(cx, cy, r, n, rot = -Math.PI / 2) { const p = []; for (let i = 0; i < n; i++) { const a = rot + (i / n) * TAU; p.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); } return p; }
function starPts(cx, cy, r1, r2, n = 5, rot = -Math.PI / 2) { const p = []; for (let i = 0; i < n * 2; i++) { const a = rot + (i / (n * 2)) * TAU, r = i % 2 ? r2 : r1; p.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); } return p; }
function bez(p0, p1, p2, p3, n = 16) {
  const pts = [];
  for (let i = 0; i <= n; i++) { const t = i / n, u = 1 - t; pts.push([u * u * u * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t * t * t * p3[0], u * u * u * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t * t * t * p3[1]]); }
  return pts;
}
function qbez(p0, p1, p2, n = 12) { const pts = []; for (let i = 0; i <= n; i++) { const t = i / n, u = 1 - t; pts.push([u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0], u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]]); } return pts; }
/** mini path language "M x y L x y Q cx cy x y C c1x c1y c2x c2y x y Z" -> array of polylines */
function pathD(d) {
  const tok = d.replace(/([MLQCZ])/g, ' $1 ').trim().split(/[\s,]+/); let i = 0; const polys = []; let cur = null, p = [0, 0];
  const num = () => parseFloat(tok[i++]);
  while (i < tok.length) {
    const c = tok[i++];
    if (c === 'M') { p = [num(), num()]; cur = [p.slice()]; polys.push(cur); }
    else if (c === 'L') { p = [num(), num()]; cur.push(p.slice()); }
    else if (c === 'Q') { const c1 = [num(), num()], e = [num(), num()]; cur.push(...qbez(p, c1, e, 10).slice(1)); p = e; }
    else if (c === 'C') { const c1 = [num(), num()], c2 = [num(), num()], e = [num(), num()]; cur.push(...bez(p, c1, c2, e, 14).slice(1)); p = e; }
    else if (c === 'Z') cur.push(cur[0].slice());
  }
  return polys;
}
function xform(pts, ox, oy, sx, sy = sx, rot = 0) { const c = Math.cos(rot), s = Math.sin(rot); return pts.map(([x, y]) => { const X = x * sx, Y = y * sy; return [ox + X * c - Y * s, oy + X * s + Y * c]; }); }
function bbox(pts) { let x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9; for (const [x, y] of pts) { if (x < x0) x0 = x; if (y < y0) y0 = y; if (x > x1) x1 = x; if (y > y1) y1 = y; } return [x0, y0, x1, y1]; }

// ---------------------------------------------------------------- path drawing
function tracePath(pts, closed = true) { ctx.beginPath(); ctx.moveTo(pts[0][0], pts[0][1]); for (let i = 1; i < pts.length; i++) ctx.lineTo(pts[i][0], pts[i][1]); if (closed) ctx.closePath(); }
function fillPts(pts, col, alpha = 1) { ctx.save(); ctx.globalAlpha *= alpha; tracePath(pts, true); ctx.fillStyle = col; ctx.fill(); ctx.restore(); }
function strokePts(pts, col, lw, closed = false, alpha = 1) { ctx.save(); ctx.globalAlpha *= alpha; tracePath(pts, closed); ctx.strokeStyle = col; ctx.lineWidth = lw; ctx.stroke(); ctx.restore(); }
/** stroke the first fraction u of a path (draw-on). */
function drawOn(pts, u, col, lw, closed = false, alpha = 1) { if (u <= 0) return; strokePts(partial(pts, u, closed), col, lw, false, alpha); }
function rect(x, y, w, h, col) { ctx.fillStyle = col; ctx.fillRect(x, y, w, h); }
function circle(x, y, r, col, alpha = 1) { if (r <= 0) return; ctx.save(); ctx.globalAlpha *= alpha; ctx.beginPath(); ctx.arc(x, y, r, 0, TAU); ctx.fillStyle = col; ctx.fill(); ctx.restore(); }
function ringStroke(x, y, r, col, lw, u = 1, a0 = -Math.PI / 2) { if (r <= 0 || u <= 0) return; ctx.save(); ctx.beginPath(); ctx.arc(x, y, r, a0, a0 + TAU * clamp(u)); ctx.strokeStyle = col; ctx.lineWidth = lw; ctx.stroke(); ctx.restore(); }
function roundRect(x, y, w, h, r, fill, stroke, lw = 2 * U) { ctx.beginPath(); ctx.roundRect(x, y, w, h, r); if (fill) { ctx.fillStyle = fill; ctx.fill(); } if (stroke) { ctx.strokeStyle = stroke; ctx.lineWidth = lw; ctx.stroke(); } }
function line(x0, y0, x1, y1, col, lw, u = 1) { if (u <= 0) return; ctx.save(); ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(lerp(x0, x1, u), lerp(y0, y1, u)); ctx.strokeStyle = col; ctx.lineWidth = lw; ctx.stroke(); ctx.restore(); }
function arrow(x0, y0, x1, y1, col, lw, u = 1, head = 18 * U) {
  if (u <= 0) return; const x = lerp(x0, x1, u), y = lerp(y0, y1, u), a = Math.atan2(y1 - y0, x1 - x0);
  line(x0, y0, x, y, col, lw);
  ctx.save(); ctx.beginPath(); ctx.moveTo(x + Math.cos(a - 2.6) * head, y + Math.sin(a - 2.6) * head); ctx.lineTo(x, y); ctx.lineTo(x + Math.cos(a + 2.6) * head, y + Math.sin(a + 2.6) * head);
  ctx.strokeStyle = col; ctx.lineWidth = lw; ctx.stroke(); ctx.restore();
}

// ---------------------------------------------------------------- hand-drawn ink (boil + hatching)
/** displace points along their normals with smooth noise; new wobble per drawing (BOIL). */
function wob(pts, closed, seed, amp, wl = 70) {
  if (!amp) return pts;
  const n = pts.length; if (n < 2) return pts;
  const s = [0];
  for (let i = 1; i < n; i++) s.push(s[i - 1] + Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]));
  const L = s[n - 1] + (closed ? Math.hypot(pts[0][0] - pts[n - 1][0], pts[0][1] - pts[n - 1][1]) : 0);
  const out = new Array(n);
  for (let i = 0; i < n; i++) {
    const a = pts[(i - 1 + n) % n], b = pts[(i + 1) % n];
    let tx, ty;
    if (!closed && i === 0) { tx = pts[1][0] - pts[0][0]; ty = pts[1][1] - pts[0][1]; }
    else if (!closed && i === n - 1) { tx = pts[n - 1][0] - pts[n - 2][0]; ty = pts[n - 1][1] - pts[n - 2][1]; }
    else { tx = b[0] - a[0]; ty = b[1] - a[1]; }
    const tl = Math.hypot(tx, ty) || 1, nx = -ty / tl, ny = tx / tl;
    const f = (u) => snoise(u / wl, seed) + 0.45 * snoise(u / (wl * 0.33), seed + 77);
    let d;
    if (closed) { const w = s[i] / L; d = f(s[i]) * (1 - w) + f(s[i] - L) * w; } else d = f(s[i]);
    out[i] = [pts[i][0] + nx * d * amp, pts[i][1] + ny * d * amp];
  }
  return out;
}
/** seed tied to the current drawing, so boil changes every drawing (every 2 frames on twos) */
function bseed(id) { return hashInts(seedOf(id), CLK.BOIL); }
function hatchIn(pts, h, seed) {
  const [bx0, by0, bx1, by1] = bbox(pts), ang = (h.ang ?? -8) * Math.PI / 180;
  const dx = Math.cos(ang), dy = Math.sin(ang), nx = -dy, ny = dx, cx = (bx0 + bx1) / 2, cy = (by0 + by1) / 2;
  const hw = (bx1 - bx0) / 2, hh = (by1 - by0) / 2, ext = Math.abs(hw * nx) + Math.abs(hh * ny), extD = Math.abs(hw * dx) + Math.abs(hh * dy);
  const gap = h.gap ?? 8 * U, lmin = h.len ? h.len[0] : 10 * U, lmax = h.len ? h.len[1] : 28 * U;
  const r = rng(seed, h.id || 'h'), where = h.where || (() => 1), dens = h.dens ?? 0.8;
  ctx.save(); tracePath(pts, true); ctx.clip(); ctx.beginPath();
  for (let o = -ext; o <= ext; o += gap) {
    const off = o + (r() - 0.5) * gap * 0.6;
    let pos = -extD - r() * lmax;
    while (pos < extD) {
      const L = lmin + (lmax - lmin) * r(), mid = pos + L / 2, px = cx + dx * mid + nx * off, py = cy + dy * mid + ny * off;
      if (r() < dens * where(px, py)) { const ja = (r() - 0.5) * 0.08, ddx = Math.cos(ang + ja), ddy = Math.sin(ang + ja); ctx.moveTo(px - ddx * L / 2, py - ddy * L / 2); ctx.lineTo(px + ddx * L / 2, py + ddy * L / 2); }
      pos += L + (0.25 + r() * 1.1) * L;
    }
  }
  ctx.strokeStyle = h.color; ctx.globalAlpha *= (h.alpha ?? 0.5); ctx.lineWidth = h.lw ?? 1.6 * U; ctx.stroke(); ctx.restore();
}
function side(cx, cy, r, lx, ly, a, b) { const l = Math.hypot(lx, ly); lx /= l; ly /= l; return (x, y) => sstep(a, b, ((x - cx) * lx + (y - cy) * ly) / r); }
/** two-tone hatching for a shape centred at (cx, cy) with size r: light from top-left by default */
function hatchSet(cx, cy, r, light, dark, opt = {}) {
  const lx = opt.lx ?? -0.55, ly = opt.ly ?? -0.85, s = (opt.scale ?? 1) * U, out = [];
  if (light) out.push({ id: 'hl', color: light, alpha: opt.la ?? 0.55, ang: -8, gap: 7 * s, len: [8 * s, 26 * s], lw: 1.7 * s, dens: 0.85, where: side(cx, cy, r, lx, ly, 0.05, 0.75) });
  if (dark) {
    out.push({ id: 'hd', color: dark, alpha: opt.da ?? 0.42, ang: 58, gap: 6 * s, len: [10 * s, 30 * s], lw: 1.5 * s, dens: 0.9, where: side(cx, cy, r, -lx, -ly, 0.0, 0.8) });
    out.push({ id: 'hx', color: dark, alpha: (opt.da ?? 0.42) * 0.8, ang: 120, gap: 7 * s, len: [8 * s, 22 * s], lw: 1.3 * s, dens: 0.9, where: side(cx, cy, r, -lx, -ly, 0.45, 1.0) });
  }
  return out;
}
/** ink(pts, {id, fill, hatch, stroke, lw, boil, closed, alpha, fx}) — fill, hatch, clipped fx, then outline */
function ink(pts, o = {}) {
  const closed = o.closed !== false, seed = o.seed ?? bseed(o.id || 'ink');
  const bp = o.boil === 0 ? pts : wob(pts, closed, seed, o.boil ?? 1.2 * U, o.wl ?? 70 * U);
  ctx.save();
  if (o.alpha != null) ctx.globalAlpha *= o.alpha;
  if (o.fill && closed) { tracePath(bp, true); ctx.fillStyle = o.fill; ctx.fill(); }
  if (o.hatch && closed) for (const h of o.hatch) hatchIn(bp, h, seed);
  if (o.fx && closed) { ctx.save(); tracePath(bp, true); ctx.clip(); o.fx(bp); ctx.restore(); }
  if (o.stroke && (o.lw ?? 6 * U) > 0) { tracePath(bp, closed); ctx.strokeStyle = o.stroke; ctx.lineWidth = o.lw ?? 6 * U; ctx.stroke(); }
  ctx.restore();
  return bp;
}
function hatchShadow(cx, cy, rx, ry, col, a = 0.5, id = 'shadow') {
  const pts = ellipse(cx, cy, rx, ry, 36), fall = (x, y) => 1 - clamp(Math.hypot((x - cx) / rx, (y - cy) / ry));
  hatchIn(pts, { id, color: col, alpha: a, ang: 62, gap: 3.2 * U, len: [4 * U, 10 * U], lw: 1.2 * U, dens: 1, where: (x, y) => 0.25 + fall(x, y) * 1.2 }, bseed(id));
}

// ---------------------------------------------------------------- light, sparkle, overlays, fx
function glow(x, y, r, col, a = 1, mode = 'lighter') {
  if (a <= 0 || r <= 0) return;
  const g = ctx.createRadialGradient(x, y, 0, x, y, r);
  g.addColorStop(0, rgba(col, a)); g.addColorStop(0.25, rgba(col, a * 0.55)); g.addColorStop(0.6, rgba(col, a * 0.16)); g.addColorStop(1, rgba(col, 0));
  ctx.save(); ctx.globalCompositeOperation = mode; ctx.fillStyle = g; ctx.fillRect(x - r, y - r, 2 * r, 2 * r); ctx.restore();
}
function wash(x0, y0, x1, y1, col, a0, a1, mode = 'source-over') { ctx.save(); ctx.globalCompositeOperation = mode; ctx.fillStyle = linGrad(x0, y0, x1, y1, [[0, rgba(col, a0)], [1, rgba(col, a1)]]); ctx.fillRect(-1e4, -1e4, 2e4, 2e4); ctx.restore(); }
function sparkle(x, y, r, col, a = 1, rot = 0) {
  if (r <= 0 || a <= 0) return;
  ctx.save(); ctx.translate(x, y); ctx.rotate(rot); ctx.globalAlpha *= a; ctx.beginPath();
  for (let i = 0; i < 4; i++) { const a0 = i * Math.PI / 2, a1 = a0 + Math.PI / 4, a2 = a0 + Math.PI / 2; if (i === 0) ctx.moveTo(Math.cos(a0) * r, Math.sin(a0) * r); ctx.quadraticCurveTo(Math.cos(a1) * r * 0.16, Math.sin(a1) * r * 0.16, Math.cos(a2) * r, Math.sin(a2) * r); }
  ctx.closePath(); ctx.fillStyle = col; ctx.fill(); ctx.restore();
}
/** dashed construction ring with tick marks */
function ring(x, y, r, o = {}) {
  const lw = o.lw ?? 1.5 * U, rot = o.rot ?? 0;
  ctx.save(); ctx.globalAlpha *= o.alpha ?? 0.5; ctx.strokeStyle = o.color || '#ffffff'; ctx.lineWidth = lw;
  if (o.dash !== false) ctx.setLineDash(o.dash || [lw * 3, lw * 5]);
  ctx.lineDashOffset = o.dashOff ?? 0;
  ctx.beginPath(); ctx.arc(x, y, r, (o.a0 ?? 0) + rot, (o.a1 ?? TAU) + rot); ctx.stroke(); ctx.setLineDash([]);
  const nt = o.ticks ?? 8, tl = o.tickLen ?? r * 0.06; ctx.beginPath();
  for (let i = 0; i < nt; i++) { const ang = rot + (i / nt) * TAU + 0.3, c = Math.cos(ang), s = Math.sin(ang); ctx.moveTo(x + c * (r - tl), y + s * (r - tl)); ctx.lineTo(x + c * (r + tl), y + s * (r + tl)); }
  ctx.stroke(); ctx.restore();
}
function speedLines(cx, cy, r0, r1, n, id, col, a, lw) {
  const r = rng(id, CLK.BOIL);
  ctx.save(); ctx.strokeStyle = col; ctx.globalAlpha *= a; ctx.lineWidth = lw; ctx.beginPath();
  for (let i = 0; i < n; i++) { const ang = r() * TAU, ra = r0 + (r1 - r0) * r() * 0.6, rb = ra + (r1 - r0) * (0.15 + r() * 0.5); ctx.moveTo(cx + Math.cos(ang) * ra, cy + Math.sin(ang) * ra); ctx.lineTo(cx + Math.cos(ang) * rb, cy + Math.sin(ang) * rb); }
  ctx.stroke(); ctx.restore();
}
/** short emphasis lines radiating from a point */
function burst(x, y, r0, r1, n, rot, col, lw, a = 1) {
  ctx.save(); ctx.strokeStyle = col; ctx.lineWidth = lw; ctx.globalAlpha *= a; ctx.beginPath();
  for (let i = 0; i < n; i++) { const ang = rot + (i / n) * TAU; ctx.moveTo(x + Math.cos(ang) * r0, y + Math.sin(ang) * r0); ctx.lineTo(x + Math.cos(ang) * r1, y + Math.sin(ang) * r1); }
  ctx.stroke(); ctx.restore();
}
/** deterministic particles: fn(i, r) is called for each; r() gives stable randoms per particle */
function particles(id, n, fn) { for (let i = 0; i < n; i++) fn(i, rng(id, i)); }
/** falling streaks (rain / snow / data), animated on the animation clock */
function streaks(x0, y0, w, h, o = {}) {
  const n = o.count ?? 140, len = o.len ?? [14 * U, 38 * U], ang = (o.ang ?? 76) * Math.PI / 180, spd = o.speed ?? 1400 * U, r = rng(o.id || 'streaks');
  const dx = Math.cos(ang), dy = Math.sin(ang), t = CLK.TA;
  ctx.save(); ctx.strokeStyle = o.color || '#b8c0ff'; ctx.lineWidth = o.lw ?? 1.2 * U; ctx.globalAlpha *= (o.alpha ?? 0.35); ctx.beginPath();
  for (let i = 0; i < n; i++) {
    const bx = r() * (w + 200 * U) - 100 * U, by = r(), L = len[0] + (len[1] - len[0]) * r(), sp = spd * (0.8 + r() * 0.4);
    const travel = (by * (h + L * 2) + t * sp) % (h + L * 2) - L, px = x0 + bx + travel * dx / dy, py = y0 + travel;
    ctx.moveTo(px, py); ctx.lineTo(px + dx * L, py + dy * L);
  }
  ctx.stroke(); ctx.restore();
}
/** full-frame flash (use with pulse()) */
function flash(a, col = '#ffffff', mode = 'source-over') { if (a <= 0) return; ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.globalCompositeOperation = mode; ctx.globalAlpha = clamp(a); ctx.fillStyle = col; ctx.fillRect(0, 0, W, H); ctx.restore(); }
/** solid wipe covering the frame as u goes 0..1. dir: 'left'|'right'|'up'|'down' */
function wipe(u, dir = 'left', col = '#000000') {
  if (u <= 0) return; u = clamp(u); ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.fillStyle = col;
  if (dir === 'left') ctx.fillRect(W * (1 - u), 0, W * u, H); else if (dir === 'right') ctx.fillRect(0, 0, W * u, H);
  else if (dir === 'up') ctx.fillRect(0, H * (1 - u), W, H * u); else ctx.fillRect(0, 0, W, H * u);
  ctx.restore();
}
/** circle reveal: at u=0 nothing is covered, at u=1 the whole frame is covered by col */
function iris(u, x = CX, y = CY, col = '#000000') { if (u <= 0) return; const R = Math.hypot(Math.max(x, W - x), Math.max(y, H - y)); ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0); circle(x, y, R * eInOut(clamp(u)), col); ctx.restore(); }

// ---------------------------------------------------------------- real-font typography
const FONT_FILES = [
  ['Bricolage Grotesque', 'BricolageGrotesque-Regular.ttf', 400], ['Bricolage Grotesque', 'BricolageGrotesque-Bold.ttf', 700],
  ['Instrument Serif', 'InstrumentSerif-Regular.ttf', 400], ['Instrument Serif', 'InstrumentSerif-Italic.ttf', 400, 'italic'],
  ['Instrument Sans', 'InstrumentSans-Regular.ttf', 400], ['Instrument Sans', 'InstrumentSans-Bold.ttf', 700],
  ['Outfit', 'Outfit-Regular.ttf', 400], ['Outfit', 'Outfit-Bold.ttf', 700],
  ['Big Shoulders', 'BigShoulders-Regular.ttf', 400], ['Big Shoulders', 'BigShoulders-Bold.ttf', 700],
  ['Boldonse', 'Boldonse-Regular.ttf', 400], ['Gloock', 'Gloock-Regular.ttf', 400],
  ['Geist Mono', 'GeistMono-Regular.ttf', 400], ['Geist Mono', 'GeistMono-Bold.ttf', 700],
  ['Tektur', 'Tektur-Medium.ttf', 500], ['Nothing You Could Do', 'NothingYouCouldDo-Regular.ttf', 400],
];
const FONT_WEIGHTS = {};
FONT_FILES.forEach(([fam, , w]) => { (FONT_WEIGHTS[fam] ||= []).push(w); });
/** nearest weight the family really has (asking Boldonse for 700 would give a smeared fake bold) */
function realWeight(fam, want) { const ws = FONT_WEIGHTS[fam]; if (!ws) return want; return ws.reduce((b, w) => Math.abs(w - want) < Math.abs(b - want) ? w : b, ws[0]); }
function fontStr(size, o = {}) { const fam = o.font || FILM.font; return `${o.italic ? 'italic ' : ''}${realWeight(fam, o.weight ?? 700)} ${size}px "${fam}"`; }
/** measured width including tracking (tracking is in em, e.g. -0.02) */
function textW(str, size, o = {}) { if (o.tabular) return tabularW(str, size, o); ctx.save(); ctx.font = fontStr(size, o); const w = ctx.measureText(str).width + (o.tracking ?? 0) * size * Math.max(0, [...str].length - 1); ctx.restore(); return w; }
/** metrics(str, size, o) -> { w, asc, desc, capH, fontAsc, fontDesc }: measured ink box of this string
 *  (asc/desc above/below the baseline) and the font's full line box. Use it to size backing shapes and masks. */
function metrics(str, size, o = {}) {
  ctx.save(); ctx.font = fontStr(size, o); const m = ctx.measureText(str), hm = ctx.measureText('H'); ctx.restore();
  return { w: textW(str, size, o), asc: m.actualBoundingBoxAscent, desc: m.actualBoundingBoxDescent, capH: hm.actualBoundingBoxAscent, fontAsc: m.fontBoundingBoxAscent, fontDesc: m.fontBoundingBoxDescent };
}
/** cap height in px of a font at a size (for optical vertical centring) */
function capH(size, o = {}) { ctx.save(); ctx.font = fontStr(size, o); const m = ctx.measureText('H'); ctx.restore(); return m.actualBoundingBoxAscent; }
/** largest size <= size that fits maxW */
function fitSize(str, size, maxW, o = {}) { const w = textW(str, size, o); return w > maxW ? size * maxW / w : size; }
/**
 * text(str, x, y, size, o) — draw one line of real-font text.
 * o: font, weight, italic, color, align ('left'|'center'|'right'), base ('alphabetic'|'middle'|'top'),
 *    tracking (em), alpha, maxW (auto-shrink), stroke, lw, glow ({color, r}), shadow
 */
function text(str, x, y, size, o = {}) {
  if (o.tabular) { if (o.maxW) { const tw = tabularW(str, size, o); if (tw > o.maxW) size *= o.maxW / tw; } return tabularText(str, x, y, size, o); }
  if (o.maxW) size = fitSize(str, size, o.maxW, o);
  const tr = (o.tracking ?? 0) * size;
  ctx.save(); ctx.font = fontStr(size, o); ctx.textBaseline = o.base || 'alphabetic';
  if (o.alpha != null) ctx.globalAlpha *= clamp(o.alpha);
  const w = textW(str, size, o), x0 = o.align === 'center' ? x - w / 2 : o.align === 'right' ? x - w : x;
  const paint = () => {
    if (!tr) { ctx.textAlign = 'left'; if (o.stroke) { ctx.strokeStyle = o.stroke; ctx.lineWidth = o.lw ?? size * 0.06; ctx.strokeText(str, x0, y); } if (o.color !== null) { ctx.fillStyle = o.color || '#ffffff'; ctx.fillText(str, x0, y); } return; }
    let cx = x0; const chars = [...str];
    chars.forEach((ch, i) => { const pre = ctx.measureText(chars.slice(0, i).join('')).width; cx = x0 + pre + tr * i; if (o.stroke) { ctx.strokeStyle = o.stroke; ctx.lineWidth = o.lw ?? size * 0.06; ctx.strokeText(ch, cx, y); } if (o.color !== null) { ctx.fillStyle = o.color || '#ffffff'; ctx.fillText(ch, cx, y); } });
  };
  if (o.shadow) { ctx.shadowColor = o.shadow.color || 'rgba(0,0,0,0.5)'; ctx.shadowBlur = o.shadow.blur ?? 20 * U; ctx.shadowOffsetY = o.shadow.y ?? 6 * U; }
  if (o.glow) { ctx.save(); ctx.shadowColor = o.glow.color || o.color; ctx.shadowBlur = o.glow.r ?? 30 * U; paint(); paint(); ctx.restore(); }
  paint();
  ctx.restore();
  return { x: x0, w, size };
}
/** width of a string laid out with tabular digits */
function tabularW(str, size, o = {}) {
  ctx.save(); ctx.font = fontStr(size, o);
  const dw = Math.max(...'0123456789'.split('').map((d) => ctx.measureText(d).width)), chars = [...str];
  const w = chars.reduce((a, c) => a + (/\d/.test(c) ? dw : ctx.measureText(c).width), 0) + (o.tracking ?? 0) * size * (chars.length - 1);
  ctx.restore(); return w;
}
/** digits in fixed-width slots so counting numbers don't jitter sideways (text(..., {tabular: true})).
 *  Best with Geist Mono, Bricolage or Outfit; very wide display faces space narrow digits (1) visibly. */
function tabularText(str, x, y, size, o) {
  ctx.save(); ctx.font = fontStr(size, o);
  const dw = Math.max(...'0123456789'.split('').map((d) => ctx.measureText(d).width)), tr = (o.tracking ?? 0) * size;
  const chars = [...str], cw = chars.map((c) => /\d/.test(c) ? dw : ctx.measureText(c).width), w = cw.reduce((a, b) => a + b, 0) + tr * (chars.length - 1);
  let cx = o.align === 'center' ? x - w / 2 : o.align === 'right' ? x - w : x;
  ctx.textBaseline = o.base || 'alphabetic'; if (o.alpha != null) ctx.globalAlpha *= clamp(o.alpha);
  if (o.glow) { ctx.shadowColor = o.glow.color || o.color; ctx.shadowBlur = o.glow.r ?? 30 * U; }
  chars.forEach((c, i) => { const off = /\d/.test(c) ? (dw - ctx.measureText(c).width) / 2 : 0; if (o.stroke) { ctx.strokeStyle = o.stroke; ctx.lineWidth = o.lw ?? size * 0.06; ctx.strokeText(c, cx + off, y); } if (o.color !== null) { ctx.fillStyle = o.color || '#ffffff'; ctx.fillText(c, cx + off, y); } cx += cw[i] + tr; });
  ctx.restore(); return { x: x, w, size };
}
/** split into lines that fit maxW */
function wrap(str, size, maxW, o = {}) {
  const words = str.split(/\s+/), lines = []; let cur = '';
  for (const w of words) { const t = cur ? cur + ' ' + w : w; if (textW(t, size, o) > maxW && cur) { lines.push(cur); cur = w; } else cur = t; }
  if (cur) lines.push(cur); return lines;
}
/**
 * words(str, x, y, size, o) -> layout for per-word animation:
 * [{word, i, line, x, y, w}] with x = left edge, y = baseline. Honors o.maxW (wraps), o.lh (line height ×size), o.align.
 */
function words(str, x, y, size, o = {}) {
  const lh = (o.lh ?? 1.08) * size, lines = o.maxW ? wrap(str, size, o.maxW, o) : [str], space = textW(' ', size, o), out = [];
  let i = 0;
  lines.forEach((ln, li) => {
    const ws = ln.split(/\s+/), lw = textW(ln, size, o);
    let cx = o.align === 'center' ? x - lw / 2 : o.align === 'right' ? x - lw : x;
    const ly = y + li * lh - (o.valign === 'middle' ? (lines.length - 1) * lh / 2 : 0);
    ws.forEach((w) => { const ww = textW(w, size, o); out.push({ word: w, i: i++, line: li, x: cx, y: ly, w: ww }); cx += ww + space; });
  });
  return out;
}
/**
 * reveal(str, x, y, size, u, o) — kinetic text in one call. u: 0..1 progress.
 * o.by: 'word' | 'char' ; o.mode: 'rise' | 'fade' | 'scale' | 'mask' | 'blur' | 'type' | 'slam'
 * o.stagger: 0..1 share of the reveal spent staggering (default 0.6); o.ease; plus text() options.
 */
function reveal(str, x, y, size, u, o = {}) {
  if (u <= 0) return; if (o.maxW && !o.wrap) size = fitSize(str, size, o.maxW, o);
  const by = o.by || 'word', mode = o.mode || 'rise', ease = o.ease || eOutQuint, stag = o.stagger ?? 0.6;
  const items = by === 'char' ? charLayout(str, x, y, size, o) : words(str, x, y, size, o.wrap ? o : { ...o, maxW: 0 });
  const n = items.length;
  items.forEach((it, k) => {
    const start = n > 1 ? (k / (n - 1)) * stag : 0, p = ease(clamp((u - start) / (1 - stag || 1)));
    if (p <= 0) return;
    const label = it.word ?? it.ch, base = { ...o, align: 'left', maxW: 0 };
    if (o.colors) base.color = o.colors[k % o.colors.length];
    if (o.colorOf) base.color = o.colorOf(label, k);
    ctx.save();
    if (mode === 'rise') { ctx.globalAlpha *= clamp(p * 1.6); text(label, it.x, it.y + (1 - p) * size * 0.6, size, base); }
    else if (mode === 'fade') { ctx.globalAlpha *= p; text(label, it.x, it.y, size, base); }
    else if (mode === 'scale' || mode === 'slam') {
      const s = mode === 'slam' ? lerp(2.4, 1, eOutBack(p, 1.2)) : lerp(0.6, 1, eOutBack(p)); const cx = it.x + it.w / 2, cy = it.y - size * 0.35;
      ctx.globalAlpha *= clamp(p * 2); ctx.translate(cx, cy); ctx.scale(s, s); ctx.translate(-cx, -cy); text(label, it.x, it.y, size, base);
    }
    else if (mode === 'mask') { const mm = metrics('Hg', size, base), top = it.y - mm.fontAsc, hgt = mm.fontAsc + mm.fontDesc; ctx.beginPath(); ctx.rect(it.x - size, top, it.w + size * 2, hgt); ctx.clip(); text(label, it.x, it.y + (1 - p) * hgt, size, base); }
    else if (mode === 'blur') { ctx.globalAlpha *= p; ctx.filter = `blur(${(1 - p) * size * 0.25}px)`; text(label, it.x, it.y, size, base); }
    else if (mode === 'type') { if (p > 0) text(label, it.x, it.y, size, base); }
    ctx.restore();
  });
}
function charLayout(str, x, y, size, o = {}) {
  const chars = [...str], w = textW(str, size, o), x0 = o.align === 'center' ? x - w / 2 : o.align === 'right' ? x - w : x, tr = (o.tracking ?? 0) * size;
  ctx.save(); ctx.font = fontStr(size, o);
  const out = chars.map((ch, i) => ({ ch, i, x: x0 + ctx.measureText(chars.slice(0, i).join('')).width + tr * i, y, w: ctx.measureText(ch).width }));
  ctx.restore(); return out;
}
/** animated number: counter(0, 1250000, u, v => '$' + fmtNum(v)) */
function counter(a, b, u, fmt = (v) => fmtNum(Math.round(v))) { return fmt(lerp(a, b, clamp(u))); }
function fmtNum(v, dp = 0) { return Number(v).toLocaleString('en-US', { minimumFractionDigits: dp, maximumFractionDigits: dp }); }

// ---------------------------------------------------------------- hand-lettered stroke font (for the ink style)
// Glyph box: width ~4, cap height 6, y down. Drawn with the same boil as the ink shapes.
const GLYPHS = {
  'A': [4, 'M0 6 L2 0 L4 6 M0.8 3.9 L3.2 3.9'], 'B': [4, 'M0 6 L0 0 L2.3 0 C4 0 4 3 2.3 3 L0 3 M2.3 3 C4.3 3 4.3 6 2.3 6 L0 6'],
  'C': [4, 'M4 1 C3 -0.3 0 -0.3 0 3 C0 6.3 3 6.3 4 5'], 'D': [4, 'M0 0 L0 6 L1.7 6 C4.4 6 4.4 0 1.7 0 L0 0'],
  'E': [3.6, 'M3.6 0 L0 0 L0 6 L3.6 6 M0 3 L2.9 3'], 'F': [3.5, 'M3.5 0 L0 0 L0 6 M0 3 L2.8 3'],
  'G': [4, 'M4 1 C3 -0.3 0 -0.3 0 3 C0 6.3 4 6.3 4 3.4 L2.3 3.4'], 'H': [4, 'M0 0 L0 6 M4 0 L4 6 M0 3 L4 3'],
  'I': [1.2, 'M0.6 0 L0.6 6'], 'J': [3.4, 'M3 0 L3 4.3 C3 6.4 0 6.4 0 4.6'],
  'K': [4, 'M0 0 L0 6 M4 0 L0 3.9 M1.4 2.7 L4 6'], 'L': [3.5, 'M0 0 L0 6 L3.5 6'],
  'M': [5, 'M0 6 L0 0 L2.5 4 L5 0 L5 6'], 'N': [4, 'M0 6 L0 0 L4 6 L4 0'],
  'O': [4.4, 'M2.2 0 C-0.7 0 -0.7 6 2.2 6 C5.1 6 5.1 0 2.2 0'], 'P': [3.8, 'M0 6 L0 0 L2.3 0 C4.3 0 4.3 3.3 2.3 3.3 L0 3.3'],
  'Q': [4.4, 'M2.2 0 C-0.7 0 -0.7 6 2.2 6 C5.1 6 5.1 0 2.2 0 M2.6 4.4 L4.4 6.4'],
  'R': [4, 'M0 6 L0 0 L2.3 0 C4.3 0 4.3 3.3 2.3 3.3 L0 3.3 M2.1 3.3 L4 6'],
  'S': [3.8, 'M3.7 0.9 C3 -0.2 0.2 -0.3 0.2 1.5 C0.2 3.2 3.7 2.6 3.7 4.5 C3.7 6.3 0.7 6.3 0 5'],
  'T': [4, 'M0 0 L4 0 M2 0 L2 6'], 'U': [4, 'M0 0 L0 4 C0 6.4 4 6.4 4 4 L4 0'], 'V': [4, 'M0 0 L2 6 L4 0'],
  'W': [5.4, 'M0 0 L1.3 6 L2.7 1.8 L4.1 6 L5.4 0'], 'X': [4, 'M0 0 L4 6 M4 0 L0 6'], 'Y': [4, 'M0 0 L2 3 L4 0 M2 3 L2 6'], 'Z': [4, 'M0 0 L4 0 L0 6 L4 6'],
  '0': [4, 'M2 0 C-0.6 0 -0.6 6 2 6 C4.6 6 4.6 0 2 0'], '1': [3.4, 'M0.6 1.3 L2 0 L2 6 M0.6 6 L3.4 6'],
  '2': [4, 'M0.3 1.2 C1 -0.4 4 -0.4 3.8 1.8 C3.6 3.2 0 5 0 6 L4 6'],
  '3': [4, 'M0.2 0.8 C1 -0.4 3.8 -0.2 3.8 1.5 C3.8 2.8 2.4 3 1.6 3 C2.6 3 4 3.3 4 4.6 C4 6.3 1 6.4 0 5.2'],
  '4': [4, 'M3 6 L3 0 L0 4.2 L4 4.2'], '5': [4, 'M3.8 0 L0.6 0 L0.3 2.6 C1.2 2.1 4 1.9 4 4.1 C4 6.4 0.8 6.4 0 5.2'],
  '6': [4, 'M3.5 0.6 C2.3 -0.4 0 0 0 3.6 C0 6.4 4 6.4 4 4.2 C4 2.2 0.8 2 0.1 3.6'], '7': [4, 'M0 0 L4 0 L1.4 6'],
  '8': [4, 'M2 3 C-0.4 3 -0.4 0 2 0 C4.4 0 4.4 3 2 3 C-0.6 3 -0.6 6 2 6 C4.6 6 4.6 3 2 3'],
  '9': [4, 'M3.9 2.4 C3.2 4 0 3.8 0 1.8 C0 -0.4 4 -0.4 4 2.4 C4 6 1.7 6.4 0.5 5.4'],
  '%': [4.4, 'M4.2 0 L0.2 6 M1 0 C0 0 0 2 1 2 C2 2 2 0 1 0 M3.4 4 C2.4 4 2.4 6 3.4 6 C4.4 6 4.4 4 3.4 4'],
  ':': [1.4, 'M0.7 1.7 L0.7 1.8 M0.7 4.6 L0.7 4.7'], '!': [1.4, 'M0.7 0 L0.7 4 M0.7 5.8 L0.7 5.9'], '.': [1.2, 'M0.6 5.9 L0.6 6'],
  ',': [1.4, 'M0.8 5.6 L0.5 6.8'], '?': [3.6, 'M0.2 1 C0.8 -0.4 3.6 -0.3 3.6 1.5 C3.6 3 1.8 3 1.8 4.3 M1.8 5.8 L1.8 5.9'],
  '-': [3, 'M0.3 3.4 L2.7 3.4'], '+': [3.6, 'M0.2 3.4 L3.4 3.4 M1.8 1.8 L1.8 5'], "'": [1.2, 'M0.6 0 L0.6 1.6'], '/': [3, 'M3 0 L0 6'],
  '$': [4, 'M3.7 1.2 C3 0.1 0.3 0 0.3 1.7 C0.3 3.2 3.7 2.7 3.7 4.4 C3.7 6.1 0.8 6.1 0 5 M2 -0.6 L2 6.6'], ' ': [2.4, ''],
  '#': [4.4, 'M1.5 0.3 L0.9 5.7 M3.5 0.3 L2.9 5.7 M0.2 2 L4.2 2 M0 4 L4 4'], '&': [4.4, 'M4.2 6 L1.1 2.4 C0.2 1.3 0.8 0 1.9 0 C3 0 3.4 1.3 2.4 2.3 L0.9 3.7 C-0.4 5 0.6 6.2 1.9 6.1 C2.9 6 3.6 5.2 4.1 4'],
  '(': [2, 'M1.8 -0.4 C0 1.5 0 4.5 1.8 6.4'], ')': [2, 'M0.2 -0.4 C2 1.5 2 4.5 0.2 6.4'], '=': [3.6, 'M0.2 2.5 L3.4 2.5 M0.2 4.3 L3.4 4.3'],
  '"': [2.2, 'M0.6 0 L0.6 1.6 M1.6 0 L1.6 1.6'], '*': [3.4, 'M1.7 0.6 L1.7 3.4 M0.4 1.3 L3 2.7 M3 1.3 L0.4 2.7'],
};
const _glyphCache = {};
function glyphPolys(ch) {
  if (_glyphCache[ch]) return _glyphCache[ch];
  const g = GLYPHS[ch] || GLYPHS[ch.toUpperCase()] || GLYPHS[' '];
  // tiny strokes (the dots of . ! : ?) are kept as dots instead of being resampled away
  const polys = g[1] ? pathD(g[1]).map((p) => polyLen(p, false) < 0.3 ? [p[0], p[0]] : resample(p, false, 0.35)) : [];
  return (_glyphCache[ch] = { w: g[0], polys });
}
function handW(str, size, track = 1.1) { const k = size / 6; let w = 0; for (const ch of str) w += (glyphPolys(ch).w + track) * k; return w - track * k; }
/** hand-lettered text (ink style). size = cap height. u (0..1) draws the strokes on. */
function hand(str, x, y, size, o = {}) {
  const k = size / 6, track = o.track ?? 1.1, w = handW(str, size, track), u = o.u ?? 1;
  let cx = o.align === 'center' ? x - w / 2 : o.align === 'right' ? x - w : x;
  ctx.save(); ctx.strokeStyle = o.color || '#2e1a1b'; ctx.lineWidth = o.lw ?? size * 0.14; if (o.alpha != null) ctx.globalAlpha *= o.alpha;
  const chars = [...str]; let gi = 0;
  chars.forEach((ch) => {
    const g = glyphPolys(ch), cu = clamp(u * chars.length - gi);
    g.polys.forEach((poly, pi) => {
      if (cu <= 0) return;
      const pts = poly.map(([px, py]) => [cx + px * k, y - size + py * k]);
      if (poly.length === 2 && poly[0] === poly[1]) { ctx.beginPath(); ctx.arc(pts[0][0], pts[0][1], ctx.lineWidth * 0.6, 0, TAU); ctx.fillStyle = ctx.strokeStyle; ctx.fill(); return; }
      const bp = wob(cu < 1 ? partial(pts, cu) : pts, false, bseed(hashInts(seedOf(o.id || 'hand'), gi, pi)), o.boil ?? size * 0.02, size * 0.6);
      tracePath(bp, false); ctx.stroke();
    });
    cx += (g.w + track) * k; gi++;
  });
  ctx.restore(); return w;
}

// ---------------------------------------------------------------- icons (24x24 path data, stroked)
const ICONS = {
  check: 'M5 12.5 L10 17.5 L19.5 6.5', x: 'M6 6 L18 18 M18 6 L6 18', plus: 'M12 5 L12 19 M5 12 L19 12',
  arrowRight: 'M4 12 L20 12 M14 6 L20 12 L14 18', arrowUp: 'M12 20 L12 4 M6 10 L12 4 L18 10', arrowDown: 'M12 4 L12 20 M6 14 L12 20 L18 14',
  play: 'M7 4.5 L19 12 L7 19.5 Z', pause: 'M8 5 L8 19 M16 5 L16 19',
  heart: 'M12 20 C12 20 3 14.5 3 8.6 C3 5.5 5.4 3.5 8 3.5 C9.8 3.5 11.2 4.6 12 6 C12.8 4.6 14.2 3.5 16 3.5 C18.6 3.5 21 5.5 21 8.6 C21 14.5 12 20 12 20 Z',
  star: 'M12 3 L14.7 8.8 L21 9.5 L16.3 13.8 L17.6 20 L12 16.8 L6.4 20 L7.7 13.8 L3 9.5 L9.3 8.8 Z',
  bolt: 'M13.5 2.5 L5 13.5 L11.5 13.5 L10.5 21.5 L19 10.5 L12.5 10.5 Z',
  lock: 'M6 11 L18 11 L18 20.5 L6 20.5 Z M8.5 11 L8.5 8 C8.5 3.5 15.5 3.5 15.5 8 L15.5 11',
  user: 'M12 12 C9.5 12 8 10.2 8 7.8 C8 5.4 9.6 3.5 12 3.5 C14.4 3.5 16 5.4 16 7.8 C16 10.2 14.5 12 12 12 Z M4.5 20.5 C4.5 16.5 8 14.5 12 14.5 C16 14.5 19.5 16.5 19.5 20.5',
  chat: 'M4 5 L20 5 L20 16 L11 16 L6.5 20 L6.5 16 L4 16 Z', bell: 'M6 17 L6 11 C6 7 8.5 4.5 12 4.5 C15.5 4.5 18 7 18 11 L18 17 L20 18.5 L4 18.5 Z M10 20.5 L14 20.5',
  chart: 'M4 20 L20 20 M6.5 20 L6.5 13 M11 20 L11 8 M15.5 20 L15.5 11 M20 20 L20 5', clock: 'M12 3.5 C16.7 3.5 20.5 7.3 20.5 12 C20.5 16.7 16.7 20.5 12 20.5 C7.3 20.5 3.5 16.7 3.5 12 C3.5 7.3 7.3 3.5 12 3.5 Z M12 7 L12 12 L15.5 14',
  globe: 'M12 3.5 C16.7 3.5 20.5 7.3 20.5 12 C20.5 16.7 16.7 20.5 12 20.5 C7.3 20.5 3.5 16.7 3.5 12 C3.5 7.3 7.3 3.5 12 3.5 Z M3.5 12 L20.5 12 M12 3.5 C8.5 7.5 8.5 16.5 12 20.5 M12 3.5 C15.5 7.5 15.5 16.5 12 20.5',
  search: 'M10.5 4 C14.1 4 17 6.9 17 10.5 C17 14.1 14.1 17 10.5 17 C6.9 17 4 14.1 4 10.5 C4 6.9 6.9 4 10.5 4 Z M15.2 15.2 L20 20',
  code: 'M8.5 7 L3.5 12 L8.5 17 M15.5 7 L20.5 12 L15.5 17 M13.5 4.5 L10.5 19.5', cursor: 'M5 3.5 L5 18.5 L9 14.5 L11.8 20.5 L14.3 19.3 L11.6 13.5 L17 13.5 Z',
  spark: 'M12 2.5 C12.6 8.5 15.5 11.4 21.5 12 C15.5 12.6 12.6 15.5 12 21.5 C11.4 15.5 8.5 12.6 2.5 12 C8.5 11.4 11.4 8.5 12 2.5 Z',
  trendUp: 'M3.5 17 L9.5 11 L13.5 15 L20.5 8 M15.5 8 L20.5 8 L20.5 13', dollar: 'M16.5 7 C15.5 5.5 14 5 12 5 C9.5 5 7.5 6.2 7.5 8.3 C7.5 13 16.5 10.8 16.5 15.6 C16.5 17.8 14.4 19 12 19 C9.8 19 8.2 18.3 7.2 16.8 M12 2.5 L12 21.5',
  mail: 'M3.5 6 L20.5 6 L20.5 18 L3.5 18 Z M3.5 6.5 L12 13 L20.5 6.5', eye: 'M2.5 12 C5 7 8.5 5 12 5 C15.5 5 19 7 21.5 12 C19 17 15.5 19 12 19 C8.5 19 5 17 2.5 12 Z M12 9 C13.7 9 15 10.3 15 12 C15 13.7 13.7 15 12 15 C10.3 15 9 13.7 9 12 C9 10.3 10.3 9 12 9 Z',
};
const _iconPaths = {};
/** icon('check', x, y, size, {color, lw, fill, u}) — (x, y) is the centre. u draws it on (0..1). */
function icon(name, x, y, size, o = {}) {
  const k = size / 24;
  if (o.u != null && o.u < 1) { const polys = (_iconPaths[name + ':pts'] ||= pathD(ICONS[name]).map((p) => resample(p, false, 0.4))); ctx.save(); ctx.strokeStyle = o.color || '#fff'; ctx.lineWidth = (o.lw ?? 1.9) * k; polys.forEach((p) => drawOn(p.map(([px, py]) => [x + (px - 12) * k, y + (py - 12) * k]), o.u, o.color || '#fff', (o.lw ?? 1.9) * k)); ctx.restore(); return; }
  const p = (_iconPaths[name] ||= new Path2D(ICONS[name]));
  ctx.save(); ctx.translate(x - 12 * k, y - 12 * k); ctx.scale(k, k);
  if (o.alpha != null) ctx.globalAlpha *= o.alpha;
  if (o.fill) { ctx.fillStyle = o.fill; ctx.fill(p); }
  ctx.strokeStyle = o.color || '#ffffff'; ctx.lineWidth = o.lw ?? 1.9; ctx.stroke(p); ctx.restore();
}

// ---------------------------------------------------------------- faces (ink-style characters)
/**
 * face(x, y, size, mood, o) — expressive cartoon face centred at (x, y); size ≈ distance between the eyes × 2.
 * moods: 'happy' 'joy' 'calm' 'wired' 'tired' 'shocked' 'angry' 'smug' 'sad' 'wink' 'dizzy' 'determined' 'sleep'
 * o: color (ink), lw, blush (hex or false), look ([-1..1, -1..1] pupil direction), id (boil seed), talk (0..1 mouth open)
 */
function face(x, y, size, mood = 'happy', o = {}) {
  const c = o.color || '#2e1a1b', lw = o.lw ?? size * 0.07, ex = size * 0.36, ey = -size * 0.08, er = size * 0.075, id = o.id || 'face';
  const lk = o.look || [0, 0], S = (pts) => strokePts(wob(pts, false, bseed(id + pts.length), size * 0.012, size * 0.3), c, lw);
  const dot = (cx, cy, r) => circle(cx + lk[0] * er * 0.5, cy + lk[1] * er * 0.5, r, c);
  const arc = (cx, cy, r, a0, a1, n = 10) => { const p = []; for (let i = 0; i <= n; i++) { const a = lerp(a0, a1, i / n); p.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); } return p; };
  ctx.save(); ctx.translate(x, y); ctx.lineCap = 'round'; ctx.lineJoin = 'round';
  const eyes = { happy: 'dot', joy: 'arcUp', calm: 'arcDown', wired: 'wide', tired: 'half', shocked: 'wide', angry: 'dot', smug: 'half', sad: 'dot', wink: 'wink', dizzy: 'x', determined: 'dot', sleep: 'arcDown' }[mood] || 'dot';
  [-1, 1].forEach((sd) => {
    const cx = sd * ex, cy = ey;
    if (eyes === 'dot') dot(cx, cy, er);
    else if (eyes === 'arcUp') S(arc(cx, cy + er * 0.6, er * 1.3, Math.PI * 1.15, Math.PI * 1.85));
    else if (eyes === 'arcDown') S(arc(cx, cy - er * 0.6, er * 1.3, Math.PI * 0.15, Math.PI * 0.85));
    else if (eyes === 'wide') { S(ellipse(cx, cy, er * 2, er * 2.2, 20).concat([ellipse(cx, cy, er * 2, er * 2.2, 20)[0]])); dot(cx, cy, er * (mood === 'wired' ? 0.55 : 0.8)); }
    else if (eyes === 'half') { S([[cx - er * 1.6, cy], [cx + er * 1.6, cy]]); dot(cx, cy + er * 0.5, er * 0.8); }
    else if (eyes === 'wink') { if (sd < 0) dot(cx, cy, er); else S(arc(cx, cy + er * 0.6, er * 1.3, Math.PI * 1.15, Math.PI * 1.85)); }
    else if (eyes === 'x') { S([[cx - er, cy - er], [cx + er, cy + er]]); S([[cx + er, cy - er], [cx - er, cy + er]]); }
    // brows
    const b = { angry: [0.35, 1], determined: [0.22, 1], sad: [-0.35, 1], shocked: [0, 1.6], wired: [0, 1.5], smug: [0.15, 1] }[mood];
    if (b) { const by = cy - er * 2.3 * b[1], tilt = -b[0] * sd; S([[cx - er * 1.8, by - tilt * er * 1.8], [cx + er * 1.8, by + tilt * er * 1.8]]); }
  });
  const my = size * 0.22, mw = size * 0.22, talk = clamp(o.talk ?? 0);
  if (talk > 0.05 || mood === 'shocked') { const h = mood === 'shocked' ? mw * 0.9 : mw * talk; fillPts(ellipse(0, my, mw * 0.55, h, 18), c); }
  else if (mood === 'happy' || mood === 'wink') S(arc(0, my - mw * 0.6, mw * 0.9, Math.PI * 0.2, Math.PI * 0.8));
  else if (mood === 'joy') { const p = arc(0, my - mw * 0.5, mw, 0.05 * Math.PI, 0.95 * Math.PI, 14); fillPts(p, c); }
  else if (mood === 'sad' || mood === 'tired') S(arc(0, my + mw * 0.8, mw * 0.8, Math.PI * 1.2, Math.PI * 1.8));
  else if (mood === 'angry' || mood === 'determined' || mood === 'calm') S([[-mw * 0.6, my], [mw * 0.6, my + (mood === 'angry' ? mw * 0.1 : 0)]]);
  else if (mood === 'smug') S(qbez([-mw * 0.6, my + mw * 0.1], [mw * 0.1, my + mw * 0.3], [mw * 0.7, my - mw * 0.25]));
  else if (mood === 'wired') { const p = []; for (let i = 0; i <= 6; i++) p.push([lerp(-mw * 0.8, mw * 0.8, i / 6), my + (i % 2 ? -1 : 1) * mw * 0.18]); S(p); }
  else if (mood === 'dizzy') S(arc(0, my, mw * 0.5, 0, Math.PI * 1.7, 14));
  else if (mood === 'sleep') S([[-mw * 0.35, my], [mw * 0.35, my]]);
  if (o.blush !== false && ['happy', 'joy', 'wink', 'calm', 'smug', 'sleep'].includes(mood)) [-1, 1].forEach((sd) => circle(sd * ex * 1.25, ey + er * 3, er * 1.4, o.blush || '#e89a8a', 0.55));
  ctx.restore();
}

// ---------------------------------------------------------------- audio-reactive look (deterministic)
/** waveform(x, y, w, h, t, o): animated equaliser bars centred on y. o: bars, color, energy (0..1 or fn(t)), gap, r, id */
function waveform(x, y, w, h, t, o = {}) {
  const n = o.bars ?? 32, gap = o.gap ?? 0.35, bw = w / (n + (n - 1) * gap), en = typeof o.energy === 'function' ? o.energy(t) : (o.energy ?? 1), sd = seedOf(o.id || 'wave');
  for (let i = 0; i < n; i++) {
    const v = (0.25 + 0.75 * vnoise(t * 6 + i * 0.37, sd)) * (0.55 + 0.45 * Math.sin(i / n * Math.PI)) * en, bh = Math.max(bw, h * v);
    roundRect(x + i * bw * (1 + gap), y - bh / 2, bw, bh, bw / 2, o.color || '#ffffff');
  }
}

// ---------------------------------------------------------------- charts (explainer building blocks)
/** bars(x, y, w, h, values, u, o): bottom-left at (x, y+h). values 0..max. Each bar grows in order. */
function barsChart(x, y, w, h, values, u, o = {}) {
  const n = values.length, gap = o.gap ?? 0.28, bw = w / (n + (n - 1) * gap), max = o.max ?? Math.max(...values);
  values.forEach((v, i) => {
    const p = (o.ease || eOutQuint)(clamp(u * (1 + (n - 1) * 0.25) - i * 0.25)), bh = h * (v / max) * p, bx = x + i * bw * (1 + gap);
    roundRect(bx, y + h - bh, bw, bh, Math.min(o.r ?? 10 * U, bw / 2, bh / 2 || 0.01), (o.colors && o.colors[i]) || o.color || '#ffffff');
  });
}
/** line chart through values, drawn on with u */
function lineChart(x, y, w, h, values, u, o = {}) {
  const max = o.max ?? Math.max(...values), min = o.min ?? Math.min(0, ...values);
  const pts = values.map((v, i) => [x + (i / (values.length - 1)) * w, y + h - (v - min) / (max - min) * h]);
  const sm = resample(pts, false, 3 * U);
  if (o.fill) { const part = partial(sm, u); ctx.save(); tracePath([...part, [part[part.length - 1][0], y + h], [x, y + h]], true); ctx.fillStyle = o.fill; ctx.fill(); ctx.restore(); }
  drawOn(sm, u, o.color || '#ffffff', o.lw ?? 6 * U);
  if (o.dot !== false && u > 0) { const e = partial(sm, u).pop(); circle(e[0], e[1], (o.lw ?? 6 * U) * 1.6, o.color || '#ffffff'); }
  return pts;
}
/** donut(x, y, r, frac, u, o) — frac 0..1 filled, animated by u */
function donut(x, y, r, frac, u, o = {}) {
  const lw = o.lw ?? r * 0.22;
  ringStroke(x, y, r, o.track || 'rgba(255,255,255,0.12)', lw, 1);
  ringStroke(x, y, r, o.color || '#ffffff', lw, frac * (o.ease || eOutQuint)(clamp(u)));
}

// ---------------------------------------------------------------- user images (logos, product shots)
const IMG = {};
/** in setup(): await loadImg('logo', 'assets/logo.png'). Only local files inside the project. */
function loadImg(name, src) { return new Promise((res, rej) => { const im = new Image(); im.onload = () => { IMG[name] = im; res(im); }; im.onerror = () => rej(new Error('could not load ' + src)); im.src = src; }); }
/** image(name, x, y, w, o): draw centred at (x, y) with width w (height keeps aspect). o: alpha, rot, h */
function image(name, x, y, w, o = {}) {
  const im = IMG[name]; if (!im) throw new Error('image not loaded: ' + name);
  const h = o.h ?? w * im.height / im.width;
  ctx.save(); ctx.translate(x, y); if (o.rot) ctx.rotate(o.rot); if (o.alpha != null) ctx.globalAlpha *= clamp(o.alpha);
  ctx.drawImage(im, -w / 2, -h / 2, w, h); ctx.restore();
}
/** stable pick from an array by id */
function pick(arr, ...id) { return arr[Math.floor(h01(...id) * arr.length) % arr.length]; }

// ---------------------------------------------------------------- textures + post
const TEX = {};
function makeCanvas(w, h) { const c = document.createElement('canvas'); c.width = w; c.height = h; return c; }
/** a static grain/mottle texture (neutral grey 128) blended with soft-light in post() */
function buildGrain() {
  const s = 2, w = Math.ceil(W / s), h = Math.ceil(H / s), c = makeCanvas(w, h), g = c.getContext('2d'), id = g.createImageData(w, h), d = id.data, r = rng('grain');
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) { const v = 128 + (vnoise2(x / 130, y / 130, 11) - 0.5) * 14 + (r() - 0.5) * 26, i = (y * w + x) * 4; d[i] = d[i + 1] = d[i + 2] = v; d[i + 3] = 255; }
  g.putImageData(id, 0, 0); TEX.grain = c;
}
/** paper(base) -> a mottled paper canvas (built once per colour), for the ink style */
function paperTex(base = '#e9e5da') {
  const key = 'paper' + base; if (TEX[key]) return TEX[key];
  const s = 2, w = Math.ceil(W / s), h = Math.ceil(H / s), c = makeCanvas(w, h), g = c.getContext('2d'), id = g.createImageData(w, h), d = id.data, b = rgb(base), r = rng('paper');
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) { const m = (vnoise2(x / 60, y / 60, 21) - 0.5) * 12 + (vnoise2(x / 18, y / 18, 22) - 0.5) * 5 + (r() - 0.5) * 3, i = (y * w + x) * 4; d[i] = b[0] + m; d[i + 1] = b[1] + m; d[i + 2] = b[2] + m - 1; d[i + 3] = 255; }
  g.putImageData(id, 0, 0); g.lineCap = 'round';
  for (let i = 0; i < w * h / 700; i++) { const x = r() * w, y = r() * h, L = 1 + r() * 4, a = r() * TAU; g.strokeStyle = `rgba(90,80,70,${0.12 + r() * 0.25})`; g.lineWidth = 0.4 + r() * 0.4; g.beginPath(); g.moveTo(x, y); g.lineTo(x + Math.cos(a) * L, y + Math.sin(a) * L); g.stroke(); }
  return (TEX[key] = c);
}
function drawPaper(base) { const c = paperTex(base); ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.drawImage(c, 0, 0, W, H); ctx.restore(); }
/** grain + vignette, applied after frame() when FILM.grain / FILM.vignette > 0 */
function post() {
  ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0);
  if (FILM.grain > 0) {
    if (!TEX.grain) buildGrain();
    const ox = FILM.grainMoves === false ? 0 : Math.floor(h01('gx', CLK.BOIL) * 40), oy = FILM.grainMoves === false ? 0 : Math.floor(h01('gy', CLK.BOIL) * 40);
    ctx.globalCompositeOperation = 'soft-light'; ctx.globalAlpha = FILM.grain; ctx.drawImage(TEX.grain, -ox, -oy, W + 40, H + 40);
  }
  if (FILM.vignette > 0) {
    ctx.globalCompositeOperation = 'source-over'; ctx.globalAlpha = 1;
    ctx.fillStyle = radGrad(CX, CY, Math.min(W, H) * 0.35, Math.hypot(W, H) * 0.6, [[0, 'rgba(0,0,0,0)'], [1, `rgba(0,0,0,${FILM.vignette})`]]);
    ctx.fillRect(0, 0, W, H);
  }
  ctx.restore();
}

// ---------------------------------------------------------------- boot
function renderFrame(n) {
  setClock(n);
  ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.globalAlpha = 1; ctx.globalCompositeOperation = 'source-over'; ctx.filter = 'none';
  ctx.fillStyle = FILM.bg; ctx.fillRect(0, 0, W, H);
  window.frame(CLK.T, n);
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  if (FILM.grain > 0 || FILM.vignette > 0) post();
}
async function loadFonts(base) {
  await Promise.all(FONT_FILES.map(async ([family, file, weight, style]) => {
    const f = new FontFace(family, `url(${base}${file})`, { weight: String(weight), style: style || 'normal' });
    document.fonts.add(await f.load());
  }));
}
async function boot() {
  canvas = document.getElementById('c'); canvas.width = W; canvas.height = H;
  setCtx(canvas.getContext('2d', { alpha: false }));
  await loadFonts('engine/fonts/');
  if (typeof window.frame !== 'function') throw new Error('film/scenes.js must define function frame(t)');
  if (typeof window.setup === 'function') await window.setup();
  if (FILM.grain > 0) buildGrain();
}
window.__safe = { x0: SAFE.x0, y0: SAFE.y0, x1: SAFE.x1, y1: SAFE.y1 };
window.__reel = { frames: FRAMES, fps: FPS, w: W, h: H, seconds: DUR, renderFrame: (n) => renderFrame(n), audioWav: () => (window.audioWav ? window.audioWav() : null) };
window.__reelReady = new Promise((res, rej) => window.addEventListener('load', () => boot().then(res, rej)));
