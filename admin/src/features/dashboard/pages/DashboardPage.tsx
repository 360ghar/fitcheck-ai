import { useQueryClient } from '@tanstack/react-query'
import { RefreshCw, Trophy, Users } from 'lucide-react'
import { lazy, Suspense, useEffect, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useSearchParams } from 'react-router-dom'

import {
  dashboardKeys,
  useFunnelQuery,
  useOpsHealthQuery,
  useOverviewQuery,
  useRecentAuditQuery,
  useReferralsQuery,
  useRetentionQuery,
  useRevenueQuery,
  useTopUsersQuery,
  useTrendsQuery,
} from '@/features/dashboard/api/dashboard'
import { normalizeError } from '@/shared/api/errors'
import { formatMoney, formatNumber, relativeTimeValue } from '@/shared/lib/formatters'
import { pickArray, pickNumber, pickString, type JsonRecord } from '@/shared/lib/json'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { Skeleton } from '@/shared/ui/skeleton'
import { Tabs, TabsList, TabsTrigger } from '@/shared/ui/tabs'

const OverviewCharts = lazy(() =>
  import('@/features/dashboard/components/OverviewCharts').then((m) => ({
    default: m.OverviewCharts,
  })),
)

const TrendsCharts = lazy(() =>
  import('@/features/dashboard/components/TrendsCharts').then((m) => ({
    default: m.TrendsCharts,
  })),
)

/**
 * Single-page ops-console dashboard (Phase 1a): 7 Card sections stacked.
 * ONE page /dashboard with 7 sections, no new top-level routes, no migrations,
 * reuse existing API plus two new backend keys (trials_ending_7d, tickets_open_48h)
 * and funnel/retention if available else graceful fallback.
 */

const TREND_DAYS = [7, 15, 30, 90] as const
type TrendDays = (typeof TREND_DAYS)[number]

function parseDays(value: string | null): TrendDays {
  const parsed = Number(value)
  return (TREND_DAYS as readonly number[]).includes(parsed) ? (parsed as TrendDays) : 30
}

function pickExtraNumber(record: JsonRecord | null | undefined, keys: string[]): number | null {
  if (!record) return null
  for (const key of keys) {
    const value = pickNumber(record, key)
    if (value !== null) return value
  }
  return null
}

type TopUsersTab = 'outfits' | 'items' | 'referrers'

export function DashboardPage() {
  const { t } = useTranslation('dashboard')
  const queryClient = useQueryClient()
  const [searchParams, setSearchParams] = useSearchParams()

  const overview = useOverviewQuery()
  const revenue = useRevenueQuery()
  const trendsDays = parseDays(searchParams.get('days'))
  const trends = useTrendsQuery(trendsDays)
  const funnel = useFunnelQuery(trendsDays)
  const retention = useRetentionQuery(4)
  const referrals = useReferralsQuery()
  const topUsers = useTopUsersQuery()
  const activity = useRecentAuditQuery()
  const opsHealth = useOpsHealthQuery()

  const setDays = (value: TrendDays): void => {
    const next = new URLSearchParams(searchParams)
    if (value === 30) next.delete('days')
    else next.set('days', String(value))
    setSearchParams(next, { replace: true })
  }

  // Deep-link scroll: ?section=trends|funnel|retention|revenue|referrals|overview|ops → scroll + highlight
  useEffect(() => {
    const section = searchParams.get('section')
    if (!section) return
    // Wait for the 7 cards to mount (including lazy TrendsCharts) then smooth-scroll.
    const id = `section-${section}`
    const timer = window.setTimeout(() => {
      const el = document.getElementById(id)
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }, 300)
    return () => window.clearTimeout(timer)
  }, [searchParams])

  const updatedAt = Math.max(
    overview.dataUpdatedAt,
    revenue.dataUpdatedAt,
    trends.dataUpdatedAt,
    funnel.dataUpdatedAt,
    retention.dataUpdatedAt,
    referrals.dataUpdatedAt,
    topUsers.dataUpdatedAt,
    activity.dataUpdatedAt,
    opsHealth.dataUpdatedAt,
  )

  const handleRefresh = (): void => {
    void queryClient.invalidateQueries({ queryKey: dashboardKeys.all })
  }

  const overviewData = overview.data as unknown as JsonRecord | undefined
  const revenueData = revenue.data as unknown as JsonRecord | undefined
  const referralsData = referrals.data as unknown as JsonRecord | undefined

  const signups = (overviewData?.signups as JsonRecord | undefined) ?? {}
  const activeUsers = (overviewData?.active_users as JsonRecord | undefined) ?? {}
  const aiJobs = (overviewData?.ai_jobs_7d as JsonRecord | undefined) ?? {}
  const signups7d = pickNumber(signups, '7d') ?? 0
  const signups30d = pickNumber(signups, '30d') ?? 0
  const active7d = pickNumber(activeUsers, '7d') ?? 0
  const active30d = pickNumber(activeUsers, '30d') ?? 0
  const paidSubscriptions = pickNumber(overviewData, 'paid_subscriptions') ?? 0
  const aiJobsTotal = pickNumber(aiJobs, 'total') ?? 0
  const aiJobsSucceeded = pickNumber(aiJobs, 'succeeded') ?? 0
  const aiJobsFailed = pickNumber(aiJobs, 'failed') ?? 0
  const trialsEnding7d = overviewData ? pickExtraNumber(overviewData, ['trials_ending_7d']) : null
  const ticketsOpen48h = overviewData ? pickExtraNumber(overviewData, ['tickets_open_48h']) : null

  // Revenue strip
  const mrr = (revenueData?.mrr as JsonRecord | undefined) ?? {}
  const churn = (revenueData?.churn_events_30d as JsonRecord | undefined) ?? {}
  const mrrTotal = pickNumber(mrr, 'total') ?? 0
  const mrrStripe = pickNumber(mrr, 'stripe') ?? 0
  const mrrIap = pickNumber(mrr, 'iap') ?? 0
  const paidSubs = pickNumber(revenueData, 'paid_subscriptions') ?? 0
  const trials = pickNumber(revenueData, 'trial_subscriptions') ?? 0
  const churnTotal = pickNumber(churn, 'total') ?? 0
  const refunds30d = pickNumber(revenueData, 'refunds_30d') ?? 0
  const arpu = paidSubs > 0 ? mrrTotal / paidSubs : null
  const trialConversion =
    trials !== null && paidSubs !== null && paidSubs + trials > 0
      ? (paidSubs / (paidSubs + trials)) * 100
      : null

  // Referrals pulse extras
  const promoActive = referralsData
    ? pickExtraNumber(referralsData, ['promo_active', 'promo_codes_active', 'active_promo_codes'])
    : null
  const giftsIssued = referralsData
    ? pickExtraNumber(referralsData, ['gifts_issued', 'gifts', 'referral_gifts'])
    : null

  // Trends data for Trends section
  const trendsData = trends.data
  const signupsSeries = (trendsData?.signups ?? []).map((row) => ({
    day: pickString(row, 'day') ?? '',
    count: pickNumber(row, 'count') ?? 0,
  }))
  const jobsSeries = (trendsData?.jobs ?? []).map((row) => ({
    day: pickString(row, 'day') ?? '',
    total: pickNumber(row, 'total') ?? 0,
    succeeded: pickNumber(row, 'succeeded') ?? 0,
    failed: pickNumber(row, 'failed') ?? 0,
  }))
  const paidSeries = (trendsData?.paid ?? []).map((row) => ({
    day: pickString(row, 'day') ?? '',
    provider: pickString(row, 'provider') ?? 'iap',
    count: pickNumber(row, 'count') ?? 0,
  }))
  const activeSeries = (trendsData?.active ?? []).map((row) => ({
    day: pickString(row, 'day') ?? '',
    count: pickNumber(row, 'count') ?? 0,
  }))

  const trendLabels = {
    signups: t('trends.charts.signups', { defaultValue: 'Signups' }),
    jobs: t('trends.charts.jobs', { defaultValue: 'AI jobs' }),
    jobsHint: t('trends.charts.jobsHint', { defaultValue: 'Succeeded vs failed' }),
    paid: t('trends.charts.paid', { defaultValue: 'Paid subscriptions' }),
    paidHint: t('trends.charts.paidHint', { defaultValue: 'Stripe vs stores' }),
    active: t('trends.charts.active', { defaultValue: 'AI-active users' }),
    activeHint: t('trends.charts.activeHint', { defaultValue: 'Users with ≥1 AI job that day' }),
    succeeded: t('charts.succeeded', { defaultValue: 'Succeeded' }),
    failed: t('charts.failed', { defaultValue: 'Failed' }),
    stripe: t('revenue.mrrStripe', { defaultValue: 'MRR · Stripe' }),
    iap: t('revenue.mrrIap', { defaultValue: 'MRR · Stores' }),
  }

  const funnelDerived = useMemo(() => {
    // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-assertion
    const funnelData = funnel.data as unknown as JsonRecord | null | undefined
    const stepsRaw = funnelData?.['steps']
    const backendSteps = Array.isArray(stepsRaw) ? (stepsRaw as JsonRecord[]) : []
    const hasBackend = !funnel.isError && !!funnel.data && backendSteps.length > 0
    if (hasBackend) return { steps: backendSteps, isApprox: false }
    const approxSteps: JsonRecord[] = [
      { label: t('funnel.stepSignups', { defaultValue: 'Signups (30d)' }), count: signups30d, pct_of_prev: 100 },
      {
        label: t('funnel.stepActive', { defaultValue: 'Active (7d)' }),
        count: active7d,
        pct_of_prev: signups30d > 0 ? (active7d / signups30d) * 100 : 0,
      },
      {
        label: t('funnel.stepTrials', { defaultValue: 'Trials' }),
        count: trials,
        pct_of_prev: active7d > 0 ? (trials / active7d) * 100 : 0,
      },
      {
        label: t('funnel.stepPaid', { defaultValue: 'Paid' }),
        count: paidSubscriptions,
        pct_of_prev: trials + paidSubscriptions > 0 ? (paidSubscriptions / (trials + paidSubscriptions)) * 100 : 0,
      },
    ]
    return { steps: approxSteps, isApprox: true }
  }, [funnel.data, funnel.isError, signups30d, active7d, trials, paidSubscriptions, t])

  return (
    <div className="space-y-4">
      {/* Header with title + updated-ago + Refresh that invalidates dashboardKeys.all */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-baseline gap-3">
          <h1 className="text-lg font-bold tracking-tight text-ink">{t('title')}</h1>
          <UpdatedAgo updatedAt={updatedAt} />
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={handleRefresh}
          disabled={
            overview.isFetching ||
            revenue.isFetching ||
            trends.isFetching ||
            funnel.isFetching ||
            retention.isFetching ||
            referrals.isFetching ||
            topUsers.isFetching ||
            activity.isFetching ||
            opsHealth.isFetching
          }
        >
          <RefreshCw
            className={
              overview.isFetching ||
              revenue.isFetching ||
              trends.isFetching ||
              funnel.isFetching ||
              retention.isFetching ||
              referrals.isFetching ||
              topUsers.isFetching ||
              activity.isFetching ||
              opsHealth.isFetching
                ? 'animate-spin'
                : undefined
            }
            aria-hidden="true"
          />
          {t('refresh')}
        </Button>
      </div>

      {/* Anchor nav — horizontal pills, sticky below header, keyboard + screen-reader friendly */}
      <nav
        aria-label={t('sections.navLabel', { defaultValue: 'Dashboard sections' })}
        className="sticky top-0 z-10 -mx-1 flex gap-1.5 overflow-x-auto border-b border-border bg-background/80 px-1 py-2 backdrop-blur supports-[backdrop-filter]:bg-background/60"
      >
        {[
          { id: 'overview', label: t('sections.overview', { defaultValue: 'Key metrics' }) },
          { id: 'revenue', label: t('sections.revenue', { defaultValue: 'Revenue' }) },
          { id: 'trends', label: t('sections.trends', { defaultValue: 'Trends' }) },
          { id: 'funnel', label: t('sections.funnel', { defaultValue: 'Funnel' }) },
          { id: 'retention', label: t('sections.retention', { defaultValue: 'Retention' }) },
          { id: 'referrals', label: t('sections.referralsPulse', { defaultValue: 'Referrals & promos' }) },
          { id: 'ops', label: t('sections.ops', { defaultValue: 'Ops & health' }) },
        ].map((item) => {
          const active = searchParams.get('section') === item.id
          return (
            <button
              key={item.id}
              type="button"
              onClick={() => {
                const next = new URLSearchParams(searchParams)
                next.set('section', item.id)
                setSearchParams(next, { replace: true })
                const el = document.getElementById(`section-${item.id}`)
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
              }}
              aria-current={active ? 'true' : undefined}
              className={`whitespace-nowrap rounded-full px-3 py-1 text-xs font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring ${
                active
                  ? 'bg-foreground text-background'
                  : 'bg-surface-card text-muted-foreground hover:bg-accent hover:text-accent-foreground'
              }`}
            >
              {item.label}
            </button>
          )
        })}
      </nav>

      {/* Section 1: KPI strip: 8 cells grid (existing 6 + trials_ending_7d + tickets_open_48h) */}
      <Card id="section-overview">
        <CardHeader dense>
          <CardTitle className="text-sm">{t('sections.overview', { defaultValue: 'Key metrics' })}</CardTitle>
        </CardHeader>
        <CardContent dense>
          {overview.isPending ? (
            <div
              className="grid grid-cols-2 gap-px overflow-hidden rounded-md border border-border bg-border sm:grid-cols-4 xl:grid-cols-8"
              aria-hidden="true"
            >
              {Array.from({ length: 8 }, (_, index) => (
                <div key={`metric-skeleton-${index}`} className="bg-card px-4 py-3">
                  <Skeleton className="h-3 w-24" />
                  <Skeleton className="mt-2 h-6 w-16" />
                </div>
              ))}
            </div>
          ) : overview.isError ? (
            <ErrorState
              message={normalizeError(overview.error).message}
              onRetry={() => void queryClient.invalidateQueries({ queryKey: dashboardKeys.overview })}
            />
          ) : (
            <>
              <div className="grid grid-cols-2 gap-px overflow-hidden rounded-md border border-border bg-border sm:grid-cols-4 xl:grid-cols-8">
                <MetricCell label={t('metrics.signups7d')} value={signups7d} />
                <MetricCell label={t('metrics.signups30d')} value={signups30d} />
                <MetricCell label={t('metrics.activeUsers7d')} value={active7d} />
                <MetricCell label={t('metrics.activeUsers30d')} value={active30d} />
                <MetricCell label={t('metrics.paidSubscriptions')} value={paidSubscriptions} />
                <MetricCell
                  label={t('metrics.aiJobs7d')}
                  value={aiJobsTotal}
                  hint={t('aiJobsHint', {
                    succeeded: formatNumber(aiJobsSucceeded),
                    failed: formatNumber(aiJobsFailed),
                  })}
                />
                <MetricCell
                  label={t('metrics.trialsEnding7d', { defaultValue: 'Trials ending (7d)' })}
                  value={trialsEnding7d ?? '—'}
                />
                <MetricCell
                  label={t('metrics.ticketsOpen48h', { defaultValue: 'Tickets open (48h)' })}
                  value={ticketsOpen48h ?? '—'}
                />
              </div>
              {/* OverviewCharts lazy */}
              <div className="mt-4">
                <Suspense
                  fallback={
                    <div className="grid gap-4 lg:grid-cols-2" aria-hidden="true">
                      <Skeleton className="h-40 w-full" />
                      <Skeleton className="h-40 w-full" />
                    </div>
                  }
                >
                  <OverviewCharts
                    signups={{ '7d': signups7d, '30d': signups30d }}
                    activeUsers={{ '7d': active7d, '30d': active30d }}
                    aiJobs={{ total: aiJobsTotal, succeeded: aiJobsSucceeded, failed: aiJobsFailed }}
                    labels={{
                      signups: t('charts.signups'),
                      activeUsers: t('charts.activeUsers'),
                      last7Days: t('charts.last7Days'),
                      last30Days: t('charts.last30Days'),
                      total: t('charts.total'),
                      succeeded: t('charts.succeeded'),
                      failed: t('charts.failed'),
                    }}
                  />
                </Suspense>
              </div>
            </>
          )}
        </CardContent>
      </Card>

      {/* BENTO Row2: Revenue (8) + Referrals (4) — densified from 2 full-width Cards */}
      <div className="grid gap-4 lg:grid-cols-12">
        <div className="lg:col-span-8">
      {/* Section 2: Revenue strip Card with 6 cells + 2 computed cells: ARPU and trialConversion */}
      <Card id="section-revenue">
        <CardHeader dense className="flex-row items-center justify-between">
          <CardTitle className="text-sm">{t('sections.revenue', { defaultValue: t('revenue.title') })}</CardTitle>
          <Link
            to="/dashboard?section=trends"
            className="text-xs font-medium text-muted-foreground underline-offset-4 hover:text-foreground hover:underline focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
          >
            {t('revenue.viewTrends')}
          </Link>
        </CardHeader>
        <CardContent dense>
          {revenue.isPending ? (
            <div
              className="grid grid-cols-2 gap-px overflow-hidden rounded-md border border-border bg-border sm:grid-cols-4 xl:grid-cols-8"
              aria-hidden="true"
            >
              {Array.from({ length: 8 }, (_, index) => (
                <div key={`revenue-skeleton-${index}`} className="bg-card px-4 py-3">
                  <Skeleton className="h-3 w-24" />
                  <Skeleton className="mt-2 h-6 w-16" />
                </div>
              ))}
            </div>
          ) : revenue.isError ? (
            <ErrorState
              message={normalizeError(revenue.error).message}
              onRetry={() => void queryClient.invalidateQueries({ queryKey: dashboardKeys.revenue })}
            />
          ) : (
            <div className="grid grid-cols-2 gap-px overflow-hidden rounded-md border border-border bg-border sm:grid-cols-4 xl:grid-cols-8">
              <MetricCell label={t('revenue.mrr')} value={formatMoney(mrrTotal)} hint={t('revenue.estimateHint')} />
              <MetricCell label={t('revenue.mrrStripe')} value={formatMoney(mrrStripe)} />
              <MetricCell label={t('revenue.mrrIap')} value={formatMoney(mrrIap)} />
              <MetricCell label={t('revenue.paidSubscriptions')} value={paidSubs} />
              <MetricCell label={t('revenue.trialSubscriptions')} value={trials} />
              <MetricCell
                label={t('revenue.churnEvents30d')}
                value={churnTotal}
                hint={t('revenue.churnHint', { refunds: refunds30d })}
              />
              <MetricCell
                label={t('revenue.arpu', { defaultValue: 'ARPU' })}
                value={arpu !== null ? formatMoney(arpu) : '—'}
                hint={t('revenue.arpuHint', { defaultValue: 'MRR / paid subs' })}
              />
              <MetricCell
                label={t('revenue.trialConversion', { defaultValue: 'Trial → Paid' })}
                value={trialConversion !== null ? `${trialConversion.toFixed(1)}%` : '—'}
                hint={
                  trialConversion !== null
                    ? t('revenue.trialConversionHint', {
                        value: `${trialConversion.toFixed(1)}%`,
                        defaultValue: `${trialConversion.toFixed(1)}% conversion`,
                      })
                    : undefined
                }
              />
            </div>
          )}
        </CardContent>
      </Card>
        </div>
        <div className="lg:col-span-4">
      {/* Section 6: Referrals+Promo+Gifts pulse Card: 4 cells + 2 extra */}
      <Card id="section-referrals">
        <CardHeader dense>
          <CardTitle className="text-sm">{t('sections.referralsPulse', { defaultValue: t('referrals.title') })}</CardTitle>
        </CardHeader>
        <CardContent dense>
          {referrals.isPending ? (
            <div className="grid grid-cols-2 gap-2 sm:grid-cols-3" aria-hidden="true">
              {Array.from({ length: 6 }, (_, index) => (
                <Skeleton key={`referral-skeleton-${index}`} className="h-16 w-full" />
              ))}
            </div>
          ) : referrals.isError ? (
            <ErrorState
              message={normalizeError(referrals.error).message}
              onRetry={() => void queryClient.invalidateQueries({ queryKey: dashboardKeys.referrals })}
            />
          ) : (
            <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
              <ReferralStat label={t('referrals.codesIssued')} value={referrals.data?.codes_issued ?? 0} />
              <ReferralStat label={t('referrals.redemptions')} value={referrals.data?.redemptions ?? 0} />
              <ReferralStat label={t('referrals.creditsGranted')} value={referrals.data?.credits_granted ?? 0} />
              <ReferralStat label={t('referrals.creditsPending')} value={referrals.data?.credits_pending ?? 0} />
              <ReferralStat
                label={t('referrals.promoActive', { defaultValue: 'Promo active' })}
                value={promoActive ?? '—'}
              />
              <ReferralStat
                label={t('referrals.giftsIssued', { defaultValue: 'Gifts issued' })}
                value={giftsIssued ?? '—'}
              />
            </div>
          )}
        </CardContent>
      </Card>
        </div>
      </div>

      {/* Section 3: Trends Card: reuse existing TrendsCharts lazy, keep ?days Tabs via useSearchParams parseDays */}
      <Card id="section-trends">
        <CardHeader dense className="flex-row items-center justify-between gap-2">
          <CardTitle className="text-sm">{t('sections.trends', { defaultValue: t('trends.title') })}</CardTitle>
          <Tabs
            value={String(trendsDays)}
            onValueChange={(value) => setDays(parseDays(value))}
            className="flex min-w-0"
          >
            <TabsList className="h-8 min-w-0 overflow-x-auto">
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
        </CardHeader>
        <CardContent dense>
          {trends.isPending ? (
            <div className="grid gap-4 lg:grid-cols-2" aria-hidden="true">
              {Array.from({ length: 4 }, (_, index) => (
                <div key={`trends-skeleton-${index}`} className="rounded-md border border-border p-3">
                  <Skeleton className="h-4 w-32" />
                  <Skeleton className="mt-3 h-52 w-full" />
                </div>
              ))}
            </div>
          ) : trends.isError || !trendsData ? (
            <ErrorState
              message={trends.isError ? normalizeError(trends.error).message : t('error')}
              onRetry={() => void queryClient.invalidateQueries({ queryKey: dashboardKeys.trends(trendsDays) })}
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
                signups={signupsSeries}
                jobs={jobsSeries}
                paid={paidSeries}
                active={activeSeries}
                labels={trendLabels}
              />
            </Suspense>
          )}
        </CardContent>
      </Card>

      {/* BENTO Row4: Funnel (7) + Retention (5) — replaces two full-width Cards */}
      <div className="grid gap-4 lg:grid-cols-12">
        <div className="lg:col-span-7">
      {/* Section 4: Funnel strip Card: call useFunnelQuery(days). Graceful fallback */}
      <Card id="section-funnel">
        <CardHeader dense>
          <CardTitle className="text-sm">{t('sections.funnel', { defaultValue: t('funnel.title', { defaultValue: 'Funnel' }) })}</CardTitle>
          {t('funnel.description', { defaultValue: 'Signup → active → trial → paid progression.' }) ? (
            <p className="text-xs text-muted-foreground">
              {t('funnel.description', { defaultValue: 'Signup → active → trial → paid progression.' })}
            </p>
          ) : null}
        </CardHeader>
        <CardContent dense>
          {funnel.isPending ? (
            <div className="flex gap-2" aria-hidden="true">
              {Array.from({ length: 4 }, (_, index) => (
                <Skeleton key={`funnel-skeleton-${index}`} className="h-20 flex-1" />
              ))}
            </div>
          ) : funnelDerived.steps.length === 0 ? (
            <EmptyState
              title={t('funnel.empty', { defaultValue: 'Funnel data unavailable' })}
              message={t('funnel.comingSoon', {
                defaultValue: 'Real funnel will appear when the backend exposes /dashboards/funnel.',
              })}
            />
          ) : (
            <div className="space-y-2">
              <div className="flex flex-wrap items-stretch gap-2">
                {funnelDerived.steps.slice(0, 4).map((row, index) => {
                  const label = pickString(row, 'label') ?? `Step ${index + 1}`
                  const count = pickNumber(row, 'count') ?? 0
                  const pct = pickNumber(row, 'pct_of_prev')
                  return (
                    <div key={`funnel-step-${index}`} className="flex min-w-0 flex-1 items-center gap-2">
                      <div className="flex-1 rounded-md border border-border bg-surface-card px-3 py-3 text-center">
                        <p className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                          {label}
                        </p>
                        <p className="mt-1 text-lg font-bold tabular-nums text-ink">{formatNumber(count)}</p>
                        <p className="mt-0.5 text-xs text-muted-foreground">
                          {index === 0 ? '100%' : pct !== null ? `${pct.toFixed(1)}%` : '—'}
                        </p>
                      </div>
                      {index < funnelDerived.steps.length - 1 && index < 3 ? (
                        <span className="text-muted-foreground" aria-hidden="true">
                          →
                        </span>
                      ) : null}
                    </div>
                  )
                })}
              </div>
              {funnelDerived.isApprox ? (
                <p className="text-center text-xs text-muted-foreground">
                  {t('funnel.approxCaption', { defaultValue: 'Approximation from overview metrics — real funnel when backend ready.' })}
                </p>
              ) : null}
            </div>
          )}
        </CardContent>
      </Card>
        </div>
        <div className="lg:col-span-5">
      {/* Section 5: Retention glance Card: useRetentionQuery(4). Graceful fallback */}
      <Card id="section-retention">
        <CardHeader dense>
          <CardTitle className="text-sm">
            {t('sections.retention', { defaultValue: t('retention.title', { defaultValue: 'Retention glance' }) })}
          </CardTitle>
          <p className="text-xs text-muted-foreground">
            {t('retention.description', { defaultValue: '4-week active retention.' })}
          </p>
        </CardHeader>
        <CardContent dense>
          {retention.isPending ? (
            <div className="space-y-2" aria-hidden="true">
              <Skeleton className="h-8 w-full" />
              <Skeleton className="h-8 w-full" />
              <Skeleton className="h-8 w-full" />
              <Skeleton className="h-8 w-full" />
            </div>
          ) : retention.isError || !retention.data ? (
            <EmptyState
              title={t('retention.empty', { defaultValue: 'Retention data not yet available.' })}
              message={t('retention.emptyHint', {
                defaultValue: 'Cohort retention will appear when the backend exposes /dashboards/retention.',
              })}
            />
          ) : (() => {
              const retentionData = retention.data as unknown as JsonRecord | null
              const cohortsRaw = retentionData ? (retentionData['cohorts']) : null
              const cohorts = Array.isArray(cohortsRaw) ? (cohortsRaw as JsonRecord[]) : []
              if (cohorts.length === 0) {
                return (
                  <EmptyState
                    title={t('retention.empty', { defaultValue: 'Retention data not yet available.' })}
                    message={t('retention.emptyHint', {
                      defaultValue: 'Cohort retention will appear when the backend exposes /dashboards/retention.',
                    })}
                  />
                )
              }
              return (
                <div className="overflow-hidden rounded-md border border-border">
                  <table className="w-full text-sm">
                    <thead className="bg-surface-card">
                      <tr>
                        <th className="px-3 py-2 text-left text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                          {t('retention.weekHeader', { defaultValue: 'Week' })}
                        </th>
                        <th className="px-3 py-2 text-right text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                          {t('retention.activeUsers', { defaultValue: 'Active users' })}
                        </th>
                        <th className="px-3 py-2 text-right text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                          {t('retention.retentionRate', { defaultValue: 'Retention' })}
                        </th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                      {cohorts.slice(0, 4).map((row, index) => {
                        const weekStart = pickString(row, 'week_start') ?? t('retention.week', { n: index + 1, defaultValue: `Week ${index + 1}` })
                        const signupsCount = pickNumber(row, 'signups') ?? null
                        const retentionPct = pickNumber(row, 'retention_pct') ?? null
                        return (
                          <tr key={`retention-${index}`}>
                            <td className="px-3 py-2 font-medium text-ink">{weekStart}</td>
                            <td className="px-3 py-2 text-right tabular-nums text-ink">
                              {signupsCount !== null ? formatNumber(signupsCount) : '—'}
                            </td>
                            <td className="px-3 py-2 text-right tabular-nums text-ink">
                              {retentionPct !== null ? `${retentionPct.toFixed(1)}%` : '—'}
                            </td>
                          </tr>
                        )
                      })}
                    </tbody>
                  </table>
                </div>
              )
            })()}
        </CardContent>
      </Card>
        </div>
      </div>



      {/* Section 7: Bottom grid xl:grid-cols-3: TopUsersCard + RecentAudit + Health mini-card */}
      <div className="grid gap-4 xl:grid-cols-3">
        <TopUsersCard
          data={topUsers.data}
          loading={topUsers.isPending}
          error={topUsers.isError ? normalizeError(topUsers.error).message : null}
          onRetry={() => void queryClient.invalidateQueries({ queryKey: dashboardKeys.topUsers })}
        />

        <Card className="min-w-0">
          <CardHeader dense className="flex-row items-center justify-between">
            <CardTitle className="text-sm">{t('activity.title')}</CardTitle>
            <Link
              to="/audit"
              className="text-xs font-medium text-muted-foreground underline-offset-4 hover:text-foreground hover:underline focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
            >
              {t('activity.viewAll')}
            </Link>
          </CardHeader>
          <CardContent dense>
            {activity.isPending ? (
              <div className="space-y-2" aria-hidden="true">
                {Array.from({ length: 4 }, (_, index) => (
                  <Skeleton key={`activity-skeleton-${index}`} className="h-8 w-full" />
                ))}
              </div>
            ) : activity.isError ? (
              <ErrorState
                message={normalizeError(activity.error).message}
                onRetry={() => void queryClient.invalidateQueries({ queryKey: dashboardKeys.recentAudit })}
              />
            ) : (activity.data?.items ?? []).length === 0 ? (
              <EmptyState icon={Users} title={t('activity.empty')} />
            ) : (
              <ol className="divide-y divide-border">
                {(activity.data?.items ?? []).slice(0, 8).map((event) => {
                  const actorEmail =
                    pickString(event.actor, 'email') ?? event.actor_id ?? '—'
                  return (
                    <li key={event.id} className="flex items-center gap-3 py-1.5">
                      <Badge className="shrink-0 font-mono text-[10px]">{event.action}</Badge>
                      <span className="min-w-0 flex-1 truncate text-sm">
                        <span className="font-medium text-ink">{actorEmail}</span>
                        <span className="text-muted-foreground">
                          {' '}
                          · {event.entity_type}
                          {event.entity_id ? ` / ${event.entity_id}` : ''}
                        </span>
                      </span>
                      <time className="whitespace-nowrap text-xs text-muted-foreground">
                        {relativeTimeValue(event.created_at)}
                      </time>
                    </li>
                  )
                })}
              </ol>
            )}
          </CardContent>
        </Card>

        <Card className="min-w-0">
          <CardHeader dense className="flex-row items-center justify-between gap-2">
            <CardTitle className="text-sm">{t('sections.ops', { defaultValue: t('ops.title', { defaultValue: 'Ops health' }) })}</CardTitle>
            <Link
              to="/storage"
              className="text-xs font-medium text-muted-foreground underline-offset-4 hover:text-foreground hover:underline focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
            >
              {t('ops.viewStorage', { defaultValue: 'View storage' })}
            </Link>
          </CardHeader>
          <CardContent dense>
            {opsHealth.isPending ? (
              <div className="space-y-2" aria-hidden="true">
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-4 w-3/4" />
                <Skeleton className="h-4 w-1/2" />
              </div>
            ) : opsHealth.isError ? (
              <ErrorState
                message={normalizeError(opsHealth.error).message}
                onRetry={() => void queryClient.invalidateQueries({ queryKey: dashboardKeys.opsHealth })}
              />
            ) : !opsHealth.data ? (
              <EmptyState title={t('ops.empty', { defaultValue: 'Ops health not yet available.' })} className="py-6" />
            ) : (
              <div className="space-y-2 text-sm">
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">{t('ops.status', { defaultValue: 'Status' })}</span>
                  <Badge className="font-mono text-xs">
                    {(opsHealth.data as unknown as JsonRecord)['status'] as string ?? '—'}
                  </Badge>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">{t('ops.version', { defaultValue: 'Version' })}</span>
                  <span className="font-mono text-xs text-ink">
                    {pickString(opsHealth.data, 'version') ?? '—'}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">{t('ops.commit', { defaultValue: 'Commit' })}</span>
                  <span className="max-w-[120px] truncate font-mono text-xs text-ink">
                    {pickString(opsHealth.data, 'commit') ?? '—'}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">{t('ops.schemaReady', { defaultValue: 'Schema ready' })}</span>
                  <span className="text-xs text-ink">
                    {/* eslint-disable-next-line @typescript-eslint/no-base-to-string */}
                    {String((opsHealth.data as unknown as JsonRecord)['schema_ready'] ?? '—')}
                  </span>
                </div>
                <p className="pt-2 text-xs text-muted-foreground">
                  {t('ops.webhookHint', { defaultValue: 'Webhook oldest age: — (placeholder)' })}
                </p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

function UpdatedAgo({ updatedAt }: { updatedAt: number }) {
  const { t } = useTranslation('dashboard')
  const [now, setNow] = useState(() => Date.now())
  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 5000)
    return () => clearInterval(timer)
  }, [])
  if (!updatedAt) return null
  const secondsAgo = Math.max(0, Math.floor((now - updatedAt) / 1000))
  let label: string | null = null
  if (secondsAgo < 5) label = t('updatedJustNow')
  else if (secondsAgo < 60) label = t('updatedAgo', { seconds: secondsAgo })
  else {
    const mins = Math.floor(secondsAgo / 60)
    if (mins < 60) label = t('updatedMinsAgo', { count: mins, defaultValue: `Updated ${mins}m ago` })
    else {
      const hrs = Math.floor(mins / 60)
      label = t('updatedHoursAgo', { count: hrs, defaultValue: `Updated ${hrs}h ago` })
    }
  }
  return label ? (
    <span className="text-xs text-muted-foreground" aria-live="polite">
      {label}
    </span>
  ) : null
}

function MetricCell({
  label,
  value,
  hint,
}: {
  label: string
  value: string | number
  hint?: string | undefined
}) {
  return (
    <div className="bg-card px-3 py-2">
      <p className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">{label}</p>
      <p className="mt-0.5 text-base font-bold tabular-nums tracking-tight text-ink">
        {typeof value === 'string' ? value : formatNumber(value)}
      </p>
      {hint ? <p className="mt-0.5 line-clamp-1 text-[11px] text-muted-foreground">{hint}</p> : null}
    </div>
  )
}

function ReferralStat({ label, value }: { label: string; value: number | string }) {
  return (
    <div className="rounded-md border border-border bg-surface-card px-2.5 py-2">
      <p className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">{label}</p>
      <p className="mt-0.5 text-base font-bold tabular-nums tracking-tight text-ink">
        {typeof value === 'string' ? value : formatNumber(value)}
      </p>
    </div>
  )
}

const TOP_USER_TABS: { key: TopUsersTab; labelKey: string; rows: (data: JsonRecord) => JsonRecord[] }[] = [
  { key: 'outfits', labelKey: 'topUsers.topOutfits', rows: (data) => pickArray(data, 'top_outfits') },
  { key: 'items', labelKey: 'topUsers.topItems', rows: (data) => pickArray(data, 'top_items') },
  { key: 'referrers', labelKey: 'topUsers.topReferrers', rows: (data) => pickArray(data, 'top_referrers') },
]

function TopUsersCard({
  data,
  loading,
  error,
  onRetry,
}: {
  data: JsonRecord | undefined
  loading: boolean
  error: string | null
  onRetry: () => void
}) {
  const { t } = useTranslation('dashboard')
  const [tab, setTab] = useState<TopUsersTab>('outfits')
  const activeTab = TOP_USER_TABS.find((entry) => entry.key === tab)
  if (!activeTab) return null
  const rows = data ? activeTab.rows(data) : []

  return (
    <Card className="min-w-0">
      <CardHeader dense className="flex-row items-center justify-between gap-2">
        <CardTitle className="flex items-center gap-2 text-sm">
          <Trophy className="size-4 text-muted-foreground" aria-hidden="true" />
          {t('topUsers.title')}
        </CardTitle>
        <Tabs value={tab} onValueChange={(value) => setTab(value as TopUsersTab)}>
          <TabsList className="h-8">
            {TOP_USER_TABS.map((entry) => (
              <TabsTrigger key={entry.key} value={entry.key} className="px-2.5 py-1 text-xs">
                {t(entry.labelKey)}
              </TabsTrigger>
            ))}
          </TabsList>
        </Tabs>
      </CardHeader>
      <CardContent dense>
        {loading ? (
          <div className="space-y-1.5" aria-hidden="true">
            {Array.from({ length: 5 }, (_, index) => (
              <Skeleton key={`top-user-${index}`} className="h-7 w-full" />
            ))}
          </div>
        ) : error ? (
          <ErrorState message={error} onRetry={onRetry} />
        ) : rows.length === 0 ? (
          <EmptyState icon={Users} title={t('topUsers.empty')} />
        ) : (
          <ol className="divide-y divide-border">
            {rows.slice(0, 5).map((row, index) => {
              const userId = pickString(row, 'user_id')
              const name = pickString(row, 'full_name') ?? pickString(row, 'email') ?? '—'
              const count = pickNumber(row, 'count') ?? 0
              return (
                <li key={userId ?? `top-${index}`} className="flex items-center gap-3 py-1.5">
                  <span className="w-5 text-xs font-semibold text-muted-foreground tabular-nums">{index + 1}</span>
                  <span className="min-w-0 flex-1 truncate text-sm font-medium text-ink">
                    {userId ? (
                      <Link
                        to={`/users/${userId}`}
                        className="underline-offset-4 hover:underline"
                        onClick={(event) => event.stopPropagation()}
                      >
                        {name}
                      </Link>
                    ) : (
                      name
                    )}
                  </span>
                  <span className="text-sm font-semibold tabular-nums text-ink">{formatNumber(count)}</span>
                </li>
              )
            })}
          </ol>
        )}
      </CardContent>
    </Card>
  )
}
