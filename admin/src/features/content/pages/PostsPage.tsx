import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { FileText, Pencil, Trash2 } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router-dom'
import { toast } from 'sonner'

import {
  blogKeys,
  deleteBlogPost,
  fetchAllAdminPosts,
  listAdminPostsPage,
  type BlogPost,
} from '@/features/content/api/blog'
import { categoryNames } from '@/features/content/lib/categories'
import { formatDate } from '@/shared/lib/formatters'
import { Button } from '@/shared/ui/button'
import { ConfirmDialog } from '@/shared/ui/ConfirmDialog'
import { DataTable } from '@/shared/ui/DataTable'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { MetricCard } from '@/shared/ui/MetricCard'
import { PageHeader } from '@/shared/ui/PageHeader'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import { TableToolbar } from '@/shared/ui/TableToolbar'
import { useServerTable } from '@/shared/ui/useServerTable'

export function PostsPage() {
  const { t } = useTranslation('content')
  const queryClient = useQueryClient()
  const [deleteTarget, setDeleteTarget] = useState<BlogPost | null>(null)

  const table = useServerTable<BlogPost>({
    queryKey: blogKeys.all,
    queryFn: listAdminPostsPage,
    filterKeys: ['status', 'category'],
  })

  const categoriesQuery = useQuery({
    queryKey: blogKeys.adminAll,
    queryFn: () => fetchAllAdminPosts(),
    staleTime: 300_000,
  })

  const deleteMutation = useMutation({
    mutationFn: deleteBlogPost,
    onSuccess: () => {
      toast.success(t('delete.success'))
      setDeleteTarget(null)
      void queryClient.invalidateQueries({ queryKey: blogKeys.all })
      void queryClient.invalidateQueries({ queryKey: blogKeys.adminAll })
      void queryClient.invalidateQueries({ queryKey: blogKeys.categories })
    },
    onError: () => {
      toast.error(t('delete.errorGeneric'))
    },
  })

  const categories = categoryNames(categoriesQuery.data ?? [])

  const columns: ColumnDef<BlogPost>[] = [
    {
      id: 'post',
      header: t('columns.post'),
      enableSorting: false,
      cell: ({ row }) => (
        <div className="flex min-w-0 items-center gap-3">
          <span className="flex size-10 shrink-0 items-center justify-center rounded-lg bg-surface-card text-lg">
            {row.original.emoji}
          </span>
          <div className="min-w-0">
            <Link
              to={`/content/posts/edit/${row.original.slug}`}
              className="block max-w-xs truncate font-medium text-foreground underline-offset-4 hover:text-primary hover:underline"
            >
              {row.original.title}
            </Link>
            <span className="text-xs text-muted-foreground">
              {t('editor.fields.author')}: {row.original.author} · {row.original.read_time}
            </span>
          </div>
        </div>
      ),
    },
    {
      id: 'category',
      header: t('columns.category'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="rounded-full bg-surface-card px-2.5 py-0.5 text-xs font-medium">
          {row.original.category || '—'}
        </span>
      ),
    },
    {
      id: 'status',
      header: t('columns.status'),
      enableSorting: false,
      cell: ({ row }) => (
        <StatusBadge
          status={row.original.is_published ? 'published' : 'draft'}
          label={t(row.original.is_published ? 'status.published' : 'status.draft')}
        />
      ),
    },
    {
      id: 'date',
      header: t('columns.date'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="whitespace-nowrap text-sm text-muted-foreground">
          {formatDate(row.original.date)}
        </span>
      ),
    },
    {
      id: 'updated',
      header: t('columns.updated'),
      enableSorting: false,
      cell: ({ row }) => (
        <span className="whitespace-nowrap text-sm text-muted-foreground">
          {formatDate(row.original.updated_at)}
        </span>
      ),
    },
    {
      id: 'actions',
      enableSorting: false,
      cell: ({ row }) => (
        <div className="flex items-center justify-end gap-1">
          <Button asChild variant="ghost" size="sm" aria-label={t('rowActions.edit')}>
            <Link to={`/content/posts/edit/${row.original.slug}`}>
              <Pencil aria-hidden="true" />
              {t('rowActions.edit')}
            </Link>
          </Button>
          <Button
            variant="ghost"
            size="sm"
            className="text-destructive hover:text-destructive"
            onClick={() => setDeleteTarget(row.original)}
            aria-label={t('rowActions.delete')}
          >
            <Trash2 aria-hidden="true" />
          </Button>
        </div>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        title={t('title')}
        description={t('description')}
        actions={
          <Button asChild>
            <Link to="/content/posts/new">
              <FileText aria-hidden="true" />
              {t('newPost')}
            </Link>
          </Button>
        }
      />

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <MetricCard label={t('stats.total')} value={table.total} />
        <MetricCard
          label={t('stats.published')}
          value={table.data.filter((post) => post.is_published).length}
        />
        <MetricCard
          label={t('stats.drafts')}
          value={table.data.filter((post) => !post.is_published).length}
        />
      </div>

      <TableToolbar
        searchValue={table.tableState.q}
        onSearchChange={table.tableState.setQ}
        primaryFilter={{
          key: 'status',
          label: t('filters.status'),
          placeholder: t('filters.statusPlaceholder'),
          options: [
            { value: 'all', label: t('filters.statusPlaceholder') },
            { value: 'published', label: t('status.published') },
            { value: 'draft', label: t('status.draft') },
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
              ...categories.map((category) => ({ value: category, label: category })),
            ],
            value: table.tableState.filters.category,
            onValueChange: (value) =>
              table.tableState.setFilter('category', value && value !== 'all' ? value : undefined),
          },
        ]}
        isFetching={table.props.isFetching}
        onReset={table.tableState.reset}
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
        <DataTable<BlogPost>
          {...table.props}
          columns={columns}
          ariaLabel={t('title')}
          getRowId={(row) => row.id}
          onResetFilters={() => table.tableState.reset()}
          emptyState={
            <EmptyState icon={FileText} title={t('empty.title')} message={t('empty.message')} />
          }
        />
      )}

      <ConfirmDialog
        open={deleteTarget !== null}
        onOpenChange={(open) => {
          if (!open) setDeleteTarget(null)
        }}
        title={t('delete.dialogTitle')}
        {...(deleteTarget
          ? { description: t('delete.dialogDescription', { title: deleteTarget.title }) }
          : {})}
        confirmLabel={t('delete.confirm')}
        onConfirm={async () => {
          if (!deleteTarget) return
          await deleteMutation.mutateAsync(deleteTarget.slug)
        }}
      />
    </div>
  )
}
