/**
 * Edit buffer for the closet detail surface.
 *
 * The body renders the fields and the pinned footer renders Save / Cancel, so the
 * two need one shared source of truth. It also has to reset on `item.id`: the
 * detail pane now persists across selections instead of unmounting, so an
 * abandoned edit would otherwise leak onto the next garment you click.
 */

import { useCallback, useEffect, useRef, useState } from 'react'
import type { Item } from '@/types'

export interface ItemEditor {
  isEditing: boolean
  isSaving: boolean
  form: Partial<Item>
  customUseCase: string
  setCustomUseCase: (value: string) => void
  begin: () => void
  cancel: () => void
  setField: <K extends keyof Item>(field: K, value: Item[K]) => void
  save: () => Promise<void>
}

export function useItemEditor(
  item: Item | null,
  onSave: (draft: Item) => Promise<unknown>
): ItemEditor {
  const [isEditing, setIsEditing] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [form, setForm] = useState<Partial<Item>>({})
  const [customUseCase, setCustomUseCase] = useState('')

  const itemId = item?.id ?? null
  const currentItemIdRef = useRef(itemId)
  // Update during render, not only in an effect: an older save promise can
  // resolve between the selection render and React's post-commit effects.
  currentItemIdRef.current = itemId
  useEffect(() => {
    setIsEditing(false)
    setIsSaving(false)
    setForm({})
    setCustomUseCase('')
  }, [itemId])

  const begin = useCallback(() => {
    if (!item) return
    setForm(item)
    setCustomUseCase('')
    setIsEditing(true)
  }, [item])

  const cancel = useCallback(() => {
    setIsEditing(false)
    setForm({})
    setCustomUseCase('')
  }, [])

  const setField = useCallback(<K extends keyof Item>(field: K, value: Item[K]) => {
    setForm((prev) => ({ ...prev, [field]: value }))
  }, [])

  const save = useCallback(async () => {
    if (isSaving) return
    const savedItemId = itemId
    setIsSaving(true)
    try {
      await onSave(form as Item)
      // The detail pane stays mounted while selection changes. An older save
      // resolving after a new selection must not close/reset the new editor.
      if (currentItemIdRef.current === savedItemId) {
        setIsEditing(false)
        setForm({})
        setCustomUseCase('')
      }
    } catch {
      // The api/client interceptor already toasts. Stay in edit mode so the
      // user's typing survives a failed save and can be retried.
    } finally {
      setIsSaving(false)
    }
  }, [form, isSaving, itemId, onSave])

  return {
    isEditing,
    isSaving,
    form,
    customUseCase,
    setCustomUseCase,
    begin,
    cancel,
    setField,
    save,
  }
}
