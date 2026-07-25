import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * Merge Tailwind CSS classes with proper precedence
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const dateFormatter = new Intl.DateTimeFormat('en-US', {
  month: 'short',
  day: 'numeric',
  year: 'numeric'
});

/**
 * Format a date to a human-readable string
 */
export function formatDate(date: string | Date): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return dateFormatter.format(d);
}

/**
 * Calculate cost per wear
 */
export function calculateCostPerWear(price: number, timesWorn: number): number {
  if (timesWorn === 0) return price;
  return price / timesWorn;
}

/**
 * Truncate text to a max length
 */
export function truncate(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength) + '…';
}

/**
 * Debounce function
 */
export function debounce<T extends (...args: unknown[]) => unknown>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout | null = null;

  return function executedFunction(...args: Parameters<T>) {
    const later = () => {
      timeout = null;
      func(...args);
    };

    if (timeout) {
      clearTimeout(timeout);
    }
    timeout = setTimeout(later, wait);
  };
}

/**
 * Generate a random ID
 */
export function generateId(): string {
  return Math.random().toString(36).substring(2) + Date.now().toString(36);
}

/**
 * Sleep for a specified duration
 */
export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Check if an object is empty
 */
export function isEmpty(obj: unknown): boolean {
  if (obj === null || obj === undefined) return true;
  if (Array.isArray(obj)) return obj.length === 0;
  if (typeof obj === 'object') return Object.keys(obj).length === 0;
  if (typeof obj === 'string') return obj.trim().length === 0;
  return false;
}

/**
 * Convert file to base64
 */
export function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result as string;
      resolve(result.split(',')[1]); // Remove data URL prefix
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

/**
 * Download a file from a URL
 */
export async function downloadFile(url: string, filename: string): Promise<void> {
  const response = await fetch(url);
  const blob = await response.blob();
  const downloadUrl = window.URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = downloadUrl;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  window.URL.revokeObjectURL(downloadUrl);
}

/**
 * Escape HTML special characters before building an innerHTML string from
 * user-authored text (e.g. markdown-to-HTML formatters using dangerouslySetInnerHTML).
 */
export function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/**
 * Block execution-capable URL schemes (javascript:, data:, vbscript:, etc.) in markdown
 * link targets. Scheme-less URLs (relative paths, protocol-relative, bare domains like
 * "example.com") are left untouched since browsers only ever navigate to them, never
 * execute them. Tabs/newlines are stripped first since browsers ignore them when parsing
 * a URL scheme, a known filter-bypass trick (e.g. "java\tscript:").
 */
export function sanitizeMarkdownUrl(url: string): string {
  const trimmed = url.trim().replace(/[\t\n\r]/g, '');
  if (/^[a-z][a-z0-9+.-]*:/i.test(trimmed) && !/^(https?|mailto|tel):/i.test(trimmed)) {
    return '#';
  }
  return trimmed;
}
