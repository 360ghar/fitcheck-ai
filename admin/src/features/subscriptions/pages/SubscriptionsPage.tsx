import { useMutation, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { CreditCard, Download, RotateCcw } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router-dom'
import { toast } from 'sonner'

import {
  listSubscriptions,
  refundSubscription,
  subscriptionKeys,
  type AdminSubscriptionListItem,
} from '@/features/subscriptions/api/subscriptions'
import { refundErrorKey, subscriptionUserEmail } from '@/features/subscriptions/lib/refund'
import { ApiError, isApiError } from '@/shared/api/errors'
import { useCsvExport } from '@/shared/hooks/useCsvExport'
import { usePermission } from '@/shared/hooks/usePermission'
import { formatDate, formatMoney, toDate } from '@/shared/lib/formatters'
import { Button } from '@/shared/ui/button'
import { ConfirmDialog } from '@/shared/ui/ConfirmDialog'
import { DataTable } from '@/shared/ui/DataTable'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { PageHeader } from '@/shared/ui/PageHeader'
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

export function SubscriptionsPage() {
  const { t } = useTranslation('subscriptions')
  const { can } = usePermission()
  const queryClient = useQueryClient()
  const [refundTarget, setRefundTarget] = useState<AdminSubscriptionListItem | null>(null)

  const table = useServerTable<AdminSubscriptionListItem>({
    queryKey: subscriptionKeys.all,
    queryFn: listSubscriptions,
    filterKeys: ['plan', 'status'],
  })

  const csvExport = useCsvExport<AdminSubscriptionListItem>({
    rows: table.data,
    filename: t('export.filename'),
    toastMessage: t('export.toast', { count: table.data.length }),
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
          // AdminRefundResponse.amount is Stripe minor units (cents) —
          // convert to major units for display.
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
      // Keep the dialog open with a translated, specific message.
      throw new ApiError({
        status: isApiError(error) ? error.status : 0,
        code: isApiError(error) ? error.code : 'INTERNAL_ERROR',
        message: t(refundErrorKey(error)),
      })
    }
  }

  const columns: ColumnDef<AdminSubscriptionListItem>[] = [
    {
      id: 'user',
      header: t('columns.user'),
      enableSorting: false,
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
      cell: ({ row }) => {
        const status = row.original.status ?? 'unknown'
        return <StatusBadge status={status} label={t(`status.${status}`, { defaultValue: status })} />
      },
    },
    {
      id: 'current_period_start',
      header: t('columns.period'),
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
      cell: ({ row }) => (
        <span className="whitespace-nowrap text-sm text-muted-foreground">
          {formatDate(row.original.created_at as string | null | undefined)}
        </span>
      ),
    },
    {
      id: 'actions',
      enableSorting: false,
      cell: ({ row }) => {
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
      },
    },
  ]

  if (table.query.isError) {
    return (
      <div className="space-y-6">
        <PageHeader title={t('title')} description={t('description')} />
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

  return (
    <div className="space-y-6">
      <PageHeader title={t('title')} description={t('description')} />

      <TableToolbar
        hideSearch
        searchValue=""
        onSearchChange={() => undefined}
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

      <DataTable<AdminSubscriptionListItem>
        {...table.props}
        columns={columns}
        ariaLabel={t('title')}
        getRowId={(row) => row.id}
        onResetFilters={() => table.tableState.reset()}
        emptyState={
          <EmptyState
            icon={CreditCard}
            title={t('empty.title')}
            message={t('empty.message')}
          />
        }
      />

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
    </div>
  )
}
