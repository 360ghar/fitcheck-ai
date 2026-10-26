/**
 * Display labels for the canonical taxonomy values stored on an item.
 *
 * The architectural rule is that stored values stay English: `category: "tops"`
 * is what the API writes, what the AI prompt asks for, and what every stored
 * outfit references. If the picker wrote `category: "कमीज़"`, every language
 * switch would fork a user's wardrobe and the recommendation service would stop
 * matching pieces. So the value never changes — only the word on screen does.
 *
 * That makes this file the translation boundary for item attributes, and it is
 * deliberately explicit: an unknown value (a user-typed brand, an AI-invented
 * sub-category) falls through unchanged instead of rendering a message id. A
 * generic `t(\`taxonomy.category.${value}\`)` would print
 * "taxonomy.category.gift-card" on screen the first time the model did
 * something unexpected.
 */

import type { Translate } from './index'

/** The exact enum members from `types/index.ts`. Anything else is user data. */
const CATEGORIES = [
  'tops',
  'bottoms',
  'shoes',
  'accessories',
  'outerwear',
  'swimwear',
  'activewear',
  'other',
] as const

const CONDITIONS = ['clean', 'dirty', 'laundry', 'repair', 'donate'] as const

const SEASONS = ['spring', 'summer', 'fall', 'winter', 'all-season'] as const

const STYLES = [
  'casual',
  'formal',
  'business',
  'sporty',
  'bohemian',
  'streetwear',
  'classic',
  'elegant',
  'vintage',
  'minimalist',
  'romantic',
  'edgy',
  'preppy',
  'artsy',
  'other',
] as const

function label(
  t: Translate,
  group: 'category' | 'condition' | 'season' | 'style',
  known: readonly string[],
  value: string | null | undefined
): string {
  if (!value) return ''
  const key = value.toLowerCase()
  if (!known.includes(key)) return value
  return t(`taxonomy.${group}.${key}`)
}

export function categoryLabel(t: Translate, value: string | null | undefined): string {
  return label(t, 'category', CATEGORIES, value)
}

export function conditionLabel(t: Translate, value: string | null | undefined): string {
  return label(t, 'condition', CONDITIONS, value)
}

export function seasonLabel(t: Translate, value: string | null | undefined): string {
  return label(t, 'season', SEASONS, value)
}

export function styleLabel(t: Translate, value: string | null | undefined): string {
  return label(t, 'style', STYLES, value)
}

/**
 * Colour names are stored capitalized (`"Navy"`, `"Navy Blue"`), which is why
 * this group keeps its own case table rather than reusing the lowercased one.
 * `COLOR_STORAGE_VALUES` is the canonical set the filter chips offer; a colour
 * the AI invented ("Dusty Rose") falls through as itself.
 */
const COLORS = [
  'Black',
  'White',
  'Gray',
  'Navy',
  'Brown',
  'Beige',
  'Red',
  'Blue',
  'Green',
  'Yellow',
  'Pink',
  'Purple',
  'Orange',
  'Tan',
] as const

export function colorLabel(t: Translate, value: string | null | undefined): string {
  if (!value) return ''
  if (!(COLORS as readonly string[]).includes(value)) return value
  return t(`taxonomy.color.${value}`)
}

/**
 * Use cases ("formal", "date night", a user's own "brunch") are free-form tags,
 * not an enum — the backend stores whatever the user or the extraction model
 * wrote. So the known defaults translate and everything else falls through
 * with its first letter capitalized, in the *active locale*: the old
 * `charAt(0).toUpperCase()` rendered a Turkish "i" as "I" instead of "İ".
 */
/**
 * `style-options.ts` offers "Date night" as a suggested occasion, while the item
 * taxonomy calls the same tag "date". Normalize the spaces away instead of
 * shipping a second message id with a space in it.
 */
const USE_CASE_ALIASES: Record<string, string> = {
  'date night': 'date',
}

const USE_CASES = [
  'formal',
  'informal',
  'party',
  'date',
  'dinner',
  'lunch',
  'work',
  'travel',
  'wedding',
  'gym',
  'weekend',
  'interview',
] as const

export function describeUseCase(
  t: Translate,
  value: string | null | undefined,
  formattingLocale?: string
): string {
  if (!value) return ''
  const key = value.trim().toLowerCase()
  if (!key) return ''
  const canonical = USE_CASE_ALIASES[key] ?? key
  if ((USE_CASES as readonly string[]).includes(canonical)) return t(`taxonomy.usecase.${canonical}`)
  // A user-typed tag is user content: never translate it, only capitalize it.
  return key.charAt(0).toLocaleUpperCase(formattingLocale) + key.slice(1)
}

export const TAXONOMY = { CATEGORIES, CONDITIONS, SEASONS, STYLES, COLORS, USE_CASES } as const
