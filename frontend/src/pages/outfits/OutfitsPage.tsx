/**
 * Outfits Page
 * View and manage created outfits
 */

import { useEffect, useMemo, useRef, useState } from 'react'
import { useParams, useSearchParams, useNavigate } from 'react-router-dom'
import {
  useFilteredOutfits,
  useOutfitStore,
} from '../../stores/outfitStore'
import { useClosetStore } from '../../stores/wardrobeStore'
import { useJobUiStore } from '../../stores/jobUiStore'
import { useElapsedSeconds } from '@/hooks/useElapsedSeconds'
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
import { OutfitCreateDialog } from '@/components/outfits/OutfitCreateDialog'
import { OutfitCard } from '@/components/outfits/OutfitCard'
import { OutfitDetailPanel } from '@/components/outfits/OutfitDetailPanel'
import { ShareOutfitDialog } from '@/components/social/ShareOutfitDialog'
import { useToast } from '@/components/ui/use-toast'
import { EmptyState } from '@/components/ui/empty-state'
import { ErrorState } from '@/components/ui/error-state'
import { LoadingGrid } from '@/components/ui/loading-grid'
import { PageHeader } from '@/components/ui/page-header'
import { PinGrid } from '@/components/wardrobe/pin-grid'
import type { Outfit } from '@/types'

export default function OutfitsPage() {
  const { id } = useParams()
  const [searchParams] = useSearchParams()
  const requestedAction = searchParams.get('action')
  const navigate = useNavigate()
  const [isShareOpen, setIsShareOpen] = useState(false)
  const [isManaging, setIsManaging] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [favoritesOnly, setFavoritesOnly] = useState(false)
  const { toast } = useToast()

  const filteredOutfits = useFilteredOutfits()
  const isLoading = useOutfitStore((state) => state.isLoading)
  const error = useOutfitStore((state) => state.error)
  const isGridView = useOutfitStore((state) => state.isGridView)
  const setGridView = useOutfitStore((state) => state.setGridView)
  const startCreating = useOutfitStore((state) => state.startCreating)
  const toggleOutfitFavorite = useOutfitStore((state) => state.toggleOutfitFavorite)
  const setSelectedOutfit = useOutfitStore((state) => state.setSelectedOutfit)
  const selectedOutfit = useOutfitStore((state) => state.selectedOutfit)
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
    if (requestedAction === 'create') {
      startCreating()
    }
    fetchOutfits(true)
    if (wardrobeItems.length === 0) {
      void fetchItems(true).catch(() => null)
    }
  }, [fetchOutfits, requestedAction, startCreating, fetchItems, wardrobeItems.length])

  // Handle single outfit view
  useEffect(() => {
    if (id) {
      fetchOutfitById(id).catch(() => null)
    }
  }, [fetchOutfitById, id])

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
      setSelectedOutfit(dup)
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

  // Remember dialog-gen outfit even after soft-close (selectedOutfit becomes null).
  const dialogGenOutfitIdRef = useRef<string | null>(null)
  useEffect(() => {
    if (isGenerating && selectedOutfit?.id) {
      dialogGenOutfitIdRef.current = selectedOutfit.id
    }
    if (!isGenerating && generationStatus !== 'pending' && generationStatus !== 'processing') {
      dialogGenOutfitIdRef.current = null
    }
  }, [isGenerating, selectedOutfit?.id, generationStatus])

  // Dialog generate (isGenerating) OR fire-and-forget after create (generatingOutfits map)
  const mapGeneratingEntry = Array.from(generatingOutfits.entries()).find(
    ([, v]) => v.status === 'pending' || v.status === 'processing'
  )
  const generatingOutfitId =
    (isGenerating
      ? selectedOutfit?.id || dialogGenOutfitIdRef.current || undefined
      : undefined) || mapGeneratingEntry?.[0]
  const isOutfitGenActive = isGenerating || Boolean(mapGeneratingEntry)

  // Background pill while generate look runs (including when dialog closed)
  useEffect(() => {
    if (!isOutfitGenActive) {
      clearJob('outfit-generate')
      return
    }
    const outfitId =
      generatingOutfitId || selectedOutfit?.id || dialogGenOutfitIdRef.current || undefined
    const name =
      selectedOutfit?.name ||
      (outfitId ? filteredOutfits.find((o) => o.id === outfitId)?.name : undefined)
    setJob({
      id: 'outfit-generate',
      label: name ? `Generating look · ${name}` : 'Generating outfit look…',
      isActive: true,
      href: '/outfits',
      onOpen: () => {
        if (outfitId) {
          const outfit =
            filteredOutfits.find((o) => o.id === outfitId) ||
            useOutfitStore.getState().outfits.find((o) => o.id === outfitId) ||
            selectedOutfit
          if (outfit) setSelectedOutfit(outfit)
        }
      },
    })
  }, [
    isOutfitGenActive,
    generatingOutfitId,
    selectedOutfit,
    filteredOutfits,
    setJob,
    clearJob,
    setSelectedOutfit,
  ])

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
        <Button onClick={startCreating} className="w-full md:w-auto hidden md:inline-flex">
          <Plus className="h-4 w-4 mr-2" />
          Create Outfit
        </Button>
      </PageHeader>

      <div className="md:hidden mb-4">
        <Button onClick={startCreating} className="w-full">
          <Plus className="h-4 w-4 mr-2" />
          Create Outfit
        </Button>
      </div>

      {/* Search + filters */}
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
            className={favoritesOnly ? 'bg-pink-500 hover:bg-pink-500/90 border-pink-500' : ''}
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

      {/* Outfits grid */}
      {isLoading ? (
        <LoadingGrid
          count={12}
          variant={isGridView ? 'masonry' : 'list'}
          columns={
            isGridView
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
              startCreating()
            }
          }}
        />
      ) : (
        isGridView ? (
          <PinGrid>
            {displayedOutfits.map((outfit) => {
            const genEntry = generatingOutfits.get(outfit.id)
            const genStatus = genEntry?.status || null
            return (
              <OutfitCard
                key={outfit.id}
                outfit={outfit}
                variant="default"
                generationStatus={genStatus}
                generationError={genEntry?.error}
                onClick={() => {
                  if (genStatus === 'failed') {
                    void startGenerationForNewOutfit(outfit.id)
                    return
                  }
                  setSelectedOutfit(outfit)
                }}
                onToggleFavorite={(e) => {
                  e.stopPropagation()
                  toggleOutfitFavorite(outfit.id)
                }}
              />
            )
            })}
          </PinGrid>
        ) : (
          <div className="grid grid-cols-1 gap-2">
            {displayedOutfits.map((outfit) => {
              const genEntry = generatingOutfits.get(outfit.id)
              return <OutfitCard key={outfit.id} outfit={outfit} variant="list" generationStatus={genEntry?.status || null} generationError={genEntry?.error} onClick={() => setSelectedOutfit(outfit)} onToggleFavorite={(e) => { e.stopPropagation(); toggleOutfitFavorite(outfit.id) }} />
            })}
          </div>
        )
      )}

      {/* Mobile primary create action is the BottomNav center FAB — avoid dual FABs */}

      {/* Outfit details side panel + AI generation */}
      <OutfitDetailPanel
        outfit={selectedOutfit}
        open={!!selectedOutfit}
        onClose={() => {
          setSelectedOutfit(null)
          setIsShareOpen(false)
          if (!isGenerating) {
            resetGeneration()
          }
        }}
        wardrobeItems={wardrobeItems}
        generatedImageUrl={generatedImageUrl}
        isGenerating={isGenerating}
        generationStatus={generationStatus}
        generationStageLabel={generationStageLabel}
        isManaging={isManaging}
        onGenerate={() =>
          selectedOutfit && startGeneration(selectedOutfit.id, { pose: 'front', lighting: 'studio' })
        }
        onShare={() => setIsShareOpen(true)}
        onMarkWorn={() => void handleMarkWorn()}
        onDuplicate={() => void handleDuplicate()}
        onDelete={() => setIsDeleteDialogOpen(true)}
      />

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
                  setSelectedOutfit(null)
                  setIsDeleteDialogOpen(false)
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

      <OutfitCreateDialog />
    </div>
  )
}
