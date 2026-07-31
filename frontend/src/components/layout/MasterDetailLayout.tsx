/**
 * MasterDetailLayout — one geometry for every "list on the left, the thing you
 * picked on the right" surface (Closet, Outfits, and the Create preview).
 *
 * Why one primitive instead of per-page flex: two hand-rolled splits drift, and
 * the breakpoint story here is specific enough to be worth stating once.
 *
 *   - The split engages at `md` (768px), which is also where `AppLayout` swaps
 *     the bottom nav for the desktop sidebar.
 *   - The LIST stays in normal document flow. CSS-columns masonry needs the
 *     document scrollbar to compute its natural height, and `AppLayout` already
 *     owns page height (plus a desktop footer), so an inner `h-[100svh]` shell
 *     would produce three nested scrollbars.
 *   - The DETAIL pane is `sticky` with its own `overflow-y-auto` +
 *     `overscroll-contain`, so scrolling the pane never chains to the page.
 *     `md:items-start` on the row is load-bearing: a stretched flex child can
 *     never engage `position: sticky`.
 *   - The action footer is pinned to the PANE's bottom, not the viewport's.
 *   - Exactly ONE presentation mounts. Radix portals a Sheet to `document.body`,
 *     so it cannot be CSS-hidden, and mounting both would give two focus traps
 *     and two image-lightbox trees over one document.
 *
 * The page header, search, filters and any bulk bar belong ABOVE this component,
 * at full width. That is what makes the interaction read as "the list shrank"
 * rather than "the page changed".
 */

import * as React from 'react'
import { X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet'
import { useIsSplitViewport } from '@/hooks/useMediaQuery'

export interface MasterDetailLayoutProps {
  /** The browse surface. Owns the document scroll. */
  list: React.ReactNode
  /** The detail surface. Must carry no horizontal padding — this layout supplies it. */
  detail: React.ReactNode
  /** Action row. Pinned to the bottom of the pane / sheet. */
  detailFooter?: React.ReactNode
  isDetailOpen: boolean
  onCloseDetail: () => void
  /** Accessible name of the pane, and the visible pane heading. */
  detailTitle: string
  /**
   * Below `md`, where a side-by-side split is physically impossible:
   * `overlay` (default) puts the detail in a right-hand Sheet — correct when the
   * list is the primary surface and the detail is a lookup.
   * `inline-lead` puts the detail inline ABOVE the list in normal flow — correct
   * when the detail IS the task (the Create preview stage) and the list below it
   * is the palette you are picking from.
   */
  smallScreenMode?: 'overlay' | 'inline-lead'
}

export function MasterDetailLayout({
  list,
  detail,
  detailFooter,
  isDetailOpen,
  onCloseDetail,
  detailTitle,
  smallScreenMode = 'overlay',
}: MasterDetailLayoutProps) {
  const isSplit = useIsSplitViewport()
  const headingId = React.useId()
  const asideRef = React.useRef<HTMLElement | null>(null)

  // Mutually exclusive by construction — see the "exactly ONE presentation" note.
  const showAside = isSplit && isDetailOpen

  /**
   * Size the pane to the space actually available, not to the whole viewport.
   *
   * A flat `h-[calc(100svh-2rem)]` is only correct once the pane is STUCK. Before
   * that it starts ~140px down the document (below the page header, search and
   * filters), so its bottom — and therefore the action footer — sat 110-130px
   * past the fold on first open, and the primary action was invisible until you
   * scrolled. Auto-scrolling the page to fix it would yank the list out from
   * under someone who just clicked a card near the bottom, so instead the pane
   * takes the height it can actually have and grows into a full-height one as
   * sticky pins it. `top` is floored at the sticky offset, and the whole thing
   * is rAF-throttled; setting height cannot change `top`, so there is no loop.
   */
  React.useLayoutEffect(() => {
    if (!showAside) return
    const el = asideRef.current
    if (!el) return

    let frame = 0
    const measure = () => {
      frame = 0
      const STICKY_TOP = 16 // md:top-4
      const top = Math.max(el.getBoundingClientRect().top, STICKY_TOP)
      const available = window.innerHeight - top - STICKY_TOP
      el.style.setProperty('--pane-h', `${Math.max(available, 240)}px`)
    }
    const schedule = () => {
      if (!frame) frame = requestAnimationFrame(measure)
    }

    measure()
    window.addEventListener('scroll', schedule, { passive: true })
    window.addEventListener('resize', schedule)
    return () => {
      window.removeEventListener('scroll', schedule)
      window.removeEventListener('resize', schedule)
      if (frame) cancelAnimationFrame(frame)
    }
  }, [showAside])
  const showInlineLead = !isSplit && isDetailOpen && smallScreenMode === 'inline-lead'
  const showOverlay = !isSplit && isDetailOpen && smallScreenMode === 'overlay'

  const closeButton = (
    <Button
      variant="tertiary"
      size="icon"
      onClick={onCloseDetail}
      aria-label={`Close ${detailTitle} details`}
      // -mr-3 pulls the 44px target out so the X GLYPH's right edge lands on the
      // same vertical as the right-ranged values below it, rather than the
      // button's invisible box.
      className="-mr-3 shrink-0"
    >
      <X className="h-4 w-4" />
    </Button>
  )

  return (
    <>
      {showInlineLead && (
        <section aria-labelledby={`${headingId}-lead`} className="mb-xl">
          <div className="flex items-start justify-between gap-md pb-md">
            <h2 id={`${headingId}-lead`} className="type-heading-lg min-w-0 break-words text-foreground">
              {detailTitle}
            </h2>
            {closeButton}
          </div>
          {detail}
          {detailFooter && (
            <div className="mt-lg border-t border-border pt-md">{detailFooter}</div>
          )}
        </section>
      )}

      <div className="md:flex md:items-start md:gap-lg lg:gap-xl">
        <section className="min-w-0 md:flex-1">{list}</section>

        {showAside && (
          <aside
            ref={asideRef}
            aria-labelledby={`${headingId}-pane`}
            // The fallback is the stuck height, so the very first paint (before
            // the layout effect measures) is never taller than the viewport.
            style={{ ['--pane-h' as string]: 'calc(100svh - 2rem)' }}
            className={[
              // `hidden md:flex` belts the JS gate: no full-width aside can ever
              // flash if the media query resolves a frame late.
              'hidden md:flex md:shrink-0 md:flex-col',
              'md:sticky md:top-4 md:h-[var(--pane-h)]',
              'md:w-[44%] lg:w-[360px] xl:w-[400px] 2xl:w-[440px]',
              'border-l border-border md:pl-lg',
            ].join(' ')}
          >
            <div className="flex shrink-0 items-start justify-between gap-md pb-md">
              <h2
                id={`${headingId}-pane`}
                className="type-heading-lg min-w-0 break-words text-foreground"
              >
                {detailTitle}
              </h2>
              {closeButton}
            </div>

            {/* min-h-0 + flex-1 is what keeps the footer from ever overlapping
                the last line of the body. */}
            <div className="min-h-0 flex-1 overflow-y-auto overscroll-contain">{detail}</div>

            {detailFooter && (
              <div className="shrink-0 border-t border-border bg-background pt-md">
                {detailFooter}
              </div>
            )}
          </aside>
        )}
      </div>

      {showOverlay && (
        <Sheet
          open
          onOpenChange={(open) => {
            if (!open) onCloseDetail()
          }}
        >
          <SheetContent side="right" className="flex w-full flex-col gap-0 p-0 sm:max-w-md">
            {/* pr-14 clears the Sheet's own close button so a long name is never
                shaved by it. */}
            <SheetHeader className="shrink-0 px-lg pb-md pr-14 pt-lg text-left">
              <SheetTitle className="min-w-0 break-words">{detailTitle}</SheetTitle>
            </SheetHeader>

            <div className="min-h-0 flex-1 overflow-y-auto overscroll-contain px-lg">
              {detail}
            </div>

            {detailFooter && (
              <div className="shrink-0 border-t border-border bg-background px-lg pt-md pb-bottom-nav">
                {detailFooter}
              </div>
            )}
          </SheetContent>
        </Sheet>
      )}
    </>
  )
}

export default MasterDetailLayout
