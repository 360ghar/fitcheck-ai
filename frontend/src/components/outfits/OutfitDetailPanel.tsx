/**
 * Outfit Detail Panel
 *
 * Slides in from the right as a sheet (desktop) and full-screen (mobile).
 * Shows the generated AI look, metadata, composition items and actions.
 */

import { useMemo } from 'react'
import { Check, Copy, Loader2, MoreVertical, Share2, Sparkles, Trash2 } from 'lucide-react'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import { ItemImage } from '@/components/ui/item-image'
import { GeneratingSurface } from '@/components/jobs'
import type { Item, Outfit } from '@/types'

interface OutfitDetailPanelProps {
  outfit: Outfit | null
  open: boolean
  onClose: () => void
  wardrobeItems: Item[]
  generatedImageUrl: string | null
  isGenerating: boolean
  generationStatus: string
  generationStageLabel: string
  isManaging: boolean
  onGenerate: () => void
  onShare: () => void
  onMarkWorn: () => void
  onDuplicate: () => void
  onDelete: () => void
}

export function OutfitDetailPanel({
  outfit,
  open,
  onClose,
  wardrobeItems,
  generatedImageUrl,
  isGenerating,
  generationStatus,
  generationStageLabel,
  isManaging,
  onGenerate,
  onShare,
  onMarkWorn,
  onDuplicate,
  onDelete,
}: OutfitDetailPanelProps) {
  const compositionItems: Item[] = useMemo(() => {
    if (!outfit) return []
    if (outfit.items?.length) return outfit.items
    return outfit.item_ids
      .map((id) => wardrobeItems.find((i) => i.id === id))
      .filter((i): i is Item => Boolean(i))
  }, [outfit, wardrobeItems])

  return (
    <Sheet open={open} onOpenChange={(o) => (!o ? onClose() : undefined)}>
      <SheetContent side="right" className="w-full sm:max-w-md overflow-y-auto p-0 flex flex-col">
        {outfit && (
          <>
            <SheetHeader className="px-5 pt-5 pb-3 text-left">
              <SheetTitle className="text-xl">{outfit.name}</SheetTitle>
              {outfit.description && <SheetDescription>{outfit.description}</SheetDescription>}
            </SheetHeader>

            <div className="px-5 pb-6 space-y-4 flex-1">
              {/* Hero image on a clean background */}
              <div className="aspect-[3/4] rounded-lg overflow-hidden bg-muted">
                {generatedImageUrl ? (
                  <ZoomableImage
                    src={generatedImageUrl}
                    alt={`${outfit.name} (generated)`}
                    className="w-full h-full object-cover"
                  />
                ) : outfit.images.length > 0 ? (
                  <ZoomableImage
                    src={
                      (outfit.images.find((img) => img.is_primary) || outfit.images[0])
                        .thumbnail_url ||
                      (outfit.images.find((img) => img.is_primary) || outfit.images[0]).image_url
                    }
                    alt={outfit.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex flex-col items-center justify-center text-muted-foreground gap-2 p-4">
                    <Sparkles className="h-10 w-10 text-primary/40" />
                    <p className="text-sm font-medium text-foreground">No AI look yet</p>
                    <p className="text-xs text-center">Generate an image to visualize this outfit</p>
                  </div>
                )}
              </div>

              {/* Metadata */}
              <div className="flex flex-wrap gap-2">
                {outfit.occasion && (
                  <Badge variant="secondary" className="capitalize">{outfit.occasion}</Badge>
                )}
                {outfit.season && (
                  <Badge variant="outline" className="capitalize">{outfit.season}</Badge>
                )}
                {outfit.style && (
                  <Badge variant="outline" className="capitalize">{outfit.style}</Badge>
                )}
                <Badge variant="outline">Worn {outfit.worn_count ?? 0}×</Badge>
              </div>

              {/* Composition */}
              <div>
                <p className="text-sm font-semibold text-foreground mb-2">Items in this outfit</p>
                {compositionItems.length > 0 ? (
                  <div className="grid grid-cols-1 gap-2">
                    {compositionItems.map((item) => (
                      <div
                        key={item.id}
                        className="flex items-center gap-3 p-2 rounded-lg border border-border bg-muted/30"
                      >
                        <ItemImage item={item} size="sm" />
                        <div className="min-w-0">
                          <p className="text-sm font-medium truncate">{item.name}</p>
                          <p className="text-xs text-muted-foreground capitalize">{item.category}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-muted-foreground">
                    {outfit.item_ids.length > 0
                      ? `${outfit.item_ids.length} item${outfit.item_ids.length === 1 ? '' : 's'} (details loading…)`
                      : 'No items linked to this outfit.'}
                  </p>
                )}
              </div>

              {isGenerating && (
                <GeneratingSurface
                  stage={generationStageLabel}
                  detail="Often under a minute. You can close this and reopen from the progress pill."
                  isActive
                  previewUrls={
                    compositionItems
                      .map((item) => item.images?.[0]?.thumbnail_url || item.images?.[0]?.image_url)
                      .filter(Boolean) as string[]
                  }
                  previewLabel="Items in this outfit"
                />
              )}
              {generationStatus === 'failed' && !isGenerating && (
                <p className="text-sm text-destructive">
                  Generation failed. Tap Generate look to try again.
                </p>
              )}
            </div>

            {/* Footer actions */}
            <div className="px-5 py-4 border-t border-border bg-background sticky bottom-0">
              <div className="flex gap-2">
                <Button onClick={onGenerate} disabled={isGenerating || isManaging} className="flex-1">
                  {isGenerating ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Generating…
                    </>
                  ) : (
                    <>
                      <Sparkles className="h-4 w-4 mr-2" />
                      {generationStatus === 'failed' ? 'Retry look' : 'Generate look'}
                    </>
                  )}
                </Button>
                <Button variant="outline" size="icon" onClick={onShare} aria-label="Share outfit">
                  <Share2 className="h-4 w-4" />
                </Button>
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="outline" size="icon" aria-label="More actions">
                      <MoreVertical className="h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end" className="w-48">
                    <DropdownMenuItem disabled={isManaging || isGenerating} onClick={onMarkWorn}>
                      <Check className="h-4 w-4 mr-2" />
                      Mark as worn
                    </DropdownMenuItem>
                    <DropdownMenuItem disabled={isManaging || isGenerating} onClick={onDuplicate}>
                      <Copy className="h-4 w-4 mr-2" />
                      Duplicate
                    </DropdownMenuItem>
                    <DropdownMenuItem
                      className="text-destructive"
                      disabled={isManaging || isGenerating}
                      onClick={onDelete}
                    >
                      <Trash2 className="h-4 w-4 mr-2" />
                      Delete
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </div>
          </>
        )}
      </SheetContent>
    </Sheet>
  )
}
