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
    <div className="w-full max-w-7xl mx-auto px-4 md:px-6 lg:px-8 py-4 md:py-8">
      {/* Welcome header */}
      <div className="mb-4 md:mb-8">
        <h1 className="text-xl md:text-3xl font-bold text-foreground">
          Welcome back, {userDisplayName}!
        </h1>
        <p className="mt-1 md:mt-2 text-xs md:text-base text-muted-foreground">
          Here's what's happening with your wardrobe today.
        </p>
      </div>

      {/* Stats cards - scroll on mobile, grid on desktop */}
      <div className="flex gap-3 overflow-x-auto scrollbar-hide scroll-snap-x -mx-4 px-4 pb-1 md:mx-0 md:px-0 md:pb-0 md:grid md:grid-cols-4 md:gap-4 lg:gap-5 mb-6 md:mb-8">
        {stats.map((stat) => (
          <Link
            key={stat.name}
            to={stat.link}
            className="relative bg-card p-3 sm:p-4 md:p-5 lg:p-6 rounded-lg shadow hover:shadow-md transition-shadow touch-target flex flex-col justify-between min-w-[160px] sm:min-w-[180px] md:min-w-0 scroll-snap-start"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-[10px] md:text-sm font-medium text-muted-foreground truncate">{stat.name}</p>
                <p className="mt-0.5 md:mt-1 text-lg md:text-3xl font-semibold text-foreground">
                  {isLoadingItems || isLoadingOutfits ? '—' : stat.value}
                </p>
              </div>
              <div className={`${stat.color} p-1.5 md:p-3 rounded-full shrink-0`}>
                <stat.icon className="h-4 w-4 md:h-6 md:w-6 text-white" />
              </div>
            </div>
          </Link>
        ))}
      </div>

      {/* Quick actions - horizontal scroll on mobile with improved snap and visual cues */}
      <div className="mb-6 md:mb-8">
        <div className="flex items-center justify-between mb-3 md:mb-4 px-1">
          <h2 className="text-base md:text-lg font-medium text-foreground">Quick Actions</h2>
          <span className="text-xs text-muted-foreground md:hidden">Scroll for more</span>
        </div>
        
        <div className="w-full overflow-x-auto scrollbar-hide scroll-snap-x -mx-4 px-4 pb-1 md:mx-0 md:px-0 md:pb-0">
          <div className="flex gap-3 md:grid md:grid-cols-3 md:gap-4 w-max md:w-full">
            {quickActions.map((action) => (
              <Link
                key={action.name}
                to={action.link}
                className={`relative rounded-lg p-4 md:p-6 text-white ${action.color} transition-colors w-[85vw] max-w-[340px] md:w-auto md:max-w-none shrink-0 md:shrink touch-target scroll-snap-center md:scroll-snap-align-none shadow-sm`}
              >
                <div className="flex items-start">
                  <div className="flex-shrink-0">
                    <action.icon className="h-6 w-6 md:h-8 md:w-8" />
                  </div>
                  <div className="ml-3 md:ml-4 flex-1">
                    <h3 className="text-base md:text-lg font-medium">{action.name}</h3>
                    <p className="mt-0.5 md:mt-1 text-xs md:text-sm opacity-90">{action.description}</p>
                  </div>
                  <ArrowRight className="h-5 w-5 opacity-70 shrink-0" />
                </div>
              </Link>
            ))}
          </div>
        </div>
      </div>

      {/* Recent activity */}
      <div className="bg-card shadow rounded-lg">
        <div className="px-4 py-4 md:py-5 md:px-6 border-b border-border">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-medium text-foreground">Recent Activity</h3>
            <Calendar className="h-5 w-5 text-muted-foreground" />
          </div>
        </div>
        <div className="px-4 py-4 md:p-6">
          {totalItems === 0 && totalOutfits === 0 ? (
            <div className="text-center py-6 md:py-8">
              <Shirt className="mx-auto h-10 w-10 md:h-12 md:w-12 text-muted-foreground" />
              <h3 className="mt-2 text-sm font-medium text-foreground">No items yet</h3>
              <p className="mt-1 text-sm text-muted-foreground">
                Get started by adding items to your wardrobe.
              </p>
              <div className="mt-4 md:mt-6">
                <Link
                  to="/wardrobe?action=add"
                  className="inline-flex items-center px-4 py-2.5 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary hover:bg-primary/90 touch-target"
                >
                  <Plus className="h-4 w-4 mr-2" />
                  Add First Item
                </Link>
              </div>
            </div>
          ) : (
            <div className="space-y-3 md:space-y-4 max-h-[60vh] overflow-y-auto pr-1 md:max-h-none md:overflow-visible">
              {/* Recent items */}
              {items.slice(0, 3).map((item) => (
                <Link
                  key={item.id}
                  to={`/wardrobe/${item.id}`}
                  className="flex items-center p-2.5 md:p-3 rounded-lg hover:bg-accent transition-colors touch-target"
                >
                  {item.images.length > 0 ? (
                    <img
                      src={item.images[0].thumbnail_url || item.images[0].image_url}
                      alt={item.name}
                      className="h-11 w-11 md:h-12 md:w-12 rounded-lg object-cover"
                    />
                  ) : (
                    <div className="h-11 w-11 md:h-12 md:w-12 rounded-lg bg-muted flex items-center justify-center">
                      <Shirt className="h-5 w-5 md:h-6 md:w-6 text-muted-foreground" />
                    </div>
                  )}
                  <div className="ml-3 md:ml-4 flex-1 min-w-0">
                    <p className="text-sm font-medium text-foreground truncate">{item.name}</p>
                    <p className="text-sm text-muted-foreground capitalize">{item.category}</p>
                  </div>
                  <span className="text-xs text-muted-foreground shrink-0">
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
