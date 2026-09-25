/**
 * First-run setup for a new account: who we style, what they wear, then the
 * first closet upload. Every step can be skipped. The dashboard sends new
 * accounts here once (see needsSetup in lib/activation.ts).
 */

import { useEffect, useRef, useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import SEO from '@/components/seo/SEO'
import { Logo } from '@/components/brand/Logo'
import { Button } from '@/components/ui/button'
import { FilterChip } from '@/components/ui/filter-chip'
import { WizardSteps } from '@/components/ui/wizard-steps'
import { getUserPreferences, updateCurrentUser, updateUserPreferences } from '@/api/users'
import { useAuthStore, useCurrentUser } from '@/stores/authStore'
import { markSetupDone } from '@/lib/activation'
import { OCCASION_SUGGESTIONS, STYLE_SUGGESTIONS } from '@/lib/style-options'
import { cn } from '@/lib/utils'
import type { Gender } from '@/types'
import { getSafeReturnTo } from './auth/authRedirect'

const STEPS = [
  { id: 'who', label: 'You' },
  { id: 'style', label: 'Style' },
  { id: 'closet', label: 'Closet' },
] as const

type StepId = (typeof STEPS)[number]['id']

const GENDERS: { value: Gender; label: string }[] = [
  { value: 'female', label: 'Women' },
  { value: 'male', label: 'Men' },
  { value: 'non_binary', label: 'Non-binary' },
  { value: 'prefer_not_to_say', label: 'Prefer not to say' },
]

function toggle(list: string[], value: string): string[] {
  return list.includes(value) ? list.filter((v) => v !== value) : [...list, value]
}

interface OptionProps {
  label: string
  value: Gender
  selected: boolean
  onSelect: () => void
}

/** Native radio cards provide arrow navigation and one tab stop per group. */
function Option({ label, value, selected, onSelect }: OptionProps) {
  return (
    <label className="relative cursor-pointer">
      <input
        type="radio"
        name="gender"
        value={value}
        checked={selected}
        onChange={onSelect}
        className="peer sr-only"
      />
      <span
        className={cn(
          'block min-h-[44px] rounded-md border px-4 py-2.5 text-left text-sm font-semibold transition-colors',
          'peer-focus-visible:ring-2 peer-focus-visible:ring-ring peer-focus-visible:ring-offset-2',
          selected
            ? 'border-foreground bg-foreground text-background'
            : 'border-border bg-card text-foreground hover:border-foreground/40',
        )}
      >
        {label}
      </span>
    </label>
  )
}

interface StepShellProps {
  titleId: string
  title: string
  description: string
  children: React.ReactNode
  footer: React.ReactNode
}

/** One setup step: title, description, body and the Skip/Continue footer. */
function StepShell({ titleId, title, description, children, footer }: StepShellProps) {
  return (
    <section className="mt-10 flex flex-1 flex-col" aria-labelledby={titleId}>
      <h1 id={titleId} className="type-heading-xl text-foreground">
        {title}
      </h1>
      <p className="mt-2 text-muted-foreground">{description}</p>
      {children}
      <div className="mt-auto flex items-center justify-end gap-3 pt-10 sm:mt-0">{footer}</div>
    </section>
  )
}

export default function WelcomePage() {
  const navigate = useNavigate()
  const location = useLocation()
  const requested = getSafeReturnTo(new URLSearchParams(location.search).get('returnTo'))
  const requestedPath = requested?.split(/[?#]/)[0]
  const returnTo = requestedPath && requestedPath !== '/welcome' && !requestedPath.startsWith('/auth/')
    ? requested : undefined
  const preferencesEdited = useRef(false)
  const user = useCurrentUser()
  const setUser = useAuthStore((s) => s.setUser)
  const [step, setStep] = useState<StepId>('who')
  const [gender, setGender] = useState<Gender | null>(user?.gender ?? null)
  const [styles, setStyles] = useState<string[]>([])
  const [occasions, setOccasions] = useState<string[]>([])
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    let cancelled = false
    getUserPreferences()
      .then((prefs) => {
        if (cancelled || preferencesEdited.current) return
        setStyles(prefs.preferred_styles ?? [])
        setOccasions(prefs.preferred_occasions ?? [])
      })
      .catch(() => {
        // Empty choices are a fine start; saving still works.
      })
    return () => {
      cancelled = true
    }
  }, [user?.id])

  const finish = (to = returnTo ?? '/dashboard') => {
    markSetupDone(user?.id)
    navigate(to, { replace: true })
  }

  const saveGender = async () => {
    if (!gender || gender === user?.gender) return setStep('style')
    setSaving(true)
    try {
      const { user: updated } = await updateCurrentUser({ gender })
      setUser(updated)
      setStep('style')
    } catch {
      // api/client already shows the error; stay on this step.
    } finally {
      setSaving(false)
    }
  }

  const saveStyle = async () => {
    setSaving(true)
    try {
      await updateUserPreferences({ preferred_styles: styles, preferred_occasions: occasions })
      setStep('closet')
    } catch {
      // Shown by api/client.
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="flex min-h-svh flex-col bg-background px-4 pb-[calc(var(--safe-area-bottom)+1.5rem)] pt-[calc(var(--safe-area-top)+1rem)] sm:px-6">
      <SEO title="Welcome | FitCheck AI" noIndex={true} />
      <header className="mx-auto flex w-full max-w-xl items-center justify-between">
        <Logo markSize={36} wordmarkClassName="text-lg" />
        <Button variant="ghost" onClick={() => finish()}>
          Skip setup
        </Button>
      </header>

      <main className="mx-auto flex w-full max-w-xl flex-1 flex-col pt-10 sm:pt-16">
        <WizardSteps steps={STEPS} currentStepId={step} variant="bars" />

        {step === 'who' && (
          <StepShell
            titleId="welcome-who"
            title="Who are we styling?"
            description="Sets the model for try-on and photoshoots. You can change it in your profile."
            footer={
              <>
                <Button variant="ghost" onClick={() => setStep('style')}>
                  Skip
                </Button>
                <Button onClick={saveGender} disabled={!gender || saving} className="min-w-[8rem]">
                  {saving ? 'Saving…' : 'Continue'}
                </Button>
              </>
            }
          >
            <div role="radiogroup" aria-labelledby="welcome-who" className="mt-8 grid grid-cols-2 gap-3">
              {GENDERS.map((g) => (
                <Option
                  key={g.value}
                  value={g.value}
                  label={g.label}
                  selected={gender === g.value}
                  onSelect={() => setGender(g.value)}
                />
              ))}
            </div>
          </StepShell>
        )}

        {step === 'style' && (
          <StepShell
            titleId="welcome-style"
            title="What do you wear most?"
            description="Pick any. Outfit ideas start from these."
            footer={
              <>
                <Button variant="ghost" onClick={() => setStep('closet')}>
                  Skip
                </Button>
                <Button
                  onClick={saveStyle}
                  disabled={saving || (styles.length === 0 && occasions.length === 0)}
                  className="min-w-[8rem]"
                >
                  {saving ? 'Saving…' : 'Continue'}
                </Button>
              </>
            }
          >
            <h2 id="welcome-styles" className="mt-8 text-sm font-semibold text-foreground">
              Styles
            </h2>
            <div role="group" aria-labelledby="welcome-styles" className="mt-3 flex flex-wrap gap-2">
              {STYLE_SUGGESTIONS.map((s) => (
                <FilterChip key={s} active={styles.includes(s)} onClick={() => { preferencesEdited.current = true; setStyles(toggle(styles, s)) }}>
                  {s}
                </FilterChip>
              ))}
            </div>
            <h2 id="welcome-occasions" className="mt-8 text-sm font-semibold text-foreground">
              Occasions
            </h2>
            <div role="group" aria-labelledby="welcome-occasions" className="mt-3 flex flex-wrap gap-2">
              {OCCASION_SUGGESTIONS.map((o) => (
                <FilterChip
                  key={o}
                  active={occasions.includes(o)}
                  onClick={() => { preferencesEdited.current = true; setOccasions(toggle(occasions, o)) }}
                >
                  {o}
                </FilterChip>
              ))}
            </div>
          </StepShell>
        )}

        {step === 'closet' && (
          <StepShell
            titleId="welcome-closet"
            title="Add your first pieces."
            description="Photograph a few clothes, or a pile of them. Each piece is cut out and filed for you."
            footer={
              <>
                <Button variant="ghost" onClick={() => finish()}>
                  Later
                </Button>
                <Button onClick={() => finish('/wardrobe?action=add')} className="min-w-[8rem]">
                  Add clothes
                </Button>
              </>
            }
          >
            <img
              src="/generated/outfit-flatlay-4x3-640.webp"
              srcSet="/generated/outfit-flatlay-4x3-640.webp 640w, /generated/outfit-flatlay-4x3.webp 1200w"
              sizes="(min-width: 640px) 576px, 100vw"
              width={640}
              height={480}
              alt="A cream sweater, jeans and white sneakers laid flat"
              className="mt-8 aspect-[4/3] w-full rounded-2xl object-cover shadow-pressed"
            />
          </StepShell>
        )}
      </main>
    </div>
  )
}
