'use strict';
// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE · motion-graphics explainer · "How Motion Director works" · 16:9 · 15 s · 112 BPM = 7 bars
//
// The idea: the prompt typed at the start makes the MP4 that lands at the end, and the camera
// pushes THROUGH that MP4's thumbnail into the end card. The film is its own proof.
//
// How the file is organised (copy the structure, replace the content):
//   C        one palette. The accent C.acc marks the one thing that matters in each moment.
//   S        every moment on the beat grid, in seconds (beats(n)). score.js reads S directly
//            (same global scope), so picture and sound can't drift. Retime the film here only.
//   QC_AT    key moments the QC sheet must include (hook, landing, drop, last frame).
//   Content  the words, prompt, code and answers, as data.
//   Layout   positions in U and frame fractions (SAFE, W, H), so other formats adapt.
//   Scenes   one function per scene, each drawn in its own world slot and given LOCAL time
//            (lt = t - its start). The camera travels between the slots:
//              slot (0,0) idea ─whip→ (W,0) rounds ─whip→ (2W,0) code ─drop↓ (2W,H) desktop
//            then camFit() pushes through the thumbnail into the end card (screen space).
//   frame    draws the film at t; motionBlur() only while the camera is fast.
// ═════════════════════════════════════════════════════════════════════════════

const C = {
  bg: FILM.bg, ink: '#15151b', acc: '#ff5a1f', card: '#ffffff', soft: '#f7f4ee', line: '#ddd5c8', muted: '#726c62', dot: '#ddd6c9',
  term: '#18181f', termHi: '#22222b', termEdge: '#3a3a46', termText: '#ecebe6', termMuted: '#75727f',
  syn: { kw: '#ff8a5c', fn: '#8fb3ff', str: '#f3cd7d', num: '#a8e0a0', com: '#75727f', txt: '#ecebe6' },
};

const S = {
  pull: beats(1), pulled: beats(3), enter: beats(4), pan1: beats(5.4),                    // 01 idea
  q: beats(6), card1: beats(6.5), pick1: beats(8), card2: beats(8.5), pick2: beats(10), pan2: beats(11.4), // 02 rounds
  code: beats(12), chipA: beats(12.5), chipB: beats(13), strike1: beats(13.5), strike2: beats(14),        // 03 code
  fold: beats(14.75), still: beats(15.25), fall: beats(15.6),                             // fold → silence → fall
  drop: beats(16), pill: beats(17), note: beats(17.75), push: beats(20.25),               // 04 desktop (drop at 57%)
  end: beats(22), cta: beats(24),                                                          // end card
};
const QC_AT = [0, S.pulled + 0.3, S.pick2 + 0.2, S.drop + 0.08, S.note + 0.7, S.end - 1 / FPS, DUR - 1 / FPS];

// ── content
const PROMPT = '/motion-director explain', PRE = 7;                  // "/motion" is already typed on frame 0
const FILE = 'explain-motion-director.mp4';
const TYPE_T = [];                                               // keystroke times (score.js clicks on each)
for (let i = PRE, k = 0.03; i < PROMPT.length; i++) { TYPE_T.push(k); k += 0.05 + 0.04 * h01('key', i) + (PROMPT[i] === ' ' ? 0.06 : 0); }
const ROUNDS = [                                                 // local times (from S.q) so the scene stays local
  { q: 'Where will it be posted?', opts: ['9:16', '16:9', '1:1'], pick: 1, t0: S.card1 - S.q, tp: S.pick1 - S.q },
  { q: 'Pick a look.', opts: ['Kinetic', 'Motion', 'Neon'], pick: 1, t0: S.card2 - S.q, tp: S.pick2 - S.q },
];
const STRIKES = [['stock footage', S.chipA - S.code, S.strike1 - S.code], ['editing app', S.chipB - S.code, S.strike2 - S.code]];
const CODE = [
  '// scenes.js', 'const S = { idea: 0, drop: beats(16) };', 'function drawFilm(t) {', '  camera(camAt(t), () => {',
  '  sceneIdea(t);', '  sceneRounds(t - S.q);', '  sceneCode(t - S.code);', '  sceneDesktop(t - S.drop);', '}',
  'function sceneDesktop(lt) {', "  headline('04', 'On your', 'Desktop.');", '  mp4(lerp(84, 416, spring(lt)));', '}',
  '// score.js', 'function score(A) {', "  A.bell(0, 'D5', 1.4, 0.6);", '  A.riser(S.code, 1.73, 0.85);',
  '  A.silence(S.still + 0.1, S.drop);', '  A.impact(S.drop, 1);', "  A.bell(S.cta, 'G5', 3, 1);", '}',
];
const SCORE_LINE = 13, LINE_T0 = 0.07, LINE_DT = 0.065;
const CODE_TOK = CODE.map((s) => {                               // [text, colour] tokens for syntax colour
  const re = /(\/\/.*)|('[^']*')|\b(function|const)\b|(\b\d+(?:\.\d+)?\b)|([A-Za-z_$][\w$.]*)(?=\()/g, out = []; let last = 0, m;
  while ((m = re.exec(s))) {
    if (m.index > last) out.push([s.slice(last, m.index), C.syn.txt]);
    out.push([m[0], m[1] ? C.syn.com : m[2] ? C.syn.str : m[3] ? C.syn.kw : m[4] ? C.syn.num : C.syn.fn]); last = re.lastIndex;
  }
  if (last < s.length) out.push([s.slice(last), C.syn.txt]);
  return out;
});

// ── layout
const MONO = { font: 'Geist Mono', weight: 400 }, SANS = { font: 'Instrument Sans', weight: 700 }, HAND = { font: 'Nothing You Could Do', weight: 400 };
const LX = SAFE.x0 + 36 * U;                                     // left text column (headlines)
const PX0 = W * 0.47, PX1 = SAFE.x1, PW = PX1 - PX0, PCX = (PX0 + PX1) / 2;   // right visual panel
const HY1 = CY - 14 * U;                                         // headline line-1 baseline
let HS = 120 * U;                                                // headline size, fitted in setup()
const TERM = { x: PX0, y: CY - 200 * U, w: PW, h: 400 * U };
const BOX = { x: TERM.x + 36 * U, y: TERM.y + 176 * U, w: TERM.w - 72 * U, h: 130 * U };
const PROMPT_FS = 48 * U, PROMPT_X = BOX.x + 32 * U + PROMPT_FS * 1.25;   // where the typed text starts
const CARD_H = 236 * U;
const EDIT = { x: PX0, y: CY - 270 * U, w: PW, h: 520 * U };
const MON = { x: PX0, y: CY - 352 * U, w: PW, h: 560 * U, bez: 14 * U };
MON.ix = MON.x + MON.bez; MON.iy = MON.y + MON.bez; MON.iw = MON.w - 2 * MON.bez; MON.ih = MON.h - 2 * MON.bez;
const TW = 400 * U, TH = TW * H / W, TX = MON.ix + MON.iw * 0.36, TY = MON.iy + MON.ih * 0.42;   // MP4 thumbnail centre
const THUMB = { x: 2 * W + TX - TW / 2, y: H + TY - TH / 2, w: TW, h: TH };                        // ...in world coords

async function setup() {                                         // one headline size that fits every line
  const lines = ['Type', 'an idea.', 'Answer', 'two rounds.', 'Written', 'as code.', 'On your', 'Desktop.'];
  HS = Math.min(120 * U, ...lines.map((l) => fitSize(l, 120 * U, PX0 - 70 * U - LX, { tracking: -0.03 })));
}

// ───────────────────────────────────────────────────────────── shared pieces
function softCard(x, y, w, h, r, fill, a = 0.13) {
  ctx.save(); ctx.shadowColor = rgba('#2a2418', a); ctx.shadowBlur = 44 * U * curScale(); ctx.shadowOffsetY = 18 * U * curScale();
  roundRect(x, y, w, h, r, fill); ctx.restore();
}
function pill(cx, cy, label, fs, o) {                            // centred label on a rounded pill; returns its width
  const w = textW(label, fs, o.font) + (o.pad ?? 36 * U) * 2, h = o.h ?? fs * 1.8;
  roundRect(cx - w / 2, cy - h / 2, w, h, o.r ?? h / 2, o.fill, o.stroke, 2.5 * U);
  text(label, cx, cy + capH(fs, o.font) / 2, fs, { ...o.font, align: 'center', color: o.color });
  return w;
}
function headline(num, l1, l2, accWord, lt) {                    // "01 ——" + two mask-revealed lines, left third
  if (lt <= 0) return;
  const lu = eOutQuint(seg(lt, 0, 0.4)), ly = HY1 - HS * 0.78 - 46 * U;
  text(num, LX, ly + (1 - lu) * 16 * U, 30 * U, { ...MONO, weight: 700, color: C.acc, alpha: lu, tracking: 0.06 });
  line(LX + 64 * U, ly - 11 * U, LX + 134 * U, ly - 11 * U, C.acc, 3 * U, lu);
  const o = { tracking: -0.03, mode: 'mask', stagger: 0.3, colorOf: (w) => (w === accWord ? C.acc : C.ink) };
  reveal(l1, LX, HY1, HS, seg(lt, 0.03, 0.6), o);
  reveal(l2, LX, HY1 + HS, HS, seg(lt, 0.1, 0.67), o);
}
function dotGrid(cam) {                                          // background dots at half parallax: sells every camera move
  const z = Math.sqrt(cam.zoom), sp = 54 * U, ox = cam.x / 2, oy = cam.y / 2;
  ctx.save(); ctx.translate(CX, CY); ctx.scale(z, z); ctx.translate(-ox, -oy); ctx.fillStyle = C.dot; ctx.beginPath();
  for (let gx = Math.floor((ox - CX / z) / sp) * sp; gx <= ox + CX / z + sp; gx += sp)
    for (let gy = Math.floor((oy - CY / z) / sp) * sp; gy <= oy + CY / z + sp; gy += sp) { ctx.moveTo(gx + 2.2 * U, gy); ctx.arc(gx, gy, 2.2 * U, 0, TAU); }
  ctx.fill(); ctx.restore();
}

// ───────────────────────────────────────────────────────────── 01 · idea  (slot 0,0)
// A giant prompt is already typing on frame 0; the camera pulls back to reveal the terminal and the headline.
function sceneIdea(lt) {
  headline('01', 'Type', 'an idea.', 'idea.', lt - (S.pulled - 0.35));
  const dy = snoise(lt * 0.5, 4) * 4 * U, { x, w, h } = TERM, y = TERM.y + dy;
  softCard(x, y, w, h, 28 * U, C.term, 0.3);
  ctx.save(); ctx.beginPath(); ctx.roundRect(x, y, w, h, 28 * U); ctx.clip(); rect(x, y, w, 90 * U, C.termHi); ctx.restore();
  for (let i = 0; i < 3; i++) circle(x + 42 * U + i * 28 * U, y + 45 * U, 9 * U, '#3b3b47');
  text('Claude Code', x + w / 2, y + 45 * U + capH(44 * U, SANS) / 2, 44 * U, { ...SANS, color: C.termText, align: 'center' });
  text('~/projects', x + 44 * U, y + 146 * U, 24 * U, { ...MONO, color: C.termMuted });
  const by = BOX.y + dy, sent = pulse(lt, S.enter, 0.6), fs = PROMPT_FS, ty = by + BOX.h / 2 + capH(fs, MONO) / 2;
  roundRect(BOX.x, by, BOX.w, BOX.h, 18 * U, rgba('#ffffff', 0.035 + 0.06 * sent), mixHex(C.termEdge, C.acc, clamp(sent * 1.4)), (2 + 2 * sent) * U);
  text('>', BOX.x + 32 * U, ty, fs, { ...MONO, weight: 700, color: C.acc });
  const n = PRE + TYPE_T.filter((k) => k <= lt).length, r = text(PROMPT.slice(0, n), PROMPT_X, ty, fs, { ...MONO, color: C.termText });
  const lastKey = n > PRE ? TYPE_T[n - PRE - 1] : -1;
  if (lt < S.enter && (lt - lastKey < 0.4 || beatPhase(lt) < 0.5)) rect(r.x + r.w + 6 * U, ty - capH(fs, MONO) * 1.15, fs * 0.55, capH(fs, MONO) * 1.35, C.acc);
}

// ───────────────────────────────────────────────────────────── 02 · rounds  (slot W,0)
// Two question cards pop in; the cursor answers each one on the beat.
function cardRect(i) { return { x: PX0, y: CY - CARD_H - 16 * U + i * (CARD_H + 32 * U), w: PW, h: CARD_H }; }
function chipsOf(i) {
  const r = cardRect(i), fs = 44 * U; let x = r.x + 44 * U;
  return ROUNDS[i].opts.map((label) => { const w = textW(label, fs, SANS) + 72 * U, c = { label, cx: x + w / 2, cy: r.y + 164 * U, w }; x += w + 14 * U; return c; });
}
function questionCard(i, lt) {
  const q = ROUNDS[i], r = cardRect(i), p = lt - q.t0; if (p < 0) return;
  const cx = r.x + r.w / 2, cy = r.y + r.h / 2, on = eOutQuint(seg(lt, q.tp, q.tp + 0.12));
  withT({ x: cx, y: cy, scale: lerp(0.82, 1, spring(p, 2.3, 0.5)), alpha: clamp(p * 7) }, () => withT({ x: -cx, y: -cy }, () => {
    softCard(r.x, r.y, r.w, r.h, 28 * U, C.card);
    const nw = text(String(i + 1), r.x + 44 * U, r.y + 84 * U, 46 * U, { color: C.acc }).w;
    text(q.q, r.x + 44 * U + nw + 22 * U, r.y + 84 * U, 46 * U, { color: C.ink, tracking: -0.01 });
    chipsOf(i).forEach((c, k) => {
      const cu = spring(p - 0.1 - k * 0.07, 2.6, 0.5), sel = k === q.pick ? on : 0; if (cu <= 0) return;
      withT({ x: c.cx, y: c.cy, scale: lerp(0.6, 1, cu) * (1 + 0.1 * (k === q.pick ? pulse(lt, q.tp, 0.3) : 0)), alpha: clamp(cu * 3) }, () =>
        pill(0, 0, c.label, 44 * U, { font: SANS, h: 80 * U, fill: mixHex(C.soft, C.acc, sel), stroke: sel > 0.5 ? null : C.line, color: mixHex(C.ink, '#ffffff', sel) }));
    });
    const du = seg(lt, q.tp + 0.05, q.tp + 0.4), bx = r.x + r.w - 60 * U, by = r.y + 70 * U;   // "answered" badge
    if (du > 0) { circle(bx, by, 26 * U * eOutBack(clamp(du * 1.8)), C.acc); icon('check', bx, by, 30 * U, { color: '#ffffff', lw: 3, u: eOutQuint(seg(du, 0.3, 1)) }); }
  }));
}
function drawCursor(lt) {
  const [c1, c2] = [chipsOf(0)[1], chipsOf(1)[1]], [a, b] = ROUNDS;
  const P = [[PX1 + 60 * U, CY + 480 * U], [c1.cx + c1.w * 0.3, c1.cy + 18 * U], [c2.cx + c2.w * 0.3, c2.cy + 18 * U], [c2.cx + 190 * U, c2.cy + 160 * U]];
  const moves = [[a.t0 + beats(0.4), a.tp - 0.05], [a.tp + beats(0.9), b.tp - 0.05], [b.tp + beats(1), b.tp + beats(2.4)]];
  if (lt < moves[0][0]) return;
  let p = P[0];
  moves.forEach(([t0, t1], k) => { if (lt >= t0) { const u = eInOutQ(seg(lt, t0, t1)), arc = Math.sin(Math.PI * u) * 46 * U; p = [lerp(P[k][0], P[k + 1][0], u) + arc / 2, lerp(P[k][1], P[k + 1][1], u) - arc]; } });
  ROUNDS.forEach(({ tp }) => { const u = seg(lt, tp, tp + 0.45); if (u > 0 && u < 1) ringStroke(p[0], p[1], lerp(8, 64, eOutQuint(u)) * U, rgba(C.acc, 1 - u), 4 * U); });
  const k = 58 * U / 24, click = Math.max(...ROUNDS.map(({ tp }) => pulse(lt, tp, 0.22)));
  withT({ x: p[0], y: p[1], scale: 1 - 0.16 * click }, () => icon('cursor', 7 * k, 8.5 * k, 58 * U, { fill: C.ink, color: '#ffffff', lw: 1.5 }));
}
function sceneRounds(lt) {
  headline('02', 'Answer', 'two rounds.', 'two', lt + 0.16);
  questionCard(0, lt); questionCard(1, lt); drawCursor(lt);
}

// ───────────────────────────────────────────────────────────── 03 · code  (slot 2W,0)
// Code streams in while a time-lapse clock runs to ~7 min; "stock footage" and "editing app" get struck out.
// On S.fold the editor squeezes into an orange tile (fallingTile takes over).
function strikeChips(lt) {
  const fs = 44 * U, h = 76 * U, gap = 16 * U; let x = LX, y = HY1 + HS + 64 * U + h / 2;
  STRIKES.forEach(([label, ta, ts]) => {
    const w = textW(label, fs, SANS) + 56 * U;
    if (x + w > PX0 - 50 * U) { x = LX; y += h + gap; }                 // wrap to a second row if needed
    if (lt >= ta) {
      const st = eOutQuint(seg(lt, ts, ts + 0.22));
      withT({ x: x + w / 2, y, scale: lerp(0.6, 1, spring(lt - ta, 2.5, 0.5)) * (1 + 0.06 * pulse(lt, ts, 0.25)), alpha: clamp((lt - ta) * 7) }, () => {
        pill(0, 0, label, fs, { font: SANS, pad: 28 * U, h, fill: mixHex(C.card, C.bg, st), stroke: mixHex(C.ink, C.line, st), color: mixHex(C.ink, C.muted, st) });
        line(-w / 2 + 14 * U, -capH(fs, SANS) * 0.1, w / 2 - 14 * U, -capH(fs, SANS) * 0.1, C.acc, 6 * U, st);
      });
    }
    x += w + gap;
  });
}
function editorContents(lt, { x, y, w, h }) {
  rect(x, y, w, 64 * U, C.termHi);
  const shown = (lt - LINE_T0) / LINE_DT + 1, onScore = shown > SCORE_LINE + 1;
  const t1 = text('scenes.js', x + 40 * U, y + 41 * U, 22 * U, { ...MONO, color: onScore ? C.termMuted : C.termText });
  const t2 = text('score.js', t1.x + t1.w + 36 * U, y + 41 * U, 22 * U, { ...MONO, color: onScore ? C.termText : C.termMuted });
  const tab = onScore ? t2 : t1; rect(tab.x, y + 60 * U, tab.w, 4 * U, C.acc);
  const fs = 25 * U, LH = 38 * U, top = y + 114 * U, cap = Math.floor((h - 104 * U) / LH), cw = textW('M', fs, MONO);
  const scroll = Math.max(0, Math.min(shown, CODE.length) - cap) * LH, cur = Math.min(CODE.length, Math.floor(shown)) - 1;
  ctx.save(); ctx.beginPath(); ctx.rect(x, y + 64 * U, w, h - 64 * U); ctx.clip();
  for (let i = 0; i <= cur; i++) {
    const ly = top + i * LH - scroll; if (ly < y + 30 * U) continue;
    if (i === cur) rect(x, ly - 27 * U, w, LH, rgba('#ffffff', 0.05));
    text(String(i + 1), x + 70 * U, ly, 20 * U, { ...MONO, color: C.termMuted, align: 'right' });
    let cx = x + 96 * U, left = Math.floor(CODE[i].length * clamp((lt - LINE_T0 - i * LINE_DT) / 0.12));
    for (const [s, col] of CODE_TOK[i]) { if (left <= 0) break; const part = s.slice(0, left); text(part, cx, ly, fs, { ...MONO, color: col }); cx += part.length * cw; left -= part.length; }
    if (i === cur) rect(cx + 3 * U, ly - 21 * U, 12 * U, 26 * U, C.acc);
  }
  ctx.restore();
}
function sceneCode(lt) {
  headline('03', 'Written', 'as code.', 'code.', lt + 0.16);
  strikeChips(lt);
  const fu = seg(lt, S.fold - S.code, S.still - S.code); if (fu >= 1) return;
  const ant = fu < 0.3 ? Math.sin(Math.PI * fu / 0.3) : 0, a = eInOutExpo(seg(fu, 0.22, 1));   // anticipation, then squeeze
  const cw = lerp(EDIT.w, 84 * U, a) * (1 + 0.035 * ant), ch = lerp(EDIT.h, 84 * U, a) * (1 + 0.035 * ant), rr = lerp(28, 22, a) * U;
  const cy = EDIT.y + EDIT.h / 2 + (1 - a) * snoise(lt * 0.5, 7) * 4 * U, x = PCX - cw / 2, y = cy - ch / 2;
  softCard(x, y, cw, ch, rr, mixHex(C.term, C.acc, sstep(0.55, 1, a)), 0.3);
  const fade = 1 - sstep(0, 0.45, a);
  if (fade > 0) {
    ctx.save(); ctx.beginPath(); ctx.roundRect(x, y, cw, ch, rr); ctx.clip(); ctx.globalAlpha *= fade;
    withT({ x: PCX, y: cy, sx: cw / EDIT.w, sy: ch / EDIT.h }, () => withT({ x: -PCX, y: -(EDIT.y + EDIT.h / 2) }, () => editorContents(lt, EDIT)));
    ctx.restore();
  }
  const pu = spring(lt - 0.15, 2.4, 0.5);                                   // the time-lapse clock pill
  if (pu > 0 && fade > 0) withT({ x: PX1 - 170 * U, y: EDIT.y + EDIT.h, scale: lerp(0.6, 1, pu) * (0.4 + 0.6 * fade), alpha: clamp(pu * 3) * fade }, () => {
    softCard(-150 * U, -48 * U, 300 * U, 96 * U, 48 * U, C.card, 0.18);
    icon('clock', -88 * U, 0, 46 * U, { color: C.acc, lw: 2.2 });
    const secs = Math.round(lerp(0, 432, sstep(0.05, 1.45, lt)));
    text(`${String(Math.floor(secs / 60)).padStart(2, '0')}:${String(secs % 60).padStart(2, '0')}`, 34 * U, capH(48 * U, MONO) / 2, 48 * U, { ...MONO, weight: 700, color: C.ink, align: 'center', tabular: true });
  });
}
// The folded film: an orange tile that hangs in the silence, then falls from slot 03 onto the desktop (world coords).
function fallingTile(t) {
  if (t < S.still || t >= S.drop) return;
  const e = eIn(seg(t, S.fall, S.drop)), st = 1 + 0.55 * Math.sin(Math.PI * e), beat = 1 + 0.08 * pulse(t, S.still, 0.25);
  withT({ x: lerp(2 * W + PCX, 2 * W + TX, e), y: lerp(EDIT.y + EDIT.h / 2, H + TY, e), sx: beat / Math.sqrt(st), sy: beat * st }, () => {
    glow(0, 0, 170 * U, C.acc, 0.35, 'source-over');
    roundRect(-42 * U, -42 * U, 84 * U, 84 * U, 22 * U, C.acc);
    icon('play', 2 * U, 0, 38 * U, { fill: '#ffffff', color: '#ffffff', lw: 1.5, alpha: clamp((t - S.still) * 10) });
  });
}

// ───────────────────────────────────────────────────────────── 04 · desktop  (slot 2W,H)
// DROP: the tile slams onto a desktop and blooms into the MP4; "original soundtrack" and "you're watching it" follow.
function folder(x, y, label) {
  roundRect(x - 40 * U, y - 37 * U, 36 * U, 16 * U, 5 * U, '#9db0ff');
  roundRect(x - 40 * U, y - 28 * U, 80 * U, 58 * U, 9 * U, '#7d95ff');
  text(label, x, y + 58 * U, 16 * U, { font: 'Instrument Sans', weight: 400, color: '#ffffff', alpha: 0.85, align: 'center' });
}
function monitor() {
  const m = MON, mx = m.x + m.w / 2;
  fillPts([[mx - 70 * U, m.y + m.h - 4 * U], [mx + 70 * U, m.y + m.h - 4 * U], [mx + 92 * U, m.y + m.h + 62 * U], [mx - 92 * U, m.y + m.h + 62 * U]], '#d6cebf');
  softCard(mx - 150 * U, m.y + m.h + 58 * U, 300 * U, 16 * U, 8 * U, '#c9c0b0', 0.1);
  softCard(m.x, m.y, m.w, m.h, 30 * U, C.ink, 0.22);
  ctx.save(); ctx.beginPath(); ctx.roundRect(m.ix, m.iy, m.iw, m.ih, 16 * U); ctx.clip();
  ctx.fillStyle = linGrad(m.ix, m.iy, m.ix + m.iw, m.iy + m.ih, [[0, '#2c3160'], [1, '#191b31']]); ctx.fillRect(m.ix, m.iy, m.iw, m.ih);
  glow(m.ix + m.iw * 0.78, m.iy + m.ih * 0.05, 520 * U, C.acc, 0.5, 'source-over');
  glow(m.ix + m.iw * 0.05, m.iy + m.ih, 480 * U, '#5b74ff', 0.4, 'source-over');
  rect(m.ix, m.iy, m.iw, 30 * U, rgba('#ffffff', 0.1));
  circle(m.ix + 22 * U, m.iy + 15 * U, 6 * U, '#ffffff', 0.85);
  let bx = m.ix + 42 * U; [54, 38, 46, 34].forEach((bw) => { roundRect(bx, m.iy + 11 * U, bw * U, 8 * U, 4 * U, rgba('#ffffff', 0.4)); bx += (bw + 16) * U; });
  text('9:41', m.ix + m.iw - 22 * U, m.iy + 21 * U, 16 * U, { ...MONO, weight: 700, color: '#ffffff', alpha: 0.8, align: 'right' });
  folder(m.ix + m.iw - 80 * U, m.iy + 104 * U, 'Projects');
  folder(m.ix + m.iw - 80 * U, m.iy + 228 * U, 'Invoices');
  ctx.restore();
}
function mp4(lt) {
  if (lt < 0) return;
  const m = spring(lt, 2.4, 0.42), sq = pulse(lt, 0, 0.2), ru = seg(lt, 0, 0.6);
  const bw = lerp(84 * U, TW + 16 * U, m), bh = lerp(84 * U, TH + 16 * U, m), iw = bw - 16 * U, ih = bh - 16 * U;
  if (ru < 1) {                                                              // impact: shock ring + burst
    ringStroke(TX, TY, lerp(70, 520, eOutQuint(ru)) * U, rgba(C.acc, 0.9 * (1 - ru)), (2 + 8 * (1 - ru)) * U);
    burst(TX, TY, lerp(90, 250, eOutQuint(ru)) * U, lerp(120, 330, eOutQuint(ru)) * U, 14, 0.2, '#ffffff', 4 * U, 1 - ru);
  }
  withT({ x: TX, y: TY, sx: 1 + 0.2 * sq, sy: 1 - 0.2 * sq }, () => {       // squash on landing, bloom into the thumbnail
    ctx.save(); ctx.shadowColor = rgba('#000000', 0.4); ctx.shadowBlur = 40 * U * curScale(); ctx.shadowOffsetY = 16 * U * curScale();
    roundRect(-bw / 2, -bh / 2, bw, bh, lerp(22, 14, m) * U, mixHex(C.acc, '#ffffff', clamp(lt / 0.12))); ctx.restore();
    if (iw <= 0 || ih <= 0) return;
    ctx.save(); ctx.beginPath(); ctx.rect(-iw / 2, -ih / 2, iw, ih); ctx.clip(); ctx.globalAlpha *= clamp((lt - 0.03) / 0.14);
    withT({ sx: iw / W, sy: ih / H }, () => withT({ x: -CX, y: -CY }, () => endCard(0, true)));   // the thumbnail IS the end card
    ctx.restore();
  });
  const fu = spring(lt - 0.14, 2.6, 0.5);
  if (fu > 0) withT({ x: TX, y: TY + TH / 2 + 50 * U, scale: lerp(0.6, 1, fu), alpha: clamp(fu * 3) }, () =>
    pill(0, 0, FILE, 44 * U, { font: MONO, pad: 22 * U, h: 64 * U, r: 14 * U, fill: C.acc, color: '#ffffff' }));
}
function soundPill(lt) {
  if (lt < 0) return;
  const fs = 44 * U, label = 'original soundtrack', h = 88 * U, w = 180 * U + textW(label, fs, SANS) + 40 * U;
  withT({ x: LX, y: HY1 + HS + 64 * U + h / 2, scale: lerp(0.7, 1, spring(lt, 2.4, 0.5)), alpha: clamp(lt * 7) }, () => {
    roundRect(0, -h / 2, w, h, h / 2, C.ink);
    waveform(40 * U, 0, 116 * U, 46 * U, lt, { bars: 9, color: C.acc, id: 'pill', energy: (tt) => 0.9 + 0.7 * Math.exp(-5 * beatPhase(tt + S.drop)) });
    text(label, 180 * U, capH(fs, SANS) / 2, fs, { ...SANS, color: '#ffffff' });
  });
}
function annotation(lt) {
  if (lt < 0) return;
  const fs = 46 * U, label = "you're watching it", tw = textW(label, fs, HAND);
  const tx = MON.ix + MON.iw - 36 * U - tw, ty = MON.iy + MON.ih - 40 * U;
  const p0 = [tx + tw * 0.62, ty - 56 * U], p3 = [TX + TW / 2 + 22 * U, TY + 30 * U];
  const pts = bez(p0, [p0[0] + 40 * U, p0[1] - 80 * U], [p3[0] + 90 * U, p3[1] + 20 * U], p3, 28), u = eOutQuint(seg(lt, 0, 0.4));
  drawOn(pts, u, C.acc, 4.5 * U);
  if (u > 0.9) { const [qx, qy] = pts[pts.length - 4], ang = Math.atan2(p3[1] - qy, p3[0] - qx); arrow(qx, qy, p3[0] + Math.cos(ang), p3[1] + Math.sin(ang), C.acc, 4.5 * U, 1, 20 * U * clamp((u - 0.9) * 10)); }
  withT({ x: tx, y: ty, rot: -0.05 }, () => {                                // hand-written in, left to right
    ctx.save(); ctx.beginPath(); ctx.rect(-10 * U, -70 * U, (tw + 20 * U) * eOutQuint(seg(lt, 0.12, 0.6)), 110 * U); ctx.clip();
    text(label, 0, 0, fs, { ...HAND, color: C.acc, stroke: C.acc, lw: 1.4 * U }); ctx.restore();
  });
}
function sceneDesktop(lt) {
  monitor();
  mp4(lt);
  headline('04', 'On your', 'Desktop.', 'Desktop.', lt);
  soundPill(lt - (S.pill - S.drop));
  annotation(lt - (S.note - S.drop));
}

// ───────────────────────────────────────────────────────────── END · screen space (also the MP4's thumbnail)
// "Motion Director." lands on the hit, the tagline follows on the beats, the CTA echoes the hook so the loop closes.
function endCard(lt, poster = false) {
  rect(0, 0, W, H, C.bg);
  withT({ x: CX, y: CY, scale: poster ? 1 : 1 + 0.035 * Math.sin(Math.PI * clamp(lt / 0.45)) }, () => withT({ x: -CX, y: -CY }, () => {
    const s = 236 * U, y0 = CY - 30 * U, o = { tracking: -0.045, color: C.ink }, dr = 23 * U;
    const ww = textW('Motion Director', s, o), x0 = CX - (ww + 12 * U + dr * 2) / 2;
    text('Motion Director', x0, y0, s, o);
    circle(x0 + ww + 12 * U + dr, y0 - dr, dr * (1 + (poster ? 0 : 0.45 * pulse(lt, 0, 0.35) + 0.25 * pulse(lt, S.cta - S.end, 0.3))), C.acc);
    if (poster) return;
    const ts = 66 * U, ty = y0 + 124 * U, to = { tracking: -0.02, mode: 'mask' }, wA = textW('Idea in. ', ts, to), tx = CX - (wA + textW('Film out.', ts, to)) / 2;
    reveal('Idea in.', tx, ty, ts, seg(lt, beats(0.5), beats(0.5) + 0.4), { ...to, color: C.muted });
    reveal('Film out.', tx + wA, ty, ts, seg(lt, beats(1), beats(1) + 0.4), { ...to, color: C.ink });
    const cl = lt - (S.cta - S.end); if (cl < 0) return;
    withT({ x: CX, y: ty + 116 * U, scale: lerp(0.7, 1, spring(cl, 2.4, 0.5)), alpha: clamp(cl * 7) }, () => {
      const fs = 44 * U, cmd = '> /motion-director', w = textW(cmd, fs, MONO) + 130 * U, x = -w / 2 + 44 * U, by = capH(fs, MONO) / 2;
      roundRect(-w / 2, -44 * U, w, 88 * U, 44 * U, C.term);
      text('>', x, by, fs, { ...MONO, weight: 700, color: C.acc });
      const r = text('/motion-director', x + textW('> ', fs, MONO), by, fs, { ...MONO, color: C.termText });
      if (beatPhase(lt + S.end) < 0.55 || lt + S.end > DUR - 0.5) rect(r.x + r.w + 8 * U, by - capH(fs, MONO) * 1.15, 22 * U, capH(fs, MONO) * 1.35, C.acc);
    });
  }));
}

// ───────────────────────────────────────────────────────────── camera + frame
function hookCam(t) {                                                        // frame 0: tight on the prompt, tracking the caret
  const n = PRE + TYPE_T.filter((k) => k <= t).length, caret = PROMPT_X + n * textW('M', PROMPT_FS, MONO), w = 520 * U;
  const c = camFit({ x: clamp(caret - 0.72 * w, BOX.x - 24 * U, 1e9), y: BOX.y + BOX.h / 2 - w * H / W / 2, w, h: w * H / W }, 1);
  return { ...c, zoom: c.zoom * (1 + 0.04 * seg(t, 0, S.pull)) };             // slow creep while typing
}
const pushEase = (u) => eIn(u) - 0.05 * Math.sin(Math.PI * clamp(u / 0.4));  // small pull-back, then accelerate INTO the hit
function camAt(t) {
  if (t >= S.push) return camFit(THUMB, seg(t, S.push, S.end), { x: 2 * W + CX, y: H + CY, zoom: 1 }, 'fill', pushEase);
  const c = camFit({ x: 0, y: 0, w: W, h: H }, seg(t, S.pull, S.pulled), hookCam(Math.min(t, S.pull)));   // pull back
  return {
    x: c.x + W * eInOutQ(seg(t, S.pan1, S.q)) + W * eInOutQ(seg(t, S.pan2, S.code)),   // two whip-pans
    y: c.y + H * eIn(seg(t, S.fall, S.drop)), zoom: c.zoom,                          // the drop
    shake: 16 * U * pulse(t, S.drop, 0.4), seed: 'drop',
  };
}
function drawFilm(t) {
  if (t >= S.end) return endCard(t - S.end);
  const cam = camAt(t);
  dotGrid(cam);
  camera(cam, () => {
    if (t < S.q) sceneIdea(t);
    if (t >= S.pan1 && t < S.code) withT({ x: W }, () => sceneRounds(t - S.q));
    if (t >= S.pan2 && t < S.drop) withT({ x: 2 * W }, () => sceneCode(t - S.code));
    if (t >= S.fall) withT({ x: 2 * W, y: H }, () => sceneDesktop(t - S.drop));
    fallingTile(t);
  });
}
function frame(t) {
  const a = camAt(t), b = camAt(t - 1 / FPS);                                 // screen px the camera moved this frame
  const v = Math.hypot(a.x - b.x, a.y - b.y) * a.zoom + Math.abs(Math.log(a.zoom / b.zoom)) * W / 2;
  if (v > 3 * U) motionBlur(drawFilm, t, Math.min(32, 4 + Math.ceil(v / (20 * U))));
  else drawFilm(t);
  flash(pulse(t, S.end, 0.16) * 0.3, '#ffffff');
}
