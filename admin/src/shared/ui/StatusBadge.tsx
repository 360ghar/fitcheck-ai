import { cn } from '@/shared/lib/cn'

/**
 * Status badge: maps a backend status string to a tone. The status string
 * itself is data (not UI copy) — pass a translated `label` when the raw
 * value should not be shown (e.g. t(`components:status.${status}`)).
 */

export type StatusTone = 'success' | 'warning' | 'danger' | 'info' | 'neutral'

const TONE_CLASSES: Record<StatusTone, string> = {
  success: 'bg-success-pale text-success-deep',
  warning: 'bg-warning-pale text-warning-deep',
  danger: 'bg-destructive/10 text-destructive',
  info: 'bg-info-pale text-info-deep',
  neutral: 'bg-surface-card text-muted-foreground',
}

const SUCCESS_STATUSES = [
  'active',
  'ok',
  'healthy',
  'verified',
  'completed',
  'paid',
  'published',
  'enabled',
  'resolved',
]
const DANGER_STATUSES = [
  'suspended',
  'cancelled',
  'canceled',
  'failed',
  'blocked',
  'banned',
  'disabled',
  'deleted',
  'down',
]
const WARNING_STATUSES = [
  'trialing',
  'trial',
  'past_due',
  'pending',
  'processing',
  'refunding',
  'expiring',
  'expired',
  'draft',
  'degraded',
  'in_progress',
]
const INFO_STATUSES = ['review', 'needs_review', 'flagged', 'open']

export function toneForStatus(status: string): StatusTone {
  const normalized = status.toLowerCase()
  if (SUCCESS_STATUSES.includes(normalized)) return 'success'
  if (DANGER_STATUSES.includes(normalized)) return 'danger'
  if (WARNING_STATUSES.includes(normalized)) return 'warning'
  if (INFO_STATUSES.includes(normalized)) return 'info'
  return 'neutral'
}

export interface StatusBadgeProps {
  /** Raw backend status string (drives the tone) */
  status?: string
  /** Display label — pass translated copy when the raw value should be hidden */
  label?: string
  /** Explicit tone override */
  tone?: StatusTone
  className?: string
}

export function StatusBadge({ status, label, tone, className }: StatusBadgeProps) {
  const resolvedTone = tone ?? (status ? toneForStatus(status) : 'neutral')
  const display = label ?? status ?? ''
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 whitespace-nowrap rounded-full px-2.5 py-0.5 text-xs font-medium',
        TONE_CLASSES[resolvedTone],
        className,
      )}
    >
      <span className="size-1.5 rounded-full bg-current" aria-hidden="true" />
      {display}
    </span>
  )
}
