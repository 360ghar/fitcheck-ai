import { useMutation, useQueryClient } from '@tanstack/react-query'
import { Database, Eraser } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import {
  cleanupTempObjects,
  useStorageQuery,
  type AdminStorageResponse,
} from '@/features/ops/api/ops'
import { ApiError, isApiError } from '@/shared/api/errors'
import { usePermission } from '@/shared/hooks/usePermission'
import { formatBytes, formatDate, formatNumber, relativeTime } from '@/shared/lib/formatters'
import { Button } from '@/shared/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import { ConfirmDialog } from '@/shared/ui/ConfirmDialog'
import { EmptyState } from '@/shared/ui/EmptyState'
import { ErrorState } from '@/shared/ui/ErrorState'
import { MetricCard } from '@/shared/ui/MetricCard'
import { PageHeader } from '@/shared/ui/PageHeader'
import { SkeletonTable } from '@/shared/ui/SkeletonTable'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shared/ui/table'

/** Backend safety cap (backend/app/services/admin_service.py TEMP_DELETE_MAX_OBJECTS). */
const TEMP_DELETE_CAP = 5000

export function StoragePage() {
  const { t } = useTranslation('ops')
  const { can } = usePermission()
  const queryClient = useQueryClient()
  const [cleanupOpen, setCleanupOpen] = useState(false)
  const canCleanup = can('storage.cleanup')

  const storageQuery = useStorageQuery()

  const cleanupMutation = useMutation({
    mutationFn: cleanupTempObjects,
    onSuccess: (result) => {
      const message = t(
        result.truncated ? 'cleanup.successTruncated' : 'cleanup.success',
        {
          count: formatNumber(result.deleted),
          bytes: formatBytes(result.bytes_freed),
        },
      )
      toast.success(message)
      setCleanupOpen(false)
      void queryClient.invalidateQueries({ queryKey: ['ops', 'storage'] })
    },
    onError: (error) => {
      if (isApiError(error)) {
        toast.error(error.message)
      }
    },
  })

  const handleConfirmCleanup = async (): Promise<void> => {
    try {
      await cleanupMutation.mutateAsync()
    } catch (error) {
      throw new ApiError({
        status: isApiError(error) ? error.status : 0,
        code: isApiError(error) ? error.code : 'INTERNAL_ERROR',
        message: t('cleanup.errorGeneric'),
      })
    }
  }

  if (storageQuery.isPending) {
    return (
      <div className="space-y-6">
        <PageHeader title={t('title')} description={t('description')} />
        <SkeletonTable rows={4} columns={4} />
      </div>
    )
  }

  if (storageQuery.isError || !storageQuery.data) {
    return (
      <div className="space-y-6">
        <PageHeader title={t('title')} description={t('description')} />
        <ErrorState
          title={t('loadError.title')}
          message={t('loadError.message')}
          onRetry={() => {
            void storageQuery.refetch()
          }}
        />
      </div>
    )
  }

  const inventory: AdminStorageResponse = storageQuery.data
  const items = inventory.items ?? []

  return (
    <div className="space-y-6">
      <PageHeader
        title={t('title')}
        description={t('description')}
        actions={
          canCleanup ? (
            <Button
              variant="destructive"
              onClick={() => setCleanupOpen(true)}
              disabled={inventory.count === 0}
            >
              <Eraser aria-hidden="true" />
              {t('cleanup.title')}
            </Button>
          ) : undefined
        }
      />

      {inventory.truncated ? (
        <p className="rounded-md border border-warning-deep/40 bg-warning-pale px-3 py-2 text-sm text-warning-deep">
          {t('truncated.banner')}
        </p>
      ) : null}

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard label={t('summary.objects')} value={inventory.count} />
        <MetricCard label={t('summary.totalBytes')} value={formatBytes(inventory.total_bytes)} />
        <MetricCard label={t('summary.scannedKeys')} value={inventory.scanned_keys} />
        <MetricCard
          label={t('summary.oldest')}
          value={formatDate(extractIsoDate(inventory.oldest))}
          hint={`${t('summary.newest')}: ${formatDate(extractIsoDate(inventory.newest))}`}
        />
      </div>

      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">
            {t('summary.bucket')}: <span className="font-mono">{inventory.bucket}</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          {items.length === 0 ? (
            <EmptyState icon={Database} title={t('empty.title')} message={t('empty.message')} />
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>{t('columns.key')}</TableHead>
                  <TableHead className="w-32">{t('columns.size')}</TableHead>
                  <TableHead className="w-44">{t('columns.age')}</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((item) => (
                  <TableRow key={item.key}>
                    <TableCell className="break-all font-mono text-xs">{item.key}</TableCell>
                    <TableCell className="tabular-nums">{formatBytes(item.size)}</TableCell>
                    <TableCell className="whitespace-nowrap text-muted-foreground">
                      {relativeTime(item.last_modified as string | null | undefined)}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      <ConfirmDialog
        open={cleanupOpen}
        onOpenChange={setCleanupOpen}
        title={t('cleanup.title')}
        description={t('cleanup.description', {
          count: formatNumber(inventory.count),
          bytes: formatBytes(inventory.total_bytes),
        })}
        confirmLabel={t('cleanup.confirm', { count: formatNumber(Math.min(inventory.count, TEMP_DELETE_CAP)) })}
        onConfirm={handleConfirmCleanup}
      />
    </div>
  )
}

/** oldest/newest are untyped dicts ({ LastModified: iso, ... }) — extract defensively. */
function extractIsoDate(
  value: { [key: string]: unknown } | null | undefined,
): string | null | undefined {
  if (!value || typeof value !== 'object') return null
  for (const key of ['last_modified', 'LastModified']) {
    const candidate = value[key]
    if (typeof candidate === 'string' && candidate.length > 0) return candidate
  }
  return null
}
