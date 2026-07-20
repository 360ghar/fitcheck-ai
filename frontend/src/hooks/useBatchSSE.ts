/**
 * Hook for managing SSE connection to batch processing jobs.
 *
 * Handles connection, reconnection, and event parsing.
 */

import { useCallback, useEffect, useRef, useState } from 'react';
import { createAuthenticatedSSEConnection } from '@/api/batch';
import type { BatchSSEEventType } from '@/types';

interface UseBatchSSEOptions {
  /** Job ID to connect to */
  jobId: string | null;
  /** Callback for each SSE event */
  onEvent: (event: { type: BatchSSEEventType; data: unknown }) => void;
  /** Callback for errors */
  onError?: (error: Error) => void;
  /** Callback when reconnecting */
  onReconnect?: () => void;
  /**
   * Callback when the stream ends without a terminal event (silent death or
   * idle timeout). The caller should reconcile via the /status endpoint.
   */
  onStreamEnded?: () => void;
  /** Whether to auto-connect when jobId is set */
  autoConnect?: boolean;
}

interface UseBatchSSEReturn {
  /** Whether connected to SSE */
  isConnected: boolean;
  /** Current error if any */
  error: Error | null;
  /** Manually disconnect */
  disconnect: () => void;
  /** Manually reconnect */
  reconnect: () => void;
}

/**
 * Hook for managing SSE connection to batch processing jobs.
 */
export function useBatchSSE({
  jobId,
  onEvent,
  onError,
  onReconnect,
  onStreamEnded,
  autoConnect = true,
}: UseBatchSSEOptions): UseBatchSSEReturn {
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const disconnectRef = useRef<(() => void) | null>(null);
  const reconnectAttempts = useRef(0);
  const maxReconnects = 3;
  const reconnectTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const watchdogRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const lastEventAtRef = useRef(0);

  // Store callbacks in refs to avoid reconnecting on every callback change
  const onEventRef = useRef(onEvent);
  const onErrorRef = useRef(onError);
  const onReconnectRef = useRef(onReconnect);
  const onStreamEndedRef = useRef(onStreamEnded);

  useEffect(() => {
    onEventRef.current = onEvent;
    onErrorRef.current = onError;
    onReconnectRef.current = onReconnect;
    onStreamEndedRef.current = onStreamEnded;
  }, [onEvent, onError, onReconnect, onStreamEnded]);

  const connect = useCallback(() => {
    if (!jobId) return;

    // Clear any pending reconnect
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }

    // Disconnect existing connection
    if (disconnectRef.current) {
      disconnectRef.current();
      disconnectRef.current = null;
    }

    // Reset the idle watchdog
    if (watchdogRef.current) {
      clearInterval(watchdogRef.current);
      watchdogRef.current = null;
    }

    setError(null);
    lastEventAtRef.current = Date.now();

    const stopWatchdog = () => {
      if (watchdogRef.current) {
        clearInterval(watchdogRef.current);
        watchdogRef.current = null;
      }
    };

    // Shared path for any connection drop - a real error OR a silent stream
    // end with no terminal event. Try reconnecting (the backend replays the
    // terminal event if the job already finished); if reconnects are
    // exhausted, hand off to the caller to reconcile by polling /status.
    const handleDrop = (err: Error | null) => {
      setIsConnected(false);
      stopWatchdog();

      if (reconnectAttempts.current < maxReconnects) {
        reconnectAttempts.current++;
        const delay = 1000 * reconnectAttempts.current;

        reconnectTimeoutRef.current = setTimeout(() => {
          onReconnectRef.current?.();
          connect();
        }, delay);
      } else if (err) {
        setError(err);
        onErrorRef.current?.(err);
      } else {
        onStreamEndedRef.current?.();
      }
    };

    const disconnect = createAuthenticatedSSEConnection(
      jobId,
      (event) => {
        setIsConnected(true);
        reconnectAttempts.current = 0;
        lastEventAtRef.current = Date.now();
        onEventRef.current({
          type: event.type as BatchSSEEventType,
          data: event.data,
        });

        // Check for terminal events
        if (
          event.type === 'job_complete' ||
          event.type === 'job_failed' ||
          event.type === 'job_cancelled'
        ) {
          // Don't reconnect after terminal events
          setIsConnected(false);
          stopWatchdog();
        }
      },
      (err) => handleDrop(err),
      (sawTerminal) => {
        if (!sawTerminal) handleDrop(null);
      }
    );

    disconnectRef.current = disconnect;

    // Idle watchdog: the backend heartbeats every 30s, so 45s of silence means
    // a dead or hung connection. Abort the stream and use the same drop path
    // as a silent end so reconnect budget is shared (backend can replay the
    // terminal event). Abort does not fire onClose (signal.aborted), so this
    // will not double-call handleDrop.
    watchdogRef.current = setInterval(() => {
      if (Date.now() - lastEventAtRef.current > 45_000) {
        if (disconnectRef.current) {
          disconnectRef.current();
          disconnectRef.current = null;
        }
        handleDrop(null);
      }
    }, 15_000);
  }, [jobId]);

  const disconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }

    if (watchdogRef.current) {
      clearInterval(watchdogRef.current);
      watchdogRef.current = null;
    }

    if (disconnectRef.current) {
      disconnectRef.current();
      disconnectRef.current = null;
    }

    setIsConnected(false);
  }, []);

  const reconnect = useCallback(() => {
    reconnectAttempts.current = 0;
    connect();
  }, [connect]);

  // Auto-connect when jobId changes
  useEffect(() => {
    if (autoConnect && jobId) {
      connect();
    }

    return () => {
      disconnect();
    };
  }, [jobId, autoConnect, connect, disconnect]);

  return {
    isConnected,
    error,
    disconnect,
    reconnect,
  };
}

export default useBatchSSE;
