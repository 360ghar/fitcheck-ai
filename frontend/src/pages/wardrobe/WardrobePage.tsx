/**
 * Wardrobe Page
 *
 * Browse and manage all items in the closet.
 *
 * The detail surface is an in-window split pane at `md`+ (never a modal over the
 * list), and the URL — `/wardrobe/:id` — is the single source of truth for what is
 * selected. Selection deliberately lives in the PATH, not the query string: the
 * effect below keyed on `searchParams` refetches the whole closet, so a
 * query-param selection would re-fetch on every card click.
 *
 * @see https://docs.fitcheck.ai/features/wardrobe
 */

import { useEffect, useState, useCallback, useMemo, useRef } from 'react'
import { useParams, useSearchParams, useNavigate, useLocation } from 'react-router-dom'
import { useClosetStore } from '../../stores/wardrobeStore'
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
import { LoadingGrid } from '@/components/ui/loading-grid'
import { FilterPanel, type ItemFilters, type SortOptions } from '@/components/wardrobe/FilterPanel'
import { BatchExtractionFlow, type ItemUploadResult } from '@/components/wardrobe/BatchExtractionFlow'
import { ItemDetailPanel } from '@/components/wardrobe/ItemDetailPanel'
import { ItemDetailActions } from '@/components/wardrobe/ItemDetailActions'
import { useItemEditor } from '@/components/wardrobe/useItemEditor'
import { ItemCard } from '@/components/wardrobe/ItemCard'
import { MasterDetailLayout } from '@/components/layout/MasterDetailLayout'
import { useToast } from '@/components/ui/use-toast'
import type { BatchJobUiStatus, Category, Item } from '@/types'
import { useJobUiStore } from '@/stores/jobUiStore'
import { useIsSplitViewport, useIsWideViewport } from '@/hooks/useMediaQuery'
import { EmptyState } from '@/components/ui/empty-state'
import { FilterChip } from '@/components/ui/filter-chip'
import { PinGrid } from '@/components/wardrobe/pin-grid'

// Quick category filter chips (Alta-style), mirror the FilterPanel categories.
const CATEGORY_CHIPS: { value: Category | 'all'; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'tops', label: 'Tops' },
  { value: 'bottoms', label: 'Bottoms' },
  { value: 'shoes', label: 'Shoes' },
  { value: 'outerwear', label: 'Outerwear' },
  { value: 'accessories', label: 'Accessories' },
  { value: 'activewear', label: 'Activewear' },
  { value: 'swimwear', label: 'Swimwear' },
  { value: 'other', label: 'Other' },
]

const LIST_PATH = '/wardrobe'
// With the pane taking its share of a 1280px cap, the masonry gives up columns
// rather than the page giving up width (DESIGN.md 05).
const SPLIT_COLUMNS = 'lg:columns-2 xl:columns-3 2xl:columns-4'

export default function WardrobePage() {
  const { id } = useParams()
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const location = useLocation()

  // Store state
  const items = useClosetStore((state) => state.items)
  const filteredItems = useClosetStore((state) => state.filteredItems)
  const isLoading = useClosetStore((state) => state.isLoading)
  const isDetailLoading = useClosetStore((state) => state.isDetailLoading)
  const error = useClosetStore((state) => state.error)
  // Subscribe so multi-select checkboxes re-render when selection changes
  const selectedItems = useClosetStore((state) => state.selectedItems)
  const storeSelectedItem = useClosetStore((state) => state.selectedItem)

  // Store actions
  const fetchItems = useClosetStore((state) => state.fetchItems)
  const fetchItemById = useClosetStore((state) => state.fetchItemById)
  const toggleItemFavorite = useClosetStore((state) => state.toggleItemFavorite)
  const updateItem = useClosetStore((state) => state.updateItem)
  const markItemAsWorn = useClosetStore((state) => state.markItemAsWorn)
  const deleteItem = useClosetStore((state) => state.deleteItem)
  const setFilter = useClosetStore((state) => state.setFilter)
  const setSelectedItem = useClosetStore((state) => state.setSelectedItem)
  const toggleItemSelected = useClosetStore((state) => state.toggleItemSelected)
  const clearSelectedItems = useClosetStore((state) => state.clearSelectedItems)
  const deleteSelectedItems = useClosetStore((state) => state.deleteSelectedItems)
  const clearError = useClosetStore((state) => state.clearError)

  // Local state
  const [isUploadModalOpen, setIsUploadModalOpen] = useState(false)
  const setJob = useJobUiStore((s) => s.setJob)
  const clearJob = useJobUiStore((s) => s.clearJob)
  const lastBatchStatusRef = useRef<BatchJobUiStatus | null>(null)
  const favoritingIdsRef = useRef<Set<string>>(new Set())
  const [itemPendingDelete, setItemPendingDelete] = useState<Item | null>(null)
  const [isBulkDeleteOpen, setIsBulkDeleteOpen] = useState(false)
  const [isDeleting, setIsDeleting] = useState(false)
  const [isManaging, setIsManaging] = useState(false)

  // Filters and sort
  const [filters, setFilters] = useState<ItemFilters>({
    search: '',
    category: 'all',
    color: '',
    occasion: '',
    condition: 'all',
    isFavorite: false,
  })
  const hasActiveFilters = Boolean(
    filters.search ||
      filters.category !== 'all' ||
      filters.condition !== 'all' ||
      filters.occasion ||
      filters.isFavorite
  )

  const [sort, setSort] = useState<SortOptions>({
    sortBy: 'date_added',
    sortOrder: 'desc',
    isGridView: true,
  })

  const { toast } = useToast()

  const publishedBatchJobIdRef = useRef<string | null>(null)

  const publishBatchJob = useCallback(
    (status: BatchJobUiStatus | null, dialogOpen: boolean) => {
      lastBatchStatusRef.current = status
      if (!status) {
        if (publishedBatchJobIdRef.current) {
          clearJob(publishedBatchJobIdRef.current)
          publishedBatchJobIdRef.current = null
        }
        return
      }
      const jobId = status.jobId || 'batch-upload'
      // AppLayout JobPill is global — hide while this dialog owns the UI.
      if (dialogOpen) {
        clearJob(jobId)
        // Keep published id so we can restore when dialog closes
        publishedBatchJobIdRef.current = jobId
        return
      }
      publishedBatchJobIdRef.current = jobId
      setJob({
        id: jobId,
        label: status.label,
        isActive: status.isProcessing || status.isGenerationRunning,
        etaSeconds: status.generationEtaSeconds,
        href: '/wardrobe?action=add',
        onOpen: () => setIsUploadModalOpen(true),
      })
    },
    [clearJob, setJob]
  )

  // ============================================================================
  // SELECTION (URL is the source of truth)
  // ============================================================================

  const selectedId = id || null

  // Resolve from `items` (not `filteredItems`) so a selection that the current
  // filters exclude still resolves; the store's `selectedItem` is the fallback for
  // a deep link that is not in the list yet.
  const selectedItemDetail: Item | null = useMemo(() => {
    if (!selectedId) return null
    return (
      items.find((i) => i.id === selectedId) ||
      (storeSelectedItem?.id === selectedId ? storeSelectedItem : null)
    )
  }, [selectedId, items, storeSelectedItem])

  useEffect(() => {
    if (selectedId) {
      if (selectedItemDetail && storeSelectedItem?.id !== selectedItemDetail.id) {
        setSelectedItem(selectedItemDetail)
      }
    } else if (storeSelectedItem) {
      setSelectedItem(null)
    }
  }, [selectedId, selectedItemDetail, storeSelectedItem, setSelectedItem])

  const isDetailOpen = Boolean(selectedId)
  const hasItemInStore = useClosetStore((state) =>
    selectedId ? state.items.some((i) => i.id === selectedId) : false
  )

  // ============================================================================
  // EFFECTS
  // ============================================================================

  useEffect(() => {
    publishBatchJob(lastBatchStatusRef.current, isUploadModalOpen)
  }, [isUploadModalOpen, publishBatchJob])

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

  // Deep link only. Deps are the id and a boolean — NOT `filteredItems`, whose
  // identity changes on every fetch, which made this re-run constantly.
  useEffect(() => {
    if (!selectedId || hasItemInStore) return
    fetchItemById(selectedId).catch(() => {
      // Store records the error; the pane shows its own unavailable line.
    })
  }, [selectedId, hasItemInStore, fetchItemById])

  // ============================================================================
  // HANDLERS
  // ============================================================================

  const handleFilterChange = useCallback(<K extends keyof ItemFilters>(key: K, value: ItemFilters[K]) => {
    setFilters((prev) => ({ ...prev, [key]: value }))
    // Update store filters
    useClosetStore.getState().setFilter(key, value)
    // Favorites uses server-side is_favorite and can leave `items` as a subset;
    // re-fetch when it flips so "all items" is restored when cleared.
    if (key === 'isFavorite') {
      void useClosetStore.getState().fetchItems(true)
    }
  }, [])

  const handleSortChange = useCallback(<K extends keyof SortOptions>(key: K, value: SortOptions[K]) => {
    setSort((prev) => ({ ...prev, [key]: value }))
    // Update store sort
    // The key comparison guarantees each value type; TS cannot narrow a
    // generic parameter from it, hence the assertions.
    if (key === 'sortBy') {
      useClosetStore.getState().setSortBy(value as SortOptions['sortBy'])
    } else if (key === 'sortOrder') {
      useClosetStore.getState().setSortOrder(value as SortOptions['sortOrder'])
    } else if (key === 'isGridView') {
      useClosetStore.getState().setGridView(value as SortOptions['isGridView'])
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
    useClosetStore.getState().resetFilters()
    void useClosetStore.getState().fetchItems(true)
  }, [])

  const handleCardClick = (item: Item) => {
    // Deliberate behaviour change: while a bulk selection is live, a card-body tap
    // extends that selection instead of opening the pane. A bulk operation and a
    // detail pane otherwise fight for the same screen.
    if (selectedItems.size > 0) {
      toggleItemSelected(item.id)
      return
    }
    navigate({ pathname: `${LIST_PATH}/${item.id}`, search: location.search })
  }

  const closeDetail = () => {
    // Pushed, not replaced, so Back walks the selection — and the id is genuinely
    // cleared, which is the fix for "the same card cannot be reopened".
    navigate({ pathname: LIST_PATH, search: location.search })
  }

  const handleToggleFavorite = async (itemId: string) => {
    if (favoritingIdsRef.current.has(itemId)) return
    favoritingIdsRef.current.add(itemId)
    try {
      // Single store path → single API call (avoids double-toggle race).
      // The store patches items/filteredItems/selectedItem, so the pane follows.
      const updated = await toggleItemFavorite(itemId)
      toast({
        title: updated.is_favorite ? 'Added to favorites' : 'Removed from favorites',
      })
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      favoritingIdsRef.current.delete(itemId)
    }
  }

  const handleMarkAsWorn = async (itemId: string) => {
    setIsManaging(true)
    try {
      await markItemAsWorn(itemId)
      toast({
        title: 'Marked as worn',
        description: 'Added to your wear history',
      })
      // The pane stays open: the wear ledger it shows is exactly what changed.
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      setIsManaging(false)
    }
  }

  const handleDeleteItem = (itemId: string) => {
    const item =
      selectedItemDetail?.id === itemId
        ? selectedItemDetail
        : items.find((i) => i.id === itemId) || null
    setItemPendingDelete(item ?? ({ id: itemId, name: 'this item' } as Item))
  }

  const confirmDeleteItem = async () => {
    if (!itemPendingDelete) return
    const deletedId = itemPendingDelete.id
    setIsDeleting(true)
    try {
      // Store action patches every collection in place — no refetch, so the list
      // beside the pane does not blink.
      await deleteItem(deletedId)
      toast({
        title: 'Item deleted',
        description: 'The item has been removed from your closet',
      })
      setItemPendingDelete(null)
      if (selectedId === deletedId) {
        // replace, so Back cannot land on a deleted id.
        navigate({ pathname: LIST_PATH, search: location.search }, { replace: true })
      }
    } catch {
      // api/client interceptor already toasts the failure.
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
        description: `${count} item${count === 1 ? '' : 's'} removed from your closet`,
      })
      setIsBulkDeleteOpen(false)
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      setIsDeleting(false)
    }
  }

  // Rejects on failure so the inline edit form can stay open for a retry.
  // The api/client interceptor already toasts, so no catch here.
  const handleEditItem = useCallback(
    async (updatedItem: Item) => {
      await updateItem(updatedItem.id, {
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
      })
      toast({
        title: 'Item updated',
        description: 'Your changes have been saved',
      })
    },
    [updateItem, toast]
  )

  const editor = useItemEditor(selectedItemDetail, handleEditItem)

  const handleUploadComplete = (results: ItemUploadResult[]) => {
    const successCount = results.filter((r) => r.success).length
    const failCount = results.filter((r) => !r.success).length

    if (successCount > 0) {
      toast({
        title: 'Items added',
        description: `${successCount} item${successCount > 1 ? 's have' : ' has'} been added to your closet`,
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

    if (publishedBatchJobIdRef.current) {
      clearJob(publishedBatchJobIdRef.current)
      publishedBatchJobIdRef.current = null
    }
    lastBatchStatusRef.current = null
    setIsUploadModalOpen(false)
  }

  // ============================================================================
  // RENDER
  // ============================================================================

  const isSplitViewport = useIsSplitViewport()
  const isWideViewport = useIsWideViewport()
  // At exactly `md` the sidebar is expanded and a 44% pane leaves ~270px of list —
  // one cramped masonry column. Compact rows read better in that band.
  const forceListRows = isDetailOpen && isSplitViewport && !isWideViewport
  const showMasonry = sort.isGridView && !forceListRows

  const selectionHiddenByFilters =
    isDetailOpen &&
    Boolean(selectedItemDetail) &&
    !filteredItems.some((i) => i.id === selectedId)

  const renderCard = (item: Item, variant: 'default' | 'list') => {
    const isMultiSelected = selectedItems.has(item.id)
    const isOpenInPane = item.id === selectedId
    return (
      <div key={item.id} aria-current={isOpenInPane ? 'true' : undefined}>
        <ItemCard
          item={item}
          variant={variant}
          isSelected={isMultiSelected}
          className={isOpenInPane ? 'border-ink' : undefined}
          onClick={() => handleCardClick(item)}
          onToggleFavorite={(e) => {
            e.stopPropagation()
            handleToggleFavorite(item.id)
          }}
          onSelect={(e) => {
            e.stopPropagation()
            toggleItemSelected(item.id)
          }}
        />
      </div>
    )
  }

  const listContent = isLoading ? (
    <LoadingGrid
      count={14}
      variant={showMasonry ? 'masonry' : 'list'}
      className={showMasonry && isDetailOpen ? SPLIT_COLUMNS : undefined}
    />
  ) : filteredItems.length === 0 ? (
    hasActiveFilters ? (
      <EmptyState
        icon={Shirt}
        title="No items match"
        description="Try adjusting your filters or search query"
        actionLabel="Clear filters"
        onAction={handleResetFilters}
      />
    ) : (
      <EmptyState
        icon={Shirt}
        title="Your closet is empty"
        description="Upload photos and AI finds each item, so you can build outfits the same day."
        actionLabel="Upload photos"
        onAction={() => setIsUploadModalOpen(true)}
      />
    )
  ) : showMasonry ? (
    <PinGrid className={isDetailOpen ? SPLIT_COLUMNS : undefined}>
      {filteredItems.map((item) => renderCard(item, 'default'))}
    </PinGrid>
  ) : (
    <div className="grid grid-cols-1 gap-2">
      {filteredItems.map((item) => renderCard(item, 'list'))}
    </div>
  )

  return (
    <div className="app-page max-w-7xl">
      {/* Header */}
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between mb-4 md:mb-4">
        <div>
          <h1 className="type-heading-xl text-foreground">Closet</h1>
          <p className="type-body-sm text-muted-foreground">
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

      {/* Filters, category chips and the bulk bar stay full width ABOVE the split —
          the list shrinks, the page does not change. */}
      <FilterPanel
        filters={filters}
        sort={sort}
        onFilterChange={handleFilterChange}
        onSortChange={handleSortChange}
        onResetFilters={handleResetFilters}
      />

      {/* Quick category chips — dense closet browsing (Alta-style) */}
      <div
        className="mb-4 -mx-1 flex gap-2 overflow-x-auto px-1 pb-1 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
        role="tablist"
        aria-label="Filter by category"
      >
        {CATEGORY_CHIPS.map((chip) => {
          const isActive = filters.category === chip.value
          return (
            <FilterChip
              key={chip.value}
              type="button"
              role="tab"
              aria-selected={isActive}
              onClick={() => handleFilterChange('category', chip.value)}
              active={isActive}
              className="shrink-0"
            >
              {chip.label}
            </FilterChip>
          )
        })}
      </div>

      {/* Bulk selection bar */}
      {selectedItems.size > 0 && (
        <div
          // Solid surface, not glass: at bg-card/95 the backdrop-blur was doing
          // nothing but costing a compositor layer, while still letting cards
          // ghost through the bar. A sticky toolbar should be an honest surface.
          // rounded-md (16px) per DESIGN.md 06 — rounded-xl aliases to 32px here,
          // which turned a 44px toolbar into most of a pill.
          className="sticky top-2 z-30 mb-4 flex flex-wrap items-center justify-between gap-3 rounded-md border border-border bg-card px-3 py-2.5 md:top-4"
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
            <Button variant="tertiary" size="sm" onClick={() => clearSelectedItems()}>
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

      <MasterDetailLayout
        isDetailOpen={isDetailOpen}
        onCloseDetail={closeDetail}
        detailTitle={selectedItemDetail?.name || 'Item'}
        list={listContent}
        detail={
          <ItemDetailPanel
            item={selectedItemDetail}
            isDetailLoading={isDetailLoading}
            editor={editor}
            notice={selectionHiddenByFilters ? 'Hidden by the current filters.' : null}
          />
        }
        detailFooter={
          selectedItemDetail ? (
            <ItemDetailActions
              item={selectedItemDetail}
              editor={editor}
              isBusy={isManaging}
              onMarkWorn={() => void handleMarkAsWorn(selectedItemDetail.id)}
              onToggleFavorite={() => void handleToggleFavorite(selectedItemDetail.id)}
              onDelete={() => handleDeleteItem(selectedItemDetail.id)}
            />
          ) : undefined
        }
      />

      {/* Mobile primary add action is the BottomNav center FAB — avoid dual FABs */}

      {/* Modals — destructive confirms and the upload flow only */}
      <BatchExtractionFlow
        isOpen={isUploadModalOpen}
        onClose={() => setIsUploadModalOpen(false)}
        onUploadComplete={handleUploadComplete}
        onRequestOpen={() => setIsUploadModalOpen(true)}
        onJobStatusChange={(status) => publishBatchJob(status, isUploadModalOpen)}
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
                ? `"${itemPendingDelete.name}" will be permanently removed from your closet. This cannot be undone.`
                : 'This item will be permanently removed from your closet.'}
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
              Selected items will be permanently removed from your closet. This cannot be undone.
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
