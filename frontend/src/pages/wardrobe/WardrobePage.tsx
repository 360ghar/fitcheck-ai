/**
 * Wardrobe Page
 *
 * View and manage all items in the wardrobe.
 *
 * Features:
 * - Grid/list view toggle
 * - Advanced filtering and search
 * - Item selection for batch operations
 * - Add new items with AI extraction
 * - View item details
 * - Mark items as worn
 * - Toggle favorites
 *
 * @see https://docs.fitcheck.ai/features/wardrobe
 */

import { useEffect, useState, useCallback } from 'react'
import { useParams, useSearchParams } from 'react-router-dom'
import { useWardrobeStore } from '../../stores/wardrobeStore'
import {
  Shirt,
  Plus,
  Heart,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { FilterPanel, type ItemFilters, type SortOptions } from '@/components/wardrobe/FilterPanel'
import { ItemUpload } from '@/components/wardrobe/ItemUpload'
import { ItemDetailModal } from '@/components/wardrobe/ItemDetailModal'
import { useToast } from '@/components/ui/use-toast'
import { toggleItemFavorite as apiToggleFavorite, markItemAsWorn as apiMarkAsWorn, deleteItem as apiDeleteItem } from '@/api/items'
import type { Item } from '@/types'

export default function WardrobePage() {
  const { id } = useParams()
  const [searchParams] = useSearchParams()

  // Store state
  const filteredItems = useWardrobeStore((state) => state.filteredItems)
  const isLoading = useWardrobeStore((state) => state.isLoading)
  const error = useWardrobeStore((state) => state.error)

  // Store actions
  const fetchItems = useWardrobeStore((state) => state.fetchItems)
  const toggleItemFavorite = useWardrobeStore((state) => state.toggleItemFavorite)

  // Local state
  const [isUploadModalOpen, setIsUploadModalOpen] = useState(false)
  const [selectedItemDetail, setSelectedItemDetail] = useState<Item | null>(null)
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false)

  // Filters and sort
  const [filters, setFilters] = useState<ItemFilters>({
    search: '',
    category: 'all',
    color: '',
    condition: 'all',
    isFavorite: false,
  })

  const [sort, setSort] = useState<SortOptions>({
    sortBy: 'date_added',
    sortOrder: 'desc',
    isGridView: true,
  })

  const { toast } = useToast()

  // ============================================================================
  // EFFECTS
  // ============================================================================

  useEffect(() => {
    const action = searchParams.get('action')
    if (action === 'add') {
      setIsUploadModalOpen(true)
    }
    fetchItems(true)
  }, [fetchItems, searchParams])

  useEffect(() => {
    if (id) {
      // Load single item details if id is present
      const item = filteredItems.find((i) => i.id === id)
      if (item) {
        setSelectedItemDetail(item)
        setIsDetailModalOpen(true)
      }
    }
  }, [id, filteredItems])

  // ============================================================================
  // HANDLERS
  // ============================================================================

  const handleFilterChange = useCallback((key: keyof ItemFilters, value: any) => {
    setFilters((prev) => ({ ...prev, [key]: value }))
    // Update store filters
    useWardrobeStore.getState().setFilter(key, value)
  }, [])

  const handleSortChange = useCallback((key: keyof SortOptions, value: any) => {
    setSort((prev) => ({ ...prev, [key]: value }))
    // Update store sort
    if (key === 'sortBy') {
      useWardrobeStore.getState().setSortBy(value)
    } else if (key === 'sortOrder') {
      useWardrobeStore.getState().setSortOrder(value)
    } else if (key === 'isGridView') {
      useWardrobeStore.getState().setGridView(value)
    }
  }, [])

  const handleResetFilters = useCallback(() => {
    setFilters({
      search: '',
      category: 'all',
      color: '',
      condition: 'all',
      isFavorite: false,
    })
    useWardrobeStore.getState().resetFilters()
  }, [])

  const handleItemClick = (item: Item) => {
    setSelectedItemDetail(item)
    setIsDetailModalOpen(true)
  }

  const handleToggleFavorite = async (itemId: string) => {
    try {
      const updated = await apiToggleFavorite(itemId)
      toggleItemFavorite(itemId)
      toast({
        title: updated.is_favorite ? 'Added to favorites' : 'Removed from favorites',
      })
      // Update local detail modal state if open
      if (selectedItemDetail?.id === itemId) {
        setSelectedItemDetail({ ...selectedItemDetail, is_favorite: updated.is_favorite })
      }
    } catch (err) {
      toast({
        title: 'Error',
        description: 'Failed to update favorite status',
        variant: 'destructive',
      })
    }
  }

  const handleMarkAsWorn = async (itemId: string) => {
    try {
      await apiMarkAsWorn(itemId)
      toast({
        title: 'Marked as worn',
        description: 'Item has been added to your wear history',
      })
      setIsDetailModalOpen(false)
      fetchItems(true)
    } catch (err) {
      toast({
        title: 'Error',
        description: 'Failed to mark item as worn',
        variant: 'destructive',
      })
    }
  }

  const handleDeleteItem = async (itemId: string) => {
    if (!confirm('Are you sure you want to delete this item?')) return

    try {
      await apiDeleteItem(itemId)
      toast({
        title: 'Item deleted',
        description: 'The item has been removed from your wardrobe',
      })
      setIsDetailModalOpen(false)
      fetchItems(true)
    } catch (err) {
      toast({
        title: 'Error',
        description: 'Failed to delete item',
        variant: 'destructive',
      })
    }
  }

  const handleEditItem = () => {
    toast({
      title: 'Item updated',
      description: 'Your changes have been saved',
    })
    setIsDetailModalOpen(false)
    fetchItems(true)
  }

  const handleUploadComplete = (results: any[]) => {
    const successCount = results.filter((r) => r.success).length
    const failCount = results.filter((r) => !r.success).length

    if (successCount > 0) {
      toast({
        title: 'Items added',
        description: `${successCount} item${successCount > 1 ? 's have' : ' has'} been added to your wardrobe`,
      })
      fetchItems(true)
    }

    if (failCount > 0) {
      toast({
        title: 'Some items failed',
        description: `${failCount} item${failCount > 1 ? 's' : ''} could not be added`,
        variant: 'destructive',
      })
    }

    setIsUploadModalOpen(false)
  }

  // ============================================================================
  // RENDER
  // ============================================================================

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 md:py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-4 md:mb-6">
        <div>
          <h1 className="text-xl md:text-2xl font-bold text-foreground">Wardrobe</h1>
          <p className="text-sm text-muted-foreground">
            {filteredItems.length} {filteredItems.length === 1 ? 'item' : 'items'}
          </p>
        </div>
        <Button onClick={() => setIsUploadModalOpen(true)} className="hidden md:flex">
          <Plus className="h-4 w-4 mr-2" />
          Add Item
        </Button>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-destructive/10 border border-destructive/20 rounded-md text-sm text-destructive">
          {error.message}
        </div>
      )}

      {/* Filters */}
      <FilterPanel
        filters={filters}
        sort={sort}
        onFilterChange={handleFilterChange}
        onSortChange={handleSortChange}
        onResetFilters={handleResetFilters}
      />

      {/* Items grid/list */}
      {isLoading ? (
        <div className="text-center py-12">
          <div className="inline-block animate-spin rounded-full h-10 w-10 md:h-12 md:w-12 border-b-2 border-primary"></div>
          <p className="mt-4 text-muted-foreground">Loading items...</p>
        </div>
      ) : filteredItems.length === 0 ? (
        <div className="text-center py-12 bg-card rounded-lg shadow">
          <Shirt className="mx-auto h-12 w-12 md:h-16 md:w-16 text-muted-foreground" />
          <h3 className="mt-4 text-lg font-medium text-foreground">No items found</h3>
          <p className="mt-2 text-sm text-muted-foreground">
            {filters.search || filters.category !== 'all' || filters.condition !== 'all'
              ? 'Try adjusting your filters or search query'
              : 'Add your first item to get started'}
          </p>
          <Button className="mt-6" onClick={() => setIsUploadModalOpen(true)}>
            <Plus className="h-4 w-4 mr-2" />
            Add First Item
          </Button>
        </div>
      ) : (
        <div
          className={`grid gap-3 md:gap-4 ${
            sort.isGridView
              ? 'grid-cols-2 xs:grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5'
              : 'grid-cols-1'
          }`}
        >
          {filteredItems.map((item) => (
            <ItemCard
              key={item.id}
              item={item}
              onClick={() => handleItemClick(item)}
              onToggleFavorite={(e) => {
                e.stopPropagation()
                handleToggleFavorite(item.id)
              }}
            />
          ))}
        </div>
      )}

      {/* Floating Action Button for mobile */}
      <button
        onClick={() => setIsUploadModalOpen(true)}
        className="fixed bottom-[calc(var(--bottom-nav-height)+16px+var(--safe-area-bottom))] right-4 w-14 h-14 rounded-full bg-primary text-primary-foreground shadow-lg flex items-center justify-center md:hidden z-40 hover:bg-primary/90 active:scale-95 transition-transform"
        aria-label="Add new item"
      >
        <Plus className="h-6 w-6" />
      </button>

      {/* Modals */}
      <ItemUpload
        isOpen={isUploadModalOpen}
        onClose={() => setIsUploadModalOpen(false)}
        onUploadComplete={handleUploadComplete}
      />

      <ItemDetailModal
        item={selectedItemDetail}
        isOpen={isDetailModalOpen}
        onClose={() => setIsDetailModalOpen(false)}
        onEdit={handleEditItem}
        onDelete={handleDeleteItem}
        onToggleFavorite={handleToggleFavorite}
        onMarkAsWorn={handleMarkAsWorn}
      />
    </div>
  )
}

// ============================================================================
// ITEM CARD COMPONENT
// ============================================================================

interface ItemCardProps {
  item: Item
  onClick: () => void
  onToggleFavorite: (e: React.MouseEvent) => void
}

function ItemCard({ item, onClick, onToggleFavorite }: ItemCardProps) {
  const selectedItems = useWardrobeStore((state) => state.selectedItems)
  const toggleItemSelected = useWardrobeStore((state) => state.toggleItemSelected)

  const isSelected = selectedItems.has(item.id)

  const getConditionBadgeClass = (condition: string) => {
    switch (condition) {
      case 'clean':
        return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
      case 'dirty':
        return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'
      case 'laundry':
        return 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400'
      case 'repair':
        return 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'
      case 'donate':
        return 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400'
      default:
        return 'bg-muted text-muted-foreground'
    }
  }

  return (
    <div
      className="bg-card rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer relative group"
      onClick={onClick}
    >
      {/* Checkbox for selection */}
      <div
        className={`absolute top-2 left-2 z-10 w-6 h-6 md:w-5 md:h-5 rounded border-2 ${
          isSelected
            ? 'bg-primary border-primary'
            : 'bg-card border-border'
        } flex items-center justify-center touch-target`}
        onClick={(e) => {
          e.stopPropagation()
          toggleItemSelected(item.id)
        }}
      >
        {isSelected && (
          <div className="w-2.5 h-2.5 md:w-2 md:h-2 bg-primary-foreground rounded-sm" />
        )}
      </div>

      {/* Favorite button - larger touch target */}
      <button
        className={`absolute top-2 right-2 z-10 p-2.5 md:p-2 rounded-full touch-target flex items-center justify-center ${
          item.is_favorite
            ? 'bg-pink-100 dark:bg-pink-900/30 text-pink-600 dark:text-pink-400'
            : 'bg-card/80 backdrop-blur-sm text-muted-foreground hover:text-pink-500 dark:hover:text-pink-400'
        }`}
        onClick={onToggleFavorite}
        aria-label={item.is_favorite ? 'Remove from favorites' : 'Add to favorites'}
      >
        <Heart
          className={`h-4 w-4 ${item.is_favorite ? 'fill-current' : ''}`}
        />
      </button>

      {/* Item image */}
      <div className="aspect-square rounded-t-lg overflow-hidden bg-muted">
        {item.images.length > 0 ? (
          <img
            src={item.images[0].thumbnail_url || item.images[0].image_url}
            alt={item.name}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform"
            loading="lazy"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <Shirt className="h-12 w-12 md:h-16 md:w-16 text-muted-foreground/50" />
          </div>
        )}
      </div>

      {/* Item info */}
      <div className="p-2.5 md:p-3">
        <h3 className="font-medium text-sm md:text-base text-foreground truncate">{item.name}</h3>
        <p className="text-xs md:text-sm text-muted-foreground capitalize">{item.category}</p>
        {item.brand && (
          <p className="text-xs text-muted-foreground/70 mt-0.5 md:mt-1 truncate">{item.brand}</p>
        )}
        {item.usage_times_worn > 0 && (
          <p className="text-xs text-muted-foreground/70 mt-0.5 md:mt-1">
            Worn {item.usage_times_worn} {item.usage_times_worn === 1 ? 'time' : 'times'}
          </p>
        )}
      </div>

      {/* Condition indicator */}
      <div
        className={`absolute bottom-14 md:bottom-16 left-2 px-2 py-0.5 rounded-full text-xs font-medium ${getConditionBadgeClass(item.condition)}`}
      >
        {item.condition}
      </div>
    </div>
  )
}
