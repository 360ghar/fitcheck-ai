import { useCallback } from 'react'
import { toast } from 'sonner'

import { buildCsv, downloadCsv, type CsvColumn } from '@/shared/lib/csv'

/**
 * Client-side CSV export for list pages (current filtered page, mirroring
 * the audit page's export pattern). Pages provide the row type, columns and
 * translated strings; the hook wires buildCsv/downloadCsv + success toast.
 */
export function useCsvExport<T>(options: {
  /** Rows to export (typically the current filtered page). */
  rows: readonly T[]
  /** Download filename (i18n key value, e.g. `t('export.filename')`). */
  filename: string
  /** Column definitions for the CSV (headers + value accessors). */
  columns: readonly CsvColumn<T>[]
  /** Success toast text, e.g. `t('export.toast', { count })`. */
  toastMessage: string
}): { canExport: boolean; exportCsv: () => void } {
  const { rows, filename, columns, toastMessage } = options

  const exportCsv = useCallback((): void => {
    if (rows.length === 0) return
    downloadCsv(filename, buildCsv(rows, columns))
    toast.success(toastMessage)
  }, [rows, filename, columns, toastMessage])

  return { canExport: rows.length > 0, exportCsv }
}
