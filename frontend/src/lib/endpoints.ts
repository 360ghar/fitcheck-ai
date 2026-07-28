/**
 * Centralized API endpoint constants.
 *
 * All backend route paths live here so call sites reference `ENDPOINTS.*`
 * instead of string-literal drift. The Axios client and per-domain API
 * modules import from this file. `as const` is preserved so consumers get
 * literal string types for static analysis.
 *
 * NOTE: Dynamic path segments (e.g. `/{id}`) are appended at the call site
 * using the matching `*_BASE` constant via template literals.
 */

export const ENDPOINTS = {
  AUTH: {
    LOGIN: '/api/v1/auth/login',
    REGISTER: '/api/v1/auth/register',
    REFRESH: '/api/v1/auth/refresh',
    RESET_PASSWORD: '/api/v1/auth/reset-password',
    CONFIRM_RESET_PASSWORD: '/api/v1/auth/confirm-reset-password',
    LOGOUT: '/api/v1/auth/logout',
    OAUTH_SYNC: '/api/v1/auth/oauth/sync',
  },
  AI: {
    EXTRACT_ITEMS: '/api/v1/ai/extract-items',
    EXTRACT_SINGLE_ITEM: '/api/v1/ai/extract-single-item',
    GENERATE_OUTFIT: '/api/v1/ai/generate-outfit',
    GENERATE_PRODUCT_IMAGE: '/api/v1/ai/generate-product-image',
    TRY_ON: '/api/v1/ai/try-on',
    BATCH_EXTRACT_MULTIPART: '/api/v1/ai/batch-extract-multipart',
    BATCH_EXTRACT_BASE: '/api/v1/ai/batch-extract',
    SOCIAL_IMPORT_JOBS: '/api/v1/ai/social-import/jobs',
    CHAT: '/api/v1/ai/chat',
    SETTINGS: '/api/v1/ai/settings',
    SETTINGS_TEST: '/api/v1/ai/settings/test',
    EMBEDDINGS: '/api/v1/ai/embeddings',
    EMBEDDINGS_BATCH: '/api/v1/ai/embeddings/batch',
    EMBEDDINGS_SEARCH: '/api/v1/ai/embeddings/search',
  },
  USERS: {
    ME: '/api/v1/users/me',
    PREFERENCES: '/api/v1/users/preferences',
    SETTINGS: '/api/v1/users/settings',
    AVATAR: '/api/v1/users/me/avatar',
  },
  ITEMS: {
    BASE: '/api/v1/items',
    UPLOAD: '/api/v1/items/upload',
    BATCH_DELETE: '/api/v1/items/batch-delete',
    CHECK_DUPLICATES: '/api/v1/items/check-duplicates',
  },
  OUTFITS: {
    BASE: '/api/v1/outfits',
    AVAILABLE_ITEMS: '/api/v1/outfits/available-items',
    BATCH_DELETE: '/api/v1/outfits/batch-delete',
  },
  SUBSCRIPTION: {
    BASE: '/api/v1/subscription',
    USAGE: '/api/v1/subscription/usage',
    PLANS: '/api/v1/subscription/plans',
    CHECKOUT: '/api/v1/subscription/checkout',
    PORTAL: '/api/v1/subscription/portal',
    CANCEL: '/api/v1/subscription/cancel',
  },
  REFERRAL: {
    CODE: '/api/v1/referral/code',
    STATS: '/api/v1/referral/stats',
    VALIDATE: '/api/v1/referral/validate',
  },
  PHOTOSHOOT: {
    USAGE: '/api/v1/photoshoot/usage',
    GENERATE: '/api/v1/photoshoot/generate',
    DEMO: '/api/v1/photoshoot/demo',
  },
  RECOMMENDATIONS: {
    MATCH: '/api/v1/recommendations/match',
    COMPLETE_LOOK: '/api/v1/recommendations/complete-look',
    WEATHER: '/api/v1/recommendations/weather',
    ASTROLOGY: '/api/v1/recommendations/astrology',
    SHOPPING: '/api/v1/recommendations/shopping',
  },
  GAMIFICATION: {
    STREAK: '/api/v1/gamification/streak',
    ACHIEVEMENTS: '/api/v1/gamification/achievements',
    LEADERBOARD: '/api/v1/gamification/leaderboard',
  },
  CALENDAR: {
    CONNECT: '/api/v1/calendar/connect',
    EVENTS: '/api/v1/calendar/events',
  },
  BLOG: {
    POSTS: '/api/v1/blog/posts',
    CATEGORIES: '/api/v1/blog/categories',
    ADMIN_POSTS: '/api/v1/blog/admin/posts',
  },
  FEEDBACK: {
    BASE: '/api/v1/feedback',
    MY_TICKETS: '/api/v1/feedback/my-tickets',
  },
  WAITLIST: {
    JOIN: '/api/v1/waitlist/join',
  },
  DEMO: {
    EXTRACT_ITEMS: '/api/v1/demo/extract-items',
    TRY_ON: '/api/v1/demo/try-on',
  },
} as const;

/**
 * URL prefixes that map to long-running AI/batch operations. Requests matching
 * one of these get the extended Axios timeout automatically (see client.ts).
 *
 * Derived from the AI endpoints so the two never drift apart.
 */
export const LONG_RUNNING_PREFIXES = [
  ENDPOINTS.AI.EXTRACT_ITEMS,
  ENDPOINTS.AI.EXTRACT_SINGLE_ITEM,
  ENDPOINTS.AI.GENERATE_OUTFIT,
  ENDPOINTS.AI.GENERATE_PRODUCT_IMAGE,
  ENDPOINTS.AI.TRY_ON,
  ENDPOINTS.AI.BATCH_EXTRACT_MULTIPART,
  ENDPOINTS.PHOTOSHOOT.GENERATE,
] as const;
