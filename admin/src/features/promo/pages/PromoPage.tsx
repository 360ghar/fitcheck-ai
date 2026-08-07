import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { Download, Plus, Tag } from 'lucide-react'
import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'
import { z } from 'zod'

import {
  createPromoCode,
  listPromoCodes,
  promoKeys,
  updatePromoCode,
  PROMO_PLAN_TYPES,
  type AdminPromoCodeCreate,
  type PromoCodeItem,
} from '@/features/promo/api/promo'
import { isApiError } from '@/shared/api/errors'
import { useCsvExport } from '@/shared/hooks/useCsvExport'
import { usePermission } from '@/shared/hooks/usePermission'
import { formatDate, toDate } from '@/shared/lib/formatters'
import { Button } from '@/shared/ui/button'
import { ConfirmDialog } from '@/shared/ui/ConfirmDialog'
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
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/shared/ui/form'
import { Input } from '@/shared/ui/input'
import { PageHeader } from '@/shared/ui/PageHeader'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/shared/ui/select'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import { Switch } from '@/shared/ui/switch'
import { TableToolbar } from '@/shared/ui/TableToolbar'
import { useServerTable } from '@/shared/ui/useServerTable'

type PromoFormValues = {
  code: string
  plan_type: (typeof PROMO_PLAN_TYPES)[number]
  months: string
  max_uses: string
  expires_at: string
  active: boolean
}

export function PromoPage() {
  const { t } = useTranslation('promo')
  const { can } = usePermission()
  const queryClient = useQueryClient()
  const canManage = can('content.write')
  const [createOpen, setCreateOpen] = useState(false)
  const [toggleTarget, setToggleTarget] = useState<PromoCodeItem | null>(null)

  const table = useServerTable<PromoCodeItem>({
    queryKey: promoKeys.all,
    queryFn: listPromoCodes,
    filterKeys: ['active', 'plan_type'],
  })

  const csvExport = useCsvExport<PromoCodeItem>({
    rows: table.data,
    filename: t('export.filename'),
    toastMessage: t('export.toast', { count: table.data.length }),
    columns: [
      { label: t('columns.code'), value: (row) => row.code },
      { label: t('columns.discount'), value: (row) => String(row.months) },
      { label: t('columns.plan'), value: (row) => row.plan_type },
      { label: t('columns.active'), value: (row) => String(row.active ?? false) },
      { label: t('columns.redemptions'), value: (row) => row.redemptions_count ?? 0 },
      {
        label: t('columns.expires'),
        value: (row) => (row.expires_at ? toDate(row.expires_at)?.toISOString() ?? '' : ''),
      },
      {
        label: t('columns.createdAt'),
        value: (row) => toDate(row.created_at)?.toISOString() ?? '',
      },
    ],
  })

  const promoFormSchema = z.object({
    code: z
      .string()
      .min(1, t('errors.codeRequired'))
      .max(50, t('errors.codeFormat'))
      .regex(/^[a-zA-Z0-9][a-zA-Z0-9_-]{2,49}$/, t('errors.codeFormat')),
    plan_type: z.enum(PROMO_PLAN_TYPES, { message: t('errors.planRequired') }),
    months: z
      .string()
      .min(1, t('errors.monthsRequired'))
      .regex(/^[1-9]\d*$/, t('errors.monthsMin')),
    max_uses: z.string().refine(
      (value) => value === '' || /^[1-9]\d*$/.test(value),
      t('errors.maxUsesMin'),
    ),
    expires_at: z.string(),
    active: z.boolean(),
  })

  const form = useForm<PromoFormValues>({
    resolver: zodResolver(promoFormSchema),
    defaultValues: {
      code: '',
      plan_type: 'plus_monthly',
      months: '1',
      max_uses: '',
      expires_at: '',
      active: true,
    },
  })

  const createMutation = useMutation({
    mutationFn: createPromoCode,
    onSuccess: (created) => {
      toast.success(t('create.success', { code: created.code }))
      setCreateOpen(false)
      form.reset()
      void queryClient.invalidateQueries({ queryKey: promoKeys.all })
    },
    onError: (error, _vars) => {
      if (isApiError(error) && error.code === 'VALIDATION_ERROR' && error.details?.field === 'code') {
        form.setError('code', { message: t('errors.codeDuplicate') })
        return
      }
      toast.error(t('errors.createFailed'))
    },
  })

  const toggleMutation = useMutation({
    mutationFn: ({ codeId, active }: { codeId: string; active: boolean }) =>
      updatePromoCode(codeId, { active }),
    onSuccess: (updated) => {
      toast.success(t('toggle.success', { code: updated.code }))
      setToggleTarget(null)
      void queryClient.invalidateQueries({ queryKey: promoKeys.all })
    },
    onError: () => {
      toast.error(t('toggle.errorGeneric'))
    },
  })

  const handleCreateSubmit = (values: PromoFormValues): void => {
    const body: AdminPromoCodeCreate = {
      code: values.code.trim(),
      plan_type: values.plan_type,
      months: Number(values.months),
      active: values.active,
    }
    if (values.max_uses) body.max_uses = Number(values.max_uses)
    if (values.expires_at) body.expires_at = values.expires_at
    createMutation.mutate(body)
  }

  const columns: ColumnDef<PromoCodeItem>[] = [
    {
      id: 'code',
      header: t('columns.code'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="font-mono text-sm font-semibold tracking-wide">{row.original.code}</span>
      ),
    },
    {
      id: 'discount',
      header: t('columns.discount'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="whitespace-nowrap">{t('discount.months', { months: row.original.months })}</span>
      ),
    },
    {
      id: 'plan_type',
      header: t('columns.plan'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="rounded-full bg-surface-card px-2.5 py-0.5 text-xs font-medium">
          {t(`plans.${row.original.plan_type}`, { defaultValue: row.original.plan_type })}
        </span>
      ),
    },
    {
      id: 'active',
      header: t('columns.active'),
      enableSorting: false,
      cell: ({ row }) => (
        <StatusBadge
          status={row.original.active ? 'active' : 'disabled'}
          label={t(row.original.active ? 'active.active' : 'active.inactive')}
        />
      ),
    },
    {
      id: 'redemptions_count',
      header: t('columns.redemptions'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="tabular-nums">
          {row.original.redemptions_count}
          {row.original.max_uses !== null
            ? ` / ${row.original.max_uses}`
            : ''}
        </span>
      ),
    },
    {
      id: 'expires_at',
      header: t('columns.expires'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="whitespace-nowrap text-sm text-muted-foreground">
          {row.original.expires_at ? formatDate(row.original.expires_at) : '—'}
        </span>
      ),
    },
    {
      id: 'created_at',
      header: t('columns.createdAt'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="whitespace-nowrap text-sm text-muted-foreground">
          {formatDate(row.original.created_at)}
        </span>
      ),
    },
    {
      id: 'actions',
      enableSorting: false,
      cell: ({ row }) => {
        if (!canManage) return null
        return (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setToggleTarget(row.original)}
            aria-label={t(
              row.original.active ? 'rowActions.deactivate' : 'rowActions.activate',
            )}
          >
            {t(row.original.active ? 'rowActions.deactivate' : 'rowActions.activate')}
          </Button>
        )
      },
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        title={t('title')}
        description={t('description')}
        actions={
          canManage ? (
            <Button onClick={() => setCreateOpen(true)}>
              <Plus aria-hidden="true" />
              {t('create.title')}
            </Button>
          ) : undefined
        }
      />

      <TableToolbar
        searchValue={table.tableState.q}
        onSearchChange={table.tableState.setQ}
        primaryFilter={{
          key: 'active',
          label: t('filters.active'),
          placeholder: t('filters.activePlaceholder'),
          options: [
            { value: 'all', label: t('filters.activePlaceholder') },
            { value: 'active', label: t('active.active') },
            { value: 'inactive', label: t('active.inactive') },
          ],
          value: table.tableState.filters.active,
          onValueChange: (value) =>
            table.tableState.setFilter(
              'active',
              value === 'active' ? 'true' : value === 'inactive' ? 'false' : undefined,
            ),
        }}
        filters={[
          {
            key: 'plan_type',
            label: t('filters.plan'),
            placeholder: t('filters.planPlaceholder'),
            options: [
              { value: 'all', label: t('filters.planPlaceholder') },
              ...PROMO_PLAN_TYPES.map((plan) => ({
                value: plan,
                label: t(`plans.${plan}`, { defaultValue: plan }),
              })),
            ],
            value: table.tableState.filters.plan_type,
            onValueChange: (value) =>
              table.tableState.setFilter('plan_type', value && value !== 'all' ? value : undefined),
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
        <DataTable<PromoCodeItem>
          {...table.props}
          columns={columns}
          ariaLabel={t('title')}
          getRowId={(row) => row.id}
          onResetFilters={() => table.tableState.reset()}
          emptyState={<EmptyState icon={Tag} title={t('empty.title')} message={t('empty.message')} />}
        />
      )}

      {/* Create dialog */}
      <Dialog open={createOpen} onOpenChange={setCreateOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>{t('create.title')}</DialogTitle>
            <DialogDescription>{t('create.description')}</DialogDescription>
          </DialogHeader>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(handleCreateSubmit)} className="space-y-5">
              <FormField
                control={form.control}
                name="code"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('form.code')}</FormLabel>
                    <FormControl>
                      <Input
                        placeholder={t('form.codePlaceholder')}
                        autoComplete="off"
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>{t('form.codeHint')}</FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="plan_type"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('form.planType')}</FormLabel>
                    <Select value={field.value} onValueChange={field.onChange}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {PROMO_PLAN_TYPES.map((plan) => (
                          <SelectItem key={plan} value={plan}>
                            {t(`plans.${plan}`, { defaultValue: plan })}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <div className="grid grid-cols-2 gap-4">
                <FormField
                  control={form.control}
                  name="months"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>{t('form.months')}</FormLabel>
                      <FormControl>
                        <Input type="number" min={1} {...field} />
                      </FormControl>
                      <FormDescription>{t('form.monthsHint')}</FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="max_uses"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>{t('form.maxUses')}</FormLabel>
                      <FormControl>
                        <Input
                          type="number"
                          min={1}
                          placeholder={t('form.maxUsesPlaceholder')}
                          {...field}
                        />
                      </FormControl>
                      <FormDescription>{t('form.maxUsesHint')}</FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
              <FormField
                control={form.control}
                name="expires_at"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('form.expiresAt')}</FormLabel>
                    <FormControl>
                      <Input type="date" {...field} />
                    </FormControl>
                    <FormDescription>{t('form.expiresAtHint')}</FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="active"
                render={({ field }) => (
                  <FormItem className="flex items-center justify-between gap-4 rounded-md border border-border p-3">
                    <div>
                      <FormLabel>{t('form.active')}</FormLabel>
                    </div>
                    <FormControl>
                      <Switch checked={field.value} onCheckedChange={field.onChange} />
                    </FormControl>
                  </FormItem>
                )}
              />
              <DialogFooter>
                <Button
                  type="button"
                  variant="secondary"
                  onClick={() => setCreateOpen(false)}
                  disabled={createMutation.isPending}
                >
                  {t('create.cancel')}
                </Button>
                <Button type="submit" loading={createMutation.isPending}>
                  {t('create.submit')}
                </Button>
              </DialogFooter>
            </form>
          </Form>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={toggleTarget !== null}
        onOpenChange={(open) => {
          if (!open) setToggleTarget(null)
        }}
        title={t(
          toggleTarget?.active ? 'toggle.deactivateTitle' : 'toggle.activateTitle',
        )}
        {...(toggleTarget
          ? {
              description: t(
                toggleTarget.active
                  ? 'toggle.deactivateDescription'
                  : 'toggle.activateDescription',
                { code: toggleTarget.code },
              ),
            }
          : {})}
        confirmLabel={t('toggle.confirm')}
        onConfirm={async () => {
          if (!toggleTarget) return
          await toggleMutation.mutateAsync({
            codeId: toggleTarget.id,
            active: !toggleTarget.active,
          })
        }}
      />
    </div>
  )
}
