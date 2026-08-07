import { Area, AreaChart, ResponsiveContainer } from 'recharts'

/**
 * Minimal area sparkline for MetricCard. Lazy-loaded via React.lazy from
 * MetricCard so recharts stays out of the initial bundle (spec §9).
 */
export interface SparklineProps {
  data: number[]
  /** CSS color value (defaults to Brand Red) */
  color?: string
}

export function Sparkline({ data, color = 'var(--color-primary)' }: SparklineProps) {
  const points = data.map((value, index) => ({ index, value }))
  return (
    <div className="h-10 w-full" aria-hidden="true">
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={points} margin={{ top: 2, right: 0, bottom: 2, left: 0 }}>
          <defs>
            <linearGradient id="sparkline-fill" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor={color} stopOpacity={0.25} />
              <stop offset="100%" stopColor={color} stopOpacity={0} />
            </linearGradient>
          </defs>
          <Area
            type="monotone"
            dataKey="value"
            stroke={color}
            strokeWidth={1.5}
            fill="url(#sparkline-fill)"
            isAnimationActive={false}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  )
}
