import { ArrowRight, Gift, Sparkles, type LucideIcon } from 'lucide-react'
import { Link } from 'react-router-dom'

import {
  giftIncomingTitle,
  giftShareText,
  giftTermLabel,
  type GiftAllowance,
  type GiftDashboardSummary,
  type GiftVoucher,
} from '@/api/gifts'
import { cn } from '@/lib/utils'

interface GiftPriorityCardProps {
  incoming?: GiftVoucher
  incomingCount?: number
  allowance?: GiftAllowance
}

export interface GiftPriority {
  incoming?: GiftVoucher
  incomingCount?: number
  allowance?: GiftAllowance
}

export function resolveGiftPriority(summary: GiftDashboardSummary | null): GiftPriority | null {
  const incoming = summary?.incoming[0]
  if (incoming) {
    return { incoming, incomingCount: summary?.incoming.length }
  }
  const allowance = summary?.allowances.find((item) => item.remaining_count > 0)
  return allowance ? { allowance } : null
}

/**
 * A non-dismissible dashboard action. The caller selects the priority so this
 * component does not make network requests or own referral state.
 */
export function GiftPriorityCard({
  incoming,
  incomingCount = 0,
  allowance,
}: GiftPriorityCardProps) {
  // Narrowed branches instead of non-null assertions. Render nothing when the
  // caller passes neither priority (resolveGiftPriority already returns null).
  let href: string
  let Icon: LucideIcon
  let title: string
  let description: string
  if (incoming) {
    href = `/gifts?claim=${incoming.id}`
    Icon = Gift
    title = giftIncomingTitle(incomingCount)
    description =
      incomingCount > 1
        ? 'Open your gift inbox to review and claim them with your verified email.'
        : giftShareText(incoming)
  } else if (allowance) {
    href = `/gifts?mode=complimentary&duration=${allowance.duration_months}`
    Icon = Sparkles
    title = `Send a free ${giftTermLabel(allowance.duration_months)} invitation`
    description = `${allowance.remaining_count} free ${giftTermLabel(allowance.duration_months)} invitation${allowance.remaining_count === 1 ? '' : 's'} available.`
  } else {
    return null
  }
  const action = incoming ? 'Open gifts' : 'Send invitation'

  return (
    <Link
      to={href}
      className={cn(
        'group relative flex flex-col gap-3 overflow-hidden rounded-xl border border-primary/30 bg-primary/5 p-4',
        'transition-colors hover:bg-primary/10 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
        'sm:flex-row sm:items-center',
      )}
      aria-label={`${title}. ${action}`}
    >
      <div className="flex min-w-0 flex-1 items-start gap-3 sm:items-center">
        <div className="shrink-0 rounded-lg bg-primary p-2 text-primary-foreground">
          <Icon className="h-5 w-5" aria-hidden="true" />
        </div>
        <div className="min-w-0">
          <p className="text-sm font-semibold text-foreground">{title}</p>
          <p className="mt-0.5 text-xs text-muted-foreground">{description}</p>
        </div>
      </div>
      <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-primary">
        {action}
        <ArrowRight
          className="h-4 w-4 transition-transform duration-200 group-hover:translate-x-0.5"
          aria-hidden="true"
        />
      </span>
    </Link>
  )
}
