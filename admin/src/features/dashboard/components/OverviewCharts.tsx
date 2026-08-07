import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'

/**
 * Lazy-loaded compact trend charts (recharts is pinned to its own chunk in
 * vite.config.ts). The overview endpoint returns 7d/30d aggregates and
 * AI-job totals — no daily series — so the charts honestly plot the
 * aggregate pairs (spec §4 "where the shape allows"). Compact layout for the
 * ops-console grid: h-40, no Legend, tight margins (UX v2).
 */
export interface OverviewChartsProps {
  signups: { '7d': number; '30d': number }
  activeUsers: { '7d': number; '30d': number }
  aiJobs: { total: number; succeeded: number; failed: number }
  /** Translated labels */
  labels: {
    signups: string
    activeUsers: string
    last7Days: string
    last30Days: string
    total: string
    succeeded: string
    failed: string
  }
}

export function OverviewCharts({ signups, activeUsers, aiJobs, labels }: OverviewChartsProps) {
  const usageBars = [
    { name: labels.last7Days, signups: signups['7d'], active: activeUsers['7d'] },
    { name: labels.last30Days, signups: signups['30d'], active: activeUsers['30d'] },
  ]
  const jobBars = [
    { name: labels.total, value: aiJobs.total },
    { name: labels.succeeded, value: aiJobs.succeeded },
    { name: labels.failed, value: aiJobs.failed },
  ]

  return (
    <div className="grid gap-4 lg:grid-cols-2">
      <div className="h-40 w-full" role="img" aria-label={`${labels.signups} & ${labels.activeUsers}`}>
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={usageBars} margin={{ top: 4, right: 4, bottom: 0, left: -22 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="var(--color-hairline)" vertical={false} />
            <XAxis dataKey="name" tick={{ fontSize: 11 }} />
            <YAxis allowDecimals={false} tick={{ fontSize: 11 }} />
            <Tooltip cursor={{ fill: 'var(--color-surface-card)' }} />
            <Bar dataKey="signups" name={labels.signups} fill="var(--color-primary)" radius={[4, 4, 0, 0]} />
            <Bar dataKey="active" name={labels.activeUsers} fill="var(--color-mute)" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
      <div className="h-40 w-full" role="img" aria-label={labels.total}>
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={jobBars} margin={{ top: 4, right: 4, bottom: 0, left: -22 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="var(--color-hairline)" vertical={false} />
            <XAxis dataKey="name" tick={{ fontSize: 11 }} />
            <YAxis allowDecimals={false} tick={{ fontSize: 11 }} />
            <Tooltip cursor={{ fill: 'var(--color-surface-card)' }} />
            <Bar dataKey="value" name={labels.total} fill="var(--color-primary)" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}
