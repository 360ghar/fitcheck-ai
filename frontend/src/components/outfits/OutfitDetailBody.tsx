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
    <div className="pb-md">
      {notice && <p className="pb-sm text-sm text-muted-foreground">{notice}</p>}

      {/* Hero. object-contain over a card surface: a look is never cropped, and a
          portrait render letterboxes onto the surface instead of being cut. */}
      <div className="overflow-hidden rounded-md bg-card">
        {heroSrc ? (
          <ZoomableImage
            src={heroSrc}
            alt={generatedImageUrl ? `${outfit.name} (generated look)` : outfit.name}
            className="mx-auto block max-h-[32svh] w-full object-contain"
          />
        ) : (
          <div className="flex aspect-[16/10] flex-col items-center justify-center gap-xs px-md py-4 text-center">
            <Sparkles className="h-6 w-6 text-ash" aria-hidden="true" />
            <p className="text-[13px] font-semibold text-foreground">No AI look yet</p>
            <p className="text-xs text-muted-foreground">
              Generate one to see this outfit worn.
            </p>
          </div>
        )}
      </div>

      {metaLine && (
        <p className="mt-md text-[13px] capitalize text-muted-foreground">{metaLine}</p>
      )}
      {outfit.description && (
        <p className="mt-xs text-[13px] text-foreground">{outfit.description}</p>
      )}

      {/* The wear ledger.
          Wear count is what this product is actually for, so it gets the largest
          type on the surface instead of being the fourth grey badge in a row of
          four. Set against a hairline, ranged right, like the due-slip in the
          back of a library book. */}
      <div className="mt-md border-t border-border pt-md">
        {/* md split pane is 38% (~292px at 768px). Stack the figure under the
            date there so the count cannot crush the date; lg+ (340px) has room
            for one row. */}
        <div className="flex items-end justify-between gap-md md:max-lg:flex-col">
          <div className="min-w-0">
            <p className="text-xs text-muted-foreground">Last worn</p>
            <p className="mt-xxs text-[13px] text-foreground">{lastWorn || 'Not yet'}</p>
          </div>
          <div className="shrink-0 text-right">
            <span className="block font-display text-[28px] font-bold leading-none tracking-[-0.01em] tabular-nums text-foreground">
              {wornCount}
            </span>
            <span className="mt-xs block text-xs text-muted-foreground">
              {wornCount === 1 ? 'time worn' : 'times worn'}
            </span>
          </div>
        </div>
      </div>

      <div className="mt-md">
        <p className="text-xs text-muted-foreground">
          Pieces{compositionItems.length > 0 ? ` (${compositionItems.length})` : ''}
        </p>
        {compositionItems.length > 0 ? (
          <ul className="mt-xs border-t border-border">
            {compositionItems.map((item) => (
              <li
                key={item.id}
                className="flex items-center gap-sm border-b border-border py-2"
              >
                <ItemImage item={item} size="md" className="shrink-0" />
                <div className="min-w-0">
                  <p className="truncate text-[13px] font-medium text-foreground">{item.name}</p>
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
          className="mt-md"
          stage={generationStageLabel}
          detail="Often under a minute. You can close this and reopen from the progress pill."
          isActive
          previewUrls={
            // Full size on purpose. GeneratingSurface takes a flat string[], so
            // there is no per-URL error fallback to express here, and a derived
            // `_thumb` URL is not guaranteed to exist. At most 4 images in a
            // transient progress card, so correctness beats the byte saving.
            compositionItems
              .map((item) => item.images?.[0]?.image_url || item.images?.[0]?.thumbnail_url)
              .filter(Boolean) as string[]
          }
          previewLabel="Pieces in this outfit"
        />
      )}

      {generationStatus === 'failed' && !isGenerating && (
        <p className="mt-md text-[13px] text-destructive">
          Generation failed. Use Retry look to try again.
        </p>
      )}
    </div>
  )
}

export default OutfitDetailBody
