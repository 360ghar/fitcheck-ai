/**
 * Language picker.
 *
 * Searchable, native-name first, and RTL-correct: each row renders in its own
 * script and its own direction, so "العربية" inside an LTR list is not mangled
 * by the surrounding paragraph direction. A right-to-left language's row gets
 * `dir="rtl"` on the label span only — the *list* stays in the interface
 * direction, because a picker whose rows move under the cursor is unusable.
 *
 * The search box matches the native name, the English name, and the code, so
 * "japanese", "日本語" and "ja" all find the same row.
 */

import { useMemo, useState } from 'react'
import { Check, Search } from 'lucide-react'
import { useTranslation, useLocaleChoices } from '@/i18n'
import { normalizeLocaleTag } from '@/i18n'
import { useLocaleStore } from '@/stores/localeStore'
import { cn } from '@/lib/utils'

export function LanguageSwitcher() {
  const { t } = useTranslation()
  const { locale, setLocale, locales, hasExplicitChoice, current } = useLocaleChoices()
  const clearExplicit = useLocaleStore((state) => state.clearExplicit)
  const [query, setQuery] = useState('')

  const filtered = useMemo(() => {
    const needle = query.trim().toLowerCase()
    if (!needle) return locales
    // A BCP-47 fragment ("hi-IN") should match the base code too.
    const normalizedNeedle = normalizeLocaleTag(needle) ?? needle
    return locales.filter(
      (entry) =>
        entry.native.toLowerCase().includes(needle) ||
        entry.english.toLowerCase().includes(needle) ||
        entry.code.toLowerCase().includes(needle) ||
        entry.code === normalizedNeedle
    )
  }, [locales, query])

  return (
    <div className="space-y-2">
      <div className="relative">
        <Search
          aria-hidden="true"
          className="pointer-events-none absolute inset-y-0 start-3 my-auto h-4 w-4 text-muted-foreground"
        />
        <input
          type="search"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder={t('settings.languageSearch')}
          aria-label={t('settings.languageSearch')}
          className="w-full h-11 rounded-md border border-border bg-background ps-9 pe-3 text-base text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-primary"
        />
      </div>

      {filtered.length === 0 ? (
        <p className="px-1 py-3 text-sm text-muted-foreground">
          {t('settings.languageNoMatch', { query })}
        </p>
      ) : (
        <ul
          // 43 rows in a bounded scroll area keeps the settings tab from becoming
          // a 43-row page, and the listbox role tells a screen reader what it is.
          role="listbox"
          aria-label={t('settings.language')}
          className="max-h-72 overflow-y-auto rounded-md border border-border divide-y divide-border"
        >
          {filtered.map((entry) => {
            const selected = entry.code === locale
            return (
              <li key={entry.code}>
                <button
                  type="button"
                  role="option"
                  aria-selected={selected}
                  onClick={() => {
                    void setLocale(entry.code)
                  }}
                  className={cn(
                    'flex w-full items-center justify-between gap-3 px-3 py-2.5 text-start transition-colors',
                    selected ? 'bg-primary/10 text-foreground' : 'hover:bg-muted'
                  )}
                >
                  <span className="min-w-0">
                    <span
                      // The label, not the row: an RTL endonym inside an LTR list
                      // must be shaped RTL, but must not drag the row's padding.
                      dir={entry.rtl ? 'rtl' : undefined}
                      className="block truncate text-sm font-medium text-foreground"
                    >
                      {entry.native}
                    </span>
                    <span className="block truncate text-xs text-muted-foreground">
                      {entry.english}
                    </span>
                  </span>
                  {selected && <Check aria-hidden="true" className="h-4 w-4 shrink-0 text-primary" />}
                </button>
              </li>
            )
          })}
        </ul>
      )}

      {/* Arabic, Hebrew and Urdu mirror the interface; say so rather than let it
          look like a bug. Keyed off the resolved language, not the picker. */}
      {current.rtl && (
        <p className="px-1 text-xs text-muted-foreground">{t('language.rtlNote')}</p>
      )}

      {/* An explicit choice is sticky; this is the only way back to "follow the
          device", so it disappears once there is nothing to clear. */}
      {hasExplicitChoice && (
        <button
          type="button"
          onClick={() => {
            clearExplicit()
          }}
          className="w-full rounded-md px-1 py-2 text-start text-sm text-muted-foreground transition-colors hover:text-foreground"
        >
          {t('language.useDeviceLanguage')}
        </button>
      )}
    </div>
  )
}

export default LanguageSwitcher
