import { useTranslation } from 'react-i18next'

import { useOpsHealthQuery } from '@/features/ops/api/ops'
import { usePermission } from '@/shared/hooks/usePermission'
import { cn } from '@/shared/lib/cn'
import { Tooltip, TooltipContent, TooltipTrigger } from '@/shared/ui/tooltip'

/**
 * Deployment status pill — polls GET /api/v1/admin/ops/health every 60s
 * (spec §4). Green/amber/red dot + short label.
 *
 * The endpoint requires ops.read; roles without it get nothing (no polling,
 * no permanent-403 red "Down" pill).
 */
export function DeploymentStatus() {
  const { t } = useTranslation('layout')
  const { can } = usePermission()
  const canReadOps = can('ops.read')
  const { data, isError, isPending } = useOpsHealthQuery({ enabled: canReadOps })

  if (!canReadOps) return null

  const tone = isPending
    ? 'neutral'
    : isError || data?.status === 'down'
      ? 'danger'
      : data?.status === 'degraded'
        ? 'warning'
        : 'success'
  const labelKey = isPending
    ? 'deployment.unknown'
    : isError || data?.status === 'down'
      ? 'deployment.down'
      : data?.status === 'degraded'
        ? 'deployment.degraded'
        : 'deployment.operational'

  return (
    <Tooltip>
      <TooltipTrigger asChild>
        <span className="inline-flex items-center gap-1.5 rounded-full border border-border px-2.5 py-1.5 text-xs font-medium text-muted-foreground">
          <span
            className={cn(
              'size-2 rounded-full',
              tone === 'success' && 'bg-success-deep',
              tone === 'warning' && 'bg-warning-deep',
              tone === 'danger' && 'bg-destructive',
              tone === 'neutral' && 'bg-ash',
            )}
            aria-hidden="true"
          />
          {t(labelKey)}
        </span>
      </TooltipTrigger>
      <TooltipContent>{t(labelKey)}</TooltipContent>
    </Tooltip>
  )
}
