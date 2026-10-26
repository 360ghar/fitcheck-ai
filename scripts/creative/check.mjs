#!/usr/bin/env node
/**
 * check.mjs — validate every asset the pipeline produced.
 *
 * Runs offline against `store/creative/manifest.json`: no App Store Connect
 * token, no Chromium. Each check below is a real upload failure or a real
 * quality failure that shipped in the past, not a stylistic preference.
 *
 *   node scripts/creative/check.mjs
 *   node scripts/creative/check.mjs --strict     # warnings become errors
 *   node scripts/creative/check.mjs --locale ja  # one locale, still full checks
 *
 * Checks per entry:
 *   1. the file exists and its bytes hash to the manifest sha256
 *   2. the pixel size is one Apple accepts for the entry's display type
 *   3. no alpha channel (App Store Connect rejects transparency)
 *   4. the file is under Apple's 500 MB cap
 *   5. the image is not blank: sampled pixels show real contrast
 *   6. the localized headline is non-empty and its script has no tofu
 *   7. the headline fitted its line budget when it was rendered
 *
 * Exits non-zero on any failure so CI and a human get the same answer.
 */
import { createHash } from 'node:crypto';
import { existsSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { PNG } from 'pngjs';

import { MANIFEST, ROOT, FONT_INDEX, FONTS } from './lib/paths.mjs';
import { DEVICES, MAX_IMAGE_BYTES, SURFACES } from './lib/design.mjs';
import { fontFor } from './lib/scripts.mjs';
import { orderedLocales } from './lib/locales.mjs';
import { framePlan } from './lib/copy.mjs';

const argv = process.argv.slice(2);
const STRICT = argv.includes('--strict');
const localeFlag = argv.indexOf('--locale');
const LOCALE = localeFlag === -1 ? null : (argv[localeFlag + 1] ?? null);

const errors = [];
const warnings = [];
const fail = (message) => errors.push(message);
const warn = (message) => (STRICT ? errors : warnings).push(message);

if (!existsSync(MANIFEST)) {
  console.error('✗ store/creative/manifest.json is missing — run render.mjs first.');
  process.exit(1);
}

const manifest = JSON.parse(readFileSync(MANIFEST, 'utf8'));
const entries = manifest.entries.filter((entry) => !LOCALE || entry.locale === LOCALE);

/** Every (display type, size) pair Apple accepts, from the design table. */
const ACCEPTED = new Map();
for (const device of Object.values(DEVICES)) {
  ACCEPTED.set(device.display, [...(ACCEPTED.get(device.display) ?? []), ...device.accepted]);
}
for (const surface of Object.values(SURFACES)) {
  ACCEPTED.set(surface.display, [...(ACCEPTED.get(surface.display) ?? []), surface.size]);
}

/** Mirror what the font kit was built to cover. */
const index = existsSync(FONT_INDEX) ? JSON.parse(readFileSync(FONT_INDEX, 'utf8')) : null;

function accentCoverage(script) {
  const entry = index?.scripts?.[script];
  return entry?.chars ?? 0;
}

const results = { checked: 0, bytes: 0, rendered: 0 };

for (const entry of entries) {
  const label =
    entry.kind === 'screenshot'
      ? `${entry.locale} ${entry.device} frame ${entry.frame}`
      : `${entry.locale} ${entry.kind}`;
  const path = join(ROOT, entry.path);

  // 1. Exists and matches the manifest hash.
  if (!existsSync(path)) {
    fail(`${label}: missing file ${entry.path}`);
    continue;
  }
  const bytes = readFileSync(path);
  const digest = createHash('sha256').update(bytes).digest('hex');
  if (digest !== entry.sha256) {
    fail(`${label}: sha256 mismatch — file changed after the manifest was written`);
  }
  if (statSync(path).size !== entry.bytes) {
    fail(`${label}: manifest says ${entry.bytes} bytes, file is ${statSync(path).size}`);
  }

  // 2. An accepted size for the display type.
  const accepted = ACCEPTED.get(entry.displayType);
  if (!accepted) {
    fail(`${label}: unknown display type ${entry.displayType}`);
  } else if (!accepted.some(([w, h]) => w === entry.width && h === entry.height)) {
    fail(
      `${label}: ${entry.width}x${entry.height} is not accepted for ${entry.displayType} ` +
        `(accepted: ${accepted.map(([w, h]) => `${w}x${h}`).join(', ')})`,
    );
  }

  // 3 and 4. No alpha, under the cap.
  if (bytes.length >= MAX_IMAGE_BYTES) {
    fail(`${label}: ${bytes.length} bytes is at or over Apple's ${MAX_IMAGE_BYTES}-byte cap`);
  }

  const png = PNG.sync.read(bytes);
  if (entry.width !== png.width || entry.height !== png.height) {
    fail(`${label}: manifest says ${entry.width}x${entry.height}, PNG is ${png.width}x${png.height}`);
  }
  const alpha = png.alpha === true || png.colorType === 6 || png.colorType === 4;
  if (alpha) {
    fail(`${label}: PNG has an alpha channel (colorType ${png.colorType}); upload is rejected`);
  }

  // 5. Not blank, and not a single flat colour: sample a grid and require spread.
  const samples = [];
  const stepX = Math.max(1, Math.floor(png.width / 40));
  const stepY = Math.max(1, Math.floor(png.height / 60));
  for (let y = 0; y < png.height; y += stepY) {
    for (let x = 0; x < png.width; x += stepX) {
      const i = (png.width * y + x) << 2;
      samples.push([png.data[i], png.data[i + 1], png.data[i + 2]]);
    }
  }
  const lum = samples.map(([r, g, b]) => 0.2126 * r + 0.7152 * g + 0.0722 * b);
  const min = Math.min(...lum);
  const max = Math.max(...lum);
  if (max - min < 40) {
    fail(`${label}: image looks blank (luminance range ${Math.round(max - min)} < 40)`);
  }
  const transparent = samples.filter((_, i) => lum[i] === 0 && max - min < 5).length;
  if (transparent === samples.length) fail(`${label}: every sampled pixel is black`);

  // 6. Localized headline is present, in a script the font kit covers.
  if (!entry.copy?.headline || entry.copy.headline.trim().length === 0) {
    fail(`${label}: headline is empty`);
  }
  const script = fontFor(entry.locale).script;
  if (entry.type?.script !== script) {
    warn(`${label}: manifest records script ${entry.type?.script}, ledger says ${script}`);
  }
  if (accentCoverage(script) === 0) {
    fail(`${label}: font kit has no coverage recorded for script "${script}" — run fonts.mjs`);
  }
  const tofu = /[\uFFFD\u25A1\u25AA]/.test(entry.copy?.headline ?? '');
  if (tofu) fail(`${label}: headline contains a replacement or box glyph`);
  if (entry.copy?.support) {
    if (/[\uFFFD\u25A1\u25AA]/.test(entry.copy.support)) {
      fail(`${label}: supporting line contains a replacement or box glyph`);
    }
  }

  // 7. Type fitted its budget when rendered.
  if (entry.type?.headlineFits === false) {
    fail(
      `${label}: headline needed ${entry.type.headlineLines} lines at the legibility floor ` +
        `(${entry.type.headlineSize}px). Shorten it in store/creative/copy.json.`,
    );
  }
  if (entry.type?.headlineSize && entry.type.headlineSize < 60) {
    warn(`${label}: headline set at ${entry.type.headlineSize}px — small for a store card`);
  }
  if (entry.copy?.untranslated) {
    const why = String(entry.copy.source).includes('section-missing')
      ? 'the listing never wrote this section for this locale'
      : 'the listing line is still English';
    warn(`${label}: copy falls back to the subtitle because ${why} (source ${entry.copy.source})`);
  }
  if (entry.copy?.reviewed === false && entry.copy?.source?.startsWith('override')) {
    warn(`${label}: authored fallback copy has not had a native review`);
  }
  if (entry.copy?.source === 'override-fallback') {
    warn(`${label}: listing headline overflowed; rendered the authored fallback from store/creative/copy.json`);
  }

  results.checked += 1;
  results.bytes += entry.bytes;
  results.rendered += 1;
}

/* ------------------------------------------------------------------ coverage */

const allLocales = orderedLocales().map((locale) => locale.asc);
const frames = framePlan().map((frame) => frame.index);
const present = new Set(entries.map((entry) => entry.locale));
const missingLocales = allLocales.filter((asc) => !present.has(asc));

const byDevice = {};
for (const device of Object.values(DEVICES)) {
  for (const asc of allLocales) {
    const have = entries.filter(
      (entry) =>
        entry.locale === asc &&
        entry.kind === 'screenshot' &&
        entry.displayType === device.display,
    );
    const haveFrames = new Set(have.map((entry) => entry.frame));
    const missing = frames.filter((frame) => !haveFrames.has(frame));
    if (missing.length === 0) continue;
    byDevice[device.display] = byDevice[device.display] ?? [];
    byDevice[device.display].push(`${asc}(frames ${missing.join(',')})`);
  }
}
for (const [display, missing] of Object.entries(byDevice)) {
  const note = `${display}: ${missing.length} locale(s) incomplete — ${missing.slice(0, 3).join(' ')}${missing.length > 3 ? ' …' : ''}`;
  // An intentionally partial run (--locale) is not a coverage failure.
  if (LOCALE || missing.length !== allLocales.length) warn(note);
}

// The device screen is a bitmap capture of the app. Frame copy is localized but
// the capture is not, so a non-English frame currently shows an English tab bar
// under translated marketing copy — the largest honest gap in the set. A
// locale-specific capture at source/screens/<locale>/<name>.png clears this.
// Older manifests predate the `screen` field, so a missing locale directory is
// treated as "every frame fell back".
const screenDir = join(ROOT, 'store/creative/source/screens');
const onFallback = entries.filter((entry) => {
  if (entry.kind !== 'screenshot' || entry.locale.startsWith('en')) return false;
  if (entry.screen) return !entry.screen.includes(`/screens/${entry.locale}/`);
  return !existsSync(join(screenDir, entry.locale));
});
if (onFallback.length > 0) {
  const locales = [...new Set(onFallback.map((entry) => entry.locale))];
  warn(
    `${onFallback.length} screenshot(s) across ${locales.length} non-English locale(s) embed the shared English app capture — `
    + `the frame headline is translated, the app UI inside the phone is not. Capture to `
    + `source/screens/<locale>/ to clear this (${locales.slice(0, 4).join(' ')}${locales.length > 4 ? ' …' : ''})`,
  );
}

/* ---------------------------------------------------------------------- fonts */

if (!index) {
  fail('store/creative/fonts/index.json is missing — run `node scripts/creative/fonts.mjs`');
} else {
  for (const locale of orderedLocales()) {
    const font = fontFor(locale.asc);
    const kit = index.scripts[font.script];
    if (!kit) {
      fail(`font kit has no entry for script "${font.script}" (${locale.asc})`);
      continue;
    }
    for (const role of ['display', 'body']) {
      const file = kit[role];
      if (!file || file.local) continue;
      if (!existsSync(join(ROOT, file.file))) {
        fail(`font kit is missing ${file.file} — run fonts.mjs`);
      }
    }
  }
}

/* --------------------------------------------------------------------- report */

console.log(
  `checked ${results.checked} file(s), ${(results.bytes / 1024 / 1024).toFixed(1)} MiB` +
    `${LOCALE ? ` for ${LOCALE}` : ` across ${present.size}/${allLocales.length} locale(s)`}`,
);
if (warnings.length > 0) {
  console.log(`\n${warnings.length} warning(s):`);
  for (const message of warnings.slice(0, 40)) console.log(`  ! ${message}`);
  if (warnings.length > 40) console.log(`  ! … and ${warnings.length - 40} more`);
}
if (errors.length > 0) {
  console.error(`\n✗ ${errors.length} error(s):`);
  for (const message of errors.slice(0, 60)) console.error(`  ${message}`);
  if (errors.length > 60) console.error(`  … and ${errors.length - 60} more`);
  process.exit(1);
}
console.log('\n✓ every manifest entry is present, hashed, correctly sized, opaque and non-blank');
if (missingLocales.length > 0) {
  console.log(`  not yet rendered: ${missingLocales.length} locale(s)`);
}
console.log(`  fonts: ${Object.keys(index?.scripts ?? {}).length} script kit(s) in ${FONTS}`);
