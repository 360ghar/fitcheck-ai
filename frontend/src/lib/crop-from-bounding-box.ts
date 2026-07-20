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

    // Normalize box (API may send 0–1 or 0–100)
    let x = box.x
    let y = box.y
    let w = box.width
    let h = box.height
    if (x <= 1 && y <= 1 && w <= 1 && h <= 1) {
      x *= 100
      y *= 100
      w *= 100
      h *= 100
    }

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
