import { useTranslation } from 'react-i18next'

import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'

export function ItemsGrid({ items }: { items: JsonRecord[] }) {
  const { t } = useTranslation('users')
  if (items.length === 0) {
    return (
      <Card>
        <CardHeader className="py-2">
          <CardTitle className="text-sm">{t('detail.uploadSection')}</CardTitle>
        </CardHeader>
        <CardContent className="py-3">
          <EmptyState title={t('detail.itemsGridEmpty')} message={t('detail.itemsGridEmptyHint')} className="py-2" />
        </CardContent>
      </Card>
    )
  }
  return (
    <Card>
      <CardHeader className="py-2">
        <CardTitle className="text-sm">{t('detail.uploadSection')}</CardTitle>
      </CardHeader>
      <CardContent className="py-2">
        <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6">
          {items.slice(0, 12).map((row, index) => {
            const id = stringValue(row, 'id') ?? `item-${index}`
            const name = stringValue(row, 'name') ?? stringValue(row, 'title') ?? '—'
            const category = stringValue(row, 'category') ?? ''
            const image = stringValue(row, 'image_url') ?? stringValue(row, 'thumbnail_url') ?? ''
            return (
              <div key={id} className="overflow-hidden rounded-md border border-border">
                {image ? (
                  <img src={image} alt={name} className="h-20 w-full object-cover" loading="lazy" />
                ) : (
                  <div className="h-20 w-full bg-surface-card" />
                )}
                <div className="px-1.5 py-1">
                  <p className="truncate text-xs font-medium leading-tight text-ink">{name}</p>
                  {category ? <p className="truncate text-[10px] leading-tight text-muted-foreground">{category}</p> : null}
                </div>
              </div>
            )
          })}
        </div>
      </CardContent>
    </Card>
  )
}

export default ItemsGrid
