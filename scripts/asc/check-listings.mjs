#!/usr/bin/env node
/**
 * Validates the store listing before anything is pushed to App Store Connect.
 *
 *   node scripts/asc/check-listings.mjs            # report, fail on errors
 *   node scripts/asc/check-listings.mjs --strict   # also fail on warnings
 *
 * The checks are the ones that actually cost a submission:
 *
 *   1. Coverage - every one of the 50 locales has an entry. A missing locale is
 *      a storefront showing English to a user who was promised their language.
 *   2. Limits - Apple rejects the whole submission on one over-limit field, and
 *      reports it at upload rather than at edit time.
 *   3. Keyword hygiene - a space after a comma wastes the 100-character budget,
 *      a repeated term earns nothing, and a word already in the subtitle is
 *      indexed twice but counted once.
 *   4. Offer integrity - the free month and the free-forever limits must be
 *      present in every description. This is the one claim that must not drift
 *      in translation, because it is what the ads and the paywall promise.
 *   5. Places - URLs are identical in every locale (a mistranslated URL is a
 *      404 on the product page) and the numbers match the backend.
 *
 * Exit code is 0 when there are no errors, 1 otherwise.
 */

import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

import { loadLocales, validateListings, LIMITS, splitKeywords, FORBIDDEN_LATIN, FORBIDDEN_SUBSTRINGS } from './plan.mjs';
import { STORE_DIR } from './asc.mjs';

const strict = process.argv.includes('--strict');
const raw = JSON.parse(readFileSync(join(STORE_DIR, 'listings.json'), 'utf8'));
const englishListing = raw['en-US'] ?? {};

/**
 * Rewrites every Unicode decimal digit to ASCII.
 *
 * A language-neutral check cannot assume `50` is spelled with Latin digits:
 * Bengali writes ৫০, Marathi ५०, Odia ୫୦, Arabic ٥٠.
 *
 * The digit value comes from the position inside the character's contiguous
 * `Nd` run, which is exactly that block's ten digits. A modulo shortcut looks
 * simpler and is wrong: Bengali zero is U+09E6, so `0x9E6 % 16` is 6, and every
 * Bengali number would come out shifted by six.
 */
function asciiDigits(value) {
  return value.replace(/\p{Nd}/gu, (digit) => {
    const code = digit.codePointAt(0);
    let start = code;
    while (/\p{Nd}/u.test(String.fromCodePoint(start - 1))) start -= 1;
    return String(code - start);
  });
}

/**
 * True for scripts without letter case, where "the line is uppercase" cannot
 * distinguish a heading from body text. Every line of a Japanese or Hebrew
 * description compares equal to its own uppercase, which is how a length check
 * turned into 21 "section headings".
 */
const CASELESS = /[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}\p{Script=Hebrew}\p{Script=Devanagari}\p{Script=Bengali}\p{Script=Tamil}\p{Script=Telugu}\p{Script=Kannada}\p{Script=Malayalam}\p{Script=Gujarati}\p{Script=Gurmukhi}\p{Script=Oriya}\p{Script=Thai}\p{Script=Arabic}]/u;

/** Heading count, or null when the script has no case to detect one by. */
function sectionCount(description) {
  if (CASELESS.test(description)) return null;
  return description.split('\n')
    .filter((line) => line.trim() !== '' && line.trim() === line.trim().toUpperCase())
    .length;
}

/**
 * A description's length band relative to English, by script.
 *
 * CJK expresses the same content in roughly half the characters, so one band
 * for every language would flag every correct Japanese and Chinese listing.
 */
function lengthBand(description) {
  if (/[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}]/u.test(description)) {
    return [0.25, 0.85];
  }
  if (/[\p{Script=Hangul}\p{Script=Thai}\p{Script=Devanagari}\p{Script=Bengali}\p{Script=Tamil}\p{Script=Telugu}\p{Script=Kannada}\p{Script=Malayalam}\p{Script=Gujarati}\p{Script=Gurmukhi}\p{Script=Oriya}]/u.test(description)) {
    return [0.55, 1.35];
  }
  return [0.65, 1.35];
}

function main() {
  const { locales } = loadLocales();
  const { errors, warnings, coverage } = validateListings();
  const allErrors = [...errors];
  const allWarnings = [...warnings];

  console.log(`App Store listing: ${coverage.present}/${coverage.wanted} locales\n`);

  // --- offer integrity -----------------------------------------------------
  // Read the raw file: validateListings already rejected missing entries, so
  // this only inspects the ones that exist.

  let offerWarnings = 0;
  const englishDescription = raw['en-US']?.description ?? '';
  const englishSections = sectionCount(englishDescription) ?? 0;

  for (const locale of locales) {
    const entry = raw[locale.asc];
    if (!entry) continue;
    const description = entry.description ?? '';
    const normalized = asciiDigits(description);

    // The offer is structural, not lexical. Every locale keeps the English
    // section headings' shape, states the per-month allowance and the daily
    // photoshoot allowance. Checking those survives translation; checking for
    // the word "free" does not, because Finnish, Polish, Bengali and Odia each
    // spell it differently, and a word list is always one language short.
    const sections = sectionCount(description);
    if (sections !== null && sections < englishSections - 1) {
      offerWarnings += 1;
      allWarnings.push(
        `${locale.asc}.description: ${sections} section headings, English has ${englishSections}`,
      );
    }
    const fifties = (normalized.match(/\b50\b/g) ?? []).length;
    if (fifties < 2) {
      offerWarnings += 1;
      allWarnings.push(
        `${locale.asc}.description: the 50-item and 50-outfit limits appear ${fifties} time(s)`,
      );
    }
    if (!/\b10\b/.test(normalized)) {
      offerWarnings += 1;
      allWarnings.push(`${locale.asc}.description: the 10-images-a-day limit is missing`);
    }
    // A description far outside the band for its script has lost a section in
    // translation (short) or been padded (long). Both read wrong to a local
    // user, and the short case can drop the offer entirely.
    if (description.length > 0) {
      const ratio = description.length / englishDescription.length;
      const [low, high] = lengthBand(description);
      if (ratio < low || ratio > high) {
        allWarnings.push(
          `${locale.asc}.description: ${Math.round(ratio * 100)}% of the English length`
          + ` (expected ${Math.round(low * 100)}-${Math.round(high * 100)}% for this script)`,
        );
      }
    }
    if ((entry.whatsNew ?? '').length === 0) {
      allErrors.push(`${locale.asc}.whatsNew: empty`);
    }
  }

  // --- placeholder parity in promotional text ------------------------------
  // A stale `{price}` style token in store copy is not rendered by Apple: it
  // would appear literally to every customer in that storefront.
  for (const locale of locales) {
    const entry = raw[locale.asc];
    if (!entry) continue;
    for (const field of ['name', 'subtitle', 'promotionalText', 'description', 'keywords', 'whatsNew']) {
      const value = entry[field] ?? '';
      if (/\{[a-zA-Z_]+\}/.test(value)) {
        allErrors.push(`${locale.asc}.${field}: contains an unrendered {placeholder}`);
      }
    }
  }

  // --- URLs -----------------------------------------------------------------
  for (const locale of locales) {
    const entry = raw[locale.asc];
    if (!entry) continue;
    const description = entry.description ?? '';
    for (const url of ['https://fitcheckaiapp.com/privacy', 'https://fitcheckaiapp.com/terms']) {
      if (!description.includes(url)) {
        allWarnings.push(`${locale.asc}.description: missing ${url}`);
      }
    }
  }

  // --- structural parity ----------------------------------------------------
  // Lives in `validateListings()` (plan.mjs) so it is counted and reported
  // alongside every other listing warning. A translation may silently drop
  // paragraphs and still land inside the length band for its script; or-IN
  // shipped 3 of 9 bullets and lost the auto-renewal disclosure that way.

  // --- report ---------------------------------------------------------------
  const byTier = new Map();
  for (const locale of locales) {
    const tier = locale.tier;
    byTier.set(tier, (byTier.get(tier) ?? 0) + 1);
  }
  console.log('Review tiers:');
  for (const [tier, count] of [...byTier].sort()) {
    const reviewed = locales.filter((l) => l.tier === tier && raw[l.asc]?.reviewed).length;
    console.log(`  tier ${tier}: ${count} locale(s), ${reviewed} marked reviewed`);
  }
  const unreviewed = locales.filter((l) => raw[l.asc] && !raw[l.asc].reviewed);
  console.log(`  machine-translated, not human-reviewed: ${unreviewed.length}`);

  console.log(`\nLimits: name ${LIMITS.name}, subtitle ${LIMITS.subtitle}, promo ${LIMITS.promotionalText}, keywords ${LIMITS.keywords}, description ${LIMITS.whatsNew}`);
  console.log(`Offer message missing in ${offerWarnings} field(s)`);

  // --- custom product page keywords -----------------------------------------
  // A CPP earns its review cycle by capturing a search the main listing does not
  // win. A keyword the main listing already indexes buys nothing, and the same
  // discouraged terms apply. This is the only place the two keyword surfaces are
  // checked against each other, because they are written by different tools.
  const cppPath = join(STORE_DIR, 'cpp.json');
  if (existsSync(cppPath)) {
    const cpp = JSON.parse(readFileSync(cppPath, 'utf8'));
    const pages = cpp.pages ?? [];
    const indexed = new Set(
      [
        ...splitKeywords(englishListing.keywords ?? ''),
        ...(englishListing.subtitle ?? '').split(/[^\p{L}\p{N}-]+/u),
        ...(englishListing.name ?? '').split(/[^\p{L}\p{N}-]+/u),
      ]
        .map((token) => token.toLowerCase().trim())
        .filter(Boolean),
    );
    for (const page of pages) {
      const slug = page.slug ?? page.name ?? '(unnamed)';
      const keywords = page.keywords ?? [];
      if (keywords.length === 0) {
        allErrors.push(`cpp ${slug}: no keywords assigned, so it captures no search`);
      }
      for (const keyword of keywords) {
        if (indexed.has(keyword.toLowerCase())) {
          allErrors.push(
            `cpp ${slug}: "${keyword}" is already indexed by the main listing`,
          );
        }
        const latin = FORBIDDEN_LATIN.exec(keyword);
        const hit = latin ? latin[0] : FORBIDDEN_SUBSTRINGS.find((token) => keyword.includes(token));
        if (hit) {
          allErrors.push(`cpp ${slug}: "${keyword}" is the discouraged term "${hit}"`);
        }
      }
    }
    console.log(`\nCustom product pages: ${pages.length} page(s), keywords checked`);
  }

  if (allWarnings.length > 0) {
    // "not marked reviewed" fires once per locale — 49 lines of the same thing.
    // Printing in insertion order buried every *specific* warning (a dropped
    // disclosure, a locale with 17% of the English length) behind that wall, so
    // the one class of warning you could act on was the one you never saw.
    // Collapse the per-locale review flag to a count and let the rest lead.
    const isReviewFlag = (warning) => warning.endsWith(': not marked reviewed');
    const specific = allWarnings.filter((warning) => !isReviewFlag(warning));
    const reviewFlags = allWarnings.length - specific.length;

    console.log(`\n${allWarnings.length} warning(s): ${specific.length} specific, ${reviewFlags} per-locale review flags`);
    for (const warning of specific.slice(0, 40)) console.log(`  WARN ${warning}`);
    if (specific.length > 40) console.log(`  … ${specific.length - 40} more specific`);
    if (reviewFlags > 0) {
      console.log(`  WARN ${reviewFlags} locale(s) not marked reviewed (same for every locale; fixed by native review, not code)`);
    }
  }

  if (allErrors.length > 0) {
    console.log(`\n${allErrors.length} error(s):`);
    for (const error of allErrors.slice(0, 40)) console.log(`  ERROR ${error}`);
    if (allErrors.length > 40) console.log(`  … ${allErrors.length - 40} more`);
    process.exit(1);
  }

  console.log('\nNo errors.');
  if (strict && allWarnings.length > 0) {
    console.log('--strict: failing on warnings.');
    process.exit(1);
  }
}

main();
