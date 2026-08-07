import { useTranslation } from 'react-i18next'

import { useSettingsQuery } from '@/features/settings/api/settings'
import { formatNumber } from '@/shared/lib/formatters'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { ErrorState } from '@/shared/ui/ErrorState'
import { PageHeader } from '@/shared/ui/PageHeader'
import { SkeletonTable } from '@/shared/ui/SkeletonTable'
import { StatusBadge } from '@/shared/ui/StatusBadge'

/** Render a scalar (string | number | boolean) or a fallback dash. */
function scalar(value: unknown): string {
  if (typeof value === 'string' && value.length > 0) return value
  if (typeof value === 'number' && Number.isFinite(value)) return formatNumber(value)
  if (typeof value === 'boolean') return String(value)
  return '—'
}

export function SettingsPage() {
  const { t } = useTranslation('settings')
  const query = useSettingsQuery()

  if (query.isPending) {
    return (
      <div className="space-y-6">
        <PageHeader title={t('title')} description={t('description')} />
        <SkeletonTable rows={5} columns={3} />
      </div>
    )
  }

  if (query.isError || !query.data) {
    return (
      <div className="space-y-6">
        <PageHeader title={t('title')} description={t('description')} />
        <ErrorState
          title={t('loadError.title')}
          message={t('loadError.message')}
          onRetry={() => {
            void query.refetch()
          }}
        />
      </div>
    )
  }

  const data = query.data
  const environment = data.environment
  const toggles = data.feature_toggles ?? {}
  const billing = data.billing ?? {}
  const storage = data.storage ?? {}
  const limits = data.limits ?? {}

  return (
    <div className="space-y-6">
      <PageHeader title={t('title')} description={t('description')} />

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        {/* Application */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">{t('sections.app')}</CardTitle>
          </CardHeader>
          <CardContent>
            <dl className="space-y-2 text-sm">
              <Row label={t('sections.appName')} value={scalar(data.app_name)} />
              <Row label={t('sections.version')} value={scalar(data.version)} />
              <Row
                label={t('sections.commit')}
                value={<span className="font-mono">{scalar(data.commit)}</span>}
              />
              <div className="flex items-center justify-between gap-3">
                <dt className="text-muted-foreground">{t('sections.environment')}</dt>
                <dd>
                  <StatusBadge
                    status={environment === 'production' ? 'active' : 'draft'}
                    label={t(
                      environment === 'production'
                        ? 'sections.environmentProduction'
                        : environment === 'development'
                          ? 'sections.environmentDevelopment'
                          : 'sections.environmentUnknown',
                    )}
                  />
                </dd>
              </div>
            </dl>
          </CardContent>
        </Card>

        {/* Billing */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">{t('sections.billing')}</CardTitle>
          </CardHeader>
          <CardContent>
            <dl className="space-y-2 text-sm">
              <Row
                label={t('sections.billingStripe')}
                value={
                  <StatusBadge
                    status={billing['stripe'] === true ? 'active' : 'disabled'}
                    label={t(
                      billing['stripe'] === true ? 'sections.configured' : 'sections.notConfigured',
                    )}
                  />
                }
              />
              <Row
                label={t('sections.billingApple')}
                value={
                  <StatusBadge
                    status={billing['apple'] === true ? 'active' : 'disabled'}
                    label={t(
                      billing['apple'] === true ? 'sections.configured' : 'sections.notConfigured',
                    )}
                  />
                }
              />
              <Row
                label={t('sections.billingGoogle')}
                value={
                  <StatusBadge
                    status={billing['google'] === true ? 'active' : 'disabled'}
                    label={t(
                      billing['google'] === true ? 'sections.configured' : 'sections.notConfigured',
                    )}
                  />
                }
              />
            </dl>
          </CardContent>
        </Card>

        {/* Object storage */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">{t('sections.storage')}</CardTitle>
          </CardHeader>
          <CardContent>
            <dl className="space-y-2 text-sm">
              <Row
                label={t('sections.storageBucket')}
                value={<span className="font-mono">{scalar(storage['bucket'])}</span>}
              />
              <Row label={t('sections.storageServingMode')} value={scalar(storage['serving_mode'])} />
              <Row
                label={t('sections.storagePresignTtl')}
                value={scalar(storage['presign_ttl_seconds'])}
              />
              <Row
                label={t('sections.storageConfigured')}
                value={
                  <StatusBadge
                    status={storage['configured'] === true ? 'active' : 'disabled'}
                    label={t(
                      storage['configured'] === true
                        ? 'sections.configured'
                        : 'sections.notConfigured',
                    )}
                  />
                }
              />
            </dl>
          </CardContent>
        </Card>

        {/* Feature toggles */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">{t('sections.featureToggles')}</CardTitle>
          </CardHeader>
          <CardContent>
            {Object.keys(toggles).length === 0 ? (
              <p className="text-sm text-muted-foreground">{t('sections.noToggles')}</p>
            ) : (
              <dl className="space-y-2 text-sm">
                {Object.entries(toggles).map(([name, enabled]) => (
                  <div key={name} className="flex items-center justify-between gap-3">
                    <dt className="truncate font-mono text-xs">{name}</dt>
                    <dd>
                      <StatusBadge
                        status={enabled === true ? 'active' : 'disabled'}
                        label={t(enabled === true ? 'enabled' : 'disabled')}
                      />
                    </dd>
                  </div>
                ))}
              </dl>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Plan limits */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">{t('sections.limits')}</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            {['free', 'plus_monthly', 'pro_monthly'].map((plan) => {
              const planLimits = limits[plan]
              const isObject = typeof planLimits === 'object' && planLimits !== null
              const limitsRecord = isObject
                ? (planLimits as Record<string, unknown>)
                : undefined
              return (
                <div key={plan} className="rounded-md border border-border p-3">
                  <h4 className="mb-2 text-sm font-semibold">{t(`sections.${plan}`)}</h4>
                  <dl className="space-y-1 text-sm">
                    <Row
                      label={t('sections.extractions')}
                      value={scalar(limitsRecord?.['extractions'])}
                    />
                    <Row
                      label={t('sections.generations')}
                      value={scalar(limitsRecord?.['generations'])}
                    />
                    <Row
                      label={t('sections.embeddings')}
                      value={scalar(limitsRecord?.['embeddings'])}
                    />
                  </dl>
                </div>
              )
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

function Row({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between gap-3">
      <dt className="text-muted-foreground">{label}</dt>
      <dd className="font-medium">{value}</dd>
    </div>
  )
}
