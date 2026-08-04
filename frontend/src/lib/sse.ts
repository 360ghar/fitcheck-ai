/**
 * Shared authenticated SSE client (fetch + ReadableStream parsing).
 *
 * Used by the batch extraction, photoshoot, and social import event streams.
 * Endpoint wrappers (api/batch.ts, api/socialImport.ts) supply the URL,
 * terminal event names, auth headers, and replay offsets; this module only
 * owns the wire protocol: `event:`/`id:`/`data:` line parsing, JSON payload
 * parsing, terminal-event tracking, and abort handling.
 */

export interface SSEMessage {
  type: string;
  data: unknown;
  /** Numeric `id:` line from the event, when present (used for replay offsets). */
  id?: number;
}

export interface SSEConnectionOptions {
  url: string;
  onMessage: (message: SSEMessage) => void;
  onError?: (error: Error) => void;
  /**
   * Called when the stream ends without an abort. `sawTerminal` is true when
   * a terminal event (from `terminalEvents`) was seen, letting callers detect
   * a silent stream death and reconcile via polling.
   */
  onClose?: (sawTerminal: boolean) => void;
  /** Event types that count as terminal for the `sawTerminal` flag. */
  terminalEvents?: ReadonlySet<string>;
  /** Extra headers, e.g. `{ Authorization: 'Bearer …' }`. */
  headers?: Record<string, string>;
  /** Last received event ID, sent to the server for replay on reconnect. */
  lastEventId?: number;
}

export function createSSEConnection(options: SSEConnectionOptions): () => void {
  const {
    url,
    onMessage,
    onError,
    onClose,
    terminalEvents = new Set(['job_complete', 'job_failed', 'job_cancelled']),
    headers = {},
  } = options;
  const controller = new AbortController();

  const connect = async () => {
    let sawTerminal = false;
    try {
      const response = await fetch(url, {
        headers: {
          Accept: 'text/event-stream',
          ...headers,
          ...(options.lastEventId != null
            ? { 'Last-Event-ID': String(options.lastEventId) }
            : {}),
        },
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new Error(`SSE connection failed: ${response.status}`);
      }

      const reader = response.body?.getReader();
      if (!reader) {
        throw new Error('No response body');
      }

      const decoder = new TextDecoder();
      let buffer = '';
      let currentEvent = '';
      let currentEventId = '';
      let dataLines: string[] = [];

      const dispatch = () => {
        if (!currentEvent && dataLines.length === 0) return;

        const payload = dataLines.join('\n');
        const type = currentEvent || 'message';
        if (terminalEvents.has(type)) sawTerminal = true;

        const numericId = Number(currentEventId);
        const message: SSEMessage = {
          type,
          data: null,
          ...(currentEventId !== '' && Number.isFinite(numericId) ? { id: numericId } : {}),
        };
        if (payload) {
          try {
            message.data = JSON.parse(payload);
          } catch {
            message.data = payload;
          }
        }
        onMessage(message);

        currentEvent = '';
        currentEventId = '';
        dataLines = [];
      };

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const rawLine of lines) {
          const line = rawLine.replace(/\r$/, '');

          if (line.startsWith('event:')) {
            currentEvent = line.slice(6).trim();
            continue;
          }

          if (line.startsWith('id:')) {
            currentEventId = line.slice(3).trim();
            continue;
          }

          if (line.startsWith('data:')) {
            dataLines.push(line.slice(5).trimStart());
            continue;
          }

          if (line === '') {
            dispatch();
          }
        }
      }

      dispatch();

      // Stream ended on its own. Tell the caller whether a terminal event was
      // seen so it can reconcile (poll /status) when the end was silent.
      if (!controller.signal.aborted) onClose?.(sawTerminal);
    } catch (error) {
      if ((error as Error).name !== 'AbortError') {
        onError?.(error as Error);
      }
    }
  };

  connect();

  return () => {
    controller.abort();
  };
}
