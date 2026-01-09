/**
 * Outfits Page
 * View and manage created outfits
 */

import { useEffect, useState } from 'react'
import { useParams, useSearchParams, useNavigate } from 'react-router-dom'
import { useOutfitStore } from '../../stores/outfitStore'
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
} from 'lucide-react'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
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

export default function OutfitsPage() {
  const { id } = useParams()
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const [isShareOpen, setIsShareOpen] = useState(false)
  const [isManaging, setIsManaging] = useState(false)
  const { toast } = useToast()

  const filteredOutfits = useOutfitStore((state) => state.filteredOutfits)
  const isLoading = useOutfitStore((state) => state.isLoading)
  const isGridView = useOutfitStore((state) => state.isGridView)
  const startCreating = useOutfitStore((state) => state.startCreating)
  const toggleOutfitFavorite = useOutfitStore((state) => state.toggleOutfitFavorite)
  const setSelectedOutfit = useOutfitStore((state) => state.setSelectedOutfit)
  const selectedOutfit = useOutfitStore((state) => state.selectedOutfit)
  const fetchOutfits = useOutfitStore((state) => state.fetchOutfits)
  const fetchOutfitById = useOutfitStore((state) => state.fetchOutfitById)
  const startGeneration = useOutfitStore((state) => state.startGeneration)
  const resetGeneration = useOutfitStore((state) => state.resetGeneration)
  const isGenerating = useOutfitStore((state) => state.isGenerating)
  const generationStatus = useOutfitStore((state) => state.generationStatus)
  const generatedImageUrl = useOutfitStore((state) => state.generatedImageUrl)
  const generatingOutfits = useOutfitStore((state) => state.generatingOutfits)
  const markOutfitAsWorn = useOutfitStore((state) => state.markOutfitAsWorn)
  const duplicateOutfit = useOutfitStore((state) => state.duplicateOutfit)
  const deleteOutfit = useOutfitStore((state) => state.deleteOutfit)

  useEffect(() => {
    const action = searchParams.get('action')
    if (action === 'create') {
      startCreating()
    }
    fetchOutfits(true)
  }, [fetchOutfits, searchParams, startCreating])

  // Handle single outfit view
  useEffect(() => {
    if (id) {
      fetchOutfitById(id).catch(() => null)
    }
  }, [fetchOutfitById, id])

  return (
    <div className="max-w-7xl mx-auto px-4 md:px-6 lg:px-8 py-4 md:py-8">
      {/* Header */}
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between mb-4 md:mb-6">
        <div>
          <h1 className="text-xl md:text-2xl font-bold text-foreground">Outfits</h1>
          <p className="text-sm text-muted-foreground">
            {filteredOutfits.length} {filteredOutfits.length === 1 ? 'outfit' : 'outfits'}
          </p>
        </div>
        <div className="hidden md:flex items-center gap-3">
          <Button
            variant="outline"
            onClick={() => navigate('/try-on')}
          >
            <Camera className="h-4 w-4 mr-2" />
            Try My Look
          </Button>
          <Button onClick={startCreating}>
            <Plus className="h-4 w-4 mr-2" />
            Create Outfit
          </Button>
        </div>
      </div>

      <div className="flex flex-col gap-2 md:hidden mb-4">
        <Button
          variant="outline"
          onClick={() => navigate('/try-on')}
          className="w-full"
        >
          <Camera className="h-4 w-4 mr-2" />
          Try My Look
        </Button>
        <Button onClick={startCreating} className="w-full">
          <Plus className="h-4 w-4 mr-2" />
          Create Outfit
        </Button>
      </div>

      {/* Outfits grid */}
      {isLoading ? (
        <div className="text-center py-12">
          <div className="inline-block animate-spin rounded-full h-8 w-8 md:h-12 md:w-12 border-b-2 border-primary"></div>
          <p className="mt-4 text-muted-foreground">Loading outfits...</p>
        </div>
      ) : filteredOutfits.length === 0 ? (
        <div className="text-center py-12 bg-card rounded-lg shadow">
          <Layers className="mx-auto h-12 w-12 md:h-16 md:w-16 text-muted-foreground" />
          <h3 className="mt-4 text-lg font-medium text-foreground">No outfits yet</h3>
          <p className="mt-2 text-sm text-muted-foreground">
            Create your first outfit by combining items from your wardrobe
          </p>
          <Button onClick={startCreating} className="mt-6">
            <Plus className="h-4 w-4 mr-2" />
            Create First Outfit
          </Button>
        </div>
      ) : (
        <div
          className={`grid gap-3 md:gap-4 ${
            isGridView ? 'grid-cols-2 gap-2 md:gap-4 md:grid-cols-3 xl:grid-cols-4' : 'grid-cols-1'
          }`}
        >
          {filteredOutfits.map((outfit) => {
            const genStatus = generatingOutfits.get(outfit.id)?.status || null
            return (
              <OutfitCard
                key={outfit.id}
                outfit={outfit}
                variant={isGridView ? 'default' : 'list'}
                generationStatus={genStatus}
                onClick={() => setSelectedOutfit(outfit)}
                onToggleFavorite={(e) => {
                  e.stopPropagation()
                  toggleOutfitFavorite(outfit.id)
                }}
              />
            )
          })}
        </div>
      )}

      {/* Floating Action Button for mobile */}
      <button
        onClick={startCreating}
        className="fixed bottom-[calc(var(--bottom-nav-height)+16px+var(--safe-area-bottom))] right-[calc(var(--safe-area-right)+1rem)] w-14 h-14 rounded-full bg-primary text-primary-foreground shadow-lg flex items-center justify-center md:hidden z-[90] hover:bg-primary/90 active:scale-95 transition-transform"
        aria-label="Create new outfit"
      >
        <Plus className="h-6 w-6" />
      </button>

      {/* Outfit details + AI generation */}
      <Dialog
        open={!!selectedOutfit}
        onOpenChange={(open) => {
          if (!open) {
            setSelectedOutfit(null)
            resetGeneration()
            setIsShareOpen(false)
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
            <div className="space-y-3 sm:space-y-4">
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
                  <div className="w-full h-full flex items-center justify-center text-muted-foreground">
                    <Layers className="h-10 w-10" />
                  </div>
                )}
              </div>

              {generationStatus !== 'idle' && (
                <div className="text-xs sm:text-sm text-muted-foreground">
                  Status: <span className="capitalize">{generationStatus}</span>
                </div>
              )}
            </div>
          )}

          <DialogFooter className="flex-col md:flex-row gap-2">
            {/* Primary actions visible on all screens */}
            <div className="flex gap-2 w-full md:w-auto order-2 md:order-1">
              <Button
                variant="outline"
                onClick={() => {
                  setSelectedOutfit(null)
                  resetGeneration()
                  setIsShareOpen(false)
                }}
                className="flex-1 md:flex-none"
              >
                Close
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
                      <span className="hidden xs:inline">Generating...</span>
                      <span className="xs:hidden">...</span>
                    </>
                  ) : (
                    <>
                      <Sparkles className="h-4 w-4 mr-2" />
                      <span className="hidden xs:inline">Generate AI Image</span>
                      <span className="xs:hidden">AI Generate</span>
                    </>
                  )}
                </Button>
              )}
            </div>

            {/* Secondary actions in dropdown on mobile, visible on desktop */}
            {selectedOutfit && (
              <>
                <div className="hidden md:flex items-center gap-2 order-2">
                  <Button variant="outline" onClick={() => setIsShareOpen(true)}>
                    <Share2 className="h-4 w-4 mr-2" />
                    Share
                  </Button>
                  <Button
                    variant="outline"
                    disabled={isManaging || isGenerating}
                    onClick={async () => {
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
                    }}
                  >
                    <Check className="h-4 w-4 mr-2" />
                    Mark Worn
                  </Button>
                  <Button
                    variant="outline"
                    disabled={isManaging || isGenerating}
                    onClick={async () => {
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
                    }}
                  >
                    <Copy className="h-4 w-4 mr-2" />
                    Duplicate
                  </Button>
                  <Button
                    variant="destructive"
                    disabled={isManaging || isGenerating}
                    onClick={async () => {
                      if (!confirm('Delete this outfit?')) return
                      setIsManaging(true)
                      try {
                        await deleteOutfit(selectedOutfit.id)
                        toast({ title: 'Outfit deleted' })
                        setSelectedOutfit(null)
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
                    <Trash2 className="h-4 w-4 mr-2" />
                    Delete
                  </Button>
                </div>

                {/* Mobile dropdown menu for secondary actions */}
                <div className="md:hidden order-1 w-full">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="outline" className="w-full">
                        <MoreVertical className="h-4 w-4 mr-2" />
                        More Actions
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="w-48">
                      <DropdownMenuItem onClick={() => setIsShareOpen(true)}>
                        <Share2 className="h-4 w-4 mr-2" />
                        Share
                      </DropdownMenuItem>
                      <DropdownMenuItem
                        disabled={isManaging || isGenerating}
                        onClick={async () => {
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
                        }}
                      >
                        <Check className="h-4 w-4 mr-2" />
                        Mark as Worn
                      </DropdownMenuItem>
                      <DropdownMenuItem
                        disabled={isManaging || isGenerating}
                        onClick={async () => {
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
                        }}
                      >
                        <Copy className="h-4 w-4 mr-2" />
                        Duplicate
                      </DropdownMenuItem>
                      <DropdownMenuItem
                        className="text-destructive"
                        disabled={isManaging || isGenerating}
                        onClick={async () => {
                          if (!confirm('Delete this outfit?')) return
                          setIsManaging(true)
                          try {
                            await deleteOutfit(selectedOutfit.id)
                            toast({ title: 'Outfit deleted' })
                            setSelectedOutfit(null)
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

      <OutfitCreateDialog />
    </div>
  )
}
