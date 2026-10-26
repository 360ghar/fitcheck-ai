/**
 * The design system for store creative: paper stocks, ink, type ramp, device
 * chrome, and the display types Apple actually accepts.
 *
 * Colour and paper behaviour are copied from the app's own tokens
 * (`flutter/lib/core/theme/paper_tokens.dart`, light), so a frame is cut from
 * the same five stocks the app is. A frame's background is the stock of the tab
 * whose screen it shows — the app's own rule, applied to the store.
 */

/** Paper stocks, light mode, verbatim from paper_tokens.dart. */
export const STOCKS = {
  ink: {
    page: '#E3E9F1',
    card: '#FBFCFD',
    sunk: '#D6DEE9',
    edge: '#C3CEDC',
    shadow: '#9FB0C6',
    accent: '#2E4A6E',
  },
  clay: {
    page: '#F1E0D6',
    card: '#FFFCFA',
    sunk: '#EAD2C4',
    edge: '#DDBFAE',
    shadow: '#C99A82',
    accent: '#8C4026',
  },
  moss: {
    page: '#E2E9DA',
    card: '#FCFDFA',
    sunk: '#D3DECA',
    edge: '#C0CEB3',
    shadow: '#9CB08C',
    accent: '#3F5E36',
  },
  marigold: {
    page: '#F5E6BF',
    card: '#FFFEFA',
    sunk: '#EEDBA6',
    edge: '#E0C987',
    shadow: '#CDA94F',
    accent: '#6E510C',
  },
  stone: {
    page: '#E7E6E1',
    card: '#FDFDFC',
    sunk: '#DCDBD5',
    edge: '#CAC9C2',
    shadow: '#ABAAA2',
    accent: '#3A3A35',
  },
};

export const INK = {
  primary: '#1C1B17',
  secondary: '#45433C',
  muted: '#5B5951',
  brand: '#E00016',
  brandSlab: '#9E0010',
  onBrand: '#FFFFFF',
};

/**
 * Apple's accepted screenshot geometry, as it exists in App Store Connect today.
 *
 * `display` is the App Store Connect API enum, not a human name. There is no
 * `APP_IPHONE_69`: the 6.9-inch Dynamic Island display is graded on the
 * long-standing `APP_IPHONE_67` row, which is why a set built against a guessed
 * `APP_IPHONE_69` fails to upload. The 6.5-inch row is `APP_IPHONE_65`.
 *
 * Verified 2026-10-26 against
 *   GET /v1/appStoreVersionLocalizations/{id}/appScreenshotSets   (live sets)
 *   GET /v1/appScreenshotSets/{id}/appScreenshots                 (live pixels)
 * and against Apple's screenshot specification reference.
 */
export const DEVICES = {
  69: {
    key: '69',
    dir: 'iphone-69',
    display: 'APP_IPHONE_67',
    label: 'iPhone 6.9" (Dynamic Island, large display) — iPhone 16/17 Pro Max class',
    size: [1320, 2868],
    accepted: [
      [1320, 2868],
      [1290, 2796],
      [1260, 2736],
    ],
    chrome: 'island',
    /** Aspect of the app screen that fills the device (source: 1284x2778). */
    screenAspect: 1284 / 2778,
  },
  65: {
    key: '65',
    dir: 'iphone-65',
    display: 'APP_IPHONE_65',
    label: 'iPhone 6.5" (Face ID, large display) — iPhone 13 Pro Max class',
    size: [1284, 2778],
    accepted: [
      [1284, 2778],
      [1242, 2688],
    ],
    chrome: 'notch',
    screenAspect: 1284 / 2778,
  },
};

/**
 * Non-screenshot creative. These are not uploadable App Store Connect assets;
 * they are the marketing surfaces the same pipeline produces, and the manifest
 * records them with the app-equivalent display type so an uploader knows to
 * skip them.
 */
export const SURFACES = {
  header: {
    kind: 'header',
    display: 'APP_HEADER_21X9',
    size: [3840, 1646],
    note: 'Product page hero, 21:9. Not an App Store Connect asset.',
  },
  search: {
    kind: 'search',
    display: 'APP_SEARCH_CARD_3X2',
    size: [2400, 1600],
    note: 'Search results card, 3:2. Not an App Store Connect asset.',
  },
  poster: {
    kind: 'poster',
    display: 'APP_IPHONE_67',
    size: [1290, 2796],
    note: 'App preview poster frame. Matches the 6.9" preview size Apple accepts (1080x1920 or 1290x2796).',
  },
};

/** Apple's cap for a screenshot/preview upload, in bytes (500 MB). */
export const MAX_IMAGE_BYTES = 500 * 1024 * 1024;

/**
 * Type ramp, in px on the 1320-wide 6.9" canvas. Everything scales with canvas
 * width so the 6.5" set is the same design at 97% — not a different design.
 */
export const TYPE = {
  headline: { max: 128, min: 84, lines: 3 },
  support: { max: 40, min: 32, lines: 2 },
  offerHeadline: { max: 100, min: 68, lines: 3 },
  offerChip: { size: 30 },
  offerRow: { size: 34, lines: 2 },
  header: {
    headline: { max: 172, min: 96, lines: 3 },
    support: { max: 52, min: 40, lines: 2 },
  },
  search: {
    headline: { max: 176, min: 120, lines: 2 },
    support: { max: 56, min: 44, lines: 1 },
  },
};

/** Grain opacity per stock: light papers take less texture than dark ones. */
export const GRAIN_OPACITY = 0.055;

/** Hard offset slab under paper, as a fraction of canvas width. Never a blur. */
export const SLAB = { x: 0.0115, y: 0.0165 };
