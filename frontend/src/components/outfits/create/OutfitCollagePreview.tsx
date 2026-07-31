/**
 * OutfitCollagePreview — the free, instant, zero-network look.
 *
 * Pure CSS/flexbox by design. No `<canvas>`, no `drawImage`, no `crossOrigin`,
 * no `toDataURL`: compositing Supabase-hosted images on a canvas risks tainting
 * it, and we never need the bytes. The collage is a *placeholder* that is never
 * uploaded — the AI render is the artifact.
 *
 * Item images are matted WebP with a real alpha channel (see `ui/item-image.tsx`),
 * so they composite honestly with `object-contain` and nothing else.
 * Deliberately NO `mix-blend-multiply`: that was a trick for knocking white out
 * of product shots, and on a true cutout it only darkens the anti-aliased edge.
 *
 * GEOMETRY IS FIXED, and that is the point. The three bands always occupy the
 * same fractions of the frame and the ground line always lands on the same
 * pixel row, whether the stage holds nothing, two pieces or six. Adding a piece
 * fills a band; it never moves the frame.
 */

import * as React from 'react'
import { cn } from '@/lib/utils'
import { bandForCategory, type AvailableItem, type StageBand } from './constants'

export interface OutfitCollagePreviewProps {
  items: AvailableItem[]
  className?: string
}

/**
 * Band heights as a share of the frame's inner box, and the widest a single
 * garment may grow inside its band. Shared constants rather than per-band magic
 * numbers so the composition stays proportional at every pane width.
 */
const BAND_LAYOUT: Record<Exclude<StageBand, 'rail'>, { basis: string; slot: string }> = {
  upper: { basis: 'basis-[42%]', slot: 'max-w-[64%]' },
  lower: { basis: 'basis-[36%]', slot: 'max-w-[56%]' },
  base: { basis: 'basis-[22%]', slot: 'max-w-[34%]' },
}

const BAND_ORDER: Array<Exclude<StageBand, 'rail'>> = ['upper', 'lower', 'base']

function Piece({
  item,
  index,
  className,
}: {
  item: AvailableItem
  index: number
  className?: string
}) {
  return (
    <div
      className={cn(
        'min-w-0',
        className,
        // The authored moment, and the only motion here: a piece DROPS INTO
        // PLACE when you tap it. `animate-in` with no `fade-in` leaves
        // `--tw-enter-opacity` at its initial value, so the keyframe never
        // touches opacity — the piece is at full opacity on every frame, and if
        // the animation never runs (reduced motion, a throttled tab, a
        // screenshot pass) the element is already sitting in its final
        // position. Nothing can strand invisible.
        'animate-in slide-in-from-bottom-2 duration-300 ease-out'
      )}
      // Staggered by band index so a multi-piece band settles left to right
      // rather than snapping as one block.
      style={{ animationDelay: `${Math.min(index, 4) * 40}ms` }}
    >
      {item.image_url ? (
        <img
          src={item.image_url}
          alt={item.name}
          className="h-full w-full object-contain"
          loading="eager"
          decoding="async"
          draggable={false}
        />
      ) : (
        // A piece with no photo is still part of the look, so it holds its slot
        // and says what it is rather than leaving a silent hole.
        <div className="flex h-full w-full items-center justify-center px-xxs text-center">
          <span className="line-clamp-2 text-[10px] leading-tight text-muted-foreground">
            {item.name}
          </span>
        </div>
      )}
    </div>
  )
}

export function OutfitCollagePreview({ items, className }: OutfitCollagePreviewProps) {
  const bands = React.useMemo(() => {
    const grouped: Record<StageBand, AvailableItem[]> = {
      upper: [],
      lower: [],
      base: [],
      rail: [],
    }
    for (const item of items) grouped[bandForCategory(item.category)].push(item)
    return grouped
  }, [items])

  const hasRail = bands.rail.length > 0

  return (
    <div className={cn('absolute inset-0 flex flex-col gap-sm p-lg', className)} aria-hidden="true">
      <div className="relative flex min-h-0 flex-1 flex-col">
        <div
          className={cn(
            'flex min-h-0 flex-1 flex-col',
            // Only reserve the rail's width when something is actually in it, so
            // an outfit with no accessories stays centred in the full frame.
            hasRail && 'pr-[22%]'
          )}
        >
          {BAND_ORDER.map((band) => (
            <div
              key={band}
              className={cn(
                'flex min-h-0 shrink-0 items-center justify-center gap-sm',
                BAND_LAYOUT[band].basis
              )}
            >
              {bands[band].map((item, i) => (
                <Piece
                  key={item.id}
                  item={item}
                  index={i}
                  className={cn('h-full flex-1 basis-0', BAND_LAYOUT[band].slot)}
                />
              ))}
            </div>
          ))}
        </div>

        {hasRail && (
          <div className="absolute inset-y-0 right-0 flex w-[18%] flex-col items-center justify-center gap-sm">
            {bands.rail.slice(0, 4).map((item, i) => (
              <Piece
                key={item.id}
                item={item}
                index={i}
                className="aspect-square w-full shrink-0"
              />
            ))}
          </div>
        )}
      </div>

      {/*
        The ground line. The one bespoke mark on this surface and the through-line
        across every state: it is the floor the look stands on, drawn at exactly
        the y the shoes land on, present when the frame is empty and still there
        once pieces arrive. Rounded caps, because a bare square-capped hairline
        used as ornament is the cheap version — this one has a job.
      */}
      <div className="mx-auto h-0.5 w-2/5 shrink-0 rounded-full bg-border" />
    </div>
  )
}

export default OutfitCollagePreview
