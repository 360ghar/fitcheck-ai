import { Link } from 'react-router-dom'
import { CalendarDays, Sparkles, Stars } from 'lucide-react'

import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ItemImage } from '@/components/ui/item-image'
import type { AstrologyRecommendation, AstrologyRecommendationMode, Item } from '@/types'

interface AstrologyTabProps {
  data: AstrologyRecommendation | null
  isLoading: boolean
  targetDate: string
  mode: AstrologyRecommendationMode
  onTargetDateChange: (value: string) => void
  onModeChange: (value: AstrologyRecommendationMode) => void
  onRun: () => Promise<void> | void
}

function normalizeItem(item: Item): Item {
  const rawItem = item as Item & {
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

  if (Array.isArray(rawItem.images) && rawItem.images.length > 0) {
    return rawItem
  }

  if (!Array.isArray(rawItem.item_images) || rawItem.item_images.length === 0) {
    return rawItem
  }

  return {
    ...rawItem,
    images: rawItem.item_images.map((img, index) => ({
      id: img.id || `${rawItem.id}-img-${index}`,
      item_id: rawItem.id,
      image_url: img.image_url || '',
      thumbnail_url: img.thumbnail_url,
      is_primary: Boolean(img.is_primary),
      width: img.width,
      height: img.height,
      created_at: img.created_at || new Date().toISOString(),
    })),
  }
}

function safeItems(items: Item[] | undefined): Item[] {
  if (!Array.isArray(items)) return []
  return items.filter((item) => item?.id).map(normalizeItem)
}

export function AstrologyTab({
  data,
  isLoading,
  targetDate,
  mode,
  onTargetDateChange,
  onModeChange,
  onRun,
}: AstrologyTabProps) {
  const outfitNameById = new Map<string, string>()
  for (const group of data?.wardrobe_picks || []) {
    for (const item of safeItems(group.items)) {
      outfitNameById.set(item.id, item.name)
    }
  }

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader className="px-4 py-3 md:px-6 md:py-4">
          <CardTitle className="text-base md:text-lg flex items-center gap-2">
            <Stars className="h-4 w-4 text-primary" />
            Astrology Color Guide
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4 px-4 pb-4 md:px-6 md:pb-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
            <div>
              <label className="block text-sm font-medium text-foreground mb-1">Recommendation Type</label>
              <select
                value={mode}
                onChange={(e) => onModeChange(e.target.value as AstrologyRecommendationMode)}
                className="w-full h-11 px-3 border border-border rounded-md bg-background text-foreground"
              >
                <option value="daily">Daily</option>
                <option value="important_meeting">Important Meeting</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-foreground mb-1">Target Date</label>
              <div className="relative">
                <CalendarDays className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <input
                  type="date"
                  value={targetDate}
                  onChange={(e) => onTargetDateChange(e.target.value)}
                  className="w-full h-11 pl-9 pr-3 border border-border rounded-md bg-background text-foreground"
                />
              </div>
            </div>

            <div className="flex items-end">
              <Button onClick={onRun} disabled={isLoading || !targetDate} className="w-full">
                {isLoading ? 'Checking…' : 'Get Astrology Colors'}
              </Button>
            </div>
          </div>

          {isLoading && <div className="text-sm text-muted-foreground">Generating Vedic-style color guidance…</div>}
        </CardContent>
      </Card>

      {!isLoading && data?.status === 'profile_required' && (
        <Card>
          <CardContent className="pt-6">
            <div className="space-y-3">
              <div className="text-sm text-muted-foreground">
                Add your date of birth to unlock astrology recommendations.
              </div>
              {Array.isArray(data.notes) && data.notes.length > 0 && (
                <div className="text-xs text-muted-foreground space-y-1">
                  {data.notes.map((note, index) => (
                    <p key={`${note}-${index}`}>{note}</p>
                  ))}
                </div>
              )}
              <Button asChild>
                <Link to="/settings?tab=profile">Complete Profile</Link>
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {!isLoading && data?.status === 'ready' && (
        <>
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">
            <Card>
              <CardHeader className="px-4 py-3 md:px-6 md:py-4">
                <CardTitle className="text-base md:text-lg flex items-center gap-2">
                  <Sparkles className="h-4 w-4 text-primary" />
                  Lucky Colors
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 px-4 pb-4 md:px-6 md:pb-6">
                {data.lucky_colors.map((color) => (
                  <div key={color.name} className="flex items-center justify-between gap-3 p-3 border border-border rounded-md">
                    <div className="flex items-center gap-3 min-w-0">
                      <div
                        className="w-6 h-6 rounded-full border border-border"
                        style={{ backgroundColor: color.hex }}
                      />
                      <div className="min-w-0">
                        <div className="text-sm font-medium text-foreground truncate">{color.name}</div>
                        <div className="text-xs text-muted-foreground truncate">{color.reason}</div>
                      </div>
                    </div>
                    <Badge variant="secondary">{Math.round(color.confidence * 100)}%</Badge>
                  </div>
                ))}
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="px-4 py-3 md:px-6 md:py-4">
                <CardTitle className="text-base md:text-lg">Lower-Priority Colors</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 px-4 pb-4 md:px-6 md:pb-6">
                {data.avoid_colors.length === 0 ? (
                  <div className="text-sm text-muted-foreground">No avoid colors for this day.</div>
                ) : (
                  data.avoid_colors.map((color) => (
                    <div key={color.name} className="flex items-center justify-between gap-3 p-3 border border-border rounded-md">
                      <div className="flex items-center gap-3 min-w-0">
                        <div
                          className="w-6 h-6 rounded-full border border-border"
                          style={{ backgroundColor: color.hex }}
                        />
                        <div className="min-w-0">
                          <div className="text-sm font-medium text-foreground truncate">{color.name}</div>
                          <div className="text-xs text-muted-foreground truncate">{color.reason}</div>
                        </div>
                      </div>
                      <Badge variant="outline">{Math.round(color.confidence * 100)}%</Badge>
                    </div>
                  ))
                )}
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="text-base md:text-lg">Wardrobe Picks</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 px-4 pb-4 md:px-6 md:pb-6">
              {data.wardrobe_picks.length === 0 ? (
                <div className="text-sm text-muted-foreground">
                  No matching wardrobe items found. Add more tagged items and try again.
                </div>
              ) : (
                data.wardrobe_picks.map((group) => (
                  <div key={group.category} className="space-y-2">
                    <div className="text-sm font-semibold text-foreground capitalize">{group.category}</div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
                      {safeItems(group.items).map((item) => (
                        <div key={item.id} className="p-2 border border-border rounded-md flex items-center gap-3">
                          <ItemImage item={item} size="sm" />
                          <div className="min-w-0">
                            <div className="text-sm font-medium text-foreground truncate">{item.name}</div>
                            <div className="text-xs text-muted-foreground capitalize truncate">{item.category}</div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                ))
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="px-4 py-3 md:px-6 md:py-4">
              <CardTitle className="text-base md:text-lg">Suggested Outfits</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 px-4 pb-4 md:px-6 md:pb-6">
              {data.suggested_outfits.length === 0 ? (
                <div className="text-sm text-muted-foreground">No complete outfit could be assembled yet.</div>
              ) : (
                data.suggested_outfits.map((outfit, index) => (
                  <div key={`${outfit.description}-${index}`} className="p-3 border border-border rounded-md">
                    <div className="flex items-center justify-between gap-3">
                      <div className="text-sm font-medium text-foreground">{outfit.description}</div>
                      <Badge>{outfit.match_score}</Badge>
                    </div>
                    <div className="mt-2 text-xs text-muted-foreground">
                      {outfit.item_ids.map((id) => outfitNameById.get(id) || id).join(' • ')}
                    </div>
                  </div>
                ))
              )}
            </CardContent>
          </Card>
        </>
      )}
    </div>
  )
}

export default AstrologyTab
