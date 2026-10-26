'use strict';
// =====================================================================================
// NIGHTSHIFT: the Motion Director example for the neon / cinematic style (vertical, 15 s, 96 BPM).
// Idea: you log off, the screen collapses to one pixel, and the pixel refuses to die.
// It becomes a cursor, codes all night, and at 07:00 floods the frame with light: NIGHT / SHIFT.
//
// How the file is organised (copy this shape):
//   C      palette: one accent (cyan), one support (violet), one colour saved for the end (dawn).
//   S      every moment on the beat grid, in absolute seconds via beats()/bars(). score.js
//          reads S directly (same global scope), so a sound can never drift from its picture.
//   QC_AT  key moments the QC contact sheet must include.
//   Sync tables (CODE, LOG, the clock) sit next to S so score.js can sound every keystroke.
//   Scenes: frame(t) calls one scene function per section. Self-contained scenes get local
//   time (lt = t - start). Scenes whose moments the score also hits take absolute t and
//   compare it against S, so there is only ever one number for each moment.
// =====================================================================================

const C = { ink: '#eaf3ff', hot: '#e6fbff', cyan: '#27e4ff', violet: '#8b6bff', dawn: '#ff4fa8', dim: '#4c5a7a', punct: '#8e9bb8' };
const DISPLAY = { font: 'Big Shoulders', weight: 700 }, MONO = { font: 'Geist Mono', weight: 400 }, MONO_B = { font: 'Geist Mono', weight: 700 };

const S = {
  hits: [0, beats(0.5), beats(1)], // YOU / LOG / OFF. flare on 8th notes
  off: beats(3.5),                 // CRT power-off: squash to a scanline...
  dot: beats(3.5) + 0.24,          // ...then to one living pixel
  heart: bars(1),                  // its heartbeat (lub, dub at +0.19 s)
  doesnt: beats(5),                // IT DOESN'T. The pixel becomes a cursor
  glide: beats(5.6),               // the cursor glides into place
  type: beats(6),                  // first keystroke
  night: bars(2),                  // the clock appears at 00:00
  log: beats(11.5),                // the loop runs: commits stream in, faster and faster
  freeze: beats(13.5),             // everything stops dead: true silence
  drop: beats(14),                 // 07:00: light floods out of the cursor, NIGHT
  ignite: beats(15),               // SHIFT flickers on like a neon tube
  tag: beats(18),                  // the cursor types SHIPS MONDAY
  home: beats(20),                 // dawn warms (the score resolves to D major)
  still: beats(23),                // final hold: nothing moves
};
const QC_AT = [0, S.off + 0.08, S.freeze + 0.15, S.drop + 0.02, S.drop + 0.12, S.ignite + 0.5, DUR - 0.04];

// ---------------------------------------------------------------- layout
const HEAD_Y = CY - 380 * U, CLOCK_Y = CY - 290 * U, CODE_Y = CY - 60 * U;
const CODE_SIZE = 54 * U, LOG_SIZE = 44 * U, LH = 80 * U, NIGHT_ZOOM = 0.07;
const TITLE_O = { ...DISPLAY, tracking: -0.01, align: 'center' };
let L = null; // measured on the first frame, when fonts are loaded
function layout() {
  if (L) return L;
  const T = Math.min(fitSize('NIGHT', 350 * U, SAFE.wc, TITLE_O), fitSize('SHIFT', 350 * U, SAFE.wc, TITLE_O));
  const cap = capH(T, TITLE_O), gap = 0.13 * T, tagGap = 120 * U;
  const y1 = CY - 30 * U - (2 * cap + gap + tagGap) / 2 + cap, y2 = y1 + gap + cap;
  const cw = textW('0', CODE_SIZE, MONO);
  L = { T, y1, y2, tagY: y2 + tagGap, titleCY: (y1 - cap + y2) / 2, cw, cwLog: cw * LOG_SIZE / CODE_SIZE, codeX: CX - 10 * cw };
  L.flashFrom = cursorAt(S.freeze); // the drop's light pours out of the cursor's last position
  return L;
}

// ---------------------------------------------------------------- sync tables (score.js reads these too)
const TOK = { kw: C.violet, fn: C.cyan, id: C.ink, p: C.punct };
const CODE = [ // the loop the pixel writes, one line per beat
  { t0: S.type, dt: 0.03, s: [['while', 'kw'], [' (', 'p'], ['you', 'id'], ['.', 'p'], ['asleep', 'fn'], [') {', 'p']] },
  { t0: beats(8), dt: 0.028, s: [['  fix', 'fn'], ['(', 'p'], ['bugs', 'id'], [');', 'p']] },
  { t0: beats(9), dt: 0.028, s: [['  write', 'fn'], ['(', 'p'], ['tests', 'id'], [');', 'p']] },
  { t0: beats(10), dt: 0.03, s: [['  ship', 'fn'], ['();', 'p']] },
  { t0: beats(11), dt: 0.03, s: [['}', 'p']] },
];
CODE.forEach((l) => { l.str = l.s.map((x) => x[0]).join(''); l.lead = l.str.length - l.str.trimStart().length; l.t1 = l.t0 + (l.str.length - l.lead - 1) * l.dt; });
const typedN = (l, t) => t < l.t0 ? 0 : Math.min(l.str.length, l.lead + Math.floor((t - l.t0) / l.dt) + 1);

const LOG_BASE = ['refactor: auth flow', 'fix: race in queue', 'tests: +38 cases', 'perf: cache warmed', 'deps: bumped 12', 'docs: regenerated',
  'fix: flaky e2e', 'types: tightened', 'lint: 0 warnings', 'ci: all green', 'feat: retry logic', 'fix: memory leak'];
const LOG_END = ['fix: n+1 query', '1,204 tests passing', 'PR #214 merged', 'ready for review']; // readable in the freeze
const NLOG = 47, LOG_P = 2.3; // commits streamed; >1 = accelerating
const LOG = Array.from({ length: NLOG }, (_, j) => j >= NLOG - LOG_END.length ? LOG_END[j - NLOG + LOG_END.length] : LOG_BASE[(j * 5) % LOG_BASE.length]);
const logN = (t) => NLOG * Math.pow(seg(t, S.log, S.freeze), LOG_P);              // rows emitted (continuous)
const logRate = (t) => { const u = seg(t, S.log, S.freeze); return u > 0 && u < 1 ? NLOG * LOG_P * Math.pow(u, LOG_P - 1) / (S.freeze - S.log) : 0; };
const logT = (j) => S.log + (S.freeze - S.log) * Math.pow((j + 1) / NLOG, 1 / LOG_P); // when row j lands

const CLOCK_P = 1.7, CLOCK_END = 6 * 60 + 59; // 00:00 → 06:59, accelerating
const clockMin = (t) => Math.floor(CLOCK_END * Math.pow(seg(t, S.night, S.freeze), CLOCK_P) + 1e-6);
const clockT = (m) => S.night + (S.freeze - S.night) * Math.pow(m / CLOCK_END, 1 / CLOCK_P);
const hhmm = (m) => String(Math.floor(m / 60)).padStart(2, '0') + ':' + String(m % 60).padStart(2, '0');

const FLICKER = [[0, 0.06], [0.1, 0.14], [0.2, 0.36], [0.42, 99]]; // SHIFT's on-segments, s after S.ignite
function neonOn(t) { const d = t - S.ignite; for (const [a, b] of FLICKER) if (d >= a && d < b) return b > 10 ? 1 : 0.75; return 0; }

const TAG = 'SHIPS MONDAY', TAG_DT = 0.045;

// ---------------------------------------------------------------- shared pieces
function dust(t, a) { // slow drifting motes: the room is never dead
  particles('dust', 110, (i, r) => {
    const x0 = r() * W, y0 = r() * H, sp = 0.4 + r() * 0.9, sz = (1 + r() * 2.2) * U, a0 = 0.12 + r() * 0.4, ph = r() * 10;
    const x = x0 + snoise(t * 0.12 * sp + ph, i) * 70 * U, y = ((y0 - t * 14 * U * sp) % H + H) % H;
    circle(x, y, sz, i % 4 ? C.cyan : C.violet, a0 * a * (0.6 + 0.4 * snoise(t * 0.8 + ph, i + 7)));
  });
}
function pixel(x, y, w, h, a = 1, halo = 1, rr = Math.min(w, h) * 0.12) { // the living pixel / cursor
  glow(x, y, 150 * U * halo, C.cyan, 0.45 * a);
  withT({ alpha: a }, () => roundRect(x - w / 2, y - h / 2, w, h, rr, C.hot));
  glow(x, y, Math.max(w, h) * 0.9, '#ffffff', 0.5 * a);
}
function drawCode(segs, x, y, size, nChars = 1e9, alpha = 1) { // syntax-coloured segments, typed up to nChars
  let left = nChars;
  for (const [str, k] of segs) {
    if (left <= 0) break;
    const s = str.slice(0, left); left -= str.length;
    text(s, x, y, size, { ...MONO, color: TOK[k], alpha: alpha * (k === 'p' ? 0.85 : 1) });
    x += textW(s, size, MONO);
  }
  return x;
}

// ---------------------------------------------------------------- 1 · HOOK (0 s): editor mid-flow at 23:58, YOU LOG OFF. already on screen
const KW = ['const', 'await', 'return', 'if', 'export', 'let'], ID = ['user', 'queue', 'cache', 'session', 'retry', 'config', 'result', 'token', 'router', 'events'];
const FN = ['fetch', 'parse', 'resolve', 'update', 'commit', 'validate', 'render', 'dispatch', 'merge', 'schedule'];
function codeRow(k) { // a plausible line of code for editor row k (texture, not meant to be read)
  const v = Math.floor(h01('row', k) * 4), ind = '  '.repeat(Math.floor(h01('ind', k) * 3));
  const id = pick(ID, 'id', k), id2 = pick(ID, 'id2', k), fn = pick(FN, 'fn', k);
  if (v === 0) return [[ind + pick(KW, 'kw', k) + ' ', 'kw'], [id, 'id'], [' = ', 'p'], [fn, 'fn'], ['(' + id2 + ');', 'p']];
  if (v === 1) return [[ind + 'await ', 'kw'], [id + '.', 'id'], [fn, 'fn'], ['();', 'p']];
  if (v === 2) return [[ind + 'if ', 'kw'], ['(!' + id + ') ', 'p'], ['return', 'kw'], [';', 'p']];
  return [[ind + id + '.', 'id'], [fn, 'fn'], ['(', 'p'], [id2, 'id'], [', ', 'p'], ['true', 'kw'], [');', 'p']];
}
function editorScreen(lt) {
  const w = 840 * U, h = 680 * U, x = CX - w / 2, y = CY + 70 * U - h / 2, bar = y + 70 * U;
  glow(CX, y + h / 2, 1050 * U, C.cyan, 0.12); // screen light spilling into the room
  roundRect(x, y, w, h, 30 * U, linGrad(0, y, 0, y + h, [[0, '#0d1532'], [1, '#060a17']]));
  [0, 1, 2].forEach((i) => circle(x + 44 * U + i * 28 * U, bar - 15 * U, 7 * U, C.dim));
  text('23:58', x + w - 36 * U, bar, 44 * U, { ...MONO_B, color: C.cyan, align: 'right', tabular: true });
  line(x, bar + 20 * U, x + w, bar + 20 * U, rgba(C.cyan, 0.16), 2 * U);
  ctx.save(); ctx.beginPath(); ctx.rect(x + 16 * U, bar + 24 * U, w - 32 * U, y + h - bar - 44 * U); ctx.clip();
  const lh = 44 * U, sc = 3 + lt * 5.2, first = Math.floor(sc), act = first + 11; // rows type in at the bottom and scroll up
  for (let k = first; k <= act; k++) {
    const ly = bar + 76 * U + (k - sc) * lh, row = codeRow(k), len = row.reduce((n, s) => n + s[0].length, 0);
    const end = drawCode(row, x + 44 * U, ly, 30 * U, k < act ? 1e9 : Math.floor((sc - first) * len * 1.25), k < act ? 0.8 : 1);
    if (k === act) rect(end + 3 * U, ly - 25 * U, 16 * U, 32 * U, C.hot);
  }
  ctx.restore();
  bloom(() => roundRect(x, y, w, h, 30 * U, null, C.cyan, 3.5 * U), 16 * U, 0.9);
}
function headline(lt) { // the line lands just before frame 0 (thumbnail), then each word flares on its hit
  const o = { ...DISPLAY, tracking: 0.01, color: C.ink, glow: { color: C.cyan, r: 26 * U } };
  const size = fitSize('YOU LOG OFF.', 190 * U, SAFE.wc, o);
  withT({ x: CX, y: HEAD_Y, scale: lerp(1.4, 1, eOutExpo(seg(lt, -0.3, 0.12))) }, () =>
    words('YOU LOG OFF.', 0, 0, size, { ...o, align: 'center' }).forEach((w, i) => {
      const hit = pulse(lt, S.hits[i], 0.35);
      withT({ x: w.x + w.w / 2, y: -size * 0.36, scale: 1 + 0.1 * hit }, () =>
        text(w.word, -w.w / 2, size * 0.36, size, { ...o, color: mixHex(C.ink, '#ffffff', hit), glow: { color: C.cyan, r: (26 + 40 * hit) * U } }));
    }));
}
function sceneHook(lt) {
  dust(lt, 0.6);
  editorScreen(lt);
  headline(lt);
}

// ---------------------------------------------------------------- 2 · POWER-OFF (S.off): the picture squashes into a scanline, then one pixel
function scenePowerOff(lt) {
  const squash = seg(lt, 0, 0.1), shrink = seg(lt, 0.1, S.dot - S.off);
  if (squash < 1) {
    const sy = lerp(1, 0.008, eIn(squash));
    const squashed = (fn) => withT({ x: CX, y: CY, sx: 1 + 0.05 * squash, sy }, () => withT({ x: -CX, y: -CY }, fn));
    squashed(() => sceneHook(S.off));
    withT({ blend: 'lighter', alpha: 0.9 * squash }, () => squashed(() => sceneHook(S.off))); // over-brightens as it squashes
    const bh = Math.max(6 * U, 40 * U * sy);
    withT({ blend: 'lighter', alpha: squash }, () => bloom(() => roundRect(CX - 440 * U, CY - bh / 2, 880 * U, bh, bh / 2, C.hot), 20 * U, 1));
  } else {
    const w = Math.max(14 * U, 880 * U * (1 - eIn(shrink)));
    bloom(() => roundRect(CX - w / 2, CY - 3 * U, w, 6 * U, 3 * U, C.hot), 16 * U, 1);
    glow(CX, CY, 120 * U + 220 * U * (1 - shrink), C.cyan, 0.6);
  }
}

// ---------------------------------------------------------------- 3 · THE NIGHT (S.dot): the pixel wakes, types the loop, the clock races, freeze
function lastKey(t) { // time of the most recent keystroke in CODE
  let k = -1;
  for (const l of CODE) if (t >= l.t0) k = Math.max(k, Math.min(l.t1, l.t0 + Math.floor((t - l.t0) / l.dt) * l.dt));
  return k;
}
function cursorAt(t) { // where the pixel is and what shape it has (a dot, then a block cursor)
  const { cw, cwLog, codeX } = layout(), n = logN(t);
  if (t < S.glide) { // a dot with a heartbeat, morphing into a cursor on IT DOESN'T.
    const hb = pulse(t, S.heart, 0.28) + 0.75 * pulse(t, S.heart + 0.19, 0.28), m = spring(t - S.doesnt, 2.4, 0.42);
    const d = 16 * U * (1 + 1.4 * hb), w = lerp(d, cw * 0.92, m);
    return { x: CX, y: CY, w, h: lerp(d, CODE_SIZE * 1.02, m), rr: lerp(d / 2, w * 0.12, clamp(m)), halo: 1 + hb * 0.8 };
  }
  const slot = (li, chars) => [codeX + (chars + 0.5) * cw + 3 * U, CODE_Y + (li - n) * LH - CODE_SIZE * 0.34];
  if (t < S.type) { // the glide into the editor
    const [tx, ty] = slot(0, 0), u = eInOutExpo(seg(t, S.glide, S.type - 0.02));
    return { x: lerp(CX, tx, u), y: lerp(CY, ty, u), w: cw * 0.92, h: CODE_SIZE * 1.02, halo: 1 + 0.6 * Math.sin(u * Math.PI) };
  }
  if (n < 1) { // typing the loop; blinks on the beat while idle
    let li = 0; CODE.forEach((l, i) => { if (t >= l.t0) li = i; });
    const [x, y] = slot(li, typedN(CODE[li], t));
    return { x, y, w: cw * 0.92, h: CODE_SIZE * 1.02, blink: t < S.log && t - lastKey(t) > 0.3 };
  }
  const j = Math.min(NLOG, Math.floor(n)) - 1; // riding the newest commit row
  return { x: codeX + 58 * U + textW(LOG[j], LOG_SIZE, MONO) + 12 * U + cwLog * 0.5, y: CODE_Y + (5 + j - n) * LH - LOG_SIZE * 0.34, w: cwLog * 0.92, h: LOG_SIZE * 1.02 };
}
function answer(t) { // IT DOESN'T. rises in word by word, then lifts away for the clock
  const out = eInExpo(seg(t, S.night - 0.28, S.night - 0.02));
  if (t < S.doesnt || out >= 1) return;
  const o = { ...DISPLAY, tracking: 0.01, color: C.ink, glow: { color: C.cyan, r: 26 * U } }, size = fitSize('IT DOESN’T.', 190 * U, SAFE.wc, o);
  withT({ x: CX, y: HEAD_Y - 60 * U * out, scale: 1 + 0.025 * seg(t, S.doesnt, S.night), alpha: 1 - out }, () =>
    reveal('IT DOESN’T.', 0, 0, size, seg(t, S.doesnt, S.doesnt + 0.55), { ...o, align: 'center', mode: 'mask', by: 'word', stagger: 0.35 }));
}
function nightClock(t) { // 00:00 → 06:59, flaring on every hour; the commit count below
  const u = eOutQuint(seg(t, S.night - 0.04, S.night + 0.35)), m = clockMin(t);
  if (u <= 0) return;
  const hot = m >= 60 ? pulse(t, clockT(Math.floor(m / 60) * 60), 0.25) : 0;
  withT({ y: (1 - u) * 50 * U, alpha: u }, () =>
    text(hhmm(m), CX, CLOCK_Y, 176 * U, { ...MONO_B, align: 'center', tracking: -0.02, tabular: true, color: mixHex(C.ink, C.cyan, hot * 0.6), glow: { color: C.cyan, r: (24 + 30 * hot) * U } }));
  const cu = eOutQuint(seg(t, S.log, S.log + 0.3));
  if (cu > 0) text(`${Math.floor(logN(t))} COMMITS`, CX, CLOCK_Y + 84 * U, 44 * U, { ...MONO_B, align: 'center', tracking: 0.14, tabular: true, color: C.cyan, alpha: cu * 0.9 });
}
function band(y) { return sstep(CLOCK_Y + 130 * U, CLOCK_Y + 230 * U, y) * (1 - sstep(CODE_Y + 4.25 * LH, CODE_Y + 4.95 * LH, y)); } // visible strip
function codeAndLog(t, frozen) { // the loop, then the commit log scrolling up; rows smear with speed, crisp in the freeze
  const { codeX } = layout(), n = logN(t), spd = frozen ? 0 : logRate(t) * LH / FPS;
  CODE.forEach((l, i) => { const y = CODE_Y + (i - n) * LH; if (t >= l.t0 && band(y) > 0) drawCode(l.s, codeX, y, CODE_SIZE, typedN(l, t), band(y)); });
  const copies = Math.max(1, Math.min(9, Math.round(spd / (10 * U)))), smear = Math.min(spd, 160 * U);
  for (let j = Math.max(0, Math.floor(n) - 8); j < Math.min(NLOG, Math.ceil(n) + 1); j++) {
    const y = CODE_Y + (5 + j - n) * LH, a = band(y);
    if (a <= 0) continue;
    for (let q = 0; q < copies; q++) withT({ y: copies > 1 ? (q / (copies - 1) - 0.5) * smear : 0, alpha: a * Math.min(1, 1.6 / copies) }, () => {
      icon('check', codeX + 18 * U, y - 15 * U, 36 * U, { color: C.cyan, lw: 2.8 });
      text(LOG[j], codeX + 58 * U, y, LOG_SIZE, { ...MONO, color: j === NLOG - 1 ? C.ink : rgba(C.ink, 0.75) });
    });
  }
}
function sceneNight(t) {
  const tb = Math.min(t, S.freeze); // the freeze: time stops for every layer
  camera({ zoom: 1 + NIGHT_ZOOM * eInOut(seg(tb, S.dot, S.freeze)) }, () => {
    dust(tb, 0.8);
    answer(tb);
    nightClock(tb);
    codeAndLog(tb, t >= S.freeze);
    const c = cursorAt(tb);
    pixel(c.x, c.y, c.w, c.h, c.blink && beatPhase(tb) >= 0.5 ? 0.12 : 1, c.halo, c.rr);
  });
}

// ---------------------------------------------------------------- 4 · 07:00 (S.drop): NIGHT slams out of the light, SHIFT ignites, dawn rises
function dawn(t) { // a magenta horizon glow that swells again when the score turns major
  const u = eOut(seg(t, S.drop, S.drop + 2.2)) * (0.7 + 0.3 * sstep(S.home, S.home + 1.6, t)), hy = H * 0.79;
  const hw = W * 0.56 * eOutExpo(seg(t, S.drop, S.drop + 1.1));
  glow(CX, hy + 300 * U, 1150 * U, C.dawn, 0.34 * u);
  glow(CX, hy + 160 * U, 620 * U, C.violet, 0.26 * u);
  withT({ blend: 'lighter' }, () => { line(CX - hw, hy, CX + hw, hy, rgba(C.dawn, 0.85 * u), 3 * U); line(CX - hw * 0.55, hy, CX + hw * 0.55, hy, rgba('#ffffff', 0.6 * u), 1.5 * U); });
  glow(CX, hy, 320 * U, C.dawn, 0.22 * u);
}
function sparks(t) { // the burst: streaks fly out of the title and burn out
  const d = t - S.drop, { titleCY } = layout();
  if (d > 2.2) return;
  particles('spark', 150, (i, r) => {
    const ang = r() * TAU, dist = (200 + r() * 950) * U, a = 1 - clamp(d / (0.8 + r() * 1.2)), b = eOutExpo(clamp(d / 1.5));
    if (a <= 0) return;
    const x = CX + Math.cos(ang) * dist * b, y = titleCY + Math.sin(ang) * dist * b, len = (4 + (1 - b) * 90) * U;
    withT({ alpha: a, blend: 'lighter' }, () => line(x - Math.cos(ang) * len, y - Math.sin(ang) * len, x, y, i % 5 ? C.cyan : C.hot, (1.4 + r() * 2.2) * U));
  });
  speedLines(CX, titleCY, 420 * U, 1500 * U, 70, 'sl', C.cyan, 0.5 * pulse(t, S.drop, 0.45), 2 * U);
}
function title(t) { // NIGHT solid and white-hot; SHIFT a glass tube that lights up
  const { T, y1, y2, titleCY } = layout(), on = neonOn(t), sweep = seg(t, S.drop + 1.2, S.drop + 2.1);
  withT({ x: CX, y: titleCY, scale: lerp(1.32, 1, eOutQuint(seg(t, S.drop, S.drop + 0.8))) }, () => withT({ x: -CX, y: -titleCY }, () => {
    bloom(() => text('NIGHT', CX, y1, T, { ...TITLE_O, color: C.ink, glow: { color: C.cyan, r: 34 * U } }), 26 * U, 0.55);
    if (sweep > 0 && sweep < 1) withT({ blend: 'lighter' }, () => masked( // a light sweep across NIGHT once it has landed
      () => text('NIGHT', CX, y1, T, { ...TITLE_O, color: '#ffffff' }),
      () => { const bx = lerp(-300 * U, W + 300 * U, eInOutSine(sweep)); ctx.fillStyle = linGrad(bx - 160 * U, 0, bx + 160 * U, 0, [[0, rgba('#ffffff', 0)], [0.5, rgba('#ffffff', 0.75)], [1, rgba('#ffffff', 0)]]); ctx.fillRect(0, 0, W, H); }));
    text('SHIFT', CX, y2, T, { ...TITLE_O, color: null, stroke: rgba(C.cyan, 0.16), lw: 6 * U }); // unlit tube
    if (on > 0) withT({ alpha: on }, () => bloom(() => {
      text('SHIFT', CX, y2, T, { ...TITLE_O, color: null, stroke: C.cyan, lw: 8 * U });
      text('SHIFT', CX, y2, T, { ...TITLE_O, color: null, stroke: C.hot, lw: 2.4 * U });
    }, 22 * U, 1));
  }));
}
function tagline(t) { // the same cursor types the launch day, then blinks on the beat (steady for the last hold)
  const { tagY } = layout(), o = { ...MONO_B, tracking: 0.16 }, size = 58 * U;
  if (t < S.tag) return;
  const n = Math.min(TAG.length, Math.floor((t - S.tag) / TAG_DT) + 1), x0 = CX - textW(TAG, size, o) / 2 - 25 * U;
  text(TAG.slice(0, n), x0, tagY, size, { ...o, color: C.ink, glow: { color: C.cyan, r: 14 * U } });
  const typing = t < S.tag + TAG.length * TAG_DT + 0.25, x = x0 + textW(TAG.slice(0, n), size, o) + (n < TAG.length ? 20 : 36) * U;
  pixel(x, tagY - size * 0.36, 28 * U, size * 1.02, typing || t >= S.still || beatPhase(t) < 0.5 ? 1 : 0.12, 0.6);
}
function sceneTitle(t) {
  dawn(t);
  camera({ zoom: 1 + 0.03 * eInOut(seg(t, S.drop, S.still)), shake: 26 * U * pulse(t, S.drop, 0.55) + 10 * U * pulse(t, S.ignite, 0.35), seed: 'drop' }, () => {
    dust(Math.min(t, S.still), 0.7);
    sparks(t);
    title(t);
    tagline(t);
  });
  const d = t - S.drop, f = layout().flashFrom, z = 1 + NIGHT_ZOOM; // two frames of white-out pouring from the cursor...
  if (d < 0.07) circle(CX + (f.x - CX) * z, CY + (f.y - CY) * z, 2300 * U * eOutExpo(clamp(d / 0.06)), C.hot);
  flash(0.4 * pulse(t, S.drop + 0.07, 0.12), C.cyan, 'lighter'); // ...then a hard cut with an additive cyan afterglow (never grey)
}

// ---------------------------------------------------------------- the film
function frame(t) {
  layout();
  if (t < S.off) camera({ zoom: 1 + 0.04 * eInOut(seg(t, 0, S.off)) }, () => sceneHook(t)); // slow push into the hook
  else if (t < S.dot) camera({ zoom: 1.04 }, () => scenePowerOff(t - S.off));
  else if (t < S.drop) sceneNight(t);
  else sceneTitle(t);
}
