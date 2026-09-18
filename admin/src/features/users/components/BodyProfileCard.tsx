import { useTranslation } from 'react-i18next'

import { useUserBodyProfileQuery } from '@/features/users/api/users'
import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { Badge } from '@/shared/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { Skeleton } from '@/shared/ui/skeleton'

/** Body profiles + gender — the inputs that drive photoshoot realism. */
export function BodyProfileCard({ userId }: { userId: string }) {
  const { t } = useTranslation('users')
  const query = useUserBodyProfileQuery(userId)

  return (
    <Card>
      <CardHeader className="py-2">
        <CardTitle className="text-sm">{t('detail.bodyProfileSection')}</CardTitle>
      </CardHeader>
      <CardContent className="py-2">
        {query.isPending ? (
          <div className="space-y-2">
            <Skeleton className="h-3 w-full" />
            <Skeleton className="h-3 w-2/3" />
          </div>
        ) : query.isError ? (
          <ErrorState message={query.error.message} onRetry={() => void query.refetch()} />
        ) : (
          (() => {
            const data = query.data as unknown as JsonRecord
            const profiles = (data['profiles'] as JsonRecord[] | undefined) ?? []
            const gender = stringValue(data, 'gender')
            if (profiles.length === 0 && !gender) {
              return (
                <EmptyState
                  title={t('detail.bodyProfileEmpty')}
                  message={t('detail.bodyProfileEmptyHint')}
                  className="py-2"
                />
              )
            }
            return (
              <div className="space-y-2">
                {gender ? (
                  <p className="text-xs text-muted-foreground">
                    {t('detail.bodyProfileGender')}:{' '}
                    <span className="font-medium text-ink">
                      {t(`detail.bodyProfileGender_${gender}`, { defaultValue: gender })}
                    </span>
                  </p>
                ) : null}
                {profiles.map((profile) => (
                  <div
                    key={stringValue(profile, 'id') ?? undefined}
                    className="rounded-md border border-border px-2.5 py-1.5"
                  >
                    <div className="flex items-center justify-between gap-2">
                      <span className="min-w-0 truncate text-xs font-medium text-ink">
                        {stringValue(profile, 'name') ?? '—'}
                      </span>
                      {profile['is_default'] === true ? (
                        <Badge variant="secondary" className="text-[10px]">
                          {t('detail.bodyProfileDefault')}
                        </Badge>
                      ) : null}
                    </div>
                    <p className="mt-0.5 text-[10px] text-muted-foreground">
                      {t('detail.bodyProfileSummary', {
                        height: Number(profile['height_cm'] ?? 0),
                        weight: Number(profile['weight_kg'] ?? 0),
                        shape: stringValue(profile, 'body_shape') ?? '—',
                        skinTone: stringValue(profile, 'skin_tone') ?? '—',
                      })}
                    </p>
                  </div>
                ))}
              </div>
            )
          })()
        )}
      </CardContent>
    </Card>
  )
}

export default BodyProfileCard
