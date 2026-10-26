#!/usr/bin/env node
/**
 * fonts.mjs — build the per-script font kit.
 *
 * A screenshot headline is the one element that cannot be covered by a fallback
 * stack: if the face lacks the glyph, Chromium substitutes and the design falls
 * apart (or renders tofu). So each script gets a face that actually contains
 * every character the pipeline will ask it to set.
 *
 * The kit is built by subsetting: we ask Google Fonts' CSS API for exactly the
 * characters in the copy (`text=`), and store the resulting woff2 under
 * `store/creative/fonts/`. Each file is a few tens of KB, so the whole kit is
 * committed and rendering needs no network.
 *
 * Re-run after changing headlines in another script:
 *   node scripts/creative/fonts.mjs
 * `check.mjs` fails when a stored subset is out of date, so a stale kit cannot
 * silently ship.
 *
 * Basteleur (the app's display face, already in the repo) covers Latin and
 * Greek, so those scripts need no download.
 */
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { isAbsolute, join, relative } from 'node:path';
import { BASETELEUR_BOLD, FONTS, FONT_INDEX, INTER, ROOT, fileUrl } from './lib/paths.mjs';
import { SCRIPT_FONTS, allScripts, fontFor } from './lib/scripts.mjs';
import { orderedLocales } from './lib/locales.mjs';
import { copyFor, offerFor, framePlan } from './lib/copy.mjs';

/** Characters the kit must cover: every string any template will set. */
export function charsetForScript(script) {
  const chars = new Set();
  for (const locale of orderedLocales()) {
    if (fontFor(locale.asc).script !== script) continue;
    for (const frame of framePlan()) {
      const copy = copyFor(locale.asc, frame);
      for (const part of [copy.headline, copy.support]) {
        if (!part) continue;
        for (const ch of part) chars.add(ch);
      }
      if (frame.layout === 'offer') {
        const offer = offerFor(locale.asc);
        for (const row of [offer.chip, ...offer.rows]) {
          if (!row) continue;
          for (const ch of row) chars.add(ch);
        }
      }
    }
    // Digits and the punctuation the offer card splits on are always present in
    // the number styling even when no headline uses them.
    for (const ch of '0123456789 .,:;!?/+-—·%') chars.add(ch);
  }
  return [...chars].sort().join('');
}

const UA =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36';

async function fetchFamily(family, weight, text, label) {
  const url =
    'https://fonts.googleapis.com/css2?' +
    `family=${encodeURIComponent(family).replace(/%20/g, '+')}:wght@${weight}` +
    '&display=block&text=' +
    encodeURIComponent(text);
  const res = await fetch(url, { headers: { 'User-Agent': UA } });
  if (!res.ok) throw new Error(`${label}: CSS request failed (${res.status})`);
  const css = await res.text();
  const match = css.match(/src:\s*url\((https:\/\/[^)]+)\)/);
  if (!match) throw new Error(`${label}: no font URL in Google Fonts response`);
  const fontRes = await fetch(match[1]);
  if (!fontRes.ok) throw new Error(`${label}: font download failed (${fontRes.status})`);
  const buf = Buffer.from(await fontRes.arrayBuffer());
  if (buf.length < 500) throw new Error(`${label}: font file suspiciously small (${buf.length} bytes)`);
  return { buf, url: match[1] };
}

async function main() {
  mkdirSync(FONTS, { recursive: true });
  const index = { generated: new Date().toISOString(), scripts: {} };
  let fetched = 0;
  let reused = 0;

  for (const script of allScripts()) {
    const font = SCRIPT_FONTS[script];
    const chars = charsetForScript(script);
    const hash = createHash('sha256').update(`${script}:${chars}`).digest('hex').slice(0, 12);
    const entry = { chars: chars.length, hash, display: null, body: null };

    if (!font.local) {
      const display = await ensure(script, 'display', font.remote, 700, chars, hash);
      entry.display = display;
      if (display.fetched) fetched += 1;
      else reused += 1;
    }
    const bodyFamily = font.bodyFamily;
    if (bodyFamily.startsWith('noto-sans')) {
      const body = await ensure(script, 'body', font.bodyRemote, 500, chars, hash);
      entry.body = body;
      if (body.fetched) fetched += 1;
      else reused += 1;
    } else {
      // Repo-relative, like every other path in the index: an absolute path here
      // commits the builder's home directory into a shared file.
      entry.body = { family: 'Inter', file: relative(ROOT, INTER), local: true };
    }
    index.scripts[script] = entry;
    console.log(
      `  ${script.padEnd(12)} ${String(chars.length).padStart(3)} chars  ` +
        `${font.local ? 'Basteleur (local)' : font.remote}${entry.body && !entry.body.local ? ' + ' + font.bodyRemote : ''}`,
    );
  }

  // Rewrite any absolute paths a previous build committed, so the index is
  // portable across checkouts.
  for (const entry of Object.values(index.scripts)) {
    for (const role of ['display', 'body']) {
      const slot = entry[role];
      if (slot?.file && isAbsolute(slot.file)) slot.file = relative(ROOT, slot.file);
    }
  }

  writeFileSync(FONT_INDEX, `${JSON.stringify(index, null, 2)}\n`);
  console.log(`\nfont kit: ${fetched} fetched, ${reused} reused → ${FONT_INDEX}`);
}

async function ensure(script, role, family, weight, chars, hash) {
  const file = join(FONTS, `${script}-${role}.woff2`);
  const rel = relative(ROOT, file);
  if (existsSync(file) && existsSync(FONT_INDEX)) {
    try {
      const previous = JSON.parse(readFileSync(FONT_INDEX, 'utf8')).scripts?.[script];
      if (previous?.hash === hash) {
        return { family, file: rel, weight, local: false, fetched: false };
      }
    } catch {
      // fall through and rebuild
    }
  }
  const { buf } = await fetchFamily(family, weight, chars, `${script}/${role}`);
  writeFileSync(file, buf);
  return { family, file: rel, weight, local: false, fetched: true, bytes: buf.length };
}

/** Font files one render needs. Missing files are a hard error, not a fallback. */
export function fontFilesFor(asc) {
  const font = fontFor(asc);
  const index = existsSync(FONT_INDEX) ? JSON.parse(readFileSync(FONT_INDEX, 'utf8')) : null;
  if (!index) {
    throw new Error(
      'store/creative/fonts/index.json is missing — run `node scripts/creative/fonts.mjs` once.',
    );
  }
  const entry = index.scripts[font.script];
  if (!entry) throw new Error(`font kit has no entry for script "${font.script}"`);

  const absolute = (rel) => (rel ? join(ROOT, rel) : null);
  const displayPath = font.local
    ? BASETELEUR_BOLD
    : entry.display
      ? absolute(entry.display.file)
      : null;
  if (!displayPath || !existsSync(displayPath)) {
    throw new Error(`font kit is missing ${font.script}-display.woff2 — run fonts.mjs`);
  }
  const bodyPath = entry.body?.local ? INTER : absolute(entry.body?.file);
  if (!bodyPath || !existsSync(bodyPath)) {
    throw new Error(`font kit is missing ${font.script}-body.woff2 — run fonts.mjs`);
  }
  return {
    display: fileUrl(displayPath),
    body: fileUrl(bodyPath),
    displayPath,
    bodyPath,
  };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error(`\n✗ fonts: ${error.message}`);
    process.exit(1);
  });
}
