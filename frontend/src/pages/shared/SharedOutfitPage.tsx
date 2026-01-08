/**
 * Shared Outfit Page (public)
 *
 * Displays a shared outfit via `/api/v1/outfits/public/:id` with no auth.
 */

import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { Layers, Loader2 } from 'lucide-react'

import { getPublicOutfit, type PublicOutfit } from '@/api/outfits'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'

export default function SharedOutfitPage() {
  const { id } = useParams()
  const [outfit, setOutfit] = useState<PublicOutfit | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const load = async () => {
      if (!id) return
      setIsLoading(true)
      setError(null)
      try {
        const data = await getPublicOutfit(id)
        setOutfit(data)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load shared outfit')
      } finally {
        setIsLoading(false)
      }
    }

    load()
  }, [id])

  const primary = outfit?.images?.length
    ? outfit.images.find((img) => img.is_primary) || outfit.images[0]
    : null

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div className="flex items-center justify-between mb-6">
          <Link to="/" className="text-xl font-bold text-indigo-600 dark:text-indigo-400">
            FitCheck<span className="font-light text-gray-600 dark:text-gray-400 ml-1">AI</span>
          </Link>
          <div className="flex items-center gap-2">
            <Button variant="outline" asChild>
              <Link to="/auth/login">Sign in</Link>
            </Button>
            {id && (
              <Button asChild>
                <Link to={`/outfits/${id}`}>Open in app</Link>
              </Button>
            )}
          </div>
        </div>

        {isLoading ? (
          <div className="text-center py-16 text-gray-600 dark:text-gray-400">
            <Loader2 className="h-6 w-6 animate-spin inline-block mr-2" />
            Loading shared outfit…
          </div>
        ) : error ? (
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow dark:shadow-gray-900/50 p-8 text-center">
            <Layers className="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" />
            <h1 className="mt-4 text-lg font-semibold text-gray-900 dark:text-white">Outfit not available</h1>
            <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">{error}</p>
          </div>
        ) : outfit ? (
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow dark:shadow-gray-900/50 overflow-hidden">
            <div className="aspect-[4/3] bg-gray-100 dark:bg-gray-700">
              {primary?.image_url ? (
                <img
                  src={primary.thumbnail_url || primary.image_url}
                  alt={outfit.name}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-gray-400 dark:text-gray-500">
                  <Layers className="h-10 w-10" />
                </div>
              )}
            </div>

            <div className="p-6 space-y-4">
              <div>
                <h1 className="text-2xl font-bold text-gray-900 dark:text-white">{outfit.name}</h1>
                {outfit.description && (
                  <p className="mt-2 text-gray-600 dark:text-gray-400">{outfit.description}</p>
                )}
              </div>

              <div className="flex flex-wrap gap-2">
                {outfit.style && <Badge variant="secondary" className="capitalize">{outfit.style}</Badge>}
                {outfit.season && <Badge variant="secondary" className="capitalize">{outfit.season}</Badge>}
                {outfit.occasion && <Badge variant="outline" className="capitalize">{outfit.occasion}</Badge>}
                {outfit.tags?.slice(0, 6).map((t) => (
                  <Badge key={t} variant="outline" className="capitalize">{t}</Badge>
                ))}
              </div>

              {outfit.items?.length > 0 && (
                <div>
                  <div className="text-sm font-semibold text-gray-900 dark:text-white mb-2">Items</div>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    {outfit.items.map((it) => (
                      <div key={it.id} className="p-3 rounded-lg border border-gray-200 dark:border-gray-700">
                        <div className="text-sm font-medium text-gray-900 dark:text-white">{it.name}</div>
                        <div className="text-xs text-gray-600 dark:text-gray-400 capitalize">{it.category}</div>
                        {it.colors?.length > 0 && (
                          <div className="text-xs text-gray-500 dark:text-gray-400 mt-1">{it.colors.join(', ')}</div>
                        )}
                        {it.brand && (
                          <div className="text-xs text-gray-500 dark:text-gray-400 mt-1">{it.brand}</div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        ) : null}
      </div>
    </div>
  )
}

