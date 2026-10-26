'use strict';
// ============================================================================
// audio.js — the whole soundtrack is synthesized in Web Audio from film/score.js,
// rendered once in an OfflineAudioContext, then mastered in JS:
// BS.1770 loudness normalised to -14 LUFS (streaming/social standard) and a 4x
// oversampled true-peak limiter at -1.5 dBTP. Output: 48 kHz float WAV.
//
// film/score.js defines `function score(A) { ... }` and schedules everything
// with the instrument kit below. Times are in seconds. Notes are MIDI numbers
// or names ('A3', 'C#5'). Everything is deterministic (seeded noise).
// ============================================================================
const SR = 48000;
const NOTE_IX = { C: 0, 'C#': 1, Db: 1, D: 2, 'D#': 3, Eb: 3, E: 4, F: 5, 'F#': 6, Gb: 6, G: 7, 'G#': 8, Ab: 8, A: 9, 'A#': 10, Bb: 10, B: 11 };
/** 'A4' -> 69 ; numbers pass through */
function midi(n) { if (typeof n === 'number') return n; const m = /^([A-G][#b]?)(-?\d)$/.exec(n); if (!m) throw new Error('bad note ' + n); return NOTE_IX[m[1]] + 12 * (+m[2] + 1); }
const mtof = (m) => 440 * Math.pow(2, (midi(m) - 69) / 12);
const CHORD_IV = { '': [0, 4, 7], m: [0, 3, 7], '7': [0, 4, 7, 10], m7: [0, 3, 7, 10], maj7: [0, 4, 7, 11], m9: [0, 3, 7, 10, 14], maj9: [0, 4, 7, 11, 14], add9: [0, 4, 7, 14], madd9: [0, 3, 7, 14], sus2: [0, 2, 7], sus4: [0, 5, 7], dim: [0, 3, 6], aug: [0, 4, 8], '6': [0, 4, 7, 9], m6: [0, 3, 7, 9], '5': [0, 7] };
/** chord('Am7', 4) -> [57, 60, 64, 67] (root in the given octave) */
function chord(name, oct = 4) { const m = /^([A-G][#b]?)(.*)$/.exec(name); const iv = CHORD_IV[m[2]]; if (!iv) throw new Error('unknown chord ' + name); const root = NOTE_IX[m[1]] + 12 * (oct + 1); return iv.map((i) => root + i); }

async function renderAudio() {
  if (typeof window.score !== 'function' || FILM.audio === false) return null;
  const len = Math.round(DUR * SR), ac = new OfflineAudioContext(2, len, SR), rnd = rng('audio');
  const nb = ac.createBuffer(1, SR * 2, SR); { const d = nb.getChannelData(0); for (let i = 0; i < d.length; i++) d[i] = rnd() * 2 - 1; }

  // ---- buses: music (filterable, duckable) + sfx -> glue compressor -> destination; shared room reverb
  const master = ac.createGain(); master.gain.value = 0.85;
  const glue = ac.createDynamicsCompressor(); glue.threshold.value = -14; glue.ratio.value = 2.2; glue.attack.value = 0.012; glue.release.value = 0.18; glue.knee.value = 8;
  master.connect(glue); glue.connect(ac.destination);
  const levelEvents = [], silenceEvents = [], duckEvents = [];
  const musicIn = ac.createGain(), musicLP = ac.createBiquadFilter(), musicDuck = ac.createGain();
  musicLP.type = 'lowpass'; musicLP.frequency.value = 20000; musicLP.Q.value = 0.7;
  musicIn.connect(musicLP); musicLP.connect(musicDuck); musicDuck.connect(master);
  const sfx = ac.createGain(); sfx.connect(master);
  const verb = ac.createGain(); verb.gain.value = 0.2;
  [[0.029, -0.7], [0.043, 0.7], [0.071, -0.35], [0.097, 0.4], [0.131, 0]].forEach(([dt, pan]) => {
    const dl = ac.createDelay(1); dl.delayTime.value = dt; const fb = ac.createGain(); fb.gain.value = 0.42; const lp = ac.createBiquadFilter(); lp.frequency.value = 3800; const pn = ac.createStereoPanner(); pn.pan.value = pan;
    verb.connect(dl); dl.connect(lp); lp.connect(fb); fb.connect(dl); lp.connect(pn); pn.connect(master);
  });
  musicIn.connect(verb); sfx.connect(verb);
  const music = musicIn;

  // ---- primitives
  const out = (node, dest, pan) => { if (pan != null && pan !== 0) { const p = ac.createStereoPanner(); p.pan.value = clamp(pan, -1, 1); node.connect(p); p.connect(dest); } else node.connect(dest); };
  /** raw oscillator voice. o: to (Hz glide target), glide, a (attack), hold, lp, q, hp, det, pan, vib ({rate, depth}) */
  const tone = (dest, type, f, t, dur, peak, o = {}) => {
    const osc = ac.createOscillator(); osc.type = type; osc.frequency.setValueAtTime(f, t);
    if (o.to) osc.frequency.exponentialRampToValueAtTime(Math.max(1, o.to), t + (o.glide ?? dur));
    if (o.det) osc.detune.value = o.det;
    if (o.vib) { const l = ac.createOscillator(), lg = ac.createGain(); l.frequency.value = o.vib.rate ?? 5.5; lg.gain.value = f * (o.vib.depth ?? 0.006); l.connect(lg); lg.connect(osc.frequency); l.start(t); l.stop(t + dur + 0.05); }
    let node = osc;
    if (o.lp) { const f2 = ac.createBiquadFilter(); f2.type = 'lowpass'; f2.frequency.setValueAtTime(o.lp, t); f2.Q.value = o.q ?? 0.7; if (o.lpTo) f2.frequency.exponentialRampToValueAtTime(o.lpTo, t + (o.lpGlide ?? dur)); node.connect(f2); node = f2; }
    if (o.hp) { const f3 = ac.createBiquadFilter(); f3.type = 'highpass'; f3.frequency.value = o.hp; node.connect(f3); node = f3; }
    const g = ac.createGain(); node.connect(g); out(g, dest, o.pan);
    const a = o.a ?? 0.005;
    g.gain.setValueAtTime(0.0001, t); g.gain.linearRampToValueAtTime(peak, t + a);
    if (o.hold) g.gain.setValueAtTime(peak, t + a + o.hold);
    g.gain.exponentialRampToValueAtTime(0.0001, t + Math.max(dur, a + (o.hold || 0) + 0.01));
    osc.start(t); osc.stop(t + dur + 0.1);
    return osc;
  };
  /** filtered noise voice. o: type ('bandpass'|'lowpass'|'highpass'), f, to, q, a, hold, swell, pan */
  const noise = (dest, t, dur, peak, o = {}) => {
    const src = ac.createBufferSource(); src.buffer = nb; src.loop = true; if (o.rate) src.playbackRate.value = o.rate;
    const f = ac.createBiquadFilter(); f.type = o.type || 'bandpass'; f.frequency.setValueAtTime(o.f || 1000, t); f.Q.value = o.q ?? 1;
    if (o.to) f.frequency.exponentialRampToValueAtTime(o.to, t + dur);
    const g = ac.createGain(); src.connect(f); f.connect(g); out(g, dest, o.pan);
    g.gain.setValueAtTime(0.0001, t);
    if (o.swell) { g.gain.exponentialRampToValueAtTime(peak, t + dur * 0.92); g.gain.linearRampToValueAtTime(0.0001, t + dur); }
    else { g.gain.linearRampToValueAtTime(peak, t + (o.a ?? 0.003)); if (o.hold) g.gain.setValueAtTime(peak, t + (o.a ?? 0.003) + o.hold); g.gain.exponentialRampToValueAtTime(0.0001, t + dur); }
    src.start(t, rnd() * 1.5); src.stop(t + dur + 0.05);
    return g;
  };
  const fm = (dest, f, t, dur, peak, ratio, index, pan = 0, a = 0.004) => {
    const car = ac.createOscillator(), mod = ac.createOscillator(), mg = ac.createGain(), g = ac.createGain();
    car.frequency.value = f; mod.frequency.value = f * ratio; mg.gain.setValueAtTime(f * index, t); mg.gain.exponentialRampToValueAtTime(Math.max(0.01, f * index * 0.02), t + dur);
    mod.connect(mg); mg.connect(car.frequency); car.connect(g); out(g, dest, pan);
    g.gain.setValueAtTime(0.0001, t); g.gain.linearRampToValueAtTime(peak, t + a); g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    car.start(t); mod.start(t); car.stop(t + dur + 0.05); mod.stop(t + dur + 0.05);
  };

  const bpm = FILM.bpm, beat = 60 / bpm, bar = beat * 4;
  const A = {
    ac, music, sfx, tone, noise, fm, midi, mtof, chord, bpm, beat, bar, dur: DUR,
    b: (n) => n * beat, /** bars+beats -> seconds: A.at(2, 1.5) */ at: (barN, beatN = 0) => barN * bar + beatN * beat,
    rnd,

    // ---------------- drums (music bus)
    kick(t, v = 1, o = {}) { tone(music, 'sine', o.f0 ?? 155, t, o.len ?? 0.38, 0.95 * v, { to: o.f1 ?? 43, glide: 0.11 }); tone(music, 'triangle', 90, t, 0.06, 0.25 * v, { to: 50, glide: 0.05 }); noise(music, t, 0.018, 0.22 * v, { type: 'highpass', f: 3500 }); },
    snare(t, v = 1) { tone(music, 'triangle', 205, t, 0.12, 0.3 * v, { to: 150, glide: 0.08 }); noise(music, t, 0.2, 0.34 * v, { type: 'highpass', f: 1400, pan: 0.04 }); noise(music, t, 0.09, 0.2 * v, { f: 2600, q: 0.8 }); },
    clap(t, v = 1) { for (let k = 0; k < 3; k++) noise(music, t + k * 0.011, 0.13 + k * 0.035, 0.3 * v * (k === 2 ? 1 : 0.6), { f: 1500, q: 0.9, pan: 0.06 }); },
    hat(t, v = 1, open = false, pan = 0.22) { noise(music, t, open ? 0.26 : 0.045, (open ? 0.07 : 0.06) * v, { type: 'highpass', f: open ? 7000 : 8500, pan }); },
    shaker(t, v = 1, pan = -0.3) { noise(music, t, 0.07, 0.035 * v, { type: 'highpass', f: 6000, a: 0.02, pan }); },
    tom(t, m = 'A2', v = 1) { tone(music, 'sine', mtof(m) * 1.6, t, 0.35, 0.5 * v, { to: mtof(m), glide: 0.18 }); },
    crash(t, v = 1) { noise(music, t, 1.6, 0.09 * v, { type: 'highpass', f: 5200 }); noise(music, t, 0.5, 0.06 * v, { f: 3000, q: 0.5 }); },

    // ---------------- tonal (music bus)
    /** bass(t, note, dur, v, {type: 'saw'|'square'|'sine', cutoff, glideTo}) */
    bass(t, n, dur, v = 1, o = {}) {
      const f = mtof(n), type = o.type === 'square' ? 'square' : o.type === 'sine' ? 'sine' : 'sawtooth';
      tone(music, type, f, t, dur, 0.16 * v, { lp: o.cutoff ?? 650, q: o.q ?? 3, a: 0.01, hold: Math.max(0, dur - 0.08), to: o.glideTo ? mtof(o.glideTo) : undefined, glide: o.glide });
      tone(music, 'sine', f / 2, t, dur, 0.22 * v, { a: 0.01, hold: Math.max(0, dur - 0.08) });
    },
    sub(t, n, dur, v = 1) { tone(music, 'sine', mtof(n), t, dur, 0.3 * v, { a: 0.02, hold: Math.max(0, dur - 0.1) }); },
    /** pad(t, notes[], dur, v, {cutoff, attack, width, bright}) — lush detuned saws */
    pad(t, notes, dur, v = 1, o = {}) {
      const a = o.attack ?? 0.35, per = 0.11 * v / notes.length;
      notes.forEach((n, i) => [-8, 8].forEach((det) => tone(music, 'sawtooth', mtof(n), t, dur + 0.3, per, { det: det + i * 1.5, lp: o.cutoff ?? 1600, lpTo: o.cutoffTo, a, hold: Math.max(0, dur - a - 0.2), pan: det < 0 ? -(o.width ?? 0.45) : (o.width ?? 0.45) })));
    },
    /** soft electric-piano chord */
    keys(t, notes, dur, v = 1) { notes.forEach((n, i) => { fm(music, mtof(n), t + i * 0.006, dur, 0.06 * v, 1, 1.2, (i - notes.length / 2) * 0.12, 0.006); tone(music, 'sine', mtof(n), t, dur, 0.04 * v, { a: 0.01 }); }); },
    pluck(t, n, dur = 0.4, v = 1, o = {}) { const f = mtof(n); tone(music, o.type || 'sawtooth', f, t, dur, 0.09 * v, { lp: o.bright ?? 3200, lpTo: 300, lpGlide: dur * 0.8, a: 0.002, pan: o.pan }); tone(music, 'sine', f, t, dur, 0.05 * v, { a: 0.002, pan: o.pan }); },
    bell(t, n, dur = 1.6, v = 1, pan = 0) { fm(music, mtof(n), t, dur, 0.09 * v, 3.5, 2.2, pan); tone(music, 'sine', mtof(n), t, dur * 0.8, 0.04 * v, { a: 0.01, pan }); },
    /** lead(t, note, dur, v, {type, vib, glideTo, cutoff}) */
    lead(t, n, dur, v = 1, o = {}) { const f = mtof(n); tone(music, o.type || 'square', f, t, dur, 0.07 * v, { lp: o.cutoff ?? 2600, a: 0.012, hold: Math.max(0, dur - 0.1), vib: o.vib === false ? null : { rate: 5.2, depth: 0.005 }, to: o.glideTo ? mtof(o.glideTo) : undefined, glide: o.glide ?? 0.08, pan: o.pan }); tone(music, 'sawtooth', f * 1.003, t, dur, 0.03 * v, { lp: 1800, a: 0.02, hold: Math.max(0, dur - 0.1), pan: -(o.pan || 0), to: o.glideTo ? mtof(o.glideTo) * 1.003 : undefined, glide: o.glide ?? 0.08 }); },
    /** arp(t0, notes[], stepSec, dur, v): cycles through notes until t0+dur */
    arp(t0, notes, step, dur, v = 1, o = {}) { let i = 0; for (let t = t0; t < t0 + dur - 1e-6; t += step, i++) A.pluck(t, notes[i % notes.length] + (o.octaves && Math.floor(i / notes.length) % 2 ? 12 : 0), step * 1.6, v, { pan: i % 2 ? 0.3 : -0.3, bright: o.bright }); },
    /** long cinematic drone (root + fifth), for tension beds */
    drone(t, n, dur, v = 1) { tone(music, 'sawtooth', mtof(n), t, dur, 0.05 * v, { lp: 500, a: Math.min(1.5, dur / 3), hold: dur * 0.5, det: -6 }); tone(music, 'sawtooth', mtof(midi(n) + 7), t, dur, 0.035 * v, { lp: 450, a: Math.min(1.5, dur / 3), hold: dur * 0.5, det: 6 }); tone(music, 'sine', mtof(midi(n) - 12), t, dur, 0.12 * v, { a: 1, hold: dur * 0.6 }); },

    // ---------------- sfx (sfx bus) — sync these to the picture
    whoosh(t, dur = 0.5, v = 1, up = true) { noise(sfx, t, dur, 0.25 * v, { f: up ? 350 : 5000, to: up ? 6500 : 260, q: 1.3, swell: true }); },
    /** riser(t, dur, v): tension build ending exactly at t+dur (put the drop there) */
    riser(t, dur = 2, v = 1) { noise(sfx, t, dur, 0.22 * v, { f: 250, to: 9000, q: 1.1, swell: true }); tone(sfx, 'sawtooth', 110, t, dur, 0.035 * v, { to: 880, glide: dur, a: dur * 0.8, lp: 2400 }); tone(sfx, 'sine', 220, t, dur, 0.05 * v, { to: 1760, glide: dur, a: dur * 0.85 }); },
    downer(t, dur = 1, v = 1) { noise(sfx, t, dur, 0.18 * v, { f: 6000, to: 200, q: 1.1 }); tone(sfx, 'sine', 900, t, dur, 0.06 * v, { to: 80, glide: dur }); },
    impact(t, v = 1) { tone(sfx, 'sine', 70, t, 1.1, 0.75 * v, { to: 32, glide: 0.9 }); noise(sfx, t, 0.35, 0.3 * v, { type: 'lowpass', f: 1400 }); noise(sfx, t, 0.9, 0.08 * v, { type: 'highpass', f: 4000 }); A.duck(t, 0.5, 0.65); },
    boom(t, v = 1) { tone(sfx, 'sine', 55, t, 2.2, 0.8 * v, { to: 28, glide: 1.8, a: 0.004 }); noise(sfx, t, 1.4, 0.16 * v, { type: 'lowpass', f: 500, to: 120 }); A.duck(t, 0.9, 0.7); },
    hit(t, v = 1) { tone(sfx, 'square', 120, t, 0.25, 0.14 * v, { to: 60, glide: 0.2, lp: 1800 }); noise(sfx, t, 0.22, 0.26 * v, { f: 1800, q: 0.7 }); tone(sfx, 'sine', 60, t, 0.5, 0.45 * v, { to: 38, glide: 0.4 }); },
    tick(t, v = 1, f = 2800, pan = 0) { noise(sfx, t, 0.03, 0.12 * v, { f, q: 2.5, pan }); tone(sfx, 'sine', f * 0.7, t, 0.025, 0.05 * v, { pan }); },
    click(t, v = 1) { noise(sfx, t, 0.012, 0.2 * v, { f: 3600, q: 3 }); tone(sfx, 'sine', 1800, t, 0.018, 0.08 * v); },
    type(t, v = 1, pan = 0) { noise(sfx, t, 0.02, 0.1 * v * (0.8 + rnd() * 0.4), { f: 2400 + rnd() * 1400, q: 2, pan }); tone(sfx, 'sine', 180 + rnd() * 60, t, 0.02, 0.05 * v, { pan }); },
    pop(t, v = 1, pitch = 1) { tone(sfx, 'sine', 380 * pitch, t, 0.12, 0.3 * v, { to: 900 * pitch, glide: 0.05 }); noise(sfx, t, 0.02, 0.08 * v, { f: 2000 }); },
    blip(t, n = 'E6', v = 1, pan = 0) { tone(sfx, 'square', mtof(n), t, 0.09, 0.05 * v, { lp: 4000, pan }); tone(sfx, 'sine', mtof(n), t, 0.12, 0.08 * v, { pan }); },
    notify(t, v = 1) { A.bellFx(t, 'E6', 0.9, v * 0.9); A.bellFx(t + 0.09, 'B6', 1.1, v); },
    bellFx(t, n, dur = 1, v = 1, pan = 0) { fm(sfx, mtof(n), t, dur, 0.08 * v, 3.5, 2, pan); tone(sfx, 'sine', mtof(n), t, dur * 0.8, 0.05 * v, { pan }); },
    sparkle(t, v = 1) { [0, 0.05, 0.11, 0.18].forEach((d, i) => A.bellFx(t + d, 88 + [0, 4, 7, 12][i], 0.6, 0.35 * v, (i - 1.5) * 0.4)); },
    chirp(t, f0, f1, dur = 0.15, v = 1, pan = 0) { tone(sfx, 'sine', f0, t, dur, 0.12 * v, { to: f1, glide: dur * 0.8, a: 0.01, pan }); tone(sfx, 'triangle', f0 * 2, t, dur * 0.8, 0.03 * v, { to: f1 * 2, glide: dur * 0.8, a: 0.01, pan }); },
    glitch(t, dur = 0.25, v = 1) { for (let k = 0; t + k * 0.03 < t + dur; k++) { tone(sfx, 'square', 200 + rnd() * 2200, t + k * 0.03, 0.028, 0.05 * v, { lp: 5000, pan: rnd() * 1.4 - 0.7 }); } noise(sfx, t, dur, 0.05 * v, { type: 'highpass', f: 3000 }); },
    swipe(t, v = 1, dir = 1) { noise(sfx, t, 0.22, 0.16 * v, { f: dir > 0 ? 900 : 4000, to: dir > 0 ? 4000 : 900, q: 1.2, swell: true, pan: dir * 0.3 }); },
    cash(t, v = 1) { A.click(t, v); A.bellFx(t + 0.03, 'C7', 0.7, v * 0.8, 0.2); A.bellFx(t + 0.1, 'E7', 0.9, v * 0.7, -0.2); },

    // ---------------- mix controls
    /** duck the music bus (sidechain feel) at t for dur seconds by depth 0..1 */
    duck(t, dur = 0.25, depth = 0.5) { duckEvents.push([t, dur, depth]); },
    /** sweep the music low-pass from Hz to Hz between t0 and t1 (muffled -> open for builds, reverse for drops) */
    sweep(t0, t1, from, to) { musicLP.frequency.setValueAtTime(from, t0); musicLP.frequency.exponentialRampToValueAtTime(to, t1); },
    /** music bus volume from time t (ramped). Calls may come in any order; they're applied sorted by time. */
    level(t, v, ramp = 0.02) { levelEvents.push([t, v, ramp]); },
    /** true silence from t0 to t1 — music, sfx AND reverb tails. Sounds scheduled exactly at t1 play normally. */
    silence(t0, t1, fade = 0.03) { silenceEvents.push([t0, t1, fade]); },
    /** reverb send amount (default 0.2) */
    reverb(v) { verb.gain.value = v; },

    // ---------------- sequencing
    /** pattern(t0, 'x...x...x..xx...', fn, repeat=1, step=beat/4): fn(t, i, char) for each non-'.' step */
    pattern(t0, str, fn, repeat = 1, step = beat / 4) { const s = str.replace(/\s/g, ''); for (let r = 0; r < repeat; r++) for (let i = 0; i < s.length; i++) if (s[i] !== '.') fn(t0 + (r * s.length + i) * step, r * s.length + i, s[i]); },
    /** progression(t0, ['Am', 'F', 'C', 'G'], beatsEach, fn(notes, t, i, name), oct) */
    progression(t0, names, beatsEach, fn, oct = 4) { names.forEach((nm, i) => fn(chord(nm, oct), t0 + i * beatsEach * beat, i, nm)); },
    /** every(t0, t1, step, fn(t, i)) */
    every(t0, t1, step, fn) { let i = 0; for (let t = t0; t < t1 - 1e-6; t += step) fn(t, i++); },
  };
  window.score(A);
  // apply level automation in time order (offline scheduling can't read back current values)
  levelEvents.sort((a, b) => a[0] - b[0]).reduce((prev, [t, v, ramp]) => { musicIn.gain.setValueAtTime(prev, t); musicIn.gain.linearRampToValueAtTime(v, t + ramp); return v; }, 1);
  // ducks: merge every duck into one envelope (overlapping ducks take the deepest dip), 400 points/s
  if (duckEvents.length) {
    const rate = 400, n = Math.max(2, Math.ceil(DUR * rate)), env = new Float32Array(n).fill(1);
    for (const [t, dur, depth] of duckEvents) {
      const i0 = Math.max(0, Math.floor(t * rate)), i1 = Math.min(n - 1, Math.ceil((t + dur) * rate));
      for (let i = i0; i <= i1; i++) { const x = i / rate - t, g = x < 0.01 ? 1 - depth * clamp(x / 0.01) : 1 - depth * (1 - clamp((x - 0.01) / Math.max(0.01, dur - 0.01))); if (g < env[i]) env[i] = g; }
    }
    musicDuck.gain.setValueCurveAtTime(env, 0, DUR);
  }
  silenceEvents.sort((a, b) => a[0] - b[0]).forEach(([t0, t1, f]) => {
    const g = master.gain, base = 0.85;
    g.setValueAtTime(base, Math.max(0, t0 - f)); g.linearRampToValueAtTime(0.0001, t0);
    g.setValueAtTime(0.0001, Math.max(t0, t1 - 0.004)); g.linearRampToValueAtTime(base, t1);
  });
  const buf = await ac.startRendering();
  return [buf.getChannelData(0), buf.getChannelData(1)];
}

// ---------------------------------------------------------------- mastering: BS.1770-4 loudness + true-peak limiter
function kWeight(x) {
  const y = new Float32Array(x.length); let x1 = 0, x2 = 0, y1 = 0, y2 = 0;
  const b = [1.53512485958697, -2.69169618940638, 1.19839281085285], a = [-1.69065929318241, 0.73248077421585];
  for (let i = 0; i < x.length; i++) { const v = b[0] * x[i] + b[1] * x1 + b[2] * x2 - a[0] * y1 - a[1] * y2; x2 = x1; x1 = x[i]; y2 = y1; y1 = v; y[i] = v; }
  const z = new Float32Array(x.length); x1 = x2 = y1 = y2 = 0;
  const b2 = [1, -2, 1], a2 = [-1.99004745483398, 0.99007225036621];
  for (let i = 0; i < y.length; i++) { const v = b2[0] * y[i] + b2[1] * x1 + b2[2] * x2 - a2[0] * y1 - a2[1] * y2; x2 = x1; x1 = y[i]; y2 = y1; y1 = v; z[i] = v; }
  return z;
}
function lufs(L, R) {
  const kl = kWeight(L), kr = kWeight(R), blk = Math.round(0.4 * SR), hop = Math.round(0.1 * SR), ms = [];
  for (let s = 0; s + blk <= kl.length; s += hop) { let a = 0; for (let i = s; i < s + blk; i++) a += kl[i] * kl[i] + kr[i] * kr[i]; ms.push(a / blk); }
  const ld = (m) => -0.691 + 10 * Math.log10(m + 1e-12);
  let g = ms.filter((m) => ld(m) > -70); if (!g.length) return -70;
  const rel = ld(g.reduce((a, b) => a + b, 0) / g.length) - 10;
  g = g.filter((m) => ld(m) > rel);
  return ld(g.reduce((a, b) => a + b, 0) / g.length);
}
const OS_TAPS = (() => { const taps = []; for (let ph = 1; ph < 4; ph++) { const h = []; let s = 0; for (let k = -8; k < 8; k++) { const t = (k + ph / 4), w = 0.5 + 0.5 * Math.cos(Math.PI * t / 8), v = t === 0 ? 1 : Math.sin(Math.PI * t) / (Math.PI * t) * w; h.push(v); s += v; } taps.push(h.map((v) => v / s)); } return taps; })();
function truePeakAbs(x) {
  const out = new Float32Array(x.length);
  for (let i = 0; i < x.length; i++) { let m = Math.abs(x[i]); for (let p = 0; p < 3; p++) { let v = 0; const h = OS_TAPS[p]; for (let k = -8; k < 8; k++) { const j = i - k; if (j >= 0 && j < x.length) v += x[j] * h[k + 8]; } const a = Math.abs(v); if (a > m) m = a; } out[i] = m; }
  return out;
}
function limit(L, R, ceilDb) {
  const ceil = Math.pow(10, ceilDb / 20), look = Math.round(0.003 * SR), rel = Math.exp(-1 / (0.08 * SR)), pl = truePeakAbs(L), pr = truePeakAbs(R), n = L.length;
  const need = new Float32Array(n); for (let i = 0; i < n; i++) { const pk = Math.max(pl[i], pr[i]); need[i] = pk > ceil ? ceil / pk : 1; }
  const gmin = new Float32Array(n); for (let i = 0; i < n; i++) { let m = 1; for (let j = i; j < Math.min(n, i + look); j++) if (need[j] < m) m = need[j]; gmin[i] = m; }
  let g = 1; for (let i = 0; i < n; i++) { g = gmin[i] < g ? gmin[i] : gmin[i] - (gmin[i] - g) * rel; L[i] *= g; R[i] *= g; }
}
function wavFloat32(L, R) {
  const n = L.length, dataBytes = n * 8, buf = new ArrayBuffer(44 + dataBytes), v = new DataView(buf), w = (o, s) => { for (let i = 0; i < s.length; i++) v.setUint8(o + i, s.charCodeAt(i)); };
  w(0, 'RIFF'); v.setUint32(4, 36 + dataBytes, true); w(8, 'WAVE'); w(12, 'fmt '); v.setUint32(16, 16, true); v.setUint16(20, 3, true); v.setUint16(22, 2, true);
  v.setUint32(24, SR, true); v.setUint32(28, SR * 8, true); v.setUint16(32, 8, true); v.setUint16(34, 32, true); w(36, 'data'); v.setUint32(40, dataBytes, true);
  let o = 44; for (let i = 0; i < n; i++) { v.setFloat32(o, L[i], true); v.setFloat32(o + 4, R[i], true); o += 8; }
  return new Uint8Array(buf);
}
/** -> { base64, lufs, peak } or null when the film has no score */
async function audioWav() {
  const r = await renderAudio(); if (!r) return null;
  let [L, R] = r; L = Float32Array.from(L); R = Float32Array.from(R);
  const target = FILM.lufs ?? -14, passes = [];
  for (let it = 0; it < 4; it++) {
    const lu = lufs(L, R); passes.push(lu);
    if (lu <= -69) break;                                 // silent score
    if (Math.abs(lu - target) < 0.1 && it > 0) break;
    const gain = Math.pow(10, (target - lu) / 20); for (let i = 0; i < L.length; i++) { L[i] *= gain; R[i] *= gain; }
    limit(L, R, -1.5);
  }
  // 10 ms fade-in / 30 ms fade-out: no clicks at the edges
  const fi = Math.round(0.01 * SR), fo = Math.round(0.03 * SR);
  for (let i = 0; i < fi; i++) { L[i] *= i / fi; R[i] *= i / fi; }
  for (let i = 0; i < fo; i++) { const k = L.length - 1 - i; L[k] *= i / fo; R[k] *= i / fo; }
  // level timeline: RMS dBFS per 0.25 s window (lets QC check contrast and silences)
  const win = Math.round(0.25 * SR), timeline = [];
  for (let s0 = 0; s0 < L.length; s0 += win) { let a = 0, n = 0; for (let i = s0; i < Math.min(L.length, s0 + win); i++) { a += L[i] * L[i] + R[i] * R[i]; n += 2; } timeline.push(Math.round(10 * Math.log10(a / n + 1e-12))); }
  const bytes = wavFloat32(L, R); let s = ''; const CH = 0x8000;
  for (let i = 0; i < bytes.length; i += CH) s += String.fromCharCode.apply(null, bytes.subarray(i, i + CH));
  // loudest hits: 50 ms RMS windows, top 3 at least 0.4 s apart (the timeline's 0.25 s windows under-read short hits)
  const hw = Math.round(0.05 * SR), st = [];
  for (let s0 = 0; s0 + hw <= L.length; s0 += hw) { let a = 0; for (let i = s0; i < s0 + hw; i++) a += L[i] * L[i] + R[i] * R[i]; st.push([s0 / SR, 10 * Math.log10(a / (2 * hw) + 1e-12)]); }
  const hits = [];
  for (const [t, db] of st.slice().sort((x, y) => y[1] - x[1])) { if (hits.length === 3) break; if (hits.every((h) => Math.abs(h.t - t) >= 0.4)) hits.push({ t: +t.toFixed(2), db: +db.toFixed(1) }); }
  // sections: loudness between the film's own timing marks (the S object in scenes.js), so QC can check
  // the dip before the drop and the drop itself directly, whatever the tempo
  const sections = [];
  try {
    const M = (typeof S !== 'undefined' && S && typeof S === 'object') ? S : null, marks = new Map();
    if (M) for (const [k, v] of Object.entries(M)) if (typeof v === 'number' && isFinite(v) && v >= 0 && v < DUR - 0.05) { const key = Math.round(v * 100) / 100; marks.set(key, (marks.has(key) ? marks.get(key) + '/' : '') + k); }
    if (marks.size && !marks.has(0)) marks.set(0, 'start');
    const ts = [...marks.keys()].sort((x, y) => x - y);
    ts.forEach((t0, i) => {
      const t1 = i + 1 < ts.length ? ts[i + 1] : DUR, a0 = Math.round(t0 * SR), a1 = Math.min(L.length, Math.round(t1 * SR));
      if (a1 - a0 < SR * 0.02) return;
      let a = 0; for (let j = a0; j < a1; j++) a += L[j] * L[j] + R[j] * R[j];
      sections.push({ name: marks.get(t0), t0, db: +(10 * Math.log10(a / (2 * (a1 - a0)) + 1e-12)).toFixed(1) });
    });
  } catch { /* no S: skip */ }
  for (const h of hits) { const m = sections.filter((x) => x.t0 <= h.t + 0.01 && h.t - x.t0 < BEAT).pop(); if (m) h.near = `${m.name} +${Math.max(0, h.t - m.t0).toFixed(2)} s`; }
  return { base64: btoa(s), lufs: lufs(L, R), passes, timeline, hits, sections };
}
window.audioWav = audioWav;
