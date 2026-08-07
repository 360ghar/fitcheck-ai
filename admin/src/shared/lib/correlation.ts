/**
 * Short, user-facing correlation id shown in error states so support can
 * cross-reference Sentry/backend logs.
 */
export function generateCorrelationId(): string {
  const time = Date.now().toString(36)
  const random = Math.random().toString(36).slice(2, 8)
  return `corr-${time}-${random}`
}
