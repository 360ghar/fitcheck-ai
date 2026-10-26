'use strict';
// Punchy electronic · 128 BPM · A minor. Sparse filtered intro → riser → a breath of true silence → drop →
// the motif answered on the end card. Every time below comes from scenes.js (S, BEAT, BAR, SCAN, COUNT_T, QUIET),
// so picture and sound can't drift: change a scene time there and its sounds move with it.
function score(A) {
  const b = A.beat, D = S.drop, E = S.end;
  A.reverb(0.16);

  // bars 1–4 · intro bed: muffled pad that opens up, half-time kick, offbeat hats, backbeat from bar 2
  A.sweep(0, S.count, 700, 3200);
  A.sweep(S.count, D - QUIET, 3200, 12000);
  A.progression(0, ['Am', 'F', 'C', 'G'], 4, (n, t) => A.pad(t, n, A.b(4), 0.55, { cutoff: 1500 }), 3);
  A.pattern(0, 'x.......x.......', (t) => A.kick(t, 0.9), 3);
  A.pattern(0, '..x...x...x...x.', (t) => A.hat(t, 0.45), 3);
  A.pattern(S.rules, '....x.......x...', (t) => A.clap(t, 0.4), 2);
  A.progression(S.rules, ['F', 'C', 'G'], 4, (n, t) => A.bass(t, n[0] - 12, A.b(4) - 0.05, 0.7, { cutoff: 380 }), 3);

  // bar 1 · hook: 98¢ slams on frame 0; the motif asks a question (ends on D)
  A.impact(0, 0.85); A.hit(0, 0.45);
  [[0, 'A4'], [0.75, 'C5'], [1.5, 'E5'], [2.5, 'D5']].forEach(([bt, n]) => A.pluck(A.b(bt), n, 0.42, 1));
  A.swipe(b - 0.04, 0.55, 1);                                    // "Near-certain favorites."
  A.chirp(2 * b + 0.02, 480, 1500, 0.32, 0.6);                    // the price marker races right…
  A.blip(2 * b + 0.42, 'E6', 0.7);                                // …and lands in the 97–99.5¢ zone

  // bars 2–3 · Jev reads the fine print: a tick per line, a hit per stacked line, an impact on "FIRST."
  A.whoosh(S.rules - 0.3, 0.3, 0.7);
  [0, 1, 2].forEach((k) => A.hit(S.rules + k * b, k ? 0.55 : 0.4));
  for (let i = 0; i < SCAN.n; i++) A.tick(S.rules + SCAN.t0 + i / SCAN.v, 0.4, 2900 + i * 70, i % 2 ? 0.25 : -0.25);
  A.impact(S.rules + BAR, 0.6); A.clap(S.rules + BAR, 0.8); A.chirp(S.rules + BAR + 0.02, 900, 2400, 0.18, 0.5);

  // bar 4 · build: riser, snare roll, ticks that slow down with the eOutExpo counter, a hit when it lands, then silence
  A.riser(S.count, D - QUIET - S.count, 0.85);
  A.pattern(S.count, 'x...x...x...', (t) => A.kick(t, 0.9), 1);
  A.every(S.count, D - QUIET - 0.01, b / 4, (t, i) => A.snare(t, 0.12 + 0.045 * i));
  for (let k = 1; k <= 26; k++) A.tick(S.count + Math.min(1, -Math.log2(1 - k / 27) / 10) * COUNT_T, 0.45, 2200 + k * 40);
  A.hit(S.count + COUNT_T, 0.6); A.bellFx(S.count + COUNT_T, 'E6', 0.7, 0.6);
  A.silence(D - QUIET, D);
  A.sweep(D - 0.01, D, 12000, 20000);

  // bars 5–7 · drop: four on the floor with sidechain ducks, pumping 8th-note bass, the motif an octave up
  A.impact(D, 1); A.boom(D, 0.6); A.crash(D, 0.9); A.sparkle(D + 0.06, 0.7);
  A.pattern(D, 'x...x...x...x...', (t) => { A.kick(t, 1); A.duck(t, 0.16, 0.3); }, 2);
  A.pattern(D, '....x.......x...', (t) => A.clap(t, 0.85), 2);
  A.pattern(D, '..x...x...x...x.', (t) => A.hat(t, 0.55, true), 2);
  A.pattern(D, 'xxxxxxxxxxxxxxxx', (t, i) => A.shaker(t, i % 2 ? 0.45 : 0.8), 2);
  A.progression(D, ['Am', 'F', 'G'], 4, (n, t) => {
    A.pattern(t, 'x.x.x.x.x.x.x.x.', (tt) => A.bass(tt, n[0] - 12, b / 2 - 0.03, 0.95, { cutoff: 950 }), 1);
    A.pad(t, n, A.b(4), 0.45, { cutoff: 3000 });
  }, 3);
  [[0, 'A5'], [0.75, 'C6'], [1.5, 'E6'], [2.5, 'D6']].forEach(([bt, n]) => A.pluck(D + A.b(bt), n, 0.35, 0.85, { bright: 5200 }));
  A.hit(D + b, 0.35);                                             // "paid out."

  // bar 6 · +0.58%: whoosh under the dark wipe, blips climbing with the counter, a bell when it lands
  A.whoosh(S.edge - 0.22, 0.22, 0.8); A.hit(S.edge, 0.45);
  ['A5', 'C6', 'D6', 'E6', 'G6'].forEach((n, k) => A.blip(S.edge + 0.03 + Math.min(1, -Math.log2(1 - (k + 1) / 6) / 10) * (b - 0.03), n, 0.55, (k - 2) * 0.2));
  A.bellFx(S.edge + b, 'A6', 0.9, 0.6); A.hit(S.edge + b, 0.35);
  [[0, 'C6'], [0.75, 'A5'], [1.5, 'G5'], [2.5, 'A5']].forEach(([bt, n]) => A.pluck(S.edge + A.b(bt), n, 0.35, 0.7, { bright: 4200 }));

  // bar 7 · setup: the beat takes a breath; two key clicks for "h" and "i", then enter
  A.pattern(S.setup, 'x.......x.......', (t) => A.kick(t, 0.9), 1);
  A.pattern(S.setup, '..x...x...x...x.', (t) => A.hat(t, 0.5), 1);
  A.pattern(S.setup, '............x...', (t) => A.clap(t, 0.6), 1);
  A.swipe(S.setup, 0.6, 1);
  A.type(S.setup + b, 1.2, -0.1); A.type(S.setup + 1.5 * b, 1.2, 0.1);
  A.click(S.setup + 2.5 * b, 1); A.blip(S.setup + 2.5 * b + 0.02, 'E6', 0.7); A.blip(S.setup + 2.5 * b + 0.1, 'A6', 0.7);
  A.riser(E - 2 * b, 2 * b - 0.12, 0.35);
  A.silence(E - 0.1, E);

  // bar 8 · end card: the motif answers and resolves to the tonic, then rings out to the last frame
  A.impact(E, 0.9); A.kick(E, 1); A.crash(E, 0.6);
  A.pad(E, [...A.chord('Am', 3), A.midi('B4')], A.dur - E, 0.6, { cutoff: 2600, cutoffTo: 900 });
  A.sub(E, 'A1', A.dur - E - 0.05, 0.8);
  [[0, 'A4'], [0.75, 'C5'], [1.5, 'E5'], [2.5, 'A5']].forEach(([bt, n], i) => A.bell(E + A.b(bt), n, 1.8, 0.9, (i - 1.5) * 0.2));
  A.pop(E + 0.3, 0.35, 1.2);                                      // "$5 bot for Claude Code"
}
