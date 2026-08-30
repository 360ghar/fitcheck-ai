import { useTranslation } from 'react-i18next'

import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'

export function CollectionsTripsStreaks({
  collections,
  trips,
  streaks,
  achievements,
}: {
  collections: JsonRecord[]
  trips: JsonRecord[]
  streaks: JsonRecord | null
  achievements: JsonRecord[]
}) {
  const { t } = useTranslation('users')
  return (
    <div className="grid gap-3 lg:grid-cols-3">
      <Card>
        <CardHeader className="py-2">
          <CardTitle className="text-sm">{t('detail.collectionsSection', { defaultValue: 'Collections' })}</CardTitle>
        </CardHeader>
        <CardContent className="py-2">
          {collections.length === 0 ? (
            <EmptyState title={t('detail.collectionsEmpty', { defaultValue: 'No collections yet' })} className="py-2" />
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
          <CardTitle className="text-sm">{t('detail.tripsSection', { defaultValue: 'Trips' })}</CardTitle>
        </CardHeader>
        <CardContent className="py-2">
          {trips.length === 0 ? (
            <EmptyState title={t('detail.tripsEmpty', { defaultValue: 'No trips yet' })} className="py-2" />
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
          <CardTitle className="text-sm">{t('detail.streaksSection', { defaultValue: 'Streaks' })}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2 py-2 text-xs">
          <p className="text-muted-foreground">
            {t('detail.streakDays', {
              count: (streaks as unknown as Record<string, unknown>)?.['current_streak'] as number ?? 0,
              // eslint-disable-next-line @typescript-eslint/no-base-to-string
              defaultValue: `${String((streaks as unknown as Record<string, unknown>)?.['current_streak'] ?? 0)} day streak`,
            })}
          </p>
          <p className="text-muted-foreground">
            {t('detail.achievementsCount', { count: achievements.length, defaultValue: `${achievements.length} achievements` })}
          </p>
        </CardContent>
      </Card>
    </div>
  )
}

export default CollectionsTripsStreaks
