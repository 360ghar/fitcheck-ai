import { useTranslation } from 'react-i18next'

import { useUserReferralsQuery } from '@/features/users/api/users'
import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { formatDateTimeValue } from '@/shared/lib/formatters'
import { Badge } from '@/shared/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { Skeleton } from '@/shared/ui/skeleton'

/** Referrals & promo: code, who redeemed it, credits, promo grants. */
export function ReferralsCard({ userId }: { userId: string }) {
  const { t } = useTranslation('users')
  const query = useUserReferralsQuery(userId)

  return (
    <Card>
      <CardHeader className="py-2">
        <CardTitle className="text-sm">{t('detail.referralsSection')}</CardTitle>
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
            const redemptions = (data['redemptions'] as JsonRecord[] | undefined) ?? []
            const promos = (data['promo_redemptions'] as JsonRecord[] | undefined) ?? []
            const code = stringValue(data, 'code')
            const timesUsed = typeof data['times_used'] === 'number' ? data['times_used'] : 0
            if (!code && redemptions.length === 0 && promos.length === 0) {
              return (
                <EmptyState
                  title={t('detail.referralsEmpty')}
                  message={t('detail.referralsEmptyHint')}
                  className="py-2"
                />
              )
            }
            return (
              <div className="space-y-2">
                {code ? (
                  <div className="flex items-center justify-between gap-2 rounded-md border border-border px-2.5 py-1.5">
                    <code className="truncate font-mono text-xs text-ink">{code}</code>
                    <Badge variant="secondary" className="text-[10px]">
                      {t('detail.referralsTimesUsed', { count: timesUsed })}
                    </Badge>
                  </div>
                ) : null}

                {redemptions.length > 0 ? (
                  <ul className="divide-y divide-border">
                    {redemptions.map((redemption) => (
                      <li key={stringValue(redemption, 'id') ?? undefined} className="py-1.5">
                        <div className="flex items-center justify-between gap-2">
                          <span className="min-w-0 truncate text-xs font-medium text-ink">
                            {stringValue(redemption, 'referred_email') ??
                              stringValue(redemption, 'referred_name') ??
                              '—'}
                          </span>
                          <span className="shrink-0 text-[10px] text-muted-foreground">
                            {formatDateTimeValue(redemption['redeemed_at'])}
                          </span>
                        </div>
                        <div className="mt-0.5 flex flex-wrap items-center gap-1">
                          <Badge
                            variant={
                              redemption['referrer_credit_applied'] === true ? 'success' : 'outline'
                            }
                            className="text-[10px]"
                          >
                            {t('detail.referralsCreditApplied', {
                              months: Number(redemption['credit_months'] ?? 0),
                            })}
                          </Badge>
                        </div>
                      </li>
                    ))}
                  </ul>
                ) : null}

                {promos.length > 0 ? (
                  <div>
                    <p className="py-1 text-xs font-medium text-muted-foreground">
                      {t('detail.referralsPromos')}
                    </p>
                    <ul className="divide-y divide-border">
                      {promos.map((promo) => (
                        <li
                          key={stringValue(promo, 'id') ?? undefined}
                          className="flex items-center justify-between gap-2 py-1.5 text-xs"
                        >
                          <span className="min-w-0 truncate font-medium text-ink">
                            {stringValue(promo, 'code') ?? '—'}
                          </span>
                          <span className="shrink-0 text-muted-foreground">
                            {t('detail.referralsPromoMonths', {
                              months: Number(promo['months'] ?? 0),
                            })}
                            {' · '}
                            {formatDateTimeValue(promo['created_at'])}
                          </span>
                        </li>
                      ))}
                    </ul>
                  </div>
                ) : null}
              </div>
            )
          })()
        )}
      </CardContent>
    </Card>
  )
}

export default ReferralsCard
