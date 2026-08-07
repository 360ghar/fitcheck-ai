import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { Download, Receipt } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router-dom'
import { toast } from 'sonner'

import {
  getIapTransaction,
  iapKeys,
  listIapTransactions,
  markIapRefunded,
  type AdminIapTransactionListItem,
} from '@/features/subscriptions/api/iap'
import { isApiError } from '@/shared/api/errors'
import { useCsvExport } from '@/shared/hooks/useCsvExport'
import { usePermission } from '@/shared/hooks/usePermission'
import { formatDate, formatDateTime, formatMoney, toDate } from '@/shared/lib/formatters'
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
import { PageHeader } from '@/shared/ui/PageHeader'
import { Skeleton } from '@/shared/ui/skeleton'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import { TableToolbar } from '@/shared/ui/TableToolbar'
import { useServerTable } from '@/shared/ui/useServerTable'

const PLATFORMS = ['apple', 'google'] as const
const IAP_STATUSES = [
  'active',
  'trialing',
  'past_due',
  'canceled',
  'cancelled',
  'refunded',
] as const

/** Keys rendered as structured fields in the detail dialog (rest → receipt metadata). */
const KNOWN_DETAIL_KEYS = new Set([
  'subscription_id',
  'transaction_id',
  'user_id',
  'user_email',
  'platform',
  'plan_type',
  'amount',
  'status',
  'created_at',
  'billing_product_id',
  'id',
])

function displayString(value: unknown): string {
  if (typeof value === 'string') return value
  if (typeof value === 'number' || typeof value === 'boolean') return String(value)
  return ''
}

export function IapTransactionsPage() {
  const { t } = useTranslation('iap')
  const { can } = usePermission()
  const queryClient = useQueryClient()
  const [selected, setSelected] = useState<AdminIapTransactionListItem | null>(null)
  const [markTarget, setMarkTarget] = useState<AdminIapTransactionListItem | null>(null)

  const table = useServerTable<AdminIapTransactionListItem>({
    queryKey: iapKeys.all,
    queryFn: listIapTransactions,
    filterKeys: ['platform', 'status'],
  })

  const csvExport = useCsvExport<AdminIapTransactionListItem>({
    rows: table.data,
    filename: t('export.filename'),
    toastMessage: t('export.toast', { count: table.data.length }),
    columns: [
      { label: t('columns.user'), value: (row) => row.user_email ?? row.user_id },
      { label: t('columns.platform'), value: (row) => row.platform ?? '' },
      { label: t('columns.status'), value: (row) => row.status ?? '' },
      { label: t('columns.plan'), value: (row) => row.plan_type ?? '' },
      { label: t('columns.amount'), value: (row) => row.amount ?? '' },
      { label: t('columns.transactionId'), value: (row) => row.transaction_id ?? '' },
      {
        label: t('columns.createdAt'),
        value: (row) => toDate(row.created_at)?.toISOString() ?? '',
      },
    ],
  })

  const detailQuery = useQuery({
    queryKey: iapKeys.detail(selected?.transaction_id ?? ''),
    queryFn: () => getIapTransaction(selected!.transaction_id!),
    enabled: Boolean(selected?.transaction_id),
    staleTime: 30_000,
  })

  const markMutation = useMutation({
    mutationFn: markIapRefunded,
    onSuccess: (_result, txnId) => {
      toast.success(t('markRefunded.success', { transactionId: txnId }))
      setMarkTarget(null)
      setSelected(null)
      void queryClient.invalidateQueries({ queryKey: iapKeys.all })
    },
  })

  const columns: ColumnDef<AdminIapTransactionListItem>[] = [
    {
      id: 'user',
      header: t('columns.user'),
      enableSorting: false,
      cell: ({ row }) => (
        <div className="flex min-w-0 flex-col">
          <Link
            to={`/users/${row.original.user_id}`}
            className="truncate font-medium text-foreground underline-offset-4 hover:text-primary hover:underline"
          >
            {row.original.user_email ?? row.original.user_id}
          </Link>
          <span className="truncate font-mono text-xs text-muted-foreground">
            {row.original.user_id}
          </span>
        </div>
      ),
    },
    {
      id: 'platform',
      header: t('columns.platform'),
      enableSorting: false,
      cell: ({ row }) => {
        const platform = row.original.platform
        return (
          <span className="rounded-full bg-surface-card px-2.5 py-0.5 text-xs font-medium">
            {platform ? t(`platforms.${platform}`, { defaultValue: platform }) : '—'}
          </span>
        )
      },
    },
    {
      id: 'status',
      header: t('columns.status'),
      enableSorting: false,
      cell: ({ row }) => {
        const status = row.original.status ?? 'unknown'
        return <StatusBadge status={status} label={t(`status.${status}`, { defaultValue: status })} />
      },
    },
    {
      id: 'plan_type',
      header: t('columns.plan'),
      enableSorting: false,
      cell: ({ row }) => row.original.plan_type ?? '—',
    },
    {
      id: 'amount',
      header: t('columns.amount'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="whitespace-nowrap tabular-nums">
          {typeof row.original.amount === 'number' ? formatMoney(row.original.amount) : '—'}
        </span>
      ),
    },
    {
      id: 'transaction_id',
      header: t('columns.transactionId'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="font-mono text-xs text-muted-foreground">
          {row.original.transaction_id ?? '—'}
        </span>
      ),
    },
    {
      id: 'created_at',
      header: t('columns.createdAt'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="whitespace-nowrap text-sm text-muted-foreground">
          {formatDate(row.original.created_at as string | null | undefined)}
        </span>
      ),
    },
  ]

  const detail = detailQuery.data
  const detailStatus = detail && typeof detail['status'] === 'string' ? detail['status'] : undefined
  // Store-billed rows have no provider transaction id — there is nothing to
  // fetch from the detail endpoint and nothing to mark refunded by id.
  const hasProviderTransactionId = Boolean(selected?.transaction_id)
  const canMark = can('iap.read') && hasProviderTransactionId && detailStatus !== 'refunded'

  return (
    <div className="space-y-6">
      <PageHeader title={t('title')} description={t('description')} />

      <TableToolbar
        hideSearch
        searchValue=""
        onSearchChange={() => undefined}
        primaryFilter={{
          key: 'platform',
          label: t('filters.platform'),
          placeholder: t('filters.platformPlaceholder'),
          options: [
            { value: 'all', label: t('filters.platformPlaceholder') },
            ...PLATFORMS.map((platform) => ({
              value: platform,
              label: t(`platforms.${platform}`, { defaultValue: platform }),
            })),
          ],
          value: table.tableState.filters.platform,
          onValueChange: (value) =>
            table.tableState.setFilter('platform', value && value !== 'all' ? value : undefined),
        }}
        filters={[
          {
            key: 'status',
            label: t('filters.status'),
            placeholder: t('filters.statusPlaceholder'),
            options: [
              { value: 'all', label: t('filters.statusPlaceholder') },
              ...IAP_STATUSES.map((status) => ({
                value: status,
                label: t(`status.${status}`, { defaultValue: status }),
              })),
            ],
            value: table.tableState.filters.status,
            onValueChange: (value) =>
              table.tableState.setFilter('status', value && value !== 'all' ? value : undefined),
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

      {table.query.isError ? (
        <ErrorState
          title={t('loadError.title')}
          message={t('loadError.message')}
          onRetry={() => {
            void table.query.refetch()
          }}
        />
      ) : (
        <DataTable<AdminIapTransactionListItem>
          {...table.props}
          columns={columns}
          ariaLabel={t('title')}
          getRowId={(row) => row.transaction_id ?? row.subscription_id}
          onRowClick={setSelected}
          onResetFilters={() => table.tableState.reset()}
          emptyState={
            <EmptyState icon={Receipt} title={t('empty.title')} message={t('empty.message')} />
          }
        />
      )}

      {/* Detail dialog */}
      <Dialog open={selected !== null} onOpenChange={(open) => !open && setSelected(null)}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>{t('detail.title')}</DialogTitle>
            <DialogDescription>
              {t('detail.description', {
                transactionId: selected?.transaction_id ?? '—',
              })}
            </DialogDescription>
          </DialogHeader>

          {selected && !hasProviderTransactionId ? (
            <div className="py-4 text-sm text-muted-foreground">
              {t('detail.noProviderTransactionId')}
            </div>
          ) : detailQuery.isPending ? (
            <div className="space-y-3 py-2">
              <Skeleton className="h-4 w-2/3" />
              <Skeleton className="h-4 w-1/2" />
              <Skeleton className="h-4 w-3/4" />
            </div>
          ) : detailQuery.isError || !detail ? (
            <div className="py-4 text-sm text-destructive">{t('detail.notFound')}</div>
          ) : (
            <div className="space-y-4">
              <dl className="grid grid-cols-1 gap-x-6 gap-y-3 text-sm sm:grid-cols-2">
                {detail['platform'] !== undefined ? (
                  <DetailRow
                    label={t('detail.platform')}
                    value={t(
                      `platforms.${displayString(detail['platform'])}`,
                      { defaultValue: displayString(detail['platform']) },
                    )}
                  />
                ) : null}
                {detail['status'] !== undefined ? (
                  <DetailRow
                    label={t('detail.status')}
                    value={t(
                      `status.${displayString(detail['status'])}`,
                      { defaultValue: displayString(detail['status']) },
                    )}
                  />
                ) : null}
                {detail['plan_type'] !== undefined ? (
                  <DetailRow
                    label={t('detail.plan')}
                    value={displayString(detail['plan_type']) || '—'}
                  />
                ) : null}
                {detail['amount'] !== undefined ? (
                  <DetailRow
                    label={t('detail.amount')}
                    value={
                      typeof detail['amount'] === 'number' ? formatMoney(detail['amount']) : '—'
                    }
                  />
                ) : null}
                {detail['user_email'] !== undefined ? (
                  <DetailRow
                    label={t('detail.userEmail')}
                    value={displayString(detail['user_email']) || '—'}
                  />
                ) : null}
                {detail['user_id'] !== undefined ? (
                  <DetailRow
                    label={t('detail.userId')}
                    value={<span className="font-mono">{displayString(detail['user_id'])}</span>}
                  />
                ) : null}
                {detail['subscription_id'] !== undefined ? (
                  <DetailRow
                    label={t('detail.subscriptionId')}
                    value={
                      <span className="font-mono">{displayString(detail['subscription_id'])}</span>
                    }
                  />
                ) : null}
                {detail['billing_product_id'] !== undefined ? (
                  <DetailRow
                    label={t('detail.billingProductId')}
                    value={displayString(detail['billing_product_id']) || '—'}
                  />
                ) : null}
                {detail['created_at'] !== undefined ? (
                  <DetailRow
                    label={t('detail.createdAt')}
                    value={formatDateTime(displayString(detail['created_at']))}
                  />
                ) : null}
              </dl>

              <ReceiptMetadata detail={detail} />

              {canMark ? (
                <div className="flex justify-end border-t border-border pt-4">
                  <Button variant="outline" onClick={() => setMarkTarget(selected)}>
                    {t('detail.markRefunded')}
                  </Button>
                </div>
              ) : null}
            </div>
          )}
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={markTarget !== null}
        onOpenChange={(open) => {
          if (!open) setMarkTarget(null)
        }}
        title={t('markRefunded.dialogTitle')}
        description={t('markRefunded.dialogDescription', {
          transactionId: markTarget?.transaction_id ?? '—',
        })}
        confirmLabel={t('markRefunded.confirm')}
        onConfirm={async () => {
          const txnId = markTarget?.transaction_id
          if (!txnId) return
          try {
            await markMutation.mutateAsync(txnId)
          } catch (error) {
            throw new Error(isApiError(error) ? error.message : t('markRefunded.errorGeneric'))
          }
        }}
      />
    </div>
  )
}

function DetailRow({
  label,
  value,
}: {
  label: string
  value: React.ReactNode
}) {
  return (
    <div className="flex items-baseline justify-between gap-3 border-b border-border/60 pb-2">
      <dt className="shrink-0 text-muted-foreground">{label}</dt>
      <dd className="text-right font-medium">{value}</dd>
    </div>
  )
}

/** Renders the untyped remainder of the detail payload as raw receipt metadata. */
function ReceiptMetadata({ detail }: { detail: Record<string, unknown> }) {
  const { t } = useTranslation('iap')
  const entries = Object.entries(detail)
    .filter(([key]) => !KNOWN_DETAIL_KEYS.has(key))
    .filter(
      ([, value]) =>
        value === null ||
        value === undefined ||
        typeof value === 'string' ||
        typeof value === 'number' ||
        typeof value === 'boolean',
    )
  if (entries.length === 0) {
    return <p className="text-sm text-muted-foreground">{t('detail.noReceipt')}</p>
  }
  return (
    <div>
      <h4 className="mb-2 text-sm font-semibold">{t('detail.receipt')}</h4>
      <dl className="grid grid-cols-1 gap-x-6 gap-y-2 text-sm sm:grid-cols-2">
        {entries.map(([key, value]) => (
          <div key={key} className="flex items-baseline justify-between gap-3">
            <dt className="shrink-0 font-mono text-xs text-muted-foreground">{key}</dt>
            <dd className="truncate text-right font-mono text-xs">{displayString(value) || '—'}</dd>
          </div>
        ))}
      </dl>
    </div>
  )
}
