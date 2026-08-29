/**
 * Typed access to the ChatGPT Apps-SDK widget runtime (`window.openai`).
 *
 * Widgets run in an iframe inside ChatGPT: initial data arrives via
 * toolOutput (the tool's structuredContent), follow-ups and mutations go
 * through callTool (no direct API fetch, so no CORS surface), and theming
 * via `theme`. Everything degrades gracefully outside ChatGPT so the widget
 * can be previewed with `npm run dev`.
 */

export interface OpenAiWidgetApi {
  toolInput?: Record<string, unknown> | null;
  toolOutput?: unknown;
  toolResponseMetadata?: unknown;
  theme?: "light" | "dark" | "system" | null;
  callTool?: (name: string, args: Record<string, unknown>) => Promise<unknown>;
  setWidgetState?: (state: Record<string, unknown>) => Promise<void>;
  getWidgetState?: () => Promise<Record<string, unknown> | null>;
}

declare global {
  interface Window {
    openai?: OpenAiWidgetApi;
  }
}

export function widgetApi(): OpenAiWidgetApi {
  return window.openai ?? {};
}

/** The structuredContent the tool returned (already JSON, never a string). */
export function toolOutput<T>(): T | null {
  const output = widgetApi().toolOutput;
  return (output as T) ?? null;
}

export async function callTool(name: string, args: Record<string, unknown>): Promise<unknown> {
  const api = widgetApi();
  if (!api.callTool) throw new Error("callTool unavailable outside ChatGPT");
  return api.callTool(name, args);
}

export function useTheme(): "light" | "dark" {
  const theme = widgetApi().theme;
  if (theme === "dark") return "dark";
  if (theme === "light") return "light";
  if (typeof window !== "undefined" && window.matchMedia?.("(prefers-color-scheme: dark)").matches) {
    return "dark";
  }
  return "light";
}

/**
 * The API returns either a bare array, {data: [...]}, {items: [...]}, or a
 * standard response envelope such as {data: {items: [...]}}. Normalize so
 * widgets can consume both direct and enveloped list responses.
 */
export function extractList<T>(payload: unknown): T[] {
  if (Array.isArray(payload)) return payload as T[];
  if (payload && typeof payload === "object") {
    const record = payload as Record<string, unknown>;
    for (const key of ["data", "items", "outfits", "results"]) {
      const value = record[key];
      if (Array.isArray(value)) return value as T[];
    }
    const data = record.data;
    if (data && typeof data === "object") {
      for (const key of ["items", "outfits", "results"]) {
        const value = (data as Record<string, unknown>)[key];
        if (Array.isArray(value)) return value as T[];
      }
    }
  }
  return [];
}
