#!/usr/bin/env node
/**
 * render.mjs — render localized App Store creative.
 *
 *   node scripts/creative/render.mjs --locale en-US --device 69   # a subset
 *   node scripts/creative/render.mjs --all                        # everything
 *   node scripts/creative/render.mjs --frame 6 --all               # one frame, all locales
 *   node scripts/creative/render.mjs --all --kind header,search
 *
 * Deterministic: the same inputs produce byte-identical PNGs, and a re-run with
 * unchanged inputs renders nothing. Each finished frame is recorded in
 * `store/creative/.cache/render.json` as soon as it lands, so a run that dies
 * half way never redoes completed work and never leaves the manifest claiming a
 * file it did not write.
 *
 * Output: store/creative/{frames/<locale>/<device>/<n>.png, header, search,
 * preview} plus manifest.json — generated here, never hand-edited.
 */
import { createHash } from 'node:crypto';
import {
  existsSync,
  mkdirSync,
  readFileSync,
  renameSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import { dirname, join, relative } from 'node:path';
import { chromium } from 'playwright';
import { PNG } from 'pngjs';

import {
  CACHE,
  FRAMES,
  HEADER,
  MANIFEST,
  OUT,
  PREVIEW,
  ROOT,
  SCREENS,
  SEARCH,
  ART,
} from './lib/paths.mjs';
import { DEVICES, SURFACES } from './lib/design.mjs';
import { copyFor, hasOverride, listingFor, offerFor, framePlan } from './lib/copy.mjs';
import { localeOrThrow, normaliseLocale, orderedLocales } from './lib/locales.mjs';
import { fontFor } from './lib/scripts.mjs';
import { fontFilesFor } from './fonts.mjs';
import { frameHtml, headerHtml, searchHtml, posterHtml } from './lib/html.mjs';

const argv = process.argv.slice(2);
const has = (flag) => argv.includes(flag);
const valueOf = (flag) => {
  const index = argv.indexOf(flag);
  return index === -1 ? null : (argv[index + 1] ?? null);
};

const ALL = has('--all');
const FORCE = has('--force');
const DRY_RUN = has('--dry-run');
const VERBOSE = has('--verbose');
const CONCURRENCY = Math.max(1, Number(valueOf('--concurrency') ?? 4));
const LOCALE_ARG = valueOf('--locale');
const DEVICE_ARG = valueOf('--device');
const FRAME_ARG = valueOf('--frame');
const KIND_ARG = valueOf('--kind');

const CACHE_FILE = join(CACHE, 'render.json');
const HTML_DIR = join(CACHE, 'html');

const log = (message) => console.log(message);

/* ---------------------------------------------------------------- selection */

function selectedLocales() {
  if (ALL && !LOCALE_ARG) return orderedLocales();
  if (!LOCALE_ARG) {
    console.error(
      'Nothing selected. Pass --locale <code[,code]> or --all.\n' +
        '  node scripts/creative/render.mjs --locale en-US --device 69\n' +
        '  node scripts/creative/render.mjs --all',
    );
    process.exit(2);
  }
  const wanted = LOCALE_ARG.split(',')
    .map((code) => code.trim())
    .filter(Boolean);
  return wanted.map((code) => {
    const normalised = normaliseLocale(code) ?? code;
    return localeOrThrow(normalised);
  });
}

function selectedDevices() {
  const keys = (DEVICE_ARG ?? (ALL ? '69,65' : '69'))
    .split(',')
    .map((key) => key.trim())
    .filter(Boolean);
  return keys.map((key) => {
    const device = DEVICES[key];
    if (!device) {
      console.error(`Unknown --device "${key}". Known: ${Object.keys(DEVICES).join(', ')}`);
      process.exit(2);
    }
    return device;
  });
}

function selectedFrames() {
  const plan = framePlan();
  if (!FRAME_ARG) return plan;
  const wanted = FRAME_ARG.split(',')
    .map((value) => Number(value.trim()))
    .filter((value) => Number.isFinite(value));
  const frames = plan.filter((frame) => wanted.includes(frame.index));
  if (frames.length !== wanted.length) {
    console.error(
      `Unknown --frame value. Known frames: ${plan.map((f) => f.index).join(', ')}`,
    );
    process.exit(2);
  }
  return frames;
}

function selectedKinds() {
  const raw = KIND_ARG ?? (ALL ? 'frames,header,search,poster' : 'frames');
  const known = ['frames', 'header', 'search', 'poster'];
  const wanted = raw.split(',').map((kind) => kind.trim());
  for (const kind of wanted) {
    if (!known.includes(kind)) {
      console.error(`Unknown --kind "${kind}". Known: ${known.join(', ')}`);
      process.exit(2);
    }
  }
  return new Set(wanted);
}

/* ---------------------------------------------------------------- utilities */

const sha256 = (buffer) => createHash('sha256').update(buffer).digest('hex');
const fileHash = (path) => (existsSync(path) ? sha256(readFileSync(path)) : 'missing');
const rel = (path) => relative(ROOT, path);

function screenPath(name, locale) {
  // A locale-specific capture wins, so an Arabic frame can show the Arabic app.
  // Falling back to the shared English capture keeps the pipeline usable while a
  // capture run is incomplete: a missing locale must degrade to the old frame,
  // not break the build. `check.mjs` warns for every frame still on the fallback,
  // because shipping one means an English UI under localized marketing copy.
  const localized = locale ? join(SCREENS, locale, `${name}.png`) : null;
  const path = localized && existsSync(localized) ? localized : join(SCREENS, `${name}.png`);
  if (!existsSync(path)) {
    throw new Error(`missing source screen ${rel(path)} — see docs/store/creative.md`);
  }
  return path;
}

function artPath(name) {
  const path = join(ART, `${name}.png`);
  if (!existsSync(path)) throw new Error(`missing art card ${rel(path)}`);
  return path;
}

const fileUrlFor = (path) =>
  `file://${path.split('/').map((part) => encodeURIComponent(part)).join('/')}`;

function loadCache() {
  try {
    return JSON.parse(readFileSync(CACHE_FILE, 'utf8'));
  } catch {
    return {};
  }
}

let cache = loadCache();
let cacheDirty = false;
function saveCache() {
  if (!cacheDirty) return;
  mkdirSync(CACHE, { recursive: true });
  const tmp = `${CACHE_FILE}.tmp`;
  writeFileSync(tmp, JSON.stringify(cache, null, 1));
  renameSync(tmp, CACHE_FILE);
  cacheDirty = false;
}

/* ----------------------------------------------------------------- rendering */

/**
 * Tasks are plain data so the pool does not need to know what it renders.
 *
 * Screenshots are per device family; the header, the search card and the poster
 * are not. They are built once per locale, outside the device loop, because
 * their pixel size comes from `SURFACES` and iterating them per device produced
 * two manifest entries pointing at one file — which inflated the file count and
 * the byte total by 20%.
 */
function buildTasks(locales, devices, frames, kinds) {
  const tasks = [];
  for (const locale of locales) {
    for (const device of devices) {
      if (kinds.has('frames')) {
        for (const frame of frames) tasks.push({ kind: 'frame', locale, device, frame });
      }
    }
    if (kinds.has('header')) tasks.push({ kind: 'header', locale, device: null });
    if (kinds.has('search')) tasks.push({ kind: 'search', locale, device: null });
    if (kinds.has('poster')) tasks.push({ kind: 'poster', locale, device: null });
  }
  return tasks;
}

function outputPathFor(task) {
  if (task.kind === 'frame') {
    return join(FRAMES, task.locale.asc, task.device.dir, `${task.frame.index}.png`);
  }
  if (task.kind === 'header') return join(HEADER, `${task.locale.asc}.png`);
  if (task.kind === 'search') return join(SEARCH, `${task.locale.asc}.png`);
  return join(PREVIEW, `${task.locale.asc}-poster.png`);
}

function keyFor(task) {
  if (task.kind === 'frame') return `frames/${task.locale.asc}/${task.device.dir}/${task.frame.index}`;
  return `${task.kind}s/${task.locale.asc}`;
}

/**
 * Copy for the non-screenshot surfaces.
 *
 * The 21:9 hero and the 3:2 search card carry the store subtitle — 30
 * characters already translated, already reviewed, and the line ASO indexes.
 * The poster repeats frame 1 so the preview starts where the screenshot set
 * starts, and inherits frame 1's copy path (including its authored fallback).
 */
function surfaceCopy(asc, kind, variant = 'listing') {
  const subtitle = listingFor(asc).subtitle;
  if (kind === 'search') {
    return {
      headline: subtitle,
      support: null,
      source: 'subtitle',
      supportSource: null,
      reviewed: true,
      untranslated: false,
    };
  }
  if (kind === 'header') {
    const base = copyFor(asc, framePlan()[0], { variant });
    return { ...base, support: subtitle, supportSource: 'subtitle', reviewed: true };
  }
  const base = copyFor(asc, framePlan()[0], { variant });
  return { ...base, support: subtitle, supportSource: 'subtitle' };
}

/**
 * Everything one task needs, as immutable data.
 *
 * `variant` selects the copy path for a frame: `'listing'` (the store's own
 * translated header, preferred) or `'override'` (an authored fallback, used only
 * when the listing line cannot be set inside the line budget).
 */
function specFor(task, variant = 'listing') {
  const locale = task.locale;
  const font = fontFor(locale.asc);
  const fonts = fontFilesFor(locale.asc);
  const dir = locale.rtl ? 'rtl' : 'ltr';

  if (task.kind === 'header' || task.kind === 'search' || task.kind === 'poster') {
    const surface = SURFACES[task.kind];
    const [W, H] = surface.size;
    const frame = framePlan()[0];
    const copy = surfaceCopy(locale.asc, task.kind, variant);
    const screen = screenPath(frame.screen, locale.asc);
    const common = {
      W,
      H,
      dir,
      locale: locale.asc,
      copy,
      screenSrc: fileUrlFor(screen),
      font,
      fontFiles: fonts,
      stock: task.kind === 'search' ? 'marigold' : 'ink',
    };
    const built =
      task.kind === 'header'
        ? headerHtml(common)
        : task.kind === 'search'
          ? searchHtml(common)
          : posterHtml(common);
    return { ...built, W, H, display: surface.display, kind: surface.kind, inputs: [screen, fonts.displayPath, fonts.bodyPath], copy };
  }

  const frame = task.frame;
  const copy = copyFor(locale.asc, frame, { variant });
  const offer = offerFor(locale.asc);
  const screen = screenPath(frame.screen, locale.asc);
  const inputs = [screen, fonts.displayPath, fonts.bodyPath];
  if (frame.art) inputs.push(artPath(frame.art));
  const [W, H] = task.device.size;
  const { html } = frameHtml({
    W,
    H,
    dir,
    locale: locale.asc,
    frame,
    copy,
    offer,
    device: task.device.key,
    screenSrc: fileUrlFor(screen),
    artSrc: frame.art ? fileUrlFor(artPath(frame.art)) : null,
    font,
    fontFiles: fonts,
  });
  return {
    html,
    W,
    H,
    display: task.device.display,
    kind: 'screenshot',
    inputs,
    copy,
    frame,
    offer,
  };
}

/** Content hash for a built spec: everything that changes the pixels. */
function inputHashFor(task, spec) {
  return sha256(
    [task.kind, task.locale.asc, task.device?.key ?? '', task.frame?.index ?? '', spec.html, ...spec.inputs.map(fileHash)].join('\u0000'),
  );
}

/**
 * Render one frame at one copy variant, or report that the cache already has it.
 *
 * Returns `{ status, key }` where status is `cached`, `would-render` or
 * `rendered`. The frame's own fit metrics ride along on `cache[key].type` so the
 * caller can decide whether the preferred copy actually worked.
 * `extra` merges onto the cache entry (used to record the fallback provenance).
 */
async function renderVariant(page, task, variant, extra = {}) {
  const spec = specFor(task, variant);
  const outPath = outputPathFor(task);
  const inputHash = inputHashFor(task, spec);
  const key = keyFor(task);
  const cached = cache[key];

  if (!FORCE && cached && cached.inputHash === inputHash && existsSync(join(ROOT, cached.path))) {
    const onDisk = sha256(readFileSync(join(ROOT, cached.path)));
    if (onDisk === cached.sha256) return { status: 'cached', key };
  }

  if (DRY_RUN) return { status: 'would-render', key };

  mkdirSync(dirname(outPath), { recursive: true });
  mkdirSync(HTML_DIR, { recursive: true });
  const htmlPath = join(HTML_DIR, `${key.replace(/[^a-z0-9]+/gi, '-')}.html`);
  writeFileSync(htmlPath, spec.html);

  await page.setViewportSize({ width: spec.W, height: spec.H });
  await page.goto(fileUrlFor(htmlPath), { waitUntil: 'load' });
  const metrics = await page.evaluate(async () => {
    await document.fonts.ready;
    await Promise.all(
      [...document.images].map((img) =>
        img.complete ? Promise.resolve() : new Promise((resolve) => {
          img.onload = resolve;
          img.onerror = resolve;
        }),
      ),
    );
    return window.__compose();
  });

  // Flatten: Chromium writes RGBA, App Store Connect rejects alpha.
  const raw = await page.screenshot({ type: 'png' });
  const png = PNG.sync.read(raw);
  const flat = PNG.sync.write(png, { colorType: 2 });
  writeFileSync(outPath, flat);

  const entry = {
    locale: task.locale.asc,
    kind: spec.kind,
    frame: task.frame?.index ?? null,
    frameId: task.frame?.id ?? null,
    displayType: spec.display,
    // Surfaces are device-independent (their size comes from SURFACES), so they
    // carry no device and are built once per locale rather than once per family.
    device: task.device ? (task.device.key === '65' ? 'iphone-65' : task.device.dir) : null,
    path: rel(outPath),
    width: spec.W,
    height: spec.H,
    bytes: flat.length,
    sha256: sha256(flat),
    rtl: Boolean(task.locale.rtl),
    // Which app capture is inside the device bezel. Recorded so a review can
    // tell a genuinely localized product shot from one still on the shared
    // English capture without opening the PNG.
    screen: rel(spec.inputs[0]),
    copy: {
      headline: spec.copy.headline,
      support: spec.copy.support ?? null,
      source: spec.copy.source,
      supportSource: spec.copy.supportSource ?? null,
      reviewed: spec.copy.reviewed ?? false,
      untranslated: spec.copy.untranslated ?? false,
      offer: task.frame?.layout === 'offer' ? { chip: spec.offer.chip, rows: spec.offer.rows } : null,
    },
    type: {
      script: fontFor(task.locale.asc).script,
      display: fontFor(task.locale.asc).displayLabel,
      headlineSize: metrics.headline?.size ?? null,
      headlineLines: metrics.headline?.lines ?? null,
      headlineFits: metrics.headline?.fits ?? null,
      supportSize: metrics.support?.size ?? null,
      supportLines: metrics.support?.lines ?? null,
      supportFits: metrics.support?.fits ?? null,
    },
    source: { screen: rel(spec.inputs[0]) },
  };

  cache[key] = { inputHash, ...entry, ...extra, renderedAt: new Date().toISOString() };
  cacheDirty = true;
  return { status: 'rendered', key };
}

/**
 * Render a task, preferring the store's translated copy.
 *
 * When a headline cannot be set inside its line budget, and `copy.json` carries
 * an authored line for that locale and frame, the task is re-rendered with the
 * authored line and the swap is recorded on the entry
 * (`copy.source: 'override-fallback'`, plus the rejected listing hash). The
 * listing hash lets the next run skip a probe it already knows the answer to,
 * while any edit to `store/asc/listings.json` invalidates it and re-probes — so
 * a listing translated by another workstream is adopted automatically instead of
 * being shadowed by a stale override.
 *
 * This applies to the poster and header too: both take their headline from frame
 * 1, so a frame 1 that overflows takes its poster down with it. The search card
 * pins its headline to the store subtitle and never needs the retry.
 */
async function renderOne(page, task) {
  const key = keyFor(task);
  const frame = task.frame ?? framePlan()[0];
  const prior = cache[key];
  const priorOnDisk =
    prior && existsSync(join(ROOT, prior.path)) && sha256(readFileSync(join(ROOT, prior.path))) === prior.sha256;

  if (!FORCE && priorOnDisk && prior.copy?.source === 'override-fallback') {
    const listingHash = inputHashFor(task, specFor(task, 'listing'));
    if (prior.listingHash === listingHash) return { status: 'cached', key, fallback: true };
  }

  const first = await renderVariant(page, task, 'listing');
  if (first.status !== 'rendered') return first;
  const afterFirst = cache[first.key];
  if (afterFirst.type?.headlineFits !== false) return first;

  const label = task.kind === 'frame' ? `frame ${frame.index}` : task.kind;
  if (!hasOverride(task.locale.asc, frame)) {
    log(`  ! ${task.locale.asc} ${label}: headline overflows with no authored fallback`);
    return { ...first, overflow: true };
  }
  return renderVariant(page, task, 'override', { listingHash: afterFirst.inputHash });
}

async function runPool(tasks) {
  const browser = await chromium.launch();
  const pages = [];
  for (let i = 0; i < Math.min(CONCURRENCY, tasks.length); i += 1) {
    const context = await browser.newContext({ deviceScaleFactor: 1 });
    pages.push(await context.newPage());
  }

  let next = 0;
  let done = 0;
  let rendered = 0;
  let cached = 0;
  const failures = [];
  const started = Date.now();
  const total = tasks.length;

  const report = (task, result) => {
    done += 1;
    if (result.status === 'rendered') rendered += 1;
    if (result.status === 'cached') cached += 1;
    if (VERBOSE || done === total || done % 10 === 0) {
      const label =
        task.kind === 'frame'
          ? `${task.locale.asc} ${task.device.dir} frame ${task.frame.index}`
          : `${task.locale.asc} ${task.kind}`;
      const elapsed = ((Date.now() - started) / 1000).toFixed(0);
      log(`  [${String(done).padStart(String(total).length)}/${total}] ${label.padEnd(34)} ${result.status}  ${elapsed}s`);
    }
  };

  await Promise.all(
    pages.map(async (page) => {
      for (;;) {
        const index = next;
        next += 1;
        if (index >= tasks.length) return;
        const task = tasks[index];
        try {
          const result = await renderOne(page, task);
          saveCache();
          report(task, result);
        } catch (error) {
          failures.push({ task, error });
          done += 1;
          const label =
            task.kind === 'frame'
              ? `${task.locale.asc} ${task.device.dir} frame ${task.frame.index}`
              : `${task.locale.asc} ${task.kind}`;
          console.error(`  ✗ ${label}: ${error.message}`);
        }
      }
    }),
  );

  await browser.close();
  return { rendered, cached, failures, seconds: (Date.now() - started) / 1000 };
}

/* ------------------------------------------------------------------ manifest */

function writeManifest() {
  const entries = Object.values(cache)
    .filter((entry) => entry.path && entry.sha256 && existsSync(join(ROOT, entry.path)))
    .map((entry) => {
      const { inputHash, renderedAt, ...rest } = entry;
      return rest;
    });

  const order = new Map(orderedLocales().map((locale, index) => [locale.asc, index]));
  entries.sort((a, b) => {
    const localeDelta = (order.get(a.locale) ?? 999) - (order.get(b.locale) ?? 999);
    if (localeDelta !== 0) return localeDelta;
    if (a.device !== b.device) return String(a.device).localeCompare(String(b.device));
    const kindOrder = { screenshot: 0, header: 1, search: 2, poster: 3 };
    if (a.kind !== b.kind) return (kindOrder[a.kind] ?? 9) - (kindOrder[b.kind] ?? 9);
    return (a.frame ?? 0) - (b.frame ?? 0);
  });

  const byLocale = {};
  for (const entry of entries) {
    byLocale[entry.locale] = (byLocale[entry.locale] ?? 0) + 1;
  }
  const manifest = {
    _comment:
      'Generated by scripts/creative/render.mjs. Do not edit by hand. Every entry is enough for an uploader to place the file without knowing how it was made: locale, asset kind, App Store Connect display type, path, pixel size, bytes and content hash. `copy` records the localized text baked into the image so a review can read it without opening the PNG.',
    appId: '6794689012',
    generated: new Date().toISOString(),
    totals: {
      files: entries.length,
      bytes: entries.reduce((sum, entry) => sum + entry.bytes, 0),
      locales: Object.keys(byLocale).length,
    },
    coverage: byLocale,
    display: Object.fromEntries(
      Object.values(DEVICES).map((device) => [
        device.display,
        {
          device: device.dir,
          size: device.size,
          accepted: device.accepted,
          label: device.label,
        },
      ]),
    ),
    surfaces: Object.fromEntries(
      Object.entries(SURFACES).map(([name, surface]) => [
        name,
        { displayType: surface.display, size: surface.size, note: surface.note },
      ]),
    ),
    entries,
  };

  mkdirSync(OUT, { recursive: true });
  const tmp = `${MANIFEST}.tmp`;
  writeFileSync(tmp, `${JSON.stringify(manifest, null, 1)}\n`);
  renameSync(tmp, MANIFEST);
  return manifest;
}

/* ---------------------------------------------------------------------- main */

async function main() {
  const locales = selectedLocales();
  const devices = selectedDevices();
  const frames = selectedFrames();
  const kinds = selectedKinds();
  const tasks = buildTasks(locales, devices, frames, kinds);

  if (tasks.length === 0) {
    console.error('No work to do.');
    process.exit(2);
  }

  log(
    `FitCheck AI creative — ${tasks.length} task(s): ${locales.length} locale(s) × ` +
      `${devices.map((d) => d.display).join('+')} × [${[...kinds].join(', ')}]` +
      `${kinds.has('frames') ? ` × frames ${frames.map((f) => f.index).join(',')}` : ''}`,
  );
  log(`  concurrency ${CONCURRENCY}${FORCE ? ', forced' : ''}${DRY_RUN ? ', dry run' : ''}`);

  const result = await runPool(tasks);
  saveCache();

  if (DRY_RUN) {
    log(`\ndry run — ${tasks.length} task(s) would render, nothing written.`);
    return;
  }

  const manifest = writeManifest();
  log(
    `\nrendered ${result.rendered}, cached ${result.cached}, failed ${result.failures.length}` +
      ` in ${result.seconds.toFixed(1)}s`,
  );
  log(
    `manifest: ${manifest.totals.files} file(s), ` +
      `${(manifest.totals.bytes / 1024 / 1024).toFixed(1)} MiB, ` +
      `${manifest.totals.locales} locale(s) → ${rel(MANIFEST)}`,
  );

  if (result.failures.length > 0) {
    console.error(`\n✗ ${result.failures.length} task(s) failed:`);
    for (const { task, error } of result.failures.slice(0, 20)) {
      const label =
        task.kind === 'frame'
          ? `${task.locale.asc} ${task.device.dir} frame ${task.frame.index}`
          : `${task.locale.asc} ${task.kind}`;
      console.error(`  ${label}: ${error.message}`);
    }
    process.exit(1);
  }
}

main().catch((error) => {
  console.error(`\n✗ render: ${error.stack ?? error.message}`);
  process.exit(1);
});
