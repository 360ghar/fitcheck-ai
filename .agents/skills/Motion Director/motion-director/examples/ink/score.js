'use strict';
// Warm and playful, 112 BPM, F major (F-C-Dm-Bb). The motif F-A-C-E climbs with the four mugs; "NOPE." answers E-C-A-F.
// Every sync point comes from S, POURS, HOP1 and HOP2 in scenes.js (same global scope), so picture and sound can't drift.
function score(A) {
  const bar = A.bar;
  A.reverb(0.24);

  const pourNoise = (a, b1, v = 0.05) => { a = Math.max(0, a); A.noise(A.sfx, a, b1 - a, v, { type: 'bandpass', f: 750, q: 0.7 }); A.noise(A.sfx, a, b1 - a, v * 0.5, { type: 'lowpass', f: 400 }); };
  const splash = (t, v = 1) => {
    A.noise(A.sfx, t, 0.4, 0.3 * v, { type: 'lowpass', f: 2200, to: 300 });
    A.noise(A.sfx, t, 0.14, 0.12 * v, { type: 'bandpass', f: 3200, q: 1.2 });
    [0.05, 0.11, 0.19, 0.26].forEach((d, i) => A.tone(A.sfx, 'sine', 900 + i * 230, t + d, 0.05, 0.1 * v, { to: 1500 + i * 200, glide: 0.04, pan: i % 2 ? 0.3 : -0.3 }));
  };
  const land = (t, v = 1) => { A.tick(t, 0.8 * v, 1900); A.tom(t, 'C3', 0.55 * v); };

  // ---------------- bars 1-3: warm bed (keys on 1 & 3, sine bass, soft kick, shaker)
  [['F', 'F2'], ['C', 'C2'], ['Dm', 'D2']].forEach(([ch, root], i) => {
    const t0 = i * bar;
    [0, 2].forEach((bt) => { A.keys(t0 + A.b(bt), A.chord(ch, 4), A.b(1.8), 0.8); A.bass(t0 + A.b(bt), root, A.b(1.85), 0.55, { type: 'sine' }); });
    A.pattern(t0, 'x.......x.......', (t) => A.kick(t, 0.6));
    A.pattern(t0, '..x...x...x...x.', (t) => A.shaker(t, 0.7));
    if (i > 0) A.pattern(t0, '....x.......x...', (t) => A.click(t, 0.35));
  });

  // ---------------- bar 1: the conveyor. The motif climbs one note per mug; counter pops rise in pitch.
  ['F4', 'A4', 'C5', 'E5'].forEach((n, k) => A.pluck(A.b(k), n, 0.5, 1));
  POURS.slice(0, 4).forEach((p, k) => {
    pourNoise(p.a, p.b + FALL_C);
    [0.04, 0.17].forEach((d, j) => A.tone(A.sfx, 'sine', 240 + 50 * j + 40 * k, Math.max(0, p.a + FALL_C) + d, 0.09, 0.22, { to: 480 + 80 * k, glide: 0.07 }));
  });
  [1, 2, 3, 4].forEach((k) => { A.pop(A.b(k), 0.6, 1 + 0.14 * k); A.swipe(A.b(k) - 0.21, 0.28, -1); });

  // ---------------- bar 2: cup #5 arrives, dodge one
  A.whoosh(S.arrive + 0.02, 0.3, 0.5, false);                      // mug #4 yanked away
  A.pop(S.arrive, 0.8, 1.7); A.bell(S.arrive, 'F5', 1.2, 0.6);
  A.chirp(S.alarm, 520, 1350, 0.15, 0.9); A.pop(S.alarm + 0.02, 0.5, 2.2);     // "!"
  pourNoise(POURS[4].a, POURS[4].b + FALL_T);
  A.chirp(HOP1[0], 700, 1500, 0.12, 0.8); land(HOP1[1]);
  splash(POURS[4].a + FALL_T);
  A.chirp(S.smirk + 0.02, 560, 400, 0.14, 0.6);                    // "hmph"

  // ---------------- bar 3: the chase
  A.swipe(S.chase, 0.9, -1); A.whoosh(S.chase, 0.3, 0.45);
  pourNoise(POURS[5].a, POURS[5].b + FALL_T);
  A.chirp(HOP2[0], 600, 1700, 0.18, 0.85); land(HOP2[1], 1.1);
  splash(POURS[5].a + FALL_T);
  A.tone(A.sfx, 'sawtooth', 115, HOP2[1] + 0.06, 0.42, 0.11, { lp: 1200, vib: { rate: 34, depth: 0.28 }, a: 0.02 });   // raspberry
  A.noise(A.sfx, HOP2[1] + 0.06, 0.4, 0.05, { type: 'bandpass', f: 500, q: 1 });
  A.noise(A.sfx, S.fume + 0.06, 0.55, 0.13, { type: 'highpass', f: 5200 });                                         // steam hiss
  A.tone(A.sfx, 'square', 88, S.fume + 0.06, 0.34, 0.05, { lp: 480, vib: { rate: 17, depth: 0.12 } });              // grumble
  A.swipe(S.chase2, 0.9, 1); A.whoosh(S.chase2, 0.3, 0.45);

  // ---------------- bar 4: the build, a breath of true silence, then the launch
  A.keys(S.build, A.chord('Bb', 4), A.b(2.6), 0.7);
  A.pad(S.build, A.chord('Bb', 3), S.hush - S.build, 0.7, { cutoff: 900, cutoffTo: 3200, attack: 0.3 });
  A.bass(S.build, 'Bb1', S.hush - S.build - 0.05, 0.6, { type: 'sine' });
  [[0, 'F2'], [1, 'G2'], [2, 'A2'], [2.5, 'C3']].forEach(([bt, n]) => A.tom(S.build + A.b(bt), n, 0.8));
  A.sweep(S.build, S.hush, 20000, 1100);
  A.riser(S.build + 0.2, S.hush - S.build - 0.2, 0.85);
  A.silence(S.hush, S.launch);
  // the backflip has no music: just a whoosh and a "hup"
  A.whoosh(S.launch, S.drop - S.launch, 0.9, true);
  A.chirp(S.launch, 800, 2000, 0.3, 0.6);

  // ---------------- bar 5: DROP (lands upside down)
  A.sweep(S.drop, S.drop + 0.04, 1100, 20000);
  A.impact(S.drop, 1); A.crash(S.drop, 0.8); A.tom(S.drop, 'F2', 1);
  A.pattern(S.drop, 'x.......x.......', (t) => A.kick(t, 0.9), 2);
  A.pattern(S.drop, '....x.......x...', (t) => A.clap(t, 0.6), 2);
  A.pattern(S.drop, '..x...x...x...x.', (t) => A.hat(t, 0.5), 2);
  A.pattern(S.drop, 'x.x.x.x.x.x.x.x.', (t) => A.shaker(t, 0.6), 2);
  [0, 2].forEach((bt) => A.keys(S.drop + A.b(bt), A.chord('F', 4), A.b(1.8), 0.8));
  A.bass(S.drop, 'F2', A.b(3.9), 0.85, { cutoff: 800 });
  [[0.5, 'F5'], [1, 'A5'], [1.5, 'C6']].forEach(([bt, n]) => A.pluck(S.drop + A.b(bt), n, 0.3, 0.8));
  [0, 0.07, 0.14, 0.21].forEach((d, i) => A.noise(A.sfx, S.strike + d, 0.08, 0.17, { type: 'bandpass', f: i % 2 ? 2600 : 1600, to: i % 2 ? 1600 : 2600, q: 2 }));   // scribble
  A.duck(S.sulk, 1.0, 0.45);
  A.lead(S.sulk, 'A4', 0.2, 1, { type: 'sawtooth', cutoff: 1500 });                          // sad trombone
  A.lead(S.sulk + 0.22, 'G#4', 0.2, 1, { type: 'sawtooth', cutoff: 1500 });
  A.lead(S.sulk + 0.44, 'G4', 0.75, 1, { type: 'sawtooth', cutoff: 1400, glideTo: 'F4', glide: 0.6 });
  A.whoosh(S.exit + 0.02, 0.45, 0.6, true);                       // pot floats off

  // ---------------- bar 6: "NOPE." (motif answers, descending)
  [[0, 'Bb', 'Bb1'], [2, 'C', 'C2']].forEach(([bt, ch, root]) => { A.keys(S.nope + A.b(bt), A.chord(ch, 4), A.b(1.8), 0.8); A.bass(S.nope + A.b(bt), root, A.b(1.9), 0.8, { cutoff: 800 }); });
  ['E5', 'C5', 'A4', 'F4'].forEach((n, i) => A.bell(S.nope + i * 0.132, n, 1.3, 0.9, (i - 1.5) * 0.2));
  A.pop(S.nope + 0.54, 0.5, 1.3);
  A.swipe(S.nope + 0.72, 0.55, 1);

  // ---------------- bar 7: the wink and its sparkle, then the tonic rings out
  A.sparkle(S.end, 0.8); A.chirp(S.end, 900, 1250, 0.08, 0.3);
  A.kick(S.end, 0.6);
  A.keys(S.end, A.chord('F', 4), A.dur - S.end, 0.9);
  A.pad(S.end, A.chord('Fmaj7', 3), A.dur - S.end, 0.55, { cutoff: 2000 });
  A.bass(S.end, 'F2', A.dur - S.end - 0.1, 0.7, { type: 'sine' });
  A.bell(S.end + 0.02, 'F5', 2.1, 0.6);
}
