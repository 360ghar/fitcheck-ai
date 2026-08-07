/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL?: string
  readonly VITE_SENTRY_DSN?: string
  /** Feature-flag env vars — mirror entries in src/config/feature-flags.ts */
  readonly VITE_ENABLE_ADMIN_REFUNDS?: string
  readonly VITE_ENABLE_ADMIN_STORAGE_CLEANUP?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
