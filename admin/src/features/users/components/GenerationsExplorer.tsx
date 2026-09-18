import { ChevronLeft, ChevronRight, ImageIcon } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { useNavigate, useSearchParams } from 'react-router-dom'

import { useUserGenerationsQuery } from '@/features/users/api/users'
import {
  GENERATION_KINDS,
  GENERATION_STATUSES,
  generationKindLabelKey,
  generationStatusLabelKey,
  generationTabLabelKey,
  mediaList,
} from '@/features/users/lib/generations'
import type { AdminUserGeneration } from '@/shared/api/schemaTypes'
import { formatDateTimeValue } from '@/shared/lib/formatters'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/shared/ui/select'
import { Skeleton } from '@/shared/ui/skeleton'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import { Tabs, TabsList, TabsTrigger } from '@/shared/ui/tabs'

const PAGE_SIZE = 12

/**
 * Generations explorer for one user — every AI generation kind in one
 * paginated gallery. Tab / status filter / page live in the URL
 * (`gen_tab`, `gen_status`, `gen_page`) so views are deep-linkable and
 * refresh-stable, matching the console's URL-is-table-state rule.
 */
export function GenerationsExplorer({ userId }: { userId: string }) {
  const { t } = useTranslation('users')
  const [searchParams, setSearchParams] = useSearchParams()

  const rawTab = searchParams.get('gen_tab') ?? 'all'
  const tab = (GENERATION_KINDS as readonly string[]).includes(rawTab) ? rawTab : 'all'
  const rawStatus = searchParams.get('gen_status') ?? ''
  const status = (GENERATION_STATUSES as readonly string[]).includes(rawStatus) ? rawStatus : ''
  const parsedPage = Number(searchParams.get('gen_page') ?? '1')
  const page = Number.isInteger(parsedPage) ? Math.max(parsedPage, 1) : 1

  const query = useUserGenerationsQuery(userId, {
    kind: tab,
    status: status || null,
    page,
    pageSize: PAGE_SIZE,
  })

  const items = query.data?.items ?? []
  const total = query.data?.total ?? 0
  const totalPages = Math.max(Math.ceil(total / PAGE_SIZE), 1)
  // Any page past the last one gets recovery buttons — even when the filter
  // matches zero rows (totalPages floors at 1, so `total > 0` would hide them).
  const outOfRange = page > totalPages

  const updateParams = (mutate: (next: URLSearchParams) => void) => {
    setSearchParams((prev) => {
      const next = new URLSearchParams(prev)
      mutate(next)
      return next
    })
  }

  return (
    <Card>
      <CardHeader className="flex-col gap-2 py-2 sm:flex-row sm:flex-wrap sm:items-center sm:justify-between">
        <CardTitle className="text-sm">{t('detail.generationsSection')}</CardTitle>
        <div className="flex flex-wrap items-center gap-2">
          <Tabs
            value={tab}
            onValueChange={(value) =>
              updateParams((next) => {
                next.set('gen_tab', value)
                next.delete('gen_page')
              })
            }
          >
            <TabsList className="h-7 max-w-full flex-wrap">
              <TabsTrigger value="all" className="px-2.5 py-0.5 text-xs">
                {t('detail.genTabsAll')}
              </TabsTrigger>
              {GENERATION_KINDS.map((kind) => (
                <TabsTrigger key={kind} value={kind} className="px-2.5 py-0.5 text-xs">
                  {t(generationTabLabelKey(kind))}
                </TabsTrigger>
              ))}
            </TabsList>
          </Tabs>
          <Select
            value={status || 'all'}
            onValueChange={(value) =>
              updateParams((next) => {
                if (value === 'all') next.delete('gen_status')
                else next.set('gen_status', value)
                next.delete('gen_page')
              })
            }
          >
            <SelectTrigger className="h-7 w-[150px] text-xs" aria-label={t('detail.genStatusFilter')}>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">{t('detail.genStatusAll')}</SelectItem>
              {GENERATION_STATUSES.map((value) => (
                <SelectItem key={value} value={value}>
                  {t(generationStatusLabelKey(value), { defaultValue: value })}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </CardHeader>
      <CardContent className="py-2">
        {query.isError ? (
          <ErrorState message={query.error.message} onRetry={() => void query.refetch()} />
        ) : query.isPending ? (
          <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 lg:grid-cols-4">
            {Array.from({ length: 4 }, (_, i) => (
              <Skeleton key={i} className="h-28 w-full rounded-md" />
            ))}
          </div>
        ) : items.length === 0 ? (
          outOfRange ? (
            <div className="space-y-2 py-3 text-center">
              <EmptyState title={t('detail.genEmpty')} message={t('detail.genPageOutOfRange', { page })} className="py-1" />
              <div className="flex items-center justify-center gap-2">
                {page > 1 ? (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => updateParams((next) => next.set('gen_page', String(page - 1)))}
                  >
                    <ChevronLeft aria-hidden="true" />
                    {t('detail.genPrevPage')}
                  </Button>
                ) : null}
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => updateParams((next) => next.set('gen_page', String(totalPages)))}
                >
                  {t('detail.genBackToLastPage', { total: totalPages })}
                </Button>
              </div>
            </div>
          ) : (
            <EmptyState title={t('detail.genEmpty')} message={t('detail.genEmptyHint')} className="py-3" />
          )
        ) : (
          <>
            <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 lg:grid-cols-4">
              {items.map((item) => (
                <GenerationCard key={`${item.kind}-${item.id}`} userId={userId} item={item} />
              ))}
            </div>
            {totalPages > 1 ? (
              <div className="mt-2 flex items-center justify-between">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page <= 1}
                  onClick={() => updateParams((next) => next.set('gen_page', String(page - 1)))}
                >
                  <ChevronLeft aria-hidden="true" />
                  {t('detail.genPrevPage')}
                </Button>
                <span className="text-xs text-muted-foreground">
                  {t('detail.genPageIndicator', { page, total: totalPages })}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page >= totalPages}
                  onClick={() => updateParams((next) => next.set('gen_page', String(page + 1)))}
                >
                  {t('detail.genNextPage')}
                  <ChevronRight aria-hidden="true" />
                </Button>
              </div>
            ) : null}
          </>
        )}
      </CardContent>
    </Card>
  )
}

function GenerationCard({ userId, item }: { userId: string; item: AdminUserGeneration }) {
  const { t } = useTranslation('users')
  const navigate = useNavigate()
  const kind = item.kind
  const title = item.title || t(generationKindLabelKey(kind))
  const subtitle = item.subtitle
  const status = item.status
  const mediaCount = item.media_count ?? 0
  const failedCount = item.failed_count ?? 0
  const cover = mediaList(item)[0]

  return (
    <button
      type="button"
      onClick={() => navigate(`/users/${userId}/generations/${kind}/${item.id}`)}
      className="group overflow-hidden rounded-md border border-border text-left transition-colors hover:bg-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      aria-label={t('detail.genOpenViewer', { title })}
    >
      {cover ? (
        <img
          src={cover.thumbUrl || cover.url}
          alt={cover.label ?? title}
          className="h-20 w-full object-cover"
          loading="lazy"
        />
      ) : (
        <span className="flex h-20 w-full items-center justify-center bg-surface-card text-muted-foreground">
          <ImageIcon className="size-4" aria-hidden="true" />
        </span>
      )}
      <span className="block space-y-1 px-1.5 py-1">
        <span className="block truncate text-xs font-medium leading-tight text-ink">{title}</span>
        <span className="flex flex-wrap items-center gap-1">
          <Badge variant="secondary" className="text-[10px]">
            {t(generationKindLabelKey(kind))}
          </Badge>
          {status ? (
            <StatusBadge
              status={status === 'complete' ? 'completed' : status}
              label={t(generationStatusLabelKey(status), { defaultValue: status })}
            />
          ) : null}
        </span>
        <span className="flex items-center justify-between gap-1 text-[10px] leading-tight text-muted-foreground">
          <span className="truncate">{subtitle ?? formatDateTimeValue(item.created_at)}</span>
          <span className="whitespace-nowrap">
            {failedCount > 0
              ? t('detail.genFailedCount', { count: failedCount })
              : t('detail.genMediaCount', { count: mediaCount })}
          </span>
        </span>
      </span>
    </button>
  )
}

export default GenerationsExplorer
