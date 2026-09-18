import type { TFunction } from 'i18next'
import { ExternalLink } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { useUserBillingQuery } from '@/features/users/api/users'
import type { JsonRecord } from '@/features/users/lib/users'
import { planLabelKey, stringValue } from '@/features/users/lib/users'
import { usePermission } from '@/shared/hooks/usePermission'
import { formatDateTimeValue, formatMoney } from '@/shared/lib/formatters'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { ErrorState } from '@/shared/ui/ErrorState'
import { Skeleton } from '@/shared/ui/skeleton'
import { StatusBadge } from '@/shared/ui/StatusBadge'

function Field({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-4 py-1.5">
      <dt className="text-xs text-muted-foreground">{label}</dt>
      <dd className="max-w-[60%] break-words text-right text-xs font-medium text-ink">{value}</dd>
    </div>
  )
}

// Stripe minor-unit exponents (ISO 4217): zero-decimal currencies have no
// subdivision, most have 2, a few have 3. Default 2 matches the old behavior.
const ZERO_DECIMAL = new Set([
  'BIF', 'CLP', 'DJF', 'GNF', 'JPY', 'KMF', 'KRW', 'MGA',
  'PYG', 'RWF', 'UGX', 'UYI', 'VND', 'VUV', 'XAF', 'XOF', 'XPF',
])
const THREE_DECIMAL = new Set(['BHD', 'IQD', 'JOD', 'KWD', 'LYD', 'OMR', 'TND'])

export function invoiceMinorUnit(currency: string): number {
  const code = currency.toUpperCase()
  if (ZERO_DECIMAL.has(code)) return 0
  if (THREE_DECIMAL.has(code)) return 3
  return 2
}

function invoiceAmount(invoice: JsonRecord): string | null {
  const amount = invoice['amount_paid']
  const currency = stringValue(invoice, 'currency') ?? 'usd'
  if (typeof amount !== 'number') return null
  return formatMoney(amount / 10 ** invoiceMinorUnit(currency), currency.toUpperCase())
}

/** Translated status/platform label with the raw backend value as fallback. */
export function billingLabel(
  t: TFunction<'users'>,
  prefix: 'detail.billingStatus' | 'detail.billingPlatform',
  raw: string | null | undefined,
): string {
  if (!raw) return '—'
  return t(`${prefix}_${raw}`, { defaultValue: raw })
}

/** Billing history: stored subscription + Stripe invoices (+ IAP when the
 * backend included them, which requires `iap.read`). Gated on
 * `subscriptions.read` server-side; the UI mirrors that gate. */
export function BillingCard({ userId }: { userId: string }) {
  const { t } = useTranslation('users')
  const { can } = usePermission()
  const enabled = can('subscriptions.read') && userId !== ''
  const query = useUserBillingQuery(userId, { enabled })

  if (!enabled) {
    return (
      <Card>
        <CardHeader className="py-2">
          <CardTitle className="text-sm">{t('detail.billingSection')}</CardTitle>
        </CardHeader>
        <CardContent className="py-3">
          <p className="text-sm text-muted-foreground">{t('detail.billingNoAccess')}</p>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader className="py-2">
        <CardTitle className="text-sm">{t('detail.billingSection')}</CardTitle>
      </CardHeader>
      <CardContent className="py-2">
        {query.isPending ? (
          <div className="space-y-2">
            <Skeleton className="h-3 w-full" />
            <Skeleton className="h-3 w-2/3" />
            <Skeleton className="h-3 w-1/2" />
          </div>
        ) : query.isError ? (
          <ErrorState message={query.error.message} onRetry={() => void query.refetch()} />
        ) : (
          (() => {
            const data = query.data as unknown as JsonRecord
            const subscription = data['subscription'] as JsonRecord | null | undefined
            const invoices = (data['stripe_invoices'] as JsonRecord[] | undefined) ?? []
            const iap = (data['iap_transactions'] as JsonRecord[] | undefined) ?? []
            const stripeConfigured = data['stripe_configured'] === true
            const plan = stringValue(subscription, 'plan_type')
            const planLabel = plan ? planLabelKey(plan) : null
            return (
              <div className="space-y-2">
                <dl className="divide-y divide-border">
                  <Field
                    label={t('columns.plan')}
                    value={plan ? t(planLabel ?? '', { defaultValue: plan }) : t('plans.none')}
                  />
                  <Field
                    label={t('detail.status')}
                    value={
                      stringValue(subscription, 'status') ? (
                        <StatusBadge
                          status={stringValue(subscription, 'status') ?? ''}
                          label={billingLabel(t, 'detail.billingStatus', stringValue(subscription, 'status'))}
                        />
                      ) : (
                        '—'
                      )
                    }
                  />
                  <Field
                    label={t('detail.billingProvider')}
                    value={stringValue(subscription, 'billing_provider') ?? '—'}
                  />
                </dl>

                <div>
                  <p className="py-1 text-xs font-medium text-muted-foreground">
                    {t('detail.billingInvoices')}
                  </p>
                  {invoices.length === 0 ? (
                    <p className="py-1 text-xs text-muted-foreground">
                      {stripeConfigured
                        ? t('detail.billingNoInvoices')
                        : t('detail.billingStripeNotConfigured')}
                    </p>
                  ) : (
                    <ul className="divide-y divide-border">
                      {invoices.map((invoice) => {
                        const url = stringValue(invoice, 'hosted_invoice_url')
                        return (
                          <li
                            key={stringValue(invoice, 'id') ?? undefined}
                            className="flex items-center justify-between gap-2 py-1.5 text-xs"
                          >
                            <span className="min-w-0 truncate">
                              {stringValue(invoice, 'number') ?? stringValue(invoice, 'id')}
                              <span className="ml-2 text-muted-foreground">
                                {formatDateTimeValue(invoice['created'])}
                              </span>
                            </span>
                            <span className="flex shrink-0 items-center gap-2">
                              <span className="font-medium text-ink">
                                {invoiceAmount(invoice) ?? '—'}
                              </span>
                              <StatusBadge
                                status={stringValue(invoice, 'status') ?? ''}
                                label={billingLabel(t, 'detail.billingStatus', stringValue(invoice, 'status'))}
                              />
                              {url ? (
                                <a
                                  href={url}
                                  target="_blank"
                                  rel="noreferrer"
                                  className="text-primary underline-offset-4 hover:underline"
                                  aria-label={t('detail.billingOpenInvoice')}
                                >
                                  <ExternalLink className="size-3" aria-hidden="true" />
                                </a>
                              ) : null}
                            </span>
                          </li>
                        )
                      })}
                    </ul>
                  )}
                </div>

                {iap.length > 0 ? (
                  <div>
                    <p className="py-1 text-xs font-medium text-muted-foreground">
                      {t('detail.billingIap')}
                    </p>
                    <ul className="divide-y divide-border">
                      {iap.map((txn) => (
                        <li
                          key={stringValue(txn, 'subscription_id') ?? undefined}
                          className="flex items-center justify-between gap-2 py-1.5 text-xs"
                        >
                          <span className="min-w-0 truncate">
                            {billingLabel(t, 'detail.billingPlatform', stringValue(txn, 'platform'))}
                            <span className="ml-2 font-mono text-muted-foreground">
                              {stringValue(txn, 'transaction_id') ?? ''}
                            </span>
                          </span>
                          <StatusBadge
                            status={stringValue(txn, 'status') ?? ''}
                            label={billingLabel(t, 'detail.billingStatus', stringValue(txn, 'status'))}
                          />
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

export default BillingCard
