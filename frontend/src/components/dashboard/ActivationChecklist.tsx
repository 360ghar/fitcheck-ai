/**
 * First-session activation checklist for empty / partial accounts.
 */

import { Check, ChevronRight, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import {
  getActivationSteps,
  type ActivationInput,
  type ActivationStep,
} from '@/lib/activation'

export interface ActivationChecklistProps {
  input: ActivationInput
  onAddItems: () => void
  onCreateOutfit: () => void
  onAddAvatar: () => void
  onTryOn: () => void
  onDismiss?: () => void
  className?: string
}

function stepAction(
  step: ActivationStep,
  handlers: Omit<ActivationChecklistProps, 'input' | 'onDismiss' | 'className'>
): (() => void) | undefined {
  if (step.done) return undefined
  switch (step.id) {
    case 'items':
      return handlers.onAddItems
    case 'outfit':
      return handlers.onCreateOutfit
    case 'avatar':
      return handlers.onAddAvatar
    case 'tryon':
      return handlers.onTryOn
    default:
      return undefined
  }
}

export function ActivationChecklist({
  input,
  onAddItems,
  onCreateOutfit,
  onAddAvatar,
  onTryOn,
  onDismiss,
  className,
}: ActivationChecklistProps) {
  const steps = getActivationSteps(input)
  const handlers = { onAddItems, onCreateOutfit, onAddAvatar, onTryOn }
  const next = steps.find((s) => !s.done)
  const doneCount = steps.filter((s) => s.done).length

  return (
    <section
      className={cn(
        'rounded-xl border border-border bg-card overflow-hidden',
        className
      )}
      aria-label="Getting started"
    >
      <div className="flex items-start justify-between gap-3 px-4 py-4 md:px-6 border-b border-border">
        <div className="min-w-0">
          <h2 className="text-base md:text-lg font-semibold text-foreground">
            Get set up
          </h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Digitize a few pieces — we extract items so you can build outfits the same day.
          </p>
          <p className="mt-2 text-xs text-muted-foreground">
            {doneCount} of {steps.length} done
          </p>
        </div>
        {onDismiss && (
          <Button
            type="button"
            variant="ghost"
            size="icon"
            className="shrink-0 h-8 w-8"
            onClick={onDismiss}
            aria-label="Dismiss setup checklist"
          >
            <X className="h-4 w-4" />
          </Button>
        )}
      </div>

      <ol className="divide-y divide-border">
        {steps.map((step, index) => {
          const action = stepAction(step, handlers)
          const isNext = next?.id === step.id

          return (
            <li key={step.id}>
              <button
                type="button"
                disabled={!action}
                onClick={() => action?.()}
                className={cn(
                  'w-full flex items-center gap-3 px-4 py-3.5 md:px-6 text-left transition-colors',
                  action && 'hover:bg-accent/40 touch-target',
                  isNext && !step.done && 'bg-muted/40',
                  !action && 'cursor-default'
                )}
              >
                <span
                  className={cn(
                    'flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-sm font-medium',
                    step.done
                      ? 'bg-primary text-primary-foreground'
                      : isNext
                        ? 'bg-foreground text-background'
                        : 'bg-muted text-muted-foreground'
                  )}
                >
                  {step.done ? <Check className="h-4 w-4" /> : index + 1}
                </span>
                <div className="flex-1 min-w-0">
                  <p
                    className={cn(
                      'text-sm font-medium',
                      step.done ? 'text-muted-foreground line-through' : 'text-foreground'
                    )}
                  >
                    {step.title}
                    {!step.required && !step.done && (
                      <span className="ml-1.5 text-xs font-normal text-muted-foreground">
                        optional
                      </span>
                    )}
                  </p>
                  <p className="text-xs text-muted-foreground line-clamp-2">
                    {step.description}
                  </p>
                </div>
                {action && (
                  <ChevronRight className="h-4 w-4 shrink-0 text-muted-foreground" />
                )}
              </button>
            </li>
          )
        })}
      </ol>

      {next && (
        <div className="px-4 py-4 md:px-6 border-t border-border bg-muted/20">
          <Button
            type="button"
            className="w-full sm:w-auto"
            onClick={() => stepAction(next, handlers)?.()}
          >
            {next.id === 'items' && 'Add your first photos'}
            {next.id === 'outfit' && 'Create your first outfit'}
            {next.id === 'avatar' && 'Add a photo of you'}
            {next.id === 'tryon' && 'Try a look'}
          </Button>
        </div>
      )}
    </section>
  )
}

export default ActivationChecklist
