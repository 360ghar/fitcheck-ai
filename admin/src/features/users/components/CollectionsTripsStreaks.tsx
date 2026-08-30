import { useTranslation } from 'react-i18next'

import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'

export function CollectionsTripsStreaks({
  collections,
  trips,
  streaks,
  achievementsCount,
}: {
  collections: JsonRecord[]
  trips: JsonRecord[]
  streaks: JsonRecord | null
  achievementsCount: number
}) {
  const { t } = useTranslation('users')
  return (
    <div className="grid gap-3 lg:grid-cols-3">
      <Card>
        <CardHeader className="py-2">
          <CardTitle className="text-sm">{t('detail.collectionsSection')}</CardTitle>
        </CardHeader>
        <CardContent className="py-2">
          {collections.length === 0 ? (
            <EmptyState title={t('detail.collectionsEmpty')} className="py-2" />
          ) : (
            <ul className="space-y-1.5">
              {collections.slice(0, 6).map((row, index) => (
                <li key={stringValue(row, 'id') ?? `col-${index}`} className="rounded-md border border-border px-2.5 py-1.5 text-xs font-medium">
                  {stringValue(row, 'name') ?? stringValue(row, 'title') ?? '—'}
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="py-2">
          <CardTitle className="text-sm">{t('detail.tripsSection')}</CardTitle>
        </CardHeader>
        <CardContent className="py-2">
          {trips.length === 0 ? (
            <EmptyState title={t('detail.tripsEmpty')} className="py-2" />
          ) : (
            <ul className="space-y-1.5">
              {trips.slice(0, 6).map((row, index) => (
                <li key={stringValue(row, 'id') ?? `trip-${index}`} className="rounded-md border border-border px-2.5 py-1.5 text-xs font-medium">
                  {stringValue(row, 'name') ?? stringValue(row, 'title') ?? '—'}
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="py-2">
          <CardTitle className="text-sm">{t('detail.streaksSection')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2 py-2 text-xs">
          <p className="text-muted-foreground">
            {t('detail.streakDays', {
              count: (streaks as unknown as Record<string, unknown>)?.['current_streak'] as number ?? 0,
            })}
          </p>
          <p className="text-muted-foreground">
            {t('detail.achievementsCount', { count: achievementsCount })}
          </p>
        </CardContent>
      </Card>
    </div>
  )
}

export default CollectionsTripsStreaks
