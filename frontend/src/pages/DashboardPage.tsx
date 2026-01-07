/**
 * Dashboard Page
 * Overview of user's wardrobe, outfits, and recommendations
 */

import { useEffect } from 'react'
import { useWardrobeStore } from '../stores/wardrobeStore'
import { useOutfitStore } from '../stores/outfitStore'
import { useUserDisplayName } from '../stores/authStore'
import {
  Shirt,
  Layers,
  Sparkles,
  TrendingUp,
  Calendar,
  Plus,
  ArrowRight,
} from 'lucide-react'
import { Link } from 'react-router-dom'

export default function DashboardPage() {
  const userDisplayName = useUserDisplayName()
  const items = useWardrobeStore((state) => state.items)
  const outfits = useOutfitStore((state) => state.outfits)
  const fetchItems = useWardrobeStore((state) => state.fetchItems)
  const fetchOutfits = useOutfitStore((state) => state.fetchOutfits)
  const isLoadingItems = useWardrobeStore((state) => state.isLoading)
  const isLoadingOutfits = useOutfitStore((state) => state.isLoading)

  useEffect(() => {
    fetchItems(true)
    fetchOutfits(true)
  }, [fetchItems, fetchOutfits])

  // Calculate statistics
  const totalItems = items.length
  const totalOutfits = outfits.length
  const favoriteItems = items.filter((i) => i.is_favorite).length
  const totalWears = items.reduce((sum, item) => sum + item.usage_times_worn, 0)

  const stats = [
    {
      name: 'Total Items',
      value: totalItems,
      icon: Shirt,
      color: 'bg-blue-500',
      link: '/wardrobe',
    },
    {
      name: 'Outfits Created',
      value: totalOutfits,
      icon: Layers,
      color: 'bg-purple-500',
      link: '/outfits',
    },
    {
      name: 'Total Wears',
      value: totalWears,
      icon: TrendingUp,
      color: 'bg-green-500',
      link: '/wardrobe',
    },
    {
      name: 'Favorites',
      value: favoriteItems,
      icon: Sparkles,
      color: 'bg-yellow-500',
      link: '/wardrobe?favorites=true',
    },
  ]

  const quickActions = [
    {
      name: 'Add Item',
      description: 'Add a new item to your wardrobe',
      icon: Shirt,
      link: '/wardrobe?action=add',
      color: 'bg-indigo-600 hover:bg-indigo-700',
    },
    {
      name: 'Create Outfit',
      description: 'Combine items into a new outfit',
      icon: Layers,
      link: '/outfits?action=create',
      color: 'bg-purple-600 hover:bg-purple-700',
    },
    {
      name: 'Get Recommendations',
      description: 'AI-powered outfit suggestions',
      icon: Sparkles,
      link: '/recommendations',
      color: 'bg-pink-600 hover:bg-pink-700',
    },
  ]

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Welcome header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">
          Welcome back, {userDisplayName}!
        </h1>
        <p className="mt-2 text-gray-600">
          Here's what's happening with your wardrobe today.
        </p>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4 mb-8">
        {stats.map((stat) => (
          <Link
            key={stat.name}
            to={stat.link}
            className="relative bg-white pt-5 px-4 pb-4 sm:pt-6 sm:px-6 rounded-lg shadow hover:shadow-md transition-shadow"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 truncate">{stat.name}</p>
                <p className="mt-1 text-3xl font-semibold text-gray-900">
                  {isLoadingItems || isLoadingOutfits ? '—' : stat.value}
                </p>
              </div>
              <div className={`${stat.color} p-3 rounded-full`}>
                <stat.icon className="h-6 w-6 text-white" />
              </div>
            </div>
          </Link>
        ))}
      </div>

      {/* Quick actions */}
      <div className="mb-8">
        <h2 className="text-lg font-medium text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          {quickActions.map((action) => (
            <Link
              key={action.name}
              to={action.link}
              className={`relative rounded-lg p-6 text-white ${action.color} transition-colors`}
            >
              <div className="flex items-start">
                <div className="flex-shrink-0">
                  <action.icon className="h-8 w-8" />
                </div>
                <div className="ml-4 flex-1">
                  <h3 className="text-lg font-medium">{action.name}</h3>
                  <p className="mt-1 text-sm opacity-90">{action.description}</p>
                </div>
                <ArrowRight className="h-5 w-5 opacity-70" />
              </div>
            </Link>
          ))}
        </div>
      </div>

      {/* Recent activity */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:px-6 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-medium text-gray-900">Recent Activity</h3>
            <Calendar className="h-5 w-5 text-gray-400" />
          </div>
        </div>
        <div className="px-4 py-5 sm:p-6">
          {totalItems === 0 && totalOutfits === 0 ? (
            <div className="text-center py-8">
              <Shirt className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No items yet</h3>
              <p className="mt-1 text-sm text-gray-500">
                Get started by adding items to your wardrobe.
              </p>
              <div className="mt-6">
                <Link
                  to="/wardrobe?action=add"
                  className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
                >
                  <Plus className="h-4 w-4 mr-2" />
                  Add First Item
                </Link>
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              {/* Recent items */}
              {items.slice(0, 3).map((item) => (
                <Link
                  key={item.id}
                  to={`/wardrobe/${item.id}`}
                  className="flex items-center p-3 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  {item.images.length > 0 ? (
                    <img
                      src={item.images[0].thumbnail_url || item.images[0].image_url}
                      alt={item.name}
                      className="h-12 w-12 rounded-lg object-cover"
                    />
                  ) : (
                    <div className="h-12 w-12 rounded-lg bg-gray-200 flex items-center justify-center">
                      <Shirt className="h-6 w-6 text-gray-400" />
                    </div>
                  )}
                  <div className="ml-4 flex-1">
                    <p className="text-sm font-medium text-gray-900">{item.name}</p>
                    <p className="text-sm text-gray-500 capitalize">{item.category}</p>
                  </div>
                  <span className="text-xs text-gray-400">
                    {new Date(item.created_at).toLocaleDateString()}
                  </span>
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
