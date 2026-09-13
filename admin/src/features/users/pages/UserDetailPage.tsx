import { ArrowLeft, ExternalLink } from 'lucide-react'
import { lazy, Suspense, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useParams, useSearchParams } from 'react-router-dom'
import { toast } from 'sonner'

import {
  useClearDailyCounters,
  useExtendTrial,
  usePatchUser,
  useUserActivityQuery,
  useUserDetailQuery,
} from '@/features/users/api/users'
import {
  arrayValue,
  assignableRoles,
  booleanValue,
  displayName,
  failedJobsLastDays,
  isTrialEndingSoon,
  numberValue,
  planLabelKey,
  roleLabelKey,
  stringValue,
  subscriptionPlan,
  subscriptionStatus,
  type JsonRecord,
} from '@/features/users/lib/users'
import { normalizeError } from '@/shared/api/errors'
import type { AdminUserPatch } from '@/shared/api/schemaTypes'
import { usePermission } from '@/shared/hooks/usePermission'
import { formatDateTimeValue, formatMoney, formatNumber } from '@/shared/lib/formatters'
import { Avatar, AvatarFallback, AvatarImage } from '@/shared/ui/avatar'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/ui/card'
import { ConfirmDialog } from '@/shared/ui/ConfirmDialog'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/shared/ui/dialog'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { Input } from '@/shared/ui/input'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui/select'
import { Skeleton } from '@/shared/ui/skeleton'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import { Switch } from '@/shared/ui/switch'

const ItemsGrid = lazy(() => import('@/features/users/components/ItemsGrid'))
const OutfitsGallery = lazy(() => import('@/features/users/components/OutfitsGallery'))
const Timeline = lazy(() => import('@/features/users/components/Timeline'))
const CollectionsTripsStreaks = lazy(
  () => import('@/features/users/components/CollectionsTripsStreaks'),
)
const CountsStrip = lazy(() => import('@/features/users/components/CountsStrip'))

type PendingAction =
  | { kind: 'role'; value: string }
  | { kind: 'admin'; value: boolean }
  | { kind: 'status'; value: boolean }

function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean)
  if (parts.length === 0) return '?'
  const first = parts[0]?.[0] ?? ''
  const last = parts.length > 1 ? parts[parts.length - 1]?.[0] ?? '' : ''
  return `${first}${last}`.toUpperCase()
}

function Field({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-4 py-1.5">
      <dt className="text-xs text-muted-foreground">{label}</dt>
      <dd className="max-w-[60%] text-right text-xs font-medium text-ink">{value}</dd>
    </div>
  )
}

function SectionSkeleton() {
  return (
    <Card>
      <CardHeader className="py-2">
        <Skeleton className="h-4 w-32" />
      </CardHeader>
      <CardContent className="space-y-2 py-2">
        <Skeleton className="h-3 w-full" />
        <Skeleton className="h-3 w-2/3" />
        <Skeleton className="h-20 w-full" />
      </CardContent>
    </Card>
  )
}

export function UserDetailPage() {
  const { id } = useParams<{ id: string }>()
  const userId = id ?? ''
  const [searchParams, setSearchParams] = useSearchParams()
  const { t } = useTranslation('users')
  const { can } = usePermission()
  const canManageUser = can('users.write')
  const canExtendTrial = canManageUser || can('subscriptions.write')

  const detailQuery = useUserDetailQuery(userId, { enabled: userId !== '' })
  const activityQuery = useUserActivityQuery(userId, { enabled: userId !== '' })
  const patchMutation = usePatchUser()
  const extendTrialMutation = useExtendTrial()
  const clearCountersMutation = useClearDailyCounters()

  const [pendingAction, setPendingAction] = useState<PendingAction | null>(null)
  const [extendOpen, setExtendOpen] = useState(false)
  const [extendDays, setExtendDays] = useState('7')
  const [clearOpen, setClearOpen] = useState(false)

  const outfitsTab = searchParams.get('outfits_tab') ?? 'outfits'

  const detail = detailQuery.data as (typeof detailQuery.data & JsonRecord) | undefined
  const userRecord = detail?.user as JsonRecord | undefined
  const name = displayName(userRecord)
  const email = stringValue(userRecord, 'email') ?? '—'
  const active = booleanValue(userRecord, 'is_active') !== false
  const role = stringValue(userRecord, 'role')
  const isAdmin = booleanValue(userRecord, 'is_admin') === true

  const subscription = detail?.subscription as JsonRecord | null | undefined
  const usage = detail?.usage as JsonRecord | undefined
  const aiUsage = usage?.ai as JsonRecord | undefined
  const subUsage = usage?.subscription_usage as JsonRecord | undefined
  const counts = detail?.counts as JsonRecord | undefined

  const subPlan = subscriptionPlan(subscription)
  const subPlanLabel = subPlan ? planLabelKey(subPlan) : null
  const subStatus = subscriptionStatus(subscription)

  // Extended keys — degrade gracefully when backend hasn't yet shipped them
  const extended = detail as JsonRecord | undefined
  // Backend already caps the embedded items list (12); slice defensively only.
  const items: JsonRecord[] = useMemo(() => arrayValue(extended, 'items').slice(0, 12), [extended])
  const outfits: JsonRecord[] = useMemo(
    () => arrayValue(extended, 'outfits').slice(0, 12),
    [extended],
  )
  const photoshootJobs: JsonRecord[] = useMemo(() => {
    const raw =
      arrayValue(extended, 'photoshoot').length > 0
        ? arrayValue(extended, 'photoshoot')
        : arrayValue(extended, 'photoshoot_jobs')
    // Also merge recent_jobs that are photoshoot type when extended key missing
    const fallback =
      raw.length === 0
        ? ((detail?.recent_jobs as unknown as JsonRecord[] | undefined) ?? []).filter(
            (j) => stringValue(j, 'job_type') === 'photoshoot' || stringValue(j, 'use_case') !== null,
          )
        : []
    return (raw.length > 0 ? raw : fallback).slice(0, 12)
  }, [extended, detail?.recent_jobs])
  const collections: JsonRecord[] = useMemo(() => arrayValue(extended, 'collections'), [extended])
  const trips: JsonRecord[] = useMemo(() => arrayValue(extended, 'trips'), [extended])
  const achievements: JsonRecord[] = useMemo(
    () => arrayValue(extended, 'achievements'),
    [extended],
  )
  const streaks: JsonRecord | null = useMemo(() => {
    const s = extended?.['streaks'] ?? extended?.['streak']
    if (s && typeof s === 'object' && !Array.isArray(s)) return s as JsonRecord
    if (Array.isArray(achievements) && achievements.length > 0) return null
    return null
  }, [extended, achievements])

  const socialImportJobs: JsonRecord[] = useMemo(
    () => arrayValue(extended, 'social_import_jobs'),
    [extended],
  )
  const supportTickets: JsonRecord[] = useMemo(() => {
    const fromDetail = arrayValue(extended, 'support_tickets')
    if (fromDetail.length > 0) return fromDetail.slice(0, 5)
    return []
  }, [extended])

  // Activity timeline sources — merge activityQuery + extended detail
  const auditEvents: JsonRecord[] = useMemo(() => {
    const fromActivity = (activityQuery.data?.audit_events as unknown as JsonRecord[] | undefined) ?? []
    const fromDetail = arrayValue(extended, 'audit_events')
    // Prefer activityQuery, fallback to detail
    return fromActivity.length > 0 ? fromActivity : fromDetail
  }, [activityQuery.data?.audit_events, extended])
  const recentJobs: JsonRecord[] = useMemo(() => {
    const fromActivity = (activityQuery.data?.recent_jobs as unknown as JsonRecord[] | undefined) ?? []
    const fromDetail = (detail?.recent_jobs as unknown as JsonRecord[] | undefined) ?? []
    // Dedupe by id
    const seen = new Set<string>()
    const merged: JsonRecord[] = []
    for (const j of [...fromActivity, ...fromDetail]) {
      const id = stringValue(j, 'id') ?? ''
      if (id && seen.has(id)) continue
      if (id) seen.add(id)
      merged.push(j)
    }
    return merged
  }, [activityQuery.data?.recent_jobs, detail?.recent_jobs])

  // Risk badges
  const riskBadges = useMemo(() => {
    const badges: Array<{ key: string; label: string; variant: 'warning' | 'danger' | 'info' }> = []
    if (isTrialEndingSoon(subscription)) {
      badges.push({
        key: 'trial',
        label: t('detail.riskTrialEnding'),
        variant: 'warning',
      })
    }
    if (subStatus === 'past_due') {
      badges.push({
        key: 'pastdue',
        label: t('detail.riskPastDue'),
        variant: 'danger',
      })
    }
    // Quota 90%+ : daily counts vs custom_daily_quota
    const customQuota = numberValue(userRecord, 'custom_daily_quota')
    if (customQuota && customQuota > 0 && aiUsage) {
      const dailyExtraction = numberValue(aiUsage, 'daily_extraction_count') ?? 0
      const dailyGeneration = numberValue(aiUsage, 'daily_generation_count') ?? 0
      const dailyEmbedding = numberValue(aiUsage, 'daily_embedding_count') ?? 0
      const maxUsed = Math.max(dailyExtraction, dailyGeneration, dailyEmbedding)
      if (maxUsed / customQuota >= 0.9) {
        badges.push({
          key: 'quota',
          label: t('detail.riskQuotaHigh'),
          variant: 'warning',
        })
      }
    }
    const failedCount = failedJobsLastDays(recentJobs, 7)
    if (failedCount >= 3) {
      badges.push({
        key: 'failed',
        label: t('detail.riskFailedJobs'),
        variant: 'danger',
      })
    }
    return badges
  }, [subscription, subStatus, userRecord, aiUsage, recentJobs, t])

  const amount = numberValue(subscription, 'amount')
  const stripeCustomerId = stringValue(subscription, 'stripe_customer_id')
  const stripeSubscriptionId = stringValue(subscription, 'stripe_subscription_id')

  const countRows = useMemo(() => {
    if (!counts) return []
    const entries = Object.entries(counts)
      .filter(([, value]) => typeof value === 'number')
      .sort(([a], [b]) => a.localeCompare(b))
    return entries.map(([key, value]) => ({ key, value: value as number }))
  }, [counts])

  async function runPatch(body: AdminUserPatch) {
    try {
      await patchMutation.mutateAsync({ userId, body })
      if (body.role !== undefined && body.role !== null) {
        toast.success(t('detail.roleSavedToast'))
      } else if (body.is_admin !== undefined) {
        toast.success(t('detail.adminSavedToast'))
      } else if (body.is_active !== undefined) {
        toast.success(t(body.is_active ? 'detail.activatedToast' : 'detail.suspendedToast', { name }))
      }
    } catch (error) {
      toast.error(normalizeError(error).message)
      throw error
    }
  }

  async function handleExtendTrial() {
    const days = Number(extendDays)
    if (!Number.isInteger(days) || days < 1 || days > 90) {
      toast.error(t('detail.extendTrialInvalidDays'))
      return
    }
    try {
      await extendTrialMutation.mutateAsync({ userId, days })
      toast.success(t('detail.extendTrialSuccess', { days }))
      setExtendOpen(false)
    } catch (error) {
      toast.error(normalizeError(error).message)
    }
  }

  async function handleClearCounters() {
    try {
      await clearCountersMutation.mutateAsync({ userId })
      toast.success(t('detail.clearCountersSuccess'))
      setClearOpen(false)
    } catch (error) {
      toast.error(normalizeError(error).message)
      throw error
    }
  }

  if (userId === '') {
    return <EmptyState title={t('detail.notFoundTitle')} message={t('detail.notFoundMessage')} />
  }

  if (detailQuery.isError) {
    const apiError = normalizeError(detailQuery.error)
    if (apiError.code === 'USER_NOT_FOUND') {
      return (
        <div className="space-y-3">
          <EmptyState title={t('detail.notFoundTitle')} message={t('detail.notFoundMessage')} />
        </div>
      )
    }
    return (
      <div className="space-y-3">
        <ErrorState message={apiError.message} onRetry={() => void detailQuery.refetch()} />
      </div>
    )
  }

  const confirmDescription = pendingAction
    ? pendingAction.kind === 'role'
      ? t('detail.roleConfirmDescription')
      : pendingAction.kind === 'admin'
        ? t(pendingAction.value ? 'detail.adminConfirmGrant' : 'detail.adminConfirmRevoke', { name })
        : t(
            pendingAction.value ? 'detail.activateConfirmDescription' : 'detail.suspendConfirmDescription',
            { name },
          )
    : null
  const confirmLabel =
    pendingAction?.kind === 'status' ? t(pendingAction.value ? 'detail.activate' : 'detail.suspend') : null

  return (
    <div className="space-y-3">
      <div className="flex justify-end">
        <Button variant="outline" size="sm" asChild>
          <Link to="/users">
            <ArrowLeft aria-hidden="true" />
            {t('back')}
          </Link>
        </Button>
      </div>

      {/* Anchor nav — jump to any of the 8 sections, sticky for long 360 page */}
      {!detailQuery.isPending && !detailQuery.isError ? (
        <nav
          aria-label={t('detail.sectionsNavLabel')}
          className="sticky top-0 z-10 -mx-1 flex gap-1.5 overflow-x-auto border-b border-border bg-background/80 px-1 py-2 backdrop-blur supports-[backdrop-filter]:bg-background/60"
        >
          {[
            { id: 'section-identity', label: t('detail.navIdentity') },
            { id: 'section-subscription', label: t('detail.navSubscription') },
            { id: 'section-usage', label: t('detail.navUsage') },
            { id: 'section-uploads', label: t('detail.navUploads') },
            { id: 'section-generations', label: t('detail.navGenerations') },
            { id: 'section-collections', label: t('detail.navCollections') },
            { id: 'section-counts', label: t('detail.navCounts') },
            { id: 'section-timeline', label: t('detail.navTimeline') },
          ].map((item) => (
            <button
              key={item.id}
              type="button"
              onClick={() => {
                const el = document.getElementById(item.id)
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
              }}
              className="whitespace-nowrap rounded-full bg-surface-card px-3 py-1 text-xs font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              {item.label}
            </button>
          ))}
        </nav>
      ) : null}

      {detailQuery.isPending ? (
        <div className="space-y-3">
          <div className="grid gap-3 lg:grid-cols-3">
            <Card className="lg:col-span-2">
              <CardHeader>
                <Skeleton className="h-6 w-48" />
              </CardHeader>
              <CardContent className="space-y-3">
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-4 w-2/3" />
                <Skeleton className="h-4 w-1/2" />
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <Skeleton className="h-6 w-32" />
              </CardHeader>
              <CardContent className="space-y-3">
                <Skeleton className="h-10 w-full" />
                <Skeleton className="h-10 w-full" />
              </CardContent>
            </Card>
          </div>
          <SectionSkeleton />
          <SectionSkeleton />
        </div>
      ) : (
        <>
          {/* Section 1: Identity + risk header */}
          <Card id="section-identity" className="scroll-mt-16">
            <CardHeader>
              <div className="flex items-center gap-4">
                <Avatar className="size-14">
                  <AvatarImage src={stringValue(userRecord, 'avatar_url') ?? undefined} alt={name} />
                  <AvatarFallback>{initials(name)}</AvatarFallback>
                </Avatar>
                <div className="min-w-0">
                  <h1 className="truncate text-xl font-semibold tracking-tight text-ink">{name}</h1>
                  <CardDescription className="truncate">{email}</CardDescription>
                </div>
                <div className="ml-auto flex flex-wrap items-center justify-end gap-2">
                  <Badge variant="default">{t(roleLabelKey(role))}</Badge>
                  <StatusBadge
                    status={active ? 'active' : 'suspended'}
                    label={t(active ? 'status.active' : 'status.suspended')}
                  />
                  {riskBadges.map((badge) => (
                    <Badge key={badge.key} variant={badge.variant}>
                      {badge.label}
                    </Badge>
                  ))}
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <dl className="divide-y divide-border">
                <Field label={t('detail.memberSince')} value={formatDateTimeValue(userRecord?.created_at)} />
                <Field
                  label={t('detail.lastLogin')}
                  value={
                    userRecord?.last_login_at
                      ? formatDateTimeValue(userRecord.last_login_at)
                      : t('detail.neverLoggedIn')
                  }
                />
                <Field
                  label={t('detail.emailVerified')}
                  value={
                    <Badge variant={booleanValue(userRecord, 'email_verified') ? 'success' : 'warning'}>
                      {t(
                        booleanValue(userRecord, 'email_verified')
                          ? 'detail.emailVerified'
                          : 'detail.emailUnverified',
                      )}
                    </Badge>
                  }
                />
                <Field
                  label={t('detail.customQuota')}
                  value={numberValue(userRecord, 'custom_daily_quota') ?? t('detail.planDefault')}
                />
              </dl>
            </CardContent>
          </Card>

          {/* Admin actions row — kept directly under identity for visibility, still gated */}
          <Card>
            <CardHeader>
              <CardTitle>{t('detail.actions')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {canExtendTrial ? (
                <>
                  {canManageUser ? (
                    <div className="grid gap-4 sm:grid-cols-2">
                      <div className="space-y-2">
                        <label htmlFor="user-role-select" className="text-sm font-medium">
                          {t('detail.role')}
                        </label>
                        <Select
                          value={role ?? 'user'}
                          onValueChange={(value) => setPendingAction({ kind: 'role', value })}
                        >
                          <SelectTrigger id="user-role-select" className="w-full">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            {assignableRoles().map((option) => (
                              <SelectItem key={option} value={option}>
                                {t(roleLabelKey(option))}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                      <div className="flex items-end justify-between gap-4 rounded-md border border-border px-3 py-2">
                        <div className="space-y-0.5">
                          <p className="text-sm font-medium">{t('detail.isAdmin')}</p>
                          <p className="text-xs text-muted-foreground">{t('detail.isAdminHint')}</p>
                        </div>
                        <Switch
                          checked={isAdmin}
                          onCheckedChange={(value) => setPendingAction({ kind: 'admin', value })}
                          aria-label={t('detail.isAdmin')}
                        />
                      </div>
                    </div>
                  ) : null}

                  <div className="grid gap-3 sm:grid-cols-3">
                    {canManageUser ? (
                      <Button
                        variant={active ? 'destructive' : 'secondary'}
                        onClick={() => setPendingAction({ kind: 'status', value: !active })}
                        disabled={patchMutation.isPending}
                      >
                        {t(active ? 'detail.suspend' : 'detail.activate')}
                      </Button>
                    ) : null}
                    <Button variant="outline" onClick={() => setExtendOpen(true)} disabled={extendTrialMutation.isPending}>
                      {t('detail.extendTrial')}
                    </Button>
                    {canManageUser ? (
                      <Button variant="outline" onClick={() => setClearOpen(true)} disabled={clearCountersMutation.isPending}>
                        {t('detail.clearCounters')}
                      </Button>
                    ) : null}
                  </div>
                </>
              ) : (
                <p className="text-sm text-muted-foreground">{t('detail.noWriteAccess')}</p>
              )}
            </CardContent>
          </Card>

          {/* BENTO RowA: Subscription (5) + Usage+Counts (7) */}
          <div className="grid gap-4 lg:grid-cols-12">
            <div id="section-subscription" className="scroll-mt-16 lg:col-span-5">
          {/* Section 2: Subscription & billing */}
          <Card>
            <CardHeader>
              <CardTitle>{t('detail.subscription')}</CardTitle>
            </CardHeader>
            <CardContent>
              {subscription ? (
                <dl className="divide-y divide-border">
                  <Field
                    label={t('columns.plan')}
                    value={subPlanLabel ? t(subPlanLabel) : subPlan ?? t('plans.none')}
                  />
                  <Field
                    label={t('detail.status')}
                    value={<StatusBadge {...(subStatus ? { status: subStatus, label: subStatus } : { label: '—' })} />}
                  />
                  <Field label={t('detail.billingProvider')} value={stringValue(subscription, 'billing_provider') ?? '—'} />
                  <Field
                    label={t('detail.currentPeriod')}
                    value={
                      stringValue(subscription, 'current_period_start')
                        ? `${formatDateTimeValue(subscription.current_period_start)} → ${formatDateTimeValue(subscription.current_period_end)}`
                        : '—'
                    }
                  />
                  <Field
                    label={t('detail.cancelAtPeriodEnd')}
                    value={booleanValue(subscription, 'cancel_at_period_end') ? t('common:yes') : t('common:no')}
                  />
                  <Field label={t('detail.trialEnd')} value={formatDateTimeValue(subscription.trial_end)} />
                  <Field
                    label={t('detail.referralCreditMonths')}
                    value={numberValue(subscription, 'referral_credit_months') ?? '—'}
                  />
                  <Field
                    label={t('detail.amount')}
                    value={amount !== null ? formatMoney(amount, 'USD') : '—'}
                  />
                  <Field
                    label={t('detail.stripeCustomer')}
                    value={
                      stripeCustomerId ? (
                        <a
                          href={`https://dashboard.stripe.com/customers/${stripeCustomerId}`}
                          target="_blank"
                          rel="noreferrer"
                          className="inline-flex items-center gap-1 text-primary underline-offset-4 hover:underline"
                        >
                          {stripeCustomerId}
                          <ExternalLink className="size-3" aria-hidden="true" />
                          <span className="sr-only">{t('detail.viewInStripe')}</span>
                        </a>
                      ) : (
                        '—'
                      )
                    }
                  />
                  <Field
                    label={t('detail.stripeSubscription')}
                    value={
                      stripeSubscriptionId ? (
                        <a
                          href={`https://dashboard.stripe.com/subscriptions/${stripeSubscriptionId}`}
                          target="_blank"
                          rel="noreferrer"
                          className="inline-flex items-center gap-1 text-primary underline-offset-4 hover:underline"
                        >
                          {stripeSubscriptionId}
                          <ExternalLink className="size-3" aria-hidden="true" />
                        </a>
                      ) : (
                        '—'
                      )
                    }
                  />
                </dl>
              ) : (
                <p className="text-sm text-muted-foreground">{t('detail.noSubscription')}</p>
              )}
            </CardContent>
          </Card>
            </div>
            <div id="section-usage" className="scroll-mt-16 lg:col-span-7">
          {/* Section 3: Usage */}
          <div className="grid gap-3 lg:grid-cols-3">
            <Card className="lg:col-span-2">
              <CardHeader>
                <CardTitle>{t('detail.usage')}</CardTitle>
              </CardHeader>
              <CardContent>
                <dl className="divide-y divide-border">
                  <Field
                    label={t('detail.dailyExtractions')}
                    value={numberValue(aiUsage, 'daily_extraction_count') ?? '—'}
                  />
                  <Field
                    label={t('detail.dailyGenerations')}
                    value={numberValue(aiUsage, 'daily_generation_count') ?? '—'}
                  />
                  <Field
                    label={t('detail.dailyEmbeddings')}
                    value={numberValue(aiUsage, 'daily_embedding_count') ?? '—'}
                  />
                  <Field label={t('detail.lastReset')} value={formatDateTimeValue(aiUsage?.last_reset_date)} />
                  <Field
                    label={t('detail.totalExtractions')}
                    value={numberValue(aiUsage, 'total_extractions') ?? '—'}
                  />
                  <Field
                    label={t('detail.totalGenerations')}
                    value={numberValue(aiUsage, 'total_generations') ?? '—'}
                  />
                  <Field
                    label={t('detail.monthlyExtractions')}
                    value={numberValue(subUsage, 'monthly_extractions') ?? '—'}
                  />
                  <Field
                    label={t('detail.monthlyGenerations')}
                    value={numberValue(subUsage, 'monthly_generations') ?? '—'}
                  />
                  <Field
                    label={t('detail.monthlyEmbeddings')}
                    value={numberValue(subUsage, 'monthly_embeddings') ?? '—'}
                  />
                  <Field
                    label={t('detail.dailyPhotoshootImages')}
                    value={numberValue(subUsage, 'daily_photoshoot_images') ?? '—'}
                  />
                  <Field label={t('detail.periodStart')} value={formatDateTimeValue(subUsage?.period_start)} />
                </dl>
              </CardContent>
            </Card>

            {/* Section 7 inline beside usage on desktop: counts strip as small companion, full strip also below */}
            <Card>
              <CardHeader>
                <CardTitle>{t('detail.counts')}</CardTitle>
              </CardHeader>
              <CardContent>
                <dl className="divide-y divide-border">
                  {countRows.map((row) => (
                    <Field
                      key={row.key}
                      label={t(`detail.${row.key}`, { defaultValue: row.key.replaceAll('_', ' ') })}
                      value={formatNumber(row.value)}
                    />
                  ))}
                  {countRows.length === 0 ? (
                    <p className="py-2 text-sm text-muted-foreground">—</p>
                  ) : null}
                </dl>
              </CardContent>
            </Card>
          </div>
            </div>
          </div>

          {/* Section 4: Uploads — Items grid (lazy) */}
          <div id="section-uploads" className="scroll-mt-16">
            <Suspense fallback={<SectionSkeleton />}>
              <ItemsGrid items={items} />
            </Suspense>
          </div>

          {/* BENTO RowD: Generations (7) + Collections (5) */}
          <div className="grid gap-4 lg:grid-cols-12">
            <div className="lg:col-span-7">
          {/* Section 5: Generations — Outfits + Photoshoot (lazy) */}
          <div id="section-generations" className="scroll-mt-16">
            <Suspense fallback={<SectionSkeleton />}>
              <OutfitsGallery
                outfits={outfits}
                photoshootJobs={photoshootJobs}
                defaultTab={outfitsTab}
                onTabChange={(tab: string) => setSearchParams((prev) => {
                  const next = new URLSearchParams(prev)
                  next.set('outfits_tab', tab)
                  return next
                })}
              />
            </Suspense>
          </div>
            </div>
            <div className="lg:col-span-5">
          {/* Section 6: Collections/Trips/Streaks (lazy) */}
          <div id="section-collections" className="scroll-mt-16">
            <Suspense fallback={<SectionSkeleton />}>
              <CollectionsTripsStreaks
                collections={collections}
                trips={trips}
                streaks={streaks}
                achievementsCount={numberValue(counts, 'achievements') ?? achievements.length}
              />
            </Suspense>
          </div>
            </div>
          </div>

          {/* Section 7: Counts strip (lazy) — badge strip across full width */}
          <div id="section-counts" className="scroll-mt-16">
            <Suspense fallback={<SectionSkeleton />}>
              <CountsStrip counts={counts ?? {}} />
            </Suspense>
          </div>

          {/* Section 8: Activity timeline (lazy) */}
          <div id="section-timeline" className="scroll-mt-16">
            {activityQuery.isError ? (
              <ErrorState
                message={normalizeError(activityQuery.error).message}
                onRetry={() => void activityQuery.refetch()}
              />
            ) : (
              <Suspense fallback={<SectionSkeleton />}>
                <Timeline
                  auditEvents={auditEvents}
                  recentJobs={recentJobs}
                  socialImportJobs={socialImportJobs}
                  supportTickets={supportTickets}
                />
              </Suspense>
            )}
          </div>
        </>
      )}

      {/* Confirm dialog for role / admin / status changes */}
      <ConfirmDialog
        open={pendingAction !== null}
        onOpenChange={(open) => {
          if (!open) setPendingAction(null)
        }}
        title={
          pendingAction?.kind === 'role'
            ? t('detail.roleConfirmTitle', {
                role: t(roleLabelKey(pendingAction.value)),
              })
            : pendingAction?.kind === 'admin'
              ? t('detail.adminConfirmTitle')
              : pendingAction?.kind === 'status'
                ? t(pendingAction.value ? 'detail.activateConfirmTitle' : 'detail.suspendConfirmTitle')
                : ''
        }
        {...(confirmDescription ? { description: confirmDescription } : {})}
        {...(confirmLabel ? { confirmLabel } : {})}
        destructive={
          pendingAction?.kind === 'status'
            ? !pendingAction.value
            : pendingAction?.kind === 'admin'
              ? !pendingAction.value
              : false
        }
        onConfirm={() => {
          if (!pendingAction) return Promise.resolve()
          const body =
            pendingAction.kind === 'role'
              ? { role: pendingAction.value }
              : pendingAction.kind === 'admin'
                ? { is_admin: pendingAction.value }
                : { is_active: pendingAction.value }
          return runPatch(body)
        }}
      />

      {/* Extend trial dialog */}
      <Dialog open={extendOpen} onOpenChange={setExtendOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>{t('detail.extendTrialTitle')}</DialogTitle>
            <DialogDescription>
              {t('detail.extendTrialDescription')}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-2">
            <label htmlFor="extend-days" className="text-sm font-medium">
              {t('detail.extendTrialPlaceholder')}
            </label>
            <Input
              id="extend-days"
              type="number"
              min={1}
              max={90}
              value={extendDays}
              onChange={(e) => setExtendDays(e.target.value)}
            />
          </div>
          <DialogFooter>
            <Button variant="secondary" onClick={() => setExtendOpen(false)}>
              {t('common:cancel')}
            </Button>
            <Button
              loading={extendTrialMutation.isPending}
              onClick={() => void handleExtendTrial()}
            >
              {t('detail.extendTrialConfirm')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Clear daily counters confirm */}
      <ConfirmDialog
        open={clearOpen}
        onOpenChange={setClearOpen}
        title={t('detail.clearCountersTitle')}
        description={t('detail.clearCountersDescription')}
        confirmLabel={t('detail.clearCountersConfirm')}
        onConfirm={handleClearCounters}
      />
    </div>
  )
}
