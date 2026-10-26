/**
 * Every path the creative pipeline touches, resolved once.
 *
 * Nothing is hard-coded to a machine: the repo root comes from this file's own
 * location, so a checkout anywhere renders the same images.
 */
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export const HERE = dirname(fileURLToPath(import.meta.url));
export const SCRIPT_DIR = join(HERE, '..');
export const ROOT = join(SCRIPT_DIR, '..', '..');

/** Source of truth we read and never write. */
export const STORE_ASC = join(ROOT, 'store', 'asc');

/** Everything this pipeline owns. */
export const OUT = join(ROOT, 'store', 'creative');
export const FRAMES = join(OUT, 'frames');
export const HEADER = join(OUT, 'header');
export const SEARCH = join(OUT, 'search');
export const PREVIEW = join(OUT, 'preview');
export const MANIFEST = join(OUT, 'manifest.json');

/** Inputs committed to the repo. */
export const SOURCE = join(OUT, 'source');
export const SCREENS = join(SOURCE, 'screens');
export const ART = join(SOURCE, 'art');
export const FONTS = join(OUT, 'fonts');
export const COPY = join(OUT, 'copy.json');
export const FONT_INDEX = join(FONTS, 'index.json');

/** Render cache: gitignored, safe to delete. */
export const CACHE = join(OUT, '.cache');

/** Repo assets reused as-is (read-only). */
export const BASETELEUR_BOLD = join(ROOT, 'flutter', 'assets', 'fonts', 'Basteleur-Bold.otf');
export const BASETELEUR_MOON = join(ROOT, 'flutter', 'assets', 'fonts', 'Basteleur-Moonlight.otf');
export const INTER = join(ROOT, 'frontend', 'public', 'fonts', 'inter-latin-var.woff2');
export const GRAIN = join(ROOT, 'frontend', 'public', 'paper', 'grain-light.webp');
export const TEAR = join(ROOT, 'frontend', 'public', 'paper', 'tear.svg');
export const BRAND_MARK = join(ROOT, 'frontend', 'public', 'brand-mark.svg');

/** A `file://` URL Chromium will accept for a local asset. */
export function fileUrl(path) {
  const encoded = path.split('/').map((part) => encodeURIComponent(part)).join('/');
  return `file://${encoded}`;
}
