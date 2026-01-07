/**
 * Wardrobe Page
 * View and manage all items in the wardrobe
 */

import { useEffect } from 'react'
import { useParams, useSearchParams } from 'react-router-dom'
import { useWardrobeStore } from '../../stores/wardrobeStore'
import {
  Shirt,
  Search,
  Filter,
  Grid3x3,
  List,
  Plus,
  Heart,
  SortAsc,
  SortDesc,
  X,
} from 'lucide-react'

export default function WardrobePage() {
  const { id } = useParams()
  const [searchParams] = useSearchParams()

  const filteredItems = useWardrobeStore((state) => state.filteredItems)
  const isLoading = useWardrobeStore((state) => state.isLoading)
  const isGridView = useWardrobeStore((state) => state.isGridView)
  const filters = useWardrobeStore((state) => state.filters)
  const sortBy = useWardrobeStore((state) => state.sortBy)
  const sortOrder = useWardrobeStore((state) => state.sortOrder)
  const selectedItems = useWardrobeStore((state) => state.selectedItems)
  const error = useWardrobeStore((state) => state.error)

  const fetchItems = useWardrobeStore((state) => state.fetchItems)
  const setSelectedItem = useWardrobeStore((state) => state.setSelectedItem)
  const setFilter = useWardrobeStore((state) => state.setFilter)
  const setSortBy = useWardrobeStore((state) => state.setSortBy)
  const setSortOrder = useWardrobeStore((state) => state.setSortOrder)
  const setGridView = useWardrobeStore((state) => state.setGridView)
  const resetFilters = useWardrobeStore((state) => state.resetFilters)
  const toggleItemSelected = useWardrobeStore((state) => state.toggleItemSelected)
  const toggleItemFavorite = useWardrobeStore((state) => state.toggleItemFavorite)
  const deleteItem = useWardrobeStore((state) => state.deleteItem)

  useEffect(() => {
    // Check if action=add is in URL
    const action = searchParams.get('action')
    if (action === 'add') {
      // TODO: Open add item dialog
    }
    fetchItems(true)
  }, [fetchItems, searchParams])

  // Handle single item view
  useEffect(() => {
    if (id) {
      // TODO: Load and display single item details
    }
  }, [id])

  const categories = [
    { value: 'all', label: 'All Categories' },
    { value: 'tops', label: 'Tops' },
    { value: 'bottoms', label: 'Bottoms' },
    { value: 'shoes', label: 'Shoes' },
    { value: 'accessories', label: 'Accessories' },
    { value: 'outerwear', label: 'Outerwear' },
    { value: 'swimwear', label: 'Swimwear' },
    { value: 'activewear', label: 'Activewear' },
  ]

  const conditions = [
    { value: 'all', label: 'All Conditions' },
    { value: 'clean', label: 'Clean' },
    { value: 'dirty', label: 'Dirty' },
    { value: 'laundry', label: 'In Laundry' },
    { value: 'repair', label: 'Needs Repair' },
    { value: 'donate', label: 'To Donate' },
  ]

  const sortOptions = [
    { value: 'date_added', label: 'Date Added' },
    { value: 'name', label: 'Name' },
    { value: 'category', label: 'Category' },
    { value: 'times_worn', label: 'Times Worn' },
  ]

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Wardrobe</h1>
          <p className="text-sm text-gray-600">
            {filteredItems.length} {filteredItems.length === 1 ? 'item' : 'items'}
          </p>
        </div>
        <button className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700">
          <Plus className="h-4 w-4 mr-2" />
          Add Item
        </button>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-md text-sm text-red-800">
          {error}
        </div>
      )}

      {/* Filters and search */}
      <div className="bg-white shadow rounded-lg p-4 mb-6">
        <div className="flex flex-col lg:flex-row gap-4">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search items..."
              value={filters.search}
              onChange={(e) => setFilter('search', e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
            />
          </div>

          {/* Category filter */}
          <select
            value={filters.category}
            onChange={(e) => setFilter('category', e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
          >
            {categories.map((cat) => (
              <option key={cat.value} value={cat.value}>
                {cat.label}
              </option>
            ))}
          </select>

          {/* Condition filter */}
          <select
            value={filters.condition}
            onChange={(e) => setFilter('condition', e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
          >
            {conditions.map((cond) => (
              <option key={cond.value} value={cond.value}>
                {cond.label}
              </option>
            ))}
          </select>

          {/* Sort */}
          <div className="flex items-center gap-2">
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as any)}
              className="px-4 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
            >
              {sortOptions.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
            <button
              onClick={() => setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')}
              className="p-2 border border-gray-300 rounded-md hover:bg-gray-50"
              title={sortOrder === 'asc' ? 'Ascending' : 'Descending'}
            >
              {sortOrder === 'asc' ? (
                <SortAsc className="h-5 w-5 text-gray-600" />
              ) : (
                <SortDesc className="h-5 w-5 text-gray-600" />
              )}
            </button>
          </div>

          {/* View toggle */}
          <div className="flex items-center gap-2">
            <button
              onClick={() => setGridView(true)}
              className={`p-2 rounded-md ${
                isGridView
                  ? 'bg-indigo-100 text-indigo-600'
                  : 'hover:bg-gray-100 text-gray-600'
              }`}
            >
              <Grid3x3 className="h-5 w-5" />
            </button>
            <button
              onClick={() => setGridView(false)}
              className={`p-2 rounded-md ${
                !isGridView
                  ? 'bg-indigo-100 text-indigo-600'
                  : 'hover:bg-gray-100 text-gray-600'
              }`}
            >
              <List className="h-5 w-5" />
            </button>
          </div>
        </div>

        {/* Active filters */}
        {(filters.category !== 'all' ||
          filters.condition !== 'all' ||
          filters.isFavorite) && (
          <div className="flex items-center gap-2 mt-4 pt-4 border-t border-gray-200">
            <span className="text-sm text-gray-600">Active filters:</span>
            {filters.category !== 'all' && (
              <span className="inline-flex items-center px-2 py-1 rounded-md bg-indigo-100 text-indigo-700 text-sm">
                {categories.find((c) => c.value === filters.category)?.label}
                <button
                  onClick={() => setFilter('category', 'all')}
                  className="ml-1 hover:text-indigo-900"
                >
                  <X className="h-3 w-3" />
                </button>
              </span>
            )}
            {filters.condition !== 'all' && (
              <span className="inline-flex items-center px-2 py-1 rounded-md bg-indigo-100 text-indigo-700 text-sm">
                {conditions.find((c) => c.value === filters.condition)?.label}
                <button
                  onClick={() => setFilter('condition', 'all')}
                  className="ml-1 hover:text-indigo-900"
                >
                  <X className="h-3 w-3" />
                </button>
              </span>
            )}
            <button
              onClick={resetFilters}
              className="text-sm text-indigo-600 hover:text-indigo-700"
            >
              Clear all
            </button>
          </div>
        )}
      </div>

      {/* Items grid/list */}
      {isLoading ? (
        <div className="text-center py-12">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          <p className="mt-4 text-gray-600">Loading items...</p>
        </div>
      ) : filteredItems.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg shadow">
          <Shirt className="mx-auto h-16 w-16 text-gray-400" />
          <h3 className="mt-4 text-lg font-medium text-gray-900">No items found</h3>
          <p className="mt-2 text-sm text-gray-600">
            {filters.search || filters.category !== 'all' || filters.condition !== 'all'
              ? 'Try adjusting your filters or search query'
              : 'Add your first item to get started'}
          </p>
          <button className="mt-6 inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700">
            <Plus className="h-4 w-4 mr-2" />
            Add First Item
          </button>
        </div>
      ) : (
        <div
          className={`grid gap-4 ${
            isGridView
              ? 'grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5'
              : 'grid-cols-1'
          }`}
        >
          {filteredItems.map((item) => (
            <div
              key={item.id}
              className="bg-white rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer relative group"
              onClick={() => setSelectedItem(item)}
            >
              {/* Checkbox for selection */}
              <div
                className={`absolute top-2 left-2 z-10 w-5 h-5 rounded border-2 ${
                  selectedItems.has(item.id)
                    ? 'bg-indigo-600 border-indigo-600'
                    : 'bg-white border-gray-300'
                } flex items-center justify-center`}
                onClick={(e) => {
                  e.stopPropagation()
                  toggleItemSelected(item.id)
                }}
              >
                {selectedItems.has(item.id) && (
                  <div className="w-2 h-2 bg-white rounded-sm" />
                )}
              </div>

              {/* Favorite button */}
              <button
                className={`absolute top-2 right-2 z-10 p-1.5 rounded-full ${
                  item.is_favorite
                    ? 'bg-pink-100 text-pink-600'
                    : 'bg-white/80 text-gray-400 hover:text-pink-500'
                }`}
                onClick={(e) => {
                  e.stopPropagation()
                  toggleItemFavorite(item.id)
                }}
              >
                <Heart
                  className={`h-4 w-4 ${item.is_favorite ? 'fill-current' : ''}`}
                />
              </button>

              {/* Item image */}
              <div className="aspect-square rounded-t-lg overflow-hidden bg-gray-100">
                {item.images.length > 0 ? (
                  <img
                    src={item.images[0].thumbnail_url || item.images[0].image_url}
                    alt={item.name}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <Shirt className="h-16 w-16 text-gray-300" />
                  </div>
                )}
              </div>

              {/* Item info */}
              <div className="p-3">
                <h3 className="font-medium text-gray-900 truncate">{item.name}</h3>
                <p className="text-sm text-gray-600 capitalize">{item.category}</p>
                {item.brand && (
                  <p className="text-xs text-gray-500 mt-1">{item.brand}</p>
                )}
                {item.usage_times_worn > 0 && (
                  <p className="text-xs text-gray-500 mt-1">
                    Worn {item.usage_times_worn} {item.usage_times_worn === 1 ? 'time' : 'times'}
                  </p>
                )}
              </div>

              {/* Condition indicator */}
              <div
                className={`absolute bottom-16 left-2 px-2 py-0.5 rounded-full text-xs font-medium ${
                  item.condition === 'clean'
                    ? 'bg-green-100 text-green-800'
                    : item.condition === 'dirty'
                    ? 'bg-yellow-100 text-yellow-800'
                    : item.condition === 'laundry'
                    ? 'bg-blue-100 text-blue-800'
                    : item.condition === 'repair'
                    ? 'bg-red-100 text-red-800'
                    : 'bg-purple-100 text-purple-800'
                }`}
              >
                {item.condition}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
