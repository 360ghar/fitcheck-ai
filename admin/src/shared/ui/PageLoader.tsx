import { useTranslation } from 'react-i18next'

import { Skeleton } from '@/shared/ui/skeleton'

/**
 * Full-page loading state (route guards, lazy route suspense). Skeleton
 * blocks shaped like the app chrome, never a bare spinner (spec §5).
 */
export function PageLoader() {
  const { t } = useTranslation('components')
  return (
    <div
      role="status"
      aria-label={t('pageLoader.label')}
      className="flex min-h-dvh w-full flex-col gap-6 bg-background p-6"
    >
      <div className="flex items-center justify-between">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-8 w-24" />
      </div>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Skeleton className="h-28" />
        <Skeleton className="h-28" />
        <Skeleton className="h-28" />
        <Skeleton className="h-28" />
      </div>
      <Skeleton className="h-64 w-full" />
      <span className="sr-only">{t('pageLoader.loading')}</span>
    </div>
  )
}
