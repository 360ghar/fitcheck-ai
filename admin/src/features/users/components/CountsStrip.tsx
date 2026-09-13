import { useTranslation } from 'react-i18next'

import type { JsonRecord } from '@/features/users/lib/users'
import { formatNumber } from '@/shared/lib/formatters'
import { Badge } from '@/shared/ui/badge'
import { Card, CardContent } from '@/shared/ui/card'

export function CountsStrip({ counts }: { counts: JsonRecord }) {
  const { t } = useTranslation('users')
  const entries = Object.entries(counts)
    .filter(([, v]) => typeof v === 'number')
    .sort(([a], [b]) => a.localeCompare(b))
  return (
    <Card>
      <CardContent className="flex flex-wrap gap-1.5 py-2">
        {entries.map(([key, value]) => (
          <Badge key={key} variant="secondary" className="gap-1.5">
            {/* Unknown backend count keys degrade to a humanized label
                instead of rendering the raw translation key. */}
            {t(`detail.${key}`, { defaultValue: key.replaceAll('_', ' ') })}: {formatNumber(value as number)}
          </Badge>
        ))}
        {entries.length === 0 ? <span className="text-sm text-muted-foreground">—</span> : null}
      </CardContent>
    </Card>
  )
}

export default CountsStrip
