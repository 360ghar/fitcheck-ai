/**
 * Client-side CSV export (spec §4: audit log, tables). Emits a UTF-8 BOM so
 * Excel opens accented characters correctly, quotes every cell per RFC 4180,
 * and escapes embedded quotes by doubling them.
 */

export interface CsvColumn<T> {
  /** Human-readable header */
  label: string
  /** Value accessor — return null/undefined for an empty cell */
  value: (row: T) => string | number | boolean | null | undefined
}

function escapeCell(value: string): string {
  if (/[",\n\r]/.test(value)) {
    return `"${value.replaceAll('"', '""')}"`
  }
  return value
}

/** Build a CSV document string from rows + column definitions. */
export function buildCsv<T>(rows: readonly T[], columns: readonly CsvColumn<T>[]): string {
  const header = columns.map((c) => escapeCell(c.label)).join(',')
  const body = rows
    .map((row) =>
      columns
        .map((c) => {
          const value = c.value(row)
          if (value === null || value === undefined) return ''
          return escapeCell(String(value))
        })
        .join(','),
    )
    .join('\r\n')
  return `\uFEFF${header}\r\n${body}`
}

/** Trigger a client-side download of a CSV document. */
export function downloadCsv(filename: string, csv: string): void {
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = url
  anchor.download = filename
  document.body.appendChild(anchor)
  anchor.click()
  anchor.remove()
  URL.revokeObjectURL(url)
}
