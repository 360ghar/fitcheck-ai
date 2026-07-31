/**
 * Replayable preview URLs for session recordings.
 *
 * PostHog session recording (rrweb) serializes the DOM — including `<img src>`
 * attributes — but a `blob:` object URL only exists inside the browser session
 * that created it. The replay player is a different context, so blob-based
 * previews render as blank/broken in recordings.
 *
 * Data URLs are self-contained in the recorded DOM, so previews built through
 * this helper survive replay. Uploads never go through preview URLs (they use
 * the `File` object), so downscaling here has zero effect on upload fidelity.
 *
 * Best-effort: any decode/encode failure (e.g. HEIC) falls back to a blob URL
 * (status quo) rather than blocking the preview.
 */

const SMALL_FILE_SKIP_BYTES = 200_000;
const MAX_EDGE = 512;
const JPEG_QUALITY = 0.8;

/**
 * Build a replay-safe preview (data URL) for an uploaded image file.
 *
 * Small files pass through untouched; larger files are downscaled to a JPEG
 * data URL (capped at ~512px longest edge) so the recorded DOM stays compact.
 * Returns a blob URL (status quo) only when encoding is impossible.
 */
export async function fileToReplayablePreview(file: File): Promise<string> {
  if (file.size <= SMALL_FILE_SKIP_BYTES && file.type.startsWith('image/')) {
    try {
      return await readAsDataUrl(file);
    } catch {
      // fall through to the canvas path (may still fail -> blob fallback)
    }
  }

  try {
    const source = await loadImage(file);
    // Always re-encode files above the small-file threshold — even when the
    // dimensions are already within bounds — so oversized payloads (animated
    // GIFs, huge-but-small PNGs) cannot bloat the recorded DOM as raw data
    // URLs. Only ≤200KB files pass through as raw data URLs above.
    const scale = Math.min(1, MAX_EDGE / Math.max(source.width, source.height));
    const width = Math.max(1, Math.round(source.width * scale));
    const height = Math.max(1, Math.round(source.height * scale));

    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    // jsdom returns null for getContext; real browsers return an object. A
    // null ctx means we cannot encode — fall back to a blob URL (status quo).
    // jsdom's canvas.toDataURL also returns null instead of throwing, so a
    // non-string result is treated as a failure too.
    const ctx = canvas.getContext('2d');
    if (!ctx) {
      if ('close' in source) source.close();
      return URL.createObjectURL(file);
    }

    // White background flattens transparency (JPEG has no alpha channel).
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, width, height);
    ctx.drawImage(source, 0, 0, width, height);
    if ('close' in source) source.close();

    const dataUrl = canvas.toDataURL('image/jpeg', JPEG_QUALITY);
    return typeof dataUrl === 'string' && dataUrl.startsWith('data:')
      ? dataUrl
      : URL.createObjectURL(file);
  } catch {
    return URL.createObjectURL(file);
  }
}

function readAsDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result as string);
    reader.onerror = () => reject(new Error('Failed to read file'));
    reader.readAsDataURL(file);
  });
}

async function loadImage(file: File): Promise<ImageBitmap | HTMLImageElement> {
  if (typeof createImageBitmap === 'function') {
    try {
      return await createImageBitmap(file);
    } catch {
      // fall through to <img>
    }
  }
  return new Promise((resolve, reject) => {
    const img = new Image();
    const url = URL.createObjectURL(file);
    const timer = setTimeout(() => {
      URL.revokeObjectURL(url);
      reject(new Error('Image decode timed out'));
    }, 10_000);
    img.onload = () => {
      clearTimeout(timer);
      URL.revokeObjectURL(url);
      resolve(img);
    };
    img.onerror = (e) => {
      clearTimeout(timer);
      URL.revokeObjectURL(url);
      reject(e);
    };
    img.src = url;
  });
}
