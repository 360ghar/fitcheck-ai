import { useMutation, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { Download, Edit3, Gift, Link2, Plus, ShieldAlert, UserPlus } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import {
  adjustGiftAllowance,
  assignGift,
  createGift,
  editGift,
  exportGifts,
  giftKeys,
  GIFT_DURATIONS,
  GIFT_OCCASIONS,
  GIFT_SOURCES,
  GIFT_STATUSES,
  listGifts,
  rotateGift,
  useGiftDetailQuery,
  useGiftSummaryQuery,
  voidOrRevokeGift,
  type GiftDetail,
  type GiftItem,
  type GiftOccasion,
} from '@/features/gifts/api/gifts'
import { usePermission } from '@/shared/hooks/usePermission'
import { downloadCsv } from '@/shared/lib/csv'
import { formatDateTime, formatMoney } from '@/shared/lib/formatters'
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
import { Input } from '@/shared/ui/input'
import { Label } from '@/shared/ui/label'
import { MetricCard } from '@/shared/ui/MetricCard'
import { PageHeader } from '@/shared/ui/PageHeader'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/shared/ui/select'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import { TableToolbar } from '@/shared/ui/TableToolbar'
import { Textarea } from '@/shared/ui/textarea'
import { useServerTable } from '@/shared/ui/useServerTable'

type ActionKind = 'create' | 'edit' | 'rotate' | 'assign' | 'void' | 'allowance'

interface ActionForm {
  kind: ActionKind
  voucher: GiftDetail | null
  fromName: string
  toName: string
  recipientEmail: string
  message: string
  occasion: GiftOccasion | 'none'
  occasionGreeting: string
  duration: '1' | '3' | '12'
  expiresAt: string
  note: string
  reason: string
  userId: string
  addCount: string
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

function blankAction(kind: ActionKind, voucher: GiftDetail | null = null): ActionForm {
  return {
    kind,
    voucher,
    fromName: voucher?.from_name ?? '',
    toName: voucher?.to_name ?? '',
    recipientEmail: voucher?.recipient_email ?? '',
    message: voucher?.message ?? '',
    occasion: voucher?.occasion ?? 'none',
    occasionGreeting: voucher?.occasion_greeting ?? '',
    duration: String(voucher?.duration_months ?? 1) as '1' | '3' | '12',
    expiresAt: '',
    note: '',
    reason: '',
    userId: '',
    addCount: '1',
  }
}

function detailValue(value: string | null | undefined, fallback: string): string {
  return value || fallback
}

export function GiftsPage() {
  const { t } = useTranslation('gifts')
  const { can } = usePermission()
  const queryClient = useQueryClient()
  const canManage = can('gifts.write')
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [action, setAction] = useState<ActionForm | null>(null)

  const table = useServerTable<GiftItem>({
    queryKey: giftKeys.all,
    queryFn: listGifts,
    filterKeys: ['source', 'duration_months', 'status', 'created_from', 'created_to'],
  })
  const summary = useGiftSummaryQuery()
  const detail = useGiftDetailQuery(selectedId)

  const exportMutation = useMutation({
    mutationFn: () => exportGifts(table.tableState.params),
    onSuccess: (csv) => {
      downloadCsv(t('export.filename'), csv)
      toast.success(t('export.toast', { count: table.total }))
    },
    onError: () => toast.error(t('export.failed')),
  })

  const mutation = useMutation({
    mutationFn: async (form: ActionForm) => {
      const occasion = form.occasion === 'none' ? null : form.occasion
      const occasionGreeting = form.occasion === 'other' ? form.occasionGreeting.trim() || null : null
      if (form.kind === 'create') {
        return createGift({
          duration_months: Number(form.duration) as 1 | 3 | 12,
          from_name: form.fromName.trim(),
          to_name: form.toName.trim(),
          recipient_email: form.recipientEmail.trim(),
          message: form.message.trim() || null,
          occasion,
          occasion_greeting: occasionGreeting,
          note: form.note.trim(),
          ...(form.expiresAt ? { expires_at: new Date(form.expiresAt).toISOString() } : {}),
        })
      }
      if (form.kind === 'allowance') {
        return adjustGiftAllowance(form.userId.trim(), {
          duration_months: Number(form.duration) as 1 | 3 | 12,
          add_count: Number(form.addCount),
          reason: form.reason.trim(),
        })
      }
      if (!form.voucher) throw new Error('Missing voucher')
      if (form.kind === 'edit') {
        return editGift(form.voucher.id, {
          from_name: form.fromName.trim(),
          to_name: form.toName.trim(),
          message: form.message.trim() || null,
          occasion,
          occasion_greeting: occasionGreeting,
        })
      }
      if (form.kind === 'assign') {
        return assignGift(form.voucher.id, {
          user_id: form.userId.trim(),
          reason: form.reason.trim(),
        })
      }
      if (form.kind === 'rotate') {
        return rotateGift(form.voucher.id, { reason: form.reason.trim() })
      }
      return voidOrRevokeGift(form.voucher.id, { reason: form.reason.trim() })
    },
    onSuccess: (_result, form) => {
      const successKey: Record<ActionKind, string> = {
        create: 'toast.created',
        edit: 'toast.edited',
        rotate: 'toast.rotated',
        assign: 'toast.assigned',
        void: 'toast.voided',
        allowance: 'toast.allowance',
      }
      toast.success(t(successKey[form.kind]))
      setAction(null)
      void queryClient.invalidateQueries({ queryKey: giftKeys.all })
    },
    onError: () => toast.error(t('toast.failed')),
  })

  const columns: ColumnDef<GiftItem>[] = [
    {
      id: 'recipient',
      header: t('columns.recipient'),
      enableSorting: false,
      size: 210,
      minSize: 170,
      cell: ({ row }) => (
        <div className="min-w-0">
          <p className="truncate font-medium text-ink">{row.original.to_name}</p>
          <p className="truncate text-xs text-muted-foreground">{row.original.from_name}</p>
        </div>
      ),
    },
    {
      accessorKey: 'source',
      header: t('columns.source'),
      enableSorting: false,
      size: 140,
      cell: ({ row }) => t(`sources.${row.original.source}`, { defaultValue: row.original.source }),
    },
    {
      accessorKey: 'duration_months',
      header: t('columns.term'),
      enableSorting: false,
      size: 100,
      cell: ({ row }) => t(`terms.${row.original.duration_months}`),
    },
    {
      accessorKey: 'retail_value_cents',
      header: t('columns.value'),
      enableSorting: false,
      size: 110,
      cell: ({ row }) => (
        <span className="tabular-nums">{formatMoney(row.original.retail_value_cents / 100)}</span>
      ),
    },
    {
      accessorKey: 'status',
      header: t('columns.status'),
      enableSorting: false,
      size: 145,
      cell: ({ row }) => (
        <StatusBadge
          status={row.original.status}
          label={t(`statuses.${row.original.status}`, { defaultValue: row.original.status })}
        />
      ),
    },
    {
      accessorKey: 'payment_status',
      header: t('columns.payment'),
      enableSorting: false,
      size: 135,
      cell: ({ row }) => (
        <StatusBadge
          status={row.original.payment_status ?? 'not_applicable'}
          label={t(`statuses.${row.original.payment_status ?? 'not_applicable'}`)}
        />
      ),
    },
    {
      accessorKey: 'created_at',
      header: t('columns.created'),
      enableSorting: false,
      size: 170,
      cell: ({ row }) => (
        <span className="whitespace-nowrap text-sm text-muted-foreground">
          {formatDateTime(row.original.created_at)}
        </span>
      ),
    },
  ]

  const metrics = summary.data
  const metricValue = (value: number | string | undefined): number | string =>
    value === undefined ? '—' : value

  const actionValid = action ? isActionValid(action) : false

  return (
    <div className="space-y-6">
      <PageHeader
        title={t('title')}
        description={t('description')}
        actions={
          canManage ? (
            <>
              <Button variant="outline" onClick={() => setAction(blankAction('allowance'))}>
                <UserPlus aria-hidden="true" />
                {t('actions.adjustAllowance')}
              </Button>
              <Button onClick={() => setAction(blankAction('create'))}>
                <Plus aria-hidden="true" />
                {t('actions.manualIssue')}
              </Button>
            </>
          ) : undefined
        }
      />

      <section className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4" aria-label={t('title')}>
        <MetricCard label={t('metrics.totalIssued')} value={metricValue(metrics?.total_issued)} />
        <MetricCard
          label={t('metrics.paidRevenue')}
          value={metrics ? formatMoney(metrics.paid_revenue_cents / 100) : '—'}
        />
        <MetricCard label={t('metrics.complimentary')} value={metricValue(metrics?.complimentary_count)} />
        <MetricCard label={t('metrics.claimed')} value={metricValue(metrics?.claimed_count)} />
        <MetricCard
          label={t('metrics.redemptionRate')}
          value={metrics ? `${metrics.redemption_rate.toFixed(1)}%` : '—'}
        />
        <MetricCard label={t('metrics.queuedMonths')} value={metricValue(metrics?.queued_months)} />
        <MetricCard label={t('metrics.expired')} value={metricValue(metrics?.expired_count)} />
        <MetricCard label={t('metrics.expiringSoon')} value={metricValue(metrics?.expiring_30_days)} />
      </section>

      <TableToolbar
        searchValue={table.tableState.q}
        onSearchChange={table.tableState.setQ}
        searchPlaceholder={t('filters.search')}
        primaryFilter={{
          key: 'status',
          label: t('filters.status'),
          placeholder: t('filters.allStatuses'),
          options: [
            { value: 'all', label: t('filters.allStatuses') },
            ...GIFT_STATUSES.map((status) => ({ value: status, label: t(`statuses.${status}`) })),
          ],
          value: table.tableState.filters.status,
          onValueChange: (value) =>
            table.tableState.setFilter('status', value && value !== 'all' ? value : undefined),
        }}
        filters={[
          {
            key: 'source',
            label: t('filters.source'),
            placeholder: t('filters.allSources'),
            options: [
              { value: 'all', label: t('filters.allSources') },
              ...GIFT_SOURCES.map((source) => ({ value: source, label: t(`sources.${source}`) })),
            ],
            value: table.tableState.filters.source,
            onValueChange: (value) =>
              table.tableState.setFilter('source', value && value !== 'all' ? value : undefined),
          },
          {
            key: 'duration_months',
            label: t('filters.term'),
            placeholder: t('filters.allTerms'),
            options: [
              { value: 'all', label: t('filters.allTerms') },
              ...GIFT_DURATIONS.map((duration) => ({ value: String(duration), label: t(`terms.${duration}`) })),
            ],
            value: table.tableState.filters.duration_months,
            onValueChange: (value) =>
              table.tableState.setFilter('duration_months', value && value !== 'all' ? value : undefined),
          },
        ]}
        dateFilters={[
          {
            key: 'created_from',
            label: t('filters.createdFrom'),
            value: table.tableState.filters.created_from,
            onValueChange: (value) => table.tableState.setFilter('created_from', value),
          },
          {
            key: 'created_to',
            label: t('filters.createdTo'),
            value: table.tableState.filters.created_to,
            onValueChange: (value) => table.tableState.setFilter('created_to', value),
          },
        ]}
        isFetching={table.props.isFetching}
        onReset={table.tableState.reset}
        actions={
          <Button
            variant="outline"
            size="sm"
            onClick={() => exportMutation.mutate()}
            disabled={table.total === 0 || exportMutation.isPending}
            loading={exportMutation.isPending}
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
          onRetry={() => void table.query.refetch()}
        />
      ) : (
        <DataTable<GiftItem>
          {...table.props}
          columns={columns}
          ariaLabel={t('title')}
          getRowId={(row) => row.id}
          onRowClick={(row) => setSelectedId(row.id)}
          onResetFilters={() => table.tableState.reset()}
          emptyState={<EmptyState icon={Gift} title={t('empty.title')} message={t('empty.message')} />}
        />
      )}

      <GiftDetailDialog
        detail={detail.data ?? null}
        open={Boolean(selectedId)}
        loading={detail.isPending}
        canManage={canManage}
        onOpenChange={(open) => {
          if (!open) setSelectedId(null)
        }}
        onAction={(kind, voucher) => setAction(blankAction(kind, voucher))}
      />

      <ActionDialog
        action={action}
        setAction={setAction}
        valid={actionValid}
        loading={mutation.isPending}
        onSubmit={() => {
          if (action && actionValid) mutation.mutate(action)
        }}
      />
    </div>
  )
}

function isActionValid(form: ActionForm): boolean {
  const occasionValid =
    form.occasion !== 'other' || (form.occasionGreeting.trim().length >= 1 && form.occasionGreeting.trim().length <= 80)
  if (form.kind === 'create') {
    return (
      form.fromName.trim().length >= 1 &&
      form.fromName.trim().length <= 80 &&
      form.toName.trim().length >= 1 &&
      form.toName.trim().length <= 80 &&
      EMAIL_PATTERN.test(form.recipientEmail.trim()) &&
      form.message.trim().length <= 240 &&
      occasionValid &&
      form.note.trim().length >= 3 &&
      form.note.trim().length <= 500 &&
      (!form.expiresAt || new Date(form.expiresAt).getTime() > Date.now())
    )
  }
  if (form.kind === 'edit') {
    return (
      form.fromName.trim().length >= 1 &&
      form.fromName.trim().length <= 80 &&
      form.toName.trim().length >= 1 &&
      form.toName.trim().length <= 80 &&
      form.message.trim().length <= 240 &&
      occasionValid
    )
  }
  if (form.kind === 'allowance') {
    return UUID_PATTERN.test(form.userId.trim()) && Number(form.addCount) >= 1 && form.reason.trim().length >= 3 && form.reason.trim().length <= 500
  }
  if (form.kind === 'assign') {
    return UUID_PATTERN.test(form.userId.trim()) && form.reason.trim().length >= 3 && form.reason.trim().length <= 500
  }
  return form.reason.trim().length >= 3 && form.reason.trim().length <= 500
}

function GiftDetailDialog({
  detail,
  open,
  loading,
  canManage,
  onOpenChange,
  onAction,
}: {
  detail: GiftDetail | null
  open: boolean
  loading: boolean
  canManage: boolean
  onOpenChange: (open: boolean) => void
  onAction: (kind: ActionKind, voucher: GiftDetail) => void
}) {
  const { t } = useTranslation('gifts')
  const fallback = t('detail.notAvailable')
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl">
        <DialogHeader>
          <DialogTitle>{t('detail.title')}</DialogTitle>
          <DialogDescription>{t('detail.description')}</DialogDescription>
        </DialogHeader>
        {loading || !detail ? (
          <div className="h-64 animate-pulse rounded-lg bg-surface-card" />
        ) : (
          <div className="grid gap-6 lg:grid-cols-[minmax(260px,0.72fr)_minmax(0,1fr)]">
            <div>
              <p className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">{t('detail.artwork')}</p>
              {detail.og_image_url ? (
                <img
                  src={detail.og_image_url}
                  alt={t('detail.artwork')}
                  width={1200}
                  height={630}
                  loading="lazy"
                  className="aspect-[1200/630] w-full rounded-lg border border-border object-cover"
                />
              ) : (
                <div className="grid aspect-[1200/630] place-items-center rounded-lg border border-dashed border-border">
                  <Gift className="size-8 text-muted-foreground" aria-hidden="true" />
                </div>
              )}
              <div className="mt-4 flex flex-wrap gap-2">
                <StatusBadge status={detail.status} label={t(`statuses.${detail.status}`)} />
                <StatusBadge status={detail.payment_status ?? 'not_applicable'} label={t(`statuses.${detail.payment_status ?? 'not_applicable'}`)} />
                {detail.entitlement_status ? (
                  <StatusBadge status={detail.entitlement_status} label={t(`statuses.${detail.entitlement_status}`)} />
                ) : null}
              </div>
            </div>

            <dl className="grid content-start gap-x-5 gap-y-4 sm:grid-cols-2">
              <DetailField label={t('detail.from')} value={detail.from_name} />
              <DetailField label={t('detail.to')} value={detail.to_name} />
              <DetailField label={t('detail.recipientEmail')} value={detailValue(detail.recipient_email, fallback)} wide />
              <DetailField label={t('detail.occasion')} value={detail.occasion ? t(`occasions.${detail.occasion}`) : t('occasions.none')} />
              <DetailField label={t('detail.occasionGreeting')} value={detailValue(detail.occasion_greeting, fallback)} />
              <DetailField label={t('detail.message')} value={detailValue(detail.message, fallback)} wide />
              <DetailField label={t('detail.publicId')} value={detail.public_id} mono />
              <DetailField label={t('detail.claimCode')} value={detailValue(detail.claim_code, fallback)} mono />
              <DetailField label={t('detail.ownerId')} value={detailValue(detail.purchaser_user_id, fallback)} mono />
              <DetailField label={t('detail.claimantId')} value={detailValue(detail.claimed_by_user_id, fallback)} mono />
              <DetailField label={t('detail.checkoutId')} value={detailValue(detail.stripe_checkout_session_id, fallback)} mono />
              <DetailField label={t('detail.paymentIntent')} value={detailValue(detail.stripe_payment_intent_id, fallback)} mono />
              <DetailField
                label={t('detail.amountPaid')}
                value={detail.amount_paid_cents === null ? fallback : formatMoney(detail.amount_paid_cents / 100)}
              />
              <DetailField
                label={t('detail.amountRefunded')}
                value={formatMoney(detail.amount_refunded_cents / 100)}
              />
              <DetailField label={t('detail.issuedAt')} value={formatDateTime(detail.issued_at)} />
              <DetailField label={t('detail.claimedAt')} value={formatDateTime(detail.claimed_at)} />
              <DetailField label={t('detail.expiresAt')} value={formatDateTime(detail.expires_at)} />
              <DetailField
                label={t('detail.entitlement')}
                value={detail.entitlement_status ? t(`statuses.${detail.entitlement_status}`) : fallback}
              />
            </dl>
          </div>
        )}

        {detail && canManage ? (
          <DialogFooter className="flex-wrap sm:justify-start">
            {detail.status === 'issued' ? (
              <>
                <Button variant="outline" onClick={() => onAction('edit', detail)}><Edit3 aria-hidden="true" />{t('actions.edit')}</Button>
                <Button variant="outline" onClick={() => onAction('rotate', detail)}><Link2 aria-hidden="true" />{t('actions.rotate')}</Button>
                <Button variant="outline" onClick={() => onAction('assign', detail)}><UserPlus aria-hidden="true" />{t('actions.assign')}</Button>
              </>
            ) : null}
            {detail.source !== 'paid' && ['issued', 'claimed'].includes(detail.status) ? (
              <Button variant="destructive" onClick={() => onAction('void', detail)}>
                <ShieldAlert aria-hidden="true" />
                {t(detail.status === 'claimed' ? 'actions.revoke' : 'actions.void')}
              </Button>
            ) : null}
          </DialogFooter>
        ) : null}
      </DialogContent>
    </Dialog>
  )
}

function DetailField({ label, value, mono = false, wide = false }: { label: string; value: string; mono?: boolean; wide?: boolean }) {
  return (
    <div className={wide ? 'sm:col-span-2' : undefined}>
      <dt className="text-xs font-medium uppercase tracking-wide text-muted-foreground">{label}</dt>
      <dd className={mono ? 'mt-1 break-all font-mono text-xs text-ink' : 'mt-1 text-sm text-ink'}>{value}</dd>
    </div>
  )
}

function ActionDialog({
  action,
  setAction,
  valid,
  loading,
  onSubmit,
}: {
  action: ActionForm | null
  setAction: React.Dispatch<React.SetStateAction<ActionForm | null>>
  valid: boolean
  loading: boolean
  onSubmit: () => void
}) {
  const { t } = useTranslation('gifts')
  if (!action) return null
  const titleKey: Record<ActionKind, string> = {
    create: 'create.title',
    edit: 'edit.title',
    rotate: 'rotate.title',
    assign: 'assign.title',
    void: 'void.title',
    allowance: 'allowance.title',
  }
  const descriptionKey: Record<ActionKind, string> = {
    create: 'create.description',
    edit: 'edit.description',
    rotate: 'rotate.description',
    assign: 'assign.description',
    void: 'void.description',
    allowance: 'allowance.description',
  }
  const submitKey: Record<ActionKind, string> = {
    create: 'create.submit',
    edit: 'edit.submit',
    rotate: 'rotate.confirm',
    assign: 'assign.submit',
    void: 'void.confirm',
    allowance: 'allowance.submit',
  }
  const update = (field: keyof ActionForm, value: string): void =>
    setAction((current) => (current ? { ...current, [field]: value } : null))

  return (
    <Dialog open onOpenChange={(open) => { if (!open && !loading) setAction(null) }}>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>{t(titleKey[action.kind])}</DialogTitle>
          <DialogDescription>{t(descriptionKey[action.kind])}</DialogDescription>
        </DialogHeader>
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            if (valid) onSubmit()
          }}
        >
          {action.kind === 'create' || action.kind === 'edit' ? (
            <>
              <div className="grid gap-4 sm:grid-cols-2">
                <Field label={t('forms.fromName')} htmlFor="gift-admin-from">
                  <Input id="gift-admin-from" value={action.fromName} maxLength={80} onChange={(event) => update('fromName', event.target.value)} />
                </Field>
                <Field label={t('forms.toName')} htmlFor="gift-admin-to">
                  <Input id="gift-admin-to" value={action.toName} maxLength={80} onChange={(event) => update('toName', event.target.value)} />
                </Field>
              </div>
              {action.kind === 'create' ? (
                <Field label={t('forms.recipientEmail')} htmlFor="gift-admin-recipient-email">
                  <Input
                    id="gift-admin-recipient-email"
                    type="email"
                    value={action.recipientEmail}
                    maxLength={320}
                    onChange={(event) => update('recipientEmail', event.target.value)}
                  />
                </Field>
              ) : null}
              <Field label={t('forms.occasion')} htmlFor="gift-admin-occasion">
                <Select
                  value={action.occasion}
                  onValueChange={(value) => {
                    const occasion = value as GiftOccasion | 'none'
                    setAction((current) => current ? {
                      ...current,
                      occasion,
                      occasionGreeting: occasion === 'other' ? current.occasionGreeting : '',
                    } : null)
                  }}
                >
                  <SelectTrigger id="gift-admin-occasion"><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">{t('occasions.none')}</SelectItem>
                    {GIFT_OCCASIONS.map((occasion) => (
                      <SelectItem key={occasion} value={occasion}>{t(`occasions.${occasion}`)}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </Field>
              {action.occasion === 'other' ? (
                <Field label={t('forms.occasionGreeting')} htmlFor="gift-admin-occasion-greeting">
                  <Input
                    id="gift-admin-occasion-greeting"
                    value={action.occasionGreeting}
                    maxLength={80}
                    onChange={(event) => update('occasionGreeting', event.target.value)}
                  />
                </Field>
              ) : null}
              <Field label={t('forms.message')} htmlFor="gift-admin-message">
                <Textarea id="gift-admin-message" value={action.message} maxLength={240} onChange={(event) => update('message', event.target.value)} />
              </Field>
            </>
          ) : null}

          {action.kind === 'create' || action.kind === 'allowance' ? (
            <Field label={t('forms.duration')} htmlFor="gift-admin-duration">
              <Select value={action.duration} onValueChange={(value) => update('duration', value)}>
                <SelectTrigger id="gift-admin-duration"><SelectValue /></SelectTrigger>
                <SelectContent>
                  {GIFT_DURATIONS.map((duration) => <SelectItem key={duration} value={String(duration)}>{t(`terms.${duration}`)}</SelectItem>)}
                </SelectContent>
              </Select>
            </Field>
          ) : null}

          {action.kind === 'create' ? (
            <>
              <Field label={t('forms.expiresAt')} htmlFor="gift-admin-expiry">
                <Input id="gift-admin-expiry" type="datetime-local" value={action.expiresAt} onChange={(event) => update('expiresAt', event.target.value)} />
              </Field>
              <Field label={t('forms.note')} htmlFor="gift-admin-note">
                <Textarea id="gift-admin-note" value={action.note} maxLength={500} onChange={(event) => update('note', event.target.value)} />
              </Field>
            </>
          ) : null}

          {action.kind === 'assign' || action.kind === 'allowance' ? (
            <Field label={t(action.kind === 'assign' ? 'forms.recipientUserId' : 'forms.userId')} htmlFor="gift-admin-user">
              <Input id="gift-admin-user" value={action.userId} onChange={(event) => update('userId', event.target.value)} autoComplete="off" />
            </Field>
          ) : null}

          {action.kind === 'allowance' ? (
            <Field label={t('forms.addCount')} htmlFor="gift-admin-count">
              <Input id="gift-admin-count" type="number" min={1} max={100} value={action.addCount} onChange={(event) => update('addCount', event.target.value)} />
            </Field>
          ) : null}

          {['rotate', 'assign', 'void', 'allowance'].includes(action.kind) ? (
            <Field label={t('forms.reason')} htmlFor="gift-admin-reason">
              <Textarea id="gift-admin-reason" value={action.reason} maxLength={500} onChange={(event) => update('reason', event.target.value)} />
            </Field>
          ) : null}

          <DialogFooter>
            <Button type="button" variant="secondary" disabled={loading} onClick={() => setAction(null)}>{t('actions.close')}</Button>
            <Button type="submit" variant={action.kind === 'void' ? 'destructive' : 'primary'} loading={loading} disabled={!valid}>
              {t(submitKey[action.kind])}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

function Field({ label, htmlFor, children }: { label: string; htmlFor: string; children: React.ReactNode }) {
  return (
    <div className="space-y-2">
      <Label htmlFor={htmlFor}>{label}</Label>
      {children}
    </div>
  )
}
