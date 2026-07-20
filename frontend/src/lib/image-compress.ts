/**
 * Client-side image compression for batch uploads.
 *
 * Full-resolution phone photos make the extraction POST enormous (up to
 * ~660MB of base64 for a 50-image batch). Downscaling the longest edge to
 * ~1568px and re-encoding as JPEG cuts that ~10x with no visible loss for
 * garment extraction.
 */

const DEFAULT_MAX_EDGE = 1568;
const DEFAULT_QUALITY = 0.85;
// Below this we don't bother re-encoding - already small enough.
const SKIP_BELOW_BYTES = 300_000;

/**
 * Return a downsized JPEG File for the given image file.
 *
 * Best-effort: returns the ORIGINAL file when it's already small, when
 * re-encoding wouldn't shrink it, or if anything throws. The raw upload path
 * still works with the original.
 */
export async function compressImageFile(
  file: File,
  maxEdge: number = DEFAULT_MAX_EDGE,
  quality: number = DEFAULT_QUALITY
): Promise<File> {
  if (file.size <= SKIP_BELOW_BYTES || !file.type.startsWith('image/')) {
    return file;
  }

  try {
    const bitmap = await loadImage(file);
    const scale = Math.min(1, maxEdge / Math.max(bitmap.width, bitmap.height));

    // Already within bounds - don't re-encode just to change bytes.
    if (scale >= 1) return file;

    const width = Math.round(bitmap.width * scale);
    const height = Math.round(bitmap.height * scale);

    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');
    if (!ctx) return file;

    // White background flattens transparency (JPEG has no alpha channel).
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, width, height);
    ctx.drawImage(bitmap, 0, 0, width, height);
    if ('close' in bitmap) bitmap.close();

    const blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob(resolve, 'image/jpeg', quality)
    );
    if (!blob || blob.size >= file.size) return file;

    const name = file.name.replace(/\.\w+$/, '') + '.jpg';
    return new File([blob], name, { type: 'image/jpeg' });
  } catch {
    // ponytail: best-effort - the original file still uploads fine.
    return file;
  }
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
    img.onload = () => {
      URL.revokeObjectURL(url);
      resolve(img);
    };
    img.onerror = (e) => {
      URL.revokeObjectURL(url);
      reject(e);
    };
    img.src = url;
  });
}
