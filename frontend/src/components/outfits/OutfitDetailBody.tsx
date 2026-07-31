/**
 * OutfitDetailBody — the scrolling content of the outfit detail surface.
 *
 * Presentation-agnostic on purpose: `MasterDetailLayout` supplies the scroll
 * container, the heading and the horizontal gutter, so this renders the same
 * markup in the desktop pane and in the small-screen sheet. It carries no
 * horizontal padding and no entrance animation — the content is present on the
 * first paint or it is a bug.
 */

import { useMemo } from 'react'
import { Sparkles } from 'lucide-react'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import { ItemImage } from '@/components/ui/item-image'
import { GeneratingSurface } from '@/components/jobs'
import type { Item, Outfit } from '@/types'

export interface OutfitDetailBodyProps {
  outfit: Outfit
  wardrobeItems: Item[]
  generatedImageUrl: string | null
  isGenerating: boolean
  generationStatus: string
  generationStageLabel: string
  /** One quiet line of context, e.g. when the selection is filtered out of the list. */
  notice?: string | null
}

function formatDay(value?: string | null): string | null {
  if (!value) return null
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return null
  return date.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' })
}

export function OutfitDetailBody({
  outfit,
  wardrobeItems,
  generatedImageUrl,
  isGenerating,
  generationStatus,
  generationStageLabel,
  notice,
}: OutfitDetailBodyProps) {
  const compositionItems: Item[] = useMemo(() => {
    if (outfit.items?.length) return outfit.items
    return outfit.item_ids
      .map((id) => wardrobeItems.find((i) => i.id === id))
      .filter((i): i is Item => Boolean(i))
  }, [outfit, wardrobeItems])

  const heroImage = outfit.images?.find((img) => img.is_primary) || outfit.images?.[0]
  // The detail hero and zoom lightbox deserve the full-resolution image;
  // thumbnails are for list/card surfaces. Fall back to the thumbnail only
  // when no full image exists.
  const heroSrc = generatedImageUrl || heroImage?.image_url || heroImage?.thumbnail_url || null

  // One line replaces the old row of four tinted badges.
  const metaLine = [outfit.occasion, outfit.season, outfit.style].filter(Boolean).join(' · ')

  const wornCount = outfit.worn_count ?? 0
  const lastWorn = formatDay(outfit.last_worn_at)

  return (
    <div className="pb-lg">
      {notice && <p className="pb-md text-sm text-muted-foreground">{notice}</p>}

      {/* Hero. object-contain over a card surface: a look is never cropped, and a
          portrait render letterboxes onto the surface instead of being cut. */}
      <div className="overflow-hidden rounded-md bg-card">
        {heroSrc ? (
          <ZoomableImage
            src={heroSrc}
            alt={generatedImageUrl ? `${outfit.name} (generated look)` : outfit.name}
            className="mx-auto block max-h-[58svh] w-full object-contain"
          />
        ) : (
          <div className="flex aspect-[3/4] flex-col items-center justify-center gap-sm px-lg text-center">
            <Sparkles className="h-8 w-8 text-ash" aria-hidden="true" />
            <p className="text-sm font-semibold text-foreground">No AI look yet</p>
            <p className="text-xs text-muted-foreground">
              Generate one to see this outfit worn.
            </p>
          </div>
        )}
      </div>

      {metaLine && (
        <p className="mt-lg text-sm capitalize text-muted-foreground">{metaLine}</p>
      )}
      {outfit.description && (
        <p className="mt-sm text-sm text-foreground">{outfit.description}</p>
      )}

      {/* The wear ledger.
          Wear count is what this product is actually for, so it gets the largest
          type on the surface instead of being the fourth grey badge in a row of
          four. Set against a hairline, ranged right, like the due-slip in the
          back of a library book. */}
      <div className="mt-xl border-t border-border pt-lg">
        {/* md:max-lg: the pane is only 211–289px wide in that one band (see
            MasterDetailLayout), where a 40px figure and the date cannot share a
            row. Stacking keeps the figure right-ranged instead of crushing it. */}
        <div className="flex items-end justify-between gap-lg md:max-lg:flex-col md:max-lg:items-stretch md:max-lg:gap-md">
          <div className="min-w-0">
            <p className="text-xs text-muted-foreground">Last worn</p>
            <p className="mt-xxs text-sm text-foreground">{lastWorn || 'Not yet'}</p>
          </div>
          <div className="shrink-0 text-right">
            <span className="block font-display text-[40px] font-bold leading-none tracking-[-0.01em] tabular-nums text-foreground">
              {wornCount}
            </span>
            <span className="mt-xs block text-xs text-muted-foreground">
              {wornCount === 1 ? 'time worn' : 'times worn'}
            </span>
          </div>
        </div>
      </div>

      <div className="mt-xl">
        <p className="text-xs text-muted-foreground">
          Pieces{compositionItems.length > 0 ? ` (${compositionItems.length})` : ''}
        </p>
        {compositionItems.length > 0 ? (
          <ul className="mt-sm border-t border-border">
            {compositionItems.map((item) => (
              <li
                key={item.id}
                className="flex items-center gap-md border-b border-border py-md"
              >
                <ItemImage item={item} size="md" className="shrink-0" />
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium text-foreground">{item.name}</p>
                  <p className="text-xs capitalize text-muted-foreground">{item.category}</p>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <p className="mt-sm text-sm text-muted-foreground">
            {outfit.item_ids.length > 0
              ? `${outfit.item_ids.length} item${outfit.item_ids.length === 1 ? '' : 's'} still loading…`
              : 'No items linked to this outfit.'}
          </p>
        )}
      </div>

      {isGenerating && (
        <GeneratingSurface
          className="mt-xl"
          stage={generationStageLabel}
          detail="Often under a minute. You can close this and reopen from the progress pill."
          isActive
          previewUrls={
            compositionItems
              .map((item) => item.images?.[0]?.thumbnail_url || item.images?.[0]?.image_url)
              .filter(Boolean) as string[]
          }
          previewLabel="Pieces in this outfit"
        />
      )}

      {generationStatus === 'failed' && !isGenerating && (
        <p className="mt-lg text-sm text-destructive">
          Generation failed. Use Retry look to try again.
        </p>
      )}
    </div>
  )
}

export default OutfitDetailBody
