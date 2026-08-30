import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { formatDateTimeValue } from '@/shared/lib/formatters'
import { Badge } from '@/shared/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { Tabs, TabsList, TabsTrigger } from '@/shared/ui/tabs'

type TimelineTab = 'all' | 'audits' | 'jobs' | 'imports' | 'tickets'

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
  const merged: (JsonRecord & { _kind: string })[] = [
    ...auditEvents.map((r) => ({ ...r, _kind: 'audits' })),
    ...recentJobs.map((r) => ({ ...r, _kind: 'jobs' })),
    ...socialImportJobs.map((r) => ({ ...r, _kind: 'imports' })),
    ...supportTickets.map((r) => ({ ...r, _kind: 'tickets' })),
  ]
    .sort((a, b) =>
      String((a as JsonRecord)['created_at'] as string | undefined ?? '').localeCompare(
        String((b as JsonRecord)['created_at'] as string | undefined ?? ''),
      ),
    )
    .slice(0, 60)

  const filtered =
    tab === 'all' ? merged : merged.filter((r) => (r as unknown as Record<string, unknown>)['_kind'] === tab)

  return (
    <Card>
      <CardHeader className="flex-row items-center justify-between py-2">
        <CardTitle className="text-sm">{t('detail.timeline', { defaultValue: 'Activity timeline' })}</CardTitle>
        <Tabs value={tab} onValueChange={(v) => setTab(v as TimelineTab)}>
          <TabsList className="h-7">
            <TabsTrigger value="all" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersAll', { defaultValue: 'All' })}
            </TabsTrigger>
            <TabsTrigger value="audits" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersAudits', { defaultValue: 'Audits' })}
            </TabsTrigger>
            <TabsTrigger value="jobs" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersJobs', { defaultValue: 'Jobs' })}
            </TabsTrigger>
            <TabsTrigger value="imports" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersImports', { defaultValue: 'Imports' })}
            </TabsTrigger>
            <TabsTrigger value="tickets" className="px-2.5 py-0.5 text-xs">
              {t('detail.timelineFiltersTickets', { defaultValue: 'Tickets' })}
            </TabsTrigger>
          </TabsList>
        </Tabs>
      </CardHeader>
      <CardContent className="py-2">
        {filtered.length === 0 ? (
          <p className="py-3 text-sm text-muted-foreground">{t('detail.timelineEmpty', { defaultValue: 'No activity yet' })}</p>
        ) : (
          <ol className="divide-y divide-border">
            {filtered.map((row, index) => (
              <li key={stringValue(row as JsonRecord, 'id') ?? `tl-${index}`} className="flex items-center gap-3 py-1.5">
                <Badge variant="secondary" className="shrink-0 text-[10px]">
                  {String((row as Record<string, unknown>)['_kind'])}
                </Badge>
                <span className="min-w-0 flex-1 truncate text-sm text-ink">
                  {stringValue(row as JsonRecord, 'job_type') ??
                    stringValue(row as JsonRecord, 'action') ??
                    stringValue(row as JsonRecord, 'status') ??
                    stringValue(row as JsonRecord, 'subject') ??
                    '—'}
                </span>
                <time className="whitespace-nowrap text-xs text-muted-foreground">
                  {formatDateTimeValue((row as Record<string, unknown>)['created_at'] as string | null | undefined)}
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
