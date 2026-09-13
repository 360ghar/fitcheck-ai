import { zodResolver } from '@hookform/resolvers/zod'
import type { ColumnDef } from '@tanstack/react-table'
import type { TFunction } from 'i18next'
import { Download, Flame } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router-dom'
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
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
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
import { Skeleton } from '@/shared/ui/skeleton'
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

type QuotaOperation = 'extraction' | 'generation' | 'embedding'

type OperationUsage = {
  operation: QuotaOperation
  used: number
  limit: number
}

function operationUsage(row: AdminQuotaUsageItem): OperationUsage[] {
  return [
    {
      operation: 'extraction',
      used: row.daily_extraction_count ?? 0,
      limit: row.effective_extraction_limit,
    },
    {
      operation: 'generation',
      used: row.daily_generation_count ?? 0,
      limit: row.effective_generation_limit,
    },
    {
      operation: 'embedding',
      used: row.daily_embedding_count ?? 0,
      limit: row.effective_embedding_limit,
    },
  ]
}

/** Today's combined count, used only for the CSV export. */
function usedCount(row: AdminQuotaUsageItem): number {
  return operationUsage(row).reduce((total, item) => total + item.used, 0)
}

function quotaPct(row: AdminQuotaUsageItem): number {
  return Math.max(
    // A 0 effective limit means the operation is disabled: any use is over
    // quota (100%+ bucket), not 0%.
    ...operationUsage(row).map(({ used, limit }) => (limit > 0 ? used / limit : used > 0 ? 1 : 0)),
  )
}

function lowestRemaining(row: AdminQuotaUsageItem): number {
  return Math.min(...operationUsage(row).map(({ used, limit }) => Math.max(0, limit - used)))
}

/** Display name for a quota row (full_name → email → id). */
function rowName(row: AdminQuotaUsageItem): string {
  return row.full_name ?? row.email ?? row.user_id
}

/** Histogram bucket i18n keys, ordered lowest → highest burn. */
const BUCKET_KEYS = ['bucket0', 'bucket1', 'bucket2', 'bucket3', 'bucket4'] as const

function bucketIndex(pct: number): number {
  if (pct < 0.25) return 0
  if (pct < 0.5) return 1
  if (pct < 0.75) return 2
  if (pct < 1) return 3
  return 4
}

export function QuotasPage() {
  const { t } = useTranslation('quotas')
  const { can } = usePermission()
  const canOverride = can('quotas.write')
  const canRead = can('quotas.read')
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
        value: (row) => operationUsage(row)
          .map((item) => `${item.operation}:${item.limit}`)
          .join(' '),
      },
    ],
  })

  // Histogram buckets — client-side from table.data, no new query
  const histogram = useMemo(() => {
    const counts = [0, 0, 0, 0, 0] as number[]
    for (const row of table.data) {
      const idx = bucketIndex(quotaPct(row))
      if (idx >= 0 && idx < counts.length) {
        counts[idx] = (counts[idx] ?? 0) + 1
      }
    }
    return counts as [number, number, number, number, number]
  }, [table.data])

  const topBurners = useMemo(() => {
    const sorted = [...table.data].sort((a, b) => quotaPct(b) - quotaPct(a))
    return sorted.slice(0, 5)
  }, [table.data])

  const maxBucket = Math.max(...histogram, 1)

  useEffect(() => {
    if (selectedRow) {
      setFormError(null)
      form.reset({ dailyLimit: String(selectedRow.custom_daily_quota ?? '') })
    }
  }, [selectedRow, form])

  const columns = useMemo<ColumnDef<AdminQuotaUsageItem>[]>(
    () => [
      {
        id: 'user',
        accessorFn: (row) => row.email ?? row.full_name ?? row.user_id,
        header: t('columns.email'),
        size: 240,
        minSize: 220,
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
        size: 140,
        minSize: 110,
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
        size: 160,
        minSize: 140,
        cell: ({ row }) => (
          <div className="flex gap-2 text-xs tabular-nums text-ink">
            {operationUsage(row.original).map((item) => (
              <span key={item.operation}>
                {t(`operations.${item.operation}Short`)} {formatNumber(item.used)}
              </span>
            ))}
          </div>
        ),
        enableSorting: false,
      },
      {
        accessorKey: 'custom_daily_quota',
        header: t('columns.limit'),
        size: 180,
        minSize: 150,
        cell: ({ row }) => {
          const custom = row.original.custom_daily_quota
          return (
            <div className="flex flex-wrap gap-x-2 gap-y-1 text-xs tabular-nums text-ink">
              {operationUsage(row.original).map((item) => (
                <span key={item.operation}>
                  {t(`operations.${item.operation}Short`)} {formatNumber(item.limit)}
                </span>
              ))}
              {custom !== null && custom !== undefined ? (
                <Badge variant="info">{t('override.label')}</Badge>
              ) : null}
            </div>
          )
        },
        enableSorting: false,
      },
      {
        id: 'pct',
        header: t('columns.pct'),
        size: 110,
        minSize: 90,
        cell: ({ row }) => {
          const pct = quotaPct(row.original)
          const label = `${Math.round(pct * 100)}%`
          let variant: 'success' | 'secondary' | 'warning' | 'danger' = 'secondary'
          if (pct >= 1) variant = 'danger'
          else if (pct >= 0.75) variant = 'warning'
          else if (pct < 0.25) variant = 'success'
          return <Badge variant={variant}>{label}</Badge>
        },
        enableSorting: false,
      },
      {
        id: 'remaining',
        accessorFn: lowestRemaining,
        header: t('columns.remaining'),
        size: 120,
        minSize: 90,
        cell: ({ row }) => {
          return (
            <span className="tabular-nums text-ink">
              {formatNumber(lowestRemaining(row.original))}
            </span>
          )
        },
        enableSorting: false,
      },
      {
        id: 'override',
        header: t('columns.override'),
        size: 160,
        minSize: 130,
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

  if (!canRead) {
    return (
      <div className="space-y-3">
        <ErrorState message={t('permissionDenied')} />
      </div>
    )
  }

  if (table.query.isError) {
    return (
      <div className="space-y-3">
        <PageHeader dense title={t('title')} description={t('description')} />
        <ErrorState
          message={normalizeError(table.query.error).message}
          onRetry={() => void table.query.refetch()}
        />
      </div>
    )
  }

  return (
    <div className="space-y-3">
      <PageHeader dense title={t('title')} description={t('description')} />

      <>
          {/* Burn histogram + top burners — client-side from table.data */}
          {table.query.isPending ? (
            <Card>
              <CardHeader dense>
                <CardTitle className="text-sm font-semibold">
                  {t('histogram.title')}
                </CardTitle>
              </CardHeader>
              <CardContent dense>
                <div className="space-y-3">
                  <div className="flex gap-2">
                    {Array.from({ length: 5 }).map((_, i) => (
                      <Skeleton key={i} className="h-6 flex-1" />
                    ))}
                  </div>
                  <Skeleton className="h-20 w-full" />
                </div>
              </CardContent>
            </Card>
          ) : table.data.length === 0 ? (
            <Card>
              <CardContent dense>
                <p className="py-4 text-center text-sm text-muted-foreground">
                  {t('histogram.empty')}
                </p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
              <Card className="lg:col-span-2">
                <CardHeader dense>
                  <CardTitle className="flex items-center gap-2 text-sm font-semibold">
                    <Flame className="size-4 text-warning-deep" aria-hidden="true" />
                    {t('histogram.title')}
                    <span className="ml-auto text-xs font-normal text-muted-foreground">
                      {t('histogram.subtitle')}
                    </span>
                  </CardTitle>
                </CardHeader>
                <CardContent dense>
                  <div className="space-y-3">
                    <div className="flex flex-wrap gap-2">
                      {BUCKET_KEYS.map((key, idx) => (
                        <Badge
                          key={key}
                          variant={idx === 4 ? 'danger' : idx >= 3 ? 'warning' : 'secondary'}
                          aria-label={`${t(`histogram.${key}`)}: ${t('histogram.users', { count: histogram[idx] ?? 0 })}`}
                        >
                          {t(`histogram.${key}`)}: {formatNumber(histogram[idx] ?? 0)}
                        </Badge>
                      ))}
                    </div>
                    {/* Simple bar chart — CSS bars, no extra query */}
                    <div className="flex items-end gap-2 pt-2" role="img" aria-label={t('histogram.aria')}>
                      {histogram.map((count, idx) => {
                        const height = Math.max(8, Math.round((count / maxBucket) * 64))
                        return (
                          <div key={idx} className="flex flex-1 flex-col items-center gap-1">
                            <span className="text-xs tabular-nums text-muted-foreground">{count}</span>
                            <div
                              className={`w-full rounded-sm ${idx === 4 ? 'bg-destructive' : idx === 3 ? 'bg-warning' : 'bg-primary'}`}
                              style={{ height }}
                              aria-hidden="true"
                            />
                            <span className="text-[10px] font-medium text-muted-foreground">{t(`histogram.${BUCKET_KEYS[idx]}`)}</span>
                          </div>
                        )
                      })}
                    </div>
                    <p className="pt-2 text-center text-xs text-muted-foreground">
                      {t('histogram.caption')}
                    </p>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader dense>
                  <CardTitle className="text-sm font-semibold">
                    {t('topBurners.title')}
                  </CardTitle>
                </CardHeader>
                <CardContent dense>
                  {topBurners.length === 0 ? (
                    <p className="py-2 text-sm text-muted-foreground">
                      {t('topBurners.empty')}
                    </p>
                  ) : (
                    <ul className="space-y-2">
                      {topBurners.map((row) => {
                        const pct = quotaPct(row)
                        const mostUsed = operationUsage(row).reduce((current, item) =>
                          item.limit > 0 && item.used / item.limit > current.used / Math.max(1, current.limit)
                            ? item
                            : current,
                        )
                        return (
                          <li key={row.user_id} className="flex items-center gap-3 rounded-md border border-border px-3 py-2 transition-colors hover:bg-surface-card">
                            <div className="min-w-0 flex-1">
                              <Link
                                to={`/users/${row.user_id}`}
                                className="truncate text-sm font-medium text-foreground underline-offset-4 hover:underline"
                              >
                                {rowName(row)}
                              </Link>
                              <p className="truncate text-xs text-muted-foreground">
                                {t(`operations.${mostUsed.operation}Short`)} {formatNumber(mostUsed.used)} / {formatNumber(mostUsed.limit)} • {row.plan_type ?? '—'}
                              </p>
                            </div>
                            <Badge variant={pct >= 1 ? 'danger' : pct >= 0.75 ? 'warning' : 'secondary'}>
                              {Math.round(pct * 100)}%
                            </Badge>
                          </li>
                        )
                      })}
                    </ul>
                  )}
                </CardContent>
              </Card>
            </div>
          )}

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
      </>

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
