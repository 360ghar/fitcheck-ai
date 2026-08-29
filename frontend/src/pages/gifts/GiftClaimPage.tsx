import { useEffect, useMemo, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import {
  Check,
  Clock3,
  Gift,
  Loader2,
  LockKeyhole,
  ShieldCheck,
  Sparkles,
  TicketCheck,
} from 'lucide-react'

import {
  claimGift,
  getPublicGift,
  giftErrorMessage,
  type GiftClaimResult,
  type GiftVoucher,
} from '@/api/gifts'
import { GiftCardPreview } from '@/components/gifts/GiftCardPreview'
import { SEO } from '@/components/seo'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { withAuthContext } from '@/pages/auth/authRedirect'
import { useAuthStore, useIsAuthenticated } from '@/stores/authStore'
import {
  captureGiftClaimCredentialFromLocation,
  forgetGiftClaimCredential,
  readGiftClaimCredential,
} from '@/lib/gift-claim-credential'

function captureCredential(publicId: string): string {
  const captured = captureGiftClaimCredentialFromLocation()
  if (captured?.publicId === publicId && captured.credential) return captured.credential
  return readGiftClaimCredential(publicId)
}

function unavailableCopy(status?: GiftVoucher['status']): { title: string; body: string } {
  if (status === 'claimed') {
    return { title: 'This gift has been claimed', body: 'The private invitation was accepted. No claimant details are shown.' }
  }
  if (status === 'expired') {
    return { title: 'This promotional gift expired', body: 'Its six-month claim window has ended.' }
  }
  if (status === 'voided' || status === 'revoked') {
    return { title: 'This gift is no longer available', body: 'The invitation cannot be claimed.' }
  }
  return { title: 'This gift is not ready', body: 'Ask the sender to check the private invitation.' }
}

export default function GiftClaimPage() {
  const { publicId = '' } = useParams()
  const isAuthenticated = useIsAuthenticated()
  const user = useAuthStore((state) => state.user)
  const [voucher, setVoucher] = useState<GiftVoucher | null>(null)
  const [credential, setCredential] = useState(() => (publicId ? captureCredential(publicId) : ''))
  const [printedCode, setPrintedCode] = useState('')
  const [claimResult, setClaimResult] = useState<GiftClaimResult | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isClaiming, setIsClaiming] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!publicId) {
      setError('This gift link is incomplete.')
      setIsLoading(false)
      return
    }
    setCredential(captureCredential(publicId))
    getPublicGift(publicId)
      .then(setVoucher)
      .catch((loadError) => setError(giftErrorMessage(loadError, 'This private gift could not be found.')))
      .finally(() => setIsLoading(false))
  }, [publicId])

  const artworkUrl = useMemo(() => {
    if (!voucher?.og_image_url || typeof window === 'undefined') return undefined
    return new URL(voucher.og_image_url, window.location.origin).toString()
  }, [voucher?.og_image_url])
  const canonicalUrl = useMemo(() => {
    if (!publicId || typeof window === 'undefined') return undefined
    return `${window.location.origin}/gift/${publicId}`
  }, [publicId])

  const claimCredential = credential || printedCode.trim()
  const canClaim = Boolean(
    voucher?.status === 'issued' &&
      isAuthenticated &&
      user?.email_verified &&
      claimCredential,
  )
  const returnTo = publicId ? `/gift/${publicId}` : '/'

  async function submitClaim(): Promise<void> {
    if (!publicId || !canClaim) return
    setIsClaiming(true)
    setError(null)
    try {
      const result = await claimGift(publicId, claimCredential)
      setClaimResult(result)
      setVoucher(result.voucher)
      forgetGiftClaimCredential(publicId)
      setCredential('')
      setPrintedCode('')
    } catch (claimError) {
      const message = giftErrorMessage(claimError, 'This gift could not be claimed. Check the code and try again.')
      setError(message)
      if (message.includes('already been claimed') || message.includes('expired')) {
        void getPublicGift(publicId).then(setVoucher)
      }
    } finally {
      setIsClaiming(false)
    }
  }

  const unavailable = unavailableCopy(voucher?.status)

  return (
    <>
      <SEO
        title={voucher ? `A FitCheck Pro gift for ${voucher.to_name}` : 'A private FitCheck Pro gift'}
        description="A private FitCheck Pro invitation is waiting to be claimed."
        ogImage={artworkUrl}
        canonicalUrl={canonicalUrl}
        noIndex
      />

      <main className="min-h-screen bg-[#f7f2e9] px-4 py-5 text-[#151411] sm:px-6 lg:px-10 lg:py-8">
        <div className="mx-auto max-w-6xl">
          <header className="flex items-center justify-between gap-4 border-b border-[#d8cfc1] pb-5">
            <Link to="/" className="font-display text-lg font-extrabold tracking-[-0.04em] text-[#151411]">
              FITCHECK <span className="text-[#e00016]">AI</span>
            </Link>
            <Badge variant="outline" className="border-[#d8cfc1] bg-[#fffdf8] text-[#151411]">
              <LockKeyhole className="mr-1 h-3 w-3" aria-hidden="true" /> Private invitation
            </Badge>
          </header>

          {isLoading ? (
            <div className="grid min-h-[70vh] place-items-center">
              <div className="text-center">
                <Loader2 className="mx-auto h-7 w-7 animate-spin text-[#e00016]" aria-hidden="true" />
                <p className="mt-3 text-sm text-[#6b655d]">Opening private gift…</p>
              </div>
            </div>
          ) : !voucher ? (
            <div className="mx-auto max-w-xl py-24 text-center">
              <Gift className="mx-auto h-10 w-10 text-[#6b655d]" aria-hidden="true" />
              <h1 className="mt-5 font-display text-3xl font-bold">Gift not available</h1>
              <p className="mt-3 text-[#6b655d]">{error || 'Check the private link and try again.'}</p>
              <Button asChild className="mt-6"><Link to="/">Go to FitCheck</Link></Button>
            </div>
          ) : (
            <div className="grid gap-8 py-8 lg:grid-cols-[minmax(320px,0.88fr)_minmax(340px,0.72fr)] lg:items-center lg:gap-14 lg:py-12">
              <div className="mx-auto w-full max-w-[520px]">
                <GiftCardPreview
                  fromName={voucher.from_name}
                  toName={voucher.to_name}
                  message={voucher.message}
                  duration={voucher.duration_months}
                  retailValueCents={voucher.retail_value_cents}
                  expiresAt={voucher.expires_at}
                />
              </div>

              <section className="rounded-lg border border-[#d8cfc1] bg-[#fffdf8] p-6 sm:p-8">
                <p className="font-display text-xs font-bold uppercase tracking-[0.24em] text-[#e00016]">
                  FitCheck private gifts
                </p>
                <h1 className="mt-3 font-display text-3xl font-extrabold tracking-[-0.045em] sm:text-4xl">
                  {claimResult ? 'Your Pro gift is secured.' : `${voucher.from_name} made this for you.`}
                </h1>

                {claimResult ? (
                  <div className="mt-6">
                    <Alert className="border-[#b8cbbd] bg-[#edf6ef] text-[#173d22]">
                      {claimResult.entitlement_status === 'active' ? <TicketCheck className="h-4 w-4" aria-hidden="true" /> : <Clock3 className="h-4 w-4" aria-hidden="true" />}
                      <AlertTitle>
                        {claimResult.entitlement_status === 'active' ? 'FitCheck Pro is active now' : 'Your gift is safely queued'}
                      </AlertTitle>
                      <AlertDescription>
                        {claimResult.entitlement_status === 'active'
                          ? `Access ends ${claimResult.active_ends_at ? new Date(claimResult.active_ends_at).toLocaleDateString() : 'after the full gift term'}. It does not auto-renew.`
                          : `It will start after your current Pro access. ${claimResult.queued_count} gift${claimResult.queued_count === 1 ? '' : 's'} in your queue.`}
                      </AlertDescription>
                    </Alert>
                    <Button asChild size="lg" className="mt-5 w-full">
                      <Link to="/dashboard"><Sparkles aria-hidden="true" /> Open FitCheck Pro</Link>
                    </Button>
                  </div>
                ) : voucher.status !== 'issued' ? (
                  <div className="mt-6">
                    <Alert className="border-[#d8cfc1] bg-[#f7f2e9]">
                      <ShieldCheck className="h-4 w-4" aria-hidden="true" />
                      <AlertTitle>{unavailable.title}</AlertTitle>
                      <AlertDescription>{unavailable.body}</AlertDescription>
                    </Alert>
                    <Button asChild variant="outline" className="mt-5 w-full border-[#d8cfc1] text-[#151411]">
                      <Link to="/">Discover FitCheck</Link>
                    </Button>
                  </div>
                ) : (
                  <div className="mt-6 space-y-5">
                    <div className="grid grid-cols-2 gap-3 border-y border-[#d8cfc1] py-5">
                      <div>
                        <p className="text-xs uppercase tracking-[0.16em] text-[#6b655d]">Your access</p>
                        <p className="mt-1 font-display text-lg font-bold">
                          {voucher.duration_months === 12 ? '1 year' : `${voucher.duration_months} month${voucher.duration_months === 1 ? '' : 's'}`} Pro
                        </p>
                      </div>
                      <div>
                        <p className="text-xs uppercase tracking-[0.16em] text-[#6b655d]">Retail value</p>
                        <p className="mt-1 font-display text-lg font-bold">${voucher.retail_value_cents / 100}</p>
                      </div>
                    </div>

                    {error && (
                      <Alert variant="destructive">
                        <AlertTitle>Claim not completed</AlertTitle>
                        <AlertDescription>{error}</AlertDescription>
                      </Alert>
                    )}

                    {!isAuthenticated ? (
                      <div>
                        <p className="text-sm leading-relaxed text-[#6b655d]">
                          Sign in or create a verified account to accept this gift. The private claim credential stays in this browser through sign-in, OAuth, and email verification.
                        </p>
                        <div className="mt-4 grid gap-2 sm:grid-cols-2">
                          <Button asChild size="lg">
                            <Link to={withAuthContext('/auth/login', undefined, returnTo)}>Sign in to claim</Link>
                          </Button>
                          <Button asChild variant="outline" size="lg" className="border-[#d8cfc1] text-[#151411]">
                            <Link to={withAuthContext('/auth/register', undefined, returnTo)}>Create account</Link>
                          </Button>
                        </div>
                      </div>
                    ) : !user?.email_verified ? (
                      <Alert className="border-[#d8cfc1] bg-[#f7f2e9]">
                        <ShieldCheck className="h-4 w-4" aria-hidden="true" />
                        <AlertTitle>Verify your email to claim</AlertTitle>
                        <AlertDescription>Open the FitCheck verification email, then return to this page. The private gift is saved in this browser.</AlertDescription>
                      </Alert>
                    ) : (
                      <>
                        {!credential && (
                          <div className="space-y-2">
                            <Label htmlFor="printed-gift-code" className="text-[#151411]">Enter the code printed on the gift</Label>
                            <Input
                              id="printed-gift-code"
                              name="gift_code"
                              value={printedCode}
                              onChange={(event) => setPrintedCode(event.target.value.toUpperCase())}
                              placeholder="XXXXX-XXXXX-XXXXX…"
                              autoComplete="off"
                              autoCapitalize="none"
                              autoCorrect="off"
                              spellCheck={false}
                              className="ph-no-capture border-[#d8cfc1] bg-[#fffdf8] text-[#151411]"
                            />
                          </div>
                        )}
                        {credential && (
                          <div className="flex items-center gap-2 text-sm font-semibold text-[#173d22]" aria-live="polite">
                            <Check className="h-4 w-4" aria-hidden="true" /> Secure gift link detected
                          </div>
                        )}
                        <Button
                          size="lg"
                          className="w-full"
                          onClick={() => void submitClaim()}
                          disabled={!canClaim || isClaiming}
                        >
                          {isClaiming ? <Loader2 className="animate-spin" aria-hidden="true" /> : <TicketCheck aria-hidden="true" />}
                          Accept {voucher.duration_months === 12 ? '1 year' : `${voucher.duration_months} month${voucher.duration_months === 1 ? '' : 's'}`} of Pro
                        </Button>
                      </>
                    )}

                    <p className="text-xs leading-relaxed text-[#6b655d]">
                      The “To” name is part of the presentation. The first different, verified FitCheck account that claims the valid link or code receives the gift. Gift access does not auto-renew.
                    </p>
                  </div>
                )}
              </section>
            </div>
          )}
        </div>
      </main>
    </>
  )
}
