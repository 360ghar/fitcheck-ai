/**
 * OutfitDetailPanel — the detail surface for one outfit, as content only.
 *
 * This used to be a Radix Sheet that covered the list. It no longer owns any
 * shell: `MasterDetailLayout` decides between the inline desktop pane and the
 * small-screen Sheet, supplies the heading, the scroll container, the gutter and
 * the pinned footer slot, and guarantees exactly one of the two mounts. Putting a
 * second `mode: 'inline' | 'overlay'` switch here would mean two overlay
 * implementations to keep in step (and, if both ever rendered, two focus traps),
 * so the switch lives in exactly one place.
 *
 * Actions live in `OutfitDetailActions`, passed to the layout's `detailFooter`.
 */

import { OutfitDetailBody, type OutfitDetailBodyProps } from './OutfitDetailBody'

export interface OutfitDetailPanelProps extends Omit<OutfitDetailBodyProps, 'outfit'> {
  /** Null while a deep link is still resolving, or if the id does not exist. */
  outfit: OutfitDetailBodyProps['outfit'] | null
  isDetailLoading: boolean
}

export function OutfitDetailPanel({ outfit, isDetailLoading, ...bodyProps }: OutfitDetailPanelProps) {
  if (!outfit) {
    return (
      <p className="py-lg text-sm text-muted-foreground">
        {isDetailLoading ? 'Loading this outfit…' : "This outfit isn't available."}
      </p>
    )
  }

  return <OutfitDetailBody outfit={outfit} {...bodyProps} />
}

export default OutfitDetailPanel
