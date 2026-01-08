/**
 * Retry utility with exponential backoff
 *
 * Provides robust retry logic for async operations with configurable
 * exponential backoff and jitter to prevent thundering herd problems.
 */

export interface RetryOptions {
  /** Maximum number of retry attempts (default: 3) */
  maxRetries?: number
  /** Initial delay in milliseconds (default: 1000) */
  initialDelayMs?: number
  /** Maximum delay between retries in milliseconds (default: 30000) */
  maxDelayMs?: number
  /** Exponential backoff factor (default: 2) */
  backoffFactor?: number
  /** Add random jitter to prevent thundering herd (default: true) */
  jitter?: boolean
  /** HTTP status codes that should trigger retry (default: [429, 500, 502, 503, 504]) */
  retryableStatusCodes?: number[]
  /** Callback for each retry attempt */
  onRetry?: (attempt: number, error: Error, delayMs: number) => void
  /** AbortSignal for cancellation support */
  signal?: AbortSignal
}

export interface RetryResult<T> {
  success: boolean
  data?: T
  error?: Error
  attempts: number
}

const DEFAULT_OPTIONS: Required<Omit<RetryOptions, 'onRetry' | 'signal'>> = {
  maxRetries: 3,
  initialDelayMs: 1000,
  maxDelayMs: 30000,
  backoffFactor: 2,
  jitter: true,
  retryableStatusCodes: [429, 500, 502, 503, 504],
}

/**
 * Check if an error is retryable based on status code or error type
 */
function isRetryableError(error: unknown, retryableStatusCodes: number[]): boolean {
  // Check for Axios error with response status
  if (error && typeof error === 'object' && 'response' in error) {
    const axiosError = error as { response?: { status?: number } }
    const status = axiosError.response?.status
    if (status && retryableStatusCodes.includes(status)) {
      return true
    }
  }

  // Check for fetch Response errors
  if (error && typeof error === 'object' && 'status' in error) {
    const fetchError = error as { status?: number }
    if (fetchError.status && retryableStatusCodes.includes(fetchError.status)) {
      return true
    }
  }

  // Network errors are retryable
  if (error instanceof Error) {
    const message = error.message.toLowerCase()
    if (
      message.includes('network') ||
      message.includes('timeout') ||
      message.includes('econnreset') ||
      message.includes('econnrefused') ||
      message.includes('fetch failed') ||
      message.includes('failed to fetch')
    ) {
      return true
    }
  }

  return false
}

/**
 * Calculate delay with exponential backoff and optional jitter
 */
function calculateDelay(
  attempt: number,
  initialDelayMs: number,
  maxDelayMs: number,
  backoffFactor: number,
  jitter: boolean
): number {
  const exponentialDelay = initialDelayMs * Math.pow(backoffFactor, attempt - 1)
  const boundedDelay = Math.min(exponentialDelay, maxDelayMs)

  if (jitter) {
    // Add random jitter between 0-50% of the delay
    const jitterAmount = boundedDelay * Math.random() * 0.5
    return Math.floor(boundedDelay + jitterAmount)
  }

  return Math.floor(boundedDelay)
}

/**
 * Sleep for specified milliseconds, respecting abort signal
 */
function sleep(ms: number, signal?: AbortSignal): Promise<void> {
  return new Promise((resolve, reject) => {
    if (signal?.aborted) {
      reject(new DOMException('Aborted', 'AbortError'))
      return
    }

    const timeout = setTimeout(resolve, ms)

    const abortHandler = () => {
      clearTimeout(timeout)
      reject(new DOMException('Aborted', 'AbortError'))
    }

    signal?.addEventListener('abort', abortHandler, { once: true })
  })
}

/**
 * Execute a function with exponential backoff retry logic
 */
export async function withRetry<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<RetryResult<T>> {
  const opts = { ...DEFAULT_OPTIONS, ...options }
  let lastError: Error | undefined

  for (let attempt = 1; attempt <= opts.maxRetries + 1; attempt++) {
    // Check for cancellation
    if (opts.signal?.aborted) {
      return {
        success: false,
        error: new DOMException('Operation cancelled', 'AbortError'),
        attempts: attempt - 1,
      }
    }

    try {
      const data = await fn()
      return {
        success: true,
        data,
        attempts: attempt,
      }
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error))

      // Check if we should retry
      const isLastAttempt = attempt > opts.maxRetries
      const isRetryable = isRetryableError(error, opts.retryableStatusCodes)

      if (isLastAttempt || !isRetryable) {
        return {
          success: false,
          error: lastError,
          attempts: attempt,
        }
      }

      // Calculate and wait for backoff delay
      const delayMs = calculateDelay(
        attempt,
        opts.initialDelayMs,
        opts.maxDelayMs,
        opts.backoffFactor,
        opts.jitter
      )

      opts.onRetry?.(attempt, lastError, delayMs)

      try {
        await sleep(delayMs, opts.signal)
      } catch {
        // Aborted during sleep
        return {
          success: false,
          error: new DOMException('Operation cancelled', 'AbortError'),
          attempts: attempt,
        }
      }
    }
  }

  return {
    success: false,
    error: lastError ?? new Error('Unknown error'),
    attempts: opts.maxRetries + 1,
  }
}

/**
 * Execute multiple promises in parallel with individual retry logic
 * Returns results in the same order as input, with success/failure for each
 */
export async function parallelWithRetry<T, I>(
  items: I[],
  fn: (item: I, index: number) => Promise<T>,
  options: RetryOptions & {
    /** Callback when an item completes (success or final failure) */
    onItemComplete?: (index: number, result: RetryResult<T>) => void
  } = {}
): Promise<RetryResult<T>[]> {
  const { onItemComplete, ...retryOptions } = options

  const promises = items.map(async (item, index) => {
    const result = await withRetry(() => fn(item, index), retryOptions)
    onItemComplete?.(index, result)
    return result
  })

  return Promise.all(promises)
}
