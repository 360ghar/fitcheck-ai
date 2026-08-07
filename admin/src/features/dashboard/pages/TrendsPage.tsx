import { lazy, Suspense } from 'react'
import { useTranslation } from 'react-i18next'
import { useSearchParams } from 'react-router-dom'

import { useTrendsQuery } from '@/features/dashboard/api/dashboard'
import { normalizeError } from '@/shared/api/errors'
import { pickNumber, pickString } from '@/shared/lib/json'
import { ErrorState } from '@/shared/ui/ErrorState'
import { PageHeader } from '@/shared/ui/PageHeader'
import { Skeleton } from '@/shared/ui/skeleton'
import { Tabs, TabsList, TabsTrigger } from '@/shared/ui/tabs'

const TrendsCharts = lazy(() =>
  import('@/features/dashboard/components/TrendsCharts').then((m) => ({
    default: m.TrendsCharts,
  })),
)

/** Windows the backend supports (admin_service.TREND_DAYS_CHOICES). */
const TREND_DAYS = [7, 15, 30, 90] as const
type TrendDays = (typeof TREND_DAYS)[number]

function parseDays(value: string | null): TrendDays {
  const parsed = Number(value)
  return (TREND_DAYS as readonly number[]).includes(parsed) ? (parsed as TrendDays) : 30
}

/**
 * Daily trends page (UX v2): four charts over a 30/90-day window. The window
 * lives in the URL (`?days=90`) so it survives refresh and back/forward.
 */
export function TrendsPage() {
  const { t } = useTranslation('dashboard')
  const [searchParams, setSearchParams] = useSearchParams()
  const days = parseDays(searchParams.get('days'))
  const trends = useTrendsQuery(days)

  const setDays = (value: TrendDays): void => {
    const next = new URLSearchParams(searchParams)
    if (value === 30) {
      next.delete('days')
    } else {
      next.set('days', String(value))
    }
    setSearchParams(next, { replace: true })
  }

  const data = trends.data

  // The schema types the series rows as `{[key: string]: unknown}` — read
  // every field defensively (same convention as the rest of the dashboard).
  const signups = (data?.signups ?? []).map((row) => ({
    day: pickString(row, 'day') ?? '',
    count: pickNumber(row, 'count') ?? 0,
  }))
  const jobs = (data?.jobs ?? []).map((row) => ({
    day: pickString(row, 'day') ?? '',
    total: pickNumber(row, 'total') ?? 0,
    succeeded: pickNumber(row, 'succeeded') ?? 0,
    failed: pickNumber(row, 'failed') ?? 0,
  }))
  const paid = (data?.paid ?? []).map((row) => ({
    day: pickString(row, 'day') ?? '',
    provider: pickString(row, 'provider') ?? 'iap',
    count: pickNumber(row, 'count') ?? 0,
  }))
  const active = (data?.active ?? []).map((row) => ({
    day: pickString(row, 'day') ?? '',
    count: pickNumber(row, 'count') ?? 0,
  }))

  const labels = {
    signups: t('trends.charts.signups'),
    jobs: t('trends.charts.jobs'),
    jobsHint: t('trends.charts.jobsHint'),
    paid: t('trends.charts.paid'),
    paidHint: t('trends.charts.paidHint'),
    active: t('trends.charts.active'),
    activeHint: t('trends.charts.activeHint'),
    succeeded: t('charts.succeeded'),
    failed: t('charts.failed'),
    stripe: t('revenue.mrrStripe'),
    iap: t('revenue.mrrIap'),
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title={t('trends.title')}
        description={t('trends.description')}
        actions={
          <Tabs value={String(days)} onValueChange={(value) => setDays(parseDays(value))}>
            <TabsList className="h-8">
              <TabsTrigger value="7" className="px-3 py-1 text-xs">
                {t('trends.last7Days')}
              </TabsTrigger>
              <TabsTrigger value="15" className="px-3 py-1 text-xs">
                {t('trends.last15Days')}
              </TabsTrigger>
              <TabsTrigger value="30" className="px-3 py-1 text-xs">
                {t('trends.last30Days')}
              </TabsTrigger>
              <TabsTrigger value="90" className="px-3 py-1 text-xs">
                {t('trends.last90Days')}
              </TabsTrigger>
            </TabsList>
          </Tabs>
        }
      />

      {trends.isPending ? (
        <div className="grid gap-4 lg:grid-cols-2" aria-hidden="true">
          {Array.from({ length: 4 }, (_, index) => (
            <div key={`trends-skeleton-${index}`} className="rounded-md border border-border p-3">
              <Skeleton className="h-4 w-32" />
              <Skeleton className="mt-3 h-52 w-full" />
            </div>
          ))}
        </div>
      ) : trends.isError || !data ? (
        <ErrorState
          message={normalizeError(trends.error).message}
          onRetry={() => void trends.refetch()}
        />
      ) : (
        <Suspense
          fallback={
            <div className="grid gap-4 lg:grid-cols-2" aria-hidden="true">
              {Array.from({ length: 4 }, (_, index) => (
                <Skeleton key={`trends-chunk-${index}`} className="h-64 w-full" />
              ))}
            </div>
          }
        >
          <TrendsCharts
            signups={signups}
            jobs={jobs}
            paid={paid}
            active={active}
            labels={labels}
          />
        </Suspense>
      )}
    </div>
  )
}
