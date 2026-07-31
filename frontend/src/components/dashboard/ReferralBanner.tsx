/**
 * Referral Banner Component
 * Promotional banner encouraging users to refer friends for free Pro month
 */

import { useState, useEffect } from 'react'
import { Gift, Copy, Share2, X, Check } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useToast } from '@/components/ui/use-toast'
import { useSubscriptionStore } from '@/stores/subscriptionStore'

interface ReferralBannerProps {
  variant?: 'default' | 'urgent'
  onDismiss?: () => void
}

const DISMISSAL_KEY = 'fitcheck_referral_banner_dismissed_at'
const WEEK_IN_MS = 7 * 24 * 60 * 60 * 1000

export function useReferralBannerDismissal() {
  const [isDismissed, setIsDismissed] = useState(() => {
    const dismissedAt = localStorage.getItem(DISMISSAL_KEY)
    if (!dismissedAt) return false
    const weekAgo = Date.now() - WEEK_IN_MS
    return parseInt(dismissedAt, 10) > weekAgo
  })

  const dismiss = () => {
    localStorage.setItem(DISMISSAL_KEY, Date.now().toString())
    setIsDismissed(true)
  }

  return { isDismissed, dismiss }
}

export function ReferralBanner({ variant = 'default', onDismiss }: ReferralBannerProps) {
  const [copied, setCopied] = useState(false)
  const [isSharing, setIsSharing] = useState(false)
  const { toast } = useToast()
  const referralCode = useSubscriptionStore((state) => state.referralCode)
  const copyReferralLink = useSubscriptionStore((state) => state.copyReferralLink)
  const fetchReferralCode = useSubscriptionStore((state) => state.fetchReferralCode)

  useEffect(() => {
    // Fetch referral code if not already loaded
    if (!referralCode) {
      fetchReferralCode()
    }
  }, [referralCode, fetchReferralCode])

  const ensureShareUrl = async (): Promise<string | null> => {
    if (referralCode?.share_url) return referralCode.share_url
    await fetchReferralCode()
    return useSubscriptionStore.getState().referralCode?.share_url ?? null
  }

  const handleCopy = async () => {
    const success = await copyReferralLink()
    if (success) {
      setCopied(true)
      toast({
        title: 'Link copied!',
        description: 'Share this link with friends to earn free Pro months.',
      })
      setTimeout(() => setCopied(false), 2000)
    } else {
      toast({
        title: 'Failed to copy',
        description: 'Could not load or copy your referral link. Try again.',
        variant: 'destructive',
      })
    }
  }

  const handleShare = async () => {
    if (isSharing) return
    setIsSharing(true)
    try {
      const shareUrl = await ensureShareUrl()
      if (!shareUrl) {
        toast({
          title: 'Share unavailable',
          description: 'Could not load your referral link. Try again.',
          variant: 'destructive',
        })
        return
      }

      const shareData = {
        title: 'Join FitCheck AI',
        text: 'Sign up with my link and we both get 1 month of Pro free!',
        url: shareUrl,
      }

      if (typeof navigator.share === 'function') {
        try {
          // Prefer canShare when available
          if (typeof navigator.canShare === 'function' && !navigator.canShare(shareData)) {
            throw new Error('Share data not supported')
          }
          await navigator.share(shareData)
          return
        } catch (err) {
          // User cancelled share sheet — not an error
          if (err instanceof DOMException && err.name === 'AbortError') {
            return
          }
          // Fall through to clipboard
        }
      }

      // Clipboard fallback (desktop or share failure)
      try {
        await navigator.clipboard.writeText(shareUrl)
        setCopied(true)
        toast({
          title: 'Link copied!',
          description: 'Share sheet unavailable — link copied to clipboard instead.',
        })
        setTimeout(() => setCopied(false), 2000)
      } catch {
        toast({
          title: 'Share failed',
          description: 'Could not share or copy your link. Please try Copy Link.',
          variant: 'destructive',
        })
      }
    } finally {
      setIsSharing(false)
    }
  }

  const isUrgent = variant === 'urgent'

  return (
    <div
      className={cn(
        'relative overflow-hidden rounded-xl border p-4',
        'transition-[transform,opacity] duration-300',
        isUrgent
          ? 'border-primary bg-primary text-primary-foreground'
          : 'border-border bg-card text-foreground'
      )}
    >
      <div className="relative flex flex-col sm:flex-row sm:items-center gap-3">
        {/* Icon and text */}
        <div className="flex items-start sm:items-center gap-3 flex-1 min-w-0">
          <div className={cn(
            'shrink-0 rounded-lg p-2',
            isUrgent ? 'bg-primary-foreground/10' : 'bg-secondary'
          )}>
            <Gift className="h-5 w-5" aria-hidden="true" />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold">
              {isUrgent
                ? 'Running low? Refer a friend for 1 free month!'
                : 'Refer a friend, get 1 month Pro free!'}
            </p>
            <p className={cn(
              'mt-0.5 text-xs',
              isUrgent ? 'text-primary-foreground/80' : 'text-muted-foreground'
            )}>
              {isUrgent
                ? 'Share your link - you both get rewarded.'
                : 'Both you and your friend get 1 month of Pro.'}
            </p>
          </div>
        </div>

        {/* Action buttons */}
        <div className="flex items-center gap-2 shrink-0">
          <button
            type="button"
            onClick={handleCopy}
            className={cn(
              'inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg',
              'text-xs font-medium',
              isUrgent
                ? 'bg-primary-foreground/10 hover:bg-primary-foreground/20'
                : 'bg-secondary hover:bg-secondary/80',
              'transition-colors duration-200'
            )}
          >
            {copied ? (
              <>
                <Check className="h-3.5 w-3.5" />
                Copied!
              </>
            ) : (
              <>
                <Copy className="h-3.5 w-3.5" aria-hidden="true" />
                Copy Link
              </>
            )}
          </button>

          {/* Always show Share: uses navigator.share when available, else clipboard fallback */}
          <button
            type="button"
            onClick={handleShare}
            disabled={isSharing}
            className={cn(
              'inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg',
              'text-xs font-medium',
              isUrgent
                ? 'bg-primary-foreground/10 hover:bg-primary-foreground/20'
                : 'bg-secondary hover:bg-secondary/80',
              'transition-colors duration-200',
              isSharing && 'opacity-70 cursor-wait'
            )}
          >
            <Share2 className="h-3.5 w-3.5" aria-hidden="true" />
            {isSharing ? 'Sharing…' : 'Share'}
          </button>

          {/* Dismiss button - hidden when urgent */}
          {!isUrgent && onDismiss && (
            <button
              type="button"
              onClick={onDismiss}
              className={cn(
                'p-1.5 rounded-lg',
                isUrgent ? 'hover:bg-primary-foreground/10' : 'hover:bg-secondary',
                'transition-colors duration-200'
              )}
              aria-label="Dismiss banner"
            >
              <X className="h-4 w-4" aria-hidden="true" />
            </button>
          )}
        </div>
      </div>
    </div>
  )
}
