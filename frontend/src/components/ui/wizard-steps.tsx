import { Check } from 'lucide-react'
import { cn } from '@/lib/utils'

export interface WizardStep {
  id: string
  label: string
  shortLabel?: string
}

export interface WizardStepsProps {
  steps: readonly WizardStep[] | WizardStep[]
  currentStepId: string
  /** Bar style (photoshoot) vs numbered circles (try-on) */
  variant?: 'circles' | 'bars'
  onStepClick?: (stepId: string) => void
  className?: string
}

export function WizardSteps({
  steps,
  currentStepId,
  variant = 'circles',
  onStepClick,
  className,
}: WizardStepsProps) {
  const currentIndex = steps.findIndex((s) => s.id === currentStepId)

  if (variant === 'bars') {
    return (
      <ul className={cn('flex gap-2', className)} aria-label="Progress">
        {steps.map((step, index) => {
          const isCurrent = index === currentIndex
          const isComplete = index < currentIndex
          const canClick = onStepClick && index < currentIndex
          return (
            <li key={step.id} className="flex-1">
              <button
                type="button"
                disabled={!canClick}
                onClick={() => canClick && onStepClick?.(step.id)}
                className={cn(
                  'w-full text-left',
                  canClick && 'cursor-pointer'
                )}
                aria-current={isCurrent ? 'step' : undefined}
              >
                <div
                  className={cn(
                    'h-1 rounded-full transition-colors',
                    index <= currentIndex ? 'bg-primary' : 'bg-muted'
                  )}
                />
                <p
                  className={cn(
                    'text-xs mt-1 text-center',
                    isCurrent
                      ? 'text-primary font-medium'
                      : isComplete
                        ? 'text-foreground'
                        : 'text-muted-foreground'
                  )}
                >
                  {step.label}
                </p>
              </button>
            </li>
          )
        })}
      </ul>
    )
  }

  return (
    <ul
      className={cn(
        'flex items-center justify-center gap-2 md:gap-4 mb-4 md:mb-6 px-2 overflow-x-auto scrollbar-hide',
        className
      )}
      aria-label="Progress"
    >
      {steps.map((step, index) => {
        const isCompleted = index < currentIndex
        const isCurrent = index === currentIndex
        const isPending = index > currentIndex
        const canClick = onStepClick && index < currentIndex

        return (
          <li key={step.id} className="flex items-center gap-2 md:gap-4">
            <button
              type="button"
              disabled={!canClick}
              onClick={() => canClick && onStepClick?.(step.id)}
              className={cn(
                'flex flex-col items-center',
                canClick && 'cursor-pointer'
              )}
              aria-current={isCurrent ? 'step' : undefined}
            >
              <div
                className={cn(
                  'w-8 h-8 md:w-10 md:h-10 rounded-full flex items-center justify-center text-sm font-medium transition-colors shrink-0',
                  isCompleted && 'bg-primary text-primary-foreground',
                  isCurrent &&
                    'bg-primary text-primary-foreground ring-2 ring-primary ring-offset-2 ring-offset-background',
                  isPending && 'bg-muted text-muted-foreground'
                )}
              >
                {isCompleted ? (
                  <Check className="h-4 w-4" />
                ) : (
                  <>
                    <span className="md:hidden">{step.shortLabel ?? index + 1}</span>
                    <span className="hidden md:inline">{index + 1}</span>
                  </>
                )}
              </div>
              <span
                className={cn(
                  'mt-1 text-[10px] md:text-xs',
                  isCurrent ? 'text-foreground font-medium' : 'text-muted-foreground'
                )}
              >
                {step.label}
              </span>
            </button>
            {index < steps.length - 1 && (
              <div
                className={cn(
                  'w-4 md:w-12 h-0.5 transition-colors',
                  index < currentIndex ? 'bg-primary' : 'bg-muted'
                )}
              />
            )}
          </li>
        )
      })}
    </ul>
  )
}
