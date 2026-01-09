/**
 * Sustainability Goals Component
 *
 * Displays and manages sustainability-focused wardrobe goals.
 */

import { useState, useEffect, useMemo } from 'react'
import {
  Leaf,
  Target,
  Plus,
  Trash2,
  CheckCircle,
  TrendingUp,
  Droplet,
  Wind,
  Package,
  Trophy,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog'
import { cn } from '@/lib/utils'
import type { Item, Outfit } from '@/types'
import {
  type SustainabilityGoal,
  type GoalTemplate,
  type GoalProgress,
  type SustainabilityStats,
  getGoals,
  createGoal,
  deleteGoal,
  calculateGoalProgress,
  calculateSustainabilityStats,
  getSuggestedGoals,
  getEnvironmentalImpact,
  GOAL_TEMPLATES,
} from '@/lib/sustainability-goals'

// ============================================================================
// TYPES
// ============================================================================

interface SustainabilityGoalsProps {
  items: Item[]
  outfits: Outfit[]
  variant?: 'full' | 'compact' | 'dashboard'
  className?: string
}

interface GoalCardProps {
  progress: GoalProgress
  onDelete?: () => void
}

interface CreateGoalDialogProps {
  isOpen: boolean
  onClose: () => void
  onGoalCreated: (goal: SustainabilityGoal) => void
  suggestedTemplates: GoalTemplate[]
}

// ============================================================================
// SUB-COMPONENTS
// ============================================================================

function GoalCard({ progress, onDelete }: GoalCardProps) {
  const { goal, percentComplete, daysRemaining, onTrack, suggestion } = progress
  const template = GOAL_TEMPLATES.find((t) => t.type === goal.type)

  return (
    <div className="p-4 rounded-xl bg-muted/50 border space-y-3">
      <div className="flex items-start justify-between">
        <div className="flex items-center gap-3">
          <span className="text-2xl">{template?.icon || '🎯'}</span>
          <div>
            <p className="font-semibold">{goal.title}</p>
            <p className="text-sm text-muted-foreground">{goal.description}</p>
          </div>
        </div>
        {onDelete && (
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8 text-muted-foreground hover:text-destructive"
            onClick={onDelete}
          >
            <Trash2 className="w-4 h-4" />
          </Button>
        )}
      </div>

      {/* Progress */}
      <div className="space-y-2">
        <div className="flex items-center justify-between text-sm">
          <span>
            {goal.current} / {goal.target} {goal.unit}
          </span>
          <span className={cn('font-medium', onTrack ? 'text-green-600' : 'text-yellow-600')}>
            {percentComplete}%
          </span>
        </div>
        <Progress
          value={percentComplete}
          className={cn('h-2', percentComplete >= 100 && 'bg-green-100')}
        />
      </div>

      {/* Status badges */}
      <div className="flex items-center gap-2">
        {percentComplete >= 100 ? (
          <Badge className="bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
            <CheckCircle className="w-3 h-3 mr-1" />
            Completed
          </Badge>
        ) : onTrack ? (
          <Badge variant="outline" className="text-green-600 border-green-600">
            <TrendingUp className="w-3 h-3 mr-1" />
            On Track
          </Badge>
        ) : (
          <Badge variant="outline" className="text-yellow-600 border-yellow-600">
            <Target className="w-3 h-3 mr-1" />
            Needs Attention
          </Badge>
        )}

        {daysRemaining !== undefined && daysRemaining > 0 && (
          <Badge variant="secondary">{daysRemaining} days left</Badge>
        )}
      </div>

      {/* Suggestion */}
      {suggestion && percentComplete < 100 && (
        <p className="text-sm text-muted-foreground bg-muted/50 p-2 rounded">
          💡 {suggestion}
        </p>
      )}
    </div>
  )
}

function CreateGoalDialog({
  isOpen,
  onClose,
  onGoalCreated,
  suggestedTemplates,
}: CreateGoalDialogProps) {
  const [selectedType, setSelectedType] = useState<string | null>(null)
  const [customTarget, setCustomTarget] = useState<string>('')
  const [endDate, setEndDate] = useState<string>('')

  const selectedTemplate = GOAL_TEMPLATES.find((t) => t.type === selectedType)

  const handleCreate = () => {
    if (!selectedType) return

    const goal = createGoal(selectedType as any, {
      target: customTarget ? parseInt(customTarget, 10) : undefined,
      endDate: endDate || undefined,
    })

    onGoalCreated(goal)
    onClose()
    setSelectedType(null)
    setCustomTarget('')
    setEndDate('')
  }

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-lg max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Target className="w-5 h-5" />
            Create Sustainability Goal
          </DialogTitle>
          <DialogDescription>
            Choose a goal to help make your wardrobe more sustainable
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          {/* Suggested Goals */}
          {suggestedTemplates.length > 0 && (
            <div className="space-y-2">
              <Label className="text-sm font-medium">Recommended for you</Label>
              <div className="space-y-2">
                {suggestedTemplates.map((template) => (
                  <button
                    key={template.type}
                    onClick={() => setSelectedType(template.type)}
                    className={cn(
                      'w-full flex items-center gap-3 p-3 rounded-lg border text-left transition-colors',
                      selectedType === template.type
                        ? 'border-primary bg-primary/5'
                        : 'border-border hover:border-primary/50'
                    )}
                  >
                    <span className="text-2xl">{template.icon}</span>
                    <div className="flex-1">
                      <p className="font-medium">{template.title}</p>
                      <p className="text-sm text-muted-foreground">{template.description}</p>
                    </div>
                    <Badge
                      variant="outline"
                      className={cn(
                        template.difficulty === 'easy' && 'text-green-600 border-green-600',
                        template.difficulty === 'medium' && 'text-yellow-600 border-yellow-600',
                        template.difficulty === 'hard' && 'text-red-600 border-red-600'
                      )}
                    >
                      {template.difficulty}
                    </Badge>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* All Goals */}
          <div className="space-y-2">
            <Label className="text-sm font-medium">All Goals</Label>
            <div className="grid grid-cols-2 gap-2">
              {GOAL_TEMPLATES.filter(
                (t) => !suggestedTemplates.find((s) => s.type === t.type)
              ).map((template) => (
                <button
                  key={template.type}
                  onClick={() => setSelectedType(template.type)}
                  className={cn(
                    'flex flex-col items-center gap-2 p-3 rounded-lg border text-center transition-colors',
                    selectedType === template.type
                      ? 'border-primary bg-primary/5'
                      : 'border-border hover:border-primary/50'
                  )}
                >
                  <span className="text-2xl">{template.icon}</span>
                  <p className="text-sm font-medium">{template.title}</p>
                </button>
              ))}
            </div>
          </div>

          {/* Customization */}
          {selectedTemplate && (
            <div className="space-y-4 p-4 rounded-lg bg-muted/50 border">
              <div className="flex items-center gap-2">
                <span className="text-xl">{selectedTemplate.icon}</span>
                <span className="font-medium">{selectedTemplate.title}</span>
              </div>

              <div className="space-y-2">
                <Label htmlFor="target">
                  Target ({selectedTemplate.unit})
                </Label>
                <Input
                  id="target"
                  type="number"
                  placeholder={selectedTemplate.defaultTarget.toString()}
                  value={customTarget}
                  onChange={(e) => setCustomTarget(e.target.value)}
                />
              </div>

              {selectedTemplate.duration && (
                <div className="space-y-2">
                  <Label htmlFor="end-date">End Date (optional)</Label>
                  <Input
                    id="end-date"
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                  />
                </div>
              )}

              {/* Tips */}
              <div className="space-y-1">
                <p className="text-sm font-medium">Tips</p>
                <ul className="text-sm text-muted-foreground space-y-1">
                  {selectedTemplate.tips.map((tip, i) => (
                    <li key={i}>• {tip}</li>
                  ))}
                </ul>
              </div>
            </div>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleCreate} disabled={!selectedType}>
            <Plus className="w-4 h-4 mr-2" />
            Create Goal
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

function ImpactCard({
  impact,
}: {
  impact: ReturnType<typeof getEnvironmentalImpact>
}) {
  return (
    <div className="p-4 rounded-xl bg-gradient-to-br from-green-50 to-emerald-50 dark:from-green-950 dark:to-emerald-950 border border-green-200 dark:border-green-800">
      <div className="flex items-center gap-2 mb-4">
        <Leaf className="w-5 h-5 text-green-600" />
        <span className="font-semibold">Environmental Impact</span>
      </div>

      <div className="grid grid-cols-3 gap-4 mb-4">
        <div className="text-center">
          <div className="flex items-center justify-center gap-1 text-green-600 mb-1">
            <Wind className="w-4 h-4" />
          </div>
          <p className="text-xl font-bold">{impact.carbonSaved}</p>
          <p className="text-xs text-muted-foreground">kg CO2 saved</p>
        </div>
        <div className="text-center">
          <div className="flex items-center justify-center gap-1 text-blue-600 mb-1">
            <Droplet className="w-4 h-4" />
          </div>
          <p className="text-xl font-bold">{impact.waterSaved.toLocaleString()}</p>
          <p className="text-xs text-muted-foreground">liters saved</p>
        </div>
        <div className="text-center">
          <div className="flex items-center justify-center gap-1 text-amber-600 mb-1">
            <Package className="w-4 h-4" />
          </div>
          <p className="text-xl font-bold">{impact.wasteAvoided}</p>
          <p className="text-xs text-muted-foreground">kg waste avoided</p>
        </div>
      </div>

      {impact.equivalents.length > 0 && (
        <div className="space-y-1 text-sm text-muted-foreground">
          {impact.equivalents.map((eq, i) => (
            <p key={i}>🌱 {eq}</p>
          ))}
        </div>
      )}
    </div>
  )
}

function StatsOverview({ stats }: { stats: SustainabilityStats }) {
  return (
    <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
      <div className="p-3 rounded-lg bg-muted/50 border text-center">
        <p className="text-2xl font-bold text-green-600">{stats.overallScore}</p>
        <p className="text-xs text-muted-foreground">Sustainability Score</p>
      </div>
      <div className="p-3 rounded-lg bg-muted/50 border text-center">
        <p className="text-2xl font-bold">{stats.totalGoalsCompleted}</p>
        <p className="text-xs text-muted-foreground">Goals Completed</p>
      </div>
      <div className="p-3 rounded-lg bg-muted/50 border text-center">
        <p className="text-2xl font-bold">{stats.rewearRate}%</p>
        <p className="text-xs text-muted-foreground">Rewear Rate</p>
      </div>
      <div className="p-3 rounded-lg bg-muted/50 border text-center">
        <p className="text-2xl font-bold">${stats.moneyNotSpent}</p>
        <p className="text-xs text-muted-foreground">Est. Saved</p>
      </div>
    </div>
  )
}

// ============================================================================
// MAIN COMPONENT
// ============================================================================

export function SustainabilityGoals({
  items,
  outfits,
  variant = 'full',
  className,
}: SustainabilityGoalsProps) {
  const [showCreateDialog, setShowCreateDialog] = useState(false)
  const [goals, setGoals] = useState<SustainabilityGoal[]>([])

  // Load goals
  useEffect(() => {
    setGoals(getGoals())
  }, [])

  const activeGoals = goals.filter((g) => g.isActive && !g.completedAt)
  const completedGoals = goals.filter((g) => g.completedAt)

  const stats = useMemo(
    () => calculateSustainabilityStats(items, outfits),
    [items, outfits]
  )

  const impact = useMemo(() => getEnvironmentalImpact(items), [items])

  const suggestedTemplates = useMemo(
    () => getSuggestedGoals(items, outfits),
    [items, outfits]
  )

  const goalProgress = useMemo(
    () => activeGoals.map((goal) => calculateGoalProgress(goal, items, outfits)),
    [activeGoals, items, outfits]
  )

  const handleGoalCreated = () => {
    setGoals(getGoals())
  }

  const handleDeleteGoal = (goalId: string) => {
    deleteGoal(goalId)
    setGoals(getGoals())
  }

  // Dashboard variant
  if (variant === 'dashboard') {
    return (
      <div className={cn('space-y-4', className)}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Leaf className="w-5 h-5 text-green-600" />
            <span className="font-semibold">Sustainability</span>
          </div>
          <Badge variant="outline" className="text-green-600 border-green-600">
            Score: {stats.overallScore}
          </Badge>
        </div>

        {activeGoals.length > 0 ? (
          <div className="space-y-2">
            {goalProgress.slice(0, 2).map((progress) => (
              <div key={progress.goal.id} className="flex items-center gap-3">
                <span>{GOAL_TEMPLATES.find((t) => t.type === progress.goal.type)?.icon}</span>
                <div className="flex-1">
                  <div className="flex justify-between text-sm">
                    <span className="truncate">{progress.goal.title}</span>
                    <span className="text-muted-foreground">{progress.percentComplete}%</span>
                  </div>
                  <Progress value={progress.percentComplete} className="h-1.5" />
                </div>
              </div>
            ))}
          </div>
        ) : (
          <Button
            variant="outline"
            size="sm"
            className="w-full"
            onClick={() => setShowCreateDialog(true)}
          >
            <Plus className="w-4 h-4 mr-2" />
            Set a Goal
          </Button>
        )}

        <CreateGoalDialog
          isOpen={showCreateDialog}
          onClose={() => setShowCreateDialog(false)}
          onGoalCreated={handleGoalCreated}
          suggestedTemplates={suggestedTemplates}
        />
      </div>
    )
  }

  // Compact variant
  if (variant === 'compact') {
    return (
      <div className={cn('space-y-4', className)}>
        <StatsOverview stats={stats} />

        {activeGoals.length > 0 && (
          <div className="space-y-2">
            {goalProgress.slice(0, 2).map((progress) => (
              <GoalCard key={progress.goal.id} progress={progress} />
            ))}
          </div>
        )}

        <CreateGoalDialog
          isOpen={showCreateDialog}
          onClose={() => setShowCreateDialog(false)}
          onGoalCreated={handleGoalCreated}
          suggestedTemplates={suggestedTemplates}
        />
      </div>
    )
  }

  // Full variant
  return (
    <div className={cn('space-y-6', className)}>
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold flex items-center gap-2">
            <Leaf className="w-6 h-6 text-green-600" />
            Sustainability Goals
          </h2>
          <p className="text-muted-foreground">
            Track your progress towards a more sustainable wardrobe
          </p>
        </div>
        <Button onClick={() => setShowCreateDialog(true)}>
          <Plus className="w-4 h-4 mr-2" />
          New Goal
        </Button>
      </div>

      {/* Stats Overview */}
      <StatsOverview stats={stats} />

      {/* Environmental Impact */}
      <ImpactCard impact={impact} />

      {/* Active Goals */}
      {activeGoals.length > 0 ? (
        <div className="space-y-4">
          <h3 className="font-semibold flex items-center gap-2">
            <Target className="w-4 h-4" />
            Active Goals ({activeGoals.length})
          </h3>
          <div className="grid gap-4">
            {goalProgress.map((progress) => (
              <GoalCard
                key={progress.goal.id}
                progress={progress}
                onDelete={() => handleDeleteGoal(progress.goal.id)}
              />
            ))}
          </div>
        </div>
      ) : (
        <div className="text-center py-8 bg-muted/30 rounded-xl border border-dashed">
          <Leaf className="w-12 h-12 mx-auto mb-3 text-muted-foreground opacity-50" />
          <p className="font-medium">No active goals</p>
          <p className="text-sm text-muted-foreground mb-4">
            Set a sustainability goal to start tracking
          </p>
          <Button onClick={() => setShowCreateDialog(true)}>
            <Plus className="w-4 h-4 mr-2" />
            Create Your First Goal
          </Button>
        </div>
      )}

      {/* Completed Goals */}
      {completedGoals.length > 0 && (
        <div className="space-y-3">
          <h3 className="font-semibold flex items-center gap-2">
            <Trophy className="w-4 h-4 text-yellow-500" />
            Completed Goals ({completedGoals.length})
          </h3>
          <div className="grid gap-2">
            {completedGoals.map((goal) => {
              const template = GOAL_TEMPLATES.find((t) => t.type === goal.type)
              return (
                <div
                  key={goal.id}
                  className="flex items-center gap-3 p-3 rounded-lg bg-green-50 dark:bg-green-950 border border-green-200 dark:border-green-800"
                >
                  <span className="text-xl">{template?.icon}</span>
                  <div className="flex-1">
                    <p className="font-medium">{goal.title}</p>
                    <p className="text-sm text-muted-foreground">
                      Completed {goal.completedAt ? new Date(goal.completedAt).toLocaleDateString() : ''}
                    </p>
                  </div>
                  <CheckCircle className="w-5 h-5 text-green-600" />
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* Create Dialog */}
      <CreateGoalDialog
        isOpen={showCreateDialog}
        onClose={() => setShowCreateDialog(false)}
        onGoalCreated={handleGoalCreated}
        suggestedTemplates={suggestedTemplates}
      />
    </div>
  )
}

export default SustainabilityGoals
