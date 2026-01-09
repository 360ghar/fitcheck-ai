/**
 * Wardrobe Stats Component
 *
 * Displays fun and insightful wardrobe statistics.
 */

import { useState, useMemo } from 'react'
import {
  TrendingUp,
  DollarSign,
  Shirt,
  Palette,
  Award,
  Leaf,
  ChevronDown,
  ChevronUp,
  Sparkles,
  BarChart3,
  Zap,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { cn } from '@/lib/utils'
import type { Item, Outfit } from '@/types'
import {
  type WardrobeStats as WardrobeStatsType,
  type FunFact,
  calculateWardrobeStats,
} from '@/lib/wardrobe-stats'

// ============================================================================
// TYPES
// ============================================================================

interface WardrobeStatsProps {
  items: Item[]
  outfits: Outfit[]
  variant?: 'full' | 'compact' | 'dashboard'
  className?: string
}

// ============================================================================
// SUB-COMPONENTS
// ============================================================================

function StatCard({
  icon: Icon,
  label,
  value,
  subtext,
  trend,
  className,
}: {
  icon: typeof TrendingUp
  label: string
  value: string | number
  subtext?: string
  trend?: 'up' | 'down' | 'neutral'
  className?: string
}) {
  return (
    <div className={cn('p-4 rounded-xl bg-muted/50 border', className)}>
      <div className="flex items-start justify-between">
        <div className="p-2 rounded-lg bg-primary/10">
          <Icon className="w-5 h-5 text-primary" />
        </div>
        {trend && (
          <TrendingUp
            className={cn(
              'w-4 h-4',
              trend === 'up' && 'text-green-500',
              trend === 'down' && 'text-red-500 rotate-180',
              trend === 'neutral' && 'text-muted-foreground'
            )}
          />
        )}
      </div>
      <div className="mt-3">
        <p className="text-2xl font-bold">{value}</p>
        <p className="text-sm text-muted-foreground">{label}</p>
        {subtext && <p className="text-xs text-muted-foreground mt-1">{subtext}</p>}
      </div>
    </div>
  )
}

function FunFactCard({ fact }: { fact: FunFact }) {
  const bgColors = {
    achievement: 'bg-yellow-50 dark:bg-yellow-950 border-yellow-200 dark:border-yellow-800',
    insight: 'bg-blue-50 dark:bg-blue-950 border-blue-200 dark:border-blue-800',
    fun: 'bg-purple-50 dark:bg-purple-950 border-purple-200 dark:border-purple-800',
    tip: 'bg-green-50 dark:bg-green-950 border-green-200 dark:border-green-800',
  }

  return (
    <div className={cn('p-4 rounded-xl border', bgColors[fact.category])}>
      <div className="flex items-start gap-3">
        <span className="text-2xl">{fact.emoji}</span>
        <div>
          <p className="font-semibold">{fact.title}</p>
          <p className="text-sm text-muted-foreground">{fact.description}</p>
        </div>
      </div>
    </div>
  )
}

function ColorPaletteDisplay({
  colors,
}: {
  colors: { color: string; hexApprox: string; percentage: number }[]
}) {
  return (
    <div className="space-y-3">
      <div className="flex gap-1 h-8 rounded-lg overflow-hidden">
        {colors.map((c) => (
          <div
            key={c.color}
            className="h-full transition-all hover:scale-y-110"
            style={{
              backgroundColor: c.hexApprox,
              width: `${Math.max(c.percentage, 5)}%`,
            }}
            title={`${c.color}: ${c.percentage}%`}
          />
        ))}
      </div>
      <div className="flex flex-wrap gap-2">
        {colors.slice(0, 6).map((c) => (
          <div key={c.color} className="flex items-center gap-1.5">
            <div
              className="w-3 h-3 rounded-full border"
              style={{ backgroundColor: c.hexApprox }}
            />
            <span className="text-xs capitalize">{c.color}</span>
          </div>
        ))}
      </div>
    </div>
  )
}

function CategoryBreakdown({
  categories,
}: {
  categories: WardrobeStatsType['categoryBreakdown']
}) {
  const maxCount = Math.max(...categories.map((c) => c.count))

  return (
    <div className="space-y-3">
      {categories.map((cat) => (
        <div key={cat.category} className="space-y-1">
          <div className="flex items-center justify-between text-sm">
            <span className="capitalize">{cat.category}</span>
            <span className="text-muted-foreground">
              {cat.count} ({cat.percentage}%)
            </span>
          </div>
          <div className="h-2 bg-muted rounded-full overflow-hidden">
            <div
              className="h-full bg-primary rounded-full transition-all"
              style={{ width: `${(cat.count / maxCount) * 100}%` }}
            />
          </div>
        </div>
      ))}
    </div>
  )
}

function StylePersonalityCard({
  personality,
  styleBreakdown,
}: {
  personality: string
  styleBreakdown: WardrobeStatsType['styleBreakdown']
}) {
  return (
    <div className="p-4 rounded-xl bg-gradient-to-br from-primary/10 to-primary/5 border">
      <div className="flex items-center gap-2 mb-3">
        <Sparkles className="w-5 h-5 text-primary" />
        <span className="font-semibold">Your Style Personality</span>
      </div>
      <p className="text-2xl font-bold mb-2">{personality}</p>
      <div className="flex flex-wrap gap-2 mt-3">
        {styleBreakdown.slice(0, 4).map((s) => (
          <Badge key={s.style} variant="secondary" className="capitalize">
            {s.style} ({s.percentage}%)
          </Badge>
        ))}
      </div>
    </div>
  )
}

function SustainabilityScore({ score, carbonSavings }: { score: number; carbonSavings: number }) {
  const getScoreColor = () => {
    if (score >= 70) return 'text-green-600'
    if (score >= 40) return 'text-yellow-600'
    return 'text-red-600'
  }

  const getScoreLabel = () => {
    if (score >= 70) return 'Excellent'
    if (score >= 40) return 'Good'
    return 'Needs Work'
  }

  return (
    <div className="p-4 rounded-xl bg-green-50 dark:bg-green-950 border border-green-200 dark:border-green-800">
      <div className="flex items-center gap-2 mb-3">
        <Leaf className="w-5 h-5 text-green-600" />
        <span className="font-semibold">Sustainability Score</span>
      </div>
      <div className="flex items-baseline gap-2">
        <span className={cn('text-3xl font-bold', getScoreColor())}>{score}</span>
        <span className="text-sm text-muted-foreground">/ 100</span>
        <Badge
          variant="outline"
          className={cn(
            'ml-auto',
            score >= 70 && 'border-green-500 text-green-700',
            score >= 40 && score < 70 && 'border-yellow-500 text-yellow-700',
            score < 40 && 'border-red-500 text-red-700'
          )}
        >
          {getScoreLabel()}
        </Badge>
      </div>
      <Progress value={score} className="mt-3 h-2" />
      <p className="text-sm text-muted-foreground mt-3">
        Estimated carbon savings: <strong>{carbonSavings} kg CO2</strong> from rewearing items
      </p>
    </div>
  )
}

function ChampionItems({ stats }: { stats: WardrobeStatsType }) {
  const champions = [
    { label: 'Most Worn', item: stats.mostWornItem, icon: '👑', stat: stats.mostWornItem?.usage_times_worn + ' wears' },
    { label: 'Best Value', item: stats.bestValueItem, icon: '💰', stat: stats.bestValueItem ? `$${(stats.bestValueItem.purchase_price! / stats.bestValueItem.usage_times_worn).toFixed(2)}/wear` : '' },
    { label: 'Most Versatile', item: stats.mostVersatileItem, icon: '⚡', stat: 'Multi-outfit hero' },
    { label: 'Premium Piece', item: stats.mostExpensiveItem, icon: '💎', stat: stats.mostExpensiveItem?.purchase_price ? `$${stats.mostExpensiveItem.purchase_price}` : '' },
  ].filter((c) => c.item)

  if (champions.length === 0) return null

  return (
    <div className="space-y-3">
      <h3 className="font-semibold flex items-center gap-2">
        <Award className="w-4 h-4" />
        Wardrobe Champions
      </h3>
      <div className="grid gap-2">
        {champions.map((champ) => (
          <div
            key={champ.label}
            className="flex items-center gap-3 p-3 rounded-lg bg-muted/50 border"
          >
            <span className="text-xl">{champ.icon}</span>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium truncate">{champ.item?.name}</p>
              <p className="text-xs text-muted-foreground">{champ.label}</p>
            </div>
            <Badge variant="outline" className="shrink-0">
              {champ.stat}
            </Badge>
          </div>
        ))}
      </div>
    </div>
  )
}

// ============================================================================
// MAIN COMPONENT
// ============================================================================

export function WardrobeStats({
  items,
  outfits,
  variant = 'full',
  className,
}: WardrobeStatsProps) {
  const [showMore, setShowMore] = useState(false)

  const stats = useMemo(() => calculateWardrobeStats(items, outfits), [items, outfits])

  // Dashboard variant - minimal stats
  if (variant === 'dashboard') {
    return (
      <div className={cn('grid grid-cols-2 sm:grid-cols-4 gap-3', className)}>
        <StatCard
          icon={Shirt}
          label="Items"
          value={stats.totalItems}
        />
        <StatCard
          icon={BarChart3}
          label="Outfits"
          value={stats.totalOutfits}
        />
        <StatCard
          icon={DollarSign}
          label="Total Value"
          value={`$${stats.totalValue.toLocaleString()}`}
        />
        <StatCard
          icon={Zap}
          label="Avg Wears"
          value={stats.averageWearsPerItem}
        />
      </div>
    )
  }

  // Compact variant
  if (variant === 'compact') {
    return (
      <div className={cn('space-y-4', className)}>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <StatCard icon={Shirt} label="Items" value={stats.totalItems} />
          <StatCard icon={BarChart3} label="Outfits" value={stats.totalOutfits} />
          <StatCard
            icon={DollarSign}
            label="Value"
            value={`$${Math.round(stats.totalValue).toLocaleString()}`}
          />
          <StatCard icon={Leaf} label="Sustainability" value={stats.sustainabilityScore} />
        </div>

        {stats.funFacts.slice(0, 2).map((fact) => (
          <FunFactCard key={fact.id} fact={fact} />
        ))}
      </div>
    )
  }

  // Full variant
  return (
    <div className={cn('space-y-6', className)}>
      {/* Header Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <StatCard
          icon={Shirt}
          label="Total Items"
          value={stats.totalItems}
          subtext={`${stats.dormantItems.length} dormant`}
        />
        <StatCard
          icon={BarChart3}
          label="Outfits"
          value={stats.totalOutfits}
          subtext={`${stats.workhorseItems.length} workhorse items`}
        />
        <StatCard
          icon={DollarSign}
          label="Wardrobe Value"
          value={`$${stats.totalValue.toLocaleString()}`}
          subtext={`$${stats.averageCostPerWear.toFixed(2)} avg CPW`}
        />
        <StatCard
          icon={TrendingUp}
          label="Total Wears"
          value={stats.totalWears.toLocaleString()}
          subtext={`${stats.averageWearsPerItem} per item`}
        />
      </div>

      {/* Style Personality */}
      <StylePersonalityCard
        personality={stats.stylePersonality}
        styleBreakdown={stats.styleBreakdown}
      />

      {/* Fun Facts */}
      <div className="space-y-3">
        <h3 className="font-semibold flex items-center gap-2">
          <Sparkles className="w-4 h-4" />
          Fun Facts
        </h3>
        <div className="grid sm:grid-cols-2 gap-3">
          {stats.funFacts.slice(0, showMore ? undefined : 4).map((fact) => (
            <FunFactCard key={fact.id} fact={fact} />
          ))}
        </div>
        {stats.funFacts.length > 4 && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setShowMore(!showMore)}
            className="w-full"
          >
            {showMore ? (
              <>
                <ChevronUp className="w-4 h-4 mr-2" />
                Show Less
              </>
            ) : (
              <>
                <ChevronDown className="w-4 h-4 mr-2" />
                Show More ({stats.funFacts.length - 4} more)
              </>
            )}
          </Button>
        )}
      </div>

      {/* Two Column Layout */}
      <div className="grid md:grid-cols-2 gap-6">
        {/* Color Palette */}
        <div className="space-y-3">
          <h3 className="font-semibold flex items-center gap-2">
            <Palette className="w-4 h-4" />
            Color Palette
          </h3>
          <ColorPaletteDisplay colors={stats.colorPalette} />
          <p className="text-sm text-muted-foreground">
            Color diversity score: <strong>{stats.colorDiversity}/100</strong>
          </p>
        </div>

        {/* Category Breakdown */}
        <div className="space-y-3">
          <h3 className="font-semibold flex items-center gap-2">
            <BarChart3 className="w-4 h-4" />
            Category Breakdown
          </h3>
          <CategoryBreakdown categories={stats.categoryBreakdown} />
        </div>
      </div>

      {/* Champions */}
      <ChampionItems stats={stats} />

      {/* Sustainability */}
      <SustainabilityScore
        score={stats.sustainabilityScore}
        carbonSavings={stats.estimatedCarbonSavings}
      />
    </div>
  )
}

export default WardrobeStats
