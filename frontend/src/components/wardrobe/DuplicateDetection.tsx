/**
 * DuplicateDetection Component
 *
 * Displays potential duplicate items detected when adding a new item.
 * Uses AI embeddings for similarity matching with fallback to text-based matching.
 */

import { useState, useEffect, useCallback } from 'react'
import { AlertTriangle, X, ExternalLink, Copy, Check } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import {
  Alert,
  AlertDescription,
  AlertTitle,
} from '@/components/ui/alert'
import { checkDuplicates, type DuplicateItem, type DuplicateCheckRequest } from '@/api/items'

interface DuplicateDetectionProps {
  /** Item data to check for duplicates */
  itemData: DuplicateCheckRequest
  /** Called when user dismisses duplicates and wants to continue adding */
  onContinue: () => void
  /** Called when user wants to view an existing duplicate */
  onViewExisting?: (itemId: string) => void
  /** Called when user cancels adding the item */
  onCancel?: () => void
  /** Whether to auto-check on mount */
  autoCheck?: boolean
  /** Similarity threshold (0.5 - 0.99) */
  threshold?: number
}

interface DuplicateCardProps {
  duplicate: DuplicateItem
  onView?: (id: string) => void
}

function DuplicateCard({ duplicate, onView }: DuplicateCardProps) {
  const similarityPercent = Math.round(duplicate.similarity_score * 100)

  const getSimilarityColor = (score: number) => {
    if (score >= 0.9) return 'text-red-600 dark:text-red-400'
    if (score >= 0.8) return 'text-orange-600 dark:text-orange-400'
    return 'text-yellow-600 dark:text-yellow-400'
  }

  const getSimilarityBg = (score: number) => {
    if (score >= 0.9) return 'bg-red-100 dark:bg-red-900/30'
    if (score >= 0.8) return 'bg-orange-100 dark:bg-orange-900/30'
    return 'bg-yellow-100 dark:bg-yellow-900/30'
  }

  return (
    <Card className="overflow-hidden">
      <CardContent className="p-0">
        <div className="flex gap-3 p-3">
          {/* Thumbnail */}
          <div className="w-16 h-16 flex-shrink-0 rounded-md overflow-hidden bg-muted">
            {duplicate.image_url ? (
              <img
                src={duplicate.image_url}
                alt={duplicate.name}
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-muted-foreground">
                <Copy className="h-6 w-6" />
              </div>
            )}
          </div>

          {/* Details */}
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2">
              <div className="min-w-0">
                <h4 className="font-medium text-sm truncate text-foreground">
                  {duplicate.name}
                </h4>
                <p className="text-xs text-muted-foreground">
                  {duplicate.category}
                  {duplicate.sub_category && ` • ${duplicate.sub_category}`}
                </p>
              </div>
              <Badge
                className={`flex-shrink-0 ${getSimilarityBg(duplicate.similarity_score)} ${getSimilarityColor(duplicate.similarity_score)} border-0`}
              >
                {similarityPercent}% match
              </Badge>
            </div>

            {/* Color badges */}
            {duplicate.colors.length > 0 && (
              <div className="flex flex-wrap gap-1 mt-1.5">
                {duplicate.colors.slice(0, 3).map((color) => (
                  <Badge key={color} variant="outline" className="text-xs px-1.5 py-0">
                    {color}
                  </Badge>
                ))}
                {duplicate.colors.length > 3 && (
                  <Badge variant="outline" className="text-xs px-1.5 py-0">
                    +{duplicate.colors.length - 3}
                  </Badge>
                )}
              </div>
            )}

            {/* Reasons */}
            {duplicate.reasons.length > 0 && (
              <div className="mt-2 space-y-0.5">
                {duplicate.reasons.slice(0, 2).map((reason, idx) => (
                  <p key={idx} className="text-xs text-muted-foreground">
                    • {reason}
                  </p>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Actions */}
        {onView && (
          <div className="px-3 pb-3">
            <Button
              variant="outline"
              size="sm"
              className="w-full h-7 text-xs"
              onClick={() => onView(duplicate.id)}
            >
              <ExternalLink className="h-3 w-3 mr-1" />
              View existing item
            </Button>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

export function DuplicateDetection({
  itemData,
  onContinue,
  onViewExisting,
  onCancel,
  autoCheck = true,
  threshold = 0.75,
}: DuplicateDetectionProps) {
  const [isChecking, setIsChecking] = useState(false)
  const [duplicates, setDuplicates] = useState<DuplicateItem[]>([])
  const [error, setError] = useState<string | null>(null)
  const [hasChecked, setHasChecked] = useState(false)

  const performCheck = useCallback(async () => {
    if (!itemData.name || !itemData.category) {
      return
    }

    setIsChecking(true)
    setError(null)

    try {
      const result = await checkDuplicates(itemData, { threshold, limit: 5 })
      setDuplicates(result.duplicates)
      setHasChecked(true)
    } catch (err) {
      console.error('Duplicate check failed:', err)
      setError('Could not check for duplicates. You can continue adding the item.')
      setHasChecked(true)
    } finally {
      setIsChecking(false)
    }
  }, [itemData, threshold])

  useEffect(() => {
    if (autoCheck && !hasChecked && itemData.name && itemData.category) {
      performCheck()
    }
  }, [autoCheck, itemData.name, itemData.category, hasChecked, performCheck])

  // Loading state
  if (isChecking) {
    return (
      <Card className="border-navy-200 dark:border-navy-800 bg-navy-50/50 dark:bg-navy-900/20">
        <CardContent className="py-6">
          <div className="flex flex-col items-center gap-3">
            <div className="animate-pulse">
              <Copy className="h-8 w-8 text-navy-500" />
            </div>
            <p className="text-sm text-muted-foreground">
              Checking for similar items in your wardrobe...
            </p>
            <Progress value={50} className="w-48 h-1" />
          </div>
        </CardContent>
      </Card>
    )
  }

  // Error state
  if (error) {
    return (
      <Alert>
        <AlertTriangle className="h-4 w-4" />
        <AlertTitle>Check Failed</AlertTitle>
        <AlertDescription className="flex items-center justify-between">
          <span>{error}</span>
          <Button variant="outline" size="sm" onClick={onContinue}>
            Continue Anyway
          </Button>
        </AlertDescription>
      </Alert>
    )
  }

  // No duplicates found
  if (hasChecked && duplicates.length === 0) {
    return (
      <Alert className="border-green-200 dark:border-green-800 bg-green-50/50 dark:bg-green-900/20">
        <Check className="h-4 w-4 text-green-600" />
        <AlertTitle className="text-green-800 dark:text-green-200">No duplicates found</AlertTitle>
        <AlertDescription className="text-green-700 dark:text-green-300">
          This item appears to be unique in your wardrobe.
        </AlertDescription>
      </Alert>
    )
  }

  // Duplicates found
  if (duplicates.length > 0) {
    const highSimilarity = duplicates.some(d => d.similarity_score >= 0.9)

    return (
      <Card className={`${highSimilarity ? 'border-red-300 dark:border-red-800' : 'border-amber-300 dark:border-amber-700'}`}>
        <CardHeader className="pb-3">
          <div className="flex items-start gap-3">
            <div className={`p-2 rounded-full ${highSimilarity ? 'bg-red-100 dark:bg-red-900/30' : 'bg-amber-100 dark:bg-amber-900/30'}`}>
              <AlertTriangle className={`h-5 w-5 ${highSimilarity ? 'text-red-600 dark:text-red-400' : 'text-amber-600 dark:text-amber-400'}`} />
            </div>
            <div className="flex-1">
              <CardTitle className="text-base">
                {highSimilarity ? 'Possible Duplicate Detected' : 'Similar Items Found'}
              </CardTitle>
              <p className="text-sm text-muted-foreground mt-0.5">
                {duplicates.length === 1
                  ? 'We found 1 similar item in your wardrobe'
                  : `We found ${duplicates.length} similar items in your wardrobe`}
              </p>
            </div>
            {onCancel && (
              <Button variant="ghost" size="icon" className="h-8 w-8" onClick={onCancel}>
                <X className="h-4 w-4" />
              </Button>
            )}
          </div>
        </CardHeader>

        <CardContent className="space-y-3">
          {/* Duplicate cards */}
          <div className="space-y-2">
            {duplicates.map((duplicate) => (
              <DuplicateCard
                key={duplicate.id}
                duplicate={duplicate}
                onView={onViewExisting}
              />
            ))}
          </div>

          {/* Actions */}
          <div className="flex gap-2 pt-2">
            {onCancel && (
              <Button
                variant="outline"
                className="flex-1"
                onClick={onCancel}
              >
                Cancel
              </Button>
            )}
            <Button
              className="flex-1"
              onClick={onContinue}
            >
              Add Anyway
            </Button>
          </div>
        </CardContent>
      </Card>
    )
  }

  // Initial state - manual check trigger
  return (
    <Button
      variant="outline"
      size="sm"
      onClick={performCheck}
      disabled={!itemData.name || !itemData.category}
    >
      <Copy className="h-4 w-4 mr-2" />
      Check for duplicates
    </Button>
  )
}

export default DuplicateDetection
