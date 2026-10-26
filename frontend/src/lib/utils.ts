import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import { imageFetchOptions } from './sessionCookie';
import {
  formatCurrencyFromCents as formatCurrencyFromCentsLocalized,
  formatDate as formatDateLocalized,
} from '@/i18n/runtime';

/**
 * Merge Tailwind CSS classes with proper precedence
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Format a date to a human-readable string in the active locale.
 *
 * These three helpers used to pin `'en-US'`. That is the whole bug: a French
 * user saw "Mar 4, 2025" and a Japanese user saw a US date order, because the
 * `Intl` instance was frozen at module load with the wrong locale. They now
 * delegate to `i18n/runtime`, which reads the active locale at call time — so a
 * language switch changes the output of an already-mounted component on its next
 * render, without threading a locale argument through two hundred call sites.
 */
export function formatDate(date: string | Date): string {
  return formatDateLocalized(date);
}

/**
 * Format a cents amount as localized whole-currency USD ("$13", "13 $US").
 *
 * The currency is USD because that is what Stripe charges; only the *format* is
 * localized. Rendering a USD amount in the user's local currency would be a
 * pricing change, not a translation.
 */
export function formatUsd(cents: number): string {
  return formatCurrencyFromCentsLocalized(cents);
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
 * Trigger a browser download for an in-memory Blob, then release the object
 * URL so the blob is not pinned in memory for the life of the page.
 */
export function downloadBlob(blob: Blob, filename: string): void {
  const objectUrl = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = objectUrl;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(objectUrl);
}

/**
 * Download a file from a URL
 */
export async function downloadFile(url: string, filename: string): Promise<void> {
  const response = await fetch(url, imageFetchOptions(url));
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
