export const DEFAULT_USE_CASES = [
  'formal',
  'informal',
  'party',
  'date',
  'dinner',
  'lunch',
] as const

export type DefaultUseCase = (typeof DEFAULT_USE_CASES)[number]

export function normalizeUseCase(value: string): string {
  return value.trim().toLowerCase()
}

export function normalizeUseCases(values: string[] | undefined | null): string[] {
  if (!values?.length) return []

  const seen = new Set<string>()
  const normalized: string[] = []

  values.forEach((value) => {
    const tag = normalizeUseCase(value)
    if (!tag || seen.has(tag)) return
    seen.add(tag)
    normalized.push(tag)
  })

  return normalized
}

export function formatUseCaseLabel(value: string): string {
  const normalized = normalizeUseCase(value)
  if (!normalized) return ''
  return normalized.charAt(0).toUpperCase() + normalized.slice(1)
}
