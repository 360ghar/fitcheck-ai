/**
 * StyleInsights Component
 *
 * Displays learned style preferences and insights based on user interactions.
 * Shows color preferences, style personality, and personalized recommendations.
 */

import { useState, useEffect } from 'react'
import {
  Sparkles,
  Palette,
  TrendingUp,
  RefreshCw,
  Info,
  Shirt,
  Tag,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip'
import {
  analyzeStylePreferences,
  syncPreferencesToBackend,
  getCachedInsights,
  getInteractionCount,
  type LearnedPreferences,
  type StyleInsight,
} from '@/lib/style-learning'
import { useToast } from '@/components/ui/use-toast'

interface StyleInsightsProps {
  onSyncComplete?: () => void
}

function InsightCard({ insight }: { insight: StyleInsight }) {
  const iconMap = {
    color: Palette,
    style: Sparkles,
    brand: Tag,
    category: Shirt,
    pattern: TrendingUp,
  }

  const Icon = iconMap[insight.type] || TrendingUp

  return (
    <div className="flex items-start gap-3 p-3 rounded-lg bg-gray-50 dark:bg-gray-800/50">
      <div className="p-2 rounded-full bg-indigo-100 dark:bg-indigo-900/50">
        <Icon className="h-4 w-4 text-indigo-600 dark:text-indigo-400" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium text-gray-900 dark:text-white">
          {insight.message}
        </p>
        <div className="flex items-center gap-2 mt-1">
          <Progress value={insight.confidence * 100} className="h-1 flex-1" />
          <span className="text-xs text-gray-500 dark:text-gray-400">
            {Math.round(insight.confidence * 100)}% confident
          </span>
        </div>
      </div>
    </div>
  )
}

function ColorSwatch({ color, score }: { color: string; score: number }) {
  // Try to use the color name as a CSS color, fallback to a neutral
  const cssColor = color.toLowerCase().replace(/\s+/g, '')

  return (
    <TooltipProvider>
      <Tooltip>
        <TooltipTrigger asChild>
          <div className="flex flex-col items-center gap-1">
            <div
              className="w-8 h-8 rounded-full border-2 border-white dark:border-gray-700 shadow-sm"
              style={{
                backgroundColor: cssColor,
                // Fallback for complex color names
                background: ['black', 'white', 'gray', 'navy', 'brown', 'beige', 'red', 'blue', 'green', 'yellow', 'pink', 'purple', 'orange', 'teal', 'maroon', 'olive'].includes(cssColor)
                  ? cssColor
                  : '#9CA3AF',
              }}
            />
            <span className="text-xs text-gray-600 dark:text-gray-400 capitalize truncate max-w-12">
              {color}
            </span>
          </div>
        </TooltipTrigger>
        <TooltipContent>
          <p>{color} (score: {Math.round(score)})</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  )
}

export function StyleInsights({ onSyncComplete }: StyleInsightsProps) {
  const [preferences, setPreferences] = useState<LearnedPreferences | null>(null)
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [isSyncing, setIsSyncing] = useState(false)
  const [interactionCount, setInteractionCount] = useState(0)
  const { toast } = useToast()

  useEffect(() => {
    // Load cached insights on mount
    const cached = getCachedInsights()
    if (cached) {
      setPreferences(cached)
    }
    setInteractionCount(getInteractionCount())
  }, [])

  const handleAnalyze = async () => {
    setIsAnalyzing(true)
    try {
      // Small delay for UX
      await new Promise((resolve) => setTimeout(resolve, 500))
      const result = analyzeStylePreferences()
      setPreferences(result)
      setInteractionCount(getInteractionCount())
      toast({
        title: 'Analysis complete',
        description: `Analyzed ${result.dataPointsAnalyzed} style interactions`,
      })
    } catch (error) {
      toast({
        title: 'Analysis failed',
        description: 'Could not analyze your style preferences',
        variant: 'destructive',
      })
    } finally {
      setIsAnalyzing(false)
    }
  }

  const handleSync = async () => {
    setIsSyncing(true)
    try {
      await syncPreferencesToBackend()
      toast({
        title: 'Preferences synced',
        description: 'Your learned preferences have been saved',
      })
      onSyncComplete?.()
    } catch (error) {
      toast({
        title: 'Sync failed',
        description: 'Could not sync preferences to your profile',
        variant: 'destructive',
      })
    } finally {
      setIsSyncing(false)
    }
  }

  const hasEnoughData = interactionCount >= 10
  const showAnalysisPrompt = !hasEnoughData

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle className="flex items-center gap-2">
              <Sparkles className="h-5 w-5 text-indigo-500" />
              Your Style DNA
            </CardTitle>
            <CardDescription>
              AI-learned preferences based on your interactions
            </CardDescription>
          </div>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={handleAnalyze}
              disabled={isAnalyzing || !hasEnoughData}
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
            {preferences && hasEnoughData && (
              <Button size="sm" onClick={handleSync} disabled={isSyncing}>
                {isSyncing ? 'Saving...' : 'Save to Profile'}
              </Button>
            )}
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Data collection progress */}
        <div className="p-4 rounded-lg bg-gray-50 dark:bg-gray-800/50">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
              Style learning progress
            </span>
            <span className="text-sm text-gray-500 dark:text-gray-400">
              {interactionCount} / 10 interactions
            </span>
          </div>
          <Progress value={Math.min((interactionCount / 10) * 100, 100)} />
          {showAnalysisPrompt && (
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 flex items-center gap-1">
              <Info className="h-3 w-3" />
              Keep using FitCheck to help us learn your style preferences
            </p>
          )}
        </div>

        {preferences && hasEnoughData ? (
          <>
            {/* Style personality */}
            <div className="text-center p-4 rounded-lg bg-gradient-to-br from-indigo-50 to-purple-50 dark:from-indigo-900/20 dark:to-purple-900/20">
              <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Your style personality</p>
              <h3 className="text-2xl font-bold text-indigo-600 dark:text-indigo-400">
                {preferences.stylePersonality}
              </h3>
              <Badge
                variant="outline"
                className="mt-2"
              >
                {preferences.colorTemperature === 'warm' && '🔥 Warm tones'}
                {preferences.colorTemperature === 'cool' && '❄️ Cool tones'}
                {preferences.colorTemperature === 'neutral' && '⚖️ Neutral palette'}
                {preferences.colorTemperature === 'mixed' && '🎨 Mixed palette'}
              </Badge>
            </div>

            {/* Top colors */}
            {preferences.topColors.length > 0 && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
                  Your favorite colors
                </h4>
                <div className="flex gap-4">
                  {preferences.topColors.slice(0, 5).map((c) => (
                    <ColorSwatch key={c.color} color={c.color} score={c.score} />
                  ))}
                </div>
              </div>
            )}

            {/* Top styles */}
            {preferences.topStyles.length > 0 && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
                  Preferred styles
                </h4>
                <div className="flex flex-wrap gap-2">
                  {preferences.topStyles.slice(0, 5).map((s) => (
                    <Badge key={s.style} variant="secondary" className="capitalize">
                      {s.style}
                    </Badge>
                  ))}
                </div>
              </div>
            )}

            {/* Top brands */}
            {preferences.topBrands.length > 0 && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
                  Favorite brands
                </h4>
                <div className="flex flex-wrap gap-2">
                  {preferences.topBrands.slice(0, 5).map((b) => (
                    <Badge key={b.brand} variant="outline">
                      {b.brand}
                    </Badge>
                  ))}
                </div>
              </div>
            )}

            {/* Insights */}
            {preferences.insights.length > 0 && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
                  Style insights
                </h4>
                <div className="space-y-2">
                  {preferences.insights.map((insight, idx) => (
                    <InsightCard key={idx} insight={insight} />
                  ))}
                </div>
              </div>
            )}

            {/* Last analyzed */}
            <p className="text-xs text-gray-400 text-center">
              Last analyzed: {new Date(preferences.lastAnalyzed).toLocaleDateString()} •{' '}
              {preferences.dataPointsAnalyzed} interactions analyzed
            </p>
          </>
        ) : (
          <div className="text-center py-8 text-gray-400">
            <Sparkles className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p className="font-medium">Not enough data yet</p>
            <p className="text-sm mt-2">
              Favorite items, create outfits, and track what you wear to help us learn your style
            </p>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

export default StyleInsights
