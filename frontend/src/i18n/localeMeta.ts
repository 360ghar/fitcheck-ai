/**
 * The 43 base languages the web app ships.
 *
 * One entry per language, not per storefront. `store/asc/locales.json` lists 50
 * App Store locales (en-US, en-GB, pt-BR, pt-PT, es-ES, es-MX, zh-Hans,
 * zh-Hant …); those exist so a store listing can say "English (UK)". The web
 * app does not need them: a browser reports `pt-BR`, the catalog is `pt`, and
 * the region variant only ever changes number and date formatting, which
 * `Intl.*` derives from the *full* BCP-47 tag at runtime (see `runtime.ts`).
 *
 * `code` is the base language, and it is exactly what
 * `backend/app/core/i18n.py::SUPPORTED_LANGUAGES` accepts and what the Flutter
 * client writes to `user_settings.language` via `PUT /api/v1/users/settings`.
 * Keeping the set identical is what lets a phone choice and a web choice mean
 * the same thing. `scripts/i18n/check_web_locales.py` fails the build if this
 * list, the catalog directory, and the backend list ever drift apart.
 *
 * `native` is the endonym, copied from `store/asc/locales.json`'s `native`
 * field, because a language picker that says "Chinese (Simplified)" to a
 * Chinese reader is the one screen where English is least acceptable.
 */

export interface LocaleMeta {
  /** Base language code. Matches backend `SUPPORTED_LANGUAGES` and the catalog filename. */
  code: string
  /** Endonym, shown in the picker. */
  native: string
  /** English name, for search ("Japanese" finds 日本語) and for the translator prompt. */
  english: string
  /** Right-to-left script. Drives `dir="rtl"` on <html>. */
  rtl: boolean
}

export const LOCALES: readonly LocaleMeta[] = [
  { code: 'en', native: 'English', english: 'English', rtl: false },
  { code: 'es', native: 'Español', english: 'Spanish', rtl: false },
  { code: 'pt', native: 'Português', english: 'Portuguese', rtl: false },
  { code: 'fr', native: 'Français', english: 'French', rtl: false },
  { code: 'de', native: 'Deutsch', english: 'German', rtl: false },
  { code: 'it', native: 'Italiano', english: 'Italian', rtl: false },
  { code: 'nl', native: 'Nederlands', english: 'Dutch', rtl: false },
  { code: 'sv', native: 'Svenska', english: 'Swedish', rtl: false },
  { code: 'no', native: 'Norsk', english: 'Norwegian', rtl: false },
  { code: 'da', native: 'Dansk', english: 'Danish', rtl: false },
  { code: 'fi', native: 'Suomi', english: 'Finnish', rtl: false },
  { code: 'pl', native: 'Polski', english: 'Polish', rtl: false },
  { code: 'cs', native: 'Čeština', english: 'Czech', rtl: false },
  { code: 'sk', native: 'Slovenčina', english: 'Slovak', rtl: false },
  { code: 'sl', native: 'Slovenščina', english: 'Slovenian', rtl: false },
  { code: 'hr', native: 'Hrvatski', english: 'Croatian', rtl: false },
  { code: 'ro', native: 'Română', english: 'Romanian', rtl: false },
  { code: 'hu', native: 'Magyar', english: 'Hungarian', rtl: false },
  { code: 'el', native: 'Ελληνικά', english: 'Greek', rtl: false },
  { code: 'tr', native: 'Türkçe', english: 'Turkish', rtl: false },
  { code: 'ru', native: 'Русский', english: 'Russian', rtl: false },
  { code: 'uk', native: 'Українська', english: 'Ukrainian', rtl: false },
  { code: 'ar', native: 'العربية', english: 'Arabic', rtl: true },
  { code: 'he', native: 'עברית', english: 'Hebrew', rtl: true },
  { code: 'ur', native: 'اردو', english: 'Urdu', rtl: true },
  { code: 'hi', native: 'हिन्दी', english: 'Hindi', rtl: false },
  { code: 'bn', native: 'বাংলা', english: 'Bangla', rtl: false },
  { code: 'gu', native: 'ગુજરાતી', english: 'Gujarati', rtl: false },
  { code: 'kn', native: 'ಕನ್ನಡ', english: 'Kannada', rtl: false },
  { code: 'ml', native: 'മലയാളം', english: 'Malayalam', rtl: false },
  { code: 'mr', native: 'मराठी', english: 'Marathi', rtl: false },
  { code: 'or', native: 'ଓଡ଼ିଆ', english: 'Odia', rtl: false },
  { code: 'pa', native: 'ਪੰਜਾਬੀ', english: 'Punjabi', rtl: false },
  { code: 'ta', native: 'தமிழ்', english: 'Tamil', rtl: false },
  { code: 'te', native: 'తెలుగు', english: 'Telugu', rtl: false },
  { code: 'zh', native: '简体中文', english: 'Chinese (Simplified)', rtl: false },
  { code: 'ja', native: '日本語', english: 'Japanese', rtl: false },
  { code: 'ko', native: '한국어', english: 'Korean', rtl: false },
  { code: 'th', native: 'ไทย', english: 'Thai', rtl: false },
  { code: 'vi', native: 'Tiếng Việt', english: 'Vietnamese', rtl: false },
  { code: 'id', native: 'Bahasa Indonesia', english: 'Indonesian', rtl: false },
  { code: 'ms', native: 'Bahasa Melayu', english: 'Malay', rtl: false },
  { code: 'ca', native: 'Català', english: 'Catalan', rtl: false },
] as const

export const DEFAULT_LOCALE = 'en'

const BY_CODE = new Map(LOCALES.map((locale) => [locale.code, locale]))

export function isSupportedLocale(code: string | null | undefined): boolean {
  return Boolean(code && BY_CODE.has(code))
}

export function localeMeta(code: string): LocaleMeta {
  return BY_CODE.get(code) ?? BY_CODE.get(DEFAULT_LOCALE)!
}

export function isRtlLocale(code: string): boolean {
  return localeMeta(code).rtl
}

/**
 * Normalize anything a client can produce (`hi-IN`, `pt_BR`, `zh-Hans-CN`,
 * `en-US,en;q=0.9`) down to a base language we ship, or null.
 *
 * Deliberately returns null for unsupported languages instead of defaulting to
 * English: the caller needs to tell "the browser said Klingon" apart from "the
 * browser said English" to keep walking the preference list.
 */
export function normalizeLocaleTag(tag: string | null | undefined): string | null {
  if (!tag) return null
  // `Accept-Language`-style input: "hi-IN,hi;q=0.9,en;q=0.8" → "hi-IN".
  const first = tag.split(',')[0]?.split(';')[0]?.trim() ?? ''
  if (!first) return null
  const base = first.replace(/_/g, '-').split('-')[0]?.toLowerCase() ?? ''
  if (!base) return null
  // `he`/`iw` and `id`/`in` are the same language under two IANA codes; browsers
  // still emit the legacy form (Safari reports `iw` on some versions).
  const canonical = LEGACY_ALIASES[base] ?? base
  return BY_CODE.has(canonical) ? canonical : null
}

const LEGACY_ALIASES: Record<string, string> = {
  iw: 'he',
  in: 'id',
  ji: 'yi',
  nb: 'no',
  nn: 'no',
}
