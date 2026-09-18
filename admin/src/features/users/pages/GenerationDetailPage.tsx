import { ArrowLeft, Copy, ExternalLink, ImageIcon } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useParams } from 'react-router-dom'
import { toast } from 'sonner'

import { useGenerationQuery, useUserDetailQuery } from '@/features/users/api/users'
import {
  formatDuration,
  generationKindLabelKey,
  generationStatusLabelKey,
  mediaList,
  metaRows,
  parseGenerationKind,
} from '@/features/users/lib/generations'
import { displayName, stringValue, type JsonRecord } from '@/features/users/lib/users'
import { normalizeError } from '@/shared/api/errors'
import { formatDateTimeValue } from '@/shared/lib/formatters'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { Skeleton } from '@/shared/ui/skeleton'
import { StatusBadge } from '@/shared/ui/StatusBadge'

/**
 * Full-page generation viewer (`/users/:id/generations/:kind/:generationId`).
 * Shows every generated image of one generation run plus its metadata,
 * kind-specific breakdowns (extracted items / imported photos), and the raw
 * source identifiers so support can trace the run back to its tables.
 */
export function GenerationDetailPage() {
  const { id, kind, generationId } = useParams<{
    id: string
    kind: string
    generationId: string
  }>()
  const userId = id ?? ''
  const parsedKind = parseGenerationKind(kind)
  const { t } = useTranslation('users')

  const detailQuery = useGenerationQuery(userId, kind ?? '', generationId ?? '', {
    enabled: userId !== '' && parsedKind !== null && (generationId ?? '') !== '',
  })
  const userQuery = useUserDetailQuery(userId, { enabled: userId !== '' })

  if (parsedKind === null) {
    return (
      <div className="space-y-3">
        <BackLink userId={userId} />
        <EmptyState title={t('detail.genNotFoundTitle')} message={t('detail.genNotFoundMessage')} />
      </div>
    )
  }

  if (detailQuery.isPending) {
    return (
      <div className="space-y-3">
        <BackLink userId={userId} />
        <Card>
          <CardHeader>
            <Skeleton className="h-6 w-56" />
          </CardHeader>
          <CardContent className="space-y-2">
            <Skeleton className="h-64 w-full" />
            <Skeleton className="h-4 w-2/3" />
            <Skeleton className="h-4 w-1/2" />
          </CardContent>
        </Card>
      </div>
    )
  }

  if (detailQuery.isError) {
    const apiError = normalizeError(detailQuery.error)
    return (
      <div className="space-y-3">
        <BackLink userId={userId} />
        {apiError.code === 'NOT_FOUND' ? (
          <EmptyState title={t('detail.genNotFoundTitle')} message={t('detail.genNotFoundMessage')} />
        ) : (
          <ErrorState message={apiError.message} onRetry={() => void detailQuery.refetch()} />
        )}
      </div>
    )
  }

  const generation = detailQuery.data
  const meta = generation.meta ?? {}
  const status = generation.status
  const duration = formatDuration(generation.duration_ms)
  const userName = displayName(
    (userQuery.data as Record<string, unknown> | undefined)?.['user'] as JsonRecord | undefined,
  )

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <BackLink userId={userId} name={userName} />
        <div className="flex flex-wrap items-center gap-2">
          <Badge variant="secondary">{t(generationKindLabelKey(parsedKind))}</Badge>
          {status ? (
            <StatusBadge
              status={status === 'complete' ? 'completed' : status}
              label={t(generationStatusLabelKey(status), { defaultValue: status })}
            />
          ) : null}
        </div>
      </div>

      <Card>
        <CardHeader>
          {/* Page title is a real heading (UserDetailPage uses h1 the same
              way); section cards below keep CardTitle. */}
          <h1 className="text-lg font-semibold leading-none tracking-tight">
            {generation.title || t(generationKindLabelKey(parsedKind))}
          </h1>
          {generation.subtitle ? <CardDescription>{generation.subtitle}</CardDescription> : null}
        </CardHeader>
        <CardContent className="space-y-3">
          {generation.error ? (
            <div
              role="alert"
              className="rounded-md border border-destructive/30 bg-destructive/5 px-3 py-2 text-sm text-destructive"
            >
              <p className="font-medium">{t('detail.genErrorTitle')}</p>
              <p className="mt-0.5 break-words">{generation.error}</p>
            </div>
          ) : null}

          <MediaGallery
            key={`${stringValue(generation, 'kind') ?? ''}:${stringValue(generation, 'id') ?? ''}`}
            generation={generation}
          />

          <dl className="divide-y divide-border">
            <Field label={t('detail.createdAt')} value={formatDateTimeValue(generation.created_at)} />
            <Field
              label={t('detail.jobCompleted')}
              value={formatDateTimeValue(generation.completed_at)}
            />
            {duration ? <Field label={t('detail.genDuration')} value={duration} /> : null}
            {metaRows(generation).map((row) => (
              <Field
                key={row.key}
                label={t(`detail.genMeta_${row.key}`, { defaultValue: row.key.replaceAll('_', ' ') })}
                value={formatMetaValue(row.value)}
              />
            ))}
          </dl>

          <SourceIds generation={generation} />
        </CardContent>
      </Card>

      {Array.isArray(meta['items']) && (meta['items'] as unknown[]).length > 0 ? (
        <Card>
          <CardHeader className="py-2">
            <CardTitle className="text-sm">{t('detail.genExtractedItems')}</CardTitle>
          </CardHeader>
          <CardContent className="py-2">
            <ul className="divide-y divide-border">
              {(meta['items'] as JsonRecord[]).map((item, index) => (
                <li
                  key={`${stringValue(item, 'name') ?? 'item'}-${index}`}
                  className="flex items-center justify-between gap-3 py-1.5"
                >
                  <span className="min-w-0 truncate text-sm text-ink">
                    {stringValue(item, 'name') ?? '—'}
                  </span>
                  <span className="shrink-0 text-xs text-muted-foreground">
                    {stringValue(item, 'category') ?? ''}
                  </span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      ) : null}

      {Array.isArray(meta['photos']) && (meta['photos'] as unknown[]).length > 0 ? (
        <Card>
          <CardHeader className="py-2">
            <CardTitle className="text-sm">{t('detail.genImportPhotos')}</CardTitle>
          </CardHeader>
          <CardContent className="py-2">
            <ul className="divide-y divide-border">
              {(meta['photos'] as JsonRecord[]).map((photo) => (
                <li
                  key={stringValue(photo, 'id') ?? (typeof photo['ordinal'] === 'number' ? String(photo['ordinal']) : stringValue(photo, 'ordinal')) ?? 'photo'}
                  className="flex items-center justify-between gap-3 py-1.5"
                >
                  <span className="text-sm text-ink">
                    {t('detail.genPhotoOrdinal', {
                      ordinal:
                        typeof photo['ordinal'] === 'number'
                          ? String(photo['ordinal'])
                          : (stringValue(photo, 'ordinal') ?? '—'),
                    })}
                  </span>
                  <StatusBadge
                    status={stringValue(photo, 'status') ?? ''}
                    label={stringValue(photo, 'status') ?? '—'}
                  />
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      ) : null}
    </div>
  )
}

function BackLink({ userId, name }: { userId: string; name?: string }) {
  const { t } = useTranslation('users')
  return (
    <Button variant="outline" size="sm" asChild>
      <Link to={`/users/${userId}`}>
        <ArrowLeft aria-hidden="true" />
        {name ? t('detail.genBackTo', { name }) : t('back')}
      </Link>
    </Button>
  )
}

function Field({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-4 py-1.5">
      <dt className="text-xs text-muted-foreground">{label}</dt>
      <dd className="max-w-[60%] break-words text-right text-xs font-medium text-ink">{value}</dd>
    </div>
  )
}

function formatMetaValue(value: unknown): React.ReactNode {
  if (typeof value === 'boolean') return value ? '✓' : '—'
  if (typeof value === 'number') return String(value)
  if (Array.isArray(value)) {
    if (value.length === 0) return '—'
    if (
      value.every(
        (entry) => typeof entry === 'string' || typeof entry === 'number' || typeof entry === 'boolean',
      )
    ) {
      return value.map(String).join(', ')
    }
    return JSON.stringify(value)
  }
  if (typeof value === 'string') {
    if (/^https?:\/\//.test(value)) {
      return (
        <a
          href={value}
          target="_blank"
          rel="noreferrer"
          className="inline-flex items-center gap-1 break-all text-primary underline-offset-4 hover:underline"
        >
          {value}
          <ExternalLink className="size-3 shrink-0" aria-hidden="true" />
        </a>
      )
    }
    return value
  }
  return JSON.stringify(value)
}

function SourceIds({ generation }: { generation: JsonRecord }) {
  const { t } = useTranslation('users')
  const source = (generation['source'] && typeof generation['source'] === 'object'
    ? generation['source']
    : {}) as JsonRecord
  const meta = (generation['meta'] ?? {}) as JsonRecord
  const outfitId = stringValue(meta, 'outfit_id')
  const ids: Array<[string, string]> = [
    [t('detail.genSourceTable'), stringValue(source, 'table') ?? '—'],
    [t('detail.genSourceId'), stringValue(source, 'id') ?? '—'],
  ]
  if (outfitId) {
    ids.push([t('detail.genMeta_outfit_id'), outfitId])
  }
  return (
    <div className="space-y-1 rounded-md border border-border bg-surface-card px-3 py-2">
      {ids.map(([label, value]) => (
        <div key={label} className="flex items-center justify-between gap-3 text-xs">
          <span className="text-muted-foreground">{label}</span>
          <span className="flex min-w-0 items-center gap-1">
            <code className="min-w-0 truncate font-mono text-ink">{value}</code>
            <Button
              variant="ghost"
              size="icon"
              className="size-6"
              aria-label={t('detail.genCopyId', { value })}
              onClick={() => {
                const clipboard =
                  typeof navigator !== 'undefined' ? navigator.clipboard : undefined
                if (!clipboard) {
                  toast.error(normalizeError(new Error('Clipboard unavailable')).message)
                  return
                }
                clipboard
                  .writeText(value)
                  .then(() => toast.success(t('detail.genCopyIdToast')))
                  .catch((error: unknown) => toast.error(normalizeError(error).message))
              }}
            >
              <Copy className="size-3" aria-hidden="true" />
            </Button>
          </span>
        </div>
      ))}
    </div>
  )
}

function MediaGallery({ generation }: { generation: JsonRecord }) {
  const { t } = useTranslation('users')
  const media = mediaList(generation)
  const [selected, setSelected] = useState(0)
  const [broken, setBroken] = useState<Set<number>>(new Set())

  if (media.length === 0) {
    return (
      <div className="flex h-48 w-full items-center justify-center rounded-md border border-border bg-surface-card text-muted-foreground">
        <span className="flex items-center gap-2 text-sm">
          <ImageIcon className="size-4" aria-hidden="true" />
          {t('detail.genNoMedia')}
        </span>
      </div>
    )
  }

  const activeIndex = Math.min(selected, media.length - 1)
  const active = media[activeIndex]
  if (!active) return null
  const activeBroken = broken.has(activeIndex)

  return (
    <div className="space-y-2">
      <div className="flex h-72 items-center justify-center overflow-hidden rounded-md border border-border bg-surface-card">
        {activeBroken ? (
          <span className="px-4 text-center text-xs text-muted-foreground">
            {t('detail.genMediaUnavailable')}
          </span>
        ) : (
          <img
            src={active.url}
            alt={active.label ?? ''}
            className="max-h-72 w-auto max-w-full object-contain"
            onError={() =>
              setBroken((prev) => new Set(prev).add(activeIndex))
            }
          />
        )}
      </div>
      {media.length > 1 ? (
        <div className="flex gap-1.5 overflow-x-auto pb-1">
          {media.map((entry, index) => (
            <button
              key={`${entry.url}-${index}`}
              type="button"
              onClick={() => setSelected(index)}
              aria-label={t('detail.genSelectMedia', { index: index + 1 })}
              aria-current={index === activeIndex}
              className={`h-14 w-14 shrink-0 overflow-hidden rounded-md border focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring ${
                index === activeIndex ? 'border-primary' : 'border-border'
              }`}
            >
              {broken.has(index) ? (
                <span className="flex h-full w-full items-center justify-center bg-surface-card">
                  <ImageIcon className="size-3 text-muted-foreground" aria-hidden="true" />
                </span>
              ) : (
                <img
                  src={entry.thumbUrl || entry.url}
                  alt={entry.label ?? ''}
                  className="h-full w-full object-cover"
                  loading="lazy"
                  onError={(event) => {
                    // A dead thumbnail must not condemn the full image: retry
                    // the full URL first, mark broken only when that fails too.
                    if (entry.thumbUrl && event.currentTarget.src !== entry.url) {
                      event.currentTarget.src = entry.url
                    } else {
                      setBroken((prev) => new Set(prev).add(index))
                    }
                  }}
                />
              )}
            </button>
          ))}
        </div>
      ) : null}
      <div className="flex items-center justify-between text-xs text-muted-foreground">
        <span>{active.label ?? t('detail.genMediaNth', { index: activeIndex + 1 })}</span>
        <a
          href={active.url}
          target="_blank"
          rel="noreferrer"
          className="inline-flex items-center gap-1 text-primary underline-offset-4 hover:underline"
        >
          {t('detail.genOpenOriginal')}
          <ExternalLink className="size-3" aria-hidden="true" />
        </a>
      </div>
    </div>
  )
}

export default GenerationDetailPage
