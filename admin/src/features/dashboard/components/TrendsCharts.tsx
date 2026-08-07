import { useMemo, type ReactNode } from 'react'
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'

/**
 * Lazy-loaded daily trend charts (recharts is pinned to its own chunk in
 * vite.config.ts). Renders the migration-041 daily series: signups (area),
 * AI jobs (stacked succeeded/failed), paid subscriptions (stacked Stripe vs
 * stores) and AI-active users (line). Day ticks are compact MM-DD labels.
 */

export interface TrendDayPoint {
  day: string
  count: number
}

export interface TrendJobsPoint {
  day: string
  total: number
  succeeded: number
  failed: number
}

export interface TrendPaidPoint {
  day: string
  provider: string
  count: number
}

export interface TrendsChartsProps {
  signups: TrendDayPoint[]
  jobs: TrendJobsPoint[]
  paid: TrendPaidPoint[]
  active: TrendDayPoint[]
  labels: {
    signups: string
    jobs: string
    jobsHint: string
    paid: string
    paidHint: string
    active: string
    activeHint: string
    succeeded: string
    failed: string
    stripe: string
    iap: string
  }
}

/** Pivot interleaved {day, provider, count} rows into one row per day. */
export function pivotPaidRows(
  rows: TrendPaidPoint[],
): { day: string; stripe: number; iap: number }[] {
  const byDay = new Map<string, { day: string; stripe: number; iap: number }>()
  for (const row of rows) {
    const entry = byDay.get(row.day) ?? { day: row.day, stripe: 0, iap: 0 }
    if (row.provider === 'stripe') entry.stripe += row.count
    else entry.iap += row.count
    byDay.set(row.day, entry)
  }
  return [...byDay.values()]
}

/** Compact MM-DD tick labels ("2026-08-07" -> "08-07"). */
function dayTick(day: string): string {
  return day.length >= 10 ? day.slice(5) : day
}

/** Tooltip/label formatter accepting recharts' ReactNode label. */
function labelFormatter(label: unknown): string {
  if (typeof label === 'string' || typeof label === 'number') {
    return dayTick(String(label))
  }
  return ''
}

export function TrendsCharts({ signups, jobs, paid, active, labels }: TrendsChartsProps) {
  const paidByDay = useMemo(() => pivotPaidRows(paid), [paid])

  return (
    <div className="grid gap-4 lg:grid-cols-2">
      <ChartCard title={labels.signups}>
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={signups} margin={{ top: 4, right: 4, bottom: 0, left: -22 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="var(--color-hairline)" vertical={false} />
            <XAxis dataKey="day" tickFormatter={dayTick} tick={{ fontSize: 11 }} minTickGap={24} />
            <YAxis allowDecimals={false} tick={{ fontSize: 11 }} />
            <Tooltip cursor={{ fill: 'var(--color-surface-card)' }} labelFormatter={labelFormatter} />
            <Area
              type="monotone"
              dataKey="count"
              name={labels.signups}
              stroke="var(--color-primary)"
              fill="var(--color-primary)"
              fillOpacity={0.15}
              strokeWidth={2}
            />
          </AreaChart>
        </ResponsiveContainer>
      </ChartCard>

      <ChartCard title={labels.jobs} hint={labels.jobsHint}>
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={jobs} margin={{ top: 4, right: 4, bottom: 0, left: -22 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="var(--color-hairline)" vertical={false} />
            <XAxis dataKey="day" tickFormatter={dayTick} tick={{ fontSize: 11 }} minTickGap={24} />
            <YAxis allowDecimals={false} tick={{ fontSize: 11 }} />
            <Tooltip cursor={{ fill: 'var(--color-surface-card)' }} labelFormatter={labelFormatter} />
            <Bar dataKey="succeeded" name={labels.succeeded} fill="var(--color-primary)" radius={[2, 2, 0, 0]} stackId="jobs" />
            <Bar dataKey="failed" name={labels.failed} fill="var(--color-mute)" radius={[2, 2, 0, 0]} stackId="jobs" />
          </BarChart>
        </ResponsiveContainer>
      </ChartCard>

      <ChartCard title={labels.paid} hint={labels.paidHint}>
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={paidByDay} margin={{ top: 4, right: 4, bottom: 0, left: -22 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="var(--color-hairline)" vertical={false} />
            <XAxis dataKey="day" tickFormatter={dayTick} tick={{ fontSize: 11 }} minTickGap={24} />
            <YAxis allowDecimals={false} tick={{ fontSize: 11 }} />
            <Tooltip cursor={{ fill: 'var(--color-surface-card)' }} labelFormatter={labelFormatter} />
            <Area
              type="monotone"
              dataKey="stripe"
              name={labels.stripe}
              stackId="paid"
              stroke="var(--color-primary)"
              fill="var(--color-primary)"
              fillOpacity={0.2}
              strokeWidth={2}
            />
            <Area
              type="monotone"
              dataKey="iap"
              name={labels.iap}
              stackId="paid"
              stroke="var(--color-mute)"
              fill="var(--color-mute)"
              fillOpacity={0.35}
              strokeWidth={2}
            />
          </AreaChart>
        </ResponsiveContainer>
      </ChartCard>

      <ChartCard title={labels.active} hint={labels.activeHint}>
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={active} margin={{ top: 4, right: 4, bottom: 0, left: -22 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="var(--color-hairline)" vertical={false} />
            <XAxis dataKey="day" tickFormatter={dayTick} tick={{ fontSize: 11 }} minTickGap={24} />
            <YAxis allowDecimals={false} tick={{ fontSize: 11 }} />
            <Tooltip cursor={{ fill: 'var(--color-surface-card)' }} labelFormatter={labelFormatter} />
            <Area
              type="monotone"
              dataKey="count"
              name={labels.active}
              stroke="var(--color-ink)"
              fill="var(--color-ink)"
              fillOpacity={0.08}
              strokeWidth={2}
            />
          </AreaChart>
        </ResponsiveContainer>
      </ChartCard>
    </div>
  )
}

function ChartCard({ title, hint, children }: { title: string; hint?: string; children: ReactNode }) {
  return (
    <div className="rounded-md border border-border p-3">
      <div className="mb-2 flex items-baseline justify-between gap-2">
        <h3 className="text-sm font-semibold text-ink">{title}</h3>
        {hint ? <p className="text-xs text-muted-foreground">{hint}</p> : null}
      </div>
      <div className="h-52 w-full" role="img" aria-label={title}>
        {children}
      </div>
    </div>
  )
}
