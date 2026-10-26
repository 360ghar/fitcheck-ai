'use strict';
// ─────────────────────────────────────────────────────────────────────────────
// THE 98¢ TRADE — Motion Director example film · kinetic typography · 9:16 · 15 s · 128 BPM (8 bars of 1.875 s)
//
// How the file is organised (copy this shape):
//   C          the palette in one place: bg, fg, ONE accent (acid lime), plus neutrals.
//   S          scene start times on the beat grid (bars(n)). score.js reads S (and SCAN, COUNT_T, QUIET)
//              directly — same global scope — so every sound lands on the frame of its picture event.
//   QC_AT      key moments (the hook, hits, the drop, the end card) the QC contact sheet must include.
//   setup()    measures type once fonts are loaded and precomputes heavy geometry (8,318 dots); frames stay cheap.
//   sceneX(lt) one function per scene, drawn from LOCAL time lt = t - S.x.
//   frame(t)   camera language (push-through cuts, slow drift, shakes), the scene switch, screen-space transitions.
//
// Story: 98¢ slams in → Jev (a reading beam) flags the fine print → 8,318 past trades count up as 8,318 dots →
// a breath of silence → DROP: the dots fuse into one lime slab, 99% paid out (~1% stay dark) → +0.58% per trade
// → "Open the folder. Type hi." → the end card lands on the same 98¢ as frame 0, so the loop feels intentional.
// ─────────────────────────────────────────────────────────────────────────────
const C = {
  bg: '#0b0c0b', fg: '#f3f0e7', acc: '#b8ff3b', ink: '#0b0c0b',
  dim: '#8d928c', faint: '#4b504c', unread: '#474c48', read: '#c9ccc6',
  card: '#151816', card2: '#111412', card3: '#0e100f', edge: '#272c28',
};
const S = { hook: 0, rules: bars(1), count: bars(3), drop: bars(4), edge: bars(5), setup: bars(6), end: bars(7) };
const QUIET = 0.25;                        // true silence + stillness right before the drop
const COUNT_T = beats(3);                  // 8,318 counts up over 3 beats and lands on beat 4
const TRADES = 8318, MISSES = 83;          // ~1% of the dots stay dark on the drop (99% paid out)
const SCAN = { t0: 0.25, n: 14, hl: 7 };   // Jev reads 14 rule lines; line 7 is flagged exactly on the bar line
SCAN.v = SCAN.hl / (BAR - SCAN.t0);        // reading speed in lines per second
const QC_AT = [0, S.rules + BAR + 0.1, S.drop - 0.1, S.drop + 0.15, S.drop + 1, S.edge + 1.6, S.setup + 1.4, DUR - 0.05];

const BOLD = { font: 'Boldonse', tracking: -0.02 };                       // slams: numbers, FIRST., Trade
const SANS = { font: 'Bricolage Grotesque', weight: 700, tracking: -0.02 }; // lines
const MONO = { font: 'Geist Mono', weight: 400 };                         // labels, fine print
const MONOB = { font: 'Geist Mono', weight: 700 };

const RULES = [
  'This market resolves to "Yes" if the stated',
  'outcome is officially confirmed on or before',
  'the end date. Otherwise it resolves to "No".',
  'Resolution source: the official announcement',
  'from the organising body. Reports by third',
  'parties are not accepted as a source.',
  'Clarification (added after listing):',
  'If the event is postponed, it resolves "No".',
  'Recounts, appeals or corrections made after',
  'the end date are not considered.',
  'In ambiguous cases the resolver decides,',
  'following the spirit of the rules above.',
  'Trading may pause while a market resolves.',
  'All times are UTC.',
];

// ───────────────────────────────────────────── layout, measured once the fonts are loaded
const L = {};
async function setup() {
  const col = SAFE.wc;
  // hero "98¢": same size and place in the hook and on the end card (the match cut)
  L.numS = fitSize('98¢', 600 * U, col * 0.9, BOLD);
  let m = metrics('98¢', L.numS, BOLD);
  L.numW = m.w; L.numX0 = CX - m.w / 2;
  L.numBase = SAFE.y0 + SAFE.h * 0.34 + (m.asc - m.desc) / 2; L.numTop = L.numBase - m.asc; L.numBot = L.numBase + m.desc;
  L.hookLab = L.numTop - 62 * U;
  L.hookS = fitSize('Near-certain', 104 * U, col, SANS);
  L.hookL1 = L.numBot + 140 * U; L.hookL2 = L.hookL1 + L.hookS * 1.04;
  L.priceW = col - 130 * U; L.priceY = L.hookL2 + 175 * U;

  // rules card, then the stack "JEV READS / THE FINE PRINT / FIRST." justified to one width in the space below
  const K = { x: CX - col / 2, y: 330 * U, w: col, head: 72 * U, lh: 30 * U, pad: 34 * U };
  K.bodyTop = K.y + K.head + 16 * U; K.h = K.head + 16 * U + SCAN.n * K.lh + 24 * U;
  L.card = K;
  const lines = [['JEV READS', SANS, C.fg], ['THE FINE PRINT', SANS, C.fg], ['FIRST.', BOLD, C.acc]];
  const gap = 22 * U, r0 = K.y + K.h + 70 * U, avail = SAFE.y1 - 70 * U - r0;
  const layStack = (w) => lines.map(([s, o, c]) => { const size = fitSize(s, 3000 * U, w, o), mm = metrics(s, size, o); return { s, o, c, size, asc: mm.asc, desc: mm.desc }; });
  const hStack = (lay) => lay.reduce((a, l) => a + l.asc + l.desc, 0) + gap * 2;
  let lay = layStack(col * 0.95);                     // 5% spare for the camera drift
  if (hStack(lay) > avail) lay = layStack(col * 0.95 * (avail - gap * 2) / (hStack(lay) - gap * 2));
  let y = r0 + (avail - hStack(lay)) / 2;
  lay.forEach((l) => { l.base = y + l.asc; y = l.base + l.desc + gap; });
  L.stack = lay;

  // counter + a grid of 8,318 dots, one per past trade
  L.cntS = fitSize('8,318', 600 * U, col * 0.66, BOLD);
  m = metrics('8,318', L.cntS, BOLD);
  L.cntBase = 300 * U + m.asc; L.cntCY = L.cntBase - m.asc / 2; L.cntLab = L.cntBase + m.desc + 58 * U;
  const gTop = L.cntLab + 42 * U, gH = SAFE.y1 - 24 * U - gTop;   // the biggest dot pitch that fits the safe area
  let p = Math.sqrt(col * gH / TRADES);
  while (Math.ceil(TRADES / Math.floor(col / p)) * p > gH) p *= 0.99;
  const cols = Math.floor(col / p), rows = Math.ceil(TRADES / cols);
  const G = { p, cols, rows, d: p * 0.62, x0: CX - cols * p / 2, y0: gTop };
  G.w = cols * p; G.h = rows * p; G.cy = G.y0 + G.h / 2;
  G.col = new Uint16Array(TRADES); G.row = new Uint16Array(TRADES); G.tA = new Float32Array(TRADES);
  G.dist = new Float32Array(TRADES); G.miss = new Uint8Array(TRADES);
  const order = [], R = Math.hypot(G.w / 2, G.h / 2);
  for (let i = 0; i < TRADES; i++) {
    const c = i % cols, r = Math.floor(i / cols);
    G.col[i] = c; G.row[i] = r;
    G.dist[i] = Math.hypot((c + 0.5) * p - G.w / 2, (r + 0.5) * p - G.h / 2) / R;
    order.push([c / cols * 0.55 + r / rows * 0.45 + h01('ord', i) * 0.22, i]);   // a noisy diagonal wave
  }
  order.sort((a, z) => a[0] - z[0]);
  // the dot of rank k appears exactly when the eOutExpo counter passes k
  order.forEach(([, i], k) => { G.tA[i] = Math.min(1, -Math.log2(1 - k / TRADES) / 10) * COUNT_T; });
  Array.from({ length: TRADES }, (_, i) => [h01('miss', i), i]).sort((a, z) => a[0] - z[0]).slice(0, MISSES).forEach(([, i]) => { G.miss[i] = 1; });
  L.grid = G;

  // drop: "99%" + "paid out." centred on the slab
  L.pctS = fitSize('99%', 600 * U, G.w * 0.8, BOLD); L.paidS = 124 * U;
  m = metrics('99%', L.pctS, BOLD);
  const pm = metrics('paid out.', L.paidS, SANS), tot = m.asc + 48 * U + pm.asc + pm.desc;
  L.pctBase = G.cy - tot / 2 + m.asc; L.pctCY = L.pctBase - m.asc / 2; L.paidBase = L.pctBase + 48 * U + pm.asc;

  // edge: +0.58% per trade, on average
  L.edgeS = fitSize('+0.58%', 600 * U, col * 0.94, BOLD);
  m = metrics('+0.58%', L.edgeS, BOLD);
  L.edgeW = m.w; L.edgeBase = SAFE.y0 + SAFE.h * 0.38 + m.asc / 2; L.edgeCY = L.edgeBase - m.asc / 2;
  L.edgeKick = L.edgeBase - m.asc - 72 * U; L.edgeRule = L.edgeBase + m.desc + 46 * U;
  L.edgeLS = fitSize('on average.', 108 * U, col, SANS);
  L.edgeL1 = L.edgeRule + 60 * U + L.edgeLS * 0.74; L.edgeL2 = L.edgeL1 + L.edgeLS * 1.06;

  // setup: terminal card + headline
  L.term = { x: CX - col / 2, y: 540 * U, w: col, h: 300 * U };
  L.setKick = L.term.y - 58 * U;
  L.setS = fitSize('Open the folder.', 112 * U, col, SANS);
  L.setL1 = L.term.y + L.term.h + 110 * U + L.setS * 0.74; L.setL2 = L.setL1 + L.setS * 1.1;

  // end card: The / 98¢ / Trade
  L.theS = 112 * U; L.theBase = L.numTop - 34 * U;
  L.tradeS = fitSize('Trade', 600 * U, L.numW, BOLD);
  m = metrics('Trade', L.tradeS, BOLD);
  L.tradeBase = L.numBot + 46 * U + m.asc; L.priceBase = L.tradeBase + m.desc + 124 * U;
  L.discBase = SAFE.y1 - 64 * U;
}

// ───────────────────────────────────────────── small helpers
function drawHero(u) { reveal('98¢', CX, L.numBase, L.numS, u, { ...BOLD, align: 'center', mode: 'slam', by: 'char', stagger: 0.3, color: C.acc }); }
function kicker(str, y, a) { text(str, CX, y, 30 * U, { ...MONO, align: 'center', tracking: 0.3, color: C.dim, alpha: a }); }

// ───────────────────────────────────────────── bar 1 · hook: 98¢ slams in, what it buys, where it sits on the price line
function sceneHook(lt) {
  drawHero(seg(lt, -0.2, 0.4));                       // starts before 0, so frame 0 is mid-slam
  kicker('POLYMARKET', L.hookLab, eOut(seg(lt, 0.1, 0.35)));
  reveal('Near-certain', CX, L.hookL1, L.hookS, seg(lt, BEAT, BEAT + 0.4), { ...SANS, align: 'center', mode: 'mask', color: C.fg });
  reveal('favorites.', CX, L.hookL2, L.hookS, seg(lt, BEAT + 0.08, BEAT + 0.48), { ...SANS, align: 'center', mode: 'mask', color: C.fg });
  drawPriceLine(lt - BEAT * 2);
}
function drawPriceLine(lt) {                          // 0–100¢: the marker races right and lands in the 97–99.5¢ zone
  const u = eOutQuint(seg(lt, 0, 0.35)); if (u <= 0) return;
  const x0 = CX - L.priceW / 2, x1 = CX + L.priceW / 2, y = L.priceY, at = (c) => lerp(x0, x1, c / 100);
  const zu = eOutQuint(seg(lt, 0.32, 0.55)), mx = lerp(x0, at(98), eOutExpo(seg(lt, 0.04, 0.5)));
  line(x0, y, lerp(x0, x1, u), y, rgba(C.fg, 0.3), 12 * U);
  if (zu > 0) roundRect(at(97) - 14 * U, y - 30 * U, at(99.5) - at(97) + 28 * U, 60 * U, 16 * U, rgba(C.acc, 0.3 * zu));
  glow(mx, y, 110 * U, C.acc, 0.45 * zu);
  circle(mx, y, 22 * U, C.acc);
  text('0¢', x0, y + 80 * U, 40 * U, { ...MONO, align: 'center', color: C.dim, alpha: u });
  text('100¢', x1, y + 80 * U, 40 * U, { ...MONO, align: 'center', color: C.dim, alpha: u });
  text('97–99.5¢', at(99.5) + 14 * U, y - 62 * U, 54 * U, { ...MONOB, align: 'right', color: C.acc, alpha: zu });
}

// ───────────────────────────────────────────── bars 2–3 · Jev reads the fine print, then "FIRST." slams on the flag
function sceneRules(lt) {
  const inU = eOutExpo(seg(lt, 0, 0.45));
  withT({ y: (1 - inU) * 150 * U, alpha: clamp(inU * 1.5) }, () => drawRulesCard(lt));
  L.stack.forEach((l, k) => {
    if (k < 2) reveal(l.s, CX, l.base, l.size, seg(lt, BEAT * (k + 1), BEAT * (k + 1) + 0.38), { ...l.o, align: 'center', mode: 'mask', stagger: 0.25, color: l.c });
    else reveal(l.s, CX, l.base, l.size, seg(lt, BAR, BAR + 0.32), { ...l.o, align: 'center', mode: 'slam', by: 'char', stagger: 0.3, color: l.c });
  });
}
function drawRulesCard(lt) {
  const K = L.card, x = K.x, y = K.y, w = K.w, hx = x + K.pad, hy = y + 46 * U;
  roundRect(x + 52 * U, y - 40 * U, w - 104 * U, K.h, 22 * U, C.card3, C.edge, 2 * U);   // a deck: more markets waiting
  roundRect(x + 26 * U, y - 20 * U, w - 52 * U, K.h, 22 * U, C.card2, C.edge, 2 * U);
  roundRect(x, y, w, K.h, 22 * U, C.card, C.edge, 2 * U);
  circle(hx + 7 * U, hy - 8 * U, 7 * U, C.acc, 0.55 + 0.45 * Math.cos(lt * 10));
  const jw = text('JEV', hx + 26 * U, hy, 24 * U, { ...MONOB, color: C.fg, tracking: 0.08 }).w;
  text(' · AI BY TYPESAFE', hx + 26 * U + jw, hy, 24 * U, { ...MONO, color: C.dim, tracking: 0.08 });
  text('MARKET RULES', x + w - K.pad, hy, 22 * U, { ...MONO, align: 'right', color: C.faint, tracking: 0.12 });
  line(x, y + K.head, x + w, y + K.head, C.edge, 2 * U);
  // lines brighten as the beam passes; the catch gets a highlighter exactly on the bar line
  const pos = clamp((lt - SCAN.t0) * SCAN.v, -0.5, SCAN.n - 0.5), fs = 21 * U;
  RULES.forEach((s, i) => {
    const top = K.bodyTop + i * K.lh, base = top + K.lh * 0.7;
    text(s, hx, base, fs, { ...MONO, color: mixHex(C.unread, C.read, clamp(pos - i + 0.5)) });
    if (i === SCAN.hl) {
      const hw = (textW(s, fs, MONO) + 18 * U) * eOutQuint(seg(lt, BAR, BAR + 0.22));
      if (hw > 0) {
        ctx.save(); ctx.beginPath(); ctx.rect(hx - 9 * U, top + 2 * U, hw, K.lh - 4 * U); ctx.clip();
        rect(hx - 9 * U, top + 2 * U, hw, K.lh - 4 * U, C.acc);
        text(s, hx, base, fs, { ...MONO, color: C.ink });
        ctx.restore();
      }
    } else if (pos - i > 0.2) icon('check', x + w - K.pad - 8 * U, top + K.lh / 2, 20 * U, { color: C.dim, lw: 2.6, u: clamp((pos - i - 0.2) * 3) });
  });
  // the beam: Jev reading, with a soft lime wash trailing above it
  const tEnd = SCAN.t0 + (SCAN.n - 0.5) / SCAN.v, ba = clamp((lt - SCAN.t0 + 0.2) / 0.2) * (1 - seg(lt, tEnd, tEnd + 0.25));
  if (ba <= 0) return;
  const by = K.bodyTop + (pos + 0.5) * K.lh;
  withT({ alpha: ba }, () => {
    ctx.save(); ctx.beginPath(); ctx.rect(x, K.bodyTop - 6 * U, w, SCAN.n * K.lh + 12 * U); ctx.clip();
    ctx.fillStyle = linGrad(0, by - 90 * U, 0, by, [[0, rgba(C.acc, 0)], [1, rgba(C.acc, 0.16)]]);
    ctx.fillRect(x, by - 90 * U, w, 90 * U);
    ctx.restore();
    line(x + 2 * U, by, x + w - 2 * U, by, C.acc, 3 * U);
    roundRect(x - 32 * U, by - 17 * U, 72 * U, 34 * U, 17 * U, C.acc);
    text('JEV', x + 4 * U, by + 7 * U, 18 * U, { ...MONOB, align: 'center', color: C.ink, tracking: 0.06 });
  });
}

// ───────────────────────────────────────────── bar 4 · the build: 8,318 past trades count up as 8,318 dots
function sceneCount(lt) {
  const n = TRADES * eOutExpo(clamp(lt / COUNT_T));
  const s = lerp(1.25, 1, eOutExpo(seg(lt, 0, 0.3))) * (1 + 0.07 * pulse(lt, COUNT_T, 0.28));
  withT({ x: CX, y: L.cntCY, scale: s }, () => text(fmtNum(Math.round(n)), 0, L.cntBase - L.cntCY, L.cntS, { ...BOLD, align: 'center', color: C.fg }));
  kicker('PAST TRADES TESTED', L.cntLab, eOut(seg(lt, 0.05, 0.3)));
  drawDots(lt, lt > BAR - QUIET ? 0.8 : 1);             // the field dims a touch in the pause
}
function drawDots(lt, mul) {                           // fresh dots flash bright, then settle dim (three batched fills)
  const G = L.grid, off = (G.p - G.d) / 2, P = [new Path2D(), new Path2D(), new Path2D()];
  for (let i = 0; i < TRADES; i++) {
    const age = lt - G.tA[i]; if (age < 0) continue;
    P[age < 0.1 ? 0 : age < 0.32 ? 1 : 2].rect(G.x0 + G.col[i] * G.p + off, G.y0 + G.row[i] * G.p + off, G.d, G.d);
  }
  ctx.fillStyle = C.fg;
  [1, 0.62, 0.34].forEach((a, k) => withT({ alpha: a * mul }, () => ctx.fill(P[k])));
}

// ───────────────────────────────────────────── bar 5 · DROP (signature move): the dots fuse into one lime slab
function sceneDrop(lt) {
  withT({ x: CX, y: L.cntCY }, () => text('8,318', 0, L.cntBase - L.cntCY, L.cntS, { ...BOLD, align: 'center', color: C.fg }));
  kicker('PAST TRADES TESTED', L.cntLab, 1);
  drawSlab(lt);
  withT({ x: CX, y: L.pctCY, scale: 1 + 0.05 * pulse(lt, 0.3, 0.3) }, () =>
    reveal('99%', 0, L.pctBase - L.pctCY, L.pctS, seg(lt, 0, 0.3), { ...BOLD, align: 'center', mode: 'slam', by: 'char', stagger: 0.25, color: C.ink }));
  reveal('paid out.', CX, L.paidBase, L.paidS, seg(lt, BEAT, BEAT + 0.4), { ...SANS, align: 'center', mode: 'mask', stagger: 0.35, color: C.ink });
}
function drawSlab(lt) {                                // paid trades turn lime and grow outward from the centre; misses stay dark
  const G = L.grid, P = new Path2D(), M = new Path2D(), full = lt > 0.62, lastRow = TRADES - (G.rows - 1) * G.cols;
  if (full) { P.rect(G.x0, G.y0, G.w, (G.rows - 1) * G.p); P.rect(G.x0, G.y0 + (G.rows - 1) * G.p, lastRow * G.p, G.p); }
  for (let i = 0; i < TRADES; i++) {
    const x = G.x0 + (G.col[i] + 0.5) * G.p, y = G.y0 + (G.row[i] + 0.5) * G.p;
    if (G.miss[i]) { M.rect(x - G.d / 2, y - G.d / 2, G.d, G.d); continue; }
    if (full) continue;
    const s = lerp(G.d, G.p + 0.8 * U, eOutQuint(seg(lt, 0.02 + G.dist[i] * 0.3, 0.3 + G.dist[i] * 0.3)));
    P.rect(x - s / 2, y - s / 2, s, s);
  }
  ctx.fillStyle = C.acc; ctx.fill(P);
  ctx.fillStyle = C.bg; ctx.fill(M);
}

// ───────────────────────────────────────────── bar 6 · +0.58% counts in; its line enters on the cut so it's up ≥1.8 s
function sceneEdge(lt) {
  kicker('BACKTEST', L.edgeKick, eOut(seg(lt, 0.05, 0.3)));
  const str = '+' + (0.58 * eOutExpo(seg(lt, 0.03, BEAT))).toFixed(2) + '%';
  const s = lerp(1.45, 1, eOutQuint(seg(lt, 0, 0.26))) * (1 + 0.07 * pulse(lt, BEAT, 0.28));
  withT({ x: CX, y: L.edgeCY, scale: s }, () => text(str, 0, L.edgeBase - L.edgeCY, L.edgeS, { ...BOLD, align: 'center', color: C.acc, alpha: clamp(lt / 0.06) }));
  line(CX - L.edgeW / 2, L.edgeRule, CX + L.edgeW / 2, L.edgeRule, C.acc, 5 * U, eOutQuint(seg(lt, BEAT, BEAT + 0.35)));
  reveal('per trade,', CX, L.edgeL1, L.edgeLS, seg(lt, 0, 0.35), { ...SANS, align: 'center', mode: 'mask', stagger: 0, color: C.fg });
  reveal('on average.', CX, L.edgeL2, L.edgeLS, seg(lt, 0.04, 0.39), { ...SANS, align: 'center', mode: 'mask', stagger: 0, color: C.fg });
}

// ───────────────────────────────────────────── bar 7 · setup: "hi" is typed as the words say it
function sceneSetup(lt) {
  const T = L.term, inU = eOutExpo(seg(lt, 0, 0.4)), enter = BEAT * 2.5;
  kicker('~10 MIN SETUP', L.setKick, eOut(seg(lt, 0, 0.25)));
  withT({ y: (1 - inU) * 90 * U, alpha: clamp(inU * 1.4) }, () => {
    const lit = pulse(lt, enter, 0.5), fs = 76 * U, px = T.x + 44 * U, py = T.y + 188 * U;
    roundRect(T.x, T.y, T.w, T.h, 26 * U, C.card, mixHex(C.edge, C.acc, lit), (2 + 2 * lit) * U);
    [0, 1, 2].forEach((k) => circle(T.x + 36 * U + k * 24 * U, T.y + 36 * U, 7 * U, C.faint));
    text('Claude Code', CX, T.y + 44 * U, 24 * U, { ...MONO, align: 'center', color: C.dim });
    line(T.x, T.y + 70 * U, T.x + T.w, T.y + 70 * U, C.edge, 2 * U);
    text('›', px, py, fs, { ...MONO, color: C.acc });
    const typed = lt >= BEAT * 1.5 ? 'hi' : lt >= BEAT ? 'h' : '', tx = px + textW('› ', fs, MONO);
    if (typed) text(typed, tx, py, fs, { ...MONO, color: C.fg });
    if (lt < enter && (lt >= BEAT * 0.8 || beatPhase(lt, 0.5) < 0.5)) rect(tx + textW(typed, fs, MONO) + 6 * U, py - fs * 0.74, fs * 0.5, fs * 0.9, C.acc);
    if (lt >= enter) [0, 1, 2].forEach((k) => circle(px + 12 * U + k * 34 * U, py + 72 * U, 8 * U, C.acc, 0.3 + 0.7 * (0.5 + 0.5 * Math.sin(TAU * ((lt - enter) * 2.2 - k * 0.22)))));
  });
  reveal('Open the folder.', CX, L.setL1, L.setS, seg(lt, 0.02, 0.45), { ...SANS, align: 'center', mode: 'mask', stagger: 0.3, color: C.fg });
  // "hi." starts at stagger × duration = BEAT × 1.5, the frame the "i" is typed
  reveal('Type hi.', CX, L.setL2, L.setS, seg(lt, BEAT, BEAT + 0.5), { ...SANS, align: 'center', mode: 'mask', stagger: 0.47, colors: [C.fg, C.acc] });
}

// ───────────────────────────────────────────── bar 8 · end card: the same 98¢ as frame 0, then perfectly still from ~14.0 s
function sceneEnd(lt) {
  drawHero(seg(lt, -0.04, 0.34));
  reveal('The', L.numX0 + 6 * U, L.theBase, L.theS, seg(lt, 0.06, 0.42), { ...SANS, align: 'left', mode: 'mask', color: C.fg });
  reveal('Trade', CX, L.tradeBase, L.tradeS, seg(lt, 0.12, 0.5), { ...BOLD, align: 'center', mode: 'mask', color: C.fg });
  reveal('€5 bot for Claude Code', CX, L.priceBase, 60 * U, seg(lt, 0.3, 0.75), { ...SANS, align: 'center', mode: 'rise', stagger: 0.4, colorOf: (w, i) => (i === 0 ? C.fg : C.dim) });
  text('Paper trading · Not financial advice', CX, L.discBase, 26 * U, { ...MONO, align: 'center', tracking: 0.04, color: C.dim, alpha: eOut(seg(lt, 0.5, 0.85)) });
}

// ───────────────────────────────────────────── the film
function frame(t) {
  // cut language: a push-through zoom into each cut and a settle after it (none into the drop: that's the freeze)
  let z = 1;
  for (const b of [0, S.rules, S.count, S.drop, S.setup, S.end]) z *= 1 + 0.06 * pulse(t, b, 0.4);
  for (const b of [S.rules, S.count, S.setup, S.end]) if (t < b) z *= 1 + 0.09 * eInExpo(seg(t, b - 0.14, b));
  // a slow push-in during each scene, frozen in the pause, none on the end card
  const st = [S.hook, S.rules, S.count, S.drop, S.edge, S.setup, S.end];
  let k = 0; while (k < st.length - 1 && t >= st[k + 1]) k++;
  if (k < st.length - 1) z *= 1 + 0.025 * seg(t, st[k], st[k + 1] - (k === 2 ? QUIET : 0));
  const shake = U * (12 * pulse(t, 0, 0.25) + 9 * pulse(t, S.rules + BAR, 0.22) + 18 * pulse(t, S.drop, 0.32) + 7 * pulse(t, S.edge, 0.2) + 9 * pulse(t, S.end, 0.22));
  camera({ zoom: z, shake }, () => {
    if (t < S.rules) sceneHook(t);
    else if (t < S.count) sceneRules(t - S.rules);
    else if (t < S.drop) sceneCount(t - S.count);
    else if (t < S.edge) sceneDrop(t - S.drop);
    else if (t < S.setup) sceneEdge(t - S.edge);
    else if (t < S.end) sceneSetup(t - S.setup);
    else sceneEnd(t - S.end);
  });
  if (t < S.edge) wipe(eInExpo(seg(t, S.edge - 0.2, S.edge)), 'up', C.bg);   // the dark pushes the lime slab away
  flash(pulse(t, S.drop, 0.14) * 0.55, C.fg);
}
