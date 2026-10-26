/**
 * Lazy locale loading.
 *
 * English is a static import because it is the fallback for every key in every
 * language: if the Hindi bundle lacks a key, or the network drops mid-switch,
 * the UI must still paint. It is also the language every visitor starts on
 * before `resolveLocale` runs.
 *
 * The other 42 catalogs are separate `import()` calls so Vite emits one chunk
 * per language. Importing them eagerly would have been simpler and wrong: at
 * roughly 8–12 kB per catalog, 42 eager catalogs would add ~400 kB — and its
 * gzip — to the entry chunk that every marketing visitor downloads before the
 * hero renders. With dynamic imports, a French user downloads French and
 * nothing else, and the entry chunk stays flat (see docs/FRONTEND.md for the
 * measured before/after numbers).
 *
 * The map is written out longhand rather than built from a template string
 * (`import(\`./locales/${code}.json\`)`) on purpose: Vite can only code-split on
 * static specifiers. A template string makes Rollup inline every JSON file it
 * can see into the entry chunk, which is exactly the regression this file
 * exists to prevent.
 */

import en from './locales/en.json'
import { DEFAULT_LOCALE } from './localeMeta'

export type Messages = Record<string, string>

export const SOURCE_MESSAGES: Messages = en as Messages

type Loader = () => Promise<{ default: Messages }>

const LOADERS: Record<string, Loader> = {
  en: () => Promise.resolve({ default: SOURCE_MESSAGES }),
  es: () => import('./locales/es.json'),
  pt: () => import('./locales/pt.json'),
  fr: () => import('./locales/fr.json'),
  de: () => import('./locales/de.json'),
  it: () => import('./locales/it.json'),
  nl: () => import('./locales/nl.json'),
  sv: () => import('./locales/sv.json'),
  no: () => import('./locales/no.json'),
  da: () => import('./locales/da.json'),
  fi: () => import('./locales/fi.json'),
  pl: () => import('./locales/pl.json'),
  cs: () => import('./locales/cs.json'),
  sk: () => import('./locales/sk.json'),
  sl: () => import('./locales/sl.json'),
  hr: () => import('./locales/hr.json'),
  ro: () => import('./locales/ro.json'),
  hu: () => import('./locales/hu.json'),
  el: () => import('./locales/el.json'),
  tr: () => import('./locales/tr.json'),
  ru: () => import('./locales/ru.json'),
  uk: () => import('./locales/uk.json'),
  ar: () => import('./locales/ar.json'),
  he: () => import('./locales/he.json'),
  ur: () => import('./locales/ur.json'),
  hi: () => import('./locales/hi.json'),
  bn: () => import('./locales/bn.json'),
  gu: () => import('./locales/gu.json'),
  kn: () => import('./locales/kn.json'),
  ml: () => import('./locales/ml.json'),
  mr: () => import('./locales/mr.json'),
  or: () => import('./locales/or.json'),
  pa: () => import('./locales/pa.json'),
  ta: () => import('./locales/ta.json'),
  te: () => import('./locales/te.json'),
  zh: () => import('./locales/zh.json'),
  ja: () => import('./locales/ja.json'),
  ko: () => import('./locales/ko.json'),
  th: () => import('./locales/th.json'),
  vi: () => import('./locales/vi.json'),
  id: () => import('./locales/id.json'),
  ms: () => import('./locales/ms.json'),
  ca: () => import('./locales/ca.json'),
}

/**
 * In-flight and resolved bundles. Without this, a remount or a double effect
 * run would issue the same chunk request twice, and switching back and forth
 * between two languages would re-download both.
 */
const resolved = new Map<string, Messages>()
const inFlight = new Map<string, Promise<Messages>>()

export function getLoadedMessages(locale: string): Messages | null {
  return resolved.get(locale) ?? null
}

/**
 * Load one catalog. Never rejects: a missing or corrupt catalog resolves to the
 * English source, because a broken translation file must degrade to readable UI,
 * not to a blank screen.
 */
export function loadMessages(locale: string): Promise<Messages> {
  const cached = resolved.get(locale)
  if (cached) return Promise.resolve(cached)

  const pending = inFlight.get(locale)
  if (pending) return pending

  const loader = LOADERS[locale]
  if (!loader) return Promise.resolve(SOURCE_MESSAGES)

  const request = loader()
    .then((module) => {
      const messages = (module.default ?? {}) as Messages
      // A catalog that disagrees with English on keys is a build bug the checker
      // catches; at runtime, merging keeps a partially-translated bundle usable.
      const merged = locale === DEFAULT_LOCALE ? messages : { ...SOURCE_MESSAGES, ...messages }
      resolved.set(locale, merged)
      return merged
    })
    .catch(() => SOURCE_MESSAGES)
    .finally(() => {
      inFlight.delete(locale)
    })

  inFlight.set(locale, request)
  return request
}

/** Is this language one we ship a catalog for? */
export function hasCatalog(locale: string): boolean {
  return locale in LOADERS
}
