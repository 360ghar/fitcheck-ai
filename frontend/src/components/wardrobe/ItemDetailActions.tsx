/**
 * ItemDetailActions — the pinned action row of the closet detail surface.
 *
 * One filled primary, icon secondaries, one overflow menu. The card grid no
 * longer carries a favorite heart, so this footer is where favoriting lives —
 * a visible, stateful icon button rather than a buried overflow item.
 */

import { Check, Heart, Loader2, MoreVertical, Pencil, Shirt, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import type { Item } from '@/types'
import type { ItemEditor } from './useItemEditor'

export interface ItemDetailActionsProps {
  item: Item
  editor: ItemEditor
  isBusy: boolean
  onMarkWorn: () => void
  onToggleFavorite: () => void
  onDelete: () => void
  /** Start outfit creation pre-seeded with this item (/outfits/new?items=…). */
  onCreateOutfit?: () => void
}

export function ItemDetailActions({
  item,
  editor,
  isBusy,
  onMarkWorn,
  onToggleFavorite,
  onDelete,
  onCreateOutfit,
}: ItemDetailActionsProps) {
  if (editor.isEditing) {
    return (
      <div className="flex items-center gap-sm">
        <Button
          onClick={() => void editor.save()}
          disabled={editor.isSaving}
          className="min-w-0 flex-1"
        >
          {editor.isSaving ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
              <span className="truncate">Saving…</span>
            </>
          ) : (
            <>
              <Check className="h-4 w-4" aria-hidden="true" />
              <span className="truncate">Save changes</span>
            </>
          )}
        </Button>
        <Button
          variant="tertiary"
          onClick={editor.cancel}
          disabled={editor.isSaving}
          className="shrink-0"
        >
          Cancel
        </Button>
      </div>
    )
  }

  return (
    <div className="flex flex-wrap items-center gap-sm">
      <Button onClick={onMarkWorn} disabled={isBusy} className="min-w-0 flex-1 basis-32">
        <Check className="h-4 w-4" aria-hidden="true" />
        <span className="truncate">Mark as worn</span>
      </Button>

      {/* Favorite left the overflow menu: the grid cards dropped their hearts,
          so this is the only favoriting surface left — it must be visible and
          stateful, not a menu line. */}
      <Button
        variant="tertiary"
        size="icon"
        onClick={onToggleFavorite}
        disabled={isBusy}
        aria-label={item.is_favorite ? 'Remove from favourites' : 'Add to favourites'}
        aria-pressed={item.is_favorite}
        className="shrink-0"
      >
        <Heart
          className={`h-4 w-4 ${item.is_favorite ? 'fill-current text-primary' : ''}`}
          aria-hidden="true"
        />
      </Button>

      <Button variant="tertiary" size="icon" onClick={editor.begin} disabled={isBusy} aria-label="Edit item" className="shrink-0">
        <Pencil className="h-4 w-4" aria-hidden="true" />
      </Button>

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="tertiary" size="icon" aria-label="More item actions" className="shrink-0">
            <MoreVertical className="h-4 w-4" aria-hidden="true" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-52">
          {onCreateOutfit && (
            <DropdownMenuItem onClick={onCreateOutfit}>
              <Shirt className="h-4 w-4 mr-2" aria-hidden="true" />
              Create outfit with this item
            </DropdownMenuItem>
          )}
          <DropdownMenuItem className="text-destructive" disabled={isBusy} onClick={onDelete}>
            <Trash2 className="h-4 w-4 mr-2" aria-hidden="true" />
            Delete item
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  )
}

export default ItemDetailActions
