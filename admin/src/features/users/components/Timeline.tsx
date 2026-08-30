import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { formatDateTimeValue } from '@/shared/lib/formatters'
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
  ].sort((a, b) =>
    String(stringValue(b, 'created_at') ?? '').localeCompare(String(stringValue(a, 'created_at') ?? '')),
  )

  const filtered =
    (tab === 'all' ? merged : merged.filter((row) => row._kind === tab)).slice(0, 60)

  return (
    <Card>
      <CardHeader className="flex-row items-center justify-between py-2">
        <CardTitle className="text-sm">{t('detail.timeline')}</CardTitle>
        <Tabs value={tab} onValueChange={(v) => setTab(v as TimelineTab)}>
          <TabsList className="h-7">
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
                  {row._kind}
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
                  {formatDateTimeValue(stringValue(row, 'created_at'))}
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
