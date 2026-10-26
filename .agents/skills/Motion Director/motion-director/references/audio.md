# Audio: the score is half the video

`film/score.js` defines `function score(A) { ... }`. Everything is synthesized. The engine renders it offline and masters it to −14 LUFS with a true-peak limiter, so don't worry about loudness. Worry about **sync, contrast and one memorable sound**.

Times are in seconds. `A.b(n)` = n beats, `A.at(bar, beat)` = seconds, `A.bar`, `A.beat`, `A.dur`. Notes are MIDI numbers or names (`'A3'`, `'C#5'`). `A.chord('Am7', 3)` → MIDI array. Use the same time constants as scenes.js (`BEAT`, `BAR`, your scene-time object `S` are all global), so picture and sound can't drift.

## Instrument kit
**Drums** (music bus): `A.kick(t, v, {f0=155, f1=43, len=.38})` (pitch sweep and length: lower `f1` and longer `len` = boomier) · `A.snare(t, v)` · `A.clap(t, v)` · `A.hat(t, v, open=false)` · `A.shaker(t, v)` · `A.tom(t, note, v)` · `A.crash(t, v)`

**Tonal** (music bus):
- `A.bass(t, note, dur, v, {type:'saw'|'square'|'sine', cutoff, glideTo})`
- `A.sub(t, note, dur, v)`
- `A.pad(t, notes[], dur, v, {cutoff, cutoffTo, attack, width})`
- `A.keys(t, notes[], dur, v)` (soft e-piano)
- `A.pluck(t, note, dur, v, {bright, pan})`
- `A.bell(t, note, dur, v, pan)`
- `A.lead(t, note, dur, v, {type, cutoff, glideTo, vib})`
- `A.arp(t0, notes[], step, dur, v, {octaves})`
- `A.drone(t, note, dur, v)`

**Sound effects** (sfx bus), which you sync to picture events:
- **Motion:** `A.whoosh(t, dur, v, up=true)` · `A.riser(t, dur, v)` (ends at t+dur; put the drop there) · `A.downer(t, dur, v)` · `A.swipe(t, v, dir)`
- **Hits:** `A.impact(t, v)` (auto-ducks the music) · `A.boom(t, v)` (big cinematic sub drop) · `A.hit(t, v)`
- **Small and UI:** `A.tick(t, v, freq, pan)` · `A.click(t, v)` · `A.type(t, v, pan)` (keyboard key) · `A.pop(t, v, pitch)` · `A.blip(t, note, v, pan)` · `A.notify(t, v)` · `A.cash(t, v)`
- **Colour:** `A.bellFx(t, note, dur, v, pan)` · `A.sparkle(t, v)` · `A.chirp(t, f0, f1, dur, v, pan)` · `A.glitch(t, dur, v)`

**Mix:**
- `A.duck(t, dur, depth)` sidechain-dips the music.
- `A.sweep(t0, t1, fromHz, toHz)` automates the music low-pass. Muffle before a drop (20000 → 600), open on it (600 → 20000).
- `A.level(t, v, ramp)` sets the music-bus volume from time t. Calls may come in any order.
- `A.silence(t0, t1)` gives **true silence** from t0 to t1: music, sound effects *and* reverb tails. Anything scheduled exactly at t1 (the drop) plays at full power. This is the "breath" before a drop.
- `A.reverb(v)` sets the reverb send amount (default 0.2).

Buses: `A.music` and `A.sfx` (Web Audio nodes) are the destinations for the raw voices below.

**Sequencing:**
- `A.pattern(t0, 'x...x...x..x.x..', (t, i, ch) => ..., repeat, step=beat/4)` — one character per 16th note.
- `A.progression(t0, ['Am','F','C','G'], beatsEach, (notes, t, i, name) => ..., octave)`
- `A.every(t0, t1, step, (t, i) => ...)`

Raw voices if you need something custom: `A.tone(A.music|A.sfx, type, hz, t, dur, peak, {to, glide, a, hold, lp, lpTo, hp, q, det, pan, vib})`, `A.noise(bus, t, dur, peak, {type, f, to, q, a, hold, swell, pan})`, `A.fm(bus, hz, t, dur, peak, ratio, index, pan)`.

## Rules
1. **Sync is everything.** List the picture's events (every word slam, cut, reveal, particle burst) and give each one a sound. A word that slams in without a sound feels broken.
2. **Contrast.** Quiet intro, then a riser, then 0.2–0.5 s of true silence (`A.silence(t0, drop)`), then the drop. Energy is relative. The QC prints the loudness of each section between your `S` marks, the 3 loudest hits (50 ms windows) and a level timeline (dB per 0.5 s). Check that the section before the drop reads `silent` or clearly lower, and that the drop is among the loudest hits (each hit is labelled with the `S` mark it lands within a beat of, e.g. `drop +0.18 s`). If a later section is clearly louder than the drop, turn it down (`A.level`) or thin it out.
3. **One earworm.** A 3–5 note motif (lead, bell or pluck) stated in the hook and resolved on the end card.
4. **The low end carries it.** Kick + bass or sub on the downbeats. Keep bass notes on the chord roots.
5. **End on resolution.** The last chord is the tonic (or a warm major), then a tail: let the final sound ring out to the end.
6. **Sound effects over music.** Impacts duck the music automatically. Keep hats and shakers quiet (`v` 0.4–0.8).

## Recipes
Each recipe is a starting point: change the motif, the key and the sync points for the film.

**Punchy electronic (kinetic type, launches): 124–128 BPM, A minor, Am–F–C–G**
```js
function score(A) {
  const D = S.drop;                                   // scene times from scenes.js
  // intro: filtered pad + ticking hats, hook motif on a pluck
  A.sweep(0, D, 700, 20000);
  A.progression(0, ['Am', 'F', 'C', 'G'], 4, (n, t) => A.pad(t, n, A.b(4), 0.7), 3);
  A.pattern(0, '..x...x...x...x.', (t) => A.hat(t, 0.5), Math.round(D / A.bar));
  [[0, 'A4'], [0.75, 'C5'], [1.5, 'E5'], [2.5, 'D5']].forEach(([b, n]) => A.pluck(A.b(b), n, 0.35, 1));
  A.riser(D - A.b(4), A.b(4) - 0.25, 0.9); A.silence(D - 0.25, D);          // riser, a breath of silence, then...
  // drop: four-on-the-floor, clap on 2 and 4, saw bass on the roots
  A.impact(D, 1); A.crash(D, 0.8);
  const bars = Math.floor((A.dur - D) / A.bar);
  A.pattern(D, 'x...x...x...x...', (t) => A.kick(t, 1), bars);
  A.pattern(D, '....x.......x...', (t) => A.clap(t, 0.8), bars);
  A.pattern(D, '..x...x...x...x.', (t) => A.hat(t, 0.6), bars);
  A.progression(D, ['Am', 'F', 'C', 'G'], 4, (n, t) => { A.bass(t, n[0] - 12, A.b(4) - 0.05, 1); A.pad(t, n, A.b(4), 0.6, { cutoff: 2600 }); }, 3);
}
```

**Cinematic build and hit (neon, trailers): 90–100 BPM (or free time), D minor**
Drone from 0 (`A.drone(0, 'D2', dur, 1)`), heartbeat kicks spaced 1 per bar and then speeding up, `A.riser` into a `A.boom` + `A.impact` at the reveal, a `A.pad` of Dm9 with `cutoffTo` opening, `A.bell` motif (D5–F5–A5) over the end card, `A.downer` into the final hold.

**Warm and playful (ink, stories): 100–112 BPM, C or F major, I–V–vi–IV**
`A.keys` chords on beats 1 and 3, `A.pluck` or `A.bell` melody, `A.shaker` 16ths quietly, soft kick on 1 and 3. Cartoon sync with `A.pop` (appear), `A.chirp` (character reacts), `A.tick` (footsteps every ~0.12 s), `A.bellFx` (idea!), and `A.sparkle` on the payoff.

**Clean explainer (motion graphics): 110–120 BPM, E or G major, Imaj7–vi7–IV–V**
Minimal: `A.keys` + `A.sub` on roots + a light `A.pattern` of kick/hat. Every icon or element that appears gets an `A.pop` or `A.blip` (vary pitch across a sequence: 1, 1.12, 1.26 ...), and charts growing get a short `A.riser` or ascending `A.blip`s. Numbers landing: `A.cash` or `A.hit`.

**Sound design only (no music)**
Build a bed from `A.drone` or low `A.noise` (lowpass 300–600 Hz), then a dense sync layer. It works best for tense or minimal pieces. It still needs a clear peak moment (`A.boom`).

## Common mistakes
- Music at full energy from frame 0 leaves nowhere to go. Keep the intro sparse.
- Hits a few frames off the picture: compute both from the same constants.
- Too many simultaneous voices makes mud. Pads 0.5–0.8, bass 1, plucks 0.8–1, sfx 0.6–1.
- Forgetting the tail: the last 0.5 s should still have a sound ringing out, not a hard stop.
