/**
 * Create Outfit — a page, not a dialog.
 *
 * The old `OutfitCreateDialog` saved first and THEN fire-and-forgot an AI
 * generation the user had never seen, so every save silently cost a render.
 * Here the order is inverted: draft, render, LOOK at it, then save. The
 * approved bytes are what gets uploaded, so approving costs nothing further.
 *
 * The stage is one fixed frame that carries three states in sequence —
 * empty, then a live collage of the chosen pieces, then the render — so the
 * layout never jumps and you can see the outfit before you pay for it.
 */

import { useCallback, useEffect, useMemo, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'

import { MasterDetailLayout } from '@/components/layout/MasterDetailLayout'
import { Button } from '@/components/ui/button'
import { getAvailableItems } from '@/api/outfits'
import type { OutfitItemInput } from '@/api/ai'
import { getApiError } from '@/lib/errors'
import { logger } from '@/lib/logger'
import { useOutfitStore } from '@/stores/outfitStore'
import { useToast } from '@/components/ui/use-toast'
import { useElapsedSeconds } from '@/hooks/useElapsedSeconds'

import {
  OutfitMetaBar,
  type OutfitMetaBarProps,
} from '@/components/outfits/create/OutfitMetaBar'
import { OutfitSelectionTray } from '@/components/outfits/create/OutfitSelectionTray'
import { OutfitItemRails } from '@/components/outfits/create/OutfitItemRails'
import { OutfitPreviewStage } from '@/components/outfits/create/OutfitPreviewStage'
import { compareCategories, type AvailableItem } from '@/components/outfits/create/constants'

export default function OutfitCreatePage() {
  const navigate = useNavigate()
  const { toast } = useToast()
  const [searchParams] = useSearchParams()

  const [available, setAvailable] = useState<AvailableItem[]>([])
  const [itemsLoading, setItemsLoading] = useState(true)
  const [itemsError, setItemsError] = useState<string | null>(null)
  const [isSaving, setIsSaving] = useState(false)

  const {
    creationItems,
    creationName,
    creationDescription,
    creationStyle,
    creationSeason,
    creationTags,
    creationOccasion,
    previewStatus,
    previewImageDataUrl,
    previewError,
    previewSourceKey,
  } = useOutfitStore()

  const {
    resetOutfitDraft,
    setCreationItems,
    toggleCreationItem,
    setCreationName,
    setCreationDescription,
    setCreationStyle,
    setCreationSeason,
    setCreationTags,
    setCreationOccasion,
    generateOutfitPreview,
    discardOutfitPreview,
    saveOutfitFromDraft,
  } = useOutfitStore.getState()

  // A draft is per-visit. Reset first, then honour `?items=` — the
  // Recommendations page hands its chosen pieces over this way, which is what
  // stops "Save as outfit" from silently arriving empty.
  const prefill = searchParams.get('items')
  useEffect(() => {
    resetOutfitDraft()
    if (prefill) {
      const ids = prefill.split(',').map((s) => s.trim()).filter(Boolean)
      if (ids.length > 0) setCreationItems(ids)
    }
    // Intentionally once per mount: a draft must not reset while being edited.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const loadItems = useCallback(async () => {
    setItemsLoading(true)
    setItemsError(null)
    try {
      const items = await getAvailableItems()
      setAvailable(items)
    } catch (error) {
      logger.error('Failed to load available items', error)
      setItemsError(getApiError(error).message || 'Could not load your closet')
    } finally {
      setItemsLoading(false)
    }
  }, [])

  useEffect(() => {
    void loadItems()
  }, [loadItems])

  const selectedItems = useMemo(
    () =>
      available
        .filter((item) => creationItems.has(item.id))
        .sort((a, b) => compareCategories(a.category, b.category)),
    [available, creationItems]
  )

  const isRendering = previewStatus === 'processing'
  const elapsedSeconds = useElapsedSeconds(isRendering)

  // A look generated from different clothes is not a preview of this draft.
  const currentKey = `${[...creationItems].sort().join(',')}|${creationStyle || 'casual'}`
  const isStale = previewStatus === 'ready' && previewSourceKey !== null && previewSourceKey !== currentKey

  const canRender = creationItems.size > 0 && !isRendering && !isSaving
  const canSave = creationName.trim().length > 0 && creationItems.size > 0 && !isRendering && !isSaving

  const handleGenerate = useCallback(async () => {
    const promptItems: OutfitItemInput[] = selectedItems.map((item) => ({
      name: item.name,
      category: item.category,
      colors: item.colors,
    }))
    await generateOutfitPreview(promptItems)
  }, [generateOutfitPreview, selectedItems])

  const handleSave = useCallback(async () => {
    setIsSaving(true)
    try {
      const outfit = await saveOutfitFromDraft()
      toast({ title: 'Outfit saved' })
      navigate(`/outfits/${outfit.id}`, { replace: true })
    } catch (error) {
      toast({
        title: 'Could not save this outfit',
        description: getApiError(error).message,
        variant: 'destructive',
      })
    } finally {
      setIsSaving(false)
    }
  }, [navigate, saveOutfitFromDraft, toast])

  const metaProps: OutfitMetaBarProps = {
    name: creationName,
    onNameChange: setCreationName,
    style: creationStyle,
    onStyleChange: setCreationStyle,
    season: creationSeason,
    onSeasonChange: setCreationSeason,
    occasion: creationOccasion,
    onOccasionChange: setCreationOccasion,
    tags: creationTags,
    onTagsChange: setCreationTags,
    description: creationDescription,
    onDescriptionChange: setCreationDescription,
    disabled: isSaving,
  }

  const list = (
    <div className="flex flex-col gap-lg">
      <OutfitMetaBar {...metaProps} />
      <OutfitSelectionTray
        items={selectedItems}
        onRemove={toggleCreationItem}
        disabled={isSaving}
      />
      <OutfitItemRails
        items={available}
        selectedIds={creationItems}
        onToggle={toggleCreationItem}
        isLoading={itemsLoading}
        error={itemsError}
        onRetry={() => void loadItems()}
        disabled={isSaving}
      />
    </div>
  )

  const detail = (
    <OutfitPreviewStage
      items={selectedItems}
      status={previewStatus}
      previewImageUrl={previewImageDataUrl}
      previewError={previewError}
      isStale={isStale}
      elapsedSeconds={elapsedSeconds}
      outfitName={creationName}
    />
  )

  // One filled primary only. The secondary paths are tertiary text buttons —
  // a filled/outlined pair is a template, not a hierarchy.
  const hasLook = previewStatus === 'ready' && !!previewImageDataUrl
  const detailFooter = (
    <div className="flex flex-col gap-sm">
      {hasLook ? (
        <Button className="w-full" onClick={() => void handleSave()} disabled={!canSave}>
          {isSaving ? 'Saving…' : 'Save outfit'}
        </Button>
      ) : (
        <Button className="w-full" onClick={() => void handleGenerate()} disabled={!canRender}>
          {isRendering ? `Rendering… (${elapsedSeconds}s elapsed)` : 'Generate preview'}
        </Button>
      )}

      <div className="flex items-center justify-between gap-sm">
        {hasLook ? (
          <>
            <Button
              variant="tertiary"
              onClick={() => void handleGenerate()}
              disabled={!canRender}
            >
              Generate again
            </Button>
            <Button variant="tertiary" onClick={discardOutfitPreview} disabled={isSaving}>
              Discard look
            </Button>
          </>
        ) : (
          <Button
            variant="tertiary"
            onClick={() => void handleSave()}
            disabled={!canSave}
            title="Creates the outfit with no AI look. You can generate one later."
          >
            Save without a preview
          </Button>
        )}
      </div>

      <p className="type-body-sm text-muted-foreground">
        {hasLook
          ? 'Saving attaches this look. It costs nothing further.'
          : 'Each preview uses one generation.'}
      </p>
    </div>
  )

  return (
    <div className="app-page max-w-7xl">
      <div className="mb-lg flex items-center justify-between gap-md">
        <h1 className="type-heading-xl text-foreground">Create outfit</h1>
        <Button variant="tertiary" onClick={() => navigate('/outfits')} disabled={isSaving}>
          Cancel
        </Button>
      </div>

      <MasterDetailLayout
        list={list}
        detail={detail}
        detailFooter={detailFooter}
        isDetailOpen
        onCloseDetail={() => navigate('/outfits')}
        detailTitle="Outfit preview"
        smallScreenMode="inline-lead"
      />
    </div>
  )
}
