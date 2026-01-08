/**
 * ExtractedItemCard Component
 *
 * Individual card for displaying and editing a detected clothing item.
 * Shows generated product image, extracted metadata, and editing controls.
 */

import { useState } from 'react'
import {
  Trash2,
  RefreshCw,
  AlertTriangle,
  Check,
  Edit2,
  ChevronDown,
  ChevronUp,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import type { DetectedItem, Category } from '@/types'

interface ExtractedItemCardProps {
  /** The detected item data */
  item: DetectedItem
  /** Callback when item is updated */
  onUpdate: (tempId: string, updates: Partial<DetectedItem>) => void
  /** Callback when item is deleted */
  onDelete: (tempId: string) => void
  /** Callback to regenerate product image */
  onRegenerate: (tempId: string) => void
  /** Whether regeneration is in progress */
  isRegenerating?: boolean
}

const CATEGORIES: { value: Category; label: string }[] = [
  { value: 'tops', label: 'Tops' },
  { value: 'bottoms', label: 'Bottoms' },
  { value: 'shoes', label: 'Shoes' },
  { value: 'accessories', label: 'Accessories' },
  { value: 'outerwear', label: 'Outerwear' },
  { value: 'swimwear', label: 'Swimwear' },
  { value: 'activewear', label: 'Activewear' },
  { value: 'other', label: 'Other' },
]

const COMMON_COLORS = [
  'black', 'white', 'gray', 'navy', 'brown', 'beige',
  'red', 'blue', 'green', 'yellow', 'pink', 'purple',
]

export function ExtractedItemCard({
  item,
  onUpdate,
  onDelete,
  onRegenerate,
  isRegenerating = false,
}: ExtractedItemCardProps) {
  const [isExpanded, setIsExpanded] = useState(false)
  const [showConfirmDelete, setShowConfirmDelete] = useState(false)

  const isLowConfidence = item.confidence < 0.7
  const hasFailed = item.status === 'failed'

  const toggleColor = (color: string) => {
    const colors = item.colors.includes(color)
      ? item.colors.filter((c) => c !== color)
      : [...item.colors, color]
    onUpdate(item.tempId, { colors })
  }

  const generateDefaultName = () => {
    const parts: string[] = []
    if (item.colors[0]) parts.push(item.colors[0])
    if (item.sub_category) parts.push(item.sub_category)
    else if (item.category) parts.push(item.category)
    return parts.map(p => p.charAt(0).toUpperCase() + p.slice(1)).join(' ') || 'New Item'
  }

  return (
    <Card
      className={`overflow-hidden transition-all ${
        hasFailed
          ? 'border-red-300 dark:border-red-800 bg-red-50/50 dark:bg-red-900/20'
          : isLowConfidence
          ? 'border-amber-300 dark:border-amber-700 bg-amber-50/30 dark:bg-amber-900/20'
          : 'border-gray-200 dark:border-gray-700'
      }`}
    >
      <CardContent className="p-0">
        {/* Image Section */}
        <div className="relative aspect-square bg-gray-100 dark:bg-gray-700">
          {item.generatedImageUrl ? (
            <img
              src={item.generatedImageUrl}
              alt={item.sub_category || item.category}
              className="w-full h-full object-cover"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center text-gray-400 dark:text-gray-500">
              {hasFailed ? (
                <AlertTriangle className="h-8 w-8 text-red-400" />
              ) : (
                <div className="text-center">
                  <div className="h-8 w-8 mx-auto mb-2 border-2 border-gray-300 dark:border-gray-500 border-dashed rounded" />
                  <span className="text-xs">No image</span>
                </div>
              )}
            </div>
          )}

          {/* Status badges */}
          <div className="absolute top-2 left-2 flex flex-col gap-1">
            {isLowConfidence && !hasFailed && (
              <Badge variant="outline" className="bg-amber-100 dark:bg-amber-900/50 text-amber-700 dark:text-amber-300 border-amber-300 dark:border-amber-700">
                <AlertTriangle className="h-3 w-3 mr-1" />
                Review
              </Badge>
            )}
            {hasFailed && (
              <Badge variant="destructive">
                Failed
              </Badge>
            )}
          </div>

          {/* Action buttons */}
          <div className="absolute top-2 right-2 flex gap-1">
            <Button
              variant="secondary"
              size="icon"
              className="h-7 w-7 bg-white/90 dark:bg-gray-800/90 hover:bg-white dark:hover:bg-gray-700"
              onClick={() => onRegenerate(item.tempId)}
              disabled={isRegenerating}
            >
              <RefreshCw className={`h-3.5 w-3.5 ${isRegenerating ? 'animate-spin' : ''}`} />
            </Button>
            <Button
              variant="secondary"
              size="icon"
              className="h-7 w-7 bg-white/90 dark:bg-gray-800/90 hover:bg-red-100 dark:hover:bg-red-900/30"
              onClick={() => setShowConfirmDelete(true)}
            >
              <Trash2 className="h-3.5 w-3.5 text-red-500" />
            </Button>
          </div>

          {/* Confidence indicator */}
          <div className="absolute bottom-2 right-2">
            <Badge
              variant="secondary"
              className={`text-xs ${
                item.confidence >= 0.85
                  ? 'bg-green-100 dark:bg-green-900/50 text-green-700 dark:text-green-300'
                  : item.confidence >= 0.7
                  ? 'bg-blue-100 dark:bg-blue-900/50 text-blue-700 dark:text-blue-300'
                  : 'bg-amber-100 dark:bg-amber-900/50 text-amber-700 dark:text-amber-300'
              }`}
            >
              {Math.round(item.confidence * 100)}%
            </Badge>
          </div>
        </div>

        {/* Delete confirmation overlay */}
        {showConfirmDelete && (
          <div className="absolute inset-0 bg-black/60 flex items-center justify-center z-10">
            <div className="bg-white dark:bg-gray-800 rounded-lg p-4 mx-4 text-center space-y-3">
              <p className="text-sm font-medium text-gray-900 dark:text-white">Delete this item?</p>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setShowConfirmDelete(false)}
                >
                  Cancel
                </Button>
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={() => onDelete(item.tempId)}
                >
                  Delete
                </Button>
              </div>
            </div>
          </div>
        )}

        {/* Basic info */}
        <div className="p-3 space-y-2">
          {/* Name input */}
          <Input
            value={item.name || ''}
            onChange={(e) => onUpdate(item.tempId, { name: e.target.value })}
            placeholder={generateDefaultName()}
            className="font-medium h-8 text-sm"
          />

          {/* Category and sub-category */}
          <div className="flex gap-2">
            <Select
              value={item.category}
              onValueChange={(value) => onUpdate(item.tempId, { category: value as Category })}
            >
              <SelectTrigger className="h-8 text-xs flex-1">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {CATEGORIES.map((cat) => (
                  <SelectItem key={cat.value} value={cat.value}>
                    {cat.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Colors */}
          <div className="flex flex-wrap gap-1">
            {item.colors.slice(0, 4).map((color) => (
              <Badge key={color} variant="outline" className="text-xs px-1.5 py-0">
                {color}
              </Badge>
            ))}
            {item.colors.length > 4 && (
              <Badge variant="outline" className="text-xs px-1.5 py-0">
                +{item.colors.length - 4}
              </Badge>
            )}
          </div>

          {/* Expandable details */}
          <Collapsible open={isExpanded} onOpenChange={setIsExpanded}>
            <CollapsibleTrigger asChild>
              <Button variant="ghost" size="sm" className="w-full h-7 text-xs">
                <Edit2 className="h-3 w-3 mr-1" />
                {isExpanded ? 'Less details' : 'More details'}
                {isExpanded ? (
                  <ChevronUp className="h-3 w-3 ml-1" />
                ) : (
                  <ChevronDown className="h-3 w-3 ml-1" />
                )}
              </Button>
            </CollapsibleTrigger>
            <CollapsibleContent className="space-y-3 pt-2">
              {/* Sub-category */}
              <div>
                <Label className="text-xs">Sub-category</Label>
                <Input
                  value={item.sub_category || ''}
                  onChange={(e) => onUpdate(item.tempId, { sub_category: e.target.value })}
                  placeholder="e.g., T-Shirt, Jeans"
                  className="h-8 text-xs"
                />
              </div>

              {/* Brand & Material */}
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <Label className="text-xs">Brand</Label>
                  <Input
                    value={item.brand || ''}
                    onChange={(e) => onUpdate(item.tempId, { brand: e.target.value })}
                    placeholder="Brand"
                    className="h-8 text-xs"
                  />
                </div>
                <div>
                  <Label className="text-xs">Material</Label>
                  <Input
                    value={item.material || ''}
                    onChange={(e) => onUpdate(item.tempId, { material: e.target.value })}
                    placeholder="Material"
                    className="h-8 text-xs"
                  />
                </div>
              </div>

              {/* Pattern */}
              <div>
                <Label className="text-xs">Pattern</Label>
                <Input
                  value={item.pattern || ''}
                  onChange={(e) => onUpdate(item.tempId, { pattern: e.target.value })}
                  placeholder="e.g., solid, striped"
                  className="h-8 text-xs"
                />
              </div>

              {/* Color picker */}
              <div>
                <Label className="text-xs">Colors</Label>
                <div className="flex flex-wrap gap-1 mt-1">
                  {COMMON_COLORS.map((color) => (
                    <Badge
                      key={color}
                      variant={item.colors.includes(color) ? 'default' : 'outline'}
                      className="cursor-pointer text-xs px-1.5 py-0"
                      onClick={() => toggleColor(color)}
                    >
                      {color}
                    </Badge>
                  ))}
                </div>
              </div>
            </CollapsibleContent>
          </Collapsible>
        </div>
      </CardContent>
    </Card>
  )
}

export default ExtractedItemCard
