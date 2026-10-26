'use strict';
// CUP FIVE SAYS NOPE: the Motion Director hand-drawn ink example (square, 15 s, 112 BPM = 7 bars of 2.14 s).
// Cups #1-#4 get filled one per beat, each more wired than the last. Cup #5 dodges the pot twice,
// then backflips and lands upside down: closed. "#5" gets scribbled out and "NOPE." writes itself on.
//
// How this file is built (copy the pattern):
// - C is the whole palette. S is every story moment on the beat grid (bars()/beats()); no other time is hard-coded.
// - score.js reads S, POURS, HOP1, HOP2 directly (one shared global scope), so every sound lands on its picture event.
// - QC_AT lists the fast moments (backflip, landing) that the evenly spaced QC sheet would otherwise miss.
// - One continuous set, so the actors (cups, pot) are timelines keyed to S, while one-off beats are
//   scene functions that take local time (lt = t - S.x).
// - Character motion reads CLK.TA (it steps on twos: the hand-drawn cadence); camera, shake and flash read t.

const C = {
  paper: '#ebe3d2', ink: '#2e1a1b', white: '#fffaf0',
  cup: '#f8f1e2', cupHi: '#ffffff', cupLo: '#a8977c', inside: '#d6c6a8', band: '#d2725a', tongue: '#e0706a',
  pot: '#d9a528', potHi: '#f4d27a', potLo: '#95660f',
  coffee: '#5a3220', crema: '#b07445',
  table: '#c8996a', tableHi: '#e6c196', tableLo: '#7f5534', apron: '#a8784f',
  accent: '#d2725a',
};

// ---------------------------------------------------------------- the beat grid (BEAT 0.536 s, BAR 2.143 s)
const S = {
  arrive: bars(1), alarm: bars(1) + beats(1), dodge1: bars(1) + beats(2), smirk: bars(1) + beats(3),
  chase: bars(2), dodge2: bars(2) + beats(1), fume: bars(2) + beats(2), chase2: bars(2) + beats(3),
  build: bars(3), hush: bars(3) + beats(2.6), launch: bars(3) + beats(3),
  drop: bars(4), strike: bars(4) + beats(1), sulk: bars(4) + beats(2), exit: bars(4) + beats(3),
  nope: bars(5), end: bars(6),
};
const HOP1 = [S.dodge1 + 0.03, S.dodge1 + beats(0.5)], HOP2 = [S.dodge2 + 0.03, S.dodge2 + beats(0.75)], FLIGHT = [S.launch, S.drop];
const QC_AT = [S.alarm + 0.1, HOP2[0] + 0.12, S.hush - 0.05, S.launch + 0.2, S.launch + 0.4, S.drop + 0.05, S.strike + 0.3, S.end + 0.2];

// ---------------------------------------------------------------- layout (all in U)
const TABLE = H * 0.8, TABLE_BACK = H * 0.765, TABLE_FRONT = H * 0.875;   // where things stand, table edges
const XC = CX, XL = W * 0.24, XR = W * 0.62;                                // the three spots cup #5 visits
const CUPH = 210 * U, CUPT = 112 * U, CUPB = 86 * U, CUPRY = 24 * U;        // mug height, top/bottom half-widths, rim ellipse
const POUR = -0.62, POTY = 250 * U, POT_DX = 205 * U, SPOUT = [-180 * U, -72 * U];   // pot tilt when pouring; pot sits POT_DX right of its target
const LEAP = 230 * U, SLOT = 400 * U, FALL_T = beats(0.5), FALL_C = 0.2;       // backflip height; conveyor spacing; stream fall time to the table / into a mug

// every pour: spout open from a to b, landing at x; `cup` = the conveyor mug it fills (no cup = it misses, onto the table)
const POURS = [
  { a: -0.4, b: beats(1) - 0.25, x: XC, cup: 0 },
  { a: beats(1) + 0.03, b: beats(2) - 0.25, x: XC, cup: 1 },
  { a: beats(2) + 0.03, b: beats(3) - 0.25, x: XC, cup: 2 },
  { a: beats(3) + 0.03, b: beats(4) - 0.25, x: XC, cup: 3 },
  { a: S.dodge1 + 0.06, b: S.smirk, x: XC },
  { a: S.dodge2 + 0.06, b: S.fume, x: XR },
];
const CONVEYOR = [{ mood: 'happy', jit: 0 }, { mood: 'joy', jit: 1.2 }, { mood: 'wired', jit: 3.5 }, { mood: 'dizzy', jit: 7 }];

// ---------------------------------------------------------------- helpers
const moodAt = (tab, ta) => tab.reduce((m, e) => (ta >= e[0] ? e : m), tab[0]);
const wobble = (d) => (d < 0 ? 0 : Math.exp(-d * 8) * Math.cos(d * 32));           // decaying squash after a landing
const inkLine = (pts, col, lw, id) => strokePts(wob(pts, false, bseed(id), 1.3 * U, 30 * U), col, lw);
const arcPts = (w, y, bulge) => Array.from({ length: 23 }, (_, i) => { const x = -1.1 * w + 2.2 * w * i / 22, k = clamp(x / w, -1, 1); return [x, y + bulge * Math.sqrt(1 - k * k)]; });
function conveyor(ta) { let p = 0; for (let k = 1; k <= 4; k++) p += eInOutQ(seg(ta, beats(k) - 0.2, beats(k))); return p; }   // slots moved so far
function conveyorLean(ta) { let v = 0; for (let k = 1; k <= 4; k++) v += Math.sin(Math.PI * seg(ta, beats(k) - 0.2, beats(k) + 0.05)); return v; }

// ---------------------------------------------------------------- the mug (geometry built once, centred on (0,0))
const MUG = (() => {
  const h = CUPH, t = CUPT, b = CUPB, y0 = -h / 2, y1 = h / 2, c = 8 * U;
  const back = Array.from({ length: 15 }, (_, i) => { const a = -(i + 1) / 16 * Math.PI; return [t * Math.cos(a), y0 + CUPRY * Math.sin(a)]; });
  const body = [...bez([-t, y0], [-t * 0.99, y0 + h * 0.5], [-b * 1.04, y1 - h * 0.16], [-b, y1 - c], 12),
    ...bez([-b, y1 - c], [-b * 0.55, y1 + CUPRY * 0.7], [b * 0.55, y1 + CUPRY * 0.7], [b, y1 - c], 12).slice(1),
    ...bez([b, y1 - c], [b * 1.04, y1 - h * 0.16], [t * 0.99, y0 + h * 0.5], [t, y0], 12).slice(1), ...back];
  const bandW = lerp(t, b, (64 * U + h / 2) / h);
  return {
    body, rim: ellipse(0, y0, t, CUPRY, 40), foot: ellipse(0, y1 - 6 * U, b * 0.98, CUPRY * 0.8, 32), footIn: ellipse(0, y1 - 6 * U, b * 0.66, CUPRY * 0.5, 28),
    handle: bez([t * 0.9, y0 + h * 0.2], [t + 82 * U, y0 + h * 0.08], [t + 74 * U, y0 + h * 0.78], [b, y0 + h * 0.76], 14),
    band: arcPts(bandW, 64 * U, CUPRY * 0.8), bandInv: arcPts(bandW, 64 * U, -CUPRY * 0.8),   // upside down, the band still bulges toward us
    tongue: xform(pathD('M-10 0 Q-12 22 0 22 Q12 22 10 0')[0], 0, 27 * U, U),
  };
})();
// o: {id, n, x, y (centre), rot, sx, sy, fill 0..1, mood, look, jit, inv (upside down, drawn as rot π), blush, tongue}
function drawMug(o) {
  const j = o.jit || 0, rot = (o.rot || 0) + (j ? snoise(CLK.TA * 19, o.n + 7) * j * 0.007 : 0), lit = lightFor(rot);
  withT({ x: o.x + (j ? snoise(CLK.TA * 23, o.n) * j * U : 0), y: o.y, rot }, () => withT({ sx: o.sx ?? 1, sy: o.sy ?? 1 }, () => {
    const hs = bseed(o.id + 'h');
    ink(MUG.handle, { closed: false, stroke: C.ink, lw: 32 * U, seed: hs });
    ink(MUG.handle, { closed: false, stroke: C.cup, lw: 18 * U, seed: hs });
    ink(MUG.body, { id: o.id + 'b', fill: C.cup, hatch: hatchSet(0, 0, 125 * U, C.cupHi, C.cupLo, lit), stroke: C.ink, lw: 6 * U, fx: () => strokePts(o.inv ? MUG.bandInv : MUG.band, C.band, 22 * U) });
    if (o.inv) {
      ink(MUG.foot, { id: o.id + 'f', fill: C.cup, stroke: C.ink, lw: 5 * U });
      ink(MUG.footIn, { id: o.id + 'fi', stroke: C.ink, lw: 3 * U });
    } else ink(MUG.rim, { id: o.id + 'r', fill: C.inside, stroke: C.ink, lw: 6 * U, fx: () => {
      hatchShadow(0, -CUPH / 2 - 6 * U, CUPT * 0.9, CUPRY * 0.7, C.ink, 0.3, o.id + 'in');
      const f = o.fill || 0; if (f < 0.02) return;
      const cy = -CUPH / 2 + (1 - f) * CUPRY * 1.5 + 2 * U, rx = CUPT * (0.95 - (1 - f) * 0.25);
      ink(ellipse(0, cy, rx, CUPRY * 0.9, 32), { id: o.id + 'c', fill: C.coffee, boil: 0.8 * U });
      fillPts(ellipse(-rx * 0.25, cy - 3 * U, rx * 0.38, CUPRY * 0.28, 18), C.crema, 0.6);
    } });
    withT(o.inv ? { y: -16 * U, rot: Math.PI } : { y: -12 * U }, () => {           // upside down, the face stays upright
      face(0, 0, 118 * U, o.mood, { id: o.id + 'face', look: o.look, blush: o.blush });
      if (o.tongue) ink(MUG.tongue, { id: o.id + 't', fill: C.tongue, stroke: C.ink, lw: 4 * U, boil: 0.8 * U });
    });
  }));
}

// ---------------------------------------------------------------- the pot (a mustard enamel coffee pot with a face)
const POT = (() => {
  const P = (x, y) => [x * U, y * U];
  return {
    body: [...bez(P(-70, -92), P(-80, -20), P(-112, 40), P(-108, 88), 12), ...bez(P(-108, 88), P(-60, 116), P(60, 116), P(108, 88), 12).slice(1),
      ...bez(P(108, 88), P(112, 40), P(80, -20), P(70, -92), 12).slice(1), ...qbez(P(70, -92), P(0, -104), P(-70, -92), 10).slice(1, -1)],
    lid: [...bez(P(-80, -90), P(-72, -142), P(72, -142), P(80, -90), 16), ...qbez(P(80, -90), P(0, -80), P(-80, -90), 10).slice(1, -1)],
    spout: [...bez(P(-96, 72), P(-150, 62), P(-160, 0), P(-190, -64), 14), ...qbez(P(-190, -64), P(-184, -80), P(-168, -72), 4).slice(1),
      ...bez(P(-168, -72), P(-142, -14), P(-128, 22), P(-86, 22), 14).slice(1)],
    handle: bez(P(64, -62), P(162, -84), P(178, 44), P(100, 62), 16),
    stripe: arcPts(110 * U, 64 * U, 14 * U), knob: circlePts(0, -142 * U, 15 * U, 16),
  };
})();
function drawPot(p) {
  const lit = lightFor(p.rot);
  withT({ x: p.x, y: p.y, rot: p.rot }, () => {
    const hs = bseed('pot-h');
    ink(POT.handle, { closed: false, stroke: C.ink, lw: 34 * U, seed: hs });
    ink(POT.handle, { closed: false, stroke: C.pot, lw: 20 * U, seed: hs });
    ink(POT.spout, { id: 'pot-s', fill: C.pot, hatch: hatchSet(-140 * U, 0, 70 * U, C.potHi, C.potLo, lit), stroke: C.ink, lw: 6 * U });
    ink(POT.body, { id: 'pot-b', fill: C.pot, hatch: hatchSet(0, 0, 130 * U, C.potHi, C.potLo, lit), stroke: C.ink, lw: 6 * U, fx: () => strokePts(POT.stripe, C.cup, 16 * U) });
    ink(POT.lid, { id: 'pot-l', fill: C.pot, hatch: hatchSet(0, -112 * U, 70 * U, C.potHi, C.potLo, lit), stroke: C.ink, lw: 6 * U });
    ink(POT.knob, { id: 'pot-k', fill: C.ink, stroke: C.ink, lw: 4 * U });
    face(-6 * U, -14 * U, 108 * U, p.mood, { id: 'pot-face', look: p.look });
  });
}

// ---------------------------------------------------------------- actor timelines (absolute time, keyed to S)
const POT_X = [[0, XC + POT_DX], [S.chase, XC + POT_DX], [S.chase + 0.3, XR + POT_DX, eInOutExpo], [S.chase2, XR + POT_DX], [S.chase2 + 0.3, XL + POT_DX, eInOutExpo], [S.launch + 0.1, XL + POT_DX], [S.launch + 0.4, XL + POT_DX + 120 * U, eOutBack]];   // recoils as the mug flips past
const POT_Y = [[0, POTY], [S.build, POTY], [S.hush, POTY + 40 * U, eInOutSine], [S.launch + 0.1, POTY + 40 * U], [S.launch + 0.4, POTY - 20 * U, eOutBack], [S.exit, POTY - 20 * U], [S.exit + 0.12, POTY + 10 * U, eOut], [S.exit + 0.5, -420 * U, eInExpo]];
const POT_R = [
  [0, POUR], [S.arrive - 0.22, POUR], [S.arrive + 0.08, -0.06, eOutBack],                                   // conveyor done: sits up
  [S.alarm, -0.06], [S.alarm + 0.2, -0.36, eOutBack], [S.dodge1 - 0.06, -0.36], [S.dodge1 + 0.02, POUR, eOutQuint], [S.smirk, POUR], [S.smirk + 0.16, -0.08, eOutBack],
  [S.chase, -0.08], [S.chase + 0.15, 0.12], [S.chase + 0.32, -0.3, eOutBack], [S.dodge2 - 0.06, -0.3], [S.dodge2 + 0.02, POUR, eOutQuint], [S.fume, POUR], [S.fume + 0.16, 0.06, eOutBack],
  [S.chase2, 0.06], [S.chase2 + 0.15, -0.14], [S.chase2 + 0.32, -0.22, eOutBack], [S.hush, -0.34, eInOutSine], [S.launch, -0.34], [S.launch + 0.08, POUR, eOutQuint],
  [S.launch + 0.2, POUR], [S.launch + 0.45, -0.05, eOutBack], [S.sulk, -0.05], [S.sulk + 0.25, 0.14, eOutBack],
];
const POT_MOODS = [[0, 'happy', [-0.5, 0.8]], [S.alarm, 'determined', [-0.6, 0.8]], [S.smirk + 0.1, 'angry', [-0.3, 1]], [S.build, 'determined', [-0.8, 0.8]], [S.launch + 0.1, 'shocked', [-0.5, 1]], [S.sulk, 'sad', [-0.4, 1]]];
function potAt(ta) {
  const x = keys(ta, POT_X) + snoise(ta * 34, 8) * 7 * U * inout(ta, S.fume + 0.1, S.chase2, 0.05, 0.1)   // fuming shake
    + (ta < S.hush ? snoise(ta * 40, 9) * 3.5 * U * seg(ta, S.build + 0.3, S.hush) : 0);                  // trembling on the build
  const y = keys(ta, POT_Y) + snoise(ta * 1.3, 5) * 5 * U;
  const rot = keys(ta, POT_R) + (ta < S.arrive - 0.22 ? 0.04 * Math.sin(Math.PI * (ta % BEAT) / BEAT) : 0); // glug bob
  const c = Math.cos(rot), s = Math.sin(rot), m = moodAt(POT_MOODS, ta);
  return { x, y, rot, mood: m[1], look: m[2], tip: [x + SPOUT[0] * c - SPOUT[1] * s, y + SPOUT[0] * s + SPOUT[1] * c] };
}

const HERO_MOODS = [
  [0, 'sad', [-1, 0]], [S.arrive, 'happy', [0, 0]], [S.alarm, 'shocked', [0.4, -1]], [HOP1[1], 'smug', [0.6, -0.4]],
  [S.chase + 0.12, 'shocked', [0.4, -1]], [HOP2[1], 'wink', [0, 0]], [S.chase2 + 0.2, 'smug', [1, -0.2]],
  [S.build, 'determined', [0.5, -0.5]], [S.launch, 'joy', [0, 0]], [S.drop, 'smug', [0, 0]], [S.end, 'wink', [0, 0]], [S.end + 0.7, 'smug', [0, 0]],
];
function heroAt(ta) {
  let x = XC, lift = 0, rot = 0, k = 0, inv = false, fly = -1;
  const hop = (u, height, lean) => { lift = Math.sin(Math.PI * u) * height; k = -0.1 * Math.sin(Math.PI * u); rot = lean * Math.sin(Math.PI * u); };
  if (ta < S.arrive) { x = XC + (4 - conveyor(ta)) * SLOT; rot = 0.1 * conveyorLean(ta); }             // rides the conveyor in
  else if (ta < HOP2[0]) { const u = seg(ta, HOP1[0], HOP1[1]); x = lerp(XC, XR, eOutQuint(u)); hop(u, 120 * U, 0.2); }
  else if (ta < FLIGHT[0]) { const u = seg(ta, HOP2[0], HOP2[1]); x = lerp(XR, XL, eOut(u)); hop(u, 230 * U, -0.25); }
  else {                                                                                                   // the backflip: 1.5 turns, lands upside down
    const u = seg(ta, FLIGHT[0], FLIGHT[1]), e = eInOutSine(u);
    x = lerp(XL, XC, e); hop(u, LEAP, 0); rot = -3 * Math.PI * e; inv = ta >= S.drop; fly = u;
  }
  k += 0.09 * wobble(ta - S.arrive) + 0.16 * wobble(ta - HOP1[1]) + 0.2 * wobble(ta - HOP2[1]) + 0.32 * wobble(ta - S.drop);
  k += 0.12 * sstep(HOP1[0] - 0.12, HOP1[0] - 0.03, ta) * (1 - sstep(HOP1[0] - 0.03, HOP1[0] + 0.03, ta));  // crouch before each hop
  k += 0.12 * sstep(HOP2[0] - 0.14, HOP2[0] - 0.03, ta) * (1 - sstep(HOP2[0] - 0.03, HOP2[0] + 0.03, ta));
  if (ta < S.launch) k += 0.2 * eInOutSine(seg(ta, S.build + 0.5, S.hush));                                // the big crouch
  if (ta > S.arrive && ta < S.end && lift === 0) k += 0.02 * Math.sin(TAU * ta / BEAT);                  // breathes on the beat
  const m = moodAt(HERO_MOODS, ta), sy = 1 - k;
  return { id: 'hero', n: 5, x, y: TABLE - (CUPH / 2) * sy - lift, rot: inv ? Math.PI : rot, sx: 1 + k, sy, inv, lift, fly,
    mood: m[1], look: m[2], blush: ta >= S.drop, tongue: ta >= HOP2[1] && ta < S.chase2 + 0.2 };
}

// ---------------------------------------------------------------- set pieces
function drawTable() {                                          // wood top with long grain, darker hatched front
  const X0 = -800 * U, X1 = W + 800 * U;
  ink([[X0, TABLE_BACK], [X1, TABLE_BACK], [X1, TABLE_FRONT], [X0, TABLE_FRONT]], { id: 'table-top', fill: C.table, stroke: C.ink, lw: 6 * U,
    hatch: [{ id: 'grain', color: C.tableHi, alpha: 0.55, ang: -3, gap: 10 * U, len: [40 * U, 120 * U], lw: 2 * U, dens: 0.5 }, { id: 'grain2', color: C.tableLo, alpha: 0.25, ang: 2, gap: 14 * U, len: [30 * U, 90 * U], lw: 1.6 * U, dens: 0.35 }] });
  ink([[X0, TABLE_FRONT], [X1, TABLE_FRONT], [X1, H + 300 * U], [X0, H + 300 * U]], { id: 'table-front', fill: C.apron, stroke: C.ink, lw: 6 * U,
    hatch: [{ id: 'front', color: C.tableLo, alpha: 0.42, ang: 58, gap: 7 * U, len: [12 * U, 30 * U], lw: 1.6 * U, dens: 0.8 }] });
}
function drawPuddles(ta) {                                      // small stains where the pot missed
  POURS.forEach((pr, i) => {
    if (pr.cup != null || ta < pr.a + FALL_T) return;
    const g = eOutQuint(seg(ta, pr.a + FALL_T, pr.b + FALL_T + 0.2)), rx = (26 + 50 * g) * U, ry = rx * 0.2;
    ink(ellipse(pr.x, TABLE + 22 * U, rx, ry, 28), { id: 'puddle' + i, fill: C.coffee, stroke: C.ink, lw: 4 * U, boil: 1.2 * U });
    fillPts(ellipse(pr.x - rx * 0.3, TABLE + 18 * U, rx * 0.34, ry * 0.3, 14), C.crema, 0.6);
  });
}
function drawStreams(ta) {                              // coffee streams, head and tail falling under gravity
  POURS.forEach((pr, i) => {
    const toCup = pr.cup != null, yL = toCup ? TABLE - CUPH + 20 * U : TABLE + 16 * U, fall = toCup ? FALL_C : FALL_T;
    if (ta < pr.a || ta > pr.b + fall) return;
    const head = Math.pow(seg(ta, pr.a, pr.a + fall), 1.5), tail = Math.pow(seg(ta, pr.b, pr.b + fall), 1.5);
    if (head - tail < 0.02) return;
    const tip = potAt(Math.min(ta, pr.b)).tip, end = [pr.x, yL];          // once the pour stops, the spout position freezes so the tail detaches
    const path = resample(bez(tip, [tip[0] - 26 * U, tip[1] + 2 * U], [end[0] + 6 * U, lerp(tip[1], end[1], 0.35)], end, 20), false, 5 * U);
    const n = path.length - 1, i0 = Math.floor(tail * n), sp = wob(path.slice(i0, Math.max(i0 + 1, Math.ceil(head * n)) + 1), false, bseed('stream' + i), 1.8 * U, 26 * U);
    strokePts(sp, C.ink, 30 * U); strokePts(sp, C.coffee, 17 * U);
    strokePts(sp.map(([x, y]) => [x - 4 * U, y]), C.crema, 3.5 * U, false, 0.7);
  });
}
function drawSplashes(ta) {                                     // droplets where a stream lands (smaller inside a mug)
  POURS.forEach((pr, i) => {
    const toCup = pr.cup != null, fall = toCup ? FALL_C : FALL_T, y0 = toCup ? TABLE - CUPH + 12 * U : TABLE + 14 * U, k = toCup ? 0.5 : 1;
    for (let j = 0; j < 16; j++) {
      const ts = pr.a + fall + j * 0.045, age = ta - ts; if (ts > pr.b + fall) break;
      if (age < 0 || age > 0.42) continue;
      const r = rng('splash', i, j), x = pr.x + (r() - 0.5) * 840 * U * k * age, y = y0 - ((240 + r() * 320) * U * k * age - 1300 * U * age * age);
      if (y > y0 + 16 * U) continue;
      const rr = (5 + r() * 6) * U * (toCup ? 0.7 : 1);
      circle(x, y, rr + 3.5 * U, C.ink); circle(x, y, rr, C.coffee);
    }
  });
}
const mugShadow = (x, lift, id) => { const k = 1 - clamp(lift / (350 * U)) * 0.6; hatchShadow(x + 10 * U, TABLE + 10 * U, 118 * U * k, 16 * U * k, C.ink, 0.5 * k, id); };
function puffs(list, id) { list.forEach(([x, y, r, a], i) => ink(circlePts(x, y, r, 18), { id: id + i, fill: C.white, stroke: C.ink, lw: 4 * U, alpha: a })); }

// ---------------------------------------------------------------- scenes
function sceneConveyor(lt) {                                    // bar 1: mugs #1-#4 step in on the beat and get filled, each more wired
  const p = conveyor(lt), lean = conveyorLean(lt);
  const mugs = CONVEYOR.map((c, k) => {
    const pr = POURS[k], on = lt >= pr.a;
    const x = XC + (k - p) * SLOT - (k === 3 ? eInExpo(seg(lt, S.arrive + 0.04, S.arrive + 0.32)) * 700 * U : 0);   // #4 is yanked away
    return { id: 'mug' + k, n: k, x, y: TABLE - CUPH / 2, rot: 0.1 * lean, fill: clamp(seg(lt, pr.a + FALL_C, pr.b + FALL_C)) * 0.92,
      mood: on ? c.mood : 'happy', look: on ? [0, 0] : [-0.8, 0], jit: on ? c.jit * seg(lt, pr.a, pr.a + 0.15) : 0 };
  }).filter((m) => Math.abs(m.x - CX) < W / 2 + 320 * U);
  mugs.forEach((m) => mugShadow(m.x, 0, 'shadow' + m.id));
  mugs.forEach((m) => {
    drawMug(m);
    if (m.jit > 2) [-1, 1].forEach((sd) => { const bx = m.x + sd * 160 * U; [0, 22].forEach((o, q) => inkLine(qbez([bx + sd * o * U, TABLE - (170 - o) * U], [bx + sd * (o + 14) * U, TABLE - 120 * U], [bx + sd * o * U, TABLE - (70 + o) * U]), rgba(C.ink, 0.7), 4 * U, m.id + sd + q)); });
  });
}
function sceneBuild(t) {                                        // bar 4: construction rings lock onto cup #5
  const a = inout(t, S.build + 0.25, S.launch, 0.4, 0.08), cy = TABLE - CUPH / 2;
  if (a <= 0) return;
  ring(XL, cy, 178 * U, { color: C.ink, alpha: 0.5 * a, lw: 3 * U, ticks: 12, rot: t * 0.9, dash: [10 * U, 12 * U], tickLen: 12 * U });
  ring(XL, cy, 214 * U, { color: C.ink, alpha: 0.28 * a, lw: 2 * U, ticks: 0, rot: -t * 0.6, dash: [4 * U, 14 * U] });
}
function sceneLanding(lt) {                                     // bar 5 downbeat: burst lines and dust puffs
  if (lt < 0 || lt > 0.55) return;
  const e = eOutQuint(lt / 0.55);
  burst(XC, TABLE - 60 * U, (150 + lt * 200) * U, (210 + lt * 260) * U, 14, 0.12, C.ink, 5 * U, Math.max(0, 1 - lt / 0.5));
  puffs([-1, 1].flatMap((sd) => [0, 1].map((j) => [XC + sd * (130 + j * 40 + e * 150) * U, TABLE - (6 + j * 26 + e * 30) * U, (18 + j * 8 + e * 26) * U, 1 - e])), 'dust');
}
function sceneCounter(t, ta) {                                  // HUD: "#1".."#5" pops on each new mug, then gets scribbled out
  const n = Math.min(5, 1 + Math.floor(ta / BEAT)), tc = beats(n - 1), size = 118 * U, x0 = SAFE.x0 + 26 * U, y = SAFE.y0 + 138 * U;
  let w = 0;
  withT({ x: x0, y: y - size / 2, scale: 1 + 0.28 * pulse(t, tc, 0.28) * (n > 1) }, () =>
    (w = hand('#' + n, 0, size / 2, size, { u: n === 1 ? 1 : seg(ta, tc - 0.04, tc + 0.1), lw: 15 * U, id: 'count' + n, color: C.ink })));
  if (ta < S.strike) return;
  const zz = [-104, -82, -60, -38, -16, -4].map((dy, i) => [i % 2 ? x0 + w + 16 * U : x0 - 16 * U, y + dy * U]);
  drawOn(wob(resample(zz, false, 8 * U), false, bseed('strike'), 2 * U, 30 * U), eOut(seg(ta, S.strike, S.strike + 0.28)), C.accent, 13 * U);
}
function sceneNope(lt) {                                        // bar 6: "NOPE." writes itself on, then an accent underline
  if (lt < 0) return;
  const y = 540 * U;
  hand('NOPE.', CX, y, 160 * U, { align: 'center', u: seg(lt, 0, 0.66), lw: 25 * U, id: 'nope', color: C.ink });
  drawOn(wob(qbez([CX - 290 * U, y + 44 * U], [CX, y + 58 * U], [CX + 290 * U, y + 36 * U], 24), false, bseed('underline'), 2 * U, 40 * U), eOut(seg(lt, 0.72, 0.98)), C.accent, 13 * U);
}
function sceneWink(lt) {                                        // bar 7: cup #5 winks at the viewer, one sparkle, then stillness
  const a = inout(lt, 0, 0.7, 0.12, 0.25);
  if (a <= 0) return;
  const r = 30 * U * eOutBack(seg(lt, 0, 0.16)), x = XC + 104 * U, y = TABLE - CUPH - 34 * U;
  sparkle(x, y, r + 7 * U, C.ink, a, 0.2); sparkle(x, y, r, C.white, a, 0.2);
}

// ---------------------------------------------------------------- the film
function frame(t) {
  const ta = CLK.TA, pot = potAt(ta), hero = heroAt(ta);
  drawPaper(C.paper);
  const cam = keys(t, [[0, [CX, CY, 1]], [S.build, [CX, CY, 1]], [S.hush, [XL + 90 * U, 570 * U, 1.15], eInOutSine], [S.launch, [XL + 90 * U, 570 * U, 1.15]], [S.launch + 0.45, [CX, CY, 1], eOutExpo]]);
  const shake = 16 * U * pulse(t, S.drop, 0.4) + 4 * U * pulse(t, HOP1[1], 0.2) + 5 * U * pulse(t, HOP2[1], 0.2) + (t < S.hush ? 2.5 * U * seg(t, S.build + 0.6, S.hush) : 0);

  camera({ x: cam[0], y: cam[1], zoom: cam[2], shake, shakeFreq: 14 }, () => {
    drawTable();
    drawPuddles(ta);
    if (ta < S.arrive + 0.5) sceneConveyor(ta);
    mugShadow(hero.x, hero.lift, 'shadow-hero');
    sceneLanding(ta - S.drop);
    if (hero.fly > 0.12 && hero.fly < 0.97) [-1, 0, 1].forEach((j) => {                        // motion arcs behind the backflip
      const pts = []; for (let q = Math.max(0, hero.fly - 0.35); q <= hero.fly; q += 0.02) pts.push([lerp(XL, XC, eInOutSine(q)), TABLE - CUPH / 2 - Math.sin(Math.PI * q) * LEAP + j * 46 * U]);
      if (pts.length > 1) inkLine(pts, rgba(C.ink, 0.55), 5 * U, 'trail' + j);
    });
    drawMug(hero);
    sceneBuild(t);
    drawStreams(ta);
    drawSplashes(ta);
    const bang = inout(ta, S.alarm, HOP1[0], 0.08, 0.06);                                        // "!" when the pot leans in
    if (bang > 0) withT({ x: hero.x + 150 * U, y: TABLE - CUPH - 70 * U, scale: 0.6 + 0.4 * eOutBack(seg(ta, S.alarm, S.alarm + 0.16)) }, () => hand('!', 0, 40 * U, 90 * U, { align: 'center', lw: 13 * U, id: 'bang', alpha: bang }));
    drawPot(pot);
    const steam = [0, 1, 2, 3].map((i) => [i, ta - (S.fume + 0.06 + i * 0.1)]).filter(([, age]) => age >= 0 && age < 0.6);   // the pot fumes
    puffs(steam.map(([i, age]) => [pot.x + (i % 2 ? 1 : -1) * (20 + age * 90) * U, pot.y - 170 * U - age * 200 * U, (14 + age * 46) * U, 1 - age / 0.6]), 'steam');
    sceneWink(ta - S.end);
  });

  sceneCounter(t, ta);
  sceneNope(ta - S.nope);
  flash(pulse(t, S.drop, 0.12) * 0.45, C.white);
}
