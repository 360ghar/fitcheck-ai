# Style: Motion-graphics explainer

**The look:** clean flat shapes, icons, UI cards, charts and arrows that build up an idea step by step, like the best product-launch explainers. The palette is bright on a light or dark neutral, with soft shadows, generous rounding and precise alignment. Everything eases beautifully and snaps to a grid.

**Defaults:** `bg #f4f1ea` (or `#0e1726` for dark), ink `#141414`, accent `#3a5bff` + one support colour, `grain 0`, 30 fps, 110–120 BPM.
**Fonts:** Outfit 700 for headlines, Instrument Sans 400/700 for labels, Geist Mono for numbers and code.

## Vocabulary
- **Build-up:** elements appear one at a time, staggered 80–120 ms, each with `spring`/`eOutBack` scale 0.6 → 1 and an `A.pop` whose pitch rises through the sequence.
- **UI card:** `roundRect` with a soft shadow (`ctx.shadowColor = rgba('#000', .15); ctx.shadowBlur = 40*U; ctx.shadowOffsetY = 16*U`), an icon, a label and a value.
- **Connector:** `arrow()` or a `drawOn()` curve (`bez`) linking two elements, drawn on over 0.3–0.5 s.
- **Chart moment:** `barsChart`/`lineChart`/`donut` grow on the beat, then a `counter` lands the key number with `A.cash`/`A.hit`.
- **Zoom-through:** `camera(camFit(cardRect, seg(t, a, b)), draw)` pushes into one card until it fills the screen and becomes the next scene. Wrap the fastest 0.3 s in `motionBlur` for a pro feel.
- **Checklist:** `icon('check', ..., {u})` drawn on beside each line, one per beat.
- **Cursor:** `icon('cursor')` travels on a `bez` path and clicks (`A.click`), with the target pulsing.

## Rules
- A grid: align everything to a column system (e.g. 8% margins, 12-column feel). Equal gaps.
- One idea per scene: problem → mechanism → result → name.
- Icons plus 1–4 word labels. Never paragraphs.
- Rounded corners 18–32 U, shadows soft and consistent, and the same light direction throughout.
- Motion is confident and quick: 0.3–0.5 s moves, 70–100 ms staggers, nothing floats aimlessly.

## Pattern
```js
const C = { bg: '#f4f1ea', ink: '#141414', acc: '#3a5bff', sup: '#ffb020', card: '#ffffff' };
function card(x, y, w, h, u, fn) {           // pops in with a spring; fn draws the content in local coords
  const s = lerp(0.6, 1, spring(u * 0.9)), a = clamp(u * 3);
  withT({ x: x + w / 2, y: y + h / 2, scale: s, alpha: a }, () => {
    ctx.save(); ctx.shadowColor = rgba('#000000', 0.14); ctx.shadowBlur = 40 * U; ctx.shadowOffsetY = 16 * U;
    roundRect(-w / 2, -h / 2, w, h, 28 * U, C.card); ctx.restore();
    fn(w, h);
  });
}
// usage inside a scene: card(SAFE.x0, y, SAFE.w, 180*U, seg(lt, 0.2, 0.9), (w, h) => {
//   icon('bolt', -w/2 + 80*U, 0, 64*U, { color: C.acc, lw: 2.2 });
//   text('Instant setup', -w/2 + 150*U, 14*U, 56*U, { font: 'Outfit', color: C.ink }); });
```

## Pitfalls
- Everything appearing at once. Stagger, and give each element its own sound.
- Tiny labels in 9:16: at least 44 U, better 56 U.
- Cluttered screens: at most 3–4 cards at once. Zoom or cut to reset.
