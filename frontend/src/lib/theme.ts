export type Theme = 'light' | 'dark' | 'system';
export type ResolvedTheme = 'light' | 'dark';

const THEME_STORAGE_KEY = 'fitcheck-theme';

export const THEMES: { value: Theme; label: string }[] = [
  { value: 'light', label: 'Light' },
  { value: 'dark', label: 'Dark' },
  { value: 'system', label: 'System' },
];

/**
 * Get the system color scheme preference
 */
export function getSystemTheme(): ResolvedTheme {
  if (typeof window === 'undefined') return 'light';
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

/**
 * Resolve theme to actual light/dark value
 */
export function resolveTheme(theme: Theme): ResolvedTheme {
  if (theme === 'system') {
    return getSystemTheme();
  }
  return theme;
}

/** Resolved `--background` per theme, used for the browser/PWA status bar. */
const THEME_COLOR: Record<ResolvedTheme, string> = {
  light: '#ffffff',
  dark: '#1b1b18',
};

/**
 * The two `<meta name="theme-color">` tags in index.html are gated on
 * `prefers-color-scheme`, so they ignore an explicit in-app override. Flip
 * their `media` attributes so the tag matching the resolved theme is the one
 * the browser honours.
 */
function applyThemeColorMeta(theme: ResolvedTheme): void {
  const metas = document.head.querySelectorAll<HTMLMetaElement>(
    'meta[name="theme-color"]'
  );
  if (metas.length === 0) return;
  if (metas.length === 1) {
    metas[0].setAttribute('content', THEME_COLOR[theme]);
    return;
  }
  metas.forEach((meta) => {
    const isMatch = meta.getAttribute('content') === THEME_COLOR[theme];
    meta.setAttribute('media', isMatch ? 'all' : 'not all');
  });
}

/**
 * Apply theme to document
 */
export function applyTheme(theme: ResolvedTheme): void {
  const root = document.documentElement;
  root.classList.remove('light', 'dark');
  root.classList.add(theme);
  applyThemeColorMeta(theme);
}

/**
 * Get theme from localStorage
 */
export function getStoredTheme(): Theme | null {
  if (typeof window === 'undefined') return null;
  const stored = localStorage.getItem(THEME_STORAGE_KEY);
  if (stored === 'light' || stored === 'dark' || stored === 'system') {
    return stored;
  }
  return null;
}

/**
 * Store theme in localStorage
 */
export function storeTheme(theme: Theme): void {
  localStorage.setItem(THEME_STORAGE_KEY, theme);
}
