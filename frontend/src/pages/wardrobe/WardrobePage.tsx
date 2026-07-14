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
  Trash2,
  X,
  RefreshCw,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
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
import { Skeleton } from '@/components/ui/skeleton'
import { FilterPanel, type ItemFilters, type SortOptions } from '@/components/wardrobe/FilterPanel'
import { ItemUpload } from '@/components/wardrobe/ItemUpload'
import { ItemDetailModal } from '@/components/wardrobe/ItemDetailModal'
import { ItemCard } from '@/components/wardrobe/ItemCard'
import { useToast } from '@/components/ui/use-toast'
import {
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
  // Subscribe so multi-select checkboxes re-render when selection changes
  const selectedItems = useWardrobeStore((state) => state.selectedItems)

  // Store actions
  const fetchItems = useWardrobeStore((state) => state.fetchItems)
  const fetchItemById = useWardrobeStore((state) => state.fetchItemById)
  const toggleItemFavorite = useWardrobeStore((state) => state.toggleItemFavorite)
  const setFilter = useWardrobeStore((state) => state.setFilter)
  const toggleItemSelected = useWardrobeStore((state) => state.toggleItemSelected)
  const clearSelectedItems = useWardrobeStore((state) => state.clearSelectedItems)
  const deleteSelectedItems = useWardrobeStore((state) => state.deleteSelectedItems)
  const clearError = useWardrobeStore((state) => state.clearError)

  // Local state
  const [isUploadModalOpen, setIsUploadModalOpen] = useState(false)
  const [selectedItemDetail, setSelectedItemDetail] = useState<Item | null>(null)
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false)
  const [favoritingIds, setFavoritingIds] = useState<Set<string>>(new Set())
  const [itemPendingDelete, setItemPendingDelete] = useState<Item | null>(null)
  const [isBulkDeleteOpen, setIsBulkDeleteOpen] = useState(false)
  const [isDeleting, setIsDeleting] = useState(false)

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

    // Dashboard Favorites card links to /wardrobe?favorites=true.
    // Always sync from the URL so leaving favorites mode re-fetches the full list
    // (server-side is_favorite filter otherwise leaves items stuck as favorites-only).
    const favoritesOnly = searchParams.get('favorites') === 'true'
    setFilters((prev) => ({ ...prev, isFavorite: favoritesOnly }))
    setFilter('isFavorite', favoritesOnly)

    fetchItems(true)
  }, [fetchItems, searchParams, setFilter])

  useEffect(() => {
    if (!id) return

    // Prefer already-loaded list data, then fetch by id for deep links
    const item = filteredItems.find((i) => i.id === id)
    if (item) {
      setSelectedItemDetail(item)
      setIsDetailModalOpen(true)
      return
    }

    let cancelled = false
    fetchItemById(id)
      .then(() => {
        if (cancelled) return
        const loaded = useWardrobeStore.getState().selectedItem
        if (loaded?.id === id) {
          setSelectedItemDetail(loaded)
          setIsDetailModalOpen(true)
        }
      })
      .catch(() => {
        // Store sets error; leave modal closed
      })

    return () => {
      cancelled = true
    }
  }, [id, filteredItems, fetchItemById])

  // ============================================================================
  // HANDLERS
  // ============================================================================

  const handleFilterChange = useCallback((key: keyof ItemFilters, value: any) => {
    setFilters((prev) => ({ ...prev, [key]: value }))
    // Update store filters
    useWardrobeStore.getState().setFilter(key, value)
    // Favorites uses server-side is_favorite and can leave `items` as a subset;
    // re-fetch when it flips so "all items" is restored when cleared.
    if (key === 'isFavorite') {
      void useWardrobeStore.getState().fetchItems(true)
    }
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
    void useWardrobeStore.getState().fetchItems(true)
  }, [])

  const handleItemClick = (item: Item) => {
    setSelectedItemDetail(item)
    setIsDetailModalOpen(true)
  }

  const handleToggleFavorite = async (itemId: string) => {
    if (favoritingIds.has(itemId)) return
    setFavoritingIds((prev) => new Set(prev).add(itemId))
    try {
      // Single store path → single API call (avoids double-toggle race)
      const updated = await toggleItemFavorite(itemId)
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
    } finally {
      setFavoritingIds((prev) => {
        const next = new Set(prev)
        next.delete(itemId)
        return next
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

  const handleDeleteItem = (itemId: string) => {
    const item =
      selectedItemDetail?.id === itemId
        ? selectedItemDetail
        : filteredItems.find((i) => i.id === itemId) || null
    setItemPendingDelete(item ?? { id: itemId, name: 'this item' } as Item)
  }

  const confirmDeleteItem = async () => {
    if (!itemPendingDelete) return
    setIsDeleting(true)
    try {
      await apiDeleteItem(itemPendingDelete.id)
      toast({
        title: 'Item deleted',
        description: 'The item has been removed from your wardrobe',
      })
      setIsDetailModalOpen(false)
      setItemPendingDelete(null)
      fetchItems(true)
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to delete item',
        variant: 'destructive',
      })
    } finally {
      setIsDeleting(false)
    }
  }

  const confirmBulkDelete = async () => {
    const count = selectedItems.size
    if (count === 0) return
    setIsDeleting(true)
    try {
      await deleteSelectedItems()
      toast({
        title: 'Items deleted',
        description: `${count} item${count === 1 ? '' : 's'} removed from your wardrobe`,
      })
      setIsBulkDeleteOpen(false)
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to delete selected items',
        variant: 'destructive',
      })
    } finally {
      setIsDeleting(false)
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
      // Keep modal open so user can review; edit mode exits via modal on success
      fetchItems(true)
    } catch (err) {
      toast({
        title: 'Error',
        description: 'Failed to save item changes',
        variant: 'destructive',
      })
      throw err
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
        <div className="mb-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 p-3 bg-destructive/10 border border-destructive/20 rounded-md text-sm text-destructive">
          <span>{error.message}</span>
          <Button
            variant="outline"
            size="sm"
            className="shrink-0 border-destructive/30 text-destructive hover:bg-destructive/10"
            onClick={() => {
              clearError()
              void fetchItems(true)
            }}
          >
            <RefreshCw className="h-3.5 w-3.5 mr-1.5" />
            Try again
          </Button>
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

      {/* Bulk selection bar */}
      {selectedItems.size > 0 && (
        <div
          className="sticky top-2 z-30 mb-4 flex flex-wrap items-center justify-between gap-3 rounded-xl border border-border bg-card/95 backdrop-blur-sm px-3 py-2.5 shadow-sm md:top-4"
          role="toolbar"
          aria-label="Selected items actions"
        >
          <div className="flex items-center gap-2 text-sm font-medium text-foreground">
            <span className="inline-flex h-7 min-w-7 items-center justify-center rounded-full bg-primary px-2 text-xs text-primary-foreground">
              {selectedItems.size}
            </span>
            selected
          </div>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="sm" onClick={() => clearSelectedItems()}>
              <X className="h-4 w-4 mr-1.5" />
              Clear
            </Button>
            <Button
              variant="destructive"
              size="sm"
              onClick={() => setIsBulkDeleteOpen(true)}
            >
              <Trash2 className="h-4 w-4 mr-1.5" />
              Delete
            </Button>
          </div>
        </div>
      )}

      {/* Items grid/list */}
      {isLoading ? (
        <div
          className={`grid gap-3 md:gap-4 ${
            sort.isGridView
              ? 'grid-cols-2 gap-2 xs:gap-3 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5'
              : 'grid-cols-1'
          }`}
        >
          {Array.from({ length: 8 }).map((_, i) => (
            <Skeleton
              key={i}
              className={sort.isGridView ? 'aspect-[3/4] w-full rounded-xl' : 'h-20 w-full rounded-xl'}
            />
          ))}
        </div>
      ) : filteredItems.length === 0 ? (
        <div className="text-center py-12 bg-card rounded-lg shadow">
          <Shirt className="mx-auto h-12 w-12 md:h-16 md:w-16 text-muted-foreground" />
          <h3 className="mt-4 text-lg font-medium text-foreground">No items found</h3>
          <p className="mt-2 text-sm text-muted-foreground">
            {filters.search || filters.category !== 'all' || filters.condition !== 'all' || filters.occasion || filters.isFavorite
              ? 'Try adjusting your filters or search query'
              : 'Add your first item to get started'}
          </p>
          {filters.search || filters.category !== 'all' || filters.condition !== 'all' || filters.occasion || filters.isFavorite ? (
            <Button className="mt-6" variant="outline" onClick={handleResetFilters}>
              Clear filters
            </Button>
          ) : (
            <Button className="mt-6" onClick={() => setIsUploadModalOpen(true)}>
              <Plus className="h-4 w-4 mr-2" />
              Add First Item
            </Button>
          )}
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
            const isSelected = selectedItems.has(item.id)
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
                  toggleItemSelected(item.id)
                }}
              />
            )
          })}
        </div>
      )}

      {/* Mobile primary add action is the BottomNav center FAB — avoid dual FABs */}

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

      {/* Single item delete confirmation */}
      <AlertDialog
        open={!!itemPendingDelete}
        onOpenChange={(open) => {
          if (!open && !isDeleting) setItemPendingDelete(null)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete item?</AlertDialogTitle>
            <AlertDialogDescription>
              {itemPendingDelete
                ? `"${itemPendingDelete.name}" will be permanently removed from your wardrobe. This cannot be undone.`
                : 'This item will be permanently removed from your wardrobe.'}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isDeleting}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              disabled={isDeleting}
              onClick={(e) => {
                e.preventDefault()
                void confirmDeleteItem()
              }}
            >
              {isDeleting ? 'Deleting…' : 'Delete'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Bulk delete confirmation */}
      <AlertDialog
        open={isBulkDeleteOpen}
        onOpenChange={(open) => {
          if (!isDeleting) setIsBulkDeleteOpen(open)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>
              Delete {selectedItems.size} item{selectedItems.size === 1 ? '' : 's'}?
            </AlertDialogTitle>
            <AlertDialogDescription>
              Selected items will be permanently removed from your wardrobe. This cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isDeleting}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              disabled={isDeleting}
              onClick={(e) => {
                e.preventDefault()
                void confirmBulkDelete()
              }}
            >
              {isDeleting ? 'Deleting…' : 'Delete'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
