/**
 * Simple promise-based concurrency limiter.
 * ponytail: plain queue, no priority/cancellation — add if throughput matters.
 */
export function createPromiseQueue(concurrency: number) {
  let active = 0
  const pending: (() => void)[] = []
  const limit = Math.max(1, concurrency) // a 0/negative limit would jam forever

  return <T>(fn: () => Promise<T>): Promise<T> =>
    new Promise<T>((resolve, reject) => {
      const run = () => {
        active++
        // Promise.resolve() turns a synchronous throw in fn into a rejection
        // that flows through the same finally — a bare fn() call would skip
        // the release below and permanently leak the slot.
        Promise.resolve()
          .then(fn)
          .then(resolve, reject)
          .finally(() => {
            active--
            pending.shift()?.()
          })
      }
      if (active < limit) run()
      else pending.push(run)
    })
}
