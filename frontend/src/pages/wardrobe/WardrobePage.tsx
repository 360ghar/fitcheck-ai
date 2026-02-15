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
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { FilterPanel, type ItemFilters, type SortOptions } from '@/components/wardrobe/FilterPanel'
import { ItemUpload } from '@/components/wardrobe/ItemUpload'
import { ItemDetailModal } from '@/components/wardrobe/ItemDetailModal'
import { ItemCard } from '@/components/wardrobe/ItemCard'
import { useToast } from '@/components/ui/use-toast'
import {
  toggleItemFavorite as apiToggleFavorite,
  markItemAsWorn as apiMarkAsWorn,
  deleteItem as apiDeleteItem,
  updateItem as apiUpdateItem,
} from '@/api/items'
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
    occasion: '',
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
      occasion: '',
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

  const handleEditItem = async (updatedItem: Item) => {
    try {
      const savedItem = await apiUpdateItem(updatedItem.id, {
        name: updatedItem.name,
        category: updatedItem.category,
        sub_category: updatedItem.sub_category,
        brand: updatedItem.brand,
        colors: updatedItem.colors,
        occasion_tags: updatedItem.occasion_tags,
        size: updatedItem.size,
        price: updatedItem.price,
        purchase_date: updatedItem.purchase_date,
        purchase_location: updatedItem.purchase_location,
        tags: updatedItem.tags,
        notes: updatedItem.notes,
        condition: updatedItem.condition,
        is_favorite: updatedItem.is_favorite,
      })

      toast({
        title: 'Item updated',
        description: 'Your changes have been saved',
      })
      setSelectedItemDetail(savedItem)
      setIsDetailModalOpen(false)
      fetchItems(true)
    } catch (err) {
      toast({
        title: 'Error',
        description: 'Failed to save item changes',
        variant: 'destructive',
      })
    }
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
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between mb-4 md:mb-6">
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

      <div className="md:hidden mb-4">
        <Button onClick={() => setIsUploadModalOpen(true)} className="w-full">
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
          <div className="inline-block animate-spin rounded-full h-8 w-8 md:h-12 md:w-12 border-b-2 border-primary"></div>
          <p className="mt-4 text-muted-foreground">Loading items...</p>
        </div>
      ) : filteredItems.length === 0 ? (
        <div className="text-center py-12 bg-card rounded-lg shadow">
          <Shirt className="mx-auto h-12 w-12 md:h-16 md:w-16 text-muted-foreground" />
          <h3 className="mt-4 text-lg font-medium text-foreground">No items found</h3>
          <p className="mt-2 text-sm text-muted-foreground">
            {filters.search || filters.category !== 'all' || filters.condition !== 'all' || filters.occasion
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
              ? 'grid-cols-2 gap-2 xs:gap-3 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5'
              : 'grid-cols-1'
          }`}
        >
          {filteredItems.map((item) => {
            const isSelected = useWardrobeStore.getState().selectedItems.has(item.id)
            return (
              <ItemCard
                key={item.id}
                item={item}
                variant={sort.isGridView ? 'default' : 'list'}
                isSelected={isSelected}
                onClick={() => handleItemClick(item)}
                onToggleFavorite={(e) => {
                  e.stopPropagation()
                  handleToggleFavorite(item.id)
                }}
                onSelect={(e) => {
                  e.stopPropagation()
                  useWardrobeStore.getState().toggleItemSelected(item.id)
                }}
              />
            )
          })}
        </div>
      )}

      {/* Floating Action Button for mobile */}
      <button
        onClick={() => setIsUploadModalOpen(true)}
        className="fixed bottom-[calc(var(--bottom-nav-height)+16px+var(--safe-area-bottom))] right-[calc(var(--safe-area-right)+1rem)] w-14 h-14 rounded-full bg-primary text-primary-foreground shadow-lg flex items-center justify-center md:hidden z-[90] hover:bg-primary/90 active:scale-95 transition-transform"
        aria-label="Add new item"
      >
        <Plus className="h-6 w-6" />
      </button>

      {/* Modals */}
      <ItemUpload
        isOpen={isUploadModalOpen}
        onClose={() => setIsUploadModalOpen(false)}
        onUploadComplete={handleUploadComplete}
        onRequestOpen={() => setIsUploadModalOpen(true)}
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
