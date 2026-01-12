/**
 * Shared Outfit Page (public)
 *
 * Displays a shared outfit via `/api/v1/outfits/public/:id` with no auth.
 * Includes SEO tags for social sharing (backup for edge function).
 */

import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { Layers, Loader2 } from 'lucide-react'

import { getPublicOutfit, type PublicOutfit } from '@/api/outfits'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import { SEO, OutfitJsonLd } from '@/components/seo'

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

  // Generate SEO data
  const seoTitle = outfit?.name ? `${outfit.name} | FitCheck AI` : 'Shared Outfit | FitCheck AI'
  const seoDescription = outfit?.description ||
    `Check out this ${outfit?.style || ''} outfit on FitCheck AI`.trim()
  const seoImage = primary?.image_url || 'https://fitcheckaiapp.com/og-outfit-fallback.svg'

  return (
    <>
      {/* SEO - Client-side fallback (Edge function handles crawlers) */}
      <SEO
        title={seoTitle}
        description={seoDescription}
        ogImage={seoImage}
        ogType="article"
        canonicalUrl={`https://fitcheckaiapp.com/shared/outfits/${id}`}
      />
      {outfit && (
        <OutfitJsonLd
          name={outfit.name}
          description={outfit.description || undefined}
          imageUrl={seoImage}
          datePublished={outfit.created_at}
          tags={[outfit.style, outfit.season, outfit.occasion, ...(outfit.tags || [])].filter(Boolean) as string[]}
        />
      )}

      <div className="min-h-screen bg-muted/30">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6 md:py-10">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between mb-6">
          <Link to="/" className="text-xl font-display font-semibold text-navy-800 dark:text-gold-400">
            FitCheck<span className="font-light text-muted-foreground ml-1">AI</span>
          </Link>
          <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2">
            <Button variant="outline" asChild className="w-full sm:w-auto">
              <Link to="/auth/login">Sign in</Link>
            </Button>
            {id && (
              <Button variant="gold" asChild className="w-full sm:w-auto">
                <Link to={`/outfits/${id}`}>Open in app</Link>
              </Button>
            )}
          </div>
        </div>

        {isLoading ? (
          <div className="text-center py-16 text-muted-foreground">
            <Loader2 className="h-6 w-6 animate-spin inline-block mr-2" />
            Loading shared outfit…
          </div>
        ) : error ? (
          <div className="bg-card rounded-lg shadow-sm p-8 text-center">
            <Layers className="mx-auto h-12 w-12 text-muted-foreground" />
            <h1 className="mt-4 text-lg font-semibold text-foreground">Outfit not available</h1>
            <p className="mt-2 text-sm text-muted-foreground">{error}</p>
          </div>
        ) : outfit ? (
          <div className="bg-card rounded-lg shadow-sm overflow-hidden">
            <div className="aspect-[4/3] bg-muted">
              {primary?.image_url ? (
                <ZoomableImage
                  src={primary.thumbnail_url || primary.image_url}
                  alt={outfit.name}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-muted-foreground">
                  <Layers className="h-10 w-10" />
                </div>
              )}
            </div>

            <div className="p-6 space-y-4">
              <div>
                <h1 className="text-2xl font-display font-semibold text-foreground">{outfit.name}</h1>
                {outfit.description && (
                  <p className="mt-2 text-muted-foreground">{outfit.description}</p>
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
                  <div className="text-sm font-semibold text-foreground mb-2">Items</div>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    {outfit.items.map((it) => (
                      <div key={it.id} className="p-3 rounded-lg border border-border">
                        <div className="text-sm font-medium text-foreground">{it.name}</div>
                        <div className="text-xs text-muted-foreground capitalize">{it.category}</div>
                        {it.colors?.length > 0 && (
                          <div className="text-xs text-muted-foreground mt-1">{it.colors.join(', ')}</div>
                        )}
                        {it.brand && (
                          <div className="text-xs text-muted-foreground mt-1">{it.brand}</div>
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
    </>
  )
}

