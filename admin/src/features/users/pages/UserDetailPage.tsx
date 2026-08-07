import { ArrowLeft } from 'lucide-react'
import { useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useParams } from 'react-router-dom'
import { toast } from 'sonner'

import { usePatchUser, useUserActivityQuery, useUserDetailQuery } from '@/features/users/api/users'
import {
  assignableRoles,
  booleanValue,
  displayName,
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
import { formatDateTimeValue, formatNumber } from '@/shared/lib/formatters'
import { Avatar, AvatarFallback, AvatarImage } from '@/shared/ui/avatar'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/ui/card'
import { ConfirmDialog } from '@/shared/ui/ConfirmDialog'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { PageHeader } from '@/shared/ui/PageHeader'
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

type PendingAction =
  | { kind: 'role'; value: string }
  | { kind: 'admin'; value: boolean }
  | { kind: 'status'; value: boolean }

/** Avatar initials from a name or email. */
function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean)
  if (parts.length === 0) return '?'
  const first = parts[0]?.[0] ?? ''
  const last = parts.length > 1 ? parts[parts.length - 1]?.[0] ?? '' : ''
  return `${first}${last}`.toUpperCase()
}

/** Label/value row inside a detail card. */
function Field({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-4 py-2">
      <dt className="text-sm text-muted-foreground">{label}</dt>
      <dd className="max-w-[60%] text-right text-sm font-medium text-ink">{value}</dd>
    </div>
  )
}

export function UserDetailPage() {
  const { id } = useParams<{ id: string }>()
  const userId = id ?? ''
  const { t } = useTranslation('users')
  const { can } = usePermission()
  const canWrite = can('users.write')

  const detailQuery = useUserDetailQuery(userId, { enabled: userId !== '' })
  const activityQuery = useUserActivityQuery(userId, { enabled: userId !== '' })
  const patchMutation = usePatchUser()
  const [pendingAction, setPendingAction] = useState<PendingAction | null>(null)

  const detail = detailQuery.data
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
        toast.success(
          t(body.is_active ? 'detail.activatedToast' : 'detail.suspendedToast', { name }),
        )
      }
    } catch (error) {
      // Backend guards (self-demotion, last-admin, invalid role) surface
      // here as a toast; rethrow so the confirm dialog stays open with the
      // inline failure.
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
        <div className="space-y-6">
          <PageHeader title={t('title')} description={t('description')} />
          <EmptyState title={t('detail.notFoundTitle')} message={t('detail.notFoundMessage')} />
        </div>
      )
    }
    return (
      <div className="space-y-6">
        <PageHeader title={t('title')} description={t('description')} />
        <ErrorState
          message={apiError.message}
          onRetry={() => void detailQuery.refetch()}
        />
      </div>
    )
  }

  const confirmDescription = pendingAction
    ? pendingAction.kind === 'role'
      ? t('detail.roleConfirmDescription')
      : pendingAction.kind === 'admin'
        ? t(pendingAction.value ? 'detail.adminConfirmGrant' : 'detail.adminConfirmRevoke', {
            name,
          })
        : t(
            pendingAction.value
              ? 'detail.activateConfirmDescription'
              : 'detail.suspendConfirmDescription',
            { name },
          )
    : null
  const confirmLabel =
    pendingAction?.kind === 'status'
      ? t(pendingAction.value ? 'detail.activate' : 'detail.suspend')
      : null

  return (
    <div className="space-y-6">
      <PageHeader
        title={detailQuery.isPending ? t('detail.title') : name}
        description={email}
        actions={
          <Button variant="outline" size="sm" asChild>
            <Link to="/users">
              <ArrowLeft aria-hidden="true" />
              {t('back')}
            </Link>
          </Button>
        }
      />

      {detailQuery.isPending ? (
        <div className="grid gap-6 lg:grid-cols-3">
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
      ) : (
        <div className="grid gap-6 lg:grid-cols-3">
          {/* Identity + profile */}
          <Card className="lg:col-span-2">
            <CardHeader>
              <div className="flex items-center gap-4">
                <Avatar className="size-14">
                  <AvatarImage
                    src={stringValue(userRecord, 'avatar_url') ?? undefined}
                    alt={name}
                  />
                  <AvatarFallback>{initials(name)}</AvatarFallback>
                </Avatar>
                <div className="min-w-0">
                  <CardTitle className="truncate text-xl">{name}</CardTitle>
                  <CardDescription className="truncate">{email}</CardDescription>
                </div>
                <div className="ml-auto flex items-center gap-2">
                  <Badge variant="default">
                    {t(roleLabelKey(role), { defaultValue: role ?? '—' })}
                  </Badge>
                  <StatusBadge
                    status={active ? 'active' : 'suspended'}
                    label={t(active ? 'status.active' : 'status.suspended')}
                  />
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <dl className="divide-y divide-border">
                <Field
                  label={t('detail.memberSince')}
                  value={formatDateTimeValue(userRecord?.created_at)}
                />
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
                    <Badge
                      variant={booleanValue(userRecord, 'email_verified') ? 'success' : 'warning'}
                    >
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
                  value={
                    numberValue(userRecord, 'custom_daily_quota') ?? t('detail.planDefault')
                  }
                />
              </dl>
            </CardContent>
          </Card>

          {/* Actions (gated users.write) */}
          <Card>
            <CardHeader>
              <CardTitle>{t('detail.actions')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-5">
              {canWrite ? (
                <>
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
                            {t(roleLabelKey(option), { defaultValue: option })}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="flex items-center justify-between gap-4">
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

                  <Button
                    variant={active ? 'destructive' : 'secondary'}
                    className="w-full"
                    onClick={() => setPendingAction({ kind: 'status', value: !active })}
                  >
                    {t(active ? 'detail.suspend' : 'detail.activate')}
                  </Button>
                </>
              ) : (
                <p className="text-sm text-muted-foreground">{t('detail.noWriteAccess')}</p>
              )}
            </CardContent>
          </Card>

          {/* Subscription */}
          <Card className="lg:col-span-2">
            <CardHeader>
              <CardTitle>{t('detail.subscription')}</CardTitle>
            </CardHeader>
            <CardContent>
              {subscription ? (
                <dl className="divide-y divide-border">
                  <Field
                    label={t('columns.plan')}
                    value={
                      subPlanLabel
                        ? t(subPlanLabel)
                        : subPlan ?? t('plans.none')
                    }
                  />
                  <Field
                    label={t('detail.status')}
                    value={
                      <StatusBadge
                        {...(subStatus ? { status: subStatus, label: subStatus } : { label: '—' })}
                      />
                    }
                  />
                  <Field
                    label={t('detail.billingProvider')}
                    value={stringValue(subscription, 'billing_provider') ?? '—'}
                  />
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
                  <Field
                    label={t('detail.trialEnd')}
                    value={formatDateTimeValue(subscription.trial_end)}
                  />
                  <Field
                    label={t('detail.referralCreditMonths')}
                    value={numberValue(subscription, 'referral_credit_months') ?? '—'}
                  />
                </dl>
              ) : (
                <p className="text-sm text-muted-foreground">{t('plans.none')}</p>
              )}
            </CardContent>
          </Card>

          {/* Usage */}
          <Card>
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
                <Field
                  label={t('detail.lastReset')}
                  value={formatDateTimeValue(aiUsage?.last_reset_date)}
                />
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
                <Field
                  label={t('detail.periodStart')}
                  value={formatDateTimeValue(subUsage?.period_start)}
                />
              </dl>
            </CardContent>
          </Card>

          {/* Counts */}
          <Card>
            <CardHeader>
              <CardTitle>{t('detail.counts')}</CardTitle>
            </CardHeader>
            <CardContent>
              <dl className="divide-y divide-border">
                {countRows.map((row) => (
                  <Field
                    key={row.key}
                    label={t(`detail.${row.key}`, { defaultValue: row.key })}
                    value={formatNumber(row.value)}
                  />
                ))}
              </dl>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Activity */}
      <Card>
        <CardHeader>
          <CardTitle>{t('detail.activity')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-8">
          {activityQuery.isPending ? (
            <div className="space-y-3">
              <Skeleton className="h-4 w-40" />
              <Skeleton className="h-16 w-full" />
              <Skeleton className="h-16 w-full" />
            </div>
          ) : activityQuery.isError ? (
            <ErrorState
              message={normalizeError(activityQuery.error).message}
              onRetry={() => void activityQuery.refetch()}
            />
          ) : (
            <>
              <section aria-label={t('detail.auditEvents')}>
                <h3 className="mb-2 text-sm font-semibold text-muted-foreground">
                  {t('detail.auditEvents')}
                </h3>
                {activityQuery.data?.audit_events?.length ? (
                  <ActivityAuditTable events={activityQuery.data.audit_events} />
                ) : (
                  <p className="text-sm text-muted-foreground">{t('detail.noAuditEvents')}</p>
                )}
              </section>
              <section aria-label={t('detail.recentJobs')}>
                <h3 className="mb-2 text-sm font-semibold text-muted-foreground">
                  {t('detail.recentJobs')}
                </h3>
                {activityQuery.data?.recent_jobs?.length ? (
                  <ActivityJobsTable jobs={activityQuery.data.recent_jobs} />
                ) : (
                  <p className="text-sm text-muted-foreground">{t('detail.noJobs')}</p>
                )}
              </section>
            </>
          )}
        </CardContent>
      </Card>

      {/* Confirm dialog for role / admin / status changes */}
      <ConfirmDialog
        open={pendingAction !== null}
        onOpenChange={(open) => {
          if (!open) setPendingAction(null)
        }}
        title={
          pendingAction?.kind === 'role'
            ? t('detail.roleConfirmTitle', {
                role: t(roleLabelKey(pendingAction.value), { defaultValue: pendingAction.value }),
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
    </div>
  )
}

function ActivityAuditTable({ events }: { events: JsonRecord[] }) {
  const { t } = useTranslation('users')
  return (
    <div className="overflow-x-auto rounded-md border border-border">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-border text-left text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            <th className="px-3 py-2">{t('detail.action')}</th>
            <th className="px-3 py-2">{t('detail.actor')}</th>
            <th className="px-3 py-2">{t('detail.entity')}</th>
            <th className="px-3 py-2">{t('detail.when')}</th>
          </tr>
        </thead>
        <tbody>
          {events.map((event, index) => {
            const actor = (event.actor ?? {}) as JsonRecord
            return (
              <tr
                key={stringValue(event, 'id') ?? `event-${index}`}
                className="border-b border-border last:border-0"
              >
                <td className="px-3 py-2 font-medium">{stringValue(event, 'action') ?? '—'}</td>
                <td className="px-3 py-2">
                  {stringValue(actor, 'email') ?? stringValue(event, 'actor_id') ?? '—'}
                </td>
                <td className="px-3 py-2">
                  {stringValue(event, 'entity_type') ?? '—'}
                  {stringValue(event, 'entity_id')
                    ? ` / ${stringValue(event, 'entity_id')}`
                    : ''}
                </td>
                <td className="px-3 py-2 text-muted-foreground">
                  {formatDateTimeValue(event.created_at)}
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

function ActivityJobsTable({ jobs }: { jobs: JsonRecord[] }) {
  const { t } = useTranslation('users')
  return (
    <div className="overflow-x-auto rounded-md border border-border">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-border text-left text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            <th className="px-3 py-2">{t('detail.jobType')}</th>
            <th className="px-3 py-2">{t('detail.jobStatus')}</th>
            <th className="px-3 py-2">{t('detail.jobStarted')}</th>
            <th className="px-3 py-2">{t('detail.jobCompleted')}</th>
            <th className="px-3 py-2">{t('detail.jobError')}</th>
          </tr>
        </thead>
        <tbody>
          {jobs.map((job, index) => {
            const jobStatus = stringValue(job, 'status')
            return (
              <tr
                key={stringValue(job, 'id') ?? `job-${index}`}
                className="border-b border-border last:border-0"
              >
                <td className="px-3 py-2 font-medium">{stringValue(job, 'job_type') ?? '—'}</td>
                <td className="px-3 py-2">
                  {jobStatus ? <StatusBadge status={jobStatus} /> : null}
                </td>
                <td className="px-3 py-2 text-muted-foreground">
                  {formatDateTimeValue(job.created_at)}
                </td>
                <td className="px-3 py-2 text-muted-foreground">
                  {formatDateTimeValue(job.completed_at)}
                </td>
                <td className="max-w-60 truncate px-3 py-2 text-destructive">
                  {stringValue(job, 'error_message') ?? '—'}
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}
