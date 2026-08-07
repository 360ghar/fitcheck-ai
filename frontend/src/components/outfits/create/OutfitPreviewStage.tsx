/**
 * OutfitPreviewStage — the whole point of this page.
 *
 * ONE frame, three states, no movement between them:
 *
 * empty → collage → AI render
 *
 * You watch the look assemble itself in the exact frame the render will later
 * occupy, so you have seen the outfit before you spend a generation on it.
 *
 * WHY IT CANNOT SHIFT — the frame's height is never a function of its contents:
 * - below `md` it is a literal `40svh` (floored at 240px);
 * - at `md`+ it is `aspect-[3/4]` of the pane's own width.
 * Both are content-independent, and every state is an `absolute inset-0` layer
 * inside that frame. The caption row beneath it is a fixed `h-9` that is always
 * rendered, whatever it currently has to say. Total height = frame + 8px + 36px,
 * identical in all three states.
 *
 * Surface: `bg-card` on the page's `bg-background`, i.e. a tonal step, with no
 * border and no shadow. DESIGN.md 07 keeps content surfaces flat; a 1px outline
 * around the hero of the page would be the hairline-on-every-box tell.
 */

import { Loader2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { OutfitCollagePreview } from './OutfitCollagePreview'
import type { AvailableItem } from './constants'

export type OutfitPreviewStatus = 'idle' | 'processing' | 'ready' | 'failed'

export interface OutfitPreviewStageProps {
  /** The chosen pieces, in selection order. */
  items: AvailableItem[]
  status: OutfitPreviewStatus
  /** Data URL / signed URL of the generated look. */
  previewImageUrl: string | null
  previewError: string | null
  /**
   * True when the selection or style has changed since this look was generated.
   * The look then no longer depicts the draft, and saying so is not optional.
   */
  isStale: boolean
  /** Real elapsed seconds. Never a fabricated percentage (DESIGN.md 11). */
  elapsedSeconds: number
  outfitName: string
}

const FRAME = [
  'relative w-full overflow-hidden rounded-lg bg-card',
  // Content-independent height in both bands — this is the no-shift guarantee.
  'h-[40svh] min-h-[240px]',
  'md:h-auto md:min-h-0 md:aspect-[3/4]',
].join(' ')

export function OutfitPreviewStage({
  items,
  status,
  previewImageUrl,
  previewError,
  isStale,
  elapsedSeconds,
  outfitName,
}: OutfitPreviewStageProps) {
  const showRender = status === 'ready' && Boolean(previewImageUrl)
  const isEmpty = items.length === 0

  return (
    <div>
      <div className={FRAME}>
        {showRender ? (
          <img
            loading="lazy"
            decoding="async"
            src={previewImageUrl as string}
            alt={
              outfitName
                ? `Generated look for ${outfitName}`
                : 'Generated look for this outfit'
            }
            // object-contain: a portrait render letterboxes onto the surface
            // instead of having its head or its shoes cropped off.
            className="absolute inset-0 h-full w-full object-contain"
          />
        ) : (
          <>
            {/* Stays mounted through `processing`, so a generation never leaves
                a blank spinner void where the look should be (DESIGN.md 08/11). */}
            <OutfitCollagePreview items={items} />

            {isEmpty && (
              // Dead-centre of the frame, both axes, by construction rather than
              // by a guessed offset.
              <div className="absolute inset-0 flex items-center justify-center px-xl">
                <p className="max-w-[22ch] text-center text-sm text-muted-foreground">
                  Pick pieces below. They land here as you tap.
                </p>
              </div>
            )}
          </>
        )}
      </div>

      {/* The caption. Always present at a fixed height, so nothing under the
          stage moves when the state changes. */}
      <div className="mt-sm flex h-9 items-start gap-sm">
        {status === 'processing' && (
          <Loader2
            className="mt-xxs h-4 w-4 shrink-0 animate-spin text-muted-foreground"
            aria-hidden="true"
          />
        )}
        <p
          className={cn(
            'line-clamp-2 min-w-0 text-xs leading-snug',
            status === 'failed' ? 'text-destructive' : 'text-muted-foreground',
          )}
          role="status"
          aria-live="polite"
        >
          <StageCaption
            status={status}
            itemCount={items.length}
            previewError={previewError}
            isStale={isStale}
            elapsedSeconds={elapsedSeconds}
          />
        </p>
      </div>
    </div>
  )
}

function StageCaption({
  status,
  itemCount,
  previewError,
  isStale,
  elapsedSeconds,
}: {
  status: OutfitPreviewStatus
  itemCount: number
  previewError: string | null
  isStale: boolean
  elapsedSeconds: number
}) {
  if (status === 'processing') {
    // Elapsed only. A percentage here would be invented (DESIGN.md 11).
    return <>Generating look… ({elapsedSeconds}s elapsed)</>
  }
  if (status === 'failed') {
    return <>{previewError || 'That generation failed. Try again.'}</>
  }
  if (status === 'ready') {
    if (isStale) {
      return (
        <>
          This look was generated from your earlier pieces. Generate again to
          match.
        </>
      )
    }
    return <>Look ready. Nothing is saved until you save it.</>
  }
  if (itemCount === 0) {
    return <>Arranged live from your pieces. No generation spent yet.</>
  }
  return (
    <>
      {itemCount} {itemCount === 1 ? 'piece' : 'pieces'} arranged. Generate a
      preview to see it worn.
    </>
  )
}

export default OutfitPreviewStage
