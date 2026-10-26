#!/usr/bin/env node
/**
 * Local model of what this pipeline intends to publish.
 *
 * This module is deliberately offline: it reads `store/asc/` and answers
 * "what would we write?" without a token. `verify` prints the same plan next to
 * the live account state, and `publish` executes it.
 *
 * The separation matters because the App Store is a shared, externally visible
 * surface. Every command that writes first renders a plan, and the plan is a
 * pure function of files under version control.
 */

import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { STORE_DIR } from './asc.mjs';

export const LIMITS = {
  name: 30,
  subtitle: 30,
  promotionalText: 170,
  description: 4000,
  keywords: 100,
  whatsNew: 4000,
};

/**
 * Fields that must be present in every locale for the listing to submit.
 * `name` is exempt: it is the brand and stays constant, but it is still
 * written per locale because App Info requires a per-locale name field.
 */
export const REQUIRED_FIELDS = ['subtitle', 'promotionalText', 'description', 'keywords', 'whatsNew'];

/**
 * Terms the App Store's own guidance says to leave out of the keyword field.
 * Kept in sync with `scripts/asc/keyword_planner.py`; the two tools must not
 * disagree about what is allowed in the field they both write.
 *
 * Latin-script terms match on word boundaries, not as substrings, or "pro"
 * would condemn the Spanish "probador" (fitting room) and "app" would condemn
 * "apparel" — both good terms for this app.
 */
const FORBIDDEN_LATIN = /\b(apps?|applications?|free|gratis|gratuit(?:e|s)?|gratuit[oa]|kostenlos|ücretsiz|aplikacja|aplikasi|sovellus|ilmainen|fitcheck(?:ai)?|whering|stylebook|cladwell|pro)\b/iu;

/** Scripts without word boundaries, where a substring match is the only option. */
const FORBIDDEN_SUBSTRINGS = [
  'تطبيق', '应用', '應用', 'アプリ', '앱', 'ứng dụng', 'แอป', 'एप', 'ऐप',
  '無料', '무료', '免费', '免費', 'मुफ़', 'मुफ', 'مجان', 'חינם', 'ฟรี',
];

export { FORBIDDEN_LATIN, FORBIDDEN_SUBSTRINGS };

/** Split a comma-joined keyword field into its terms. */
export function splitKeywords(value) {
  return String(value ?? '')
    .split(',')
    .map((term) => term.trim())
    .filter(Boolean);
}

/** CJK, Thai and friends have no word spaces, so short terms prove nothing. */
const NO_WORD_SPACE_SCRIPTS = /[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}\p{Script=Thai}]/u;

export function readJson(name) {
  const path = join(STORE_DIR, name);
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, 'utf8'));
}

export function loadApp() {
  return readJson('app.json');
}

export function loadLocales() {
  const { default: primary, locales } = readJson('locales.json');
  const byAsc = new Map(locales.map((locale) => [locale.asc, locale]));
  return { primary, locales, byAsc };
}

export function loadListings() {
  const data = readJson('listings.json');
  const locales = Object.keys(data).filter((key) => !key.startsWith('_'));
  return { data, locales };
}

export function loadPlan() {
  return readJson('plan.json');
}

/**
 * Every locale that must exist for a complete listing, in the order metadata
 * should be written (primary first, then tier, then code) so a failure part-way
 * still leaves the most valuable storefronts done.
 */
export function orderedLocales() {
  const { primary, locales } = loadLocales();
  return [...locales]
    .sort((a, b) => {
      if (a.asc === primary) return -1;
      if (b.asc === primary) return 1;
      return a.tier - b.tier || a.asc.localeCompare(b.asc);
    })
    .map((locale) => locale.asc);
}

/** A locale key in listings.json also accepts the shorter Flutter form. */
export function localeKeysFor(ascCode) {
  const { byAsc } = loadLocales();
  const locale = byAsc.get(ascCode);
  if (!locale) return [ascCode];
  return [...new Set([ascCode, locale.dart, locale.dart.split('_')[0]])];
}

export function listingFor(listings, ascCode) {
  for (const key of localeKeysFor(ascCode)) {
    if (listings.data[key]) return { key, listing: listings.data[key] };
  }
  return { key: null, listing: null };
}

/**
 * Groups that are written per locale. `appInfo` carries the localized name and
 * privacy URL; `version` carries everything on the product page.
 */
export const FIELD_SURFACES = {
  appInfo: ['name', 'privacyPolicyUrl'],
  version: [
    'description',
    'keywords',
    'promotionalText',
    'supportUrl',
    'marketingUrl',
    'whatsNew',
  ],
};

/**
 * The creative asset plan. Screenshot sources are directories; the growth
 * assets are per-language PNGs produced by `scripts/growth`.
 */
export function assetPlan() {
  return loadPlan().media;
}

/**
 * Validates every listing against Apple's hard limits and this repo's ASO
 * rules. Returns { errors, warnings, coverage }.
 *
 * Errors are things Apple rejects or that break the plan (missing required
 * locale, over-limit field, duplicate keyword). Warnings are quality signals
 * (English description in a non-English locale, a keyword repeated from the
 * subtitle) that should not block a launch but should be visible.
 */
export function validateListings() {
  const errors = [];
  const warnings = [];
  const { data, locales } = loadListings();
  const { primary } = loadLocales();
  const wanted = orderedLocales();

  const missing = wanted.filter((code) => !listingFor({ data }, code).listing);
  for (const code of missing) errors.push(`${code}: no listing entry`);

  const english = listingFor({ data }, primary).listing;
  if (!english) {
    errors.push(`${primary}: no source listing, so nothing can be translated`);
    return { errors, warnings, coverage: { present: 0, wanted: wanted.length, locales } };
  }

  // The reference structure every translation is measured against.
  const englishBullets = (english.description ?? '')
    .split('\n').filter((line) => line.trim().startsWith('•')).length;
  const englishParagraphs = (english.description ?? '')
    .split(/\n\s*\n/).filter((block) => block.trim() !== '').length;

  for (const field of ['name', ...REQUIRED_FIELDS]) {
    const value = english[field];
    if (typeof value !== 'string' || value.trim() === '') {
      errors.push(`${primary}.${field}: empty`);
      continue;
    }
    if (value.length > LIMITS[field]) {
      errors.push(`${primary}.${field}: ${value.length} chars, over ${LIMITS[field]}`);
    }
  }

  for (const code of wanted) {
    const { listing, key } = listingFor({ data }, code);
    if (!listing) continue;
    if (!key) continue;

    for (const field of ['name', ...REQUIRED_FIELDS]) {
      const value = listing[field];
      if (typeof value !== 'string' || value.trim() === '') {
        errors.push(`${code}.${field}: empty`);
        continue;
      }
      if (value.length > LIMITS[field]) {
        errors.push(`${code}.${field}: ${value.length} chars, over ${LIMITS[field]}`);
      }
    }

    const keywords = listing.keywords ?? '';
    if (/,\s/.test(keywords)) {
      errors.push(`${code}.keywords: space after a comma wastes the 100-char budget`);
    }
    const terms = keywords.split(',').map((term) => term.trim()).filter(Boolean);
    const duplicates = terms.filter((term, index) => terms.indexOf(term) !== index);
    if (duplicates.length > 0) {
      errors.push(`${code}.keywords: repeats ${[...new Set(duplicates)].join(', ')}`);
    }

    // Terms Apple's own guidance says not to use. "app" describes every listing,
    // "free" is what the price label already says, and a competitor's name is a
    // rejection risk. Latin script matches on word boundaries so "apparel" and
    // "appearance" survive; scripts without spaces match as substrings.
    for (const term of terms) {
      const latin = FORBIDDEN_LATIN.exec(term);
      const embedded = FORBIDDEN_SUBSTRINGS.find((token) => term.includes(token));
      const hit = latin ? latin[0] : embedded;
      if (hit) {
        errors.push(`${code}.keywords: "${term}" spends budget on the discouraged term "${hit}"`);
      }
    }

    // A keyword string shredded into syllables matches nothing: Vietnamese
    // "trang phục" is one search, and "trang" beside "phục" is two non-searches.
    if (!NO_WORD_SPACE_SCRIPTS.test(terms.join('')) && terms.length >= 10) {
      const lengths = terms.map((term) => term.length).sort((a, b) => a - b);
      if (lengths[Math.floor(lengths.length / 2)] <= 4) {
        warnings.push(
          `${code}.keywords: terms look fragmented into syllables, not words`,
        );
      }
    }

    // Apple indexes name + subtitle + keywords together. A word in the subtitle
    // earns nothing when repeated in keywords.
    const subtitleWords = new Set(
      (listing.subtitle ?? '')
        .toLowerCase()
        .split(/[^\p{L}\p{N}\p{M}]+/u)
        .filter((word) => word.length > 2),
    );
    for (const term of terms) {
      if (term.includes(' ')) continue;
      if (subtitleWords.has(term.toLowerCase())) {
        warnings.push(`${code}.keywords: ${term} already appears in the subtitle`);
      }
    }

    if (code !== primary && listing.description === english.description) {
      // The four English storefronts legitimately share the English copy; only
      // a non-English locale still carrying it is a translation gap.
      if (!['en-GB', 'en-AU', 'en-CA'].includes(code)) {
        warnings.push(`${code}.description: still the English source`);
      }
    }

    // Structural parity with English.
    //
    // A translation that silently drops paragraphs still lands inside the
    // length band for its script, so every other check passes while a whole
    // storefront reads a shorter page. or-IN shipped 3 of 9 feature bullets and
    // lost the auto-renewal disclosure; ta-IN kept 5, pa-IN 8. Found by a
    // screenshot renderer complaining a frame had no copy, not by this
    // validator, which is why the rule lives here now.
    //
    // The disclosure is the part that matters legally: Apple's 3.1.2 requires
    // the auto-renewal terms to be stated where the subscription is described,
    // and subscriptions are described in every locale.
    if (englishBullets > 0) {
      const bullets = (listing.description ?? '')
        .split('\n').filter((line) => line.trim().startsWith('•')).length;
      if (bullets < englishBullets) {
        warnings.push(
          `${code}.description: ${bullets} feature bullet(s) of ${englishBullets};`
          + ' the translation dropped content English has',
        );
      }
    }
    if (englishParagraphs > 1) {
      const paragraphs = (listing.description ?? '')
        .split(/\n\s*\n/).filter((block) => block.trim() !== '').length;
      // One paragraph of slack: a translator may legitimately join the two
      // lines of a heading, and failing on that would be noise.
      if (paragraphs < englishParagraphs - 1) {
        warnings.push(
          `${code}.description: ${paragraphs} paragraph(s) of ${englishParagraphs};`
          + ' check that the subscription disclosure survived translation',
        );
      }
    }

    if (!listing.reviewed) {
      warnings.push(`${code}: not marked reviewed`);
    }
  }

  return {
    errors,
    warnings,
    coverage: { present: wanted.length - missing.length, wanted: wanted.length, missing },
  };
}
