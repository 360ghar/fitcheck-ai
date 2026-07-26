import { useEffect, useRef, useState } from 'react';

/**
 * Seconds elapsed since `active` last became true. Resets to 0 whenever
 * `active` flips false -> true again (e.g. cancel + retry).
 *
 * Uses Date.now() deltas rather than a naive ++counter so a backgrounded/
 * throttled tab still reports a correct value once it wakes up.
 *
 * ponytail: elapsed restarts on remount (no start timestamp lives in the
 * store) — acceptable for a "how long have I been waiting" hint; move the
 * start time into the store if it must survive navigation away and back.
 */
export function useElapsedSeconds(active: boolean): number {
  const [seconds, setSeconds] = useState(0);
  const startRef = useRef<number | null>(null);

  useEffect(() => {
    if (!active) {
      startRef.current = null;
      setSeconds(0);
      return;
    }
    startRef.current = Date.now();
    setSeconds(0);
    const id = setInterval(() => {
      setSeconds(Math.floor((Date.now() - (startRef.current as number)) / 1000));
    }, 1000);
    return () => clearInterval(id);
  }, [active]);

  return seconds;
}
