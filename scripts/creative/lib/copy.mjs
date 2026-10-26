/**
 * Headline and support copy, derived from `store/asc/listings.json`.
 *
 * Why derive instead of authoring 300 strings: the store copy for all 50
 * locales already exists, and it was translated once by the listing pipeline.
 * A screenshot headline that reuses the same translated marketing line reads as
 * one product and earns the ASO alignment Apple rewards (name, subtitle,
 * screenshots and keywords all speaking the same language).
 *
 * The description is a fixed template, so it parses by block index — verified
 * against all 50 locales (12 blocks, indices 1..9 are the marketing sections).
 * A locale whose block does not match the template is reported, never guessed:
 * that is what `store/creative/copy.json` overrides are for.
 *
 * Mapping (block index → screenshot frame):
 *   1  TRY PRO FREE FOR 1 MONTH  → frame 6 headline
 *   2  FREE FOREVER (+5 bullets) → frame 6 free tier rows
 *   3  DIGITIZE YOUR WHOLE CLOSET → frame 1
 *   4  SEE IT ON YOU              → frame 3
 *   5  AI PHOTOSHOOT              → frame 4
 *   6  GET DRESSED IN SECONDS     → frame 2
 *   7  KNOW WHAT YOU ACTUALLY WEAR → frame 5
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { STORE_ASC, COPY } from './paths.mjs';
import { loadLocales } from './locales.mjs';
import { fontFor, hasScriptText, scriptFor } from './scripts.mjs';

/**
 * The full stop a truncated supporting line should close with.
 *
 * Thai writes no full stop; Chinese and Japanese use their own ideographic one.
 * Everything else takes the Latin form through the script's own keyboard.
 */
const TERMINATOR_BY_SCRIPT = {
  thai: '',
  hans: '。',
  hant: '。',
  japanese: '。',
  bengali: '।',
  devanagari: '।',
  gujarati: '।',
  gurmukhi: '।',
  oriya: '।',
};

const listingsCache = new Map();

export function loadListings() {
  const raw = readFileSync(join(STORE_ASC, 'listings.json'), 'utf8');
  return JSON.parse(raw);
}

export function listingFor(asc, listings = null) {
  const data = listings ?? loadListings();
  const entry = data[asc];
  if (!entry) throw new Error(`listings.json has no entry for ${asc}`);
  return entry;
}

/** Description split into blocks of non-empty lines. */
export function blocksFor(asc, listings = null) {
  const entry = listingFor(asc, listings);
  return entry.description
    .split(/\n{2,}/)
    .map((block) => block.split('\n').map((line) => line.trim()).filter(Boolean))
    .filter((lines) => lines.length > 0);
}

/**
 * The listing's description as 12 named sections, `null` where a locale is
 * missing one.
 *
 * The template is fixed at 12 blocks, but two locales do not have 12 blocks:
 * `ta-IN` has 10 and `pa-IN` has 11, both because the "KNOW WHAT YOU ACTUALLY
 * WEAR" section was never written in those listings. Indexing by position then
 * silently slides: Tamil's block 7 is `SUBSCRIPTIONS`, so frame 5 was advertising
 * subscriptions under a headline about knowing what you wear.
 *
 * Sections are therefore resolved by anchor rather than by index:
 *   - 0–6 are positionally stable across all 50 locales (verified: every locale
 *     opens with the intro, then TRY PRO, FREE FOREVER, then the four feature
 *     sections).
 *   - 9–11 are anchored to the end of the description: the note is last, the
 *     legal block is the one carrying a URL or `EULA`, and `SUBSCRIPTIONS` is
 *     directly above it. Those three never move, whatever the middle holds.
 *   - 7–8 live in the middle. They are assigned by shape — section 7 is a header
 *     plus one paragraph, section 8 is a header plus bullets, so their line
 *     counts differ and a lone middle block can be told apart. An unassignable
 *     middle stays `null` instead of borrowing its neighbour's text.
 */
export function sectionsFor(asc, listings = null) {
  const raw = blocksFor(asc, listings);
  const enRaw = blocksFor(loadLocales().default, listings);
  const sections = new Array(12).fill(null);
  for (let i = 0; i < 7 && i < raw.length; i += 1) sections[i] = raw[i];
  if (raw.length === 12) {
    for (let i = 7; i < 12; i += 1) sections[i] = raw[i];
    return sections;
  }

  // Tail anchors, searched from the end so a stray paragraph mid-listing cannot
  // be mistaken for the legal block.
  let terms = -1;
  for (let i = raw.length - 1; i >= 7; i -= 1) {
    const text = raw[i].join('\n');
    if (/https?:\/\//iu.test(text) || /\bEULA\b/iu.test(text)) {
      terms = i;
      break;
    }
  }
  if (terms <= 7) return sections;
  sections[9] = raw[terms - 1] ?? null;
  sections[10] = raw[terms];
  sections[11] = raw[raw.length - 1] ?? null;

  const middle = raw.slice(7, terms - 1);
  const shape = (block) => block?.length ?? 0;
  const en7 = shape(enRaw[7]);
  const en8 = shape(enRaw[8]);
  if (middle.length === 2) {
    sections[7] = middle[0];
    sections[8] = middle[1];
  } else if (middle.length === 1) {
    const nearest = Math.abs(shape(middle[0]) - en7) <= Math.abs(shape(middle[0]) - en8) ? 7 : 8;
    sections[nearest] = middle[0];
  }
  return sections;
}

const SENTENCE_END = /[.!?。！？।॥؟…]/u;
/** Clause boundaries a supporting line may end on without reading as cut. */
const CLAUSE_END = /[,;:，、；：—–]/u;

/**
 * A supporting line: one complete short sentence from the section body.
 *
 * Never an ellipsis and never a phrase cut mid-clause. When the opening
 * sentence is longer than the budget, the line is closed at the last clause
 * boundary inside the budget — real editors do the same — and only when there is
 * no boundary at all does it fall back to a word break, restoring a full stop so
 * the fragment still reads like a sentence.
 */
export function firstSentence(text, maxChars = 88, terminator = '.') {
  const trimmed = text.replace(/^[•·\-–—]\s*/, '').trim();
  let end = -1;
  for (let i = 0; i < trimmed.length; i += 1) {
    if (SENTENCE_END.test(trimmed[i])) {
      end = i;
      break;
    }
  }
  const sentence = (end === -1 ? trimmed : trimmed.slice(0, end + 1)).trim();
  if (sentence.length <= maxChars) return sentence;

  const budget = trimmed.slice(0, maxChars);
  let clause = -1;
  for (let i = 0; i < budget.length; i += 1) {
    if (CLAUSE_END.test(budget[i])) clause = i;
  }
  if (clause >= maxChars * 0.55) {
    const cut = trimmed.slice(0, clause).trim();
    const tail = trimmed[clause];
    // A colon or dash introduces a list; it reads as complete without its
    // payload. A comma does not, so the clause keeps its own full stop.
    if (tail === ':' || tail === '—' || tail === '–') return cut;
    return terminator ? `${cut}${terminator}` : cut;
  }

  const space = budget.lastIndexOf(' ');
  const words = (space > maxChars * 0.6 ? trimmed.slice(0, space) : budget)
    .trim()
    .replace(/[,;:，、；：]$/u, '');
  return terminator ? `${words}${terminator}` : words;
}

/** Split a body paragraph into sentences on every script's own terminator. */
export function sentences(text) {
  return text
    .split(/(?<=[.!?。！？।॥؟…])\s*/u)
    .map((sentence) => sentence.trim())
    .filter(Boolean);
}

/**
 * A headline built from one translated sentence of a section body.
 *
 * Used where the section header is already spent on an earlier frame and the
 * body still holds the line the frame needs. The clause before the first comma
 * is the tightest complete thought the copy contains, so it wins when it stands
 * alone; otherwise the whole sentence is used with its terminator trimmed. The
 * words are always the store's own translated copy, never an authored string.
 */
export function clauseOf(text, { minChars = 16, maxChars = 110 } = {}) {
  const sentence = sentences(text)[0] ?? text.trim();
  const stripped = sentence.replace(/[.!?。！？।॥؟…]+$/u, '').trim();
  const separators = new Set([',', ';', ':', '，', '、', '；', '：', '—', '–']);
  let cut = -1;
  for (let i = minChars; i < stripped.length; i += 1) {
    if (separators.has(stripped[i])) {
      cut = i;
      break;
    }
  }
  const clause = cut === -1 ? stripped : stripped.slice(0, cut).trim();
  if (clause.length <= maxChars) return clause;
  const space = clause.lastIndexOf(' ', maxChars);
  return (space > minChars ? clause.slice(0, space) : clause.slice(0, maxChars)).trim();
}

function loadOverrides() {
  try {
    return JSON.parse(readFileSync(COPY, 'utf8'));
  } catch {
    return { frames: [], overrides: {} };
  }
}

let planCache = null;
export function loadCopyPlan() {
  if (planCache) return planCache;
  const file = loadOverrides();
  if (!Array.isArray(file.frames) || file.frames.length === 0) {
    throw new Error(`${COPY} has no frames[]. Run the pipeline from a real checkout.`);
  }
  planCache = file;
  return planCache;
}

/** Frames in App Store order, with their copy source mapping. */
export function framePlan() {
  const { frames } = loadCopyPlan();
  return [...frames].sort((a, b) => a.index - b.index);
}

/**
 * True when a locale's block text is not usable as that locale's headline.
 *
 * Two independent tests, because either alone lets bad copy through:
 *
 * 1. `identical` — the string equals the English source. Compared against en-US
 *    rather than sniffing for Latin characters, because Spanish, German and
 *    Indonesian are legitimately Latin and must not be flagged.
 * 2. `wrongScript` — the locale writes in a non-Latin script and the string
 *    contains none of that script's characters. This catches a listing that
 *    "translated" a header to a word like `SUBSCRIPTIONS`: it differs from the
 *    English header, so (1) passes it, and it renders in the display face looking
 *    intentional while being untranslated English.
 */
function isUntranslated(enText, text, asc, primary) {
  if (asc === primary || asc.startsWith('en-')) return false;
  if (enText === text) return true;
  return !hasScriptText(scriptFor(asc), text);
}

/**
 * The copy for one locale, one frame.
 *
 * The listing is always preferred. An authored override in `copy.json` is a
 * *fallback*: `render.mjs` uses it only when the store's own translated line
 * cannot be set inside the frame's line budget. That matters because
 * `store/asc/listings.json` is being translated by another workstream while this
 * pipeline runs — a header that was English (or too long) on Monday is finished
 * copy on Wednesday, and a hardcoded override would quietly keep overriding it.
 *
 * Precedence when `variant` is 'override' (fallback): override → listing →
 * subtitle. Otherwise: listing → subtitle, and an authored override is used
 * anyway when the listing never wrote the section the frame needs.
 */
export function copyFor(asc, frame, { variant = 'listing' } = {}) {
  const { default: primary } = loadLocales();
  const listings = loadListings();
  const en = sectionsFor(primary, listings);
  const sections = sectionsFor(asc, listings);
  const override = loadCopyPlan().overrides?.[asc]?.[String(frame.index)] ?? {};
  const terminator = TERMINATOR_BY_SCRIPT[fontFor(asc).script] ?? '.';

  const enHeadline = en[frame.headlineBlock]?.[0] ?? '';
  const section = sections[frame.headlineBlock];
  const headlineLine = section?.[0] ?? '';
  const missing = !section;
  const headlineUntranslated = !missing && isUntranslated(enHeadline, headlineLine, asc, primary);

  let headline = headlineLine;
  let source = `description[${frame.headlineBlock}].header`;

  // `headlineStyle: 'sentence'` takes the frame's line from a body sentence
  // instead of the section header, for a frame whose story the listing covers
  // under a header another frame already uses.
  if (frame.headlineStyle === 'sentence' && section) {
    const body = section.slice(1).join(' ');
    const enBody = (en[frame.headlineBlock] ?? []).slice(1).join(' ');
    const sentence = sentences(body)[frame.headlineSentence ?? 0] ?? '';
    const enSentence = sentences(enBody)[frame.headlineSentence ?? 0] ?? '';
    if (sentence && !isUntranslated(enSentence, sentence, asc, primary)) {
      headline = clauseOf(sentence);
      source = `description[${frame.headlineBlock}].sentence[${frame.headlineSentence ?? 0}]`;
    }
  }

  if (missing) source = `description[${frame.headlineBlock}].missing`;

  if (variant === 'override' && override.headline) {
    headline = override.headline;
    source = 'override-fallback';
  } else if ((missing || headlineUntranslated) && override.headline) {
    // The listing cannot carry this frame (section absent, or still English).
    // An authored line is the only remaining source that is real copy.
    headline = override.headline;
    source = missing ? 'override-section-missing' : 'override-untranslated';
  } else if (missing || headlineUntranslated) {
    headline = listingFor(asc, listings).subtitle;
    source = missing ? 'subtitle-section-missing' : 'subtitle-fallback';
  }

  let support = null;
  let supportSource = null;
  if (frame.supportStyle === 'sentence' && sections[frame.supportBlock]) {
    const body = sections[frame.supportBlock][1] ?? '';
    const candidate = body ? firstSentence(body, frame.supportMaxChars ?? 92, terminator) : '';
    if (candidate) {
      support = candidate;
      supportSource = `description[${frame.supportBlock}].sentence`;
    }
  }

  if (variant === 'override' && override.support !== undefined) {
    support = override.support;
    supportSource = override.support ? 'override-fallback' : null;
  }
  if (support && firstSentence(support, 200).length === 0) support = null;

  const authored = source.startsWith('override');
  return {
    headline: headline.trim(),
    support: support ? support.trim() : null,
    source,
    supportSource,
    untranslated: !authored && (missing || headlineUntranslated),
    reviewed: authored ? (override.reviewed ?? false) : !(missing || headlineUntranslated),
  };
}

/** Whether an authored fallback exists for this locale and frame. */
export function hasOverride(asc, frame) {
  const override = loadCopyPlan().overrides?.[asc]?.[String(frame.index)];
  return Boolean(override?.headline);
}

/**
 * The localized free-tier rows and the "free forever" chip for the offer frame.
 *
 * Both come from the listing's own FREE FOREVER block, so the numbers can never
 * drift from the store copy.
 */
export function offerFor(asc) {
  const { default: primary } = loadLocales();
  const listings = loadListings();
  const en = sectionsFor(primary, listings);
  const sections = sectionsFor(asc, listings);
  const freeBlock = loadCopyPlan().frames.find((f) => f.id === 'offer')?.freeBlock ?? 2;
  const lines = sections[freeBlock] ?? [];
  const enLines = en[freeBlock] ?? [];
  const same = (line) => asc !== primary && !asc.startsWith('en-') && enLines.includes(line);
  // The block header and the bullets are compared line by line: Odia (`or-IN`)
  // keeps an English header while its bullets are translated, and dropping the
  // whole block would throw away copy that is already localized.
  const chip = lines[0] && !same(lines[0]) ? lines[0] : null;
  const rows = lines
    .filter((line) => /^[•·]/.test(line))
    .map((line) => line.replace(/^[•·]\s*/, ''))
    .filter((line) => !same(`• ${line}`) && !same(line))
    .slice(0, 3);
  return { chip, rows, untranslated: !chip && rows.length === 0 };
}

export function listingsFingerprint() {
  if (listingsCache.has('fp')) return listingsCache.get('fp');
  const raw = readFileSync(join(STORE_ASC, 'listings.json'), 'utf8');
  listingsCache.set('fp', raw);
  return raw;
}
