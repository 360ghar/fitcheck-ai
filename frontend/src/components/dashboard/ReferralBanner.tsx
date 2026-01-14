/**
 * Referral Banner Component
 * Promotional banner encouraging users to refer friends for free Pro month
 */

import { useState, useEffect } from 'react'
import { Gift, Copy, Share2, X, Check } from 'lucide-react'
import { cn } from '@/lib/utils'
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
  const [canShare, setCanShare] = useState(false)
  const referralCode = useSubscriptionStore((state) => state.referralCode)
  const copyReferralLink = useSubscriptionStore((state) => state.copyReferralLink)
  const fetchReferralCode = useSubscriptionStore((state) => state.fetchReferralCode)

  useEffect(() => {
    // Check if Web Share API is available
    setCanShare(!!navigator.share)
    // Fetch referral code if not already loaded
    if (!referralCode) {
      fetchReferralCode()
    }
  }, [referralCode, fetchReferralCode])

  const handleCopy = async () => {
    const success = await copyReferralLink()
    if (success) {
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }

  const handleShare = async () => {
    if (!referralCode?.share_url) return
    try {
      await navigator.share({
        title: 'Join FitCheck AI',
        text: 'Sign up with my link and we both get 1 month of Pro free!',
        url: referralCode.share_url,
      })
    } catch {
      // User cancelled or share failed - silently ignore
    }
  }

  const isUrgent = variant === 'urgent'

  return (
    <div
      className={cn(
        'relative rounded-xl p-4 text-white overflow-hidden',
        'transition-all duration-300',
        isUrgent
          ? 'bg-gradient-to-r from-amber-500 via-indigo-600 to-purple-600'
          : 'bg-gradient-to-r from-indigo-600 to-purple-600'
      )}
    >
      {/* Background glow effect */}
      <div className="absolute inset-0 bg-white/5" />

      <div className="relative flex flex-col sm:flex-row sm:items-center gap-3">
        {/* Icon and text */}
        <div className="flex items-start sm:items-center gap-3 flex-1 min-w-0">
          <div className="p-2 rounded-lg bg-white/20 backdrop-blur-sm shrink-0">
            <Gift className="h-5 w-5" />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold">
              {isUrgent
                ? 'Running low? Refer a friend for 1 free month!'
                : 'Refer a friend, get 1 month Pro free!'}
            </p>
            <p className="text-xs text-white/80 mt-0.5">
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
              'bg-white/20 hover:bg-white/30 backdrop-blur-sm',
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
                <Copy className="h-3.5 w-3.5" />
                Copy Link
              </>
            )}
          </button>

          {canShare && (
            <button
              type="button"
              onClick={handleShare}
              className={cn(
                'inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg',
                'text-xs font-medium',
                'bg-white/20 hover:bg-white/30 backdrop-blur-sm',
                'transition-colors duration-200'
              )}
            >
              <Share2 className="h-3.5 w-3.5" />
              Share
            </button>
          )}

          {/* Dismiss button - hidden when urgent */}
          {!isUrgent && onDismiss && (
            <button
              type="button"
              onClick={onDismiss}
              className={cn(
                'p-1.5 rounded-lg',
                'hover:bg-white/20',
                'transition-colors duration-200'
              )}
              aria-label="Dismiss banner"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>
      </div>
    </div>
  )
}
