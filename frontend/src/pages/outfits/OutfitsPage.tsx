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
  Heart,
  Loader2,
  Share2,
  Camera,
} from 'lucide-react'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { OutfitCreateDialog } from '@/components/outfits/OutfitCreateDialog'
import { ShareOutfitDialog } from '@/components/social/ShareOutfitDialog'
import { useToast } from '@/components/ui/use-toast'

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
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Outfits</h1>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            {filteredOutfits.length} {filteredOutfits.length === 1 ? 'outfit' : 'outfits'}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button
            variant="outline"
            onClick={() => navigate('/try-on')}
          >
            <Camera className="h-4 w-4 mr-2" />
            Try My Look
          </Button>
          <button
            onClick={startCreating}
            className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
          >
            <Plus className="h-4 w-4 mr-2" />
            Create Outfit
          </button>
        </div>
      </div>

      {/* Outfits grid */}
      {isLoading ? (
        <div className="text-center py-12">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Loading outfits...</p>
        </div>
      ) : filteredOutfits.length === 0 ? (
        <div className="text-center py-12 bg-white dark:bg-gray-800 rounded-lg shadow dark:shadow-gray-900/50">
          <Layers className="mx-auto h-16 w-16 text-gray-400 dark:text-gray-500" />
          <h3 className="mt-4 text-lg font-medium text-gray-900 dark:text-white">No outfits yet</h3>
          <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
            Create your first outfit by combining items from your wardrobe
          </p>
          <button
            onClick={startCreating}
            className="mt-6 inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
          >
            <Plus className="h-4 w-4 mr-2" />
            Create First Outfit
          </button>
        </div>
      ) : (
        <div
          className={`grid gap-6 ${
            isGridView ? 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4' : 'grid-cols-1'
          }`}
        >
          {filteredOutfits.map((outfit) => (
            <div
              key={outfit.id}
              className="bg-white dark:bg-gray-800 rounded-lg shadow dark:shadow-gray-900/50 hover:shadow-md transition-shadow cursor-pointer relative group"
              onClick={() => setSelectedOutfit(outfit)}
            >
              {/* Favorite button */}
              <button
                className={`absolute top-3 right-3 z-10 p-1.5 rounded-full ${
                  outfit.is_favorite
                    ? 'bg-pink-100 dark:bg-pink-900/30 text-pink-600 dark:text-pink-400'
                    : 'bg-white/80 dark:bg-gray-700/80 text-gray-400 hover:text-pink-500 dark:hover:text-pink-400'
                }`}
                onClick={(e) => {
                  e.stopPropagation()
                  toggleOutfitFavorite(outfit.id)
                }}
              >
                <Heart
                  className={`h-4 w-4 ${outfit.is_favorite ? 'fill-current' : ''}`}
                />
              </button>

              {/* Outfit image or items grid */}
              <div className="aspect-[4/3] rounded-t-lg overflow-hidden bg-gray-100 dark:bg-gray-700">
                {outfit.images.length > 0 ? (
                  <img
                    src={
                      (outfit.images.find((img) => img.is_primary) || outfit.images[0]).thumbnail_url ||
                      (outfit.images.find((img) => img.is_primary) || outfit.images[0]).image_url
                    }
                    alt={outfit.name}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center p-4">
                    <div className="grid grid-cols-3 gap-2">
                      {outfit.item_ids.slice(0, 6).map((_, index) => (
                        <div
                          key={index}
                          className="aspect-square bg-gray-200 dark:bg-gray-600 rounded flex items-center justify-center"
                        >
                          <Layers className="h-6 w-6 text-gray-400 dark:text-gray-500" />
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Outfit info */}
              <div className="p-4">
                <h3 className="font-medium text-gray-900 dark:text-white truncate">{outfit.name}</h3>
                {outfit.description && (
                  <p className="text-sm text-gray-600 dark:text-gray-400 line-clamp-2 mt-1">{outfit.description}</p>
                )}
                <div className="flex items-center justify-between mt-2">
                  <span className="text-xs text-gray-500 dark:text-gray-400">
                    {outfit.item_ids.length} {outfit.item_ids.length === 1 ? 'item' : 'items'}
                  </span>
                  {outfit.style && (
                    <span className="text-xs px-2 py-0.5 bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 rounded-full capitalize">
                      {outfit.style}
                    </span>
                  )}
                </div>
                {outfit.worn_count > 0 && (
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
                    Worn {outfit.worn_count} {outfit.worn_count === 1 ? 'time' : 'times'}
                  </p>
                )}
              </div>

              {/* AI generation indicator */}
              {outfit.images.some((img) => img.generation_type === 'ai') && (
                <div className="absolute top-3 left-3 flex items-center gap-1 px-2 py-1 bg-purple-100 dark:bg-purple-900/30 rounded-full">
                  <Sparkles className="h-3 w-3 text-purple-600 dark:text-purple-400" />
                  <span className="text-xs font-medium text-purple-700 dark:text-purple-300">AI</span>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

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
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>{selectedOutfit?.name}</DialogTitle>
            {selectedOutfit?.description && (
              <DialogDescription>{selectedOutfit.description}</DialogDescription>
            )}
          </DialogHeader>

          {selectedOutfit && (
            <div className="space-y-4">
              <div className="aspect-[4/3] rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-700">
                {generatedImageUrl ? (
                  <img
                    src={generatedImageUrl}
                    alt={`${selectedOutfit.name} (generated)`}
                    className="w-full h-full object-cover"
                  />
                ) : selectedOutfit.images.length > 0 ? (
                  <img
                    src={
                      (selectedOutfit.images.find((img) => img.is_primary) || selectedOutfit.images[0]).thumbnail_url ||
                      (selectedOutfit.images.find((img) => img.is_primary) || selectedOutfit.images[0]).image_url
                    }
                    alt={selectedOutfit.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-gray-400 dark:text-gray-500">
                    <Layers className="h-10 w-10" />
                  </div>
                )}
              </div>

              {generationStatus !== 'idle' && (
                <div className="text-sm text-gray-600 dark:text-gray-400">
                  Status: <span className="capitalize">{generationStatus}</span>
                </div>
              )}
            </div>
          )}

          <DialogFooter className="gap-2">
            <Button
              variant="outline"
              onClick={() => {
                setSelectedOutfit(null)
                resetGeneration()
                setIsShareOpen(false)
              }}
            >
              Close
            </Button>
            {selectedOutfit && (
              <Button variant="outline" onClick={() => setIsShareOpen(true)}>
                <Share2 className="h-4 w-4 mr-2" />
                Share
              </Button>
            )}
            {selectedOutfit && (
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
                Mark as worn
              </Button>
            )}
            {selectedOutfit && (
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
                Duplicate
              </Button>
            )}
            {selectedOutfit && (
              <Button
                onClick={() => startGeneration(selectedOutfit.id, { pose: 'front', lighting: 'studio' })}
                disabled={isGenerating || isManaging}
              >
                {isGenerating ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Generating...
                  </>
                ) : (
                  <>
                    <Sparkles className="h-4 w-4 mr-2" />
                    Generate AI Image
                  </>
                )}
              </Button>
            )}
            {selectedOutfit && (
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
                Delete
              </Button>
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
