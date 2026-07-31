/**
 * ItemDetailActions — the pinned action row of the closet detail surface.
 *
 * One filled primary, tertiary text actions, one overflow menu. The dialog this
 * replaces shipped an outlined "Mark as Worn" beside a filled "Delete" in view
 * mode and an outlined "Cancel" beside a filled "Save Changes" in edit mode —
 * both of them the filled-plus-outlined couplet, and one of them putting a
 * destructive action in the primary slot.
 */

import { Check, Edit, Heart, Loader2, MoreVertical, Trash2 } from 'lucide-react'
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
}

export function ItemDetailActions({
  item,
  editor,
  isBusy,
  onMarkWorn,
  onToggleFavorite,
  onDelete,
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
    <div className="flex items-center gap-sm">
      <Button onClick={onMarkWorn} disabled={isBusy} className="min-w-0 flex-1">
        <Check className="h-4 w-4" aria-hidden="true" />
        <span className="truncate">Mark as worn</span>
      </Button>

      <Button variant="tertiary" onClick={editor.begin} disabled={isBusy} className="shrink-0">
        <Edit className="h-4 w-4" aria-hidden="true" />
        Edit
      </Button>

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="tertiary" size="icon" aria-label="More item actions" className="shrink-0">
            <MoreVertical className="h-4 w-4" aria-hidden="true" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-52">
          <DropdownMenuItem disabled={isBusy} onClick={onToggleFavorite}>
            <Heart
              className={`h-4 w-4 mr-2 ${item.is_favorite ? 'fill-current text-primary' : ''}`}
              aria-hidden="true"
            />
            {item.is_favorite ? 'Remove from favourites' : 'Add to favourites'}
          </DropdownMenuItem>
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
