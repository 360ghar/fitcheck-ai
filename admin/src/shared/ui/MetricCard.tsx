import { ArrowDownRight, ArrowUpRight, Minus } from 'lucide-react'
import { lazy, Suspense } from 'react'

import { cn } from '@/shared/lib/cn'
import { formatNumber } from '@/shared/lib/formatters'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/ui/card'

const Sparkline = lazy(() =>
  import('@/shared/ui/charts/Sparkline').then((module) => ({ default: module.Sparkline })),
)

export type DeltaTrend = 'up' | 'down' | 'flat'

export interface MetricDelta {
  value: string
  trend: DeltaTrend
  /** When true, a down-trend is good (e.g. error rates) */
  goodWhenDown?: boolean
}

export interface MetricCardProps {
  label: string
  value: number | string
  /** Optional hint under the label (e.g. "last 30 days") */
  hint?: string
  delta?: MetricDelta
  /** Sparkline series — lazy-loaded recharts */
  sparkline?: number[]
  className?: string
}

function DeltaBadge({ delta }: { delta: MetricDelta }) {
  const good =
    delta.trend === 'flat' ||
    (delta.trend === 'up' && !delta.goodWhenDown) ||
    (delta.trend === 'down' && delta.goodWhenDown)
  const Icon =
    delta.trend === 'up' ? ArrowUpRight : delta.trend === 'down' ? ArrowDownRight : Minus
  return (
    <span
      className={cn(
        'inline-flex items-center gap-0.5 rounded-full px-2 py-0.5 text-xs font-semibold',
        good ? 'bg-success-pale text-success-deep' : 'bg-destructive/10 text-destructive',
      )}
    >
      <Icon className="size-3" aria-hidden="true" />
      {delta.value}
    </span>
  )
}

/**
 * Dashboard metric card: label, tabular-nums value, optional delta badge and
 * sparkline. Flat surface, hairline edge (DESIGN.md §06).
 */
export function MetricCard({ label, value, hint, delta, sparkline, className }: MetricCardProps) {
  const displayValue = typeof value === 'number' ? formatNumber(value) : value
  return (
    <Card className={className}>
      <CardHeader className="pb-2">
        <CardDescription>{label}</CardDescription>
        {delta ? <DeltaBadge delta={delta} /> : null}
      </CardHeader>
      <CardContent className="space-y-2">
        <CardTitle className="text-3xl font-bold tabular-nums tracking-tight">
          {displayValue}
        </CardTitle>
        {hint ? <p className="text-xs text-muted-foreground">{hint}</p> : null}
        {sparkline && sparkline.length > 0 ? (
          <Suspense fallback={<div className="h-10 w-full" aria-hidden="true" />}>
            <Sparkline data={sparkline} />
          </Suspense>
        ) : null}
      </CardContent>
    </Card>
  )
}
