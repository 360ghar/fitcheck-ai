/**
 * GenerationProgress Component
 *
 * Shows progress during the product image generation phase.
 * Displays items being processed and thumbnails as they complete.
 * Supports parallel processing where multiple items generate simultaneously.
 */

import { Loader2, Check, X, ImageIcon } from 'lucide-react'
import { Progress } from '@/components/ui/progress'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import type { DetectedItem } from '@/types'

interface GenerationProgressProps {
  /** All detected items */
  items: DetectedItem[]
  /** Number of items completed (success or failure) */
  completedCount: number
  /** Set of item tempIds currently being processed (for parallel mode) */
  processingItems?: Set<string>
  /** Progress percentage (0-100) */
  progress: number
  /** @deprecated Use processingItems instead for parallel mode */
  currentIndex?: number
}

export function GenerationProgress({
  items,
  completedCount,
  processingItems,
  progress,
  currentIndex, // Kept for backwards compatibility
}: GenerationProgressProps) {
  // Get status based on item's own status field (works for both sequential and parallel)
  const getItemStatus = (item: DetectedItem, index: number) => {
    // Primary check: use the item's actual status
    if (item.status === 'generated') return 'completed'
    if (item.status === 'failed') return 'failed'

    // For parallel mode: check if item is in processing set
    if (processingItems?.has(item.tempId)) return 'processing'

    // For parallel mode: if item is 'generating' status
    if (item.status === 'generating') return 'processing'

    // Legacy sequential mode fallback
    if (currentIndex !== undefined && index === currentIndex) return 'processing'

    return 'pending'
  }

  // Count items currently processing
  const activeCount =
    processingItems?.size ??
    items.filter((i) => i.status === 'generating').length ??
    (currentIndex !== undefined ? 1 : 0)

  return (
    <div className="space-y-6">
      {/* Overall progress */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-lg flex items-center gap-2">
            <ImageIcon className="h-5 w-5 text-indigo-500" />
            Generating Product Images
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between text-sm">
            <span className="flex items-center gap-2 text-gray-700 dark:text-gray-300">
              <Loader2 className="h-4 w-4 animate-spin" />
              {activeCount > 1
                ? `Processing ${activeCount} items in parallel...`
                : 'Creating e-commerce style images...'}
            </span>
            <span className="font-medium text-gray-900 dark:text-white">
              {completedCount} of {items.length}
            </span>
          </div>
          <Progress value={progress} className="h-2" />
        </CardContent>
      </Card>

      {/* Item thumbnails grid */}
      <div className="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 gap-3">
        {items.map((item, index) => {
          const status = getItemStatus(item, index)

          return (
            <div
              key={item.tempId}
              className={`relative aspect-square rounded-lg border-2 overflow-hidden ${
                status === 'completed'
                  ? 'border-green-400 dark:border-green-500'
                  : status === 'failed'
                  ? 'border-red-400 dark:border-red-500'
                  : status === 'processing'
                  ? 'border-indigo-400 dark:border-indigo-500 ring-2 ring-indigo-200 dark:ring-indigo-800'
                  : 'border-gray-200 dark:border-gray-700'
              }`}
            >
              {/* Show generated image if available, otherwise placeholder */}
              {item.generatedImageUrl ? (
                <img
                  src={item.generatedImageUrl}
                  alt={item.sub_category || item.category}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center">
                  {status === 'processing' ? (
                    <Loader2 className="h-6 w-6 animate-spin text-indigo-500" />
                  ) : (
                    <ImageIcon className="h-6 w-6 text-gray-300 dark:text-gray-500" />
                  )}
                </div>
              )}

              {/* Status indicator */}
              <div className="absolute top-1 right-1">
                {status === 'completed' && (
                  <div className="bg-green-500 rounded-full p-0.5">
                    <Check className="h-3 w-3 text-white" />
                  </div>
                )}
                {status === 'failed' && (
                  <div className="bg-red-500 rounded-full p-0.5">
                    <X className="h-3 w-3 text-white" />
                  </div>
                )}
                {status === 'processing' && (
                  <div className="bg-indigo-500 rounded-full p-0.5">
                    <Loader2 className="h-3 w-3 text-white animate-spin" />
                  </div>
                )}
              </div>

              {/* Category label */}
              <div className="absolute bottom-0 inset-x-0 bg-gradient-to-t from-black/60 to-transparent p-1">
                <p className="text-[10px] text-white truncate text-center">
                  {item.sub_category || item.category}
                </p>
              </div>
            </div>
          )
        })}
      </div>

      {/* Generation info */}
      <p className="text-center text-sm text-gray-500 dark:text-gray-400">
        {activeCount > 1
          ? `Generating ${activeCount} images in parallel for faster processing`
          : 'Using AI to create professional product photos'}
      </p>
    </div>
  )
}

export default GenerationProgress
