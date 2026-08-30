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

function record(value: unknown): Record<string, unknown> | null {
  return value && typeof value === "object" ? value as Record<string, unknown> : null;
}

export function extractItems<T>(payload: unknown): T[] {
  if (Array.isArray(payload)) return payload as T[];
  const root = record(payload);
  if (!root) return [];
  if (Array.isArray(root.data)) return root.data as T[];
  if (Array.isArray(root.items)) return root.items as T[];
  if (Array.isArray(root.results)) return root.results as T[];
  const data = record(root.data);
  if (data && Array.isArray(data.items)) {
    return data.items as T[];
  }
  if (data && Array.isArray(data.results)) {
    return data.results as T[];
  }
  return [];
}

export function extractOutfits<T>(payload: unknown): T[] {
  if (Array.isArray(payload)) return payload as T[];
  const root = record(payload);
  if (!root) return [];
  // A direct single-outfit response has an id and its nested items are
  // clothing, not a list of outfit cards.
  if (typeof root.id === "string" || typeof root.id === "number") {
    return [root as T];
  }
  if (Array.isArray(root.outfits)) return root.outfits as T[];
  if (Array.isArray(root.data)) return root.data as T[];
  const data = record(root.data);
  if (!data) return [];
  if (Array.isArray(data.outfits)) return data.outfits as T[];
  return [data as T];
}

export function firstImageUrl(value: unknown): string | null {
  const root = record(value);
  if (!root) return null;
  if (typeof root.image_url === "string" && root.image_url) {
    return root.image_url;
  }
  if (!Array.isArray(root.images)) return null;
  for (const image of root.images) {
    const entry = record(image);
    if (!entry) continue;
    if (typeof entry.thumbnail_url === "string" && entry.thumbnail_url) {
      return entry.thumbnail_url;
    }
    if (typeof entry.image_url === "string" && entry.image_url) {
      return entry.image_url;
    }
  }
  return null;
}
