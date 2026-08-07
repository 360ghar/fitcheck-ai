import { useMutation, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { Download } from 'lucide-react'
import { useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useNavigate } from 'react-router-dom'
import { toast } from 'sonner'

import { listUsers, patchUser, userKeys } from '@/features/users/api/users'
import { planLabelKey, roleLabelKey, subscriptionPlan } from '@/features/users/lib/users'
import { normalizeError } from '@/shared/api/errors'
import type { AdminUserListItem } from '@/shared/api/schemaTypes'
import { useCsvExport } from '@/shared/hooks/useCsvExport'
import { usePermission } from '@/shared/hooks/usePermission'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { formatDateValue, formatNumber, toDate } from '@/shared/lib/formatters'
import { ADMIN_ROLES } from '@/shared/lib/permissions'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import { ConfirmDialog } from '@/shared/ui/ConfirmDialog'
import { DataTable } from '@/shared/ui/DataTable'
import { ErrorState } from '@/shared/ui/ErrorState'
import { PageHeader } from '@/shared/ui/PageHeader'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import { TableToolbar } from '@/shared/ui/TableToolbar'
import { useServerTable } from '@/shared/ui/useServerTable'

/** Value for "no filter" in a Radix Select (empty strings are reserved). */
const ALL_VALUE = '__all__'

const PLANS = ['free', 'plus_monthly', 'plus_yearly', 'pro_monthly', 'pro_yearly'] as const

export function UsersPage() {
  const { t } = useTranslation('users')
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { can } = usePermission()
  const canWrite = can('users.write')

  const table = useServerTable<AdminUserListItem>({
    queryKey: userKeys.all,
    queryFn: (params: TableStateParams) => listUsers(params),
    filterKeys: ['status', 'role', 'plan'],
  })

  const csvExport = useCsvExport<AdminUserListItem>({
    rows: table.data,
    filename: t('export.filename'),
    toastMessage: t('export.toast', { count: table.data.length }),
    columns: [
      { label: t('columns.email'), value: (row) => row.email ?? '' },
      { label: t('columns.fullName'), value: (row) => row.full_name ?? '' },
      { label: t('columns.role'), value: (row) => row.role ?? '' },
      { label: t('columns.plan'), value: (row) => subscriptionPlan(row.subscription) ?? '' },
      { label: t('columns.items'), value: (row) => row.items_count ?? 0 },
      { label: t('columns.outfits'), value: (row) => row.outfits_count ?? 0 },
      { label: t('columns.status'), value: (row) => String(row.is_active ?? false) },
      {
        label: t('columns.createdAt'),
        value: (row) => toDate(row.created_at)?.toISOString() ?? '',
      },
    ],
  })

  const [pendingBulk, setPendingBulk] = useState<
    { action: 'suspend' | 'activate'; rows: AdminUserListItem[] } | null
  >(null)

  const bulkMutation = useMutation({
    mutationFn: async ({ action, rows }: { action: 'suspend' | 'activate'; rows: AdminUserListItem[] }) => {
      // Sequential PATCHes so each is individually audited; a slow batch
      // never hammers the backend with parallel writes.
      const results = await Promise.allSettled(
        rows.map((row) => patchUser(row.id, { is_active: action === 'activate' })),
      )
      const failed = results.filter(
        (result): result is PromiseRejectedResult => result.status === 'rejected',
      )
      if (failed.length > 0) {
        const firstError = normalizeError(failed[0]?.reason)
        toast.error(
          t('bulk.failure', {
            failed: failed.length,
            total: results.length,
            message: firstError.message,
          }),
        )
      } else {
        toast.success(
          t(action === 'suspend' ? 'bulk.successSuspend' : 'bulk.successActivate', {
            done: results.length,
            total: results.length,
          }),
        )
      }
    },
    onSettled: () => {
      void queryClient.invalidateQueries({ queryKey: userKeys.all })
      setPendingBulk(null)
    },
  })

  const columns = useMemo<ColumnDef<AdminUserListItem>[]>(
    () => [
      {
        accessorKey: 'email',
        header: t('columns.email'),
        cell: ({ row }) => (
          <Link
            to={`/users/${row.original.id}`}
            className="font-medium text-ink underline-offset-4 hover:underline"
            onClick={(event) => event.stopPropagation()}
          >
            {row.original.email ?? '—'}
          </Link>
        ),
      },
      {
        accessorKey: 'full_name',
        header: t('columns.fullName'),
        cell: ({ row }) => row.original.full_name ?? '—',
      },
      {
        accessorKey: 'role',
        header: t('columns.role'),
        // Not in the backend sort_by whitelist (created_at|last_login_at|email|full_name)
        enableSorting: false,
        cell: ({ row }) => {
          const role = row.original.role
          return (
            <Badge variant="default">
              {t(roleLabelKey(role), { defaultValue: role ?? '—' })}
            </Badge>
          )
        },
      },
      {
        accessorKey: 'plan',
        header: t('columns.plan'),
        // Not in the backend sort_by whitelist
        enableSorting: false,
        cell: ({ row }) => {
          const plan = subscriptionPlan(row.original.subscription)
          const labelKey = planLabelKey(plan)
          return labelKey ? t(labelKey) : t('plans.none')
        },
      },
      {
        accessorKey: 'items_count',
        header: t('columns.items'),
        // Not in the backend sort_by whitelist
        enableSorting: false,
        cell: ({ row }) => formatNumber(row.original.items_count ?? 0),
      },
      {
        accessorKey: 'outfits_count',
        header: t('columns.outfits'),
        // Not in the backend sort_by whitelist
        enableSorting: false,
        cell: ({ row }) => formatNumber(row.original.outfits_count ?? 0),
      },
      {
        accessorKey: 'is_active',
        header: t('columns.status'),
        // Not in the backend sort_by whitelist
        enableSorting: false,
        cell: ({ row }) => {
          const active = row.original.is_active === true
          return (
            <StatusBadge
              status={active ? 'active' : 'suspended'}
              label={t(active ? 'status.active' : 'status.suspended')}
            />
          )
        },
      },
      {
        accessorKey: 'created_at',
        header: t('columns.createdAt'),
        cell: ({ row }) => formatDateValue(row.original.created_at),
      },
    ],
    [t],
  )

  if (table.query.isError) {
    return (
      <div className="space-y-6">
        <PageHeader title={t('title')} description={t('description')} />
        <ErrorState
          message={normalizeError(table.query.error).message}
          onRetry={() => void table.query.refetch()}
        />
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <PageHeader title={t('title')} description={t('description')} />

      <TableToolbar
        searchValue={table.tableState.q}
        onSearchChange={table.tableState.setQ}
        searchPlaceholder={t('searchPlaceholder')}
        primaryFilter={{
          key: 'status',
          label: t('filters.status'),
          placeholder: t('filters.statusAll'),
          options: [
            { value: ALL_VALUE, label: t('filters.statusAll') },
            { value: 'active', label: t('status.active') },
            { value: 'suspended', label: t('status.suspended') },
          ],
          value: table.tableState.filters.status,
          onValueChange: (value) =>
            table.tableState.setFilter('status', value === ALL_VALUE ? undefined : value),
        }}
        filters={[
          {
            key: 'role',
            label: t('filters.role'),
            placeholder: t('filters.roleAll'),
            options: [
              { value: ALL_VALUE, label: t('filters.roleAll') },
              ...[...ADMIN_ROLES, 'user'].map((role) => ({
                value: role,
                label: t(roleLabelKey(role), { defaultValue: role }),
              })),
            ],
            value: table.tableState.filters.role,
            onValueChange: (value) =>
              table.tableState.setFilter('role', value === ALL_VALUE ? undefined : value),
          },
          {
            key: 'plan',
            label: t('filters.plan'),
            placeholder: t('filters.planAll'),
            options: [
              { value: ALL_VALUE, label: t('filters.planAll') },
              ...PLANS.map((plan) => ({
                value: plan,
                label: t(planLabelKey(plan) ?? ''),
              })),
            ],
            value: table.tableState.filters.plan,
            onValueChange: (value) =>
              table.tableState.setFilter('plan', value === ALL_VALUE ? undefined : value),
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

      <DataTable<AdminUserListItem>
        columns={columns}
        getRowId={(row) => row.id}
        onRowClick={(row) => navigate(`/users/${row.id}`)}
        {...(canWrite
          ? {
              bulkActions: (selected) => (
                <>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setPendingBulk({ action: 'activate', rows: selected })}
                  >
                    {t('bulk.activate')}
                  </Button>
                  <Button
                    variant="destructive"
                    size="sm"
                    onClick={() => setPendingBulk({ action: 'suspend', rows: selected })}
                  >
                    {t('bulk.suspend')}
                  </Button>
                </>
              ),
            }
          : {})}
        ariaLabel={t('title')}
        {...table.props}
      />

      <ConfirmDialog
        open={pendingBulk !== null}
        onOpenChange={(open) => {
          if (!open) setPendingBulk(null)
        }}
        title={t(
          pendingBulk?.action === 'suspend' ? 'bulk.suspendTitle' : 'bulk.activateTitle',
          { count: pendingBulk?.rows.length ?? 0 },
        )}
        description={t(
          pendingBulk?.action === 'suspend'
            ? 'bulk.suspendDescription'
            : 'bulk.activateDescription',
        )}
        confirmLabel={t(
          pendingBulk?.action === 'suspend' ? 'bulk.suspend' : 'bulk.activate',
        )}
        destructive={pendingBulk?.action === 'suspend'}
        onConfirm={() =>
          pendingBulk
            ? bulkMutation.mutateAsync(pendingBulk)
            : Promise.resolve()
        }
      />
    </div>
  )
}
