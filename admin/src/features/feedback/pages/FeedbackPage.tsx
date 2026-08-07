import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { Download, MessageSquare } from 'lucide-react'
import { useEffect, useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router-dom'
import { toast } from 'sonner'
import { z } from 'zod'

import {
  FEEDBACK_STATUSES,
  feedbackKeys,
  listFeedback,
  updateFeedback,
  type AdminFeedbackListItem,
  type AdminFeedbackUpdate,
  type FeedbackStatus,
} from '@/features/feedback/api/feedback'
import { useCsvExport } from '@/shared/hooks/useCsvExport'
import { usePermission } from '@/shared/hooks/usePermission'
import { formatDateTime, toDate } from '@/shared/lib/formatters'
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
import { PageHeader } from '@/shared/ui/PageHeader'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/shared/ui/select'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import { TableToolbar } from '@/shared/ui/TableToolbar'
import { Textarea } from '@/shared/ui/textarea'
import { useServerTable } from '@/shared/ui/useServerTable'

const CATEGORIES = ['bug_report', 'feature_request', 'general_feedback', 'support_request'] as const

/** Pull a scalar string out of the joined `user` dict defensively. */
function userEmail(user: { [key: string]: unknown } | null | undefined): string | undefined {
  if (!user || typeof user !== 'object') return undefined
  const email = user['email']
  return typeof email === 'string' && email.length > 0 ? email : undefined
}

function stringList(value: unknown): string[] {
  if (!Array.isArray(value)) return []
  return value.filter((entry): entry is string => typeof entry === 'string')
}

export function FeedbackPage() {
  const { t } = useTranslation('feedback')
  const { can } = usePermission()
  const queryClient = useQueryClient()
  const canWrite = can('feedback.write')
  const [selected, setSelected] = useState<AdminFeedbackListItem | null>(null)

  const table = useServerTable<AdminFeedbackListItem>({
    queryKey: feedbackKeys.all,
    queryFn: listFeedback,
    filterKeys: ['status', 'category'],
  })

  const csvExport = useCsvExport<AdminFeedbackListItem>({
    rows: table.data,
    filename: t('export.filename'),
    toastMessage: t('export.toast', { count: table.data.length }),
    columns: [
      { label: t('columns.subject'), value: (row) => row.subject ?? '' },
      {
        label: t('columns.user'),
        value: (row) => userEmail(row.user) ?? row.contact_email ?? row.user_id ?? '',
      },
      { label: t('columns.category'), value: (row) => row.category ?? '' },
      { label: t('columns.status'), value: (row) => row.status ?? '' },
      {
        label: t('columns.createdAt'),
        value: (row) => toDate(row.created_at)?.toISOString() ?? '',
      },
    ],
  })

  const updateSchema = z.object({
    status: z.enum(FEEDBACK_STATUSES, { message: t('status.unknown') }),
    internal_notes: z.string().max(4000, t('detail.errorGeneric')),
  })
  type UpdateFormValues = z.infer<typeof updateSchema>

  const form = useForm<UpdateFormValues>({
    resolver: zodResolver(updateSchema),
    defaultValues: { status: 'open', internal_notes: '' },
  })

  // Re-seed the dialog form whenever a new ticket is opened.
  useEffect(() => {
    if (!selected) return
    form.reset({
      status: (selected.status as FeedbackStatus) ?? 'open',
      internal_notes: selected.internal_notes ?? '',
    })
  }, [selected, form])

  const updateMutation = useMutation({
    mutationFn: ({ ticketId, body }: { ticketId: string; body: AdminFeedbackUpdate }) =>
      updateFeedback(ticketId, body),
    onSuccess: () => {
      toast.success(t('detail.saved'))
      setSelected(null)
      void queryClient.invalidateQueries({ queryKey: feedbackKeys.all })
    },
    onError: () => {
      toast.error(t('detail.errorGeneric'))
    },
  })

  const handleSave = (values: UpdateFormValues): void => {
    if (!selected) return
    const body: AdminFeedbackUpdate = {}
    if (values.status !== selected.status) body.status = values.status
    if (values.internal_notes !== (selected.internal_notes ?? '')) {
      body.internal_notes = values.internal_notes || null
    }
    updateMutation.mutate({ ticketId: selected.id, body })
  }

  const columns: ColumnDef<AdminFeedbackListItem>[] = [
    {
      id: 'subject',
      header: t('columns.subject'),
      cell: ({ row }) => (
        <div className="flex min-w-0 flex-col">
          <span className="truncate font-medium">{row.original.subject ?? '—'}</span>
          <span className="truncate text-xs text-muted-foreground">
            {row.original.description ?? ''}
          </span>
        </div>
      ),
    },
    {
      id: 'user',
      header: t('columns.user'),
      enableSorting: false,
      cell: ({ row }) => {
        const email = userEmail(row.original.user)
        return row.original.user_id ? (
          <Link
            to={`/users/${row.original.user_id}`}
            className="truncate font-medium text-foreground underline-offset-4 hover:text-primary hover:underline"
          >
            {email ?? row.original.contact_email ?? row.original.user_id}
          </Link>
        ) : (
          <span className="text-sm text-muted-foreground">
            {row.original.contact_email ?? '—'}
          </span>
        )
      },
    },
    {
      id: 'category',
      header: t('columns.category'),
      enableSorting: false,
      cell: ({ row }) => {
        const category = row.original.category ?? 'unknown'
        return (
          <span className="rounded-full bg-surface-card px-2.5 py-0.5 text-xs font-medium">
            {t(`categories.${category}`, { defaultValue: category })}
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
      id: 'created_at',
      header: t('columns.createdAt'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="whitespace-nowrap text-sm text-muted-foreground">
          {formatDateTime(row.original.created_at as string | null | undefined)}
        </span>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader title={t('title')} description={t('description')} />

      <TableToolbar
        searchValue={table.tableState.q}
        onSearchChange={table.tableState.setQ}
        primaryFilter={{
          key: 'status',
          label: t('filters.status'),
          placeholder: t('filters.statusPlaceholder'),
          options: [
            { value: 'all', label: t('filters.statusPlaceholder') },
            ...FEEDBACK_STATUSES.map((status) => ({
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
            key: 'category',
            label: t('filters.category'),
            placeholder: t('filters.categoryPlaceholder'),
            options: [
              { value: 'all', label: t('filters.categoryPlaceholder') },
              ...CATEGORIES.map((category) => ({
                value: category,
                label: t(`categories.${category}`, { defaultValue: category }),
              })),
            ],
            value: table.tableState.filters.category,
            onValueChange: (value) =>
              table.tableState.setFilter('category', value && value !== 'all' ? value : undefined),
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
        <DataTable<AdminFeedbackListItem>
          {...table.props}
          columns={columns}
          ariaLabel={t('title')}
          getRowId={(row) => row.id}
          onRowClick={setSelected}
          onResetFilters={() => table.tableState.reset()}
          emptyState={
            <EmptyState
              icon={MessageSquare}
              title={t('empty.title')}
              message={t('empty.message')}
            />
          }
        />
      )}

      {/* Ticket detail dialog */}
      <Dialog open={selected !== null} onOpenChange={(open) => !open && setSelected(null)}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>{selected?.subject ?? t('detail.title')}</DialogTitle>
            <DialogDescription>
              {selected?.user_id
                ? userEmail(selected.user) ?? selected.user_id
                : selected?.contact_email ?? ''}
            </DialogDescription>
          </DialogHeader>

          {selected ? (
            <div className="space-y-4 text-sm">
              <div className="rounded-md border border-border p-3">
                <p className="whitespace-pre-wrap text-foreground">
                  {selected.description || '—'}
                </p>
              </div>

              <dl className="grid grid-cols-1 gap-x-6 gap-y-2 sm:grid-cols-2">
                <div className="flex items-baseline justify-between gap-3">
                  <dt className="shrink-0 text-muted-foreground">{t('detail.statusLabel')}</dt>
                  <dd>
                    <StatusBadge
                      status={selected.status ?? 'unknown'}
                      label={t(`status.${selected.status ?? 'unknown'}`, {
                        defaultValue: selected.status ?? 'unknown',
                      })}
                    />
                  </dd>
                </div>
                <div className="flex items-baseline justify-between gap-3">
                  <dt className="shrink-0 text-muted-foreground">{t('detail.appPlatform')}</dt>
                  <dd>{selected.app_platform ?? '—'}</dd>
                </div>
                <div className="flex items-baseline justify-between gap-3">
                  <dt className="shrink-0 text-muted-foreground">{t('detail.appVersion')}</dt>
                  <dd>{selected.app_version ?? '—'}</dd>
                </div>
                <div className="flex items-baseline justify-between gap-3">
                  <dt className="shrink-0 text-muted-foreground">{t('detail.createdAt')}</dt>
                  <dd>{formatDateTime(selected.created_at as string | null | undefined)}</dd>
                </div>
                <div className="flex items-baseline justify-between gap-3">
                  <dt className="shrink-0 text-muted-foreground">{t('detail.updatedAt')}</dt>
                  <dd>{formatDateTime(selected.updated_at as string | null | undefined)}</dd>
                </div>
              </dl>

              <AttachmentsRow item={selected} />

              {canWrite ? (
                <Form {...form}>
                  <form onSubmit={form.handleSubmit(handleSave)} className="space-y-4 border-t border-border pt-4">
                    <FormField
                      control={form.control}
                      name="status"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>{t('detail.statusLabel')}</FormLabel>
                          <Select value={field.value} onValueChange={field.onChange}>
                            <FormControl>
                              <SelectTrigger className="w-48">
                                <SelectValue />
                              </SelectTrigger>
                            </FormControl>
                            <SelectContent>
                              {FEEDBACK_STATUSES.map((status) => (
                                <SelectItem key={status} value={status}>
                                  {t(`status.${status}`, { defaultValue: status })}
                                </SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                    <FormField
                      control={form.control}
                      name="internal_notes"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>{t('detail.internalNotes')}</FormLabel>
                          <FormControl>
                            <Textarea
                              rows={3}
                              placeholder={t('detail.internalNotesPlaceholder')}
                              {...field}
                            />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                    <DialogFooter>
                      <Button
                        type="submit"
                        loading={updateMutation.isPending}
                        disabled={!form.formState.isDirty}
                      >
                        {t('detail.save')}
                      </Button>
                    </DialogFooter>
                  </form>
                </Form>
              ) : null}
            </div>
          ) : null}
        </DialogContent>
      </Dialog>
    </div>
  )
}

/** Attachments: display URLs (attachment_urls) + durable storage paths (migration 034). */
function AttachmentsRow({ item }: { item: AdminFeedbackListItem }) {
  const { t } = useTranslation('feedback')
  const displayUrls = stringList(item['attachment_urls'])
  const storagePaths = stringList(item['attachment_storage_paths'])
  if (displayUrls.length === 0 && storagePaths.length === 0) {
    return <p className="text-sm text-muted-foreground">{t('detail.noAttachments')}</p>
  }
  return (
    <div className="space-y-2 border-t border-border pt-4">
      <h4 className="text-sm font-semibold">{t('detail.attachments')}</h4>
      {displayUrls.length > 0 ? (
        <ul className="space-y-1">
          {displayUrls.map((url) => (
            <li key={url}>
              <a
                href={url}
                target="_blank"
                rel="noopener noreferrer"
                className="break-all text-sm text-primary underline-offset-4 hover:underline"
              >
                {url}
              </a>
            </li>
          ))}
        </ul>
      ) : null}
      {storagePaths.length > 0 ? (
        <div>
          <p className="text-xs font-medium text-muted-foreground">{t('detail.storagePaths')}</p>
          <ul className="mt-1 space-y-0.5">
            {storagePaths.map((path) => (
              <li key={path} className="break-all font-mono text-xs text-muted-foreground">
                {path}
              </li>
            ))}
          </ul>
        </div>
      ) : null}
    </div>
  )
}
