/**
 * GapAnalysis Component
 *
 * Displays wardrobe gap analysis with visualizations of category distribution,
 * identified gaps, and actionable recommendations for building a more versatile wardrobe.
 */

import { useState, useEffect, useCallback } from 'react'
import {
  PieChart,
  TrendingUp,
  TrendingDown,
  AlertCircle,
  CheckCircle,
  ShoppingBag,
  RefreshCw,
  ChevronDown,
  ChevronUp,
  Sparkles,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import {
  analyzeWardrobe,
  getWardrobeHealthStatus,
  type WardrobeAnalysis,
  type WardrobeGap,
  type CategoryDistribution,
} from '@/lib/gap-analysis'
import type { Item } from '@/types'
import { cn } from '@/lib/utils'

interface GapAnalysisProps {
  items: Item[]
  onShopSuggestion?: (gap: WardrobeGap) => void
}

function ScoreGauge({ score }: { score: number }) {
  const health = getWardrobeHealthStatus(score)
  const circumference = 2 * Math.PI * 45

  return (
    <div className="relative w-32 h-32 mx-auto">
      <svg className="w-full h-full transform -rotate-90">
        <circle
          cx="64"
          cy="64"
          r="45"
          stroke="currentColor"
          strokeWidth="8"
          fill="none"
          className="text-muted-foreground/30"
        />
        <circle
          cx="64"
          cy="64"
          r="45"
          stroke="currentColor"
          strokeWidth="8"
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={circumference - (score / 100) * circumference}
          strokeLinecap="round"
          className={cn(
            'transition-all duration-1000',
            health.color === 'green' && 'text-green-500',
            health.color === 'blue' && 'text-blue-500',
            health.color === 'yellow' && 'text-yellow-500',
            health.color === 'red' && 'text-red-500'
          )}
        />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-3xl font-bold">{score}</span>
        <span className="text-xs text-muted-foreground capitalize">
          {health.status}
        </span>
      </div>
    </div>
  )
}

function CategoryBar({ distribution }: { distribution: CategoryDistribution }) {
  const getStatusIcon = () => {
    switch (distribution.status) {
      case 'surplus':
        return <TrendingUp className="h-4 w-4 text-blue-500" />
      case 'balanced':
        return <CheckCircle className="h-4 w-4 text-green-500" />
      case 'deficit':
        return <TrendingDown className="h-4 w-4 text-yellow-500" />
      case 'missing':
        return <AlertCircle className="h-4 w-4 text-red-500" />
    }
  }

  const getStatusColor = () => {
    switch (distribution.status) {
      case 'surplus':
        return 'bg-blue-500'
      case 'balanced':
        return 'bg-green-500'
      case 'deficit':
        return 'bg-yellow-500'
      case 'missing':
        return 'bg-red-500'
    }
  }

  return (
    <div className="space-y-1">
      <div className="flex items-center justify-between text-sm">
        <div className="flex items-center gap-2">
          {getStatusIcon()}
          <span className="capitalize font-medium">{distribution.category}</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-muted-foreground">
            {distribution.count} items
          </span>
          <Badge variant="outline" className="text-xs">
            {distribution.percentage}%
          </Badge>
        </div>
      </div>
      <div className="flex items-center gap-2">
        <Progress
          value={Math.min(distribution.percentage, 100)}
          className="h-2 flex-1"
        />
        <div
          className={cn('w-2 h-2 rounded-full', getStatusColor())}
          title={`Ideal: ${distribution.idealPercentage}%`}
        />
      </div>
      <p className="text-xs text-muted-foreground">
        Ideal: {distribution.idealPercentage}% •{' '}
        {distribution.gapScore > 0 ? 'Needs more' : distribution.gapScore < 0 ? 'Well stocked' : 'Balanced'}
      </p>
    </div>
  )
}

function GapCard({
  gap,
  onShop,
}: {
  gap: WardrobeGap
  onShop?: () => void
}) {
  const priorityStyles = {
    high: 'border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-900/20',
    medium: 'border-yellow-200 bg-yellow-50 dark:border-yellow-800 dark:bg-yellow-900/20',
    low: 'border-border bg-muted',
  }

  const priorityBadge = {
    high: 'destructive',
    medium: 'secondary',
    low: 'outline',
  } as const

  return (
    <div className={cn('p-3 rounded-lg border', priorityStyles[gap.priority])}>
      <div className="flex items-start justify-between gap-2">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <Badge variant={priorityBadge[gap.priority]} className="capitalize text-xs">
              {gap.priority}
            </Badge>
            <span className="text-sm font-medium capitalize">
              {gap.subCategory || gap.category}
            </span>
          </div>
          <p className="text-sm text-muted-foreground">
            {gap.reason}
          </p>
          <p className="text-sm text-foreground/80 mt-1 font-medium">
            {gap.suggestion}
          </p>
          <div className="flex items-center gap-1 mt-2">
            <Sparkles className="h-3 w-3 text-gold-500" />
            <span className="text-xs text-muted-foreground">
              Versatility: {gap.versatilityScore}/10
            </span>
          </div>
        </div>
        {onShop && (
          <Button variant="outline" size="sm" onClick={onShop}>
            <ShoppingBag className="h-4 w-4" />
          </Button>
        )}
      </div>
    </div>
  )
}

function VersatilitySection({ analysis }: { analysis: WardrobeAnalysis }) {
  const [isOpen, setIsOpen] = useState(false)
  const { versatility } = analysis

  if (versatility.totalItems === 0) return null

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen}>
      <CollapsibleTrigger asChild>
        <Button variant="ghost" className="w-full justify-between">
          <span className="flex items-center gap-2">
            <TrendingUp className="h-4 w-4" />
            Item Versatility Insights
          </span>
          {isOpen ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
        </Button>
      </CollapsibleTrigger>
      <CollapsibleContent className="space-y-4 pt-4">
        <div className="grid grid-cols-3 gap-4 text-center">
          <div className="p-3 rounded-lg bg-muted">
            <p className="text-2xl font-bold">{versatility.averageTimesWorn}</p>
            <p className="text-xs text-muted-foreground">Avg. times worn</p>
          </div>
          <div className="p-3 rounded-lg bg-muted">
            <p className="text-2xl font-bold">{versatility.neverWornItems}</p>
            <p className="text-xs text-muted-foreground">Never worn</p>
          </div>
          <div className="p-3 rounded-lg bg-muted">
            <p className="text-2xl font-bold">{versatility.totalItems}</p>
            <p className="text-xs text-muted-foreground">Total items</p>
          </div>
        </div>

        {versatility.mostVersatileItems.length > 0 && (
          <div>
            <h4 className="text-sm font-medium mb-2">Most Versatile Items</h4>
            <div className="space-y-2">
              {versatility.mostVersatileItems.map(({ item, timesWorn, versatilityRating }) => (
                <div
                  key={item.id}
                  className="flex items-center justify-between p-2 rounded bg-green-50 dark:bg-green-900/20"
                >
                  <span className="text-sm font-medium truncate">{item.name}</span>
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="text-xs">
                      {timesWorn}x worn
                    </Badge>
                    <span className="text-xs text-green-600 dark:text-green-400">
                      {versatilityRating}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {versatility.underutilizedItems.length > 0 && (
          <div>
            <h4 className="text-sm font-medium mb-2">Underutilized Items</h4>
            <div className="space-y-2">
              {versatility.underutilizedItems.map(({ item, timesWorn, daysOwned }) => (
                <div
                  key={item.id}
                  className="flex items-center justify-between p-2 rounded bg-yellow-50 dark:bg-yellow-900/20"
                >
                  <span className="text-sm font-medium truncate">{item.name}</span>
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-muted-foreground">
                      {timesWorn}x in {daysOwned} days
                    </span>
                    <Badge variant="secondary" className="text-xs">
                      Consider styling
                    </Badge>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </CollapsibleContent>
    </Collapsible>
  )
}

export function GapAnalysis({ items, onShopSuggestion }: GapAnalysisProps) {
  const [analysis, setAnalysis] = useState<WardrobeAnalysis | null>(null)
  const [isAnalyzing, setIsAnalyzing] = useState(false)

  const runAnalysis = useCallback(() => {
    setIsAnalyzing(true)
    // Add slight delay for UX
    setTimeout(() => {
      const result = analyzeWardrobe(items)
      setAnalysis(result)
      setIsAnalyzing(false)
    }, 300)
  }, [items])

  useEffect(() => {
    if (items.length > 0) {
      runAnalysis()
    }
  }, [items, runAnalysis])

  if (items.length === 0) {
    return (
      <Card>
        <CardContent className="py-8">
          <div className="text-center text-muted-foreground">
            <PieChart className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p className="font-medium">No items to analyze</p>
            <p className="text-sm mt-2">Add items to your wardrobe to see gap analysis</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle className="flex items-center gap-2">
              <PieChart className="h-5 w-5 text-gold-500" />
              Wardrobe Gap Analysis
            </CardTitle>
            <CardDescription>
              Identify missing pieces and balance your wardrobe
            </CardDescription>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={runAnalysis}
            disabled={isAnalyzing}
          >
            {isAnalyzing ? (
              <>
                <RefreshCw className="h-4 w-4 mr-2 animate-spin" />
                Analyzing...
              </>
            ) : (
              <>
                <RefreshCw className="h-4 w-4 mr-2" />
                Refresh
              </>
            )}
          </Button>
        </div>
      </CardHeader>

      {analysis && (
        <CardContent className="space-y-6">
          {/* Overall Score */}
          <div className="text-center p-4 rounded-lg bg-gradient-to-br from-gold-50 to-navy-50 dark:from-gold-900/20 dark:to-navy-900/20">
            <ScoreGauge score={analysis.overallScore} />
            <p className="text-sm text-muted-foreground mt-4">
              {analysis.summary}
            </p>
          </div>

          {/* Quick Suggestions */}
          {analysis.suggestions.length > 0 && (
            <div className="p-4 rounded-lg bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800">
              <h4 className="text-sm font-medium text-blue-700 dark:text-blue-300 mb-2">
                Quick Wins
              </h4>
              <ul className="space-y-1">
                {analysis.suggestions.map((suggestion, idx) => (
                  <li key={idx} className="text-sm text-blue-600 dark:text-blue-400 flex items-start gap-2">
                    <span className="text-blue-400">•</span>
                    {suggestion}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Category Distribution */}
          <div>
            <h4 className="text-sm font-medium text-foreground/80 mb-3">
              Category Balance
            </h4>
            <div className="space-y-4">
              {analysis.categoryDistribution.map((dist) => (
                <CategoryBar key={dist.category} distribution={dist} />
              ))}
            </div>
          </div>

          {/* Gaps */}
          {analysis.gaps.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-foreground/80 mb-3">
                Recommended Additions ({analysis.gaps.length})
              </h4>
              <div className="space-y-2">
                {analysis.gaps.slice(0, 5).map((gap, idx) => (
                  <GapCard
                    key={idx}
                    gap={gap}
                    onShop={onShopSuggestion ? () => onShopSuggestion(gap) : undefined}
                  />
                ))}
              </div>
              {analysis.gaps.length > 5 && (
                <p className="text-xs text-muted-foreground mt-2 text-center">
                  +{analysis.gaps.length - 5} more suggestions
                </p>
              )}
            </div>
          )}

          {/* Top Colors */}
          {analysis.colorDistribution.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-foreground/80 mb-3">
                Color Distribution
              </h4>
              <div className="flex flex-wrap gap-2">
                {analysis.colorDistribution.slice(0, 8).map((color) => (
                  <div
                    key={color.color}
                    className="flex items-center gap-1 px-2 py-1 rounded-full bg-muted"
                  >
                    <div
                      className="w-3 h-3 rounded-full border border-border"
                      style={{
                        backgroundColor: color.color,
                        background: ['black', 'white', 'gray', 'navy', 'brown', 'beige', 'red', 'blue', 'green', 'yellow', 'pink', 'purple', 'orange', 'teal'].includes(color.color.toLowerCase())
                          ? color.color.toLowerCase()
                          : '#9CA3AF',
                      }}
                    />
                    <span className="text-xs capitalize">{color.color}</span>
                    <span className="text-xs text-muted-foreground">
                      {color.percentage}%
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Versatility Insights */}
          <VersatilitySection analysis={analysis} />
        </CardContent>
      )}
    </Card>
  )
}

export default GapAnalysis
