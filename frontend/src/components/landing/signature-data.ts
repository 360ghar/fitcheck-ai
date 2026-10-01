/**
 * Data for the landing signature ("Snap your closet once").
 *
 * Produced once, on 2026-10-01, by running FitCheck's own pipeline on
 * /signature/pile-*.webp (an AI-generated example photo):
 *   - ItemExtractionAgent.extract_multiple_items -> category, sub_category,
 *     colors, material, pattern, bounding_box (percent of the photo).
 *   - ImageGenerationAgent.generate_product_image -> each cut-out. The tee,
 *     the striped top and the trousers were rendered on a chroma backdrop and
 *     keyed: the white-backdrop threshold matte keeps white backgrounds and
 *     cast shadows (documented in backend/app/utils/background_removal.py).
 *     The jacket and sweater had their cast-shadow halo removed.
 *   - ImageGenerationAgent.generate_outfit -> /signature/outfit-*.webp from
 *     the tee, trousers and sneakers cut-outs.
 * Labels below are the extraction output verbatim, except for capitalisation.
 * See docs/exec-plans/active/2026-10-01-paper-studio-landing.md.
 */

export interface SignatureItem {
  key: string
  name: string
  colors: string
  /** Colour chip next to the name; the median colour of the cut-out. */
  swatch: string
  /** Where the garment lies in the pile photo, percent of the photo. */
  box: { x: number; y: number; w: number; h: number }
  width: number
  height: number
  inOutfit: boolean
}

// theme-static: garment colour swatches are data about the photo, not theme surfaces
export const SIGNATURE_ITEMS: SignatureItem[] = [
  { key: 'jacket', name: 'Denim jacket', colors: 'Blue, light blue', swatch: '#7392a6', box: { x: 9.8, y: 7.8, w: 31.4, h: 57.8 }, width: 438, height: 460, inOutfit: false },
  { key: 'tee', name: 'T-shirt', colors: 'White', swatch: '#f2f1ed', box: { x: 32.1, y: 8.1, w: 30.2, h: 33.4 }, width: 460, height: 480, inOutfit: true },
  { key: 'stripe', name: 'Long sleeve shirt', colors: 'White, black, navy', swatch: '#27304a', box: { x: 49.3, y: 9.7, w: 42.7, h: 38.6 }, width: 390, height: 480, inOutfit: false },
  { key: 'sweater', name: 'Sweater', colors: 'Yellow, mustard', swatch: '#a87526', box: { x: 51.0, y: 31.2, w: 43.1, h: 66.2 }, width: 426, height: 470, inOutfit: false },
  { key: 'trousers', name: 'Trousers', colors: 'Brown, orange', swatch: '#994a27', box: { x: 21.0, y: 38.0, w: 44.2, h: 62.0 }, width: 187, height: 480, inOutfit: true },
  { key: 'sneakers', name: 'Sneakers', colors: 'White', swatch: '#efeee9', box: { x: 19.5, y: 56.2, w: 20.0, h: 32.8 }, width: 479, height: 290, inOutfit: true },
]

/*
 * Stage geometry, in cqw of the stage (the stage is 100 x 40 cqw on wide
 * screens). The end layout is the default render; the scroll animation
 * starts from the "start" values and settles on it.
 */
export const STAGE = {
  /* The default (end) photo frame; the start frame lives in CSS. */
  photoStart: { x: 24, y: 0.5, w: 52, h: 39 },
  /* .sig-photo padding and the start-frame scale in index.css. */
  photoPad: 0.45,
  photoStartScale: 1.4444,
  grid: { x: 40, y: 4.5, cellW: 10.6, cellH: 13.5, gapX: 1.2, gapY: 1, cols: 3 },
  /* The cut-out sits in the top part of its cell; the label sits below. */
  cut: { padX: 0.9, padTop: 0.8, h: 9 },
} as const

/** Start offset of one cut-out: from over its garment in the big photo to its cell. */
export function cutoutStart(item: SignatureItem, index: number) {
  const { photoStart: p, grid: g, cut } = STAGE
  const col = index % g.cols
  const row = Math.floor(index / g.cols)
  const cellX = g.x + col * (g.cellW + g.gapX)
  const cellY = g.y + row * (g.cellH + g.gapY)
  const cutW = g.cellW - cut.padX * 2
  const endCx = cellX + g.cellW / 2
  const endCy = cellY + cut.padTop + cut.h / 2
  // The garment boxes are percentages of the bare photo; the img sits inside
  // .sig-photo's padding, and the start frame scales the whole figure. Use
  // the img box as seen at the start frame, or the cut-outs lift off target.
  const inset = STAGE.photoPad * STAGE.photoStartScale
  const imgBox = { x: p.x + inset, y: p.y + inset, w: p.w - inset * 2, h: p.h - inset * 2 }
  const startCx = imgBox.x + (imgBox.w * (item.box.x + item.box.w / 2)) / 100
  const startCy = imgBox.y + (imgBox.h * (item.box.y + item.box.h / 2)) / 100
  // object-fit: contain inside a cutW x cut.h box
  const fit = Math.min(cutW / item.width, cut.h / item.height)
  const drawnW = item.width * fit
  const drawnH = item.height * fit
  // min, so the lifted cut-out never pokes out past its garment in the photo
  const scale = Math.min(
    (imgBox.w * item.box.w) / 100 / drawnW,
    (imgBox.h * item.box.h) / 100 / drawnH,
  )
  const round = (n: number) => Math.round(n * 100) / 100
  return { dx: round(startCx - endCx), dy: round(startCy - endCy), scale: round(scale) }
}
