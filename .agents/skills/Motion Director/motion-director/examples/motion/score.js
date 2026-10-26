'use strict';
// Score · clean & bright, minimal beat · G major · 112 BPM · Gmaj7–Em7–Cmaj7–D.
// Every sync point reads S (and TYPE_T, CODE, LINE_T0, LINE_DT) from scenes.js: same global scope, no drift.
// Earworm: bell motif D5 G5 B5 A5, left hanging on A in the hook, resolved to G on the end card.
// Shape: sparse intro → build bar with a riser → true silence → drop → end card lands on D → resolves to G.
function score(A) {
  const b = (n) => beats(n);
  A.reverb(0.22);

  // ── HOOK (frame 0): soft hit + the motif over live typing
  A.hit(0, 0.35); A.kick(0, 0.7);
  [[0, 'D5'], [0.75, 'G5'], [1.5, 'B5'], [2.5, 'A5']].forEach(([bt, n]) => { A.bell(b(bt), n, 1.4, 0.5); A.pluck(b(bt), n, 0.3, 0.25); });
  TYPE_T.forEach((tt, i) => A.type(tt, 0.45, ((i % 5) - 2) * 0.08));
  A.whoosh(S.pull, S.pulled - S.pull, 0.45, false); A.hit(S.pulled, 0.25);          // pull back, headline lands

  // ── BED, bars 0–3: warm keys + sub on the roots, a beat that grows bar by bar
  A.progression(0, ['Gmaj7', 'Em7', 'Cmaj7', 'D'], 4, (n, t) => {
    A.keys(t, n, A.bar - 0.05, 0.4); A.keys(t + b(2.5), n.slice(1), b(1.4), 0.2); A.sub(t, n[0] - 12, A.bar - 0.1, 0.4);
  }, 3);
  A.pattern(A.bar, 'x.......x.......', (t) => A.kick(t, 0.55), 2);                 // kicks land with Enter and both clicks
  A.pattern(A.bar, '..x...x...x...x.', (t) => A.hat(t, 0.45), 2);
  A.pattern(S.code, 'x...x...x.......', (t) => A.kick(t, 0.75), 1);                 // build bar
  A.pattern(S.code, 'x.x.x.x.xxxxxx..', (t, i) => A.hat(t, 0.3 + i * 0.035), 1);
  A.sweep(S.code, S.still, 20000, 900);                                             // muffle into the gap
  A.riser(S.code, S.still - S.code, 0.85);

  // ── 01 → 02: Enter, whip, cards pop (pitch climbs), clicks
  A.click(S.enter, 1.1); A.blip(S.enter + 0.06, 'G6', 0.5);
  A.whoosh(S.pan1 - 0.08, S.q - S.pan1 + 0.08, 0.7);
  [[S.card1, 1], [S.card2, 1.12]].forEach(([t0, p]) => { A.pop(t0, 0.75, p); for (let k = 0; k < 3; k++) A.tick(t0 + 0.1 + k * 0.07, 0.35, 2400 + k * 300, 0.2); });
  A.click(S.pick1, 1); A.pop(S.pick1, 0.9, 1.26); A.bellFx(S.pick1 + 0.06, 'B6', 0.5, 0.35);
  A.click(S.pick2, 1); A.pop(S.pick2, 0.9, 1.5); A.bellFx(S.pick2 + 0.06, 'D7', 0.5, 0.35);
  A.whoosh(S.pan2 - 0.08, S.code - S.pan2 + 0.08, 0.7);

  // ── 03: a keystroke per streamed code line, clock pill, chips pop, strikes swipe, the fold
  CODE.forEach((_, i) => { const t = S.code + LINE_T0 + i * LINE_DT; A.type(t, 0.55, i % 2 ? 0.25 : -0.25); A.type(t + 0.03, 0.4, 0); });
  A.pop(S.code + 0.15, 0.5, 1.12);
  A.pop(S.chipA, 0.6, 1.33); A.pop(S.chipB, 0.6, 1.5);
  A.swipe(S.strike1, 0.8, 1); A.tick(S.strike1, 0.5, 3200);
  A.swipe(S.strike2, 0.8, -1); A.tick(S.strike2, 0.5, 3600);
  A.chirp(S.fold + 0.05, 1400, 260, S.still - S.fold, 0.55);                      // the editor folds up...
  A.bellFx(S.still, 'A6', 0.6, 0.45);                                              // ...into a tile: "ting"
  A.silence(S.still + 0.1, S.drop);                                                // true silence while it falls

  // ── DROP: the MP4 lands
  A.sweep(S.drop, S.drop + 0.03, 900, 20000);
  A.impact(S.drop, 1); A.crash(S.drop, 0.8);
  A.pattern(S.drop, 'x...x...x...x...x...x...', (t) => A.kick(t, 1), 1);
  A.pattern(S.drop, '....x.......x.......x...', (t) => A.clap(t, 0.75), 1);
  A.pattern(S.drop, '..x...x...x...x...x...x.', (t) => A.hat(t, 0.55), 1);
  A.pattern(S.drop, '.x.x.x.x.x.x.x.x.x.x.x.x', (t) => A.shaker(t, 0.5), 1);
  A.progression(S.drop, ['Gmaj7', 'Em7', 'Cmaj7'], 2, (n, t) => {
    A.bass(t, n[0] - 12, b(2) - 0.05, 1.1, { cutoff: 560 }); A.keys(t, n, b(1.9), 0.65);
    A.arp(t, n.map((x) => x + 12), b(0.5), b(2), 0.5);
  }, 3);
  A.pop(S.drop + 0.14, 0.5, 1.68);                                                 // filename pill
  A.pop(S.pill, 0.8, 1.26);                                                        // "original soundtrack"
  A.tick(S.note, 0.4, 1800);                                                       // pen down, then a scribble
  for (let k = 0; k < 9; k++) A.noise(A.sfx, S.note + 0.12 + k * 0.045, 0.04, 0.05, { f: 2600 + (k % 3) * 500, q: 1.4, pan: 0.3 });

  // ── SIGNATURE: push through the thumbnail, accelerating into the hit
  A.whoosh(S.push, S.end - S.push, 0.9, true);

  // ── END CARD: land on D (tension), resolve to G on the CTA, ring out
  A.hit(S.end, 0.8); A.crash(S.end, 0.45); A.kick(S.end, 0.9);
  A.keys(S.end, A.chord('D', 3), b(2), 0.6); A.sub(S.end, 'D2', b(2) - 0.05, 0.7);
  A.bell(S.end, 'D5', 1.2, 0.9); A.bell(S.end + b(0.5), 'G5', 1.2, 0.9); A.bell(S.end + b(1), 'B5', 1.6, 0.9);
  A.pop(S.end + b(0.5), 0.4, 1.26); A.pop(S.end + b(1), 0.4, 1.5);
  A.type(S.cta, 0.8); A.type(S.cta + 0.06, 0.7); A.kick(S.cta, 0.8);
  const tail = A.dur - S.cta;
  A.sub(S.cta, 'G1', tail - 0.3, 0.8);
  A.pad(S.cta, A.chord('Gmaj9', 3), tail - 0.6, 0.6, { attack: 0.06, cutoff: 2600 });
  A.keys(S.cta, A.chord('Gmaj9', 3), tail, 0.7);
  A.bell(S.cta, 'G5', tail, 1); A.bell(S.cta + 0.02, 'D6', tail, 0.55);
}
