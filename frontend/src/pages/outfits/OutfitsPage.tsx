/**
 * Outfits Page
 * View and manage created outfits
 */

import { useEffect, useMemo, useRef, useState } from 'react'
import { useParams, useSearchParams, useNavigate } from 'react-router-dom'
import { useOutfitStore } from '../../stores/outfitStore'
import { useWardrobeStore } from '../../stores/wardrobeStore'
import { useJobUiStore } from '../../stores/jobUiStore'
import { GeneratingSurface } from '@/components/jobs'
import {
  Layers,
  Plus,
  Sparkles,
  Loader2,
  Share2,
  Camera,
  MoreVertical,
  Copy,
  Check,
  Trash2,
  Search,
  Heart,
  Grid3x3,
  List,
} from 'lucide-react'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
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
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { OutfitCreateDialog } from '@/components/outfits/OutfitCreateDialog'
import { OutfitCard } from '@/components/outfits/OutfitCard'
import { ShareOutfitDialog } from '@/components/social/ShareOutfitDialog'
import { useToast } from '@/components/ui/use-toast'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import { EmptyState } from '@/components/ui/empty-state'
import { ErrorState } from '@/components/ui/error-state'
import { LoadingGrid } from '@/components/ui/loading-grid'
import { PageHeader } from '@/components/ui/page-header'
import { ItemImage } from '@/components/ui/item-image'
import type { Item } from '@/types'

export default function OutfitsPage() {
  const { id } = useParams()
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const [isShareOpen, setIsShareOpen] = useState(false)
  const [isManaging, setIsManaging] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [favoritesOnly, setFavoritesOnly] = useState(false)
  const { toast } = useToast()

  const filteredOutfits = useOutfitStore((state) => state.filteredOutfits)
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

  const wardrobeItems = useWardrobeStore((s) => s.items)
  const fetchItems = useWardrobeStore((s) => s.fetchItems)

  const displayedOutfits = useMemo(() => {
    let list = filteredOutfits
    if (favoritesOnly) list = list.filter((o) => o.is_favorite)
    const q = searchQuery.trim().toLowerCase()
    if (q) {
      list = list.filter(
        (o) =>
          o.name.toLowerCase().includes(q) ||
          (o.description || '').toLowerCase().includes(q) ||
          (o.occasion || '').toLowerCase().includes(q) ||
          (o.tags || []).some((t) => t.toLowerCase().includes(q))
      )
    }
    return list
  }, [filteredOutfits, favoritesOnly, searchQuery])

  const compositionItems: Item[] = useMemo(() => {
    if (!selectedOutfit) return []
    if (selectedOutfit.items?.length) return selectedOutfit.items
    return selectedOutfit.item_ids
      .map((itemId) => wardrobeItems.find((i) => i.id === itemId))
      .filter((i): i is Item => Boolean(i))
  }, [selectedOutfit, wardrobeItems])

  useEffect(() => {
    const action = searchParams.get('action')
    if (action === 'create') {
      startCreating()
    }
    fetchOutfits(true)
    if (wardrobeItems.length === 0) {
      void fetchItems(true).catch(() => null)
    }
  }, [fetchOutfits, searchParams, startCreating, fetchItems, wardrobeItems.length])

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
    } catch (err) {
      toast({
        title: 'Failed to mark as worn',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
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
    } catch (err) {
      toast({
        title: 'Failed to duplicate',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsManaging(false)
    }
  }

  const setJob = useJobUiStore((s) => s.setJob)
  const clearJob = useJobUiStore((s) => s.clearJob)

  const generationStageLabel =
    generationStatus === 'pending'
      ? 'Preparing…'
      : generationStatus === 'processing'
        ? 'Generating look…'
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
    <div className="max-w-7xl mx-auto px-4 md:px-6 lg:px-8 py-4 md:py-8">
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
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search outfits…"
            className="pl-9"
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
          count={8}
          variant={isGridView ? 'square' : 'list'}
          columns={isGridView ? 'grid-cols-2 md:grid-cols-3 xl:grid-cols-4' : 'grid-cols-1'}
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
                : 'Combine items from your wardrobe into a look you can wear.'
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
        <div
          className={`grid gap-3 md:gap-4 ${
            isGridView ? 'grid-cols-2 gap-2 md:gap-4 md:grid-cols-3 xl:grid-cols-4' : 'grid-cols-1'
          }`}
        >
          {displayedOutfits.map((outfit) => {
            const genStatus = generatingOutfits.get(outfit.id)?.status || null
            return (
              <OutfitCard
                key={outfit.id}
                outfit={outfit}
                variant={isGridView ? 'default' : 'list'}
                generationStatus={genStatus}
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
        </div>
      )}

      {/* Mobile primary create action is the BottomNav center FAB — avoid dual FABs */}

      {/* Outfit details + AI generation */}
      <Dialog
        open={!!selectedOutfit}
        onOpenChange={(open) => {
          if (!open) {
            setSelectedOutfit(null)
            setIsShareOpen(false)
            // Keep generation running in the background (job pill)
            if (!isGenerating) {
              resetGeneration()
            }
          }
        }}
      >
        <DialogContent className="max-w-2xl p-4 sm:p-6">
          <DialogHeader>
            <DialogTitle>{selectedOutfit?.name}</DialogTitle>
            {selectedOutfit?.description && (
              <DialogDescription>{selectedOutfit.description}</DialogDescription>
            )}
          </DialogHeader>

          {selectedOutfit && (
            <div className="space-y-4">
              <div className="aspect-square sm:aspect-[4/3] rounded-lg overflow-hidden bg-muted">
                {generatedImageUrl ? (
                  <ZoomableImage
                    src={generatedImageUrl}
                    alt={`${selectedOutfit.name} (generated)`}
                    className="w-full h-full object-cover"
                  />
                ) : selectedOutfit.images.length > 0 ? (
                  <ZoomableImage
                    src={
                      (selectedOutfit.images.find((img) => img.is_primary) || selectedOutfit.images[0]).thumbnail_url ||
                      (selectedOutfit.images.find((img) => img.is_primary) || selectedOutfit.images[0]).image_url
                    }
                    alt={selectedOutfit.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex flex-col items-center justify-center text-muted-foreground gap-2 p-4">
                    <Sparkles className="h-10 w-10 text-primary/40" />
                    <p className="text-sm font-medium text-foreground">No AI look yet</p>
                    <p className="text-xs text-center">Generate an image to visualize this outfit</p>
                  </div>
                )}
              </div>

              {/* Metadata */}
              <div className="flex flex-wrap gap-2">
                {selectedOutfit.occasion && (
                  <Badge variant="secondary" className="capitalize">{selectedOutfit.occasion}</Badge>
                )}
                {selectedOutfit.season && (
                  <Badge variant="outline" className="capitalize">{selectedOutfit.season}</Badge>
                )}
                {selectedOutfit.style && (
                  <Badge variant="outline" className="capitalize">{selectedOutfit.style}</Badge>
                )}
                <Badge variant="outline">Worn {selectedOutfit.worn_count ?? 0}×</Badge>
              </div>

              {/* Composition */}
              <div>
                <p className="text-sm font-semibold text-foreground mb-2">Items in this outfit</p>
                {compositionItems.length > 0 ? (
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                    {compositionItems.map((item) => (
                      <div
                        key={item.id}
                        className="flex items-center gap-2 p-2 rounded-lg border border-border bg-muted/30"
                      >
                        <ItemImage item={item} size="sm" />
                        <div className="min-w-0">
                          <p className="text-sm font-medium truncate">{item.name}</p>
                          <p className="text-xs text-muted-foreground capitalize">{item.category}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-muted-foreground">
                    {selectedOutfit.item_ids.length > 0
                      ? `${selectedOutfit.item_ids.length} item${selectedOutfit.item_ids.length === 1 ? '' : 's'} (details loading…)`
                      : 'No items linked to this outfit.'}
                  </p>
                )}
              </div>

              {isGenerating && (
                <GeneratingSurface
                  stage={generationStageLabel}
                  detail="Often under a minute. You can close this and reopen from the progress pill."
                  isActive
                  previewUrls={
                    compositionItems
                      .map((item) => item.images?.[0]?.thumbnail_url || item.images?.[0]?.image_url)
                      .filter(Boolean) as string[]
                  }
                  previewLabel="Items in this outfit"
                />
              )}
              {generationStatus === 'failed' && !isGenerating && (
                <p className="text-sm text-destructive">
                  Generation failed. Tap Generate look to try again.
                </p>
              )}
            </div>
          )}

          <DialogFooter className="flex-col md:flex-row gap-2">
            <div className="flex gap-2 w-full md:w-auto order-2 md:order-1">
              <Button
                variant="outline"
                onClick={() => {
                  // Soft-close: keep generation running; pill stays until done
                  setSelectedOutfit(null)
                  setIsShareOpen(false)
                  if (!isGenerating) {
                    resetGeneration()
                  }
                }}
                className="flex-1 md:flex-none"
              >
                {isGenerating ? 'Continue in background' : 'Close'}
              </Button>
              {selectedOutfit && (
                <Button
                  onClick={() => startGeneration(selectedOutfit.id, { pose: 'front', lighting: 'studio' })}
                  disabled={isGenerating || isManaging}
                  className="flex-1 md:flex-none"
                >
                  {isGenerating ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Generating…
                    </>
                  ) : (
                    <>
                      <Sparkles className="h-4 w-4 mr-2" />
                      {generationStatus === 'failed' ? 'Retry look' : 'Generate look'}
                    </>
                  )}
                </Button>
              )}
            </div>

            {selectedOutfit && (
              <>
                <div className="hidden md:flex items-center gap-2 order-2">
                  <Button variant="outline" onClick={() => setIsShareOpen(true)}>
                    <Share2 className="h-4 w-4 mr-2" />
                    Share
                  </Button>
                  <Button variant="outline" disabled={isManaging || isGenerating} onClick={() => void handleMarkWorn()}>
                    <Check className="h-4 w-4 mr-2" />
                    Mark as worn
                  </Button>
                  <Button variant="outline" disabled={isManaging || isGenerating} onClick={() => void handleDuplicate()}>
                    <Copy className="h-4 w-4 mr-2" />
                    Duplicate
                  </Button>
                  <Button
                    variant="destructive"
                    disabled={isManaging || isGenerating}
                    onClick={() => setIsDeleteDialogOpen(true)}
                  >
                    <Trash2 className="h-4 w-4 mr-2" />
                    Delete
                  </Button>
                </div>

                <div className="md:hidden order-1 w-full">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="outline" className="w-full">
                        <MoreVertical className="h-4 w-4 mr-2" />
                        More actions
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="w-48">
                      <DropdownMenuItem onClick={() => setIsShareOpen(true)}>
                        <Share2 className="h-4 w-4 mr-2" />
                        Share
                      </DropdownMenuItem>
                      <DropdownMenuItem disabled={isManaging || isGenerating} onClick={() => void handleMarkWorn()}>
                        <Check className="h-4 w-4 mr-2" />
                        Mark as worn
                      </DropdownMenuItem>
                      <DropdownMenuItem disabled={isManaging || isGenerating} onClick={() => void handleDuplicate()}>
                        <Copy className="h-4 w-4 mr-2" />
                        Duplicate
                      </DropdownMenuItem>
                      <DropdownMenuItem
                        className="text-destructive"
                        disabled={isManaging || isGenerating}
                        onClick={() => setIsDeleteDialogOpen(true)}
                      >
                        <Trash2 className="h-4 w-4 mr-2" />
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>
              </>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

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
                } catch (err) {
                  toast({
                    title: 'Failed to delete outfit',
                    description: err instanceof Error ? err.message : 'An error occurred',
                    variant: 'destructive',
                  })
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
