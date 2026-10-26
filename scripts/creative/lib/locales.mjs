/**
 * The locale table, read from `store/asc/locales.json`.
 *
 * That file is owned by the App Store publishing stream; this module only
 * reads it. Rendering in a locale that is missing there is a hard error, so the
 * creative can never drift from the store listing it is supposed to match.
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { STORE_ASC } from './paths.mjs';

let cache = null;

export function loadLocales() {
  if (cache) return cache;
  const raw = JSON.parse(readFileSync(join(STORE_ASC, 'locales.json'), 'utf8'));
  const byAsc = new Map(raw.locales.map((locale) => [locale.asc, locale]));
  cache = { default: raw.default, locales: raw.locales, byAsc };
  return cache;
}

/** Every locale, primary first, then by tier, then code — the order to render. */
export function orderedLocales() {
  const { default: primary, locales } = loadLocales();
  return [...locales].sort((a, b) => {
    if (a.asc === primary) return -1;
    if (b.asc === primary) return 1;
    return a.tier - b.tier || a.asc.localeCompare(b.asc);
  });
}

export function localeOrThrow(asc) {
  const { byAsc } = loadLocales();
  const locale = byAsc.get(asc);
  if (!locale) {
    const known = [...byAsc.keys()].join(', ');
    throw new Error(`Unknown locale "${asc}". Known: ${known}`);
  }
  return locale;
}

/** `-` and `_` both appear in hand-typed locale lists. */
export function normaliseLocale(value) {
  const { byAsc } = loadLocales();
  const trimmed = value.trim();
  for (const candidate of [trimmed, trimmed.replace('_', '-')]) {
    if (byAsc.has(candidate)) return candidate;
  }
  const lower = trimmed.toLowerCase();
  for (const code of byAsc.keys()) {
    if (code.toLowerCase() === lower) return code;
  }
  return null;
}
