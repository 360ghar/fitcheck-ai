/**
 * Outfits Page
 * View and manage created outfits
 */

import { useEffect } from 'react'
import { useParams } from 'react-router-dom'
import { useOutfitStore } from '../../stores/outfitStore'
import {
  Layers,
  Plus,
  Sparkles,
  Heart,
  Grid3x3,
  List,
  Search,
  Filter,
} from 'lucide-react'

export default function OutfitsPage() {
  const { id } = useParams()

  const filteredOutfits = useOutfitStore((state) => state.filteredOutfits)
  const isLoading = useOutfitStore((state) => state.isLoading)
  const isGridView = useOutfitStore((state) => state.isGridView)
  const isCreating = useOutfitStore((state) => state.isCreating)
  const startCreating = useOutfitStore((state) => state.startCreating)
  const cancelCreating = useOutfitStore((state) => state.cancelCreating)
  const toggleOutfitFavorite = useOutfitStore((state) => state.toggleOutfitFavorite)
  const setSelectedOutfit = useOutfitStore((state) => state.setSelectedOutfit)
  const fetchOutfits = useOutfitStore((state) => state.fetchOutfits)

  useEffect(() => {
    fetchOutfits(true)
  }, [fetchOutfits])

  // Handle single outfit view
  useEffect(() => {
    if (id) {
      // TODO: Load and display single outfit details
    }
  }, [id])

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Outfits</h1>
          <p className="text-sm text-gray-600">
            {filteredOutfits.length} {filteredOutfits.length === 1 ? 'outfit' : 'outfits'}
          </p>
        </div>
        <button
          onClick={startCreating}
          className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
        >
          <Plus className="h-4 w-4 mr-2" />
          Create Outfit
        </button>
      </div>

      {/* Outfits grid */}
      {isLoading ? (
        <div className="text-center py-12">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          <p className="mt-4 text-gray-600">Loading outfits...</p>
        </div>
      ) : filteredOutfits.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg shadow">
          <Layers className="mx-auto h-16 w-16 text-gray-400" />
          <h3 className="mt-4 text-lg font-medium text-gray-900">No outfits yet</h3>
          <p className="mt-2 text-sm text-gray-600">
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
              className="bg-white rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer relative group"
              onClick={() => setSelectedOutfit(outfit)}
            >
              {/* Favorite button */}
              <button
                className={`absolute top-3 right-3 z-10 p-1.5 rounded-full ${
                  outfit.is_favorite
                    ? 'bg-pink-100 text-pink-600'
                    : 'bg-white/80 text-gray-400 hover:text-pink-500'
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
              <div className="aspect-[4/3] rounded-t-lg overflow-hidden bg-gray-100">
                {outfit.image_url ? (
                  <img
                    src={outfit.image_url}
                    alt={outfit.name}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                  />
                ) : outfit.images.length > 0 ? (
                  <img
                    src={outfit.images[0].thumbnail_url || outfit.images[0].image_url}
                    alt={outfit.name}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center p-4">
                    <div className="grid grid-cols-3 gap-2">
                      {outfit.items.slice(0, 6).map((item, index) => (
                        <div
                          key={index}
                          className="aspect-square bg-gray-200 rounded flex items-center justify-center"
                        >
                          <Layers className="h-6 w-6 text-gray-400" />
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Outfit info */}
              <div className="p-4">
                <h3 className="font-medium text-gray-900 truncate">{outfit.name}</h3>
                {outfit.description && (
                  <p className="text-sm text-gray-600 line-clamp-2 mt-1">{outfit.description}</p>
                )}
                <div className="flex items-center justify-between mt-2">
                  <span className="text-xs text-gray-500">
                    {outfit.items.length} {outfit.items.length === 1 ? 'item' : 'items'}
                  </span>
                  {outfit.style && (
                    <span className="text-xs px-2 py-0.5 bg-indigo-100 text-indigo-700 rounded-full capitalize">
                      {outfit.style}
                    </span>
                  )}
                </div>
                {outfit.times_worn > 0 && (
                  <p className="text-xs text-gray-500 mt-2">
                    Worn {outfit.times_worn} {outfit.times_worn === 1 ? 'time' : 'times'}
                  </p>
                )}
              </div>

              {/* AI generation indicator */}
              {outfit.images.some((img) => img.generation_type === 'ai') && (
                <div className="absolute top-3 left-3 flex items-center gap-1 px-2 py-1 bg-purple-100 rounded-full">
                  <Sparkles className="h-3 w-3 text-purple-600" />
                  <span className="text-xs font-medium text-purple-700">AI</span>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
