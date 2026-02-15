/**
 * ExtractedItemsGrid Component
 *
 * Grid display of all extracted items for review before saving.
 * Shows original image with bounding boxes and item cards.
 */

import { Save, ArrowLeft, AlertTriangle, Check } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import { ExtractedItemCard } from './ExtractedItemCard'
import type { DetectedItem } from '@/types'

interface ExtractedItemsGridProps {
  /** All detected items */
  items: DetectedItem[]
  /** Original image preview URL */
  originalImageUrl?: string | null
  /** Callback when an item is updated */
  onItemUpdate: (tempId: string, updates: Partial<DetectedItem>) => void
  /** Callback when an item is deleted */
  onItemDelete: (tempId: string) => void
  /** Callback to regenerate an item's product image */
  onItemRegenerate: (tempId: string) => void
  /** Callback to save all items */
  onSaveAll: () => void
  /** Callback to go back */
  onBack: () => void
  /** Whether save is in progress */
  isSaving: boolean
  /** Item currently being regenerated */
  regeneratingItemId?: string | null
  /** Optional label for the empty state back button */
  backLabel?: string
}

export function ExtractedItemsGrid({
  items,
  originalImageUrl,
  onItemUpdate,
  onItemDelete,
  onItemRegenerate,
  onSaveAll,
  onBack,
  isSaving,
  regeneratingItemId,
  backLabel,
}: ExtractedItemsGridProps) {
  const activeItems = items.filter((item) => item.status !== 'deleted')
  const includedItems = activeItems.filter((item) => item.includeInWardrobe !== false)
  const failedCount = includedItems.filter((item) => item.status === 'failed').length
  const lowConfidenceCount = includedItems.filter((item) => item.confidence < 0.7).length
  const successCount = includedItems.filter(
    (item) => item.status === 'generated' && item.confidence >= 0.7
  ).length
  const saveableCount = activeItems.filter(
    (item) => item.status === 'generated' && item.includeInWardrobe !== false
  ).length

  const personGroups = Object.values(
    activeItems.reduce<
      Record<
        string,
        {
          key: string
          label: string
          isCurrent: boolean
          total: number
          included: number
          itemIds: string[]
        }
      >
    >((acc, item) => {
      const personKey = `${item.sourceImageId || 'single'}::${item.personId || 'unassigned'}`
      const defaultLabel = item.personLabel || (item.personId ? 'Person' : 'Unassigned')
      if (!acc[personKey]) {
        acc[personKey] = {
          key: personKey,
          label: defaultLabel,
          isCurrent: item.isCurrentUserPerson === true,
          total: 0,
          included: 0,
          itemIds: [],
        }
      }
      acc[personKey].total += 1
      if (item.includeInWardrobe !== false) {
        acc[personKey].included += 1
      }
      acc[personKey].itemIds.push(item.tempId)
      if (item.isCurrentUserPerson === true) {
        acc[personKey].isCurrent = true
      }
      if (item.personLabel) {
        acc[personKey].label = item.personLabel
      }
      return acc
    }, {})
  )

  return (
    <div className="flex flex-col h-full">
      {/* Header with stats */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
        <div className="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-4">
          <h3 className="text-lg font-semibold text-foreground">Review Extracted Items</h3>
          <div className="flex gap-2">
            <Badge variant="secondary" className="bg-green-100 dark:bg-green-900/50 text-green-700 dark:text-green-300">
              <Check className="h-3 w-3 mr-1" />
              {successCount} ready
            </Badge>
            {lowConfidenceCount > 0 && (
              <Badge variant="secondary" className="bg-amber-100 dark:bg-amber-900/50 text-amber-700 dark:text-amber-300">
                <AlertTriangle className="h-3 w-3 mr-1" />
                {lowConfidenceCount} needs review
              </Badge>
            )}
            {failedCount > 0 && (
              <Badge variant="destructive">
                {failedCount} failed
              </Badge>
            )}
          </div>
        </div>
        <p className="text-sm text-muted-foreground">
          {activeItems.length} item{activeItems.length !== 1 ? 's' : ''} detected, {saveableCount} selected to save
        </p>
      </div>

      {personGroups.length > 0 && (
        <div className="mb-4 p-3 rounded-lg border border-border bg-muted/20">
          <p className="text-sm font-medium text-foreground mb-2">People in photo</p>
          <div className="flex flex-wrap gap-2">
            {personGroups.map((group) => (
              <div
                key={group.key}
                className="rounded-md border border-border bg-background px-2 py-1.5 flex items-center gap-2"
              >
                <span className="text-xs font-medium">
                  {group.label}
                  {group.isCurrent ? ' (You)' : ''}
                </span>
                <span className="text-xs text-muted-foreground">{group.included}/{group.total}</span>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  className="h-6 px-2 text-xs"
                  onClick={() => {
                    group.itemIds.forEach((itemId) => {
                      onItemUpdate(itemId, { includeInWardrobe: true })
                    })
                  }}
                >
                  Include
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  className="h-6 px-2 text-xs"
                  onClick={() => {
                    group.itemIds.forEach((itemId) => {
                      onItemUpdate(itemId, { includeInWardrobe: false })
                    })
                  }}
                >
                  Exclude
                </Button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Main content */}
      <div className="flex flex-col lg:flex-row gap-4 lg:gap-6 flex-1 min-h-0">
        {/* Original image with bounding boxes */}
        {originalImageUrl && (
          <div className="w-full lg:w-64 lg:flex-shrink-0">
            <Card className="sticky top-0">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm">Original Image</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="relative">
                  <ZoomableImage
                    src={originalImageUrl}
                    alt="Original"
                    className="w-full rounded-lg"
                  />
                  {/* Bounding box overlays */}
                  <svg
                    className="absolute inset-0 w-full h-full pointer-events-none"
                    viewBox="0 0 100 100"
                    preserveAspectRatio="none"
                  >
                    {activeItems.map((item, index) => {
                      if (!item.boundingBox) return null
                      const { x, y, width, height } = item.boundingBox
                      const colors = [
                        '#3B82F6', '#10B981', '#F59E0B', '#EF4444',
                        '#8B5CF6', '#EC4899', '#06B6D4', '#84CC16',
                      ]
                      const color = colors[index % colors.length]

                      return (
                        <g key={item.tempId}>
                          <rect
                            x={x}
                            y={y}
                            width={width}
                            height={height}
                            fill="none"
                            stroke={color}
                            strokeWidth="0.5"
                            strokeDasharray="2,1"
                          />
                          <rect
                            x={x}
                            y={y}
                            width="8"
                            height="4"
                            fill={color}
                          />
                          <text
                            x={x + 1}
                            y={y + 3}
                            fill="white"
                            fontSize="2.5"
                            fontWeight="bold"
                          >
                            {index + 1}
                          </text>
                        </g>
                      )
                    })}
                  </svg>
                </div>

                {/* Legend */}
                <div className="mt-3 space-y-1">
                  {activeItems.map((item, index) => {
                    const colors = [
                      'bg-blue-500', 'bg-green-500', 'bg-amber-500', 'bg-red-500',
                      'bg-purple-500', 'bg-pink-500', 'bg-cyan-500', 'bg-lime-500',
                    ]
                    return (
                      <div key={item.tempId} className="flex items-center gap-2 text-xs">
                        <div className={`w-3 h-3 rounded ${colors[index % colors.length]}`} />
                        <span className="truncate">
                          {item.name || item.sub_category || item.category}
                        </span>
                      </div>
                    )
                  })}
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Items grid */}
        <div className="flex-1 min-w-0 overflow-y-auto">
          {activeItems.length === 0 ? (
            <Card className="p-8 text-center">
              <p className="text-muted-foreground mb-4">No items to save</p>
              <Button variant="outline" onClick={onBack}>
                <ArrowLeft className="h-4 w-4 mr-2" />
                {backLabel || 'Upload Different Image'}
              </Button>
            </Card>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3 lg:gap-4">
              {activeItems.map((item) => (
                <ExtractedItemCard
                  key={item.tempId}
                  item={item}
                  onUpdate={onItemUpdate}
                  onDelete={onItemDelete}
                  onRegenerate={onItemRegenerate}
                  isRegenerating={regeneratingItemId === item.tempId}
                />
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Footer actions */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-4 border-t border-border mt-4">
        <Button variant="outline" onClick={onBack} disabled={isSaving}>
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back
        </Button>

        <div className="flex gap-3">
          {failedCount > 0 && (
            <p className="text-sm text-amber-600 dark:text-amber-400 flex items-center">
              <AlertTriangle className="h-4 w-4 mr-1" />
              {failedCount} item(s) will be skipped
            </p>
          )}
          <Button
            onClick={onSaveAll}
            disabled={isSaving || saveableCount === 0}
            className="gap-2"
          >
            {isSaving ? (
              <>Saving...</>
            ) : (
              <>
                <Save className="h-4 w-4" />
                Save All ({saveableCount})
              </>
            )}
          </Button>
        </div>
      </div>
    </div>
  )
}

export default ExtractedItemsGrid
