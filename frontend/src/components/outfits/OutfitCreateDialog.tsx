/**
 * OutfitCreateDialog
 *
 * Minimal outfit creation flow aligned to docs:
 * - Select wardrobe items
 * - Name + optional metadata (style/season/occasion/tags)
 * - Persist to backend via `/api/v1/outfits`
 */

import { useEffect, useMemo, useState } from 'react'
import { Check, Loader2, Search } from 'lucide-react'

import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { useToast } from '@/components/ui/use-toast'

import { getAvailableItems } from '@/api/outfits'
import { useOutfitStore } from '@/stores/outfitStore'
import type { Season, Style } from '@/types'

type AvailableItem = {
  id: string
  name: string
  category: string
  image_url?: string
  colors: string[]
}

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

export function OutfitCreateDialog() {
  const isCreating = useOutfitStore((s) => s.isCreating)
  const isSaving = useOutfitStore((s) => s.isLoading)
  const error = useOutfitStore((s) => s.error)

  const creationItems = useOutfitStore((s) => s.creationItems)
  const creationName = useOutfitStore((s) => s.creationName)
  const creationDescription = useOutfitStore((s) => s.creationDescription)
  const creationOccasion = useOutfitStore((s) => s.creationOccasion)
  const creationStyle = useOutfitStore((s) => s.creationStyle)
  const creationSeason = useOutfitStore((s) => s.creationSeason)
  const creationTags = useOutfitStore((s) => s.creationTags)

  const cancelCreating = useOutfitStore((s) => s.cancelCreating)
  const toggleCreationItem = useOutfitStore((s) => s.toggleCreationItem)
  const setCreationName = useOutfitStore((s) => s.setCreationName)
  const setCreationDescription = useOutfitStore((s) => s.setCreationDescription)
  const setCreationOccasion = useOutfitStore((s) => s.setCreationOccasion)
  const setCreationStyle = useOutfitStore((s) => s.setCreationStyle)
  const setCreationSeason = useOutfitStore((s) => s.setCreationSeason)
  const setCreationTags = useOutfitStore((s) => s.setCreationTags)
  const createOutfit = useOutfitStore((s) => s.createOutfit)
  const setSelectedOutfit = useOutfitStore((s) => s.setSelectedOutfit)

  const { toast } = useToast()

  const [availableItems, setAvailableItems] = useState<AvailableItem[]>([])
  const [isLoadingItems, setIsLoadingItems] = useState(false)
  const [itemsError, setItemsError] = useState<string | null>(null)
  const [search, setSearch] = useState('')
  const [category, setCategory] = useState<string>('all')

  const tagsInput = useMemo(() => creationTags.join(', '), [creationTags])

  useEffect(() => {
    if (!isCreating) return

    if (!creationStyle) setCreationStyle('casual')
    if (!creationSeason) setCreationSeason('all-season')

    const load = async () => {
      setIsLoadingItems(true)
      setItemsError(null)
      try {
        const items = await getAvailableItems()
        setAvailableItems(items)
      } catch (err) {
        setItemsError(err instanceof Error ? err.message : 'Failed to load wardrobe items')
      } finally {
        setIsLoadingItems(false)
      }
    }

    load()
  }, [creationSeason, creationStyle, isCreating, setCreationSeason, setCreationStyle])

  const filteredItems = useMemo(() => {
    const q = search.trim().toLowerCase()
    return availableItems.filter((it) => {
      const matchesCategory = category === 'all' || it.category === category
      const matchesSearch = !q || it.name.toLowerCase().includes(q)
      return matchesCategory && matchesSearch
    })
  }, [availableItems, category, search])

  const canCreate = creationName.trim().length > 0 && creationItems.size > 0 && !isSaving

  const onSubmit = async () => {
    try {
      const outfit = await createOutfit()
      setSelectedOutfit(outfit)
      toast({ title: 'Outfit created' })
    } catch (err) {
      toast({
        title: 'Failed to create outfit',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    }
  }

  return (
    <Dialog
      open={isCreating}
      onOpenChange={(open) => {
        if (!open) cancelCreating()
      }}
    >
      <DialogContent className="max-w-4xl">
        <DialogHeader>
          <DialogTitle>Create Outfit</DialogTitle>
          <DialogDescription>Select items from your wardrobe and save an outfit.</DialogDescription>
        </DialogHeader>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left: metadata */}
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="outfit-name">Name</Label>
              <Input
                id="outfit-name"
                placeholder="e.g., Casual Friday"
                value={creationName}
                onChange={(e) => setCreationName(e.target.value)}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="outfit-description">Description</Label>
              <Textarea
                id="outfit-description"
                placeholder="Optional notes (occasion, vibe, etc.)"
                value={creationDescription}
                onChange={(e) => setCreationDescription(e.target.value)}
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-2">
                <Label>Style</Label>
                <Select
                  value={creationStyle || 'casual'}
                  onValueChange={(v) => setCreationStyle(v as Style)}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select style" />
                  </SelectTrigger>
                  <SelectContent>
                    {STYLES.map((s) => (
                      <SelectItem key={s} value={s} className="capitalize">
                        {s}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label>Season</Label>
                <Select
                  value={creationSeason || 'all-season'}
                  onValueChange={(v) => setCreationSeason(v as Season)}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select season" />
                  </SelectTrigger>
                  <SelectContent>
                    {SEASONS.map((s) => (
                      <SelectItem key={s} value={s} className="capitalize">
                        {s}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="outfit-occasion">Occasion</Label>
              <Input
                id="outfit-occasion"
                placeholder="e.g., work, date night"
                value={creationOccasion}
                onChange={(e) => setCreationOccasion(e.target.value)}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="outfit-tags">Tags</Label>
              <Input
                id="outfit-tags"
                placeholder="Comma-separated tags (e.g., casual, work)"
                value={tagsInput}
                onChange={(e) => {
                  const raw = e.target.value
                  const tags = raw
                    .split(',')
                    .map((t) => t.trim())
                    .filter(Boolean)
                  setCreationTags(tags)
                }}
              />
              {creationTags.length > 0 && (
                <div className="flex flex-wrap gap-1">
                  {creationTags.slice(0, 8).map((tag) => (
                    <Badge key={tag} variant="secondary" className="text-xs">
                      {tag}
                    </Badge>
                  ))}
                </div>
              )}
            </div>

            {error && (
              <div className="text-sm text-red-600 dark:text-red-400">
                {error.message}
              </div>
            )}
          </div>

          {/* Right: item picker */}
          <div className="lg:col-span-2 space-y-3">
            <div className="flex flex-col sm:flex-row gap-3">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  placeholder="Search wardrobe..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="pl-9"
                />
              </div>
              <Select value={category} onValueChange={setCategory}>
                <SelectTrigger className="sm:w-48">
                  <SelectValue placeholder="Category" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All categories</SelectItem>
                  {Array.from(new Set(availableItems.map((i) => i.category))).map((c) => (
                    <SelectItem key={c} value={c} className="capitalize">
                      {c}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {isLoadingItems ? (
              <div className="py-10 text-center text-gray-600 dark:text-gray-400">
                <Loader2 className="h-5 w-5 animate-spin inline-block mr-2" />
                Loading wardrobe items...
              </div>
            ) : itemsError ? (
              <div className="py-10 text-center text-red-600 dark:text-red-400">{itemsError}</div>
            ) : (
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3 max-h-[26rem] overflow-y-auto pr-1">
                {filteredItems.map((item) => {
                  const selected = creationItems.has(item.id)
                  return (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => toggleCreationItem(item.id)}
                      className={`relative rounded-lg border overflow-hidden text-left transition-colors ${
                        selected ? 'border-indigo-500 ring-2 ring-indigo-200 dark:ring-indigo-800' : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                      }`}
                    >
                      <div className="aspect-square bg-gray-100 dark:bg-gray-700">
                        {item.image_url ? (
                          <img
                            src={item.image_url}
                            alt={item.name}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center text-gray-400 dark:text-gray-500 text-sm">
                            No image
                          </div>
                        )}
                      </div>
                      <div className="p-2">
                        <div className="text-sm font-medium truncate text-gray-900 dark:text-white">{item.name}</div>
                        <div className="text-xs text-gray-500 dark:text-gray-400 capitalize">{item.category}</div>
                      </div>

                      {selected && (
                        <div className="absolute top-2 right-2 h-6 w-6 rounded-full bg-indigo-600 text-white flex items-center justify-center shadow">
                          <Check className="h-4 w-4" />
                        </div>
                      )}
                    </button>
                  )
                })}
              </div>
            )}

            <div className="text-sm text-gray-600 dark:text-gray-400">
              Selected: {creationItems.size} item{creationItems.size === 1 ? '' : 's'}
            </div>
          </div>
        </div>

        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={cancelCreating} disabled={isSaving}>
            Cancel
          </Button>
          <Button onClick={onSubmit} disabled={!canCreate}>
            {isSaving ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Saving...
              </>
            ) : (
              'Create Outfit'
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
