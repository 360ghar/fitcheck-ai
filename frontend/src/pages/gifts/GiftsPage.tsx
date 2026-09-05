import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import {
  Check,
  Copy,
  Download,
  Edit3,
  ExternalLink,
  Gift,
  Loader2,
  RefreshCw,
  Send,
  Share2,
  Sparkles,
} from 'lucide-react'

import {
  claimAssignedGift,
  createComplimentaryGift,
  createPaidGiftCheckout,
  downloadGiftArtwork,
  fulfillGiftCheckout,
  giftErrorMessage,
  giftIncomingTitle,
  giftOccasionGreeting,
  giftShareText,
  giftTermLabel,
  getGiftCatalog,
  getGiftDashboardSummary,
  getReceivedGifts,
  getSentGifts,
  rotateGiftLink,
  updateGift,
  type GiftAllowance,
  type GiftCatalogOption,
  type GiftDuration,
  type GiftOccasion,
  type GiftVoucher,
} from '@/api/gifts'
import { GiftCardPreview } from '@/components/gifts/GiftCardPreview'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { PageHeader } from '@/components/ui/page-header'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Textarea } from '@/components/ui/textarea'
import { EmptyState } from '@/components/ui/empty-state'
import { copyTextToClipboard } from '@/lib/clipboard'
import { cn, formatUsd } from '@/lib/utils'
import { useAuthStore } from '@/stores/authStore'

type GiftMode = 'complimentary' | 'paid'

const GIFT_OCCASIONS = [
  { value: 'birthday', label: 'Birthday' },
  { value: 'anniversary', label: 'Anniversary' },
  { value: 'other', label: 'Other' },
] as const satisfies readonly { value: GiftOccasion; label: string }[]

const FALLBACK_CATALOG: GiftCatalogOption[] = [
  { duration_months: 1, retail_value_cents: 2_000, currency: 'USD', paid_available: false },
  { duration_months: 3, retail_value_cents: 6_000, currency: 'USD', paid_available: false },
  { duration_months: 12, retail_value_cents: 20_000, currency: 'USD', paid_available: false },
]

function newRequestId(): string {
  return typeof crypto !== 'undefined' && 'randomUUID' in crypto
    ? crypto.randomUUID()
    : `gift-${Date.now()}-${Math.random().toString(36).slice(2)}`
}

function previewExpiry(): string {
  const date = new Date()
  const day = date.getDate()
  date.setDate(1)
  date.setMonth(date.getMonth() + 6)
  const lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()
  date.setDate(Math.min(day, lastDay))
  return date.toISOString()
}

function statusLabel(voucher: GiftVoucher): string {
  if (voucher.entitlement_status === 'active') return 'Active now'
  if (voucher.entitlement_status === 'queued') return 'Queued'
  return voucher.status.replace(/_/g, ' ')
}

interface VoucherSummaryProps {
  voucher: GiftVoucher
  /** "3 months Pro" in the ledger, "3 months of FitCheck Pro" in the inbox. */
  termText: string
  className?: string
  /** The gift inbox omits the sender's private note. */
  showMessage?: boolean
}

/**
 * Shared voucher row metadata: term + value line, occasion greeting, and the
 * private note. Used by the gift inbox and the sent/received ledger.
 */
function VoucherSummary({ voucher, termText, className, showMessage = true }: VoucherSummaryProps) {
  const occasionGreeting = giftOccasionGreeting(voucher.occasion, voucher.occasion_greeting)
  return (
    <>
      <p className={cn('text-sm text-muted-foreground', className)}>
        {termText} · {formatUsd(voucher.retail_value_cents)} value
      </p>
      {occasionGreeting && <p className="mt-1 text-sm font-medium text-primary">{occasionGreeting}</p>}
      {showMessage && voucher.message && (
        <p className="mt-2 line-clamp-1 text-sm text-muted-foreground">“{voucher.message}”</p>
      )}
    </>
  )
}

interface HistoryListProps {
  items: GiftVoucher[]
  kind: 'sent' | 'received'
  onEdit: (voucher: GiftVoucher) => void
  onRotate: (voucher: GiftVoucher) => Promise<void>
  onShare: (voucher: GiftVoucher) => Promise<void>
  onCopy: (voucher: GiftVoucher) => Promise<void>
  onDownload: (voucher: GiftVoucher) => Promise<void>
  busyId: string | null
}

function HistoryList({
  items,
  kind,
  onEdit,
  onRotate,
  onShare,
  onCopy,
  onDownload,
  busyId,
}: HistoryListProps) {
  if (!items.length) {
    return (
      <EmptyState
        icon={Gift}
        className="rounded-md border-dashed"
        title={kind === 'sent' ? 'Your first gift starts here' : 'No gifts received yet'}
        description={
          kind === 'sent'
            ? 'Create a private FitCheck Pro invitation above.'
            : 'Claimed and queued gifts will appear here.'
        }
      />
    )
  }

  return (
    <div className="divide-y divide-border rounded-md border border-border">
      {items.map((voucher) => {
        const canManage = kind === 'sent' && voucher.status === 'issued'
        const isBusy = busyId === voucher.id
        return (
          <article key={voucher.id} className="grid gap-4 p-4 sm:grid-cols-[1fr_auto] sm:items-center">
            <div className="min-w-0">
              <div className="flex flex-wrap items-center gap-2">
                <p className="truncate font-display text-base font-bold">
                  {kind === 'sent' ? `For ${voucher.to_name}` : `From ${voucher.from_name}`}
                </p>
                <Badge
                  variant={voucher.entitlement_status === 'active' ? 'success' : 'outline'}
                  className="capitalize"
                >
                  {statusLabel(voucher)}
                </Badge>
              </div>
              <VoucherSummary
                voucher={voucher}
                termText={`${giftTermLabel(voucher.duration_months)} Pro`}
                className="mt-1"
              />
            </div>

            <div className="flex flex-wrap gap-2 sm:justify-end">
              {voucher.share_url && (
                <>
                  <Button variant="outline" size="sm" onClick={() => onCopy(voucher)}>
                    <Copy aria-hidden="true" /> Copy link
                  </Button>
                  <Button variant="outline" size="sm" onClick={() => onShare(voucher)}>
                    <Share2 aria-hidden="true" /> Share
                  </Button>
                  <Button variant="outline" size="sm" onClick={() => onDownload(voucher)} disabled={isBusy}>
                    {isBusy ? <Loader2 className="animate-spin" aria-hidden="true" /> : <Download aria-hidden="true" />} Image
                  </Button>
                </>
              )}
              {canManage && (
                <>
                  <Button variant="ghost" size="sm" onClick={() => onEdit(voucher)}>
                    <Edit3 aria-hidden="true" /> Edit
                  </Button>
                  <Button variant="ghost" size="sm" onClick={() => onRotate(voucher)} disabled={isBusy}>
                    {isBusy ? <Loader2 className="animate-spin" aria-hidden="true" /> : <RefreshCw aria-hidden="true" />} Rotate link
                  </Button>
                </>
              )}
            </div>
          </article>
        )
      })}
    </div>
  )
}

export default function GiftsPage() {
  const user = useAuthStore((state) => state.user)
  const [searchParams, setSearchParams] = useSearchParams()
  const [catalog, setCatalog] = useState<GiftCatalogOption[]>(FALLBACK_CATALOG)
  const [allowances, setAllowances] = useState<GiftAllowance[]>([])
  const [sent, setSent] = useState<GiftVoucher[]>([])
  const [received, setReceived] = useState<GiftVoucher[]>([])
  const [incoming, setIncoming] = useState<GiftVoucher[]>([])
  const [selectedIncomingId, setSelectedIncomingId] = useState<string | null>(null)
  const [duration, setDuration] = useState<GiftDuration>(1)
  const [mode, setMode] = useState<GiftMode>('complimentary')
  const [fromName, setFromName] = useState(user?.full_name || user?.email?.split('@')[0] || '')
  const [toName, setToName] = useState('')
  const [recipientEmail, setRecipientEmail] = useState('')
  const [message, setMessage] = useState('')
  const [occasion, setOccasion] = useState<GiftOccasion | null>(null)
  const [occasionGreeting, setOccasionGreeting] = useState('')
  const [editing, setEditing] = useState<GiftVoucher | null>(null)
  const [created, setCreated] = useState<GiftVoucher | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [busyId, setBusyId] = useState<string | null>(null)
  const [notice, setNotice] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const requestIdRef = useRef<string | null>(null)
  const formRef = useRef<HTMLDivElement | null>(null)
  const incomingRef = useRef<HTMLElement | null>(null)

  const selected = catalog.find((item) => item.duration_months === duration) || FALLBACK_CATALOG[0]
  const allowance = allowances.find((item) => item.duration_months === duration)
  const freeRemaining = allowance?.remaining_count || 0
  const canCreate = Boolean(
    user?.email_verified &&
      fromName.trim() &&
      toName.trim() &&
      (editing || recipientEmail.trim()) &&
      (occasion !== 'other' || occasionGreeting.trim()) &&
      (editing || (mode === 'complimentary' ? freeRemaining > 0 : selected.paid_available)),
  )

  const freeExpiry = useMemo(previewExpiry, [])

  const loadData = useCallback(async () => {
    setIsLoading(true)
    try {
      const [catalogData, summaryData, sentData, receivedData] = await Promise.all([
        getGiftCatalog(),
        getGiftDashboardSummary(),
        getSentGifts(),
        getReceivedGifts(),
      ])
      setCatalog(catalogData)
      setAllowances(summaryData.allowances)
      setIncoming(summaryData.incoming)
      setSent(sentData.items)
      setReceived(receivedData.items)
    } catch (loadError) {
      setError(giftErrorMessage(loadError, 'Gift vouchers could not be loaded. Try again.'))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    void loadData()
  }, [loadData])

  useEffect(() => {
    if (!fromName && user?.full_name) setFromName(user.full_name)
  }, [user?.full_name, fromName])

  useEffect(() => {
    const requestedMode = searchParams.get('mode')
    const requestedDuration = Number(searchParams.get('duration'))
    const requestedClaim = searchParams.get('claim')
    if (requestedMode === 'complimentary') setMode('complimentary')
    if (requestedDuration === 1 || requestedDuration === 3 || requestedDuration === 12) {
      setDuration(requestedDuration)
    }
    if (requestedClaim) setSelectedIncomingId(requestedClaim)
    const checkout = searchParams.get('checkout')
    const sessionId = searchParams.get('session_id')
    if (checkout === 'cancelled') {
      setNotice('Checkout was cancelled. Your gift was not issued.')
      setSearchParams({}, { replace: true })
      return
    }
    if (checkout !== 'success' || !sessionId) return

    // Consume the params before the async fulfill so StrictMode's second
    // effect pass (or a fast re-render) cannot fulfill the checkout twice.
    setSearchParams({}, { replace: true })
    setIsSubmitting(true)
    fulfillGiftCheckout(sessionId)
      .then((voucher) => {
        setCreated(voucher)
        setNotice('Payment confirmed. Your private gift is ready to share.')
        return loadData()
      })
      .catch((checkoutError) => {
        setError(giftErrorMessage(checkoutError, 'Payment confirmation is still pending. Refresh this page shortly.'))
      })
      .finally(() => setIsSubmitting(false))
  }, [loadData, searchParams, setSearchParams])

  useEffect(() => {
    if (!selectedIncomingId || !incoming.some((voucher) => voucher.id === selectedIncomingId)) return
    incomingRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }, [incoming, selectedIncomingId])

  function resetIntent(): void {
    requestIdRef.current = null
    setNotice(null)
    setError(null)
  }

  function resetForm(): void {
    setEditing(null)
    setToName('')
    setRecipientEmail('')
    setMessage('')
    setOccasion(null)
    setOccasionGreeting('')
    requestIdRef.current = null
  }

  async function submitGift(event: React.FormEvent): Promise<void> {
    event.preventDefault()
    setError(null)
    setNotice(null)
    if (!canCreate) return
    setIsSubmitting(true)
    try {
      if (editing) {
        const updated = await updateGift(editing.id, {
          from_name: fromName.trim(),
          to_name: toName.trim(),
          message: message.trim() || null,
          occasion,
          occasion_greeting: occasion === 'other' ? occasionGreeting.trim() : null,
        })
        setCreated(updated)
        setNotice('Gift details updated. The artwork has been regenerated.')
        resetForm()
        await loadData()
        return
      }

      const body = {
        duration_months: duration,
        from_name: fromName.trim(),
        to_name: toName.trim(),
        recipient_email: recipientEmail.trim(),
        message: message.trim() || undefined,
        occasion: occasion || undefined,
        occasion_greeting: occasion === 'other' ? occasionGreeting.trim() || undefined : undefined,
        client_request_id: requestIdRef.current || newRequestId(),
      }
      requestIdRef.current = body.client_request_id
      if (mode === 'paid') {
        const checkout = await createPaidGiftCheckout(body)
        window.location.assign(checkout.checkout_url)
        return
      }
      const voucher = await createComplimentaryGift(body)
      setCreated(voucher)
      setNotice('Your private gift is ready to share.')
      resetForm()
      await loadData()
    } catch (submitError) {
      setError(giftErrorMessage(submitError, 'The gift could not be created. Try again.'))
    } finally {
      setIsSubmitting(false)
    }
  }

  async function copyLink(voucher: GiftVoucher): Promise<void> {
    if (!voucher.share_url) return
    try {
      await copyTextToClipboard(voucher.share_url)
      setNotice('Private gift link copied.')
    } catch {
      setError('The private gift link could not be copied. Select and copy it manually.')
    }
  }

  async function shareGift(voucher: GiftVoucher): Promise<void> {
    if (!voucher.share_url) return
    if (navigator.share) {
      try {
        await navigator.share({
          title: `A FitCheck Pro gift for ${voucher.to_name}`,
          text: giftShareText(voucher),
          url: voucher.share_url,
        })
        return
      } catch (shareError) {
        if (shareError instanceof DOMException && shareError.name === 'AbortError') return
      }
    }
    await copyLink(voucher)
  }

  async function download(voucher: GiftVoucher): Promise<void> {
    setBusyId(voucher.id)
    try {
      await downloadGiftArtwork(voucher)
    } catch (downloadError) {
      setError(giftErrorMessage(downloadError, 'The gift image could not be downloaded. Try again.'))
    } finally {
      setBusyId(null)
    }
  }

  function edit(voucher: GiftVoucher): void {
    setEditing(voucher)
    setDuration(voucher.duration_months)
    setFromName(voucher.from_name)
    setToName(voucher.to_name)
    setRecipientEmail('')
    setMessage(voucher.message || '')
    setOccasion(voucher.occasion || null)
    setOccasionGreeting(voucher.occasion_greeting || '')
    setCreated(null)
    setNotice('Editing an unclaimed gift. Its term and value cannot change.')
    formRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }

  async function rotate(voucher: GiftVoucher): Promise<void> {
    if (!window.confirm('Rotate this private link? The previous link and any legacy code will stop working.')) return
    setBusyId(voucher.id)
    try {
      const updated = await rotateGiftLink(voucher.id)
      setCreated(updated)
      setNotice('Private link rotated. Share the new link or image.')
      await loadData()
    } catch (rotateError) {
      setError(giftErrorMessage(rotateError, 'The private link could not be rotated. Try again.'))
    } finally {
      setBusyId(null)
    }
  }

  async function claimIncoming(voucher: GiftVoucher): Promise<void> {
    setBusyId(voucher.id)
    setError(null)
    setNotice(null)
    try {
      const result = await claimAssignedGift(voucher.id)
      setNotice(
        result.entitlement_status === 'active'
          ? 'Your FitCheck Pro gift is active.'
          : 'Your FitCheck Pro gift is queued after your current entitlement.',
      )
      await loadData()
    } catch (claimError) {
      setError(giftErrorMessage(claimError, 'The gift could not be claimed. Try again.'))
    } finally {
      setBusyId(null)
    }
  }

  return (
    <div className="app-page max-w-[1440px] !py-6 lg:!px-10 lg:!py-10">
      <PageHeader
        title="Gift FitCheck Pro"
        description="Create a private fashion-house invitation for someone you care about."
        leading={<Gift className="h-6 w-6 text-primary" aria-hidden="true" />}
      />

      {!user?.email_verified && (
        <Alert className="mt-6 border-primary/30 bg-primary/5">
          <AlertTitle>Verify your email first</AlertTitle>
          <AlertDescription>Verified accounts can create and claim private gifts.</AlertDescription>
        </Alert>
      )}

      {(notice || error) && (
        <Alert
          variant={error ? 'destructive' : 'default'}
          className="mt-6"
          aria-live={error ? 'assertive' : 'polite'}
        >
          {error ? null : <Check className="h-4 w-4" aria-hidden="true" />}
          <AlertTitle>{error ? 'Gift action not completed' : 'Done'}</AlertTitle>
          <AlertDescription>{error || notice}</AlertDescription>
        </Alert>
      )}

      {incoming.length > 0 && (
        <section ref={incomingRef} className="mt-6" aria-labelledby="incoming-gifts-title">
          <Card className="border-primary/30 bg-primary/5">
            <CardContent className="p-5 sm:p-6">
              <p className="font-display text-xs font-bold uppercase tracking-[0.24em] text-primary">Gift inbox</p>
              <h2 id="incoming-gifts-title" className="mt-2 font-display text-2xl font-bold">
                {giftIncomingTitle(incoming.length)}
              </h2>
              <div className="mt-4 space-y-3">
                {incoming.map((voucher) => (
                  <article
                    key={voucher.id}
                    className={cn(
                      'flex flex-col gap-3 rounded-md border border-border bg-card p-4 sm:flex-row sm:items-center sm:justify-between',
                      selectedIncomingId === voucher.id && 'border-primary ring-1 ring-primary/30',
                    )}
                  >
                    <div>
                      <p className="font-semibold">From {voucher.from_name}</p>
                      <VoucherSummary
                        voucher={voucher}
                        termText={`${giftTermLabel(voucher.duration_months)} of FitCheck Pro`}
                        className="mt-0.5"
                        showMessage={false}
                      />
                    </div>
                    <Button onClick={() => void claimIncoming(voucher)} disabled={busyId === voucher.id}>
                      {busyId === voucher.id ? <Loader2 className="animate-spin" aria-hidden="true" /> : <Gift aria-hidden="true" />}
                      Claim gift
                    </Button>
                  </article>
                ))}
              </div>
            </CardContent>
          </Card>
        </section>
      )}

      <section ref={formRef} className="mt-8 grid gap-8 xl:grid-cols-[minmax(0,1fr)_minmax(380px,0.82fr)] xl:gap-12">
        <form onSubmit={submitGift} className="space-y-8">
          <div>
            <p className="font-display text-xs font-bold uppercase tracking-[0.24em] text-primary">
              01 / Choose the invitation
            </p>
            <h2 className="mt-2 font-display text-2xl font-bold tracking-tight">How much Pro will you give?</h2>
            <div className="mt-4 grid grid-cols-1 xs:grid-cols-3 gap-2">
              {catalog.map((option) => {
                const remaining = allowances.find((item) => item.duration_months === option.duration_months)?.remaining_count || 0
                return (
                  <button
                    key={option.duration_months}
                    type="button"
                    aria-pressed={duration === option.duration_months}
                    disabled={Boolean(editing)}
                    onClick={() => {
                      setDuration(option.duration_months)
                      resetIntent()
                    }}
                    className={cn(
                      'min-h-24 rounded-md border p-3 text-left transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
                      duration === option.duration_months
                        ? 'border-primary bg-primary/5'
                        : 'border-border bg-card hover:border-foreground/30',
                      editing && 'cursor-not-allowed opacity-70',
                    )}
                  >
                    <span className="block font-display text-base font-bold">{giftTermLabel(option.duration_months)}</span>
                    <span className="mt-1 block text-xs text-muted-foreground">
                      {formatUsd(option.retail_value_cents)} value
                    </span>
                    <span className="mt-2 block text-xs font-semibold text-primary">{remaining} free left</span>
                  </button>
                )
              })}
            </div>
          </div>

          {!editing && (
            <div>
              <p className="font-display text-xs font-bold uppercase tracking-[0.24em] text-primary">
                02 / Select how to send it
              </p>
              <div className="mt-4 grid gap-3 sm:grid-cols-2">
                <button
                  type="button"
                  aria-pressed={mode === 'complimentary'}
                  onClick={() => {
                    setMode('complimentary')
                    resetIntent()
                  }}
                  className={cn(
                    'rounded-md border p-4 text-left focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
                    mode === 'complimentary' ? 'border-primary bg-primary/5' : 'border-border bg-card',
                  )}
                >
                  <Sparkles className="h-5 w-5 text-primary" aria-hidden="true" />
                  <span className="mt-3 block font-display font-bold">Use a free invitation</span>
                  <span className="mt-1 block text-sm text-muted-foreground">
                    {freeRemaining} of this term remaining. Claim within 6 months.
                  </span>
                </button>
                <button
                  type="button"
                  aria-pressed={mode === 'paid'}
                  disabled={!selected.paid_available}
                  onClick={() => {
                    setMode('paid')
                    resetIntent()
                  }}
                  className={cn(
                    'rounded-md border p-4 text-left focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-55',
                    mode === 'paid' ? 'border-primary bg-primary/5' : 'border-border bg-card',
                  )}
                >
                  <Send className="h-5 w-5 text-primary" aria-hidden="true" />
                  <span className="mt-3 block font-display font-bold">Purchase this gift</span>
                  <span className="mt-1 block text-sm text-muted-foreground">
                    {formatUsd(selected.retail_value_cents)} once. No expiry before claim.
                  </span>
                </button>
              </div>
              {mode === 'complimentary' && (
                <p className="mt-3 text-xs leading-relaxed text-muted-foreground">
                  Promotional gift. It expires 6 calendar months after issue. Creating it permanently uses one free slot, even if it expires or is voided.
                </p>
              )}
            </div>
          )}

          <div>
            <p className="font-display text-xs font-bold uppercase tracking-[0.24em] text-primary">
              {editing ? '02' : '03'} / Personalize it
            </p>
            <div className="mt-4 grid gap-5 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="gift-from">From</Label>
                <Input
                  id="gift-from"
                  name="from_name"
                  autoComplete="name"
                  value={fromName}
                  maxLength={80}
                  required
                  onChange={(event) => {
                    setFromName(event.target.value)
                    resetIntent()
                  }}
                />
              </div>
              {!editing && (
                <div className="space-y-2 sm:col-span-2">
                  <Label htmlFor="gift-recipient-email">Recipient email</Label>
                  <Input
                    id="gift-recipient-email"
                    name="recipient_email"
                    type="email"
                    autoComplete="email"
                    value={recipientEmail}
                    maxLength={320}
                    required
                    placeholder="name@example.com"
                    onChange={(event) => {
                      setRecipientEmail(event.target.value)
                      resetIntent()
                    }}
                  />
                  <p className="text-xs text-muted-foreground">
                    The gift can only be claimed by this verified email. We do not send email for you.
                  </p>
                </div>
              )}
              <div className="space-y-2">
                <Label htmlFor="gift-to">To</Label>
                <Input
                  id="gift-to"
                  name="to_name"
                  autoComplete="off"
                  value={toName}
                  maxLength={80}
                  required
                  placeholder="Their name"
                  onChange={(event) => {
                    setToName(event.target.value)
                    resetIntent()
                  }}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="gift-occasion">Occasion (optional)</Label>
                <Select
                  value={occasion ?? 'none'}
                  onValueChange={(value) => {
                    const nextOccasion = GIFT_OCCASIONS.find((option) => option.value === value)?.value ?? null
                    setOccasion(nextOccasion)
                    if (nextOccasion !== 'other') setOccasionGreeting('')
                    resetIntent()
                  }}
                >
                  <SelectTrigger id="gift-occasion"><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">No occasion</SelectItem>
                    {GIFT_OCCASIONS.map((option) => (
                      <SelectItem key={option.value} value={option.value}>{option.label}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              {occasion === 'other' && (
                <div className="space-y-2 sm:col-span-2">
                  <div className="flex items-center justify-between">
                    <Label htmlFor="gift-occasion-greeting">Card greeting</Label>
                    <span id="gift-occasion-greeting-count" className="text-xs text-muted-foreground">{occasionGreeting.length}/80</span>
                  </div>
                  <Input
                    id="gift-occasion-greeting"
                    name="occasion_greeting"
                    value={occasionGreeting}
                    maxLength={80}
                    required
                    placeholder="Congratulations!"
                    aria-describedby="gift-occasion-greeting-count"
                    onChange={(event) => {
                      setOccasionGreeting(event.target.value)
                      resetIntent()
                    }}
                  />
                  <p className="text-xs text-muted-foreground">This appears as the card heading exactly as written.</p>
                </div>
              )}
              <div className="space-y-2 sm:col-span-2">
                <div className="flex items-center justify-between">
                  <Label htmlFor="gift-message">Private note (optional)</Label>
                  <span id="gift-message-count" className="text-xs text-muted-foreground">{message.length}/240</span>
                </div>
                <Textarea
                  id="gift-message"
                  name="message"
                  aria-describedby="gift-message-count"
                  value={message}
                  maxLength={240}
                  rows={4}
                  placeholder="A few words for the person receiving it…"
                  onChange={(event) => {
                    setMessage(event.target.value)
                    resetIntent()
                  }}
                />
              </div>
            </div>
          </div>

          <div className="flex flex-col gap-3 sm:flex-row">
            <Button type="submit" size="lg" disabled={!canCreate || isSubmitting} className="sm:min-w-52">
              {isSubmitting ? <Loader2 className="animate-spin" aria-hidden="true" /> : editing ? <Edit3 aria-hidden="true" /> : <Gift aria-hidden="true" />}
              {editing ? 'Save gift details' : mode === 'paid' ? `Continue to pay ${formatUsd(selected.retail_value_cents)}` : 'Create free gift'}
            </Button>
            {editing && (
              <Button type="button" variant="outline" size="lg" onClick={resetForm}>
                Cancel editing
              </Button>
            )}
          </div>
        </form>

        <aside className="xl:sticky xl:top-8 xl:self-start">
          <div className="mx-auto max-w-[520px]">
            <div className="mb-3 flex items-center justify-between">
              <p className="font-display text-xs font-bold uppercase tracking-[0.2em] text-muted-foreground">Live artwork preview</p>
              <Badge variant="outline">1080 × 1350 download</Badge>
            </div>
            <GiftCardPreview
              fromName={fromName}
              toName={toName}
              message={message}
              occasion={occasion}
              occasionGreeting={occasionGreeting}
              duration={duration}
              retailValueCents={selected.retail_value_cents}
              expiresAt={mode === 'complimentary' && !editing ? freeExpiry : editing?.expires_at}
            />
            <p className="mt-3 text-center text-xs text-muted-foreground">
              Paid, complimentary, and staff-issued gifts use the same artwork and show retail value truthfully.
            </p>
          </div>
        </aside>
      </section>

      {created?.share_url && (
        <Card className="mt-10 overflow-hidden border-primary/30 bg-primary/5">
          <CardContent className="grid gap-5 p-5 sm:grid-cols-[1fr_auto] sm:items-center sm:p-6">
            <div>
              <p className="font-display text-xl font-bold">Your private invitation is ready</p>
              <p className="mt-1 text-sm text-muted-foreground">
                Send the secure link separately. You can also download the portrait artwork. The recipient must claim it with the verified email you entered.
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <Button variant="outline" onClick={() => copyLink(created)}><Copy aria-hidden="true" /> Copy link</Button>
              <Button variant="outline" onClick={() => download(created)} disabled={busyId === created.id}>
                {busyId === created.id ? <Loader2 className="animate-spin" aria-hidden="true" /> : <Download aria-hidden="true" />} Download
              </Button>
              <Button onClick={() => shareGift(created)}><Share2 aria-hidden="true" /> Share gift</Button>
              <Button
                variant="ghost"
                aria-label="Share on WhatsApp"
                onClick={() => window.open(`https://wa.me/?text=${encodeURIComponent(`A FitCheck Pro gift for you: ${created.share_url}`)}`, '_blank', 'noopener,noreferrer')}
              >
                <ExternalLink aria-hidden="true" /> WhatsApp
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      <section className="mt-12 border-t border-border pt-8">
        <div className="flex items-end justify-between gap-4">
          <div>
            <p className="font-display text-xs font-bold uppercase tracking-[0.24em] text-primary">Your private gift ledger</p>
            <h2 className="mt-2 font-display text-2xl font-bold">Sent and received</h2>
          </div>
          <Button variant="ghost" size="sm" onClick={() => void loadData()} disabled={isLoading}>
            <RefreshCw className={cn(isLoading && 'animate-spin')} aria-hidden="true" /> Refresh
          </Button>
        </div>

        <Tabs defaultValue="sent" className="mt-5">
          <TabsList className="w-full justify-start sm:w-auto">
            <TabsTrigger value="sent">Sent ({sent.length})</TabsTrigger>
            <TabsTrigger value="received">Received ({received.length})</TabsTrigger>
          </TabsList>
          <TabsContent value="sent" className="mt-4">
            <HistoryList
              items={sent}
              kind="sent"
              onEdit={edit}
              onRotate={rotate}
              onShare={shareGift}
              onCopy={copyLink}
              onDownload={download}
              busyId={busyId}
            />
          </TabsContent>
          <TabsContent value="received" className="mt-4">
            <HistoryList
              items={received}
              kind="received"
              onEdit={edit}
              onRotate={rotate}
              onShare={shareGift}
              onCopy={copyLink}
              onDownload={download}
              busyId={busyId}
            />
          </TabsContent>
        </Tabs>
      </section>
    </div>
  )
}
