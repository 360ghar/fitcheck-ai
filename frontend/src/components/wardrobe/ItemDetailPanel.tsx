/**
 * ItemDetailPanel — the detail surface for one closet item, as content only.
 *
 * Replaces `ItemDetailModal` (a `max-w-3xl` Dialog with three tabs). It owns no
 * shell: `MasterDetailLayout` picks between the inline desktop pane and the
 * small-screen Sheet, so both surfaces behave identically and only one ever
 * mounts. Actions live in `ItemDetailActions`, passed to the layout's
 * `detailFooter`.
 */

import { ItemDetailBody, type ItemDetailBodyProps } from './ItemDetailBody'

export interface ItemDetailPanelProps extends Omit<ItemDetailBodyProps, 'item'> {
  /** Null while a deep link is still resolving, or if the id does not exist. */
  item: ItemDetailBodyProps['item'] | null
  isDetailLoading: boolean
}

export function ItemDetailPanel({ item, isDetailLoading, ...bodyProps }: ItemDetailPanelProps) {
  if (!item) {
    return (
      <p className="py-lg text-sm text-muted-foreground">
        {isDetailLoading ? 'Loading this item…' : "This item isn't available."}
      </p>
    )
  }

  return <ItemDetailBody item={item} {...bodyProps} />
}

export default ItemDetailPanel
