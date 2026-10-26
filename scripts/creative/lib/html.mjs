/**
 * HTML/CSS templates for every creative surface.
 *
 * One template system for all surfaces — screenshot frames, the 21:9 header, the
 * 3:2 search card, the preview poster. Each is the same paper sheet with the
 * same type ramp; only the composition changes.
 *
 * Rules the templates enforce so a designer never has to remember them:
 *   - Logical CSS properties plus `dir` on <html>, so RTL mirrors the layout
 *     rather than only the text.
 *   - Every text block is measured in the browser and stepped to the largest
 *     size that fits its line budget. Nothing is truncated with an ellipsis.
 *   - The device is built at its largest possible size and scaled down to fit
 *     the space the headline leaves, so a three-line headline never leaves a
 *     dead band above the phone and never collides with it.
 *   - The screen image fills the device with `cover`: one aspect, no squashing.
 */
import { fileUrl, GRAIN, BRAND_MARK } from './paths.mjs';
import { DEVICES, GRAIN_OPACITY, INK, SLAB, STOCKS, TYPE } from './design.mjs';

const esc = (value) =>
  String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

/** Layout archetypes. `tilt` is degrees; the sign flips automatically in RTL. */
export const LAYOUTS = {
  /** Headline above, phone below, a paper mat and a strip of tape. */
  standard: { align: 'center', tilt: -1.25, tape: 'start' },
  /** Same, pushed aside to leave room for a second paper object. */
  collage: { align: 'end', tilt: -1.8, tape: 'end' },
  /** The offer: headline, a stat card, and the app bleeding off the corner. */
  offer: { align: 'center', tilt: -1.6, tape: null },
};

/**
 * Split "50 AI clothing uploads" into ["50", "AI clothing uploads"] so the
 * number can carry the accent colour at display size.
 *
 * The digits must be followed by whitespace. Latin, Cyrillic and the Indic
 * scripts write it that way; Japanese and Chinese write "1日10枚" and "每天10张",
 * where a leading digit is a counter, not a statistic — splitting there printed
 * "1" above "日10枚", which is wrong. Those rows keep their whole localized
 * string instead.
 */
export function splitStat(text) {
  const match = String(text).match(/^(\p{Nd}+)[ \u00A0]+(.*\S.*)$/su);
  if (!match) return { value: null, label: String(text) };
  return { value: match[1], label: match[2] };
}

function fontFaceRules(fontFiles, font) {
  const rules = [];
  if (font.local) {
    rules.push(
      `@font-face{font-family:'paper-studio-display';src:url('${fontFiles.display}') format('opentype');font-weight:700;font-style:normal;font-display:block}`,
    );
  } else {
    rules.push(
      `@font-face{font-family:'${font.displayFamily}';src:url('${fontFiles.display}') format('woff2');font-weight:700;font-style:normal;font-display:block}`,
    );
  }
  rules.push(
    `@font-face{font-family:'${font.bodyFamily}';src:url('${fontFiles.body}') format('woff2');font-weight:400 700;font-style:normal;font-display:block}`,
  );
  return rules.join('\n');
}

/**
 * Measure, fit, then place. Runs once per page before the screenshot.
 *
 * `fits:false` is recorded in the manifest and fails `check.mjs`: copy that
 * cannot be set legibly is a copy problem, and the fix is an override in
 * `store/creative/copy.json`, not a smaller font.
 */
const PAGE_SCRIPT = `
/*
 * Count rendered lines by measuring the RANGE's height against the line box.
 *
 * Counting getClientRects() entries is wrong for every complex script: an
 * Arabic, Devanagari or Thai line produces one rect per ligature or mark
 * cluster, and Nastaliq produces dozens, so a single line measured as four and
 * the fitter shrank the type for nothing. Height / line-height is the count the
 * browser actually painted.
 */
function lineCount(el) {
  const range = document.createRange();
  range.selectNodeContents(el);
  const rect = range.getBoundingClientRect();
  if (rect.height < 0.5) return 1;
  const style = getComputedStyle(el);
  let lineHeight = parseFloat(style.lineHeight);
  if (!Number.isFinite(lineHeight)) lineHeight = parseFloat(style.fontSize) * 1.2;
  return Math.max(1, Math.round(rect.height / lineHeight));
}
function fitDown(el, min, max, maxLines, step, preferLines) {
  if (!el) return null;
  const stepPx = step || 4;
  const setSize = (size) => {
    el.style.fontSize = size + 'px';
    return lineCount(el);
  };

  // The largest size that respects the line budget.
  let size = max;
  let lines = setSize(max);
  while (lines > maxLines && size > min) {
    size = Math.max(min, size - stepPx);
    lines = setSize(size);
  }
  const budget = { size, lines };

  // A shorter headline set on fewer lines reads as a title. Step down for the
  // preferred count only while the size stays within a quarter of the budget, so
  // a long localized headline keeps its size rather than shrinking to a shape
  // designed around English.
  if (preferLines && budget.lines > preferLines) {
    let lineFit = budget.size;
    let lineFitLines = budget.lines;
    while (lineFitLines > preferLines && lineFit > Math.max(min, budget.size * 0.74)) {
      lineFit -= stepPx;
      lineFitLines = setSize(lineFit);
    }
    if (lineFitLines <= preferLines) {
      budget.size = lineFit;
      budget.lines = lineFitLines;
    }
  }

  // Take the single-line setting when it costs less than a quarter of the size:
  // one strong line beats two ragged ones.
  let one = max;
  let oneLines = setSize(max);
  while (oneLines > 1 && one > min) {
    one = Math.max(min, one - stepPx);
    oneLines = setSize(one);
  }
  const chosen =
    oneLines === 1 && one >= budget.size * 0.74 && one >= min
      ? { size: one, lines: 1 }
      : budget;

  setSize(chosen.size);
  return { size: chosen.size, lines: chosen.lines, fits: chosen.lines <= maxLines };
}
function fitUp(el, min, max, maxLines) {
  if (!el) return null;
  el.style.fontSize = min + 'px';
  let best = min;
  for (let size = min; size <= max; size += 2) {
    el.style.fontSize = size + 'px';
    if (lineCount(el) > maxLines) break;
    best = size;
  }
  el.style.fontSize = best + 'px';
  return { size: best, lines: lineCount(el), fits: true };
}
window.__compose = function () {
  const cfg = window.__CFG || {};
  const out = {};
  document.querySelectorAll('[data-fit]').forEach((el) => {
    const [min, max, lines, step, prefer] = el.dataset.fit.split(',').map(Number);
    out[el.id] = fitDown(el, min, max, lines, step, prefer);
  });
  document.querySelectorAll('[data-grow]').forEach((el) => {
    const [min, max, lines] = el.dataset.grow.split(',').map(Number);
    out[el.id] = fitUp(el, min, max, lines);
  });

  const head = document.getElementById('head');
  const stage = document.getElementById('stage');
  const mat = document.getElementById('matwrap');
  const offerEl = cfg.offer && cfg.offer.selector ? document.querySelector(cfg.offer.selector) : null;
  if (stage && cfg.stage) {
    let top = cfg.stage.top;
    if (head) top = head.offsetTop + head.offsetHeight + (cfg.stage.headGap ?? cfg.stage.gap ?? 0);
    if (offerEl) {
      offerEl.style.top = Math.round(top) + 'px';
      top = offerEl.offsetTop + offerEl.offsetHeight + (cfg.offer.gap || 0);
    }
    stage.style.top = Math.round(top) + 'px';
    const availH = stage.clientHeight;
    const availW = stage.clientWidth;
    if (mat) {
      const matW = cfg.stage.matW;
      const matH = cfg.stage.matH;
      const scale = Math.min(
        cfg.stage.maxScale || 1.08,
        availH / matH,
        (availW * cfg.stage.maxWFrac) / matW,
      );
      mat.style.transform = 'rotate(' + cfg.stage.tilt + 'deg) scale(' + scale.toFixed(4) + ')';
      out.mat = { scale: Number(scale.toFixed(4)), width: Math.round(matW * scale), height: Math.round(matH * scale), stageH: availH };
    }
  }
  return out;
};
`;

function pageShell({ W, H, dir, stock, font, fontFiles, body, extraCss = '', id, cfg }) {
  const s = STOCKS[stock] ?? STOCKS.stone;
  const css = `
:root{
  --page:${s.page}; --card:${s.card}; --sunk:${s.sunk}; --edge:${s.edge};
  --shadow:${s.shadow}; --accent:${s.accent};
  --ink:${INK.primary}; --ink2:${INK.secondary}; --ink3:${INK.muted};
  --brand:${INK.brand}; --brandSlab:${INK.brandSlab}; --onBrand:${INK.onBrand};
  --display:'${font.displayFamily}',Georgia,'Noto Serif','Times New Roman',serif;
  --body-family:'${font.bodyFamily}','Inter',system-ui,sans-serif;
  --lh:${font.lineHeight}; --ls:${font.letterSpacing}; --grain-op:${GRAIN_OPACITY};
}
*{box-sizing:border-box}
html,body{margin:0;padding:0;width:${W}px;height:${H}px;overflow:hidden;background:var(--page);
  -webkit-font-smoothing:antialiased;text-rendering:geometricPrecision}
.sheet{position:relative;width:${W}px;height:${H}px;overflow:hidden;background:var(--page)}
.headline{font-family:var(--display);font-weight:700;color:var(--ink);margin:0;
  line-height:var(--lh);letter-spacing:var(--ls);text-wrap:pretty;
  -webkit-hyphens:none;hyphens:none;overflow-wrap:normal;
  padding-block:${font.headroom ?? '0.10em'} 0.08em}
.support{font-family:var(--body-family);font-weight:500;color:var(--ink2);margin:0;
  line-height:1.32;text-wrap:pretty}
.grain{position:absolute;inset:0;background-image:url('${fileUrl(GRAIN)}');
  background-size:520px 520px;opacity:var(--grain-op);mix-blend-mode:multiply;
  pointer-events:none;z-index:11}
${fontFaceRules(fontFiles, font)}
${extraCss}`;
  return `<!doctype html>
<html lang="${esc(id)}" dir="${dir}">
<head><meta charset="utf-8"><style>${css}</style></head>
<body>
<div class="sheet" id="sheet">
${body}
<div class="grain"></div>
</div>
<script>window.__CFG=${JSON.stringify(cfg ?? {})};${PAGE_SCRIPT}</script>
</body></html>`;
}

/** The device: body, screen, and the cutout its family implies. */
function deviceMarkup({ device, screenSrc, screenW, rtlSign }) {
  const spec = DEVICES[device] ?? DEVICES[69];
  const screenH = Math.round(screenW / spec.screenAspect);
  const bezX = Math.round(screenW * 0.0235);
  const bezY = Math.round(screenH * 0.0125);
  const bodyW = screenW + bezX * 2;
  const bodyH = screenH + bezY * 2;
  const bodyR = Math.round(bodyW * 0.142);
  const screenR = Math.round(bodyR - bezX * 0.86);

  const cutout =
    spec.chrome === 'island'
      ? `<div class="island" style="width:${Math.round(screenW * 0.255)}px;height:${Math.round(
          screenW * 0.081,
        )}px;top:${Math.round(screenH * 0.0125)}px"></div>`
      : `<div class="notch" style="width:${Math.round(screenW * 0.36)}px;height:${Math.round(
          screenH * 0.032,
        )}px"></div>`;

  const css = `
.device{position:relative;width:${bodyW}px;height:${bodyH}px;border-radius:${bodyR}px;
  padding:${bezY}px ${bezX}px;
  background:linear-gradient(152deg,#4c4c47 0%,#1b1b19 24%,#0d0d0c 64%,#35352f 100%);
  box-shadow:0 0 0 1px rgba(28,27,23,.5) inset, 0 2px 0 rgba(255,255,255,.14) inset}
.screen{position:relative;width:${screenW}px;height:${screenH}px;border-radius:${screenR}px;
  overflow:hidden;background:#0b0b0a}
.screen img{display:block;width:100%;height:100%;object-fit:cover;object-position:top center}
/* The cutout is physical hardware, so it is positioned with left:50%, not
   inset-inline-start. Under dir="rtl" the logical property resolved to right:50%
   and then the -50% translate slid the island a further half-width left, so it
   sat across the status-bar clock on every RTL frame (found on ar-SA frame 6).
   Real hardware does not mirror. */
.island{position:absolute;left:50%;transform:translateX(-50%);background:#08080a;
  border-radius:999px;z-index:3;box-shadow:0 0 0 1px rgba(255,255,255,.045)}
.notch{position:absolute;left:50%;transform:translateX(-50%);top:0;background:#08080a;
  border-radius:0 0 ${Math.round(screenW * 0.06)}px ${Math.round(screenW * 0.06)}px;z-index:3}`;

  return {
    css,
    html: `<div class="device">
      <div class="screen"><img src="${screenSrc}" alt="">${cutout}</div>
    </div>`,
    bodyW,
    bodyH,
  };
}

/* ------------------------------------------------------------------ frames */

/**
 * One store screenshot frame.
 *
 * `spec`: { W, H, dir, locale, device, frame, copy, offer, screenSrc, artSrc,
 *           font, fontFiles }
 */
export function frameHtml(spec) {
  const { W, H, dir, locale, frame, copy, offer, screenSrc, font, fontFiles } = spec;
  const layout = LAYOUTS[frame.layout] ?? LAYOUTS.standard;
  const rtlSign = dir === 'rtl' ? -1 : 1;
  const pad = Math.round(W * 0.0795);
  const headTop = Math.round(H * 0.0505);
  const headW = W - pad * 2;
  const matPad = Math.round(W * 0.026);
  const slabX = Math.round(W * SLAB.x);
  const slabY = Math.round(W * SLAB.y);
  const isOffer = frame.layout === 'offer';

  // The device is built at the largest size the canvas would ever allow; the
  // page script scales it down to the space the headline actually leaves.
  const maxScreenW = Math.round(W * (frame.layout === 'collage' ? 0.63 : 0.79));
  const dev = deviceMarkup({ device: spec.device, screenSrc, screenW: maxScreenW, rtlSign });
  const matW = dev.bodyW + matPad * 2;
  const matH = dev.bodyH + matPad * 2;
  const matR = Math.round(W * 0.034) + matPad;

  const align = layout.align === 'center' ? 'center' : 'flex-end';
  const tilt = (layout.tilt * rtlSign).toFixed(2);
  const bleedEnd = Math.round(H * (layout.bleed?.end ?? 0));
  const bleedBottom = Math.round(H * (layout.bleed?.bottom ?? 0));

  const tape =
    layout.tape === null
      ? ''
      : `<div class="tape" style="${layout.tape === 'start' ? 'inset-inline-start' : 'inset-inline-end'}:-${
          Math.round(W * 0.035)
        }px;transform:rotate(${-7 * rtlSign}deg)"></div>`;

  const type = TYPE.headline;

  const supportHtml = copy.support
    ? `<p class="support" id="support" data-fit="${Math.round(W * 0.0255)},${Math.round(
        W * 0.0315,
      )},2,2">${esc(copy.support)}</p>`
    : '';

  const offerHtml = isOffer
    ? `<div class="offer" id="offer">
        ${offer.chip ? `<div class="chip"><span>${esc(offer.chip)}</span></div>` : ''}
        <div class="strip">
          ${offer.rows
            .map((row) => {
              const stat = splitStat(row);
              return `<div class="cell">${
                stat.value ? `<div class="num">${esc(stat.value)}</div>` : ''
              }<div class="lbl">${esc(stat.label)}</div></div>`;
            })
            .join('')}
        </div>
      </div>`
    : '';

  const artHtml =
    frame.layout === 'collage' && spec.artSrc
      ? `<div class="artwrap">
          <div class="art-slab"></div>
          <div class="art"><img src="${spec.artSrc}" alt=""></div>
        </div>`
      : '';

  const css = `
${dev.css}
.head{position:absolute;inset-inline-start:${pad}px;top:${headTop}px;width:${headW}px;z-index:4}
.support{font-size:${Math.round(W * 0.0303)}px;margin-block-start:${Math.round(W * 0.019)}px;
  max-width:${Math.round(headW * 0.9)}px}
.stage{position:absolute;inset-inline-start:0;inset-inline-end:${-bleedEnd}px;top:${Math.round(
    H * 0.32,
  )}px;bottom:${Math.round(H * 0.052) - bleedBottom}px;display:flex;justify-content:${align};
  align-items:flex-end;z-index:2}
.matwrap{position:relative;width:${matW}px;height:${matH}px;flex:0 0 auto;
  transform-origin:bottom center;
  margin-inline-end:${align === 'center' || bleedEnd ? '0' : `${Math.round(W * 0.038)}px`}}
.mat-slab{position:absolute;inset:0;border-radius:${matR}px;background:var(--shadow);
  transform:translate(${slabX * rtlSign}px,${slabY}px)}
.mat{position:absolute;inset:0;background:var(--card);border-radius:${matR}px;
  padding:${matPad}px;display:flex;align-items:center;justify-content:center;
  box-shadow:0 0 0 1px rgba(28,27,23,.06)}
.tape{position:absolute;inset-inline-start:-${Math.round(W * 0.026)}px;top:-${Math.round(
    W * 0.022,
  )}px;width:${Math.round(W * 0.2)}px;height:${Math.round(W * 0.047)}px;
  background:linear-gradient(105deg,rgba(255,253,246,.82),rgba(255,250,238,.6));
  border:1px solid rgba(28,27,23,.045);
  box-shadow:0 ${Math.round(W * 0.0015)}px 0 rgba(28,27,23,.05),
    inset 1px 0 0 rgba(255,255,255,.55);z-index:5}
/*
 * The art card is a taped print: it bleeds off the outer edge and overlaps only
 * the device bezel, never the app's own chrome. Overlapping the tab bar read as
 * a layout accident rather than a collage.
 */
.artwrap{position:absolute;inset-inline-start:${-Math.round(W * 0.012)}px;
  bottom:${Math.round(H * 0.022)}px;width:${Math.round(W * 0.255)}px;z-index:6;
  transform:rotate(${5 * rtlSign}deg);transform-origin:bottom center}
.art-slab{position:absolute;inset:0;background:var(--shadow);border-radius:${Math.round(
    W * 0.009,
  )}px;transform:translate(${slabX * rtlSign}px,${slabY}px)}
.art{position:relative;background:#fff;border-radius:${Math.round(W * 0.009)}px;
  padding:${Math.round(W * 0.011)}px;box-shadow:0 0 0 1px rgba(28,27,23,.08)}
.art img{display:block;width:100%;aspect-ratio:3/4;object-fit:cover;
  border-radius:${Math.round(W * 0.004)}px}
.offer{position:absolute;inset-inline-start:${pad}px;top:${Math.round(
    H * 0.3,
  )}px;width:${headW}px;background:var(--card);border-radius:${Math.round(W * 0.028)}px;
  padding:${Math.round(W * 0.028)}px ${Math.round(W * 0.03)}px ${Math.round(W * 0.026)}px;
  box-shadow:${slabX}px ${slabY}px 0 var(--shadow), 0 0 0 1px rgba(28,27,23,.07);z-index:7}
.chip{display:table;max-width:100%;font-family:var(--body-family);font-weight:700;
  font-size:${Math.round(W * 0.0235)}px;letter-spacing:.02em;color:var(--onBrand);
  background:var(--brand);padding:${Math.round(W * 0.0075)}px ${Math.round(W * 0.017)}px;
  border-radius:999px;box-shadow:0 ${Math.round(W * 0.004)}px 0 var(--brandSlab)}
.chip span{display:block;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.strip{display:flex;align-items:flex-start;margin-block-start:${Math.round(W * 0.026)}px}
.cell{flex:1 1 0;min-width:0;padding-inline:${Math.round(W * 0.014)}px;
  border-inline-start:1px solid var(--edge)}
.cell:first-child{border-inline-start:0;padding-inline-start:0}
.cell:last-child{padding-inline-end:0}
.num{font-family:var(--display);font-weight:700;color:var(--brand);
  font-size:${Math.round(W * 0.058)}px;line-height:1;letter-spacing:-.02em}
.lbl{font-family:var(--body-family);font-weight:600;color:var(--ink);
  font-size:${Math.round(W * 0.0215)}px;line-height:1.26;margin-block-start:${Math.round(
    W * 0.012,
  )}px}`;

  const body = `
<div class="head" id="head">
  <h1 class="headline" id="headline" data-fit="${Math.round(
    isOffer
      ? (frame.headlineMin ?? TYPE.offerHeadline.min)
      : (frame.headlineMin ?? type.min),
  )},${Math.round(
    (isOffer ? TYPE.offerHeadline.max : type.max) * (font.scale ?? 1),
  )},${isOffer ? TYPE.offerHeadline.lines : (frame.headlineLines ?? type.lines)},4,${
    frame.headlinePrefer ?? 2
  }">${esc(copy.headline)}</h1>
  ${isOffer ? '' : supportHtml}
</div>
${offerHtml}
<div class="stage" id="stage">
  <div class="matwrap" id="matwrap">
    <div class="mat-slab"></div>
    <div class="mat">${dev.html}</div>
    ${tape}
  </div>
</div>
${artHtml}`;

  const cfg = {
    stage: {
      top: Math.round(H * 0.32),
      gap: Math.round(H * 0.028),
      headGap: isOffer ? Math.round(H * 0.022) : Math.round(H * 0.028),
      matW,
      matH,
      tilt,
      maxWFrac: isOffer ? 1 : frame.layout === 'collage' ? 0.99 : 0.97,
      maxScale: 1.04,
    },
    offer: isOffer ? { selector: '#offer', gap: Math.round(H * 0.02) } : null,
  };

  return {
    html: pageShell({
      W,
      H,
      dir,
      stock: frame.stock,
      font,
      fontFiles,
      body,
      id: locale,
      extraCss: css,
      cfg,
    }),
    matW,
    matH,
  };
}

/* ------------------------------------------------------------------ header */

/** 21:9 product-page hero. Safe area keeps type clear of the rounded mask. */
export function headerHtml(spec) {
  const { W, H, dir, locale, copy, screenSrc, font, fontFiles } = spec;
  const rtlSign = dir === 'rtl' ? -1 : 1;
  const safeX = Math.round(W * 0.066);
  const textW = Math.round(W * 0.45);
  // The phone is sized from the canvas height and then bleeds off the bottom
  // edge on purpose: a hero with a fully-contained phone reads as a floating
  // sticker, while a bleeding one reads as a window into the product.
  const screenW = Math.round(H * 1.02 / 2.17);
  const dev = deviceMarkup({ device: 69, screenSrc, screenW, rtlSign });
  const matPad = Math.round(H * 0.026);
  const slabX = Math.round(W * 0.0035);
  const slabY = Math.round(W * 0.0052);

  const css = `
${dev.css}
.copy{position:absolute;inset-inline-start:${safeX}px;top:50%;transform:translateY(-47%);
  width:${textW}px}
.mark{width:${Math.round(H * 0.075)}px;height:${Math.round(H * 0.075)}px;margin-block-end:${Math.round(
    H * 0.03,
  )}px}
.name{font-family:var(--body-family);font-weight:700;font-size:${Math.round(W * 0.0092)}px;
  letter-spacing:.18em;text-transform:uppercase;color:var(--ink3);
  margin:0 0 ${Math.round(H * 0.026)}px}
.headline{font-size:${Math.round(TYPE.header.headline.max)}px}
.support{font-size:${Math.round(W * 0.0128)}px;margin-block-start:${Math.round(H * 0.034)}px}
.stage{position:absolute;inset-inline-end:${Math.round(W * 0.052)}px;top:${Math.round(
    H * 0.075,
  )}px;bottom:${-Math.round(H * 0.16)}px;width:${Math.round(W * 0.34)}px;display:flex;
  align-items:flex-start;justify-content:flex-end}
.matwrap{position:relative;transform:rotate(${(-3.2 * rtlSign).toFixed(2)}deg);
  transform-origin:top center}
.mat-slab{position:absolute;inset:0;border-radius:${Math.round(H * 0.05)}px;
  background:var(--shadow);transform:translate(${slabX * rtlSign}px,${slabY}px)}
.mat{position:relative;background:var(--card);border-radius:${Math.round(H * 0.05)}px;
  padding:${matPad}px;box-shadow:0 0 0 1px rgba(28,27,23,.06)}`;

  const body = `
<div class="copy" id="head">
  <img class="mark" src="${fileUrl(BRAND_MARK)}" alt="">
  <p class="name">FitCheck AI</p>
  <h1 class="headline" id="headline" data-fit="${Math.round(
    TYPE.header.headline.min,
  )},${Math.round(TYPE.header.headline.max * (font.scale ?? 1))},3,6">${esc(copy.headline)}</h1>
  ${
    copy.support
      ? `<p class="support" id="support" data-fit="${Math.round(
          TYPE.header.support.min,
        )},${Math.round(TYPE.header.support.max)},3,2">${esc(copy.support)}</p>`
      : ''
  }
</div>
<div class="stage">
  <div class="matwrap">
    <div class="mat-slab"></div>
    <div class="mat">${dev.html}</div>
  </div>
</div>`;

  return {
    html: pageShell({
      W,
      H,
      dir,
      stock: spec.stock ?? 'ink',
      font,
      fontFiles,
      body,
      id: locale,
      extraCss: css,
      cfg: {},
    }),
  };
}

/* ------------------------------------------------------------------ search */

/**
 * 3:2 search card, designed for a quarter-second read at thumbnail size: one
 * short line, the brand, and the product set into the corner as a tilted mat.
 *
 * The screen is inset on all four sides rather than bleeding to the crop. At
 * thumbnail size a bleeding edge is indistinguishable from a badly cropped
 * image, while a visible mat edge with its shadow reads as a designed object.
 */
export function searchHtml(spec) {
  const { W, H, dir, locale, copy, screenSrc, font, fontFiles } = spec;
  const rtlSign = dir === 'rtl' ? -1 : 1;
  const safeX = Math.round(W * 0.056);
  const textW = Math.round(W * 0.5);
  // Size from the stage height, never from the canvas width: a 0.462-aspect
  // screen sized off width is taller than the card and gets clipped by the crop.
  const stageH = Math.round(H * (1 - 0.055 * 2));
  const stageW = Math.round(W * 0.42);
  const matPad = Math.round(W * 0.0105);
  const screenW = Math.min(
    Math.round((stageH - matPad * 2 - W * 0.01) / 1.0495 / 2.1644),
    Math.round(((stageW - matPad * 2) / 1.047) * 0.98),
  );
  const dev = deviceMarkup({ device: 69, screenSrc, screenW, rtlSign });
  const slabX = Math.round(W * 0.004);
  const slabY = Math.round(W * 0.0055);

  const css = `
${dev.css}
.copy{position:absolute;inset-inline-start:${safeX}px;top:50%;transform:translateY(-50%);
  width:${textW}px;z-index:3}
.name{font-family:var(--body-family);font-weight:700;font-size:${Math.round(W * 0.0185)}px;
  letter-spacing:.16em;text-transform:uppercase;color:var(--accent);margin:0 0 ${Math.round(
    H * 0.038,
  )}px}
.headline{font-size:${Math.round(TYPE.search.headline.max)}px;letter-spacing:-.028em}
.support{font-size:${Math.round(W * 0.021)}px;margin-block-start:${Math.round(
    H * 0.036,
  )}px;max-width:${Math.round(textW * 0.92)}px}
.stage{position:absolute;inset-inline-end:${Math.round(W * 0.04)}px;top:${Math.round(
    H * 0.055,
  )}px;bottom:${Math.round(H * 0.055)}px;width:${Math.round(W * 0.42)}px;display:flex;
  align-items:center;justify-content:center;z-index:2}
.matwrap{position:relative;transform:rotate(${(-2.6 * rtlSign).toFixed(2)}deg)}
.mat-slab{position:absolute;inset:0;border-radius:${Math.round(W * 0.018)}px;
  background:var(--shadow);transform:translate(${slabX * rtlSign}px,${slabY}px)}
.mat{position:relative;background:var(--card);border-radius:${Math.round(W * 0.018)}px;
  padding:${matPad}px;box-shadow:0 0 0 1px rgba(28,27,23,.07)}`;

  const body = `
<div class="copy">
  <p class="name">FitCheck AI</p>
  <h1 class="headline" id="headline" data-fit="${Math.round(
    TYPE.search.headline.min,
  )},${Math.round(TYPE.search.headline.max * (font.scale ?? 1))},3,6">${esc(copy.headline)}</h1>
  ${
    copy.support
      ? `<p class="support" id="support" data-fit="${Math.round(
          TYPE.search.support.min,
        )},${Math.round(TYPE.search.support.max)},2,2">${esc(copy.support)}</p>`
      : ''
  }
</div>
<div class="stage">
  <div class="matwrap">
    <div class="mat-slab"></div>
    <div class="mat">${dev.html}</div>
  </div>
</div>`;

  return {
    html: pageShell({
      W,
      H,
      dir,
      stock: spec.stock ?? 'marigold',
      font,
      fontFiles,
      body,
      id: locale,
      extraCss: css,
      cfg: {},
    }),
  };
}

/* ------------------------------------------------------------------ poster */

/** App preview poster: the frame a viewer sees before the video plays. */
export function posterHtml(spec) {
  const { W, H, dir, locale, copy, screenSrc, font, fontFiles } = spec;
  const rtlSign = dir === 'rtl' ? -1 : 1;
  const pad = Math.round(W * 0.075);
  const screenW = Math.round(W * 0.66);
  const dev = deviceMarkup({ device: 69, screenSrc, screenW, rtlSign });
  const matPad = Math.round(W * 0.025);

  const css = `
${dev.css}
.head{position:absolute;inset-inline-start:${pad}px;top:${Math.round(H * 0.055)}px;
  width:${W - pad * 2}px;z-index:4}
.headline{font-size:${Math.round(W * 0.098)}px}
.stage{position:absolute;inset-inline:0;top:${Math.round(H * 0.235)}px;
  bottom:${Math.round(H * 0.062)}px;display:flex;justify-content:center;
  align-items:flex-end;z-index:2}
.matwrap{position:relative;transform:rotate(${-1.2 * rtlSign}deg)}
.mat-slab{position:absolute;inset:0;border-radius:${Math.round(W * 0.06)}px;background:var(--shadow);
  transform:translate(${Math.round(W * 0.012)}px,${Math.round(W * 0.016)}px)}
.mat{position:relative;background:var(--card);padding:${matPad}px;
  border-radius:${Math.round(W * 0.06)}px;box-shadow:0 0 0 1px rgba(28,27,23,.06)}
/*
 * The play affordance sits in the paper margin, never over the product. A centred
 * play button covers exactly the garments the poster exists to show, and the
 * margin is empty by construction because the mat is centred.
 */
.play{position:absolute;inset-inline-start:${Math.round(W * 0.032)}px;
  bottom:${Math.round(H * 0.045)}px;z-index:9;display:flex;align-items:center;
  gap:${Math.round(W * 0.014)}px}
.play i{display:block;width:${Math.round(W * 0.098)}px;height:${Math.round(W * 0.098)}px;
  border-radius:999px;background:var(--card);position:relative;
  box-shadow:0 0 0 1px rgba(28,27,23,.1), ${Math.round(W * 0.006)}px ${Math.round(
    W * 0.009,
  )}px 0 var(--shadow)}
.play i::after{content:'';position:absolute;left:38%;top:50%;transform:translate(0,-50%);
  width:0;height:0;border-block:${Math.round(W * 0.019)}px solid transparent;
  border-inline-start:${Math.round(W * 0.032)}px solid var(--ink)}
.play{--unused:0}`;

  const body = `
<div class="head">
  <h1 class="headline" id="headline" data-fit="${Math.round(W * 0.066)},${Math.round(
    W * 0.1 * (font.scale ?? 1),
  )},3,4">${esc(copy.headline)}</h1>
</div>
<div class="stage">
  <div class="matwrap">
    <div class="mat-slab"></div>
    <div class="mat">${dev.html}</div>
  </div>
</div>
<div class="play"><i></i></div>`;

  return {
    html: pageShell({
      W,
      H,
      dir,
      stock: spec.stock ?? 'ink',
      font,
      fontFiles,
      body,
      id: locale,
      extraCss: css,
      cfg: {},
    }),
  };
}
