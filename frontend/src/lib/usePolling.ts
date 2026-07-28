import { useEffect, useRef } from 'react';

interface UsePollingOptions {
  intervalMs: number;
  shouldStop: () => boolean;
  onTick: () => Promise<void> | void;
}

/**
 * Abstracts setInterval-based polling with proper cleanup.
 *
 * `onTick` and `shouldStop` are stored in refs so the interval is NOT reset
 * when the parent re-renders — only `intervalMs` changes restart the timer.
 *
 * A busy flag prevents concurrent tick executions when onTick is async and
 * takes longer than intervalMs. The interval continues ticking but skips
 * the callback until the previous invocation finishes.
 */
export function usePolling({ intervalMs, shouldStop, onTick }: UsePollingOptions): void {
  const savedCallback = useRef(onTick);
  const savedShouldStop = useRef(shouldStop);
  const busyRef = useRef(false);

  useEffect(() => {
    savedCallback.current = onTick;
    savedShouldStop.current = shouldStop;
  }, [onTick, shouldStop]);

  useEffect(() => {
    let intervalId: ReturnType<typeof setInterval> | null = null;

    const tick = async () => {
      if (savedShouldStop.current()) {
        if (intervalId !== null) {
          clearInterval(intervalId);
          intervalId = null;
        }
        return;
      }
      if (busyRef.current) return;
      busyRef.current = true;
      try {
        await savedCallback.current();
      } catch {
        // Swallow — polling callbacks should handle their own errors;
        // an unhandled rejection in setInterval is unrecoverable.
      } finally {
        busyRef.current = false;
      }
    };

    intervalId = setInterval(tick, intervalMs);

    return () => {
      if (intervalId !== null) {
        clearInterval(intervalId);
      }
    };
  }, [intervalMs]);
}
