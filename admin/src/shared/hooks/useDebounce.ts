import { useEffect, useState } from 'react'

/**
 * Debounce a fast-changing value (search input). Returns the settled value
 * `delayMs` after the last change.
 */
export function useDebounce<T>(value: T, delayMs: number): T {
  const [debounced, setDebounced] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delayMs)
    return () => clearTimeout(timer)
  }, [value, delayMs])

  return debounced
}
