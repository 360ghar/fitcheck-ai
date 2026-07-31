/**
 * Outfits Page
 *
 * Browse and manage outfits. The detail surface is an in-window split pane at
 * `md`+ (never a modal over the list), and the URL — `/outfits/:id` — is the
 * single source of truth for what is selected, so Back/Forward walk selections
 * and closing genuinely clears the id.
 */

import { useEffect, useMemo, useState } from 'react'
import { useParams, useSearchParams, useNavigate, useLocation, Navigate } from 'react-router-dom'
import {
  useFilteredOutfits,
  useOutfitStore,
} from '../../stores/outfitStore'
import { useClosetStore } from '../../stores/wardrobeStore'
import { useJobUiStore } from '../../stores/jobUiStore'
import { useElapsedSeconds } from '@/hooks/useElapsedSeconds'
import { useIsSplitViewport, useIsWideViewport } from '@/hooks/useMediaQuery'
import {
  Layers,
  Plus,
  Camera,
  Heart,
  Grid3x3,
  List,
} from 'lucide-react'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'
import { SearchBar } from '@/components/ui/search-bar'
import { MasterDetailLayout } from '@/components/layout/MasterDetailLayout'
import { OutfitCard } from '@/components/outfits/OutfitCard'
import { OutfitDetailPanel } from '@/components/outfits/OutfitDetailPanel'
import { OutfitDetailActions } from '@/components/outfits/OutfitDetailActions'
import { ShareOutfitDialog } from '@/components/social/ShareOutfitDialog'
import { useToast } from '@/components/ui/use-toast'
import { EmptyState } from '@/components/ui/empty-state'
import { ErrorState } from '@/components/ui/error-state'
import { LoadingGrid } from '@/components/ui/loading-grid'
import { PageHeader } from '@/components/ui/page-header'
import { PinGrid } from '@/components/wardrobe/pin-grid'
import type { Outfit } from '@/types'

const LIST_PATH = '/outfits'
// With the pane taking its share of a 1280px cap, the masonry gives up columns
// rather than the page giving up width (DESIGN.md 05).
const SPLIT_COLUMNS = 'lg:columns-2 xl:columns-3 2xl:columns-4'

export default function OutfitsPage() {
  const { id } = useParams()
  const [searchParams] = useSearchParams()
  const requestedAction = searchParams.get('action')
  const navigate = useNavigate()
  const location = useLocation()
  const [isShareOpen, setIsShareOpen] = useState(false)
  const [isManaging, setIsManaging] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [favoritesOnly, setFavoritesOnly] = useState(false)
  // Which outfit the store's GLOBAL generation state belongs to. The pane now
  // persists across selections instead of unmounting, so without this the
  // generated image, the progress surface and the failure line from outfit A
  // would all render against outfit B the moment you clicked it.
  const [generationOutfitId, setGenerationOutfitId] = useState<string | null>(null)
  const { toast } = useToast()

  const filteredOutfits = useFilteredOutfits()
  const outfits = useOutfitStore((state) => state.outfits)
  const isLoading = useOutfitStore((state) => state.isLoading)
  const isDetailLoading = useOutfitStore((state) => state.isDetailLoading)
  const error = useOutfitStore((state) => state.error)
  const isGridView = useOutfitStore((state) => state.isGridView)
  const setGridView = useOutfitStore((state) => state.setGridView)
  const toggleOutfitFavorite = useOutfitStore((state) => state.toggleOutfitFavorite)
  const setSelectedOutfit = useOutfitStore((state) => state.setSelectedOutfit)
  const storeSelectedOutfit = useOutfitStore((state) => state.selectedOutfit)
  const fetchOutfits = useOutfitStore((state) => state.fetchOutfits)
  const fetchOutfitById = useOutfitStore((state) => state.fetchOutfitById)
  const startGeneration = useOutfitStore((state) => state.startGeneration)
  const startGenerationForNewOutfit = useOutfitStore((state) => state.startGenerationForNewOutfit)
  const resetGeneration = useOutfitStore((state) => state.resetGeneration)
  const isGenerating = useOutfitStore((state) => state.isGenerating)
  const generationStatus = useOutfitStore((state) => state.generationStatus)
  const generatedImageUrl = useOutfitStore((state) => state.generatedImageUrl)
  const generatingOutfits = useOutfitStore((state) => state.generatingOutfits)
  const markOutfitAsWorn = useOutfitStore((state) => state.markOutfitAsWorn)
  const duplicateOutfit = useOutfitStore((state) => state.duplicateOutfit)
  const deleteOutfit = useOutfitStore((state) => state.deleteOutfit)
  const clearError = useOutfitStore((state) => state.clearError)

  const wardrobeItems = useClosetStore((s) => s.items)
  const fetchItems = useClosetStore((s) => s.fetchItems)

  // `/outfits/new` belongs to the create route; it is never a selection.
  const selectedId = id && id !== 'new' ? id : null

  // The URL is the source of truth. `selectedOutfit` in the store is demoted to a
  // mirror — four reducers still patch it, and `fetchOutfitById` still writes it,
  // so it stays useful as the fallback for a deep link that is not in the list yet.
  const selectedOutfit: Outfit | null = useMemo(() => {
    if (!selectedId) return null
    return (
      outfits.find((o) => o.id === selectedId) ||
      (storeSelectedOutfit?.id === selectedId ? storeSelectedOutfit : null)
    )
  }, [selectedId, outfits, storeSelectedOutfit])

  useEffect(() => {
    if (selectedId) {
      if (selectedOutfit && storeSelectedOutfit?.id !== selectedOutfit.id) {
        setSelectedOutfit(selectedOutfit)
      }
    } else if (storeSelectedOutfit) {
      setSelectedOutfit(null)
    }
  }, [selectedId, selectedOutfit, storeSelectedOutfit, setSelectedOutfit])

  const isDetailOpen = Boolean(selectedId)

  const displayedOutfits = useMemo(() => {
    let list: Outfit[] = filteredOutfits
    if (favoritesOnly) list = list.filter((o: Outfit) => o.is_favorite)
    const q = searchQuery.trim().toLowerCase()
    if (q) {
      list = list.filter(
        (o: Outfit) =>
          o.name.toLowerCase().includes(q) ||
          (o.description || '').toLowerCase().includes(q) ||
          (o.occasion || '').toLowerCase().includes(q) ||
          (o.tags || []).some((t: string) => t.toLowerCase().includes(q))
      )
    }
    return list
  }, [filteredOutfits, favoritesOnly, searchQuery])

  useEffect(() => {
    fetchOutfits(true)
    if (wardrobeItems.length === 0) {
      void fetchItems(true).catch(() => null)
    }
  }, [fetchOutfits, fetchItems, wardrobeItems.length])

  // Deep link only. `getState()` rather than a reactive read so this cannot
  // re-run every time the outfits array is patched.
  useEffect(() => {
    if (!selectedId) return
    if (useOutfitStore.getState().outfits.some((o) => o.id === selectedId)) return
    fetchOutfitById(selectedId).catch(() => null)
  }, [selectedId, fetchOutfitById])

  const openOutfit = (outfit: Outfit, genStatus: string | null) => {
    // Retry short-circuit stays first: a failed card is a retry affordance, not a
    // link, and must not navigate.
    if (genStatus === 'failed') {
      void startGenerationForNewOutfit(outfit.id)
      return
    }
    navigate({ pathname: `${LIST_PATH}/${outfit.id}`, search: location.search })
  }

  const closeDetail = () => {
    // Pushed, not replaced, so Back walks the selection. This is also the fix for
    // the reported bug: the id used to survive a close, so the same card could
    // never be reopened.
    navigate({ pathname: LIST_PATH, search: location.search })
    setIsShareOpen(false)
    if (!isGenerating) {
      resetGeneration()
      setGenerationOutfitId(null)
    }
  }

  const handleMarkWorn = async () => {
    if (!selectedOutfit) return
    setIsManaging(true)
    try {
      await markOutfitAsWorn(selectedOutfit.id)
      toast({ title: 'Marked as worn' })
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      setIsManaging(false)
    }
  }

  const handleDuplicate = async () => {
    if (!selectedOutfit) return
    setIsManaging(true)
    try {
      const dup = await duplicateOutfit(selectedOutfit.id)
      navigate({ pathname: `${LIST_PATH}/${dup.id}`, search: location.search })
      toast({ title: 'Outfit duplicated' })
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      setIsManaging(false)
    }
  }

  const setJob = useJobUiStore((s) => s.setJob)
  const clearJob = useJobUiStore((s) => s.clearJob)

  // Single opaque client-side AI call — no real phases, so the honest signal
  // is elapsed time, never a fabricated percentage.
  const generationElapsed = useElapsedSeconds(generationStatus === 'processing')
  const generationStageLabel =
    generationStatus === 'pending'
      ? 'Preparing…'
      : generationStatus === 'processing'
        ? `Generating look… (${generationElapsed}s elapsed)`
        : generationStatus === 'failed'
          ? 'Generation failed'
          : generationStatus === 'completed'
            ? 'Look ready'
            : 'Working…'

  // Pane generate (isGenerating) OR fire-and-forget after create (generatingOutfits map).
  // `generationOutfitId` survives a soft close, so the pill still names the outfit
  // after the selection has left the URL.
  const mapGeneratingEntry = Array.from(generatingOutfits.entries()).find(
    ([, v]) => v.status === 'pending' || v.status === 'processing'
  )
  const generatingOutfitId =
    (isGenerating ? generationOutfitId || undefined : undefined) || mapGeneratingEntry?.[0]
  const isOutfitGenActive = isGenerating || Boolean(mapGeneratingEntry)

  // Background pill while generate look runs (including when the pane is closed).
  useEffect(() => {
    if (!isOutfitGenActive) {
      clearJob('outfit-generate')
      return
    }
    const outfitId = generatingOutfitId || undefined
    const name = outfitId ? filteredOutfits.find((o) => o.id === outfitId)?.name : undefined
    setJob({
      id: 'outfit-generate',
      label: name ? `Generating look · ${name}` : 'Generating outfit look…',
      isActive: true,
      // A URL, not an onOpen callback: selection is routing now, so the pill works
      // cross-route with no page-local reopen dance.
      href: outfitId ? `${LIST_PATH}/${outfitId}` : LIST_PATH,
    })
  }, [isOutfitGenActive, generatingOutfitId, filteredOutfits, setJob, clearJob])

  const isSplitViewport = useIsSplitViewport()
  const isWideViewport = useIsWideViewport()
  // At exactly `md` the sidebar is expanded and a 44% pane leaves ~270px of list —
  // one cramped masonry column. Compact rows read better in that band.
  const forceListRows = isDetailOpen && isSplitViewport && !isWideViewport
  const showMasonry = isGridView && !forceListRows

  const selectionHiddenByFilters =
    isDetailOpen && Boolean(selectedOutfit) && !displayedOutfits.some((o) => o.id === selectedId)

  const isGenerationForSelected = Boolean(selectedId) && generationOutfitId === selectedId

  const renderCard = (outfit: Outfit, variant: 'default' | 'list') => {
    const genEntry = generatingOutfits.get(outfit.id)
    const genStatus = genEntry?.status || null
    const isSelected = outfit.id === selectedId
    return (
      <div key={outfit.id} aria-current={isSelected ? 'true' : undefined}>
        <OutfitCard
          outfit={outfit}
          variant={variant}
          generationStatus={genStatus}
          generationError={genEntry?.error}
          className={isSelected ? 'border-ink' : undefined}
          onClick={() => openOutfit(outfit, genStatus)}
          onToggleFavorite={(e) => {
            e.stopPropagation()
            toggleOutfitFavorite(outfit.id)
          }}
        />
      </div>
    )
  }

  const listContent = isLoading ? (
    <LoadingGrid
      count={12}
      variant={showMasonry ? 'masonry' : 'list'}
      className={showMasonry && isDetailOpen ? SPLIT_COLUMNS : undefined}
      columns={
        showMasonry
          ? 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6'
          : 'grid-cols-1'
      }
    />
  ) : error ? (
    <ErrorState
      icon={Layers}
      title="Couldn't load outfits"
      description={error.message || 'Something went wrong. Please try again.'}
      onRetry={() => {
        clearError()
        void fetchOutfits(true)
      }}
    />
  ) : displayedOutfits.length === 0 ? (
    <EmptyState
      icon={Layers}
      title={searchQuery || favoritesOnly ? 'No matching outfits' : 'No outfits yet'}
      description={
        searchQuery || favoritesOnly
          ? 'Try a different search or clear filters'
          : wardrobeItems.length === 0
            ? 'Add clothes first — AI extracts items from your photos, then you can build outfits.'
            : 'Combine items from your closet into a look you can wear.'
      }
      actionLabel={
        searchQuery || favoritesOnly
          ? 'Clear filters'
          : wardrobeItems.length === 0
            ? 'Upload photos'
            : 'Create first outfit'
      }
      onAction={() => {
        if (searchQuery || favoritesOnly) {
          setSearchQuery('')
          setFavoritesOnly(false)
        } else if (wardrobeItems.length === 0) {
          navigate('/wardrobe?action=add')
        } else {
          navigate('/outfits/new')
        }
      }}
    />
  ) : showMasonry ? (
    <PinGrid className={isDetailOpen ? SPLIT_COLUMNS : undefined}>
      {displayedOutfits.map((outfit) => renderCard(outfit, 'default'))}
    </PinGrid>
  ) : (
    <div className="grid grid-cols-1 gap-2">
      {displayedOutfits.map((outfit) => renderCard(outfit, 'list'))}
    </div>
  )

  // Back-compat: creating used to be a dialog opened by `?action=create`.
  // Bookmarks and any in-flight links keep working. Placed after every hook so
  // the hook order is identical on the render that redirects.
  if (requestedAction === 'create') {
    return <Navigate to="/outfits/new" replace />
  }

  return (
    <div className="app-page max-w-7xl">
      <PageHeader
        title="Outfits"
        description={`${displayedOutfits.length} ${displayedOutfits.length === 1 ? 'outfit' : 'outfits'}`}
      >
        <Button variant="outline" onClick={() => navigate('/try-on')} className="w-full md:w-auto">
          <Camera className="h-4 w-4 mr-2" />
          Try My Look
        </Button>
        <Button onClick={() => navigate('/outfits/new')} className="w-full md:w-auto hidden md:inline-flex">
          <Plus className="h-4 w-4 mr-2" />
          Create Outfit
        </Button>
      </PageHeader>

      <div className="md:hidden mb-4">
        <Button onClick={() => navigate('/outfits/new')} className="w-full">
          <Plus className="h-4 w-4 mr-2" />
          Create Outfit
        </Button>
      </div>

      {/* Search + filters stay full width ABOVE the split — the list shrinks, the
          page does not change. */}
      <div className="flex flex-col sm:flex-row gap-2 mb-4">
        <div className="flex-1">
          <SearchBar
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search outfits…"
            aria-label="Search outfits"
          />
        </div>
        <div className="flex gap-2">
          <Button
            type="button"
            variant={favoritesOnly ? 'default' : 'outline'}
            size="icon"
            aria-label="Favorites only"
            aria-pressed={favoritesOnly}
            onClick={() => setFavoritesOnly((v) => !v)}
          >
            <Heart className={`h-4 w-4 ${favoritesOnly ? 'fill-current' : ''}`} />
          </Button>
          <Button
            type="button"
            variant={isGridView ? 'default' : 'outline'}
            size="icon"
            aria-label="Grid view"
            onClick={() => setGridView(true)}
          >
            <Grid3x3 className="h-4 w-4" />
          </Button>
          <Button
            type="button"
            variant={!isGridView ? 'default' : 'outline'}
            size="icon"
            aria-label="List view"
            onClick={() => setGridView(false)}
          >
            <List className="h-4 w-4" />
          </Button>
        </div>
      </div>

      <MasterDetailLayout
        isDetailOpen={isDetailOpen}
        onCloseDetail={closeDetail}
        detailTitle={selectedOutfit?.name || 'Outfit'}
        list={listContent}
        detail={
          <OutfitDetailPanel
            outfit={selectedOutfit}
            isDetailLoading={isDetailLoading}
            wardrobeItems={wardrobeItems}
            generatedImageUrl={isGenerationForSelected ? generatedImageUrl : null}
            isGenerating={isGenerating && isGenerationForSelected}
            generationStatus={isGenerationForSelected ? generationStatus : 'idle'}
            generationStageLabel={generationStageLabel}
            notice={selectionHiddenByFilters ? 'Hidden by the current filters.' : null}
          />
        }
        detailFooter={
          selectedOutfit ? (
            <OutfitDetailActions
              // `isGenerating` stays GLOBAL here on purpose: the client runs one
              // generation at a time, so the button must be disabled even when the
              // running job belongs to another outfit. Only the label is scoped.
              isGenerating={isGenerating}
              isManaging={isManaging}
              generationStatus={isGenerationForSelected ? generationStatus : 'idle'}
              onGenerate={() => {
                setGenerationOutfitId(selectedOutfit.id)
                void startGeneration(selectedOutfit.id, { pose: 'front', lighting: 'studio' })
              }}
              onShare={() => setIsShareOpen(true)}
              onMarkWorn={() => void handleMarkWorn()}
              onDuplicate={() => void handleDuplicate()}
              onDelete={() => setIsDeleteDialogOpen(true)}
            />
          ) : undefined
        }
      />

      {/* Mobile primary create action is the BottomNav center FAB — avoid dual FABs */}

      <ShareOutfitDialog
        isOpen={isShareOpen}
        onClose={() => setIsShareOpen(false)}
        outfit={selectedOutfit}
      />

      <AlertDialog
        open={isDeleteDialogOpen}
        onOpenChange={(open) => {
          if (!isManaging) setIsDeleteDialogOpen(open)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete outfit?</AlertDialogTitle>
            <AlertDialogDescription>
              {selectedOutfit
                ? `"${selectedOutfit.name}" will be permanently deleted. This cannot be undone.`
                : 'This outfit will be permanently deleted.'}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isManaging}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              disabled={isManaging || !selectedOutfit}
              onClick={async (e) => {
                e.preventDefault()
                if (!selectedOutfit) return
                setIsManaging(true)
                try {
                  await deleteOutfit(selectedOutfit.id)
                  toast({ title: 'Outfit deleted' })
                  setIsDeleteDialogOpen(false)
                  // replace, so Back cannot land on a deleted id.
                  navigate({ pathname: LIST_PATH, search: location.search }, { replace: true })
                } catch {
                  // api/client interceptor already toasts the failure.
                } finally {
                  setIsManaging(false)
                }
              }}
            >
              {isManaging ? 'Deleting…' : 'Delete'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

    </div>
  )
}
