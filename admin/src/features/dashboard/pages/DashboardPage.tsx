import { RefreshCw, Trophy, Users } from 'lucide-react'
import { lazy, Suspense, useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router-dom'

import {
  useOverviewQuery,
  useRecentAuditQuery,
  useReferralsQuery,
  useRevenueQuery,
  useTopUsersQuery,
} from '@/features/dashboard/api/dashboard'
import { normalizeError } from '@/shared/api/errors'
import { formatMoney, formatNumber, relativeTimeValue } from '@/shared/lib/formatters'
import { pickNumber, pickString, type JsonRecord } from '@/shared/lib/json'
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

/**
 * Ops-console dashboard (UX v2): everything valuable lands in the first
 * viewport — compact metric strip, trends charts, and a tabbed Top Users
 * card in one row; referrals + recent admin activity in the row below.
 * Recent activity reuses the audit endpoint (dashboard feature owns its
 * query; it may not import features/audit).
 */

type TopUsersTab = 'outfits' | 'items' | 'referrers'

export function DashboardPage() {
  const { t } = useTranslation('dashboard')
  const overview = useOverviewQuery()
  const topUsers = useTopUsersQuery()
  const referrals = useReferralsQuery()
  const revenue = useRevenueQuery()
  const activity = useRecentAuditQuery()

  // Relative "updated Xs ago" readout, ticking every 5s.
  const [now, setNow] = useState(() => Date.now())
  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 5000)
    return () => clearInterval(timer)
  }, [])
  const updatedAt = Math.max(
    overview.dataUpdatedAt,
    topUsers.dataUpdatedAt,
    referrals.dataUpdatedAt,
    revenue.dataUpdatedAt,
    activity.dataUpdatedAt,
  )
  const secondsAgo = updatedAt > 0 ? Math.max(0, Math.floor((now - updatedAt) / 1000)) : null

  const refetchAll = (): void => {
    void overview.refetch()
    void topUsers.refetch()
    void referrals.refetch()
    void revenue.refetch()
    void activity.refetch()
  }

  const overviewData = overview.data
  const signups = overviewData?.signups ?? {}
  const activeUsers = overviewData?.active_users ?? {}
  const aiJobs = overviewData?.ai_jobs_7d ?? {}
  const signups7d = pickNumber(signups, '7d') ?? 0
  const signups30d = pickNumber(signups, '30d') ?? 0
  const active7d = pickNumber(activeUsers, '7d') ?? 0
  const active30d = pickNumber(activeUsers, '30d') ?? 0
  const paidSubscriptions = pickNumber(overviewData, 'paid_subscriptions') ?? 0
  const aiJobsTotal = pickNumber(aiJobs, 'total') ?? 0
  const aiJobsSucceeded = pickNumber(aiJobs, 'succeeded') ?? 0
  const aiJobsFailed = pickNumber(aiJobs, 'failed') ?? 0

  // Revenue strip (estimate from plan prices; see GET /dashboards/revenue).
  const revenueData = revenue.data
  const mrr = revenueData?.mrr ?? {}
  const churn = revenueData?.churn_events_30d ?? {}
  const mrrTotal = pickNumber(mrr, 'total') ?? 0
  const mrrStripe = pickNumber(mrr, 'stripe') ?? 0
  const mrrIap = pickNumber(mrr, 'iap') ?? 0
  const paidSubs = pickNumber(revenueData, 'paid_subscriptions') ?? 0
  const trials = pickNumber(revenueData, 'trial_subscriptions') ?? 0
  const churnTotal = pickNumber(churn, 'total') ?? 0
  const refunds30d = pickNumber(revenueData, 'refunds_30d') ?? 0

  return (
    <div className="space-y-4">
      {/* Compact header: title + updated stamp + refresh on one line */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-baseline gap-3">
          <h1 className="text-lg font-bold tracking-tight text-ink">{t('title')}</h1>
          {secondsAgo !== null ? (
            <span className="text-xs text-muted-foreground">
              {secondsAgo < 5 ? t('updatedJustNow') : t('updatedAgo', { seconds: secondsAgo })}
            </span>
          ) : null}
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={refetchAll}
          disabled={overview.isFetching || activity.isFetching}
        >
          <RefreshCw
            className={overview.isFetching ? 'animate-spin' : undefined}
            aria-hidden="true"
          />
          {t('refresh')}
        </Button>
      </div>

      {/* Metric strip — one hairline container, six cells */}
      {overview.isPending ? (
        <div
          className="grid grid-cols-2 gap-px overflow-hidden rounded-md border border-border bg-border sm:grid-cols-3 xl:grid-cols-6"
          aria-hidden="true"
        >
          {Array.from({ length: 6 }, (_, index) => (
            <div key={`metric-skeleton-${index}`} className="bg-card px-4 py-3">
              <Skeleton className="h-3 w-24" />
              <Skeleton className="mt-2 h-6 w-16" />
            </div>
          ))}
        </div>
      ) : overview.isError ? null : (
        <div className="grid grid-cols-2 gap-px overflow-hidden rounded-md border border-border bg-border sm:grid-cols-3 xl:grid-cols-6">
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
        </div>
      )}

      {/* Revenue strip — MRR estimate (plan prices), paid/trials, churn */}
      <Card>
        <CardHeader dense className="flex-row items-center justify-between">
          <CardTitle className="text-sm">{t('revenue.title')}</CardTitle>
          <Link
            to="/dashboard/trends"
            className="text-xs font-medium text-muted-foreground underline-offset-4 hover:text-foreground hover:underline focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
          >
            {t('revenue.viewTrends')}
          </Link>
        </CardHeader>
        <CardContent dense>
          {revenue.isPending ? (
            <div
              className="grid grid-cols-2 gap-px overflow-hidden rounded-md border border-border bg-border sm:grid-cols-3 xl:grid-cols-6"
              aria-hidden="true"
            >
              {Array.from({ length: 6 }, (_, index) => (
                <div key={`revenue-skeleton-${index}`} className="bg-card px-4 py-3">
                  <Skeleton className="h-3 w-24" />
                  <Skeleton className="mt-2 h-6 w-16" />
                </div>
              ))}
            </div>
          ) : revenue.isError ? null : (
            <div className="grid grid-cols-2 gap-px overflow-hidden rounded-md border border-border bg-border sm:grid-cols-3 xl:grid-cols-6">
              <MetricCell
                label={t('revenue.mrr')}
                value={formatMoney(mrrTotal)}
                hint={t('revenue.estimateHint')}
              />
              <MetricCell label={t('revenue.mrrStripe')} value={formatMoney(mrrStripe)} />
              <MetricCell label={t('revenue.mrrIap')} value={formatMoney(mrrIap)} />
              <MetricCell label={t('revenue.paidSubscriptions')} value={paidSubs} />
              <MetricCell label={t('revenue.trialSubscriptions')} value={trials} />
              <MetricCell
                label={t('revenue.churnEvents30d')}
                value={churnTotal}
                hint={t('revenue.churnHint', { refunds: refunds30d })}
              />
            </div>
          )}
        </CardContent>
      </Card>

      {/* Main row: trends (2/3) + tabbed top users (1/3) */}
      <div className="grid gap-4 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <CardHeader dense>
            <CardTitle className="text-sm">{t('charts.title')}</CardTitle>
          </CardHeader>
          <CardContent dense>
            {overview.isPending ? (
              <div className="grid gap-4 lg:grid-cols-2" aria-hidden="true">
                <Skeleton className="h-40 w-full" />
                <Skeleton className="h-40 w-full" />
              </div>
            ) : overview.isError ? (
              <ErrorState
                message={normalizeError(overview.error).message}
                onRetry={() => void overview.refetch()}
              />
            ) : (
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
            )}
          </CardContent>
        </Card>

        <TopUsersCard
          data={topUsers.data ?? undefined}
          loading={topUsers.isPending}
          error={topUsers.isError ? normalizeError(topUsers.error).message : null}
          onRetry={() => void topUsers.refetch()}
        />
      </div>

      {/* Bottom row: referrals (1/3) + recent admin activity (2/3) */}
      <div className="grid gap-4 xl:grid-cols-3">
        <Card>
          <CardHeader dense>
            <CardTitle className="text-sm">{t('referrals.title')}</CardTitle>
          </CardHeader>
          <CardContent dense>
            {referrals.isPending ? (
              <div className="grid grid-cols-2 gap-2">
                {Array.from({ length: 4 }, (_, index) => (
                  <Skeleton key={`referral-skeleton-${index}`} className="h-16 w-full" />
                ))}
              </div>
            ) : referrals.isError ? (
              <ErrorState
                message={normalizeError(referrals.error).message}
                onRetry={() => void referrals.refetch()}
              />
            ) : (
              <div className="grid grid-cols-2 gap-2">
                <ReferralStat label={t('referrals.codesIssued')} value={referrals.data?.codes_issued ?? 0} />
                <ReferralStat label={t('referrals.redemptions')} value={referrals.data?.redemptions ?? 0} />
                <ReferralStat label={t('referrals.creditsGranted')} value={referrals.data?.credits_granted ?? 0} />
                <ReferralStat label={t('referrals.creditsPending')} value={referrals.data?.credits_pending ?? 0} />
              </div>
            )}
          </CardContent>
        </Card>

        <Card className="xl:col-span-2">
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
                onRetry={() => void activity.refetch()}
              />
            ) : (activity.data?.items ?? []).length === 0 ? (
              <EmptyState icon={Users} title={t('activity.empty')} />
            ) : (
              <ol className="divide-y divide-border">
                {(activity.data?.items ?? []).slice(0, 8).map((event) => {
                  const actorEmail = pickString(event.actor, 'email') ?? event.actor_id ?? '—'
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
      </div>
    </div>
  )
}

function MetricCell({
  label,
  value,
  hint,
}: {
  label: string
  value: string | number
  hint?: string
}) {
  return (
    <div className="bg-card px-4 py-3">
      <p className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
        {label}
      </p>
      <p className="mt-1 text-xl font-bold tabular-nums tracking-tight text-ink">
        {typeof value === 'string' ? value : formatNumber(value)}
      </p>
      {hint ? <p className="mt-0.5 text-xs text-muted-foreground">{hint}</p> : null}
    </div>
  )
}

function ReferralStat({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-md border border-border bg-surface-card px-3 py-2.5">
      <p className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
        {label}
      </p>
      <p className="mt-0.5 text-lg font-bold tabular-nums tracking-tight text-ink">
        {formatNumber(value)}
      </p>
    </div>
  )
}

const TOP_USER_TABS: { key: TopUsersTab; labelKey: string; rows: (data: JsonRecord) => JsonRecord[] }[] = [
  { key: 'outfits', labelKey: 'topUsers.topOutfits', rows: (data) => pickJsonArray(data, 'top_outfits') },
  { key: 'items', labelKey: 'topUsers.topItems', rows: (data) => pickJsonArray(data, 'top_items') },
  { key: 'referrers', labelKey: 'topUsers.topReferrers', rows: (data) => pickJsonArray(data, 'top_referrers') },
]

/** Pull a JSON array out of the top-users payload defensively. */
function pickJsonArray(data: JsonRecord, key: string): JsonRecord[] {
  const value = data[key]
  if (!Array.isArray(value)) return []
  return value.filter((entry): entry is JsonRecord => typeof entry === 'object' && entry !== null)
}

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
    <Card>
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
                  <span className="w-5 text-xs font-semibold text-muted-foreground tabular-nums">
                    {index + 1}
                  </span>
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
                  <span className="text-sm font-semibold tabular-nums text-ink">
                    {formatNumber(count)}
                  </span>
                </li>
              )
            })}
          </ol>
        )}
      </CardContent>
    </Card>
  )
}
