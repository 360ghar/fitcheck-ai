/**
 * Dashboard Page
 * Overview of user's wardrobe, outfits, and recommendations
 */

import { useEffect, useState } from 'react'
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
  Heart,
} from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'
import { StatCard } from '@/components/dashboard/StatCard'
import { ItemUpload, type ItemUploadResult } from '@/components/wardrobe/ItemUpload'
import { cn } from '@/lib/utils'

export default function DashboardPage() {
  const userDisplayName = useUserDisplayName()
  const items = useWardrobeStore((state) => state.items)
  const outfits = useOutfitStore((state) => state.outfits)
  const fetchItems = useWardrobeStore((state) => state.fetchItems)
  const fetchOutfits = useOutfitStore((state) => state.fetchOutfits)
  const isLoadingItems = useWardrobeStore((state) => state.isLoading)
  const isLoadingOutfits = useOutfitStore((state) => state.isLoading)

  const [isUploadModalOpen, setIsUploadModalOpen] = useState(false)
  const navigate = useNavigate()

  useEffect(() => {
    fetchItems(true)
    fetchOutfits(true)
  }, [fetchItems, fetchOutfits])

  // Handle upload completion
  const handleUploadComplete = (results: ItemUploadResult[]) => {
    setIsUploadModalOpen(false)
    fetchItems(true) // Refresh items
    if (results.some((r) => r.success)) {
      navigate('/wardrobe')
    }
  }

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
      gradient: 'cool' as const,
      link: '/wardrobe',
    },
    {
      name: 'Outfits Created',
      value: totalOutfits,
      icon: Layers,
      gradient: 'primary' as const,
      link: '/outfits',
    },
    {
      name: 'Total Wears',
      value: totalWears,
      icon: TrendingUp,
      gradient: 'success' as const,
      link: '/wardrobe',
    },
    {
      name: 'Favorites',
      value: favoriteItems,
      icon: Heart,
      gradient: 'warm' as const,
      link: '/wardrobe?favorites=true',
    },
  ]

  const quickActions = [
    {
      name: 'Add Item',
      description: 'Add a new item to your wardrobe',
      icon: Shirt,
      onClick: () => setIsUploadModalOpen(true),
      gradient: 'bg-gradient-to-br from-gold-400 to-gold-600',
      textColor: 'text-navy-900',
    },
    {
      name: 'Create Outfit',
      description: 'Combine items into a new outfit',
      icon: Layers,
      link: '/outfits?action=create',
      gradient: 'bg-navy-800 dark:bg-navy-700',
      textColor: 'text-white',
    },
    {
      name: 'Get Recommendations',
      description: 'AI-powered outfit suggestions',
      icon: Sparkles,
      link: '/recommendations',
      gradient: 'bg-gradient-to-br from-navy-700 to-navy-900',
      textColor: 'text-white',
    },
  ]

  return (
    <div className="w-full max-w-7xl mx-auto px-4 md:px-6 lg:px-8 py-4 md:py-8">
      {/* Welcome header */}
      <div className="mb-4 md:mb-8">
        <h1 className="text-xl md:text-3xl font-display font-semibold text-foreground">
          Welcome back, {userDisplayName}!
        </h1>
        <p className="mt-1 md:mt-2 text-xs md:text-base text-muted-foreground">
          Here's what's happening with your wardrobe today.
        </p>
      </div>

      {/* Stats cards - responsive grid */}
      <div className="grid grid-cols-2 gap-3 md:grid-cols-4 md:gap-4 lg:gap-5 mb-6 md:mb-8">
        {stats.map((stat) => (
          <StatCard
            key={stat.name}
            name={stat.name}
            value={stat.value}
            icon={stat.icon}
            gradient={stat.gradient}
            link={stat.link}
            isLoading={isLoadingItems || isLoadingOutfits}
          />
        ))}
      </div>

      {/* Quick actions - responsive grid */}
      <div className="mb-6 md:mb-8">
        <div className="flex items-center justify-between mb-3 md:mb-4 px-1">
          <h2 className="text-base md:text-lg font-semibold text-foreground">Quick Actions</h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 md:gap-4">
          {quickActions.map((action) => {
            const commonClassName = cn(
              'group relative rounded-xl p-4 md:p-5 overflow-hidden text-left w-full',
              'transition-all duration-300',
              'hover:shadow-elevated hover:-translate-y-0.5',
              'touch-target',
              action.gradient,
              action.textColor
            )

            const content = (
              <>
                {/* Background glow effect on hover */}
                <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity bg-white/10" />

                <div className="relative flex items-start gap-3 md:gap-4">
                  <div className="p-2 md:p-2.5 rounded-lg bg-white/20 backdrop-blur-sm shrink-0">
                    <action.icon className="h-5 w-5 md:h-6 md:w-6" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="text-sm md:text-base font-semibold">{action.name}</h3>
                    <p className="mt-0.5 text-xs md:text-sm text-white/80 line-clamp-2">{action.description}</p>
                  </div>
                  <ArrowRight className={cn(
                    'h-5 w-5 shrink-0 opacity-50',
                    'transition-all duration-200',
                    'group-hover:opacity-100 group-hover:translate-x-0.5'
                  )} />
                </div>
              </>
            )

            if (action.onClick) {
              return (
                <button
                  key={action.name}
                  type="button"
                  onClick={action.onClick}
                  className={commonClassName}
                >
                  {content}
                </button>
              )
            }

            return (
              <Link
                key={action.name}
                to={action.link!}
                className={commonClassName}
              >
                {content}
              </Link>
            )
          })}
        </div>
      </div>

      {/* Recent activity */}
      <div className="bg-card shadow-sm rounded-xl overflow-hidden">
        <div className="px-4 py-4 md:py-5 md:px-6 border-b border-border">
          <div className="flex items-center justify-between">
            <h3 className="text-base md:text-lg font-semibold text-foreground">Recent Activity</h3>
            <div className="p-2 rounded-lg bg-muted">
              <Calendar className="h-4 w-4 md:h-5 md:w-5 text-muted-foreground" />
            </div>
          </div>
        </div>
        <div className="px-4 py-4 md:p-6">
          {totalItems === 0 && totalOutfits === 0 ? (
            <div className="text-center py-8 md:py-12">
              <div className="mx-auto w-16 h-16 md:w-20 md:h-20 rounded-full bg-muted flex items-center justify-center mb-4">
                <Shirt className="h-8 w-8 md:h-10 md:w-10 text-muted-foreground" />
              </div>
              <h3 className="text-sm md:text-base font-medium text-foreground">No items yet</h3>
              <p className="mt-1 text-sm text-muted-foreground max-w-xs mx-auto">
                Get started by adding items to your wardrobe.
              </p>
              <div className="mt-5 md:mt-6">
                <button
                  type="button"
                  onClick={() => setIsUploadModalOpen(true)}
                  className={cn(
                    'inline-flex items-center px-4 py-2.5 rounded-lg',
                    'text-sm font-medium text-navy-900',
                    'bg-gradient-to-r from-gold-400 to-gold-600',
                    'hover:shadow-elevated transition-all duration-200',
                    'touch-target'
                  )}
                >
                  <Plus className="h-4 w-4 mr-2" />
                  Add First Item
                </button>
              </div>
            </div>
          ) : (
            <div className="space-y-2 md:space-y-3">
              {/* Recent items */}
              {items.slice(0, 3).map((item) => (
                <Link
                  key={item.id}
                  to={`/wardrobe/${item.id}`}
                  className={cn(
                    'flex items-center p-2.5 md:p-3 rounded-xl',
                    'hover:bg-accent/50 transition-colors',
                    'touch-target group'
                  )}
                >
                  {item.images.length > 0 ? (
                    <img
                      src={item.images[0].thumbnail_url || item.images[0].image_url}
                      alt={item.name}
                      className="h-12 w-12 md:h-14 md:w-14 rounded-lg object-cover"
                    />
                  ) : (
                    <div className="h-12 w-12 md:h-14 md:w-14 rounded-lg bg-muted flex items-center justify-center">
                      <Shirt className="h-5 w-5 md:h-6 md:w-6 text-muted-foreground" />
                    </div>
                  )}
                  <div className="ml-3 md:ml-4 flex-1 min-w-0">
                    <p className="text-sm font-medium text-foreground truncate">{item.name}</p>
                    <p className="text-xs md:text-sm text-muted-foreground capitalize">{item.category}</p>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-muted-foreground shrink-0">
                      {new Date(item.created_at).toLocaleDateString()}
                    </span>
                    <ArrowRight className="h-4 w-4 text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity" />
                  </div>
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Upload Modal */}
      <ItemUpload
        isOpen={isUploadModalOpen}
        onClose={() => setIsUploadModalOpen(false)}
        onUploadComplete={handleUploadComplete}
        onRequestOpen={() => setIsUploadModalOpen(true)}
      />
    </div>
  )
}
