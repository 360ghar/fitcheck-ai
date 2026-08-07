import { useQuery } from '@tanstack/react-query'
import { FolderTree, Tag } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { blogKeys, fetchAllAdminPosts } from '@/features/content/api/blog'
import { deriveCategoryStats, type CategoryStat } from '@/features/content/lib/categories'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { PageHeader } from '@/shared/ui/PageHeader'
import { SkeletonTable } from '@/shared/ui/SkeletonTable'
import { StatusBadge } from '@/shared/ui/StatusBadge'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shared/ui/table'

export function CategoriesPage() {
  const { t } = useTranslation('content')
  const query = useQuery({
    queryKey: blogKeys.adminAll,
    queryFn: () => fetchAllAdminPosts(),
    staleTime: 300_000,
  })

  const stats = deriveCategoryStats(query.data ?? [])

  return (
    <div className="space-y-6">
      <PageHeader title={t('categories.title')} description={t('categories.description')} />

      <p className="max-w-2xl text-sm text-muted-foreground">{t('categories.intro')}</p>

      {query.isPending ? (
        <SkeletonTable rows={6} columns={3} />
      ) : query.isError || !query.data ? (
        <ErrorState
          title={t('categories.loadErrorTitle')}
          message={t('categories.loadErrorMessage')}
          onRetry={() => {
            void query.refetch()
          }}
        />
      ) : (
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="flex items-center gap-2 text-base">
              <FolderTree className="size-4 text-muted-foreground" aria-hidden="true" />
              {t('categories.header')}
            </CardTitle>
          </CardHeader>
          <CardContent>
            {stats.length === 0 ? (
              <EmptyState
                icon={Tag}
                title={t('categories.emptyTitle')}
                message={t('categories.emptyMessage')}
              />
            ) : (
              <CategoryTable stats={stats} />
            )}
          </CardContent>
        </Card>
      )}
    </div>
  )
}

function CategoryTable({ stats }: { stats: CategoryStat[] }) {
  const { t } = useTranslation('content')
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t('categories.columnCategory')}</TableHead>
          <TableHead className="w-40">{t('stats.total')}</TableHead>
          <TableHead className="w-40">{t('stats.published')}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {stats.map((stat) => (
          <TableRow key={stat.name}>
            <TableCell>
              <span className="rounded-full bg-surface-card px-2.5 py-0.5 text-xs font-medium">
                {stat.name}
              </span>
            </TableCell>
            <TableCell className="tabular-nums">{stat.total}</TableCell>
            <TableCell>
              <StatusBadge
                status={stat.published > 0 ? 'active' : 'draft'}
                label={t('categories.postCount', { count: stat.published })}
              />
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
