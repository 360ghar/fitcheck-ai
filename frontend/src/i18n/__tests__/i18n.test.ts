/**
 * Language resolution is the one piece of the i18n layer with a rule that must
 * never regress: an explicit choice beats the browser, forever. It is pure, so
 * it is cheap to pin here rather than only through a rendered page.
 */

import { describe, expect, it } from 'vitest'
import { normalizeLocaleTag, isRtlLocale, LOCALES } from '../localeMeta'
import { resolveLocale } from '../resolveLocale'
import { categoryLabel, conditionLabel, seasonLabel, styleLabel } from '../taxonomy'

describe('normalizeLocaleTag', () => {
  it('collapses a region to its base language', () => {
    expect(normalizeLocaleTag('hi-IN')).toBe('hi')
    expect(normalizeLocaleTag('pt-BR')).toBe('pt')
    expect(normalizeLocaleTag('pt_BR')).toBe('pt')
    expect(normalizeLocaleTag('zh-Hans-CN')).toBe('zh')
  })

  it('reads the first entry of an Accept-Language style list', () => {
    expect(normalizeLocaleTag('hi-IN,hi;q=0.9,en;q=0.8')).toBe('hi')
    expect(normalizeLocaleTag('en-US,en;q=0.9')).toBe('en')
  })

  it('maps the legacy IANA aliases Safari still emits', () => {
    expect(normalizeLocaleTag('iw')).toBe('he')
    expect(normalizeLocaleTag('in')).toBe('id')
    expect(normalizeLocaleTag('nb-NO')).toBe('no')
  })

  it('returns null for a language we do not ship', () => {
    // Null, not "en": the caller needs to distinguish "unsupported" from
    // "English" to keep walking the browser's preference list.
    expect(normalizeLocaleTag('tlh')).toBeNull()
    expect(normalizeLocaleTag('')).toBeNull()
    expect(normalizeLocaleTag(null)).toBeNull()
  })
})

describe('resolveLocale', () => {
  const browser = ['es-ES', 'en-US']

  it('lets an explicit choice win over the browser, forever', () => {
    expect(
      resolveLocale({ explicit: 'hi', account: 'fr', browserLanguages: browser })
    ).toBe('hi')
  })

  it('adopts the account language when the browser has never chosen', () => {
    // The phone wrote `user_settings.language = "ta"`; the web must agree rather
    // than quietly rendering Spanish because the laptop is set to es-ES.
    expect(resolveLocale({ explicit: null, account: 'ta', browserLanguages: browser })).toBe(
      'ta'
    )
  })

  it('walks the browser list in the stated priority order', () => {
    // navigator.languages[0] alone would give English for a Tamil speaker whose
    // second preference is English. Tamil is shipped, so Tamil wins.
    expect(
      resolveLocale({ explicit: null, account: null, browserLanguages: ['ta-IN', 'en-US'] })
    ).toBe('ta')
  })

  it('skips unsupported browser languages instead of stopping at the first', () => {
    expect(
      resolveLocale({ explicit: null, account: null, browserLanguages: ['tlh', 'ja-JP', 'en'] })
    ).toBe('ja')
  })

  it('falls back to English when nothing matches', () => {
    expect(resolveLocale({ explicit: null, account: null, browserLanguages: [] })).toBe('en')
    expect(
      resolveLocale({ explicit: null, account: null, browserLanguages: ['tlh'] })
    ).toBe('en')
  })

  it('ignores an unsupported explicit value rather than persisting a broken one', () => {
    expect(
      resolveLocale({ explicit: 'tlh', account: null, browserLanguages: ['fr-FR'] })
    ).toBe('fr')
  })
})

describe('localeMeta', () => {
  it('ships 43 base languages with unique codes', () => {
    expect(LOCALES).toHaveLength(43)
    expect(new Set(LOCALES.map((entry) => entry.code)).size).toBe(43)
  })

  it('marks exactly Arabic, Hebrew and Urdu as right-to-left', () => {
    const rtl = LOCALES.filter((entry) => entry.rtl).map((entry) => entry.code)
    expect(rtl.sort()).toEqual(['ar', 'he', 'ur'])
    expect(isRtlLocale('ar')).toBe(true)
    expect(isRtlLocale('hi')).toBe(false)
  })

  it('gives every language an endonym and an English name', () => {
    for (const entry of LOCALES) {
      expect(entry.native.length).toBeGreaterThan(0)
      expect(entry.english.length).toBeGreaterThan(0)
    }
  })
})

describe('taxonomy labels', () => {
  // The English fallback formatter the hook uses outside a provider: identity
  // per key, so these assertions test the *selection* logic, not translations.
  const t = (id: string) => `[${id}]`

  it('translates a known stored value', () => {
    expect(categoryLabel(t, 'tops')).toBe('[taxonomy.category.tops]')
    expect(conditionLabel(t, 'laundry')).toBe('[taxonomy.condition.laundry]')
    expect(seasonLabel(t, 'all-season')).toBe('[taxonomy.season.all-season]')
    expect(styleLabel(t, 'Streetwear')).toBe('[taxonomy.style.streetwear]')
  })

  it('passes through a value the taxonomy does not know', () => {
    // An AI-invented sub-category or a user-typed brand must render as itself,
    // not as a message id.
    expect(categoryLabel(t, 'gift-card')).toBe('gift-card')
    expect(styleLabel(t, 'quiet luxury')).toBe('quiet luxury')
  })

  it('renders empty for a missing value', () => {
    expect(categoryLabel(t, undefined)).toBe('')
    expect(categoryLabel(t, null)).toBe('')
  })
})
