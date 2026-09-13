import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { formatDateTimeValue, toDate } from '@/shared/lib/formatters'
import { Badge } from '@/shared/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { Tabs, TabsList, TabsTrigger } from '@/shared/ui/tabs'

type TimelineTab = 'all' | 'audits' | 'jobs' | 'imports' | 'tickets'
type TimelineKind = Exclude<TimelineTab, 'all'>
type TimelineRow = JsonRecord & { _kind: TimelineKind }

function withKind(rows: JsonRecord[], kind: TimelineKind): TimelineRow[] {
  return rows.map((row) => ({ ...row, _kind: kind }))
}

export function Timeline({
  auditEvents,
  recentJobs,
  socialImportJobs,
  supportTickets,
}: {
  auditEvents: JsonRecord[]
  recentJobs: JsonRecord[]
  socialImportJobs: JsonRecord[]
  supportTickets: JsonRecord[]
}) {
  const { t } = useTranslation('users')
  const [tab, setTab] = useState<TimelineTab>('all')
  const merged: TimelineRow[] = [
    ...withKind(auditEvents, 'audits'),
    ...withKind(recentJobs, 'jobs'),
    ...withKind(socialImportJobs, 'imports'),
    ...withKind(supportTickets, 'tickets'),
  ].sort((a, b) => {
    // Parse the raw values (created_at can be a string OR a number) and sort
    // newest-first; rows without a parseable date sort last.
    const aTime = toDate(a['created_at'])?.getTime() ?? Number.NEGATIVE_INFINITY
    const bTime = toDate(b['created_at'])?.getTime() ?? Number.NEGATIVE_INFINITY
    return bTime - aTime
  })

  const filtered =
    (tab === 'all' ? merged : merged.filter((row) => row._kind === tab)).slice(0, 60)

  return (
    <Card>
      <CardHeader className="flex-wrap items-center justify-between gap-2 py-2">
        <CardTitle className="text-sm">{t('detail.timeline')}</CardTitle>
        <Tabs value={tab} onValueChange={(v) => setTab(v as TimelineTab)}>
          <TabsList className="h-7 max-w-full flex-wrap">
            <TabsTrigger value="all" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersAll')}
            </TabsTrigger>
            <TabsTrigger value="audits" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersAudits')}
            </TabsTrigger>
            <TabsTrigger value="jobs" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersJobs')}
            </TabsTrigger>
            <TabsTrigger value="imports" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersImports')}
            </TabsTrigger>
            <TabsTrigger value="tickets" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersTickets')}
            </TabsTrigger>
          </TabsList>
        </Tabs>
      </CardHeader>
      <CardContent className="py-2">
        {filtered.length === 0 ? (
          <p className="py-3 text-sm text-muted-foreground">{t('detail.timelineEmpty')}</p>
        ) : (
          <ol className="divide-y divide-border">
            {filtered.map((row, index) => (
              <li key={stringValue(row, 'id') ?? `tl-${index}`} className="flex items-center gap-3 py-1.5">
                <Badge variant="secondary" className="shrink-0 text-[10px]">
                  {t(`detail.timelineFilters${row._kind.charAt(0).toUpperCase()}${row._kind.slice(1)}`, {
                    defaultValue: row._kind,
                  })}
                </Badge>
                <span className="min-w-0 flex-1 truncate text-sm text-ink">
                  {stringValue(row, 'job_type') ??
                    stringValue(row, 'use_case') ??
                    stringValue(row, 'action') ??
                    stringValue(row, 'status') ??
                    stringValue(row, 'subject') ??
                    '—'}
                </span>
                <time className="whitespace-nowrap text-xs text-muted-foreground">
                  {formatDateTimeValue(row['created_at'])}
                </time>
              </li>
            ))}
          </ol>
        )}
      </CardContent>
    </Card>
  )
}

export default Timeline
