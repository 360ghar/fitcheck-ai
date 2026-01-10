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
  autoConnect = true,
}: UseBatchSSEOptions): UseBatchSSEReturn {
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const disconnectRef = useRef<(() => void) | null>(null);
  const reconnectAttempts = useRef(0);
  const maxReconnects = 3;
  const reconnectTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Store callbacks in refs to avoid reconnecting on every callback change
  const onEventRef = useRef(onEvent);
  const onErrorRef = useRef(onError);
  const onReconnectRef = useRef(onReconnect);

  useEffect(() => {
    onEventRef.current = onEvent;
    onErrorRef.current = onError;
    onReconnectRef.current = onReconnect;
  }, [onEvent, onError, onReconnect]);

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

    setError(null);

    const disconnect = createAuthenticatedSSEConnection(
      jobId,
      (event) => {
        setIsConnected(true);
        reconnectAttempts.current = 0;
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
        }
      },
      (err) => {
        setIsConnected(false);

        if (reconnectAttempts.current < maxReconnects) {
          reconnectAttempts.current++;
          const delay = 1000 * reconnectAttempts.current;

          reconnectTimeoutRef.current = setTimeout(() => {
            onReconnectRef.current?.();
            connect();
          }, delay);
        } else {
          setError(err);
          onErrorRef.current?.(err);
        }
      }
    );

    disconnectRef.current = disconnect;
  }, [jobId]);

  const disconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
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
