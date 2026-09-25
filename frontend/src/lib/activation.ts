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
      description: 'Upload photos — AI finds each item for your closet.',
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
function isCoreActivationComplete(input: ActivationInput): boolean {
  return input.itemCount >= 1 && input.outfitCount >= 1
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

/** Per-user "setup finished or skipped" flag for the /welcome flow. */
export function setupDoneKey(userId: string | null | undefined): string {
  return `fitcheck_setup_done_${userId || 'anon'}`
}

const SETUP_WINDOW_MS = 7 * 24 * 60 * 60 * 1000

/**
 * A new account without a gender goes through /welcome once. The 7-day
 * window keeps existing accounts out.
 * ponytail: the done flag is per device, so a user who skips on one device
 * sees setup once on another; add a backend flag if that matters.
 */
export function needsSetup(
  user: { gender?: string | null; created_at?: string } | null | undefined,
  done: boolean,
  now: number = Date.now(),
): boolean {
  return shouldShowSetup({
    createdAt: user?.created_at,
    gender: user?.gender,
    done,
    now,
  })
}

export interface SetupGateInput {
  createdAt?: string | null
  gender?: string | null
  /** Omitted when the caller holds no preferences; then only gender gates. */
  styles?: string[] | null
  done: boolean
  now?: number
}

/**
 * One setup rule shared by web and mobile: a new account (7-day window,
 * setup not done) missing profile data goes through setup once. Each
 * platform passes the profile it already holds: web passes gender, mobile
 * passes styles. A field left undefined is unknown, never missing, so the
 * rule never traps a user on data the caller did not load.
 */
export function shouldShowSetup({
  createdAt,
  gender,
  styles,
  done,
  now = Date.now(),
}: SetupGateInput): boolean {
  if (done) return false
  const created = Date.parse(createdAt ?? '')
  const age = now - created
  if (!Number.isFinite(age) || age < 0 || age >= SETUP_WINDOW_MS) return false
  if (gender !== undefined && !gender) return true
  if (styles !== undefined && (styles ?? []).length === 0) return true
  return false
}

/** Reads the per-user setup flag. True on storage failure: never trap. */
export function isSetupDone(userId: string | null | undefined): boolean {
  try {
    return localStorage.getItem(setupDoneKey(userId)) === '1'
  } catch {
    return true
  }
}

/** Marks setup finished or skipped. */
export function markSetupDone(userId: string | null | undefined): void {
  try {
    localStorage.setItem(setupDoneKey(userId), '1')
  } catch {
    // Storage blocked: the 7-day window still ends the prompt.
  }
}
