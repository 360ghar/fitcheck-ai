/**
 * Dashboard Page
 * Overview of user's wardrobe, outfits, and recommendations.
 * Empty / partial accounts get an activation checklist first.
 */

import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useWardrobeStore } from '../stores/wardrobeStore'
import { useOutfitStore } from '../stores/outfitStore'
import { useUserAvatar, useUserDisplayName, useCurrentUser } from '../stores/authStore'
import { useIsNearLimit } from '../stores/subscriptionStore'
import { useJobUiStore } from '../stores/jobUiStore'
import {
  Shirt,
  Layers,
  Sparkles,
  TrendingUp,
  Calendar,
  Plus,
  ArrowRight,
  Heart,
  Camera,
  Wand2,
} from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'
import { StatCard } from '@/components/dashboard/StatCard'
import { ReferralBanner, useReferralBannerDismissal } from '@/components/dashboard/ReferralBanner'
import { ActivationChecklist } from '@/components/dashboard/ActivationChecklist'
import { ItemUpload, type ItemUploadResult } from '@/components/wardrobe/ItemUpload'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import {
  activationDismissKey,
  shouldShowActivation,
  tryOnUsedKey,
  type ActivationInput,
} from '@/lib/activation'
import type { BatchJobUiStatus } from '@/types'

const aiTools = [
  {
    name: 'Photoshoot',
    description: 'Pro-style portraits',
    icon: Camera,
    link: '/photoshoot',
  },
  {
    name: 'Try On',
    description: 'See clothes on you',
    icon: Wand2,
    link: '/try-on',
  },
  {
    name: 'What to wear',
    description: 'Daily outfit ideas',
    icon: Sparkles,
    link: '/recommendations',
  },
  {
    name: 'Calendar',
    description: 'Plan looks ahead',
    icon: Calendar,
    link: '/calendar',
  },
]

export default function DashboardPage() {
  const userDisplayName = useUserDisplayName()
  const user = useCurrentUser()
  const userAvatar = useUserAvatar()
  const items = useWardrobeStore((state) => state.items)
  const outfits = useOutfitStore((state) => state.outfits)
  const fetchItems = useWardrobeStore((state) => state.fetchItems)
  const fetchOutfits = useOutfitStore((state) => state.fetchOutfits)
  const isLoadingItems = useWardrobeStore((state) => state.isLoading)
  const isLoadingOutfits = useOutfitStore((state) => state.isLoading)

  const [isUploadModalOpen, setIsUploadModalOpen] = useState(false)
  const setJob = useJobUiStore((s) => s.setJob)
  const clearJob = useJobUiStore((s) => s.clearJob)
  const lastBatchStatusRef = useRef<BatchJobUiStatus | null>(null)
  const navigate = useNavigate()

  const { isDismissed: isBannerDismissed, dismiss: dismissBanner } = useReferralBannerDismissal()
  const nearLimit = useIsNearLimit()
  const isNearLimit = nearLimit.extractions || nearLimit.generations
  const shouldShowReferralBanner = !isBannerDismissed || isNearLimit

  const [activationDismissed, setActivationDismissed] = useState(() => {
    try {
      return localStorage.getItem(activationDismissKey(user?.id)) === '1'
    } catch {
      return false
    }
  })

  useEffect(() => {
    try {
      setActivationDismissed(localStorage.getItem(activationDismissKey(user?.id)) === '1')
    } catch {
      setActivationDismissed(false)
    }
  }, [user?.id])

  useEffect(() => {
    fetchItems(true)
    fetchOutfits(true)
  }, [fetchItems, fetchOutfits])

  const totalItems = items.length
  const totalOutfits = outfits.length
  const favoriteItems = items.filter((i) => i.is_favorite).length
  const totalWears = items.reduce((sum, item) => sum + item.usage_times_worn, 0)

  const tryOnUsed = useMemo(() => {
    try {
      return localStorage.getItem(tryOnUsedKey(user?.id)) === '1'
    } catch {
      return false
    }
  }, [user?.id, userAvatar, totalItems, totalOutfits])

  const activationInput: ActivationInput = useMemo(
    () => ({
      itemCount: totalItems,
      outfitCount: totalOutfits,
      hasAvatar: Boolean(userAvatar),
      tryOnUsed,
    }),
    [totalItems, totalOutfits, userAvatar, tryOnUsed]
  )

  const isLoadingHome = isLoadingItems || isLoadingOutfits
  // Avoid flashing activation chrome for returning users while stores rehydrate.
  const dataReady = !isLoadingHome || totalItems > 0 || totalOutfits > 0
  const showActivation =
    dataReady && shouldShowActivation(activationInput, activationDismissed)
  const isEmpty = dataReady && totalItems === 0 && totalOutfits === 0

  const publishedBatchJobIdRef = useRef<string | null>(null)

  const publishBatchJob = useCallback(
    (status: BatchJobUiStatus | null, dialogOpen: boolean) => {
      lastBatchStatusRef.current = status
      if (!status) {
        if (publishedBatchJobIdRef.current) {
          clearJob(publishedBatchJobIdRef.current)
          publishedBatchJobIdRef.current = null
        }
        return
      }
      const jobId = status.jobId || 'batch-upload'
      if (dialogOpen) {
        clearJob(jobId)
        publishedBatchJobIdRef.current = jobId
        return
      }
      publishedBatchJobIdRef.current = jobId
      setJob({
        id: jobId,
        label: status.label,
        isActive: status.isProcessing || status.isGenerationRunning,
        etaSeconds: status.generationEtaSeconds,
        href: '/dashboard',
        onOpen: () => setIsUploadModalOpen(true),
      })
    },
    [clearJob, setJob]
  )

  useEffect(() => {
    publishBatchJob(lastBatchStatusRef.current, isUploadModalOpen)
  }, [isUploadModalOpen, publishBatchJob])

  const handleUploadComplete = (results: ItemUploadResult[]) => {
    if (publishedBatchJobIdRef.current) {
      clearJob(publishedBatchJobIdRef.current)
      publishedBatchJobIdRef.current = null
    }
    lastBatchStatusRef.current = null
    setIsUploadModalOpen(false)
    fetchItems(true)
    if (results.some((r) => r.success)) {
      // Stay on dashboard while activating so the checklist updates;
      // once they already have outfits, wardrobe is a better home for new items.
      if (totalOutfits > 0) {
        navigate('/wardrobe')
      }
    }
  }

  const handleDismissActivation = () => {
    try {
      localStorage.setItem(activationDismissKey(user?.id), '1')
    } catch {
      // ignore
    }
    setActivationDismissed(true)
  }

  const stats = [
    {
      name: 'Total Items',
      value: totalItems,
      icon: Shirt,
      gradient: 'cool' as const,
      link: '/wardrobe',
    },
    {
      name: 'Outfits Created',
      value: totalOutfits,
      icon: Layers,
      gradient: 'primary' as const,
      link: '/outfits',
    },
    {
      name: 'Total Wears',
      value: totalWears,
      icon: TrendingUp,
      gradient: 'success' as const,
      link: '/wardrobe',
    },
    {
      name: 'Favorites',
      value: favoriteItems,
      icon: Heart,
      gradient: 'warm' as const,
      link: '/wardrobe?favorites=true',
    },
  ]

  const quickActions = [
    {
      name: 'Add Item',
      description: 'Upload photos — AI catalogs each piece',
      icon: Shirt,
      onClick: () => setIsUploadModalOpen(true),
    },
    {
      name: 'Create Outfit',
      description: 'Combine items into a wearable look',
      icon: Layers,
      link: '/outfits?action=create',
    },
    {
      name: 'What to wear',
      description: 'AI outfit ideas from your wardrobe',
      icon: Sparkles,
      link: '/recommendations',
    },
  ]

  return (
    <div className="w-full max-w-7xl mx-auto px-4 md:px-6 lg:px-8 py-4 md:py-8">
      {/* Welcome header */}
      <div className="mb-4 md:mb-8">
        <h1 className="text-xl md:text-3xl font-bold text-foreground">
          {isEmpty ? `Welcome, ${userDisplayName}` : `Welcome back, ${userDisplayName}`}
        </h1>
        <p className="mt-1 md:mt-2 text-xs md:text-base text-muted-foreground">
          {isEmpty
            ? 'Start with a few clothing photos. AI finds each item so you can build outfits today.'
            : "Here's what's happening with your wardrobe today."}
        </p>
        {isEmpty && (
          <Button className="mt-4" onClick={() => setIsUploadModalOpen(true)}>
            <Plus className="h-4 w-4 mr-2" />
            Add your first photos
          </Button>
        )}
      </div>

      {shouldShowReferralBanner && (
        <div className="mb-4 md:mb-6">
          <ReferralBanner
            variant={isNearLimit ? 'urgent' : 'default'}
            onDismiss={dismissBanner}
          />
        </div>
      )}

      {/* Activation — primary surface for new / partial accounts */}
      {showActivation && (
        <div className="mb-6 md:mb-8">
          <ActivationChecklist
            input={activationInput}
            onAddItems={() => setIsUploadModalOpen(true)}
            onCreateOutfit={() => navigate('/outfits?action=create')}
            onAddAvatar={() => navigate('/profile?tab=account')}
            onTryOn={() => navigate('/try-on')}
            onDismiss={handleDismissActivation}
          />
        </div>
      )}

      {/* How it works — empty accounts only */}
      {isEmpty && (
        <div className="mb-6 md:mb-8 rounded-xl border border-border bg-muted/20 px-4 py-4 md:px-6">
          <h2 className="text-sm font-semibold text-foreground mb-3">How it works</h2>
          <ol className="space-y-2 text-sm text-muted-foreground">
            <li>
              <span className="font-medium text-foreground">1. Upload</span> — closet shots or
              outfit photos
            </li>
            <li>
              <span className="font-medium text-foreground">2. Extract</span> — AI catalogs each
              item (studio photos polish in the background)
            </li>
            <li>
              <span className="font-medium text-foreground">3. Outfit</span> — mix pieces and
              generate looks
            </li>
          </ol>
        </div>
      )}

      {/* Stats — de-emphasize when empty */}
      {!isEmpty && (
        <div className="grid grid-cols-2 gap-3 md:grid-cols-4 md:gap-4 lg:gap-5 mb-6 md:mb-8">
          {stats.map((stat) => (
            <StatCard
              key={stat.name}
              name={stat.name}
              value={stat.value}
              icon={stat.icon}
              gradient={stat.gradient}
              link={stat.link}
              isLoading={isLoadingItems || isLoadingOutfits}
            />
          ))}
        </div>
      )}

      {/* AI tools */}
      <div className="mb-6 md:mb-8">
        <div className="flex items-center justify-between mb-3 md:mb-4 px-1">
          <h2 className="text-base md:text-lg font-semibold text-foreground">AI tools</h2>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 md:gap-3">
          {aiTools.map((tool) => (
            <Link
              key={tool.name}
              to={tool.link}
              className={cn(
                'flex flex-col gap-2 rounded-xl border border-border bg-card p-3 md:p-4',
                'hover:bg-accent/50 hover:border-primary/20 transition-colors',
                'touch-target'
              )}
            >
              <tool.icon className="h-5 w-5 text-foreground" />
              <div>
                <p className="text-sm font-semibold text-foreground">{tool.name}</p>
                <p className="text-xs text-muted-foreground line-clamp-1">{tool.description}</p>
              </div>
            </Link>
          ))}
        </div>
      </div>

      {/* Quick actions — tonal cards, not purple gradient slabs */}
      <div className="mb-6 md:mb-8">
        <div className="flex items-center justify-between mb-3 md:mb-4 px-1">
          <h2 className="text-base md:text-lg font-semibold text-foreground">Quick actions</h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 md:gap-4">
          {quickActions.map((action) => {
            const commonClassName = cn(
              'group relative rounded-xl border border-border bg-card p-4 md:p-5 text-left w-full',
              'transition-colors hover:bg-accent/40 hover:border-primary/20',
              'touch-target'
            )

            const content = (
              <div className="relative flex items-start gap-3 md:gap-4">
                <action.icon className="h-5 w-5 md:h-6 md:w-6 text-foreground shrink-0 mt-0.5" />
                <div className="flex-1 min-w-0">
                  <h3 className="text-sm md:text-base font-semibold text-foreground">
                    {action.name}
                  </h3>
                  <p className="mt-0.5 text-xs md:text-sm text-muted-foreground line-clamp-2">
                    {action.description}
                  </p>
                </div>
                <ArrowRight
                  className={cn(
                    'h-5 w-5 shrink-0 text-muted-foreground opacity-50',
                    'transition-all duration-200',
                    'group-hover:opacity-100 group-hover:translate-x-0.5'
                  )}
                />
              </div>
            )

            if (action.onClick) {
              return (
                <button
                  key={action.name}
                  type="button"
                  onClick={action.onClick}
                  className={commonClassName}
                >
                  {content}
                </button>
              )
            }

            return (
              <Link key={action.name} to={action.link!} className={commonClassName}>
                {content}
              </Link>
            )
          })}
        </div>
      </div>

      {/* Recent activity — only when there is something to show */}
      {totalItems > 0 && (
        <div className="bg-card border border-border rounded-xl overflow-hidden">
          <div className="px-4 py-4 md:py-5 md:px-6 border-b border-border">
            <div className="flex items-center justify-between">
              <h3 className="text-base md:text-lg font-semibold text-foreground">Recent items</h3>
              {totalItems > 0 && totalOutfits === 0 && (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => navigate('/outfits?action=create')}
                >
                  Create outfit
                </Button>
              )}
            </div>
          </div>
          <div className="px-4 py-4 md:p-6">
            <div className="space-y-2 md:space-y-3">
              {items.slice(0, 3).map((item) => (
                <Link
                  key={item.id}
                  to={`/wardrobe/${item.id}`}
                  className={cn(
                    'flex items-center p-2.5 md:p-3 rounded-xl',
                    'hover:bg-accent/50 transition-colors',
                    'touch-target group'
                  )}
                >
                  {item.images.length > 0 ? (
                    <img
                      src={item.images[0].thumbnail_url || item.images[0].image_url}
                      alt={item.name}
                      className="h-12 w-12 md:h-14 md:w-14 rounded-lg object-cover"
                    />
                  ) : (
                    <div className="h-12 w-12 md:h-14 md:w-14 rounded-lg bg-muted flex items-center justify-center">
                      <Shirt className="h-5 w-5 md:h-6 md:w-6 text-muted-foreground" />
                    </div>
                  )}
                  <div className="ml-3 md:ml-4 flex-1 min-w-0">
                    <p className="text-sm font-medium text-foreground truncate">{item.name}</p>
                    <p className="text-xs md:text-sm text-muted-foreground capitalize">
                      {item.category}
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-muted-foreground shrink-0">
                      {new Date(item.created_at).toLocaleDateString()}
                    </span>
                    <ArrowRight className="h-4 w-4 text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity" />
                  </div>
                </Link>
              ))}
            </div>
          </div>
        </div>
      )}

      <ItemUpload
        isOpen={isUploadModalOpen}
        onClose={() => setIsUploadModalOpen(false)}
        onUploadComplete={handleUploadComplete}
        onRequestOpen={() => setIsUploadModalOpen(true)}
        onJobStatusChange={(status) => publishBatchJob(status, isUploadModalOpen)}
      />
    </div>
  )
}
