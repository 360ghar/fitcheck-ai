import { useQuery } from '@tanstack/react-query'
import {
  FileText,
  MessageSquare,
  Search,
  Tag,
  User,
  type LucideIcon,
} from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useNavigate } from 'react-router-dom'

import { searchAll } from '@/features/search/api/search'
import { firstString, resultKey, resultString } from '@/features/search/lib/results'
import { useDebounce } from '@/shared/hooks/useDebounce'
import { QUERY_STALE_TIMES, SEARCH_DEBOUNCE_MS } from '@/shared/lib/constants'
import { pickBoolean, type JsonRecord } from '@/shared/lib/json'
import { useCommandStore } from '@/shared/stores/commandStore'
import {
  CommandDialog,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
  CommandShortcut,
} from '@/shared/ui/command'
import { Kbd } from '@/shared/ui/kbd'

interface SearchGroupItem {
  key: string
  id: string
  label: string
  sub: string
  path: string
  icon: LucideIcon
}

interface SearchGroup {
  key: string
  heading: string
  items: SearchGroupItem[]
}

/**
 * Global command palette (⌘K / Ctrl+K). Hits GET /api/v1/admin/search with a
 * debounced query (min 2 chars), groups results by type, and navigates on
 * select. Result rows are schema-typed `{[key: string]: unknown}` dicts — all
 * rendering goes through defensive accessors (id/email/title heuristics).
 * cmdk owns the keyboard UX; graceful empty/loading/error states are
 * i18n-driven.
 */
export function CommandPalette() {
  const { t } = useTranslation('search')
  const open = useCommandStore((state) => state.open)
  const setOpen = useCommandStore((state) => state.setOpen)
  const navigate = useNavigate()
  const [query, setQuery] = useState('')
  const debouncedQuery = useDebounce(query, SEARCH_DEBOUNCE_MS)
  const trimmed = debouncedQuery.trim()

  const searchQuery = useQuery({
    queryKey: ['search', trimmed],
    queryFn: () => searchAll(trimmed),
    enabled: trimmed.length >= 2,
    staleTime: QUERY_STALE_TIMES.lists,
  })

  useEffect(() => {
    if (!open) {
      setQuery('')
    }
  }, [open])

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent): void => {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') {
        event.preventDefault()
        setOpen(!open)
      }
    }
    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [open, setOpen])

  const groups = useMemo<SearchGroup[]>(() => {
    const results = searchQuery.data
    if (!results) return []
    const out: SearchGroup[] = []

    const users = (results.users ?? []) as JsonRecord[]
    if (users.length > 0) {
      out.push({
        key: 'users',
        heading: t('groups.users'),
        items: users.map((row, index) => {
          const name = firstString(row, ['full_name', 'email'])
          const email = resultString(row, 'email')
          return {
            key: 'users',
            id: resultKey(row, index),
            label: name ?? t('fallbacks.noEmail'),
            sub: email && email !== name ? email : (resultString(row, 'role') ?? ''),
            path: `/users/${resultString(row, 'id') ?? ''}`,
            icon: User,
          }
        }),
      })
    }

    const posts = (results.posts ?? []) as JsonRecord[]
    if (posts.length > 0) {
      out.push({
        key: 'posts',
        heading: t('groups.posts'),
        items: posts.map((row, index) => ({
          key: 'posts',
          id: resultKey(row, index),
          label: resultString(row, 'title') ?? t('fallbacks.untitled'),
          sub: resultString(row, 'category') ?? '',
          path: '/content/posts',
          icon: FileText,
        })),
      })
    }

    const tickets = (results.tickets ?? []) as JsonRecord[]
    if (tickets.length > 0) {
      out.push({
        key: 'tickets',
        heading: t('groups.tickets'),
        items: tickets.map((row, index) => ({
          key: 'tickets',
          id: resultKey(row, index),
          label: resultString(row, 'subject') ?? t('fallbacks.noSubject'),
          sub: resultString(row, 'status') ?? '',
          path: '/feedback',
          icon: MessageSquare,
        })),
      })
    }

    const promoCodes = (results.promo_codes ?? []) as JsonRecord[]
    if (promoCodes.length > 0) {
      out.push({
        key: 'promoCodes',
        heading: t('groups.promoCodes'),
        items: promoCodes.map((row, index) => ({
          key: 'promoCodes',
          id: resultKey(row, index),
          label: resultString(row, 'code') ?? t('fallbacks.untitled'),
          sub:
            (resultString(row, 'plan_type') ?? '') +
            (pickBoolean(row, 'active') === false ? ` · ${t('inactive')}` : ''),
          path: '/promo',
          icon: Tag,
        })),
      })
    }

    return out
  }, [searchQuery.data, t])

  const hasResults = groups.length > 0

  function go(path: string): void {
    setOpen(false)
    void navigate(path)
  }

  // The cmdk listbox (`role="listbox"`) stays mounted so the input's
  // aria-controls always resolves, but is `hidden` whenever it has no option
  // children (hint/loading/error/empty states) — axe's
  // aria-required-children (WCAG 2.1 AA) then skips it, and screen readers
  // never encounter an empty listbox. Status copy renders in its place.
  const showList = trimmed.length >= 2 && !searchQuery.isPending && !searchQuery.isError && hasResults

  return (
    <CommandDialog open={open} onOpenChange={setOpen} label={t('dialogLabel')}>
      <CommandInput
        value={query}
        onValueChange={setQuery}
        placeholder={t('placeholder')}
        aria-label={t('ariaLabel')}
      />
      <CommandList hidden={!showList}>
        {showList
          ? groups.map((group) => (
              <CommandGroup key={group.key} heading={group.heading}>
                {group.items.map((item) => (
                  <CommandItem
                    key={`${group.key}-${item.id}`}
                    value={`${item.key}:${item.label}`}
                    onSelect={() => go(item.path)}
                  >
                    <item.icon className="text-muted-foreground" aria-hidden="true" />
                    <span className="truncate">{item.label}</span>
                    {item.sub ? <CommandShortcut>{item.sub}</CommandShortcut> : null}
                  </CommandItem>
                ))}
              </CommandGroup>
            ))
          : null}
      </CommandList>
      {!showList ? (
        <div className="py-6 text-center text-sm text-muted-foreground">
          {trimmed.length < 2 ? (
            <>
              <Search className="mx-auto mb-2 size-5 text-muted-foreground" aria-hidden="true" />
              {t('typeHint')}
            </>
          ) : searchQuery.isPending ? (
            t('common:loading')
          ) : searchQuery.isError ? (
            t('error')
          ) : (
            t('empty', { query: trimmed })
          )}
        </div>
      ) : null}
      <CommandSeparator />
      <div className="flex items-center gap-4 px-3 py-2 text-xs text-muted-foreground">
        <span className="inline-flex items-center gap-1">
          <Kbd>↑↓</Kbd>
          {t('hintNavigate')}
        </span>
        <span className="inline-flex items-center gap-1">
          <Kbd>↵</Kbd>
          {t('hintSelect')}
        </span>
        <span className="inline-flex items-center gap-1">
          <Kbd>esc</Kbd>
          {t('hintClose')}
        </span>
      </div>
    </CommandDialog>
  )
}
