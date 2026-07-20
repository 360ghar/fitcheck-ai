/**
 * Crop a region from an image using bounding-box percentages (0–100).
 * Used to show per-item previews immediately after extraction, before studio photos finish.
 */

export interface BoundingBoxPercent {
  x: number
  y: number
  width: number
  height: number
}

export interface CropOptions {
  /** Extra padding around the box as a fraction of box size (default 0.1 = 10%) */
  paddingFraction?: number
  /** Output MIME type */
  mimeType?: string
  /** JPEG/WebP quality when applicable */
  quality?: number
  /** Max edge length of the cropped result (keeps memory low) */
  maxEdge?: number
}

function clamp(n: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, n))
}

/**
 * Normalize a bounding box to {x,y,width,height} percentages 0–100.
 * Clamps into the image frame and rescales legacy 0–1000 rows.
 * Returns null if the box is unusable.
 */
export function normalizeBoundingBoxPercent(
  box: Partial<BoundingBoxPercent> | null | undefined
): BoundingBoxPercent | null {
  if (!box) return null

  let x = Number(box.x)
  let y = Number(box.y)
  let w = Number(box.width)
  let h = Number(box.height)

  if (![x, y, w, h].every((n) => Number.isFinite(n))) return null

  // The API contract is percent 0–100 (the backend normalizer owns the
  // conversion). The only foreign scale worth fixing up client-side is
  // legacy rows stored as 0–1000 (Gemini style). Values slightly above 100
  // are percent overflow and the clamp below pulls them back in-frame —
  // they must NOT be shrunk. And never multiply sub-1 values by 100: a
  // legitimate sub-1% box (a tiny accessory) became a near-full-frame crop.
  const maxV = Math.max(Math.abs(x), Math.abs(y), Math.abs(w), Math.abs(h))
  if (maxV > 150) {
    x *= 0.1
    y *= 0.1
    w *= 0.1
    h *= 0.1
  }

  x = clamp(x, 0, 100)
  y = clamp(y, 0, 100)
  w = clamp(w, 0, 100 - x)
  h = clamp(h, 0, 100 - y)

  if (w < 1 || h < 1) return null

  return {
    x: Math.round(x * 100) / 100,
    y: Math.round(y * 100) / 100,
    width: Math.round(w * 100) / 100,
    height: Math.round(h * 100) / 100,
  }
}

function loadImage(source: string | Blob | File): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.crossOrigin = 'anonymous'
    img.onload = () => resolve(img)
    img.onerror = () => reject(new Error('Failed to load image for crop'))

    if (typeof source === 'string') {
      img.src = source
    } else {
      img.src = URL.createObjectURL(source)
    }
  })
}

/**
 * Crop `source` using a percentage bounding box and return a data URL.
 * Pads the box slightly so tight detections are not clipped.
 */
export async function cropImageFromBoundingBox(
  source: string | Blob | File,
  box: BoundingBoxPercent,
  options: CropOptions = {}
): Promise<string> {
  const {
    paddingFraction = 0.1,
    mimeType = 'image/jpeg',
    quality = 0.85,
    maxEdge = 512,
  } = options

  const img = await loadImage(source)
  const objectUrl =
    typeof source !== 'string' ? (img.src.startsWith('blob:') ? img.src : null) : null

  try {
    const imgW = img.naturalWidth || img.width
    const imgH = img.naturalHeight || img.height
    if (!imgW || !imgH) {
      throw new Error('Image has no dimensions')
    }

    const normalized = normalizeBoundingBoxPercent(box)
    if (!normalized) {
      throw new Error('Invalid bounding box')
    }
    const { x, y, width: w, height: h } = normalized

    const padX = w * paddingFraction
    const padY = h * paddingFraction

    const leftPct = clamp(x - padX, 0, 100)
    const topPct = clamp(y - padY, 0, 100)
    const rightPct = clamp(x + w + padX, 0, 100)
    const bottomPct = clamp(y + h + padY, 0, 100)

    const sx = (leftPct / 100) * imgW
    const sy = (topPct / 100) * imgH
    const sw = ((rightPct - leftPct) / 100) * imgW
    const sh = ((bottomPct - topPct) / 100) * imgH

    if (sw < 2 || sh < 2) {
      throw new Error('Crop region too small')
    }

    let outW = sw
    let outH = sh
    if (Math.max(outW, outH) > maxEdge) {
      const scale = maxEdge / Math.max(outW, outH)
      outW = Math.round(outW * scale)
      outH = Math.round(outH * scale)
    } else {
      outW = Math.round(outW)
      outH = Math.round(outH)
    }

    const canvas = document.createElement('canvas')
    canvas.width = outW
    canvas.height = outH
    const ctx = canvas.getContext('2d')
    if (!ctx) {
      throw new Error('Canvas not available')
    }
    ctx.drawImage(img, sx, sy, sw, sh, 0, 0, outW, outH)

    return canvas.toDataURL(mimeType, quality)
  } finally {
    if (objectUrl) {
      URL.revokeObjectURL(objectUrl)
    }
  }
}
