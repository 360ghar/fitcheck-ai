/**
 * OutfitBuilder Component
 *
 * Interactive canvas for creating and visualizing outfits.
 * Features:
 * - Drag and drop items onto canvas
 * - Layer management
 * - Visual outfit composition
 * - Save outfit functionality
 * - AI image generation integration
 *
 * @see https://docs.fitcheck.ai/features/outfits/outfit-builder
 */

import { useState, useCallback, useRef } from 'react'
import {
  Plus,
  Trash2,
  GripVertical,
  Eye,
  EyeOff,
  Save,
  Wand2,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useToast } from '@/components/ui/use-toast'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import { generateOutfit } from '@/api/ai'
import type { Item, Category, Style, Season } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface OutfitItem {
  item: Item
  id: string
  position: { x: number; y: number }
  layer: number
  isVisible: boolean
}

export interface OutfitBuilderProps {
  availableItems: Item[]
  onSave?: (outfit: OutfitData) => Promise<void>
  onCancel?: () => void
  initialItems?: OutfitItem[]
  initialName?: string
  initialDescription?: string
}

export interface OutfitData {
  name: string
  description?: string
  item_ids: string[]
  style?: Style
  season?: Season
  tags: string[]
}

// ============================================================================
// CONSTANTS
// ============================================================================

const STYLES: Style[] = [
  'casual',
  'formal',
  'business',
  'sporty',
  'bohemian',
  'streetwear',
  'vintage',
  'minimalist',
  'romantic',
  'edgy',
  'preppy',
  'artsy',
  'other',
]

const SEASONS: Season[] = ['spring', 'summer', 'fall', 'winter', 'all-season']

const CATEGORIES: Category[] = ['tops', 'bottoms', 'shoes', 'accessories', 'outerwear', 'swimwear', 'activewear', 'other']

// ============================================================================
// OUTFIT ITEM CARD (for canvas)
// ============================================================================

interface CanvasItemProps {
  outfitItem: OutfitItem
  isSelected: boolean
  onSelect: () => void
  onRemove: () => void
  onToggleVisibility: () => void
  onDragStart: (e: React.DragEvent, id: string) => void
  onDragOver: (e: React.DragEvent) => void
  onDrop: (e: React.DragEvent, id: string) => void
}

function CanvasItem({
  outfitItem,
  isSelected,
  onSelect,
  onRemove,
  onToggleVisibility,
  onDragStart,
  onDragOver,
  onDrop,
}: CanvasItemProps) {
  const { item } = outfitItem

  return (
    <div
      draggable
      onDragStart={(e) => onDragStart(e, outfitItem.id)}
      onDragOver={onDragOver}
      onDrop={(e) => onDrop(e, outfitItem.id)}
      className={`relative group bg-card rounded-lg shadow-md cursor-move transition-all ${
        isSelected ? 'ring-2 ring-gold-500' : ''
      } ${!outfitItem.isVisible ? 'opacity-50' : ''}`}
      onClick={onSelect}
      style={{
        position: 'absolute',
        left: `${outfitItem.position.x}px`,
        top: `${outfitItem.position.y}px`,
        zIndex: outfitItem.layer,
        width: '120px',
      }}
    >
      {/* Drag handle */}
      <div className="absolute top-1 left-1 p-1 bg-muted rounded opacity-0 group-hover:opacity-100 transition-opacity">
        <GripVertical className="h-3 w-3 text-muted-foreground" />
      </div>

      {/* Remove button */}
      <button
        onClick={(e) => {
          e.stopPropagation()
          onRemove()
        }}
        className="absolute top-1 right-1 p-1 bg-red-100 dark:bg-red-900/30 rounded-full opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-200"
      >
        <Trash2 className="h-3 w-3 text-red-600 dark:text-red-400" />
      </button>

      {/* Visibility toggle */}
      <button
        onClick={(e) => {
          e.stopPropagation()
          onToggleVisibility()
        }}
        className="absolute top-1 left-1/2 -translate-x-1/2 p-1 bg-muted rounded-full opacity-0 group-hover:opacity-100 transition-opacity hover:bg-accent"
      >
        {outfitItem.isVisible ? (
          <Eye className="h-3 w-3 text-muted-foreground" />
        ) : (
          <EyeOff className="h-3 w-3 text-muted-foreground" />
        )}
      </button>

      {/* Item image */}
      <div className="aspect-square rounded-t-lg overflow-hidden bg-muted">
        {item.images.length > 0 ? (
          <img
            src={item.images[0].thumbnail_url || item.images[0].image_url}
            alt={item.name}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-muted-foreground">
            <span className="text-2xl">{item.category[0].toUpperCase()}</span>
          </div>
        )}
      </div>

      {/* Item name */}
      <div className="p-2">
        <p className="text-xs font-medium truncate text-foreground">{item.name}</p>
        <p className="text-xs text-muted-foreground capitalize">{item.category}</p>
      </div>

      {/* Layer indicator */}
      <Badge variant="outline" className="absolute -bottom-2 left-1/2 -translate-x-1/2 text-xs">
        L{outfitItem.layer}
      </Badge>
    </div>
  )
}

// ============================================================================
// OUTFIT BUILDER COMPONENT
// ============================================================================

export function OutfitBuilder({
  availableItems,
  onSave,
  onCancel,
  initialItems = [],
  initialName = '',
  initialDescription = '',
}: OutfitBuilderProps) {
  const [outfitItems, setOutfitItems] = useState<OutfitItem[]>(initialItems)
  const [selectedItemId, setSelectedItemId] = useState<string | null>(null)
  const [name, setName] = useState(initialName)
  const [description, setDescription] = useState(initialDescription)
  const [style, setStyle] = useState<Style>('casual')
  const [season, setSeason] = useState<Season>('all-season')
  const tags: string[] = []
  const [isSaving, setIsSaving] = useState(false)
  const [isGenerating, setIsGenerating] = useState(false)
  const [generatedImageUrl, setGeneratedImageUrl] = useState<string | null>(null)

  const [categoryFilter, setCategoryFilter] = useState<string>('all')
  const [searchQuery, setSearchQuery] = useState('')

  const canvasRef = useRef<HTMLDivElement>(null)
  const draggedItemRef = useRef<string | null>(null)
  const { toast } = useToast()

  // Filter available items
  const filteredItems = availableItems.filter((item) => {
    const matchesCategory = categoryFilter === 'all' || item.category === categoryFilter
    const matchesSearch =
      !searchQuery ||
      item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.brand?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.tags.some((t) => t.toLowerCase().includes(searchQuery.toLowerCase()))
    return matchesCategory && matchesSearch
  })

  // ============================================================================
  // HANDLERS
  // ============================================================================

  const handleAddItem = useCallback(
    (item: Item) => {
      const newItem: OutfitItem = {
        item,
        id: `${item.id}-${Date.now()}`,
        position: {
          x: 50 + outfitItems.length * 30,
          y: 50 + outfitItems.length * 30,
        },
        layer: outfitItems.length,
        isVisible: true,
      }
      setOutfitItems((prev) => [...prev, newItem])
    },
    [outfitItems.length]
  )

  const handleRemoveItem = useCallback((id: string) => {
    setOutfitItems((prev) => {
      const filtered = prev.filter((oi) => oi.id !== id)
      // Recalculate layers
      return filtered.map((oi, idx) => ({ ...oi, layer: idx }))
    })
    if (selectedItemId === id) {
      setSelectedItemId(null)
    }
  }, [selectedItemId])

  const handleToggleVisibility = useCallback((id: string) => {
    setOutfitItems((prev) =>
      prev.map((oi) => (oi.id === id ? { ...oi, isVisible: !oi.isVisible } : oi))
    )
  }, [])

  const handleSelectItem = useCallback((id: string) => {
    setSelectedItemId(id)
  }, [])

  // Drag and drop handlers
  const handleDragStart = useCallback((e: React.DragEvent, id: string) => {
    draggedItemRef.current = id
    e.dataTransfer.effectAllowed = 'move'
  }, [])

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    e.dataTransfer.dropEffect = 'move'
  }, [])

  const handleDrop = useCallback((e: React.DragEvent, targetId: string) => {
    e.preventDefault()
    const draggedId = draggedItemRef.current
    if (!draggedId || draggedId === targetId) return

    setOutfitItems((prev) => {
      const draggedIndex = prev.findIndex((oi) => oi.id === draggedId)
      const targetIndex = prev.findIndex((oi) => oi.id === targetId)

      if (draggedIndex === -1 || targetIndex === -1) return prev

      // Swap layers
      const draggedLayer = prev[draggedIndex].layer
      const targetLayer = prev[targetIndex].layer

      return prev.map((oi) => {
        if (oi.id === draggedId) return { ...oi, layer: targetLayer }
        if (oi.id === targetId) return { ...oi, layer: draggedLayer }
        return oi
      })
    })

    draggedItemRef.current = null
  }, [])

  const handleMoveLayer = useCallback((id: string, direction: 'up' | 'down') => {
    setOutfitItems((prev) => {
      const item = prev.find((oi) => oi.id === id)
      if (!item) return prev

      const newLayer = direction === 'up' ? item.layer + 1 : item.layer - 1
      if (newLayer < 0 || newLayer >= prev.length) return prev

      const swappedItem = prev.find((oi) => oi.layer === newLayer)
      if (!swappedItem) return prev

      return prev.map((oi) => {
        if (oi.id === id) return { ...oi, layer: newLayer }
        if (oi.id === swappedItem.id) return { ...oi, layer: item.layer }
        return oi
      })
    })
  }, [])

  // Save outfit
  const handleSave = async () => {
    if (!name.trim()) {
      toast({
        title: 'Name required',
        description: 'Please enter a name for your outfit',
        variant: 'destructive',
      })
      return
    }

    if (outfitItems.length === 0) {
      toast({
        title: 'No items',
        description: 'Please add at least one item to your outfit',
        variant: 'destructive',
      })
      return
    }

    setIsSaving(true)

    try {
      const outfitData: OutfitData = {
        name: name.trim(),
        description: description.trim() || undefined,
        item_ids: outfitItems.map((oi) => oi.item.id),
        style,
        season,
        tags,
      }

      await onSave?.(outfitData)

      toast({
        title: 'Outfit saved',
        description: `"${name}" has been saved to your outfits`,
      })
    } catch (err) {
      toast({
        title: 'Failed to save',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsSaving(false)
    }
  }

  // Generate AI image
  const handleGenerateAI = async () => {
    if (outfitItems.length === 0) {
      toast({
        title: 'No items',
        description: 'Please add items before generating',
        variant: 'destructive',
      })
      return
    }

    setIsGenerating(true)

    try {
      const visibleItems = outfitItems
        .filter((oi) => oi.isVisible)
        .map((oi) => ({
          name: oi.item.name,
          category: oi.item.category,
          colors: oi.item.colors,
          brand: oi.item.brand,
          material: oi.item.material,
          pattern: oi.item.pattern,
        }))

      const result = await generateOutfit(visibleItems, {
        style,
        background: 'studio white',
      })

      // Get the image URL - either direct URL or convert base64 to data URL
      const imageUrl = result.image_url || `data:image/png;base64,${result.image_base64}`

      if (imageUrl) {
        setGeneratedImageUrl(imageUrl)
        toast({
          title: 'Image generated',
          description: 'Your outfit has been visualized',
        })
      }
    } catch (err) {
      toast({
        title: 'Generation failed',
        description: err instanceof Error ? err.message : 'Failed to generate image',
        variant: 'destructive',
      })
    } finally {
      setIsGenerating(false)
    }
  }

  const selectedItem = outfitItems.find((oi) => oi.id === selectedItemId)

  // ============================================================================
  // RENDER
  // ============================================================================

  return (
    <div className="flex flex-col lg:flex-row gap-6 h-[calc(100vh-200px)]">
      {/* Left panel - Available items */}
      <div className="w-full lg:w-80 flex flex-col gap-4">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Wardrobe Items</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Search */}
            <Input
              placeholder="Search items..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />

            {/* Category filter */}
            <Select value={categoryFilter} onValueChange={setCategoryFilter}>
              <SelectTrigger>
                <SelectValue placeholder="Filter by category" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Categories</SelectItem>
                {CATEGORIES.map((cat) => (
                  <SelectItem key={cat} value={cat}>
                    {cat.charAt(0).toUpperCase() + cat.slice(1)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {/* Items list */}
            <div className="flex flex-wrap gap-2 max-h-96 overflow-y-auto">
              {filteredItems.map((item) => {
                const isInOutfit = outfitItems.some((oi) => oi.item.id === item.id)
                return (
                  <button
                    key={item.id}
                    onClick={() => !isInOutfit && handleAddItem(item)}
                    disabled={isInOutfit}
                    className={`relative w-16 h-16 rounded-lg overflow-hidden border-2 transition-all ${
                      isInOutfit
                        ? 'border-border opacity-50 cursor-not-allowed'
                        : 'border-border hover:border-gold-500'
                    }`}
                    title={item.name}
                  >
                    {item.images.length > 0 ? (
                      <img
                        src={item.images[0].thumbnail_url || item.images[0].image_url}
                        alt={item.name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center bg-muted text-muted-foreground">
                        {item.category[0].toUpperCase()}
                      </div>
                    )}
                    {isInOutfit && (
                      <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                        <Plus className="h-6 w-6 text-white" />
                      </div>
                    )}
                  </button>
                )
              })}
            </div>

            {filteredItems.length === 0 && (
              <p className="text-sm text-muted-foreground text-center py-4">No items found</p>
            )}
          </CardContent>
        </Card>

        {/* Outfit details */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Outfit Details</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="outfit-name">Name *</Label>
              <Input
                id="outfit-name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="My Casual Outfit"
              />
            </div>

            <div>
              <Label htmlFor="outfit-description">Description</Label>
              <Textarea
                id="outfit-description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="A comfortable outfit for weekend outings..."
                rows={2}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label>Style</Label>
                <Select value={style} onValueChange={(value) => setStyle(value as Style)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {STYLES.map((s) => (
                      <SelectItem key={s} value={s}>
                        {s.charAt(0).toUpperCase() + s.slice(1)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label>Season</Label>
                <Select value={season} onValueChange={(value) => setSeason(value as Season)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {SEASONS.map((s) => (
                      <SelectItem key={s} value={s}>
                        {s.charAt(0).toUpperCase() + s.slice(1)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* Generated image preview */}
            {generatedImageUrl && (
              <div>
                <Label>Generated Preview</Label>
                <div className="mt-2 rounded-lg overflow-hidden border">
                  <ZoomableImage src={generatedImageUrl} alt="AI Generated Outfit" className="w-full" />
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Right panel - Canvas */}
      <div className="flex-1 flex flex-col gap-4">
        <Card className="flex-1">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="text-lg">Outfit Canvas</CardTitle>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={handleGenerateAI}
                disabled={outfitItems.length === 0 || isGenerating}
              >
                <Wand2 className="h-4 w-4 mr-2" />
                {isGenerating ? 'Generating...' : 'Generate AI Image'}
              </Button>
              <Button
                size="sm"
                onClick={handleSave}
                disabled={outfitItems.length === 0 || isSaving}
              >
                <Save className="h-4 w-4 mr-2" />
                {isSaving ? 'Saving...' : 'Save Outfit'}
              </Button>
              {onCancel && (
                <Button variant="outline" size="sm" onClick={onCancel}>
                  Cancel
                </Button>
              )}
            </div>
          </CardHeader>
          <CardContent className="flex-1">
            <div
              ref={canvasRef}
              className="relative w-full h-[500px] bg-muted/50 rounded-lg border-2 border-dashed border-border overflow-hidden"
            >
              {outfitItems.length === 0 ? (
                <div className="absolute inset-0 flex items-center justify-center text-muted-foreground">
                  <div className="text-center">
                    <Plus className="h-12 w-12 mx-auto mb-2 opacity-50" />
                    <p>Drag items here or click to add</p>
                  </div>
                </div>
              ) : (
                outfitItems.map((outfitItem) => (
                  <CanvasItem
                    key={outfitItem.id}
                    outfitItem={outfitItem}
                    isSelected={selectedItemId === outfitItem.id}
                    onSelect={() => handleSelectItem(outfitItem.id)}
                    onRemove={() => handleRemoveItem(outfitItem.id)}
                    onToggleVisibility={() => handleToggleVisibility(outfitItem.id)}
                    onDragStart={handleDragStart}
                    onDragOver={handleDragOver}
                    onDrop={handleDrop}
                  />
                ))
              )}
            </div>

            {/* Selected item controls */}
            {selectedItem && (
              <div className="mt-4 p-4 bg-muted rounded-lg">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium text-foreground">{selectedItem.item.name}</p>
                    <p className="text-sm text-muted-foreground capitalize">{selectedItem.item.category}</p>
                  </div>
                  <div className="flex items-center gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleMoveLayer(selectedItem.id, 'up')}
                      disabled={selectedItem.layer >= outfitItems.length - 1}
                    >
                      Bring Forward
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleMoveLayer(selectedItem.id, 'down')}
                      disabled={selectedItem.layer <= 0}
                    >
                      Send Backward
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setSelectedItemId(null)}
                    >
                      Deselect
                    </Button>
                  </div>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

export default OutfitBuilder
