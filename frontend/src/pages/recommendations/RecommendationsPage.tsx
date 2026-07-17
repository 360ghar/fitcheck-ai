/**
 * Recommendations Page
 * AI-powered outfit suggestions and style recommendations
 */

import { useEffect, useMemo, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { Layers, Palette, Search, Shirt, Sparkles, Stars, Sun, TrendingUp } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { ScrollableTabs, ScrollableTab } from '@/components/ui/scrollable-tabs'
import { useToast } from '@/components/ui/use-toast'
import { ItemImage } from '@/components/ui/item-image'
import { EmptyState } from '@/components/ui/empty-state'
import { cn } from '@/lib/utils'
import { generateFallbackOutfits } from '@/lib/outfit-generator'
import { AstrologyTab } from '@/components/recommendations'

import { useWardrobeStore } from '@/stores/wardrobeStore'
import {
  findMatchingItems,
  getAstrologyRecommendations,
  getCompleteLookSuggestions,
  getShoppingRecommendations,
  getWeatherRecommendations,
} from '@/api/recommendations'
import type { AstrologyRecommendationMode, CompleteLookSuggestion, MatchResult, Item } from '@/types'

type TabType = 'today' | 'match' | 'complete' | 'weather' | 'astrology' | 'shopping'

const RECOMMENDATIONS_TABS = [
  { id: 'today' as TabType, name: 'Today', icon: Sun },
  { id: 'match' as TabType, name: 'Find Matches', icon: Shirt },
  { id: 'complete' as TabType, name: 'Complete Look', icon: Layers },
  { id: 'weather' as TabType, name: 'Weather', icon: TrendingUp },
  { id: 'astrology' as TabType, name: 'Astrology', icon: Stars },
  { id: 'shopping' as TabType, name: 'Shopping', icon: Palette },
]

function formatScore(score: number | undefined | null): string {
  if (score == null || Number.isNaN(score)) return '—'
  const pct = score <= 1 ? Math.round(score * 100) : Math.round(score)
  return `${pct}%`
}

function localDateISO(): string {
  const now = new Date()
  const yyyy = now.getFullYear()
  const mm = String(now.getMonth() + 1).padStart(2, '0')
  const dd = String(now.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

/**
 * Normalize recommendation/API item shapes so ItemImage always sees `images[]`.
 * Handles: images, item_images (Supabase join), flat image_url, and wardrobe store merge.
 */
const enrichItemWithImages = (item: Item, wardrobeItems: Item[]): Item => {
  const raw = item as Item & {
    item_images?: Array<{
      id?: string
      image_url?: string
      thumbnail_url?: string
      is_primary?: boolean
      width?: number
      height?: number
      created_at?: string
    }>
  }

  if (Array.isArray(raw.images) && raw.images.length > 0) {
    return raw
  }

  if (Array.isArray(raw.item_images) && raw.item_images.length > 0) {
    return {
      ...raw,
      images: raw.item_images.map((img, index) => ({
        id: img.id || `${raw.id}-img-${index}`,
        item_id: raw.id,
        image_url: img.image_url || '',
        thumbnail_url: img.thumbnail_url,
        is_primary: Boolean(img.is_primary),
        width: img.width,
        height: img.height,
        created_at: img.created_at || new Date().toISOString(),
      })),
    }
  }

  if (raw.image_url) {
    return {
      ...raw,
      images: [
        {
          id: `${raw.id}-primary`,
          item_id: raw.id,
          image_url: raw.image_url,
          thumbnail_url: raw.image_url,
          is_primary: true,
          created_at: new Date().toISOString(),
        },
      ],
    }
  }

  // Fallback: wardrobe store (may be partial due to pagination)
  const fullItem = wardrobeItems.find((w) => w.id === item.id)
  if (fullItem?.images && fullItem.images.length > 0) {
    return { ...item, images: fullItem.images }
  }

  return item
}

export default function RecommendationsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('today')
  const { toast } = useToast()

  const items = useWardrobeStore((s) => s.items)
  const isLoadingItems = useWardrobeStore((s) => s.isLoading)
  const fetchItems = useWardrobeStore((s) => s.fetchItems)

  useEffect(() => {
    if (items.length === 0) {
      fetchItems(true).catch(() => null)
    }
  }, [fetchItems, items.length])

  // ============================================================================
  // MATCH TAB
  // ============================================================================

  const [matchItemId, setMatchItemId] = useState<string>('')
  const [matchSearch, setMatchSearch] = useState('')
  const [matchData, setMatchData] = useState<{ matches: MatchResult[]; complete_looks: CompleteLookSuggestion[] } | null>(null)
  const [isLoadingMatch, setIsLoadingMatch] = useState(false)
  const todayAutoRanRef = useRef(false)

  const selectedMatchItem = useMemo(
    () => items.find((i) => i.id === matchItemId) || null,
    [items, matchItemId]
  )

  const runMatch = async (id: string) => {
    if (!id) return
    setIsLoadingMatch(true)
    try {
      const data = await findMatchingItems(id, { limit: 12 })
      setMatchData(data)
    } catch (err) {
      toast({
        title: 'Failed to find matches',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsLoadingMatch(false)
    }
  }

  // ============================================================================
  // COMPLETE LOOK TAB
  // ============================================================================

  const [completeSelection, setCompleteSelection] = useState<Set<string>>(new Set())
  const [completeLooks, setCompleteLooks] = useState<CompleteLookSuggestion[]>([])
  const [isLoadingComplete, setIsLoadingComplete] = useState(false)
  const [hasAttemptedComplete, setHasAttemptedComplete] = useState(false)

  const toggleCompleteItem = (itemId: string) => {
    setCompleteSelection((prev) => {
      const next = new Set(prev)
      if (next.has(itemId)) next.delete(itemId)
      else next.add(itemId)
      return next
    })
  }

  const runCompleteLook = async () => {
    const ids = Array.from(completeSelection)
    if (ids.length === 0) {
      toast({ title: 'Select at least one item', variant: 'destructive' })
      return
    }

    setIsLoadingComplete(true)
    setHasAttemptedComplete(true)

    try {
      let looks = await getCompleteLookSuggestions(ids, { limit: 6 })

      // Fallback: If API returns empty, generate client-side suggestions
      if (!looks || looks.length === 0) {
        const selectedItems = items.filter((item) => completeSelection.has(item.id))
        looks = generateFallbackOutfits(selectedItems, items, 6)
      }

      setCompleteLooks(looks)
    } catch (err) {
      // On API error, try fallback
      const selectedItems = items.filter((item) => completeSelection.has(item.id))
      const fallbackLooks = generateFallbackOutfits(selectedItems, items, 6)

      if (fallbackLooks.length > 0) {
        setCompleteLooks(fallbackLooks)
      } else {
        toast({
          title: 'Failed to generate complete looks',
          description: err instanceof Error ? err.message : 'An error occurred',
          variant: 'destructive',
        })
      }
    } finally {
      setIsLoadingComplete(false)
    }
  }

  // ============================================================================
  // WEATHER TAB
  // ============================================================================

  const [weatherLocation, setWeatherLocation] = useState('')
  const [weatherData, setWeatherData] = useState<Awaited<ReturnType<typeof getWeatherRecommendations>> | null>(null)
  const [isLoadingWeather, setIsLoadingWeather] = useState(false)

  const runWeather = async () => {
    setIsLoadingWeather(true)
    try {
      const data = await getWeatherRecommendations(weatherLocation.trim() || undefined)
      setWeatherData(data)
    } catch (err) {
      toast({
        title: 'Failed to load weather recommendations',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsLoadingWeather(false)
    }
  }

  // Auto-load weather for "Today" default tab once items are ready
  useEffect(() => {
    if (activeTab !== 'today' || todayAutoRanRef.current || isLoadingItems) return
    todayAutoRanRef.current = true
    void runWeather()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeTab, isLoadingItems])

  const weatherSuggestedItems = useMemo(() => {
    if (!weatherData?.preferred_categories?.length || items.length === 0) return []
    const cats = new Set(weatherData.preferred_categories.map((c) => c.toLowerCase()))
    return items
      .filter((i) => cats.has(String(i.category).toLowerCase()) && (i.condition === 'clean' || !i.condition))
      .slice(0, 12)
  }, [weatherData, items])

  const filteredMatchItems = useMemo(() => {
    const q = matchSearch.trim().toLowerCase()
    if (!q) return items
    return items.filter(
      (i) =>
        i.name.toLowerCase().includes(q) ||
        i.category.toLowerCase().includes(q) ||
        (i.brand || '').toLowerCase().includes(q)
    )
  }, [items, matchSearch])

  // ============================================================================
  // ASTROLOGY TAB
  // ============================================================================

  const [astrologyMode, setAstrologyMode] = useState<AstrologyRecommendationMode>('daily')
  const [astrologyDate, setAstrologyDate] = useState(localDateISO)
  const [astrologyData, setAstrologyData] = useState<Awaited<ReturnType<typeof getAstrologyRecommendations>> | null>(null)
  const [isLoadingAstrology, setIsLoadingAstrology] = useState(false)
  const astrologyRequestIdRef = useRef(0)

  const runAstrology = async () => {
    const requestId = ++astrologyRequestIdRef.current
    setIsLoadingAstrology(true)
    try {
      const data = await getAstrologyRecommendations({
        target_date: astrologyDate,
        mode: astrologyMode,
      })
      if (requestId !== astrologyRequestIdRef.current) return
      setAstrologyData(data)
    } catch (err) {
      if (requestId !== astrologyRequestIdRef.current) return
      toast({
        title: 'Failed to load astrology recommendations',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      if (requestId !== astrologyRequestIdRef.current) return
      setIsLoadingAstrology(false)
    }
  }

  // ============================================================================
  // SHOPPING TAB
  // ============================================================================

  const [shoppingCategory, setShoppingCategory] = useState('')
  const [shoppingStyle, setShoppingStyle] = useState('')
  const [shoppingBudget, setShoppingBudget] = useState('')
  const [shopping, setShopping] = useState<Awaited<ReturnType<typeof getShoppingRecommendations>>>([])
  const [isLoadingShopping, setIsLoadingShopping] = useState(false)

  const runShopping = async () => {
    setIsLoadingShopping(true)
    try {
      const budget = shoppingBudget.trim() ? Number(shoppingBudget.trim()) : undefined
      const data = await getShoppingRecommendations({
        category: shoppingCategory.trim() || undefined,
        style: shoppingStyle.trim() || undefined,
        budget: Number.isFinite(budget) ? budget : undefined,
      })
      setShopping(data)
    } catch (err) {
      toast({
        title: 'Failed to load shopping recommendations',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsLoadingShopping(false)
    }
  }

  const tabs = RECOMMENDATIONS_TABS

  const renderItemCard = (item: Item) => {
    const enrichedItem = enrichItemWithImages(item, items)
    return (
      <div className="flex items-center gap-3">
        <ItemImage item={enrichedItem} size="sm" />
        <div className="min-w-0">
          <div className="text-sm font-medium text-foreground truncate">{enrichedItem.name}</div>
          <div className="text-xs text-muted-foreground capitalize truncate">{enrichedItem.category}</div>
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-7xl mx-auto px-4 md:px-6 lg:px-8 py-4 md:py-8">
      {/* Header */}
      <div className="mb-4 md:mb-8">
        <h1 className="text-xl md:text-2xl font-bold text-foreground flex items-center">
          <Sparkles className="h-5 w-5 md:h-7 md:w-7 text-primary mr-2" />
          AI Recommendations
        </h1>
        <p className="mt-1 md:mt-2 text-sm text-muted-foreground">
          Get personalized outfit suggestions powered by AI
        </p>
      </div>

      <ScrollableTabs className="mb-4 md:mb-6" aria-label="Recommendation tools">
        {tabs.map((tab) => (
          <ScrollableTab
            key={tab.id}
            isActive={activeTab === tab.id}
            onClick={() => setActiveTab(tab.id)}
            className="min-w-[100px] justify-center"
          >
            <tab.icon className="h-4 w-4" />
            <span className="hidden xs:inline">{tab.name}</span>
            <span className="xs:hidden">{tab.name.split(' ')[0]}</span>
          </ScrollableTab>
        ))}
      </ScrollableTabs>

      <div className="space-y-4">
        {activeTab === 'today' && (
          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="text-base md:text-lg">What to wear today</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 px-4 pb-4 md:px-6 md:pb-6">
              {items.length === 0 && !isLoadingItems ? (
                <EmptyState
                  icon={Shirt}
                  title="Add clothes first"
                  description="Digitize a few wardrobe items to get daily outfit ideas."
                  actionLabel="Go to wardrobe"
                  onAction={() => { window.location.href = '/wardrobe?action=add' }}
                />
              ) : (
                <>
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                    <p className="text-sm text-muted-foreground">
                      Weather-aware picks from your wardrobe for right now.
                    </p>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => void runWeather()}
                      disabled={isLoadingWeather}
                    >
                      {isLoadingWeather ? 'Refreshing…' : 'Refresh'}
                    </Button>
                  </div>

                  {isLoadingWeather && !weatherData && (
                    <p className="text-sm text-muted-foreground">Loading today’s recommendations…</p>
                  )}

                  {weatherData && (
                    <div className="space-y-4">
                      <div className="flex flex-wrap items-center gap-2">
                        <Badge variant="secondary">{Math.round(weatherData.temperature)}°C</Badge>
                        <Badge variant="outline" className="capitalize">{weatherData.weather_state}</Badge>
                        <span className="text-sm text-muted-foreground capitalize">
                          {weatherData.temp_category}
                        </span>
                        <span className="text-xs text-muted-foreground">· current conditions</span>
                      </div>
                      {weatherData.notes?.length > 0 && (
                        <p className="text-sm text-foreground">{weatherData.notes.join(' ')}</p>
                      )}
                      <div>
                        <p className="text-sm font-semibold mb-2">From your wardrobe</p>
                        {weatherSuggestedItems.length === 0 ? (
                          <p className="text-sm text-muted-foreground">
                            No matching clean items for preferred categories (
                            {weatherData.preferred_categories.join(', ')}). Add more pieces or open
                            Complete Look.
                          </p>
                        ) : (
                          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
                            {weatherSuggestedItems.map((item) => (
                              <div
                                key={item.id}
                                className="p-2 rounded-lg border border-border bg-card"
                              >
                                {renderItemCard(item)}
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                      <div className="flex flex-wrap gap-2">
                        <Button asChild variant="outline" size="sm">
                          <Link to="/outfits?action=create">Save as outfit</Link>
                        </Button>
                        <Button asChild variant="outline" size="sm">
                          <Link to="/try-on">Try on</Link>
                        </Button>
                        <Button variant="ghost" size="sm" onClick={() => setActiveTab('complete')}>
                          Complete look tools
                        </Button>
                      </div>
                    </div>
                  )}
                </>
              )}
            </CardContent>
          </Card>
        )}

        {activeTab === 'match' && (
          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="text-base md:text-lg">Find Matches</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 px-4 pb-4 md:px-6 md:pb-6">
              {items.length === 0 && !isLoadingItems ? (
                <EmptyState
                  icon={Shirt}
                  title="Add items first"
                  description="Add wardrobe items to find matching pieces."
                  actionLabel="Add item"
                  onAction={() => { window.location.href = '/wardrobe?action=add' }}
                />
              ) : (
                <>
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                    <Input
                      value={matchSearch}
                      onChange={(e) => setMatchSearch(e.target.value)}
                      placeholder="Search wardrobe…"
                      className="pl-9"
                      aria-label="Search items to match"
                    />
                  </div>
                  <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2 max-h-[40vh] overflow-y-auto pr-1">
                    {filteredMatchItems.map((item) => {
                      const selected = matchItemId === item.id
                      return (
                        <button
                          key={item.id}
                          type="button"
                          onClick={() => setMatchItemId(item.id)}
                          className={cn(
                            'text-left p-2 rounded-lg border transition-colors',
                            selected
                              ? 'border-primary bg-primary/10 ring-1 ring-primary'
                              : 'border-border hover:border-primary/40'
                          )}
                        >
                          {renderItemCard(item)}
                        </button>
                      )
                    })}
                  </div>
                  <Button
                    onClick={() => runMatch(matchItemId)}
                    disabled={!matchItemId || isLoadingMatch}
                    className="w-full md:w-auto"
                  >
                    {isLoadingMatch ? 'Finding…' : 'Find matches'}
                  </Button>

                  {selectedMatchItem && (
                    <div className="p-3 rounded-lg bg-muted">
                      <div className="text-sm text-muted-foreground mb-2">Selected</div>
                      {renderItemCard(selectedMatchItem)}
                    </div>
                  )}

                  {matchData && (
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <div className="text-sm font-semibold text-foreground">Matching items</div>
                        {matchData.matches.length === 0 ? (
                          <div className="text-sm text-muted-foreground">No matches found.</div>
                        ) : (
                          <div className="flex overflow-x-auto gap-3 pb-2 scrollbar-hide scroll-snap-x md:grid md:grid-cols-1 md:overflow-visible md:gap-2">
                            {matchData.matches
                              .filter((m) => m.item?.id)
                              .slice(0, 10)
                              .map((m) => (
                              <div key={m.item.id} className="p-3 rounded-lg border border-border min-w-[200px] md:min-w-0 scroll-snap-start">
                                <div className="flex items-start justify-between gap-3">
                                  <div className="min-w-0">{renderItemCard(m.item)}</div>
                                  <Badge variant="secondary">{formatScore(m.score)}</Badge>
                                </div>
                                {m.reasons?.length > 0 && (
                                  <div className="mt-2 text-xs text-muted-foreground">
                                    {m.reasons.join(' • ')}
                                  </div>
                                )}
                              </div>
                            ))}
                          </div>
                        )}
                      </div>

                      <div className="space-y-2">
                        <div className="text-sm font-semibold text-foreground">Complete looks</div>
                        {matchData.complete_looks.length === 0 ? (
                          <div className="text-sm text-muted-foreground">No complete looks yet.</div>
                        ) : (
                          <div className="flex overflow-x-auto gap-3 pb-2 scrollbar-hide scroll-snap-x md:grid md:grid-cols-1 md:overflow-visible md:gap-2">
                            {matchData.complete_looks.slice(0, 4).map((look) => (
                              <div key={look.items.map((it) => it.id).join('-')} className="p-3 rounded-lg border border-border min-w-[250px] md:min-w-0 scroll-snap-start">
                                <div className="flex items-center justify-between gap-3">
                                  <div className="text-sm font-medium text-foreground">{look.description}</div>
                                  <Badge variant="outline">{formatScore(look.match_score)}</Badge>
                                </div>
                                <div className="mt-2 space-y-2">
                                  {(look.items || [])
                                    .filter((it) => it?.id)
                                    .slice(0, 4)
                                    .map((it) => (
                                    <div key={it.id} className="text-sm">
                                      {renderItemCard(it)}
                                    </div>
                                  ))}
                                </div>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                  )}
                </>
              )}
            </CardContent>
          </Card>
        )}

        {activeTab === 'complete' && (
          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="text-base md:text-lg">Complete Look</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 px-4 pb-4 md:px-6 md:pb-6">
              <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                <div className="text-sm text-muted-foreground">
                  Select a few items and generate full outfit suggestions.
                </div>
                <Button
                  onClick={runCompleteLook}
                  disabled={isLoadingComplete || completeSelection.size === 0}
                  className="w-full md:w-auto"
                >
                  {isLoadingComplete ? 'Generating…' : 'Generate'}
                </Button>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2 md:gap-3 max-h-[40vh] md:max-h-[18rem] overflow-y-auto pr-1">
                {items.map((item) => {
                  const selected = completeSelection.has(item.id)
                  return (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => toggleCompleteItem(item.id)}
                      className={cn(
                        'p-2 md:p-3 rounded-lg border text-left transition-colors touch-target',
                        selected
                          ? 'border-primary bg-primary/10'
                          : 'border-border hover:border-muted-foreground'
                      )}
                    >
                      {renderItemCard(item)}
                    </button>
                  )
                })}
              </div>

              {completeLooks.length > 0 && (
                <div className="space-y-2">
                  <div className="text-sm font-semibold text-foreground">Suggestions</div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {completeLooks.map((look) => (
                      <div key={look.items.map((it) => it.id).join('-')} className="p-3 rounded-lg border border-border">
                        <div className="flex items-center justify-between gap-3">
                          <div className="text-sm font-medium text-foreground">{look.description}</div>
                          <Badge variant="outline">{formatScore(look.match_score)}</Badge>
                        </div>
                        <div className="mt-2 space-y-2">
                          {(look.items || [])
                            .filter((it) => it?.id)
                            .slice(0, 5)
                            .map((it) => (
                            <div key={it.id}>{renderItemCard(it)}</div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {completeLooks.length === 0 && hasAttemptedComplete && !isLoadingComplete && (
                <div className="p-4 rounded-lg bg-muted text-center">
                  <div className="text-sm text-muted-foreground">
                    No outfit suggestions could be generated.
                  </div>
                  <div className="text-xs text-muted-foreground mt-1">
                    Try adding more items to your wardrobe for better suggestions.
                  </div>
                </div>
              )}

              {items.length === 0 && !isLoadingItems && (
                <div className="text-sm text-muted-foreground">
                  Add items to your wardrobe first to unlock recommendations.
                </div>
              )}
            </CardContent>
          </Card>
        )}

        {activeTab === 'weather' && (
          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="text-base md:text-lg">Weather-Based</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 px-4 pb-4 md:px-6 md:pb-6">
              <div className="flex flex-col gap-3 md:flex-row md:items-end">
                <div className="flex-1 w-full space-y-2">
                  <div className="text-sm font-medium text-foreground">Location (optional)</div>
                  <Input
                    placeholder="e.g., New York or 40.7128,-74.0060"
                    value={weatherLocation}
                    onChange={(e) => setWeatherLocation(e.target.value)}
                  />
                </div>
                <Button onClick={runWeather} disabled={isLoadingWeather} className="w-full md:w-auto">
                  {isLoadingWeather ? 'Loading…' : 'Get Recommendations'}
                </Button>
              </div>

              {weatherData && (
                <div className="space-y-3">
                  <div className="flex flex-wrap items-center gap-2 md:gap-3">
                    <Badge variant="secondary">{Math.round(weatherData.temperature)}°C</Badge>
                    <Badge variant="outline" className="capitalize">{weatherData.weather_state}</Badge>
                    <span className="text-sm text-muted-foreground capitalize">{weatherData.temp_category}</span>
                    <span className="text-xs text-muted-foreground">· current conditions for location</span>
                  </div>

                  {weatherData.notes?.length > 0 && (
                    <div className="text-sm text-foreground">
                      {weatherData.notes.join(' ')}
                    </div>
                  )}

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <div className="p-3 rounded-lg bg-muted">
                      <div className="text-sm font-semibold text-foreground mb-2">Preferred categories</div>
                      <div className="flex flex-wrap gap-2">
                        {weatherData.preferred_categories.map((c) => (
                          <Badge key={c} variant="secondary" className="capitalize">
                            {c}
                          </Badge>
                        ))}
                      </div>
                    </div>
                    <div className="p-3 rounded-lg bg-muted">
                      <div className="text-sm font-semibold text-foreground mb-2">Extra items</div>
                      <div className="flex flex-wrap gap-2">
                        {(weatherData.additional_items || []).length === 0 ? (
                          <span className="text-sm text-muted-foreground">None</span>
                        ) : (
                          weatherData.additional_items.map((x) => (
                            <Badge key={x} variant="outline">
                              {x}
                            </Badge>
                          ))
                        )}
                      </div>
                    </div>
                  </div>

                  {weatherSuggestedItems.length > 0 && (
                    <div>
                      <div className="text-sm font-semibold text-foreground mb-2">Pieces from your wardrobe</div>
                      <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                        {weatherSuggestedItems.map((item) => (
                          <div key={item.id} className="p-2 rounded-lg border border-border">
                            {renderItemCard(item)}
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}
            </CardContent>
          </Card>
        )}

        {activeTab === 'astrology' && (
          <AstrologyTab
            data={astrologyData}
            isLoading={isLoadingAstrology}
            targetDate={astrologyDate}
            mode={astrologyMode}
            onTargetDateChange={setAstrologyDate}
            onModeChange={setAstrologyMode}
            onRun={runAstrology}
          />
        )}

        {activeTab === 'shopping' && (
          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="text-base md:text-lg">Shopping Recommendations</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 px-4 pb-4 md:px-6 md:pb-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                <div className="space-y-2">
                  <div className="text-sm font-medium text-foreground">Category</div>
                  <Input
                    placeholder="e.g., tops"
                    value={shoppingCategory}
                    onChange={(e) => setShoppingCategory(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium text-foreground">Style</div>
                  <Input
                    placeholder="e.g., minimalist"
                    value={shoppingStyle}
                    onChange={(e) => setShoppingStyle(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium text-foreground">Budget</div>
                  <Input
                    placeholder="e.g., 200"
                    value={shoppingBudget}
                    onChange={(e) => setShoppingBudget(e.target.value)}
                  />
                </div>
              </div>

              <Button onClick={runShopping} disabled={isLoadingShopping} className="w-full md:w-auto">
                {isLoadingShopping ? 'Loading…' : 'Get Suggestions'}
              </Button>

              {shopping.length > 0 && (
                <div className="space-y-2">
                  {shopping.map((rec) => (
                    <div key={rec.description} className="p-3 rounded-lg border border-border">
                      <div className="flex items-center justify-between gap-3">
                        <div className="font-medium text-foreground capitalize">{rec.category}</div>
                        <Badge variant={rec.priority === 'high' ? 'default' : 'secondary'}>
                          {rec.priority}
                        </Badge>
                      </div>
                      <div className="text-sm text-muted-foreground mt-1">{rec.description}</div>
                      {rec.suggested_brands?.length ? (
                        <div className="text-xs text-muted-foreground mt-2">
                          Brands: {rec.suggested_brands.join(', ')}
                        </div>
                      ) : null}
                    </div>
                  ))}
                </div>
              )}

              {shopping.length === 0 && !isLoadingShopping && (
                <div className="text-sm text-muted-foreground">
                  Generate suggestions to see recommended items to buy.
                </div>
              )}
            </CardContent>
          </Card>
        )}
      </div>

      {/* Tips section */}
      <div className="mt-6 md:mt-8 bg-primary/10 rounded-lg p-4 md:p-6">
        <h3 className="font-medium text-primary mb-2">Pro Tips</h3>
        <ul className="text-sm text-primary/80 space-y-1">
          <li>• The more items you add, the better the recommendations become</li>
          <li>• Tag your items with styles and occasions for better matches</li>
          <li>• Mark items as favorites to prioritize them in suggestions</li>
        </ul>
      </div>
    </div>
  )
}
