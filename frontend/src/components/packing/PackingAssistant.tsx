/**
 * PackingAssistant Component
 *
 * Helps users plan what to pack for trips by generating optimized
 * packing lists from their wardrobe items.
 */

import { useState, useMemo } from 'react'
import {
  Luggage,
  MapPin,
  Calendar,
  Sun,
  Cloud,
  Snowflake,
  ThermometerSun,
  Check,
  Download,
  RefreshCw,
  Sparkles,
  AlertCircle,
  ChevronDown,
  ChevronUp,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import {
  generatePackingList,
  exportPackingList,
  type TripDetails,
  type TripActivity,
  type PackingList,
  type PackingItem,
} from '@/lib/packing-assistant'
import type { Item, Category } from '@/types'
import { cn } from '@/lib/utils'

interface PackingAssistantProps {
  items: Item[]
  onClose?: () => void
}

const ACTIVITY_OPTIONS: Array<{ value: TripActivity; label: string; icon: string }> = [
  { value: 'business', label: 'Business', icon: '💼' },
  { value: 'casual', label: 'Casual', icon: '👕' },
  { value: 'formal-dinner', label: 'Formal Dinner', icon: '🍽️' },
  { value: 'sightseeing', label: 'Sightseeing', icon: '📸' },
  { value: 'beach', label: 'Beach', icon: '🏖️' },
  { value: 'hiking', label: 'Hiking', icon: '🥾' },
  { value: 'workout', label: 'Workout', icon: '💪' },
  { value: 'nightlife', label: 'Nightlife', icon: '🌙' },
]

const CLIMATE_OPTIONS = [
  { value: 'hot', label: 'Hot', icon: Sun, color: 'text-orange-500' },
  { value: 'warm', label: 'Warm', icon: ThermometerSun, color: 'text-yellow-500' },
  { value: 'mild', label: 'Mild', icon: Cloud, color: 'text-blue-400' },
  { value: 'cold', label: 'Cold', icon: Snowflake, color: 'text-cyan-500' },
  { value: 'mixed', label: 'Mixed', icon: Cloud, color: 'text-muted-foreground' },
]

function ActivityToggle({
  activity,
  isSelected,
  onToggle,
}: {
  activity: (typeof ACTIVITY_OPTIONS)[0]
  isSelected: boolean
  onToggle: () => void
}) {
  return (
    <button
      onClick={onToggle}
      className={cn(
        'flex items-center gap-2 px-3 py-2 rounded-lg border transition-all text-sm',
        isSelected
          ? 'bg-gold-50 border-gold-300 text-gold-700 dark:bg-gold-900/30 dark:border-gold-700 dark:text-gold-300'
          : 'bg-card border-border text-foreground hover:border-muted-foreground/50'
      )}
    >
      <span>{activity.icon}</span>
      <span>{activity.label}</span>
      {isSelected && <Check className="h-3 w-3 ml-1" />}
    </button>
  )
}

function PackingItemCard({
  packingItem,
  isChecked,
  onToggle,
}: {
  packingItem: PackingItem
  isChecked: boolean
  onToggle: () => void
}) {
  const primaryImage = packingItem.item.images.find((img) => img.is_primary) || packingItem.item.images[0]

  return (
    <div
      className={cn(
        'flex items-center gap-3 p-3 rounded-lg border transition-all cursor-pointer',
        isChecked
          ? 'bg-green-50 border-green-200 dark:bg-green-900/20 dark:border-green-800'
          : 'bg-card border-border hover:border-muted-foreground/50'
      )}
      onClick={onToggle}
    >
      <div
        className={cn(
          'w-5 h-5 rounded border-2 flex items-center justify-center flex-shrink-0',
          isChecked
            ? 'bg-green-500 border-green-500'
            : 'border-border'
        )}
      >
        {isChecked && <Check className="h-3 w-3 text-white" />}
      </div>

      {primaryImage && (
        <img
          src={primaryImage.thumbnail_url || primaryImage.image_url}
          alt={packingItem.item.name}
          className="w-12 h-12 rounded object-cover"
        />
      )}

      <div className="flex-1 min-w-0">
        <p className={cn(
          'font-medium text-sm truncate',
          isChecked && 'line-through text-muted-foreground'
        )}>
          {packingItem.item.name}
        </p>
        <p className="text-xs text-muted-foreground">
          {packingItem.reason}
        </p>
      </div>

      <div className="flex items-center gap-2">
        {packingItem.isEssential && (
          <Badge variant="destructive" className="text-xs">
            Essential
          </Badge>
        )}
        <Badge variant="outline" className="text-xs capitalize">
          {packingItem.category}
        </Badge>
      </div>
    </div>
  )
}

export function PackingAssistant({ items, onClose }: PackingAssistantProps) {
  const [step, setStep] = useState<'setup' | 'results'>('setup')
  const [tripDetails, setTripDetails] = useState<TripDetails>({
    destination: '',
    startDate: '',
    endDate: '',
    climate: 'mild',
    activities: ['casual', 'sightseeing'],
    travelStyle: 'comfortable',
  })
  const [packingList, setPackingList] = useState<PackingList | null>(null)
  const [checkedItems, setCheckedItems] = useState<Set<string>>(new Set())
  const [expandedCategories, setExpandedCategories] = useState<Set<string>>(new Set(['tops', 'bottoms']))

  const toggleActivity = (activity: TripActivity) => {
    setTripDetails((prev) => ({
      ...prev,
      activities: prev.activities.includes(activity)
        ? prev.activities.filter((a) => a !== activity)
        : [...prev.activities, activity],
    }))
  }

  const handleGenerate = () => {
    if (!tripDetails.destination || !tripDetails.startDate || !tripDetails.endDate) {
      return
    }

    const list = generatePackingList(items, tripDetails)
    setPackingList(list)
    setStep('results')
    setCheckedItems(new Set())
  }

  const handleDownload = () => {
    if (!packingList) return

    const text = exportPackingList(packingList)
    const blob = new Blob([text], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `packing-list-${tripDetails.destination.toLowerCase().replace(/\s+/g, '-')}.txt`
    a.click()
    URL.revokeObjectURL(url)
  }

  const toggleCategory = (category: string) => {
    setExpandedCategories((prev) => {
      const next = new Set(prev)
      if (next.has(category)) {
        next.delete(category)
      } else {
        next.add(category)
      }
      return next
    })
  }

  const toggleItemCheck = (itemId: string) => {
    setCheckedItems((prev) => {
      const next = new Set(prev)
      if (next.has(itemId)) {
        next.delete(itemId)
      } else {
        next.add(itemId)
      }
      return next
    })
  }

  // Group items by category
  const groupedItems = useMemo(() => {
    if (!packingList) return new Map<Category, PackingItem[]>()

    const grouped = new Map<Category, PackingItem[]>()
    packingList.items.forEach((item) => {
      const existing = grouped.get(item.category) || []
      existing.push(item)
      grouped.set(item.category, existing)
    })
    return grouped
  }, [packingList])

  const packedCount = checkedItems.size
  const totalCount = packingList?.items.length || 0
  const progress = totalCount > 0 ? (packedCount / totalCount) * 100 : 0

  const isFormValid = tripDetails.destination && tripDetails.startDate && tripDetails.endDate && tripDetails.activities.length > 0

  // Setup step
  if (step === 'setup') {
    return (
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="flex items-center gap-2">
                <Luggage className="h-5 w-5 text-gold-500" />
                Packing Assistant
              </CardTitle>
              <CardDescription>
                Plan what to pack for your trip
              </CardDescription>
            </div>
            {onClose && (
              <Button variant="ghost" size="sm" onClick={onClose}>
                Close
              </Button>
            )}
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Trip Details */}
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <Label htmlFor="destination" className="flex items-center gap-2">
                <MapPin className="h-4 w-4" />
                Destination
              </Label>
              <Input
                id="destination"
                value={tripDetails.destination}
                onChange={(e) => setTripDetails((prev) => ({ ...prev, destination: e.target.value }))}
                placeholder="Paris, France"
                className="mt-1"
              />
            </div>
            <div>
              <Label className="flex items-center gap-2">
                <Calendar className="h-4 w-4" />
                Dates
              </Label>
              <div className="flex gap-2 mt-1">
                <Input
                  type="date"
                  value={tripDetails.startDate}
                  onChange={(e) => setTripDetails((prev) => ({ ...prev, startDate: e.target.value }))}
                />
                <span className="self-center text-muted-foreground">to</span>
                <Input
                  type="date"
                  value={tripDetails.endDate}
                  onChange={(e) => setTripDetails((prev) => ({ ...prev, endDate: e.target.value }))}
                />
              </div>
            </div>
          </div>

          {/* Climate */}
          <div>
            <Label>Climate</Label>
            <div className="grid grid-cols-5 gap-2 mt-2">
              {CLIMATE_OPTIONS.map((climate) => {
                const Icon = climate.icon
                return (
                  <button
                    key={climate.value}
                    onClick={() => setTripDetails((prev) => ({
                      ...prev,
                      climate: climate.value as TripDetails['climate'],
                    }))}
                    className={cn(
                      'p-3 rounded-lg border text-center transition-all',
                      tripDetails.climate === climate.value
                        ? 'bg-gold-50 border-gold-300 dark:bg-gold-900/30 dark:border-gold-700'
                        : 'bg-card border-border hover:border-muted-foreground/50'
                    )}
                  >
                    <Icon className={cn('h-5 w-5 mx-auto', climate.color)} />
                    <span className="text-xs mt-1 block">{climate.label}</span>
                  </button>
                )
              })}
            </div>
          </div>

          {/* Activities */}
          <div>
            <Label>Planned Activities</Label>
            <p className="text-xs text-muted-foreground mb-2">
              Select all that apply
            </p>
            <div className="flex flex-wrap gap-2">
              {ACTIVITY_OPTIONS.map((activity) => (
                <ActivityToggle
                  key={activity.value}
                  activity={activity}
                  isSelected={tripDetails.activities.includes(activity.value)}
                  onToggle={() => toggleActivity(activity.value)}
                />
              ))}
            </div>
          </div>

          {/* Travel Style */}
          <div>
            <Label>Packing Style</Label>
            <Select
              value={tripDetails.travelStyle}
              onValueChange={(value) => setTripDetails((prev) => ({
                ...prev,
                travelStyle: value as TripDetails['travelStyle'],
              }))}
            >
              <SelectTrigger className="mt-1">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="minimal">Minimal - Pack light, rewear items</SelectItem>
                <SelectItem value="comfortable">Comfortable - Balanced packing</SelectItem>
                <SelectItem value="comprehensive">Comprehensive - Full outfit per day</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* Generate Button */}
          <Button
            className="w-full"
            size="lg"
            onClick={handleGenerate}
            disabled={!isFormValid || items.length === 0}
          >
            <Sparkles className="h-4 w-4 mr-2" />
            Generate Packing List
          </Button>

          {items.length === 0 && (
            <p className="text-sm text-center text-muted-foreground">
              Add items to your wardrobe first to generate a packing list
            </p>
          )}
        </CardContent>
      </Card>
    )
  }

  // Results step
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle className="flex items-center gap-2">
              <Luggage className="h-5 w-5 text-gold-500" />
              Packing List for {tripDetails.destination}
            </CardTitle>
            <CardDescription>
              {tripDetails.startDate} - {tripDetails.endDate}
            </CardDescription>
          </div>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={() => setStep('setup')}>
              <RefreshCw className="h-4 w-4 mr-2" />
              Edit Trip
            </Button>
            <Button variant="outline" size="sm" onClick={handleDownload}>
              <Download className="h-4 w-4 mr-2" />
              Download
            </Button>
            {onClose && (
              <Button variant="ghost" size="sm" onClick={onClose}>
                Close
              </Button>
            )}
          </div>
        </div>
      </CardHeader>

      {packingList && (
        <CardContent className="space-y-6">
          {/* Progress */}
          <div className="p-4 rounded-lg bg-muted">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium">Packing Progress</span>
              <span className="text-sm text-muted-foreground">
                {packedCount} / {totalCount} items
              </span>
            </div>
            <Progress value={progress} className="h-2" />
          </div>

          {/* Statistics */}
          <div className="grid grid-cols-3 gap-4 text-center">
            <div className="p-3 rounded-lg bg-gold-50 dark:bg-gold-900/20">
              <p className="text-2xl font-bold text-gold-600 dark:text-gold-400">
                {packingList.statistics.totalItems}
              </p>
              <p className="text-xs text-muted-foreground">Items</p>
            </div>
            <div className="p-3 rounded-lg bg-green-50 dark:bg-green-900/20">
              <p className="text-2xl font-bold text-green-600 dark:text-green-400">
                {packingList.statistics.outfitCombinations}
              </p>
              <p className="text-xs text-muted-foreground">Outfits</p>
            </div>
            <div className="p-3 rounded-lg bg-navy-50 dark:bg-navy-900/20">
              <p className="text-2xl font-bold text-navy-600 dark:text-navy-400">
                {packingList.statistics.daysPerItem}
              </p>
              <p className="text-xs text-muted-foreground">Days/Item</p>
            </div>
          </div>

          {/* Suggestions */}
          {packingList.suggestions.length > 0 && (
            <div className="p-4 rounded-lg bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800">
              <h4 className="text-sm font-medium text-yellow-800 dark:text-yellow-300 mb-2 flex items-center gap-2">
                <AlertCircle className="h-4 w-4" />
                Items to Consider
              </h4>
              <ul className="space-y-1">
                {packingList.suggestions.map((s, i) => (
                  <li key={i} className="text-sm text-yellow-700 dark:text-yellow-400">
                    <Badge variant="outline" className="mr-2 text-xs capitalize">
                      {s.priority}
                    </Badge>
                    {s.description} - {s.reason}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Items by Category */}
          <div className="space-y-2">
            {Array.from(groupedItems.entries()).map(([category, categoryItems]) => (
              <Collapsible
                key={category}
                open={expandedCategories.has(category)}
                onOpenChange={() => toggleCategory(category)}
              >
                <CollapsibleTrigger asChild>
                  <Button variant="ghost" className="w-full justify-between h-10">
                    <span className="flex items-center gap-2 capitalize">
                      {category}
                      <Badge variant="secondary" className="text-xs">
                        {categoryItems.length}
                      </Badge>
                    </span>
                    {expandedCategories.has(category) ? (
                      <ChevronUp className="h-4 w-4" />
                    ) : (
                      <ChevronDown className="h-4 w-4" />
                    )}
                  </Button>
                </CollapsibleTrigger>
                <CollapsibleContent className="space-y-2 pt-2">
                  {categoryItems.map((item) => (
                    <PackingItemCard
                      key={item.item.id}
                      packingItem={item}
                      isChecked={checkedItems.has(item.item.id)}
                      onToggle={() => toggleItemCheck(item.item.id)}
                    />
                  ))}
                </CollapsibleContent>
              </Collapsible>
            ))}
          </div>

          {/* Outfit Ideas */}
          {packingList.outfitIdeas.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-foreground/80 mb-3">
                Outfit Ideas
              </h4>
              <div className="grid gap-2 sm:grid-cols-2">
                {packingList.outfitIdeas.map((outfit, i) => (
                  <div
                    key={i}
                    className="p-3 rounded-lg bg-gradient-to-r from-gold-50 to-navy-50 dark:from-gold-900/20 dark:to-navy-900/20 border border-gold-100 dark:border-gold-800"
                  >
                    <p className="font-medium text-sm text-gold-700 dark:text-gold-300">
                      {outfit.name}
                    </p>
                    <div className="flex flex-wrap gap-1 mt-2">
                      {packingList.items
                        .filter((pi) => outfit.itemIds.includes(pi.item.id))
                        .map((pi) => (
                          <Badge key={pi.item.id} variant="outline" className="text-xs">
                            {pi.item.name}
                          </Badge>
                        ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </CardContent>
      )}
    </Card>
  )
}

export default PackingAssistant
