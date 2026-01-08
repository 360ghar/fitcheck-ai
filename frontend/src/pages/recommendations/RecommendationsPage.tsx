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
import { useToast } from '@/components/ui/use-toast'

import { useWardrobeStore } from '@/stores/wardrobeStore'
import {
  findMatchingItems,
  getCompleteLookSuggestions,
  getShoppingRecommendations,
  getWeatherRecommendations,
} from '@/api/recommendations'
import type { CompleteLookSuggestion, MatchResult, Item } from '@/types'

type TabType = 'match' | 'complete' | 'weather' | 'shopping'

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
    try {
      const looks = await getCompleteLookSuggestions(ids, { limit: 6 })
      setCompleteLooks(looks)
    } catch (err) {
      toast({
        title: 'Failed to generate complete looks',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
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

  const renderItemCard = (item: Item) => (
    <div className="flex items-center gap-3">
      {item.images?.length ? (
        <img
          src={item.images[0].thumbnail_url || item.images[0].image_url}
          alt={item.name}
          className="h-10 w-10 rounded-lg object-cover"
        />
      ) : (
        <div className="h-10 w-10 rounded-lg bg-gray-100 dark:bg-gray-700 flex items-center justify-center text-gray-400 dark:text-gray-500 text-xs">
          {item.category}
        </div>
      )}
      <div className="min-w-0">
        <div className="text-sm font-medium text-gray-900 dark:text-white truncate">{item.name}</div>
        <div className="text-xs text-gray-500 dark:text-gray-400 capitalize truncate">{item.category}</div>
      </div>
    </div>
  )

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center">
          <Sparkles className="h-7 w-7 text-purple-600 dark:text-purple-400 mr-2" />
          AI Recommendations
        </h1>
        <p className="mt-2 text-gray-600 dark:text-gray-400">
          Get personalized outfit suggestions powered by AI
        </p>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200 dark:border-gray-700 mb-6">
        <nav className="flex space-x-8">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center px-1 py-4 border-b-2 font-medium text-sm transition-colors ${
                activeTab === tab.id
                  ? 'border-purple-500 text-purple-600 dark:text-purple-400'
                  : 'border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300 dark:hover:border-gray-600'
              }`}
            >
              <tab.icon className="h-4 w-4 mr-2" />
              {tab.name}
            </button>
          ))}
        </nav>
      </div>

      {/* Tab content */}
      <div className="space-y-4">
        {activeTab === 'match' && (
          <Card>
            <CardHeader>
              <CardTitle>Find Matches</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-end">
                <div className="flex-1 w-full space-y-2">
                  <div className="text-sm font-medium text-gray-700 dark:text-gray-300">Pick an item</div>
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 dark:text-gray-500" />
                    <select
                      className="w-full pl-9 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-sm bg-white dark:bg-gray-800 text-gray-900 dark:text-white"
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
                >
                  {isLoadingMatch ? 'Finding…' : 'Find Matches'}
                </Button>
              </div>

              {selectedMatchItem && (
                <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-800">
                  <div className="text-sm text-gray-600 dark:text-gray-400 mb-2">Selected</div>
                  {renderItemCard(selectedMatchItem)}
                </div>
              )}

              {matchData && (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <div className="text-sm font-semibold text-gray-900 dark:text-white">Matching items</div>
                    {matchData.matches.length === 0 ? (
                      <div className="text-sm text-gray-600 dark:text-gray-400">No matches found.</div>
                    ) : (
                      <div className="space-y-2">
                        {matchData.matches.slice(0, 10).map((m, idx) => (
                          <div key={`${m.item?.id || idx}-${idx}`} className="p-3 rounded-lg border border-gray-200 dark:border-gray-700">
                            <div className="flex items-start justify-between gap-3">
                              <div className="min-w-0">{renderItemCard(m.item as Item)}</div>
                              <Badge variant="secondary">{m.score}</Badge>
                            </div>
                            {m.reasons?.length > 0 && (
                              <div className="mt-2 text-xs text-gray-600 dark:text-gray-400">
                                {m.reasons.join(' • ')}
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  <div className="space-y-2">
                    <div className="text-sm font-semibold text-gray-900 dark:text-white">Complete looks</div>
                    {matchData.complete_looks.length === 0 ? (
                      <div className="text-sm text-gray-600 dark:text-gray-400">No complete looks yet.</div>
                    ) : (
                      <div className="space-y-2">
                        {matchData.complete_looks.slice(0, 4).map((look, idx) => (
                          <div key={idx} className="p-3 rounded-lg border border-gray-200 dark:border-gray-700">
                            <div className="flex items-center justify-between gap-3">
                              <div className="text-sm font-medium text-gray-900 dark:text-white">{look.description}</div>
                              <Badge variant="outline">{look.match_score}</Badge>
                            </div>
                            <div className="mt-2 space-y-2">
                              {look.items.slice(0, 4).map((it) => (
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
                <div className="text-sm text-gray-600 dark:text-gray-400">
                  Add items to your wardrobe first to unlock recommendations.
                </div>
              )}
            </CardContent>
          </Card>
        )}

        {activeTab === 'complete' && (
          <Card>
            <CardHeader>
              <CardTitle>Complete Look</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between gap-3">
                <div className="text-sm text-gray-600 dark:text-gray-400">
                  Select a few items and generate full outfit suggestions.
                </div>
                <Button onClick={runCompleteLook} disabled={isLoadingComplete || completeSelection.size === 0}>
                  {isLoadingComplete ? 'Generating…' : 'Generate'}
                </Button>
              </div>

              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3 max-h-[18rem] overflow-y-auto pr-1">
                {items.map((item) => {
                  const selected = completeSelection.has(item.id)
                  return (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => toggleCompleteItem(item.id)}
                      className={`p-3 rounded-lg border text-left transition-colors ${
                        selected ? 'border-purple-500 bg-purple-50 dark:bg-purple-900/20' : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                      }`}
                    >
                      {renderItemCard(item)}
                    </button>
                  )
                })}
              </div>

              {completeLooks.length > 0 && (
                <div className="space-y-2">
                  <div className="text-sm font-semibold text-gray-900 dark:text-white">Suggestions</div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {completeLooks.map((look, idx) => (
                      <div key={idx} className="p-3 rounded-lg border border-gray-200 dark:border-gray-700">
                        <div className="flex items-center justify-between gap-3">
                          <div className="text-sm font-medium text-gray-900 dark:text-white">{look.description}</div>
                          <Badge variant="outline">{look.match_score}</Badge>
                        </div>
                        <div className="mt-2 space-y-2">
                          {look.items.slice(0, 5).map((it) => (
                            <div key={it.id}>{renderItemCard(it)}</div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        )}

        {activeTab === 'weather' && (
          <Card>
            <CardHeader>
              <CardTitle>Weather-Based</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-end">
                <div className="flex-1 w-full space-y-2">
                  <div className="text-sm font-medium text-gray-700 dark:text-gray-300">Location (optional)</div>
                  <Input
                    placeholder="e.g., New York or 40.7128,-74.0060"
                    value={weatherLocation}
                    onChange={(e) => setWeatherLocation(e.target.value)}
                  />
                </div>
                <Button onClick={runWeather} disabled={isLoadingWeather}>
                  {isLoadingWeather ? 'Loading…' : 'Get Recommendations'}
                </Button>
              </div>

              {weatherData && (
                <div className="space-y-3">
                  <div className="flex items-center gap-3">
                    <Badge variant="secondary">{Math.round(weatherData.temperature)}°C</Badge>
                    <Badge variant="outline" className="capitalize">{weatherData.weather_state}</Badge>
                    <span className="text-sm text-gray-600 dark:text-gray-400 capitalize">{weatherData.temp_category}</span>
                  </div>

                  {weatherData.notes?.length > 0 && (
                    <div className="text-sm text-gray-700 dark:text-gray-300">
                      {weatherData.notes.join(' ')}
                    </div>
                  )}

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-800">
                      <div className="text-sm font-semibold text-gray-900 dark:text-white mb-2">Preferred categories</div>
                      <div className="flex flex-wrap gap-2">
                        {weatherData.preferred_categories.map((c) => (
                          <Badge key={c} variant="secondary" className="capitalize">
                            {c}
                          </Badge>
                        ))}
                      </div>
                    </div>
                    <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-800">
                      <div className="text-sm font-semibold text-gray-900 dark:text-white mb-2">Extra items</div>
                      <div className="flex flex-wrap gap-2">
                        {(weatherData.additional_items || []).length === 0 ? (
                          <span className="text-sm text-gray-600 dark:text-gray-400">None</span>
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
            <CardHeader>
              <CardTitle>Shopping Recommendations</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div className="space-y-2">
                  <div className="text-sm font-medium text-gray-700 dark:text-gray-300">Category</div>
                  <Input
                    placeholder="e.g., tops"
                    value={shoppingCategory}
                    onChange={(e) => setShoppingCategory(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium text-gray-700 dark:text-gray-300">Style</div>
                  <Input
                    placeholder="e.g., minimalist"
                    value={shoppingStyle}
                    onChange={(e) => setShoppingStyle(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium text-gray-700 dark:text-gray-300">Budget</div>
                  <Input
                    placeholder="e.g., 200"
                    value={shoppingBudget}
                    onChange={(e) => setShoppingBudget(e.target.value)}
                  />
                </div>
              </div>

              <Button onClick={runShopping} disabled={isLoadingShopping}>
                {isLoadingShopping ? 'Loading…' : 'Get Suggestions'}
              </Button>

              {shopping.length > 0 && (
                <div className="space-y-2">
                  {shopping.map((rec, idx) => (
                    <div key={idx} className="p-3 rounded-lg border border-gray-200 dark:border-gray-700">
                      <div className="flex items-center justify-between gap-3">
                        <div className="font-medium text-gray-900 dark:text-white capitalize">{rec.category}</div>
                        <Badge variant={rec.priority === 'high' ? 'default' : 'secondary'}>
                          {rec.priority}
                        </Badge>
                      </div>
                      <div className="text-sm text-gray-700 dark:text-gray-300 mt-1">{rec.description}</div>
                      {rec.suggested_brands?.length ? (
                        <div className="text-xs text-gray-500 dark:text-gray-400 mt-2">
                          Brands: {rec.suggested_brands.join(', ')}
                        </div>
                      ) : null}
                    </div>
                  ))}
                </div>
              )}

              {shopping.length === 0 && !isLoadingShopping && (
                <div className="text-sm text-gray-600 dark:text-gray-400">
                  Generate suggestions to see recommended items to buy.
                </div>
              )}
            </CardContent>
          </Card>
        )}
      </div>

      {/* Tips section */}
      <div className="mt-8 bg-purple-50 dark:bg-purple-900/20 rounded-lg p-6">
        <h3 className="font-medium text-purple-900 dark:text-purple-200 mb-2">Pro Tips</h3>
        <ul className="text-sm text-purple-800 dark:text-purple-300 space-y-1">
          <li>• The more items you add, the better the recommendations become</li>
          <li>• Tag your items with styles and occasions for better matches</li>
          <li>• Mark items as favorites to prioritize them in suggestions</li>
        </ul>
      </div>
    </div>
  )
}
