import { zodResolver } from '@hookform/resolvers/zod'
import type { ColumnDef } from '@tanstack/react-table'
import type { TFunction } from 'i18next'
import { Download } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'
import { z } from 'zod'

import { listQuotas, quotaKeys, useSetQuotaOverride } from '@/features/quotas/api/quotas'
import { normalizeError } from '@/shared/api/errors'
import type { AdminQuotaUsageItem } from '@/shared/api/schemaTypes'
import { useCsvExport } from '@/shared/hooks/useCsvExport'
import { usePermission } from '@/shared/hooks/usePermission'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { formatNumber } from '@/shared/lib/formatters'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import { DataTable } from '@/shared/ui/DataTable'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/shared/ui/dialog'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/shared/ui/form'
import { Input } from '@/shared/ui/input'
import { PageHeader } from '@/shared/ui/PageHeader'
import { TableToolbar } from '@/shared/ui/TableToolbar'
import { useServerTable } from '@/shared/ui/useServerTable'

/** Value for "no filter" in a Radix Select (empty strings are reserved). */
const ALL_VALUE = '__all__'

const PLANS = ['free', 'plus_monthly', 'plus_yearly', 'pro_monthly', 'pro_yearly'] as const

const planLabelKeys: Record<(typeof PLANS)[number], string> = {
  free: 'users:plans.free',
  plus_monthly: 'users:plans.plus_monthly',
  plus_yearly: 'users:plans.plus_yearly',
  pro_monthly: 'users:plans.pro_monthly',
  pro_yearly: 'users:plans.pro_yearly',
}

/** Raw-string validation so empty vs <1 vs non-integer get distinct messages. */
function overrideSchema(t: TFunction<'quotas', undefined>) {
  return z.object({
    dailyLimit: z
      .string()
      .trim()
      .refine((value) => value !== '', t('override.required'))
      .refine((value) => /^\d+$/.test(value), t('override.integer'))
      .refine((value) => Number(value) >= 1, t('override.min')),
  })
}

type OverrideFormValues = z.infer<ReturnType<typeof overrideSchema>>

/** Today's "used" total = extraction + generation + embedding counters. */
function usedCount(row: AdminQuotaUsageItem): number {
  return (
    (row.daily_extraction_count ?? 0) +
    (row.daily_generation_count ?? 0) +
    (row.daily_embedding_count ?? 0)
  )
}

/** Display name for a quota row (full_name → email → id). */
function rowName(row: AdminQuotaUsageItem): string {
  return row.full_name ?? row.email ?? row.user_id
}

export function QuotasPage() {
  const { t } = useTranslation('quotas')
  const { can } = usePermission()
  const canOverride = can('quotas.read')
  const [selectedRow, setSelectedRow] = useState<AdminQuotaUsageItem | null>(null)
  const [formError, setFormError] = useState<string | null>(null)
  const overrideMutation = useSetQuotaOverride()

  const schema = useMemo(() => overrideSchema(t), [t])
  const form = useForm<OverrideFormValues>({
    resolver: zodResolver(schema),
    defaultValues: { dailyLimit: '' },
  })

  const table = useServerTable<AdminQuotaUsageItem>({
    queryKey: quotaKeys.all,
    queryFn: (params: TableStateParams) => listQuotas(params),
    filterKeys: ['plan'],
  })

  const csvExport = useCsvExport<AdminQuotaUsageItem>({
    rows: table.data,
    filename: t('export.filename'),
    toastMessage: t('export.toast', { count: table.data.length }),
    columns: [
      { label: t('columns.email'), value: (row) => row.full_name ?? row.email ?? row.user_id },
      { label: t('columns.userEmail'), value: (row) => row.email ?? '' },
      { label: t('columns.plan'), value: (row) => row.plan_type ?? '' },
      { label: t('columns.used'), value: (row) => usedCount(row) },
      {
        label: t('columns.limit'),
        value: (row) => (row.custom_daily_quota !== null && row.custom_daily_quota !== undefined
          ? String(row.custom_daily_quota)
          : ''),
      },
    ],
  })

  useEffect(() => {
    if (selectedRow) {
      setFormError(null)
      form.reset({ dailyLimit: String(selectedRow.custom_daily_quota ?? '') })
    }
  }, [selectedRow, form])

  const columns = useMemo<ColumnDef<AdminQuotaUsageItem>[]>(
    () => [
      {
        // id matches the backend sort_by vocabulary ('user')
        id: 'user',
        accessorFn: (row) => row.email ?? row.full_name ?? row.user_id,
        header: t('columns.email'),
        cell: ({ row }) => (
          <div className="min-w-0">
            <p className="truncate font-medium text-ink">{row.original.full_name ?? row.original.email ?? '—'}</p>
            {row.original.full_name && row.original.email ? (
              <p className="truncate text-xs text-muted-foreground">{row.original.email}</p>
            ) : null}
          </div>
        ),
      },
      {
        accessorKey: 'plan_type',
        header: t('columns.plan'),
        cell: ({ row }) => {
          const plan = row.original.plan_type
          if (!plan) return '—'
          const labelKey =
            plan in planLabelKeys ? planLabelKeys[plan as (typeof PLANS)[number]] : null
          return labelKey ? t(labelKey) : plan
        },
        enableSorting: false,
      },
      {
        id: 'used',
        accessorFn: usedCount,
        header: t('columns.used'),
        cell: ({ row }) => formatNumber(usedCount(row.original)),
        enableSorting: false,
      },
      {
        accessorKey: 'custom_daily_quota',
        header: t('columns.limit'),
        cell: ({ row }) => {
          const custom = row.original.custom_daily_quota
          return custom !== null && custom !== undefined ? (
            <span className="tabular-nums font-medium text-ink">{formatNumber(custom)}</span>
          ) : (
            <span className="text-muted-foreground">{t('limit.planDefault')}</span>
          )
        },
        enableSorting: false,
      },
      {
        id: 'remaining',
        accessorFn: (row) => {
          const custom = row.custom_daily_quota
          return custom !== null && custom !== undefined ? Math.max(0, custom - usedCount(row)) : null
        },
        header: t('columns.remaining'),
        cell: ({ row }) => {
          const custom = row.original.custom_daily_quota
          if (custom === null || custom === undefined) return t('limit.none')
          return (
            <span className="tabular-nums text-ink">
              {formatNumber(Math.max(0, custom - usedCount(row.original)))}
            </span>
          )
        },
        enableSorting: false,
      },
      {
        id: 'override',
        header: t('columns.override'),
        cell: ({ row }) => (
          <div className="flex items-center gap-2">
            {row.original.custom_daily_quota !== null &&
            row.original.custom_daily_quota !== undefined ? (
              <Badge variant="info">{t('override.label')}</Badge>
            ) : null}
            {canOverride ? (
              <Button
                variant="outline"
                size="sm"
                onClick={(event) => {
                  event.stopPropagation()
                  setSelectedRow(row.original)
                }}
              >
                {t('override.set')}
              </Button>
            ) : null}
          </div>
        ),
        enableSorting: false,
      },
    ],
    [t, canOverride],
  )

  async function submitOverride(values: OverrideFormValues): Promise<void> {
    if (!selectedRow) return
    setFormError(null)
    try {
      await overrideMutation.mutateAsync({
        userId: selectedRow.user_id,
        dailyLimit: Number(values.dailyLimit),
      })
      toast.success(t('override.savedToast', { name: rowName(selectedRow) }))
      setSelectedRow(null)
    } catch (error) {
      const apiError = normalizeError(error)
      setFormError(apiError.message)
      toast.error(t('override.failedToast', { message: apiError.message }))
    }
  }

  async function clearOverride(): Promise<void> {
    if (!selectedRow) return
    setFormError(null)
    try {
      await overrideMutation.mutateAsync({ userId: selectedRow.user_id, dailyLimit: null })
      toast.success(t('override.clearedToast', { name: rowName(selectedRow) }))
      setSelectedRow(null)
    } catch (error) {
      const apiError = normalizeError(error)
      setFormError(apiError.message)
      toast.error(t('override.failedToast', { message: apiError.message }))
    }
  }

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
          key: 'plan',
          label: t('filters.plan'),
          placeholder: t('filters.planAll'),
          options: [
            { value: ALL_VALUE, label: t('filters.planAll') },
            ...PLANS.map((plan) => ({ value: plan, label: t(planLabelKeys[plan]) })),
          ],
          value: table.tableState.filters.plan,
          onValueChange: (value) =>
            table.tableState.setFilter('plan', value === ALL_VALUE ? undefined : value),
        }}
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

      <DataTable
        columns={columns}
        getRowId={(row) => row.user_id}
        ariaLabel={t('title')}
        emptyState={
          <EmptyState
            title={t('empty.title')}
            message={t('empty.message')}
          />
        }
        {...table.props}
      />

      <Dialog
        open={selectedRow !== null}
        onOpenChange={(open) => {
          if (!open && !overrideMutation.isPending) setSelectedRow(null)
        }}
      >
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>{t('override.title')}</DialogTitle>
            <DialogDescription>
              {t('override.description', { name: selectedRow ? rowName(selectedRow) : '—' })}
            </DialogDescription>
          </DialogHeader>
          <Form {...form}>
            <form id="quota-override-form" onSubmit={form.handleSubmit(submitOverride)}>
              <FormField
                control={form.control}
                name="dailyLimit"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('override.fieldLabel')}</FormLabel>
                    <FormControl>
                      <Input
                        type="number"
                        min={1}
                        inputMode="numeric"
                        placeholder={t('override.placeholder')}
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </form>
          </Form>
          {formError ? (
            <p role="alert" className="rounded-md bg-destructive/10 px-3 py-2 text-sm text-destructive">
              {formError}
            </p>
          ) : null}
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setSelectedRow(null)}
              disabled={overrideMutation.isPending}
            >
              {t('common:cancel')}
            </Button>
            {selectedRow?.custom_daily_quota !== null &&
            selectedRow?.custom_daily_quota !== undefined ? (
              <Button
                variant="secondary"
                onClick={() => void clearOverride()}
                loading={overrideMutation.isPending}
              >
                {t('override.clear')}
              </Button>
            ) : null}
            <Button
              type="submit"
              form="quota-override-form"
              loading={overrideMutation.isPending}
            >
              {t('override.save')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
