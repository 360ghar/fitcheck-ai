import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { Badge } from '@/shared/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/shared/ui/dialog'
import { EmptyState } from '@/shared/ui/EmptyState'

interface ItemImage {
  url: string
  thumbUrl: string
  isPrimary: boolean
}

function imagesOf(item: JsonRecord): ItemImage[] {
  const raw = item['images']
  if (!Array.isArray(raw) || raw.length === 0) {
    const url = stringValue(item, 'image_url') ?? stringValue(item, 'thumbnail_url')
    return url
      ? [{ url, thumbUrl: stringValue(item, 'thumbnail_url') ?? url, isPrimary: true }]
      : []
  }
  const entries: ItemImage[] = []
  for (const entry of raw) {
    if (!entry || typeof entry !== 'object') continue
    const record = entry as JsonRecord
    const url = stringValue(record, 'url') ?? stringValue(record, 'image_url')
    if (!url) continue
    entries.push({
      url,
      thumbUrl: stringValue(record, 'thumb_url') ?? url,
      isPrimary: record['is_primary'] === true,
    })
  }
  return entries
}

function itemDisplayName(item: JsonRecord): string {
  return stringValue(item, 'name') ?? stringValue(item, 'title') ?? '—'
}

/** Uploads grid — one tile per wardrobe item. Tiles open a viewer with every
 * generated/catalog image plus the original source photo. */
export function ItemsGrid({ items }: { items: JsonRecord[] }) {
  const { t } = useTranslation('users')
  const [openId, setOpenId] = useState<string | null>(null)
  // Resolve the open row by stable id each render: a refetch clones row
  // objects, so object identity would close the viewer mid-read. A user
  // switch still closes it — the new list carries different ids.

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
  const openItem = openId
    ? (items
        .slice(0, 12)
        .find((row, index) => (stringValue(row, 'id') ?? `item-${index}`) === openId) ?? null)
    : null
  return (
    <Card>
      <CardHeader className="py-2">
        <CardTitle className="text-sm">{t('detail.uploadSection')}</CardTitle>
      </CardHeader>
      <CardContent className="py-2">
        <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6">
          {items.slice(0, 12).map((row, index) => {
            const id = stringValue(row, 'id') ?? `item-${index}`
            const name = itemDisplayName(row)
            const category = stringValue(row, 'category') ?? ''
            const image = stringValue(row, 'image_url') ?? stringValue(row, 'thumbnail_url') ?? ''
            return (
              <button
                key={id}
                type="button"
                onClick={() => setOpenId(id)}
                aria-label={t('detail.itemsOpen', { name })}
                className="overflow-hidden rounded-md border border-border text-left transition-colors hover:bg-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                {image ? (
                  <img src={image} alt={name} className="h-20 w-full object-cover" loading="lazy" />
                ) : (
                  <span className="block h-20 w-full bg-surface-card" />
                )}
                <span className="block px-1.5 py-1">
                  <span className="block truncate text-xs font-medium leading-tight text-ink">{name}</span>
                  {category ? <span className="block truncate text-[10px] leading-tight text-muted-foreground">{category}</span> : null}
                </span>
              </button>
            )
          })}
        </div>

        {/* Gated on the current items: a dialog for a previous user's item
            must not survive a user switch while the new list loads. */}
        <Dialog open={openItem !== null} onOpenChange={(open) => !open && setOpenId(null)}>
          <DialogContent className="max-w-lg">
            <DialogHeader>
              <DialogTitle>{openItem ? itemDisplayName(openItem) : ''}</DialogTitle>
              <DialogDescription>
                {openItem ? stringValue(openItem, 'category') ?? '' : ''}
              </DialogDescription>
            </DialogHeader>
            {openItem ? (
              <div className="space-y-3">
                {(() => {
                  const images = imagesOf(openItem)
                  const source = stringValue(openItem, 'source_image_url')
                  return (
                    <>
                      {images.length > 0 ? (
                        <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
                          {images.map((image) => (
                            <a
                              key={image.url}
                              href={image.url}
                              target="_blank"
                              rel="noreferrer"
                              className="relative block overflow-hidden rounded-md border border-border"
                            >
                              <img
                                src={image.thumbUrl || image.url}
                                alt={openItem ? itemDisplayName(openItem) : ''}
                                className="h-28 w-full object-cover"
                                loading="lazy"
                              />
                              {image.isPrimary ? (
                                <Badge variant="secondary" className="absolute left-1 top-1 text-[10px]">
                                  {t('detail.itemsPrimaryImage')}
                                </Badge>
                              ) : null}
                            </a>
                          ))}
                        </div>
                      ) : (
                        <p className="text-sm text-muted-foreground">{t('detail.itemsNoImages')}</p>
                      )}
                      {source ? (
                        <div>
                          <p className="py-1 text-xs font-medium text-muted-foreground">
                            {t('detail.itemsSourcePhoto')}
                          </p>
                          <a
                            href={source}
                            target="_blank"
                            rel="noreferrer"
                            className="block overflow-hidden rounded-md border border-border"
                          >
                            <img
                              src={source}
                              alt={t('detail.itemsSourcePhoto')}
                              className="h-40 w-full object-cover"
                              loading="lazy"
                            />
                          </a>
                        </div>
                      ) : null}
                      <div className="rounded-md border border-border bg-surface-card px-3 py-2">
                        <p className="text-xs text-muted-foreground">{t('detail.genSourceId')}</p>
                        <code className="block truncate font-mono text-xs text-ink">
                          {stringValue(openItem, 'id') ?? '—'}
                        </code>
                      </div>
                    </>
                  )
                })()}
              </div>
            ) : null}
          </DialogContent>
        </Dialog>
      </CardContent>
    </Card>
  )
}

export default ItemsGrid
