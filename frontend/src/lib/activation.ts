/**
 * First-session activation helpers for new users.
 */

export interface ActivationInput {
  itemCount: number
  outfitCount: number
  hasAvatar: boolean
  tryOnUsed?: boolean
}

export interface ActivationStep {
  id: 'items' | 'outfit' | 'avatar' | 'tryon'
  title: string
  description: string
  done: boolean
  /** Core path (items + outfit) vs optional polish */
  required: boolean
}

export function getActivationSteps(input: ActivationInput): ActivationStep[] {
  return [
    {
      id: 'items',
      title: 'Add clothes',
      description: 'Upload photos — AI finds each item for your wardrobe.',
      done: input.itemCount >= 1,
      required: true,
    },
    {
      id: 'outfit',
      title: 'Build an outfit',
      description: 'Combine a few pieces into a look you can wear.',
      done: input.outfitCount >= 1,
      required: true,
    },
    {
      id: 'avatar',
      title: 'Add a photo of you',
      description: 'Needed for try-on and better photoshoot results.',
      done: input.hasAvatar,
      required: false,
    },
    {
      id: 'tryon',
      title: 'Try a look',
      description: 'See clothes on you before you wear them.',
      done: Boolean(input.tryOnUsed),
      required: false,
    },
  ]
}

/** Core activation is items + at least one outfit. */
export function isCoreActivationComplete(input: ActivationInput): boolean {
  return input.itemCount >= 1 && input.outfitCount >= 1
}

/** All guided steps including optional avatar / try-on. */
export function isFullActivationComplete(input: ActivationInput): boolean {
  return (
    isCoreActivationComplete(input) &&
    input.hasAvatar &&
    Boolean(input.tryOnUsed)
  )
}

/**
 * Show checklist until the user dismisses it, or until core path is done AND
 * optional steps are either complete or we only care about core once dismissed.
 * Default: keep visible until core complete (items + outfit). Optional steps
 * remain clickable rows while core is incomplete; after core, hide automatically.
 */
export function shouldShowActivation(
  input: ActivationInput,
  dismissed: boolean
): boolean {
  if (dismissed) return false
  return !isCoreActivationComplete(input)
}

/** Per-user try-on completion flag. */
export function tryOnUsedKey(userId: string | null | undefined): string {
  return `fitcheck_tryon_used_${userId || 'anon'}`
}

export function activationDismissKey(userId: string | null | undefined): string {
  return `fitcheck_activation_dismissed_${userId || 'anon'}`
}
