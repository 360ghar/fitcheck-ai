/**
 * Recommendations Page
 * AI-powered outfit suggestions and style recommendations
 */

import { useEffect, useMemo, useState } from 'react'
import { Layers, Palette, Search, Shirt, Sparkles, TrendingUp } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { ScrollableTabs } from '@/components/ui/scrollable-tabs'
import { useToast } from '@/components/ui/use-toast'
import { ItemImage } from '@/components/ui/item-image'
import { cn } from '@/lib/utils'
import { generateFallbackOutfits } from '@/lib/outfit-generator'

import { useWardrobeStore } from '@/stores/wardrobeStore'
import {
  findMatchingItems,
  getCompleteLookSuggestions,
  getShoppingRecommendations,
  getWeatherRecommendations,
} from '@/api/recommendations'
import type { CompleteLookSuggestion, MatchResult, Item } from '@/types'

type TabType = 'match' | 'complete' | 'weather' | 'shopping'

/**
 * Enrich an item with images from the wardrobe store
 * The recommendations API returns items without images for performance,
 * so we look up the full item data from the local store
 */
const enrichItemWithImages = (item: Item, wardrobeItems: Item[]): Item => {
  // If item already has images, return as-is
  if (item.images && item.images.length > 0) {
    return item
  }

  // Look up the full item from wardrobe store
  const fullItem = wardrobeItems.find(w => w.id === item.id)
  if (fullItem?.images && fullItem.images.length > 0) {
    return { ...item, images: fullItem.images }
  }

  return item
}

export default function RecommendationsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('match')
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
  const [matchData, setMatchData] = useState<{ matches: MatchResult[]; complete_looks: CompleteLookSuggestion[] } | null>(null)
  const [isLoadingMatch, setIsLoadingMatch] = useState(false)

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
        const selectedItems = items.filter((item) => ids.includes(item.id))
        looks = generateFallbackOutfits(selectedItems, items, 6)
      }

      setCompleteLooks(looks)
    } catch (err) {
      // On API error, try fallback
      const selectedItems = items.filter((item) => ids.includes(item.id))
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

  const tabs = [
    { id: 'match' as TabType, name: 'Find Matches', icon: Shirt },
    { id: 'complete' as TabType, name: 'Complete Look', icon: Layers },
    { id: 'weather' as TabType, name: 'Weather-Based', icon: TrendingUp },
    { id: 'shopping' as TabType, name: 'Shopping', icon: Palette },
  ]

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

      {/* Scrollable Tabs for mobile, regular tabs for desktop */}
      <ScrollableTabs className="mb-4 md:mb-6">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={cn(
              'flex items-center gap-2 px-4 py-3 md:py-4 text-sm font-medium whitespace-nowrap transition-colors touch-target border-b-2 scroll-snap-start min-w-[100px] justify-center',
              activeTab === tab.id
                ? 'border-primary text-primary'
                : 'border-transparent text-muted-foreground hover:text-foreground hover:border-border'
            )}
          >
            <tab.icon className="h-4 w-4" />
            <span className="hidden xs:inline">{tab.name}</span>
            <span className="xs:hidden">{tab.name.split(' ')[0]}</span>
          </button>
        ))}
      </ScrollableTabs>

      {/* Tab content */}
      <div className="space-y-4">
        {activeTab === 'match' && (
          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="text-base md:text-lg">Find Matches</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 px-4 pb-4 md:px-6 md:pb-6">
              <div className="flex flex-col gap-3 md:flex-row md:items-end">
                <div className="flex-1 w-full space-y-2">
                  <div className="text-sm font-medium text-foreground">Pick an item</div>
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                    <select
                      className="w-full h-12 pl-9 pr-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground appearance-none"
                      value={matchItemId}
                      onChange={(e) => setMatchItemId(e.target.value)}
                      disabled={isLoadingItems}
                    >
                      <option value="">Select an item…</option>
                      {items.map((item) => (
                        <option key={item.id} value={item.id}>
                          {item.name} ({item.category})
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                <Button
                  onClick={() => runMatch(matchItemId)}
                  disabled={!matchItemId || isLoadingMatch}
                  className="w-full md:w-auto"
                >
                  {isLoadingMatch ? 'Finding…' : 'Find Matches'}
                </Button>
              </div>

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
                      <div className="flex overflow-x-auto gap-3 pb-2 md:grid md:grid-cols-1 md:overflow-visible md:gap-2">
                        {matchData.matches
                          .filter((m) => m.item?.id)
                          .slice(0, 10)
                          .map((m, idx) => (
                          <div key={`${m.item.id}-${idx}`} className="p-3 rounded-lg border border-border min-w-[200px] md:min-w-0">
                            <div className="flex items-start justify-between gap-3">
                              <div className="min-w-0">{renderItemCard(m.item)}</div>
                              <Badge variant="secondary">{m.score}</Badge>
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
                      <div className="flex overflow-x-auto gap-3 pb-2 md:grid md:grid-cols-1 md:overflow-visible md:gap-2">
                        {matchData.complete_looks.slice(0, 4).map((look, idx) => (
                          <div key={idx} className="p-3 rounded-lg border border-border min-w-[250px] md:min-w-0">
                            <div className="flex items-center justify-between gap-3">
                              <div className="text-sm font-medium text-foreground">{look.description}</div>
                              <Badge variant="outline">{look.match_score}</Badge>
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

              {items.length === 0 && !isLoadingItems && (
                <div className="text-sm text-muted-foreground">
                  Add items to your wardrobe first to unlock recommendations.
                </div>
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

              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2 md:gap-3 max-h-[18rem] overflow-y-auto pr-1">
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
                    {completeLooks.map((look, idx) => (
                      <div key={idx} className="p-3 rounded-lg border border-border">
                        <div className="flex items-center justify-between gap-3">
                          <div className="text-sm font-medium text-foreground">{look.description}</div>
                          <Badge variant="outline">{look.match_score}</Badge>
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
                </div>
              )}
            </CardContent>
          </Card>
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
                  {shopping.map((rec, idx) => (
                    <div key={idx} className="p-3 rounded-lg border border-border">
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
