import type { JsonRecord } from '@/features/users/lib/users'
import { arrayValue, stringValue } from '@/features/users/lib/users'

/**
 * Generation explorer vocabulary — mirrors the backend
 * `admin_user_generations_service.GEN_KINDS`. The viewer route takes the kind
 * as a URL segment, so unknown segments must fall back safely (see
 * `parseGenerationKind`).
 */
export const GENERATION_KINDS = [
  'item',
  'outfit',
  'outfit_render',
  'photoshoot',
  'social_import',
] as const

export type GenerationKind = (typeof GENERATION_KINDS)[number]

export function isGenerationKind(value: string | null | undefined): value is GenerationKind {
  return (GENERATION_KINDS as readonly string[]).includes(value ?? '')
}

/** Safe URL-segment parse: unknown kinds fall back to null (viewer shows 404). */
export function parseGenerationKind(value: string | null | undefined): GenerationKind | null {
  return isGenerationKind(value) ? value : null
}

/** i18n key per kind (`detail.genKind_item` etc.). */
export function generationKindLabelKey(kind: string): string {
  return isGenerationKind(kind) ? `detail.genKind_${kind}` : 'detail.genKind_unknown'
}

/** i18n key for the explorer tab of a kind (`detail.genTabsItem`,
 * `detail.genTabsOutfitRender`, ...). */
export function generationTabLabelKey(kind: string): string {
  const camel = kind
    .split('_')
    .map((part, index) => (index === 0 ? part : part.charAt(0).toUpperCase() + part.slice(1)))
    .join('')
  return `detail.genTabs${camel.charAt(0).toUpperCase()}${camel.slice(1)}`
}

/** i18n key per raw status (`detail.genStatus_completed` etc.), falling back
 * to the raw status as defaultValue at the call site. */
export function generationStatusLabelKey(status: string | null | undefined): string {
  return `detail.genStatus_${status ?? 'unknown'}`
}

/** Statuses offered in the explorer's status filter (exact server eq match). */
export const GENERATION_STATUSES = [
  'completed',
  'complete',
  'failed',
  'processing',
  'pending',
] as const

export interface GenerationMedia {
  url: string
  thumbUrl: string
  label: string | null
}

export function mediaList(record: JsonRecord | null | undefined): GenerationMedia[] {
  return arrayValue(record, 'media')
    .map((entry) => ({
      url: stringValue(entry, 'url') ?? '',
      thumbUrl: stringValue(entry, 'thumb_url') ?? '',
      label: stringValue(entry, 'label'),
    }))
    .filter((entry) => entry.url !== '')
}

/** Compact duration: 42s / 3m 05s / 1h 12m; null when unknown. */
export function formatDuration(ms: number | null | undefined): string | null {
  if (ms === null || ms === undefined || Number.isNaN(ms) || ms < 0) return null
  const totalSeconds = Math.round(ms / 1000)
  if (totalSeconds < 60) return `${totalSeconds}s`
  const minutes = Math.floor(totalSeconds / 60)
  const seconds = totalSeconds % 60
  if (minutes < 60) return `${minutes}m ${String(seconds).padStart(2, '0')}s`
  const hours = Math.floor(minutes / 60)
  return `${hours}h ${String(minutes % 60).padStart(2, '0')}m`
}

/** Kind-specific metadata rows for the viewer (label key, raw value). */
export function metaRows(record: JsonRecord): Array<{ key: string; value: JsonRecord[string] }> {
  const meta = (
    record['meta'] && typeof record['meta'] === 'object' ? record['meta'] : {}
  ) as JsonRecord
  const preferred = [
    'job_type',
    'use_case',
    'custom_prompt',
    'aspect_ratio',
    'pose',
    'lighting',
    'variations',
    'progress',
    'platform',
    'source_url',
    'style',
    'season',
    'occasion',
    'worn_count',
    'item_count',
    'num_images',
    'batch_size',
    'total_batches',
    'current_batch',
    'reference_photo_count',
    'total_images',
    'total_items',
    'extractions_completed',
    'extractions_failed',
    'generations_completed',
    'generations_failed',
    'auto_generate',
    'approved_photos',
    'rejected_photos',
    'discovered_photos',
    'processed_photos',
    'total_photos',
    'auth_required',
  ]
  const rows: Array<{ key: string; value: JsonRecord[string] }> = []
  for (const key of preferred) {
    const value = meta[key]
    if (value === undefined || value === null) continue
    // Empty arrays ("[]") carry no information — the section cards below
    // (extracted items / import photos) own the non-empty case.
    if (Array.isArray(value) && value.length === 0) continue
    rows.push({ key, value })
  }
  return rows
}
