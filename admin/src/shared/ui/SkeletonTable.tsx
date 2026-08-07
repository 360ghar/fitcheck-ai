import { useTranslation } from 'react-i18next'

import { cn } from '@/shared/lib/cn'
import { Skeleton } from '@/shared/ui/skeleton'

/**
 * Skeleton table — content-shaped loading placeholder for page-level
 * suspense/loading states. DataTable has its own inline skeleton rows.
 */
export interface SkeletonTableProps {
  rows?: number
  columns?: number
  className?: string
}

export function SkeletonTable({ rows = 8, columns = 5, className }: SkeletonTableProps) {
  const { t } = useTranslation('components')
  return (
    <div
      role="status"
      aria-label={t('skeleton.tableLabel')}
      className={cn('space-y-3', className)}
    >
      {Array.from({ length: rows }, (_, rowIndex) => (
        <div key={rowIndex} className="flex items-center gap-4 rounded-md border border-border bg-card p-4">
          {Array.from({ length: columns }, (_, colIndex) => (
            <Skeleton
              key={colIndex}
              className={cn('h-4', colIndex === 0 ? 'w-1/4' : colIndex === 1 ? 'w-1/5' : 'w-1/6')}
            />
          ))}
        </div>
      ))}
      <span className="sr-only">{t('skeleton.loading')}</span>
    </div>
  )
}
