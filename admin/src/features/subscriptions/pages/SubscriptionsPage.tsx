import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { AlertTriangle, CreditCard, Download, Receipt, RotateCcw } from 'lucide-react'
import { useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router-dom'
import { toast } from 'sonner'

import { markIapRefunded } from '@/features/subscriptions/api/iap'
import {
  getSubscriptionDetail,
  listSubscriptions,
  refundSubscription,
  subscriptionKeys,
  type AdminSubscriptionDetail,
  type AdminSubscriptionListItem,
} from '@/features/subscriptions/api/subscriptions'
import { refundErrorKey, subscriptionUserEmail } from '@/features/subscriptions/lib/refund'
import { ApiError, isApiError } from '@/shared/api/errors'
import { useCsvExport } from '@/shared/hooks/useCsvExport'
import { usePermission } from '@/shared/hooks/usePermission'
import { formatDate, formatMoney, toDate } from '@/shared/lib/formatters'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import { ConfirmDialog } from '@/shared/ui/ConfirmDialog'
import { DataTable } from '@/shared/ui/DataTable'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/shared/ui/dialog'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { Skeleton } from '@/shared/ui/skeleton'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import { TableToolbar } from '@/shared/ui/TableToolbar'
import { useServerTable } from '@/shared/ui/useServerTable'

const PLAN_TYPES = ['plus_monthly', 'plus_yearly', 'pro_monthly', 'pro_yearly'] as const
const SUBSCRIPTION_STATUSES = [
  'active',
  'trialing',
  'past_due',
  'canceled',
  'cancelled',
  'incomplete',
  'incomplete_expired',
  'unpaid',
  'refunded',
] as const

const PROVIDER_OPTIONS = [
  { value: 'all', labelKey: 'filters.providerAll' },
  { value: 'stripe', label: 'Stripe' },
  { value: 'apple', label: 'Apple' },
  { value: 'google', label: 'Google' },
] as const

const FAILED_STATUSES = new Set(['past_due', 'incomplete', 'incomplete_expired', 'unpaid'])

function daysLeft(trialEnd: unknown): number | null {
  const date = toDate(trialEnd)
  if (!date) return null
  const now = new Date()
  const diffMs = date.getTime() - now.getTime()
  // ceil((trial_end - now)/1d) — past dates yield <=0
  return Math.ceil(diffMs / (1000 * 60 * 60 * 24))
}

function isTrialStatus(status: string | null | undefined): boolean {
  if (!status) return false
  const s = status.toLowerCase()
  return s === 'trial' || s === 'trialing'
}

/** The store identifier used as the IAP transaction id (admin_service._iap_item). */
function providerTransactionId(sub: Record<string, unknown>): string | null {
  for (const key of ['apple_original_transaction_id', 'google_order_id', 'google_purchase_token']) {
    const value = sub[key]
    if (typeof value === 'string' && value) return value
  }
  return null
}

function stringField(sub: Record<string, unknown>, key: string): string | null {
  const value = sub[key]
  return typeof value === 'string' && value ? value : null
}

function rowProvider(row: AdminSubscriptionListItem): 'stripe' | 'apple' | 'google' {
  return (row.billing_provider ?? 'stripe') as 'stripe' | 'apple' | 'google'
}

export function SubscriptionsPage() {
  const { t } = useTranslation('subscriptions')
  const { t: tIap } = useTranslation('iap')
  const { can } = usePermission()
  const queryClient = useQueryClient()
  const [refundTarget, setRefundTarget] = useState<AdminSubscriptionListItem | null>(null)
  const [txnTarget, setTxnTarget] = useState<AdminSubscriptionListItem | null>(null)
  const [markTarget, setMarkTarget] = useState<string | null>(null)

  const table = useServerTable<AdminSubscriptionListItem>({
    queryKey: subscriptionKeys.all,
    queryFn: listSubscriptions,
    filterKeys: ['plan', 'status', 'provider'],
  })

  // Provider filter is SERVER-side (backend billing_provider param) — totals
  // and pagination are correct for the selected rail. Only the email search
  // stays client-side (backend has no q param yet), filtering the current
  // page (see caption).
  const searchQ = (table.tableState.q ?? '').trim().toLowerCase()

  const { filteredData, failedCount } = useMemo(() => {
    const out: AdminSubscriptionListItem[] = []
    let failed = 0
    for (const row of table.data) {
      if (searchQ) {
        const email = subscriptionUserEmail(row.user) ?? ''
        const haystack = `${email} ${row.user_id}`.toLowerCase()
        if (!haystack.includes(searchQ)) continue
      }
      out.push(row)
      const s = (row.status ?? '').toLowerCase()
      if (FAILED_STATUSES.has(s)) failed += 1
    }
    return { filteredData: out, failedCount: failed }
  }, [table.data, searchQ])

  // For banner total, also consider server total when we have failed rows server-side?
  // We use page count; task says "visible on current page or total" — show if any failed visible.
  const showFailedBanner = failedCount > 0 && can('subscriptions.read')

  const csvExport = useCsvExport<AdminSubscriptionListItem>({
    rows: filteredData,
    filename: t('export.filename'),
    toastMessage: t('export.toast', { count: filteredData.length }),
    columns: [
      {
        label: t('columns.user'),
        value: (row) => subscriptionUserEmail(row.user) ?? row.user_id,
      },
      { label: t('columns.plan'), value: (row) => row.plan_type ?? '' },
      { label: t('columns.status'), value: (row) => row.status ?? '' },
      {
        label: t('columns.period'),
        value: (row) =>
          `${toDate(row.current_period_start)?.toISOString() ?? ''} → ${toDate(row.current_period_end)?.toISOString() ?? ''}`,
      },
      {
        label: t('columns.cancelAtPeriodEnd'),
        value: (row) => String(row.cancel_at_period_end ?? false),
      },
      { label: t('columns.amount'), value: (row) => row.amount ?? '' },
      {
        label: t('columns.createdAt'),
        value: (row) => toDate(row.created_at)?.toISOString() ?? '',
      },
    ],
  })

  const refundMutation = useMutation({
    mutationFn: refundSubscription,
    onSuccess: (result) => {
      toast.success(
        t('refund.success', {
          refundId: result.refund_id,
          amount: formatMoney(result.amount / 100, result.currency),
          status: result.status,
        }),
      )
      setRefundTarget(null)
      void queryClient.invalidateQueries({ queryKey: subscriptionKeys.all })
    },
  })

  const handleConfirmRefund = async (item: AdminSubscriptionListItem): Promise<void> => {
    try {
      await refundMutation.mutateAsync(item.user_id)
    } catch (error) {
      throw new ApiError({
        status: isApiError(error) ? error.status : 0,
        code: isApiError(error) ? error.code : 'INTERNAL_ERROR',
        message: t(refundErrorKey(error)),
      })
    }
  }

  // Store (Apple/Google) transaction detail — fetched when the row dialog opens.
  const txnDetailQuery = useQuery({
    queryKey: subscriptionKeys.detail(txnTarget?.user_id ?? ''),
    queryFn: () => getSubscriptionDetail(txnTarget!.user_id),
    enabled: txnTarget !== null,
  })
  const txnDetail: AdminSubscriptionDetail['subscription'] | null =
    txnDetailQuery.data?.subscription ?? null
  const providerTxnId = txnDetail ? providerTransactionId(txnDetail) : null
  const txnStatus = txnDetail ? stringField(txnDetail, 'status') : null
  const txnProvider = txnDetail ? stringField(txnDetail, 'billing_provider') : null

  const markRefundedMutation = useMutation({
    mutationFn: markIapRefunded,
    onSuccess: (_result, txnId) => {
      toast.success(tIap('markRefunded.success', { transactionId: txnId }))
      setMarkTarget(null)
      setTxnTarget(null)
      void queryClient.invalidateQueries({ queryKey: subscriptionKeys.all })
    },
    onError: () => {
      toast.error(tIap('markRefunded.errorGeneric'))
    },
  })

  const columns: ColumnDef<AdminSubscriptionListItem>[] = [
    {
      id: 'user',
      header: t('columns.user'),
      enableSorting: false,
      size: 240,
      minSize: 220,
      cell: ({ row }) => {
        const email = subscriptionUserEmail(row.original.user)
        return (
          <div className="flex min-w-0 flex-col">
            <Link
              to={`/users/${row.original.user_id}`}
              className="truncate font-medium text-foreground underline-offset-4 hover:text-primary hover:underline"
            >
              {email ?? row.original.user_id}
            </Link>
            <span className="truncate font-mono text-xs text-muted-foreground">
              {row.original.user_id}
            </span>
          </div>
        )
      },
    },
    {
      id: 'plan_type',
      header: t('columns.plan'),
      size: 130,
      minSize: 110,
      cell: ({ row }) => {
        const plan = row.original.plan_type
        return (
          <span className="rounded-full bg-surface-card px-2.5 py-0.5 text-xs font-medium">
            {plan ? t(`plans.${plan}`, { defaultValue: plan }) : '—'}
          </span>
        )
      },
    },
    {
      id: 'status',
      header: t('columns.status'),
      size: 160,
      minSize: 130,
      cell: ({ row }) => {
        const status = row.original.status ?? 'unknown'
        const dl = isTrialStatus(status) ? daysLeft(row.original.trial_end) : null
        return (
          <div className="flex items-center gap-2">
            <StatusBadge status={status} label={t(`status.${status}`, { defaultValue: status })} />
            {dl !== null ? (
              <Badge variant={dl <= 3 ? 'warning' : 'secondary'} aria-label={t('trial.daysLeft', { count: dl, defaultValue: `${dl}d left` })}>
                {dl <= 0
                  ? t('trial.expired', { defaultValue: 'expired' })
                  : t('trial.daysLeft', { count: dl, defaultValue: `${dl}d left` })}
              </Badge>
            ) : null}
          </div>
        )
      },
    },
    {
      id: 'billing_provider',
      header: t('columns.provider', { defaultValue: 'Provider' }),
      size: 110,
      minSize: 90,
      cell: ({ row }) => {
        const bp = row.original.billing_provider ?? 'stripe'
        return (
          <span className="rounded-full bg-surface-card px-2.5 py-0.5 text-xs font-medium capitalize">
            {bp}
          </span>
        )
      },
    },
    {
      id: 'current_period_start',
      header: t('columns.period'),
      size: 200,
      minSize: 170,
      cell: ({ row }) => {
        const start = formatDate(row.original.current_period_start as string | null | undefined)
        const end = formatDate(row.original.current_period_end as string | null | undefined)
        return (
          <span className="whitespace-nowrap text-sm text-muted-foreground">
            {start} → {end}
          </span>
        )
      },
    },
    {
      id: 'cancel_at_period_end',
      header: t('columns.cancelAtPeriodEnd'),
      enableSorting: false,
      size: 150,
      minSize: 130,
      cell: ({ row }) => (
        <StatusBadge
          status={row.original.cancel_at_period_end ? 'cancelled' : 'active'}
          label={t(
            row.original.cancel_at_period_end
              ? 'cancelAtPeriodEnd.yes'
              : 'cancelAtPeriodEnd.no',
          )}
        />
      ),
    },
    {
      id: 'amount',
      header: t('columns.amount'),
      enableSorting: false,
      size: 100,
      minSize: 80,
      cell: ({ row }) => {
        const amount = row.original.amount
        return (
          <span className="whitespace-nowrap tabular-nums">
            {typeof amount === 'number' ? formatMoney(amount) : '—'}
          </span>
        )
      },
    },
    {
      id: 'created_at',
      header: t('columns.createdAt'),
      size: 150,
      minSize: 120,
      cell: ({ row }) => (
        <span className="whitespace-nowrap text-sm text-muted-foreground">
          {formatDate(row.original.created_at as string | null | undefined)}
        </span>
      ),
    },
    {
      id: 'actions',
      enableSorting: false,
      size: 130,
      minSize: 100,
      cell: ({ row }) => {
        // A8-05: Stripe refund only applies to Stripe-billed rows — the
        // backend rejects store-billed ones, so the affordance must not
        // render there. Store rows get the IAP transaction dialog instead.
        if (rowProvider(row.original) === 'stripe') {
          if (!can('subscriptions.refund')) return null
          return (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setRefundTarget(row.original)}
              aria-label={t('rowActions.refund')}
            >
              <RotateCcw aria-hidden="true" />
              {t('rowActions.refund')}
            </Button>
          )
        }
        if (!can('iap.read')) return null
        return (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setTxnTarget(row.original)}
            aria-label={t('rowActions.viewTransaction')}
          >
            <Receipt aria-hidden="true" />
            {t('rowActions.viewTransaction')}
          </Button>
        )
      },
    },
  ]

  if (table.query.isError) {
    return (
      <div className="space-y-3">
        <ErrorState
          title={t('loadError.title')}
          message={t('loadError.message')}
          onRetry={() => {
            void table.query.refetch()
          }}
        />
      </div>
    )
  }

  // Permission gate for content (route guard already enforces, but keep skeleton guard)
  const canRead = can('subscriptions.read')

  return (
    <div className="space-y-3">

      {showFailedBanner ? (
        <div
          role="status"
          aria-live="polite"
          className="flex flex-wrap items-center gap-3 rounded-md border border-warning/30 bg-warning-pale px-4 py-3 text-sm"
        >
          <AlertTriangle className="size-4 shrink-0 text-warning-deep" aria-hidden="true" />
          <span className="font-medium text-warning-deep">
            {t('banner.failed', {
              count: failedCount,
              defaultValue: `${failedCount} failed subscription(s) — past due / incomplete / unpaid`,
            })}
          </span>
          <Button
            variant="outline"
            size="sm"
            className="ml-auto"
            onClick={() => table.tableState.setFilter('status', 'past_due')}
          >
            {t('banner.viewFailed', { defaultValue: 'View failed' })}
          </Button>
        </div>
      ) : null}

      {!canRead ? (
        <ErrorState
          title={t('loadError.title')}
          message={t('common:permissionDenied', { defaultValue: 'You do not have permission to view subscriptions.' })}
        />
      ) : (
        <>
          <TableToolbar
            searchValue={table.tableState.q}
            onSearchChange={table.tableState.setQ}
            searchPlaceholder={t('filters.searchPlaceholder', { defaultValue: 'Search by email or user ID…' })}
            primaryFilter={{
              key: 'status',
              label: t('filters.status'),
              placeholder: t('filters.statusPlaceholder'),
              options: [
                { value: 'all', label: t('filters.statusPlaceholder') },
                ...SUBSCRIPTION_STATUSES.map((status) => ({
                  value: status,
                  label: t(`status.${status}`, { defaultValue: status }),
                })),
              ],
              value: table.tableState.filters.status,
              onValueChange: (value) =>
                table.tableState.setFilter('status', value && value !== 'all' ? value : undefined),
            }}
            filters={[
              {
                key: 'plan',
                label: t('filters.plan'),
                placeholder: t('filters.planPlaceholder'),
                options: [
                  { value: 'all', label: t('filters.planPlaceholder') },
                  ...PLAN_TYPES.map((plan) => ({
                    value: plan,
                    label: t(`plans.${plan}`, { defaultValue: plan }),
                  })),
                ],
                value: table.tableState.filters.plan,
                onValueChange: (value) =>
                  table.tableState.setFilter('plan', value && value !== 'all' ? value : undefined),
              },
              {
                key: 'provider',
                label: t('filters.provider', { defaultValue: 'Provider' }),
                placeholder: t('filters.providerPlaceholder', { defaultValue: 'All providers' }),
                options: PROVIDER_OPTIONS.map((opt) => ({
                  value: opt.value,
                  label:
                    opt.value === 'all'
                      ? t(opt.labelKey, { defaultValue: 'All providers' })
                      : opt.label,
                })),
                value: table.tableState.filters.provider,
                onValueChange: (value) =>
                  table.tableState.setFilter('provider', value && value !== 'all' ? value : undefined),
              },
            ]}
            isFetching={table.props.isFetching}
            onReset={table.tableState.reset}
            actions={
              <Button
                variant="outline"
                size="sm"
                onClick={csvExport.exportCsv}
                disabled={!csvExport.canExport}
              >
                <Download aria-hidden="true" />
                {t('export.label')}
              </Button>
            }
          />

          {searchQ ? (
            <p className="text-xs text-muted-foreground">
              {t('filters.clientCaption', { defaultValue: 'Search filters the current page only.' })}
            </p>
          ) : null}
          <DataTable<AdminSubscriptionListItem>
            {...table.props}
            data={filteredData}
            total={searchQ ? filteredData.length : table.props.total}
            columns={columns}
            pinnedColumnId="user"
            ariaLabel={t('title')}
            getRowId={(row) => row.id}
            onResetFilters={() => table.tableState.reset()}
            emptyState={
              <EmptyState
                icon={CreditCard}
                title={t('empty.title')}
                message={
                  searchQ
                    ? t('empty.messageFiltered', {
                        defaultValue: 'No subscriptions match the current filters.',
                      })
                    : t('empty.message')
                }
              />
            }
          />
        </>
      )}

      <ConfirmDialog
        open={refundTarget !== null}
        onOpenChange={(open) => {
          if (!open) setRefundTarget(null)
        }}
        title={t('refund.dialogTitle')}
        {...(refundTarget
          ? {
              description: t('refund.dialogDescription', {
                amount: formatMoney(refundTarget.amount ?? 0),
                email: subscriptionUserEmail(refundTarget.user) ?? refundTarget.user_id,
              }),
              confirmLabel: t('refund.confirm', {
                amount: formatMoney(refundTarget.amount ?? 0),
              }),
            }
          : {})}
        onConfirm={() => (refundTarget ? handleConfirmRefund(refundTarget) : undefined)}
      />

      <Dialog
        open={txnTarget !== null}
        onOpenChange={(open) => {
          if (!open) setTxnTarget(null)
        }}
      >
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>{tIap('detail.title')}</DialogTitle>
            <DialogDescription>
              {providerTxnId
                ? tIap('detail.description', { transactionId: providerTxnId })
                : tIap('detail.noProviderTransactionId')}
            </DialogDescription>
          </DialogHeader>
          {txnDetailQuery.isPending ? (
            <div className="space-y-2">
              <Skeleton className="h-4 w-full" />
              <Skeleton className="h-4 w-3/4" />
              <Skeleton className="h-4 w-1/2" />
            </div>
          ) : txnDetailQuery.isError ? (
            <ErrorState
              title={tIap('loadError.title')}
              message={tIap('loadError.message')}
              onRetry={() => {
                void txnDetailQuery.refetch()
              }}
            />
          ) : txnDetail ? (
            <div className="space-y-3">
              <dl className="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1.5 text-sm">
                <dt className="text-muted-foreground">{t('columns.user')}</dt>
                <dd className="break-all">
                  {txnTarget
                    ? (subscriptionUserEmail(txnTarget.user) ?? txnTarget.user_id)
                    : '—'}
                </dd>
                <dt className="text-muted-foreground">{tIap('detail.platform')}</dt>
                <dd>
                  {txnProvider === 'apple'
                    ? tIap('platforms.apple')
                    : txnProvider === 'google'
                      ? tIap('platforms.google')
                      : tIap('platforms.unknown')}
                </dd>
                <dt className="text-muted-foreground">{tIap('detail.plan')}</dt>
                <dd>
                  {stringField(txnDetail, 'plan_type')
                    ? t(`plans.${stringField(txnDetail, 'plan_type')}`, {
                        defaultValue: stringField(txnDetail, 'plan_type') ?? '',
                      })
                    : '—'}
                </dd>
                <dt className="text-muted-foreground">{tIap('detail.status')}</dt>
                <dd>
                  {txnStatus
                    ? t(`status.${txnStatus}`, { defaultValue: txnStatus })
                    : '—'}
                </dd>
                <dt className="text-muted-foreground">{tIap('detail.amount')}</dt>
                <dd className="tabular-nums">
                  {typeof txnTarget?.amount === 'number'
                    ? formatMoney(txnTarget.amount)
                    : '—'}
                </dd>
                <dt className="text-muted-foreground">{tIap('detail.billingProductId')}</dt>
                <dd className="break-all">
                  {stringField(txnDetail, 'billing_product_id') ?? '—'}
                </dd>
                <dt className="text-muted-foreground">{tIap('detail.createdAt')}</dt>
                <dd>
                  {formatDate(txnDetail.created_at as string | null | undefined) || '—'}
                </dd>
              </dl>

              <div className="rounded-md bg-surface-card p-3 text-xs">
                <p className="mb-1 font-medium">{tIap('detail.receipt')}</p>
                <div className="space-y-1 font-mono break-all text-muted-foreground">
                  {stringField(txnDetail, 'apple_original_transaction_id') ? (
                    <p>
                      {tIap('detail.appleOriginalTransactionId')}:{' '}
                      {stringField(txnDetail, 'apple_original_transaction_id')}
                    </p>
                  ) : null}
                  {stringField(txnDetail, 'google_order_id') ? (
                    <p>
                      {tIap('detail.googleOrderId')}: {stringField(txnDetail, 'google_order_id')}
                    </p>
                  ) : null}
                  {stringField(txnDetail, 'google_purchase_token') ? (
                    <p>
                      {tIap('detail.googlePurchaseToken')}:{' '}
                      {stringField(txnDetail, 'google_purchase_token')}
                    </p>
                  ) : null}
                  {!providerTxnId ? <p>{tIap('detail.noReceipt')}</p> : null}
                </div>
              </div>

              {providerTxnId && can('iap.write') && txnStatus !== 'refunded' ? (
                <div className="flex justify-end">
                  <Button size="sm" onClick={() => setMarkTarget(providerTxnId)}>
                    {tIap('detail.markRefunded')}
                  </Button>
                </div>
              ) : null}
            </div>
          ) : null}
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={markTarget !== null}
        onOpenChange={(open) => {
          if (!open) setMarkTarget(null)
        }}
        title={tIap('markRefunded.dialogTitle')}
        {...(markTarget
          ? {
              description: tIap('markRefunded.dialogDescription', {
                transactionId: markTarget,
              }),
              confirmLabel: tIap('markRefunded.confirm'),
            }
          : {})}
        onConfirm={() => (markTarget ? markRefundedMutation.mutateAsync(markTarget) : undefined)}
      />
    </div>
  )
}
