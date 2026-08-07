import type { ColumnDef } from '@tanstack/react-table'
import { Download, Eye } from 'lucide-react'
import { useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { auditKeys, listAudit } from '@/features/audit/api/audit'
import { normalizeError } from '@/shared/api/errors'
import type { AdminAuditEventItem } from '@/shared/api/schemaTypes'
import { usePermission } from '@/shared/hooks/usePermission'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { downloadCsv, buildCsv } from '@/shared/lib/csv'
import { formatDateTimeValue, toDate } from '@/shared/lib/formatters'
import { pickString } from '@/shared/lib/json'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
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
import { TableToolbar } from '@/shared/ui/TableToolbar'
import { useServerTable } from '@/shared/ui/useServerTable'

/** Value for "no filter" in a Radix Select (empty strings are reserved). */
const ALL_VALUE = '__all__'

/** Actor email from the joined `actor` dict, falling back to actor_id. */
export function auditActorEmail(row: AdminAuditEventItem): string | null {
  return pickString(row.actor, 'email') ?? row.actor_id ?? null
}

/** Distinct option lists derived from the current page (server-driven selects). */
function distinctOptions(
  rows: AdminAuditEventItem[],
  extract: (row: AdminAuditEventItem) => string | null,
): { value: string; label: string }[] {
  const seen = new Map<string, string>()
  for (const row of rows) {
    const value = extract(row)
    if (value && !seen.has(value)) seen.set(value, value)
  }
  return [...seen.keys()].map((value) => ({ value, label: value }))
}

export function AuditPage() {
  const { t } = useTranslation('audit')
  const { can } = usePermission()
  const [selectedEvent, setSelectedEvent] = useState<AdminAuditEventItem | null>(null)

  const table = useServerTable<AdminAuditEventItem>({
    queryKey: auditKeys.all,
    queryFn: (params: TableStateParams) => listAudit(params),
    filterKeys: ['actor_id', 'action', 'entity_type', 'from', 'to'],
  })

  // The backend has no free-text q param — q filters the current page
  // client-side (actor email / action / entity / ip).
  const q = table.tableState.q.trim().toLowerCase()
  const data = useMemo(() => {
    if (!q) return table.data
    return table.data.filter((row) => {
      const haystack = [
        auditActorEmail(row),
        row.action,
        row.entity_type,
        row.entity_id ?? '',
        row.ip ?? '',
      ]
        .filter(Boolean)
        .join(' ')
        .toLowerCase()
      return haystack.includes(q)
    })
  }, [table.data, q])

  const actorOptions = useMemo(
    () => distinctOptions(table.data, auditActorEmail),
    [table.data],
  )
  const actionOptions = useMemo(
    () => distinctOptions(table.data, (row) => row.action),
    [table.data],
  )
  const entityTypeOptions = useMemo(
    () => distinctOptions(table.data, (row) => row.entity_type),
    [table.data],
  )

  const columns = useMemo<ColumnDef<AdminAuditEventItem>[]>(
    () => [
      {
        accessorKey: 'created_at',
        header: t('columns.createdAt'),
        // Backend /admin/audit exposes no sort_by param (sort_dir only) —
        // no column is server-sortable.
        enableSorting: false,
        cell: ({ row }) => (
          <span className="whitespace-nowrap text-muted-foreground">
            {formatDateTimeValue(row.original.created_at)}
          </span>
        ),
      },
      {
        accessorKey: 'actor',
        header: t('columns.actor'),
        enableSorting: false,
        cell: ({ row }) => auditActorEmail(row.original) ?? '—',
      },
      {
        accessorKey: 'action',
        header: t('columns.action'),
        enableSorting: false,
        cell: ({ row }) => <Badge variant="default">{row.original.action}</Badge>,
      },
      {
        accessorKey: 'entity_type',
        header: t('columns.entityType'),
        enableSorting: false,
        cell: ({ row }) => row.original.entity_type,
      },
      {
        accessorKey: 'entity_id',
        header: t('columns.entityId'),
        enableSorting: false,
        cell: ({ row }) => row.original.entity_id ?? '—',
      },
      {
        accessorKey: 'ip',
        header: t('columns.ip'),
        enableSorting: false,
        cell: ({ row }) => row.original.ip ?? '—',
      },
      {
        id: 'payload',
        header: '',
        cell: ({ row }) => (
          <Button
            variant="ghost"
            size="sm"
            onClick={(event) => {
              event.stopPropagation()
              setSelectedEvent(row.original)
            }}
          >
            <Eye aria-hidden="true" />
            {t('actions.view')}
          </Button>
        ),
        enableSorting: false,
      },
    ],
    [t],
  )

  function exportCsv(): void {
    const rows = data
    if (rows.length === 0) return
    const csv = buildCsv(rows, [
      {
        label: t('columns.createdAt'),
        value: (row) => toDate(row.created_at)?.toISOString() ?? '',
      },
      { label: t('columns.actor'), value: (row) => auditActorEmail(row) ?? '' },
      { label: t('columns.action'), value: (row) => row.action },
      { label: t('columns.entityType'), value: (row) => row.entity_type },
      { label: t('columns.entityId'), value: (row) => row.entity_id ?? '' },
      { label: t('columns.ip'), value: (row) => row.ip ?? '' },
      { label: t('payload.userAgent'), value: (row) => row.user_agent ?? '' },
      {
        label: t('payload.payload'),
        value: (row) => JSON.stringify(row.payload ?? {}),
      },
    ])
    downloadCsv(t('export.filename'), csv)
    toast.success(t('export.toast', { count: rows.length }))
  }

  if (!can('audit.read')) {
    return (
      <div className="space-y-6">
        <PageHeader title={t('title')} description={t('description')} />
        <EmptyState
          title={t('errors:forbidden.title')}
          message={t('errors:forbidden.message')}
        />
      </div>
    )
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

  const fromValue = table.tableState.filters.from
  const toValue = table.tableState.filters.to

  return (
    <div className="space-y-6">
      <PageHeader title={t('title')} description={t('description')} />

      <TableToolbar
        searchValue={table.tableState.q}
        onSearchChange={table.tableState.setQ}
        searchPlaceholder={t('searchPlaceholder')}
        primaryFilter={{
          key: 'action',
          label: t('filters.action'),
          placeholder: t('filters.actionAll'),
          options: [{ value: ALL_VALUE, label: t('filters.actionAll') }, ...actionOptions],
          value: table.tableState.filters.action,
          onValueChange: (value) =>
            table.tableState.setFilter('action', value === ALL_VALUE ? undefined : value),
        }}
        filters={[
          {
            key: 'actor_id',
            label: t('filters.actor'),
            placeholder: t('filters.actorAll'),
            options: [{ value: ALL_VALUE, label: t('filters.actorAll') }, ...actorOptions],
            value: table.tableState.filters.actor_id,
            onValueChange: (value) =>
              table.tableState.setFilter('actor_id', value === ALL_VALUE ? undefined : value),
          },
          {
            key: 'entity_type',
            label: t('filters.entityType'),
            placeholder: t('filters.entityTypeAll'),
            options: [
              { value: ALL_VALUE, label: t('filters.entityTypeAll') },
              ...entityTypeOptions,
            ],
            value: table.tableState.filters.entity_type,
            onValueChange: (value) =>
              table.tableState.setFilter('entity_type', value === ALL_VALUE ? undefined : value),
          },
        ]}
        dateFilters={[
          {
            key: 'from',
            label: t('filters.from'),
            value: fromValue,
            onValueChange: (value) => table.tableState.setFilter('from', value),
          },
          {
            key: 'to',
            label: t('filters.to'),
            value: toValue,
            onValueChange: (value) => table.tableState.setFilter('to', value),
          },
        ]}
        isFetching={table.query.isFetching}
        onReset={table.tableState.reset}
        actions={
          <Button variant="outline" size="sm" onClick={exportCsv} disabled={data.length === 0}>
            <Download aria-hidden="true" />
            {t('export.label')}
          </Button>
        }
      />

      {q ? <p className="text-xs text-muted-foreground">{t('searchHint')}</p> : null}

      <DataTable
        columns={columns}
        getRowId={(row) => row.id}
        ariaLabel={t('title')}
        {...table.props}
        data={data}
      />

      <Dialog
        open={selectedEvent !== null}
        onOpenChange={(open) => {
          if (!open) setSelectedEvent(null)
        }}
      >
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>{t('payload.title')}</DialogTitle>
            <DialogDescription>
              {selectedEvent
                ? `${selectedEvent.action} · ${selectedEvent.entity_type} / ${selectedEvent.entity_id ?? '—'}`
                : ''}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <div>
              <h4 className="mb-1 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                {t('payload.payload')}
              </h4>
              <pre className="max-h-72 overflow-auto rounded-md bg-surface-card p-3 text-xs leading-relaxed">
                {JSON.stringify(selectedEvent?.payload ?? {}, null, 2)}
              </pre>
            </div>
            <p className="text-xs text-muted-foreground">
              <span className="font-semibold">{t('payload.userAgent')}:</span>{' '}
              {selectedEvent?.user_agent ?? '—'}
            </p>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
