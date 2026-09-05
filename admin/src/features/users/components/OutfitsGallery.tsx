import { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'

import type { JsonRecord } from '@/features/users/lib/users'
import { stringValue } from '@/features/users/lib/users'
import { Badge } from '@/shared/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { EmptyState } from '@/shared/ui/EmptyState'
import { Tabs, TabsList, TabsTrigger } from '@/shared/ui/tabs'

export function OutfitsGallery({
  outfits,
  photoshootJobs,
  defaultTab,
  onTabChange,
}: {
  outfits: JsonRecord[]
  photoshootJobs: JsonRecord[]
  defaultTab: string
  onTabChange: (tab: string) => void
}) {
  const { t } = useTranslation('users')
  const [tab, setTab] = useState(defaultTab || 'outfits')
  useEffect(() => {
    setTab(defaultTab || 'outfits')
  }, [defaultTab])
  const handle = (value: string) => {
    setTab(value)
    onTabChange(value)
  }
  return (
    <Card>
      <CardHeader className="flex-row items-center justify-between py-2">
        <CardTitle className="text-sm">{t('detail.generationsSection')}</CardTitle>
        <Tabs value={tab} onValueChange={handle}>
          <TabsList className="h-7">
            <TabsTrigger value="outfits" className="px-2.5 py-0.5 text-xs">
              {t('detail.outfitsTab')}
            </TabsTrigger>
            <TabsTrigger value="photoshoot" className="px-2.5 py-0.5 text-xs">
              {t('detail.photoshootTab')}
            </TabsTrigger>
          </TabsList>
        </Tabs>
      </CardHeader>
      <CardContent className="py-2">
        {tab === 'outfits' ? (
          outfits.length === 0 ? (
            <EmptyState title={t('detail.outfitsEmpty')} message={t('detail.outfitsEmptyHint')} className="py-2" />
          ) : (
            <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 lg:grid-cols-4">
              {outfits.slice(0, 12).map((row, index) => {
                const id = stringValue(row, 'id') ?? `outfit-${index}`
                const title = stringValue(row, 'title') ?? stringValue(row, 'name') ?? '—'
                const image = stringValue(row, 'cover_image_url') ?? stringValue(row, 'image_url') ?? ''
                return (
                  <div key={id} className="overflow-hidden rounded-md border border-border">
                    {image ? (
                      <img src={image} alt={title} className="h-20 w-full object-cover" loading="lazy" />
                    ) : (
                      <div className="h-20 w-full bg-surface-card" />
                    )}
                    <div className="px-1.5 py-1">
                      <p className="truncate text-xs font-medium leading-tight text-ink">{title}</p>
                    </div>
                  </div>
                )
              })}
            </div>
          )
        ) : photoshootJobs.length === 0 ? (
          <EmptyState title={t('detail.photoshootEmpty')} message={t('detail.photoshootEmptyHint')} className="py-2" />
        ) : (
          <div className="space-y-1.5">
            {photoshootJobs.slice(0, 12).map((row, index) => {
              const id = stringValue(row, 'id') ?? `ps-${index}`
              const status = stringValue(row, 'status') ?? '—'
              const useCase = stringValue(row, 'use_case') ?? ''
              return (
                <div key={id} className="flex items-center justify-between rounded-md border border-border px-2.5 py-1.5">
                  <span className="text-sm font-medium text-ink">{useCase || id}</span>
                  <Badge variant="secondary">{status}</Badge>
                </div>
              )
            })}
          </div>
        )}
      </CardContent>
    </Card>
  )
}

export default OutfitsGallery
