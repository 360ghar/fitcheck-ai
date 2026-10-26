# Style: Kinetic typography

**The look:** words are the actors. Huge, tightly tracked type slams, stacks, slides and locks into place on the beat, against a flat background with one accent colour. The feel is a well-edited title sequence meeting a poster.

**Defaults:** `bg #0d0d0d`, `fg #f4f1ea`, one accent (`#ff4d2e`, or brand), `grain 0.06`, 30 fps, 124–128 BPM.
**Fonts:** pick **one display face and one support face** (see craft.md → Typography). Display options: Boldonse (1–2-word slams; its caps are ~1.7× taller than other faces at the same size, so check the height with `capH`), Big Shoulders 700 (tall stacked lines) or Bricolage Grotesque 700 (sentences). Support options: Geist Mono (small labels) or Instrument Serif italic (one contrasting word).

## Vocabulary
- **Slam:** a word enters at 2–3× scale and snaps to 1 on the beat (`reveal(..., {mode:'slam', by:'char'})`), with `A.impact` and a tiny `camera` shake (6–12 U, decaying over 0.2 s).
- **Stack:** lines of different sizes justified to the same width (`fitSize` each line to a common `maxW`), revealed line by line with `mode:'mask'`.
- **Swap:** a word is replaced in place by another on each beat (the rhythm carries meaning: "fast. / cheap. / done.").
- **Kinetic scroll:** a column of words moves up continuously and the current word highlights in the accent colour.
- **Counter:** a big number counts with `counter()`. Ease the count with `eOutExpo` so it decelerates into the final value, then `pulse` a scale bump when it lands.
- **Invert:** on the drop, background and foreground swap (`flash` to fg, then draw with reversed colours).
- **Outline echo:** a stroke-only copy of the word trails behind the solid one (`text(..., {color:null, stroke:C.fg, lw})`) at 60% scale steps.

## Rules
- At most about 6 words visible at once. One accent word per moment.
- Big: in 9:16 slams run 200–320 U, sentences 90–130 U. Use `maxW: SAFE.w` on everything.
- Tight tracking on display type (−0.02 to −0.04). Uppercase for slams, sentence case for lines.
- Move on the beat grid: new word on the beat, stack lines on 8th notes, holds of at least 2 beats on key words.
- Let empty space and a flat background do the work. No textures behind text.

## Pattern
```js
const C = { bg: '#0d0d0d', fg: '#f4f1ea', acc: '#ff4d2e' };
const S = { hook: 0, swap: bars(1), stack: bars(3), drop: bars(5), end: bars(7) };
const SWAPS = ['FAST.', 'CHEAP.', 'DONE.'];

function frame(t) {
  const shake = 10 * U * pulse(t, S.drop, 0.25);
  camera({ shake }, () => {
    if (t < S.swap) hook(t);
    else if (t < S.stack) swap(t - S.swap);
    else if (t < S.drop) stack(t - S.stack);
    else if (t < S.end) drop(t - S.drop);
    else endCard(t - S.end);
  });
  flash(pulse(t, S.drop, 0.18) * 0.8, C.fg);
}
function swap(lt) {
  const i = Math.min(SWAPS.length - 1, Math.floor(lt / BEAT)), lu = seg(lt - i * BEAT, 0, 0.18);
  const s = 1 + 0.08 * pulse(lt, i * BEAT, 0.2);
  withT({ x: CX, y: CY, scale: s }, () => reveal(SWAPS[i], 0, 0, 260 * U, lu, { align: 'center', base: 'middle', font: 'Boldonse', mode: 'slam', by: 'char', stagger: 0.3, color: i === SWAPS.length - 1 ? C.acc : C.fg, maxW: SAFE.w }));
}
```

## Pitfalls
- Text sliding in slowly with linear easing: use `eOutQuint`/`eOutExpo`, 0.2–0.35 s.
- Too many fonts. Too many words. Words off the beat.
- A dead end card. Land it with a hit, then hold still and let the motif resolve.
