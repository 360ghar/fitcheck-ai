/**
 * OutfitSelectionTray — what you have picked, and one tap to unpick it.
 *
 * Replaces the dialog's bare "Selected: 3 items" line of grey text. The pieces
 * themselves are the readout: this is an image-first app (DESIGN.md 04), so the
 * honest summary of a selection is the selection.
 *
 * Two deliberate details:
 *   - The row's height is RESERVED whether or not anything is in it, so picking
 *     the first piece does not shove the rails down.
 *   - The remove control is the same disc geometry as the rails' select control,
 *     inverted: a check disc adds, an X disc removes. One vocabulary, two verbs,
 *     rather than two unrelated affordances.
 */

import { X } from 'lucide-react'
import { cn } from '@/lib/utils'
import type { AvailableItem } from './constants'

export interface OutfitSelectionTrayProps {
  items: AvailableItem[]
  onRemove: (itemId: string) => void
  disabled?: boolean
}

export function OutfitSelectionTray({ items, onRemove, disabled }: OutfitSelectionTrayProps) {
  const count = items.length

  return (
    <div className="border-b border-border pb-md">
      <p className="text-sm font-bold text-foreground">
        {count === 0 ? 'No pieces yet' : `${count} ${count === 1 ? 'piece' : 'pieces'}`}
      </p>

      {/* min-h holds the row open at exactly one tile's height from the start.
          -mx-4 px-4 pr-8 lets the scroller bleed to the page gutter while the
          last tile still clears the container edge by 32px. */}
      <div className="-mx-4 mt-sm min-h-14 snap-x overflow-x-auto px-4 pr-8">
        {count === 0 ? (
          <p className="flex h-14 items-center text-xs text-muted-foreground">
            Tap a piece below to add it to the look.
          </p>
        ) : (
          <div className="flex gap-sm">
            {items.map((item) => (
              <button
                key={item.id}
                type="button"
                onClick={() => onRemove(item.id)}
                disabled={disabled}
                aria-label={`Remove ${item.name} from this outfit`}
                title={item.name}
                className={cn(
                  'relative h-14 w-14 shrink-0 snap-start rounded-md',
                  // No hover lift and no scale. The disc darkens; the tile does
                  // not move.
                  'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                  'group disabled:opacity-60'
                )}
              >
                <span className="absolute inset-1 overflow-hidden rounded-sm bg-card">
                  {item.image_url ? (
                    <img
                      src={item.image_url}
                      alt=""
                      className="h-full w-full object-contain"
                      loading="lazy"
                      decoding="async"
                    />
                  ) : (
                    <span className="flex h-full w-full items-center justify-center px-xxs text-center text-[9px] leading-tight text-muted-foreground">
                      {item.category}
                    </span>
                  )}
                </span>

                {/* Sits fully inside the 56px button box, so nothing is clipped
                    by the tile's own rounded corner. flex centring puts the
                    glyph dead-centre in the disc. */}
                <span
                  className={cn(
                    'absolute right-0 top-0 flex h-[18px] w-[18px] items-center justify-center rounded-full',
                    'bg-ink text-on-dark transition-colors group-hover:bg-destructive',
                    'group-hover:text-destructive-foreground'
                  )}
                  aria-hidden="true"
                >
                  <X className="h-3 w-3" strokeWidth={2.5} />
                </span>
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

export default OutfitSelectionTray
