'use strict';
// NIGHTSHIFT score: cinematic build and hit, 96 BPM, D minor → D major at dawn.
// Every time below comes from scenes.js (S, CODE, LOG, logT, clockT, FLICKER, TAG), so each
// picture event has its sound on the same frame. Sections follow the scenes in order.
function score(A) {
  const D = S.drop;
  A.reverb(0.3);

  // HOOK: a low room drone, and each word of YOU LOG OFF. is a hit plus one note of the motif (D–F–A)
  A.drone(0, 'D2', S.freeze, 0.9);
  A.sub(0, 'D1', S.off + 0.15, 0.7);
  ['D5', 'F5', 'A5'].forEach((n, i) => { A.hit(S.hits[i], [0.9, 0.55, 0.75][i]); A.bell(S.hits[i], n, 1.5, 0.9, (i - 1) * 0.25); });
  A.every(0.03, S.off - 0.03, 0.07, (t, i) => A.type(t + (h01('ty', i) - 0.5) * 0.025, 0.45 + h01('tv', i) * 0.35, (h01('tp', i) - 0.5) * 0.7));

  // POWER-OFF: relay click, a falling CRT whine, the room goes muffled (and reopens through the night)
  A.click(S.off, 1.2); A.chirp(S.off, 3400, 70, 0.3, 0.9); A.downer(S.off, 0.5, 0.35);
  A.sweep(S.off, S.off + 0.25, 20000, 360);
  A.sweep(S.heart, S.freeze, 360, 7000);

  // THE NIGHT: the pixel's heartbeat, speeding up into the freeze
  const heart = (t, v) => { A.kick(t, v, { f0: 110, f1: 40, len: 0.5 }); A.kick(t + 0.19, v * 0.6, { f0: 100, f1: 38, len: 0.4 }); };
  heart(S.heart, 1); heart(S.night, 0.9); heart(beats(10), 0.95);
  [beats(12), beats(12.5), beats(13), beats(13.25)].forEach((t, i) => A.kick(t, 0.8 + i * 0.07, { f0: 120, f1: 40, len: 0.3 }));
  // IT DOESN'T.: the pixel answers, and a filtered Dm9 pad opens slowly
  A.hit(S.doesnt, 0.7); A.bell(S.doesnt, 'D6', 1.8, 0.6, 0.15);
  A.pad(S.doesnt, A.chord('Dm9', 3), S.freeze - S.doesnt, 0.85, { cutoff: 500, cutoffTo: 2600, attack: 0.6 });
  // the cursor glides, then every typed character is a key
  A.swipe(S.glide, 0.5, 1);
  CODE.forEach((l) => { for (let k = l.lead; k < l.str.length; k++) A.type(l.t0 + (k - l.lead) * l.dt, 0.8, 0.12); });
  // 00:00: the clock appears; each hour flip is a tick and a rising blip
  A.hit(S.night, 0.45); A.blip(S.night, 'A5', 0.6);
  ['D6', 'E6', 'F6', 'G6', 'A6', 'C7'].forEach((n, i) => { const t = clockT(60 * (i + 1)); A.tick(t, 0.9, 2600 + i * 250); A.blip(t, n, 0.4, i % 2 ? 0.3 : -0.3); });
  // the commit log: one key per row, accelerating into a whirr, over a riser
  let last = -1;
  for (let j = 0; j < NLOG; j++) { const t = logT(j); if (t - last >= 0.04) { A.type(t, 0.55, j % 2 ? 0.35 : -0.35); last = t; } }
  A.riser(S.log - 1.25, S.freeze - S.log + 1.25, 1);
  // FREEZE: true silence, reverb tails included, until the drop
  A.silence(S.freeze, D);

  // 07:00 DROP: boom, then a trailer pulse on D under NIGHT
  A.boom(D, 1.1); A.impact(D, 1); A.crash(D, 0.9);
  A.sweep(D, D + 0.05, 7000, 20000);
  A.pad(D, A.chord('Dm9', 3), S.tag - D + 0.1, 0.9, { cutoff: 3200, attack: 0.04 });
  A.sub(D, 'D1', S.tag - D, 0.9);
  A.every(D, S.tag - 0.01, beats(0.5), (t, i) => A.bass(t, 'D2', beats(0.5) - 0.04, i % 2 ? 0.7 : 0.95, { cutoff: 950 }));
  A.every(D + beats(1), S.tag - 0.01, beats(1), (t) => A.kick(t, 0.85));
  A.tom(S.tag - beats(0.5), 'A2', 0.7); A.tom(S.tag - beats(0.25), 'F2', 0.8);
  // SHIFT ignites: a second impact and an electric buzz on each flicker
  A.impact(S.ignite, 0.55);
  FLICKER.forEach(([a, b]) => A.tone(A.sfx, 'sawtooth', 118, S.ignite + a, Math.min(b - a, 0.25), 0.07, { lp: 2200, a: 0.004 }));
  A.chirp(S.ignite + FLICKER[3][0], 400, 1600, 0.12, 0.35);

  // SHIPS MONDAY: typed by the same cursor, the chord lifts to Bbmaj7
  A.hit(S.tag, 0.5);
  [...TAG].forEach((ch, k) => { if (ch !== ' ') A.type(S.tag + k * TAG_DT, 0.9, 0.1); });
  A.pad(S.tag, A.chord('Bbmaj7', 3), S.home - S.tag + 0.1, 0.8, { cutoff: 2600, attack: 0.05 });
  A.bass(S.tag, 'Bb1', S.home - S.tag - 0.05, 0.8, { cutoff: 700 });

  // DAWN: D major; the motif resolves (D–F#–A–D) and rings out past the last frame
  const tail = A.dur - S.home;
  A.pad(S.home, A.chord('Dadd9', 3), tail - 0.2, 0.9, { cutoff: 2400, attack: 0.08 });
  A.sub(S.home, 'D1', tail, 0.8);
  A.crash(S.home, 0.35);
  [['D5', 0], ['F#5', 0.5], ['A5', 1], ['D6', 2]].forEach(([n, b]) => A.bell(S.home + beats(b), n, b === 2 ? 2.2 : 1.4, 0.95, b === 2 ? 0 : (b - 0.5) * 0.4));
}
