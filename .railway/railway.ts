import {
  defineRailway,
  github,
  preserve,
  project,
  service,
} from "railway/iac";

// FitCheck AI — Railway Infrastructure as Code (backend only).
//
// Replaces the deprecated Config as Code file `backend/railway.json`
// (Railway stopped reading railway.json/railway.toml for new services on
// 2026-08-28; existing files go dark on 2026-12-01). A service cannot be
// managed by both systems, so `backend/railway.json` is deleted and the
// Service > Settings > Config File Path must be empty in the dashboard.
//
// Scope: backend only. The frontend stays on Netlify and the images worker
// lives on Cloudflare, so neither is declared here. WARNING: one file owns
// the whole environment — `apply` DELETES services omitted from this file.
// Run `railway config plan` first; if the plan proposes deleting a service
// you still need, stop and add it here before applying.
//
// Names must match the dashboard:
// - service("backend", ...) must equal the Railway service name. If your
//   dashboard service is named differently, rename it here, not there.
// - project("fitcheck-ai", ...) should equal the Railway project name.
//
// Build: Dockerfile (not Nixpacks). `backend/Dockerfile` is tuned for the
// 512 MB worker (multi-stage slim image, MALLOC arena caps, uvicorn
// --limit-concurrency 50) — re-declared here via builder/dockerfilePath
// because `railway config migrate` is known to drop those fields.
// No `startCommand`: the Dockerfile CMD already carries the tuned flags.

// Every env key backend/app reads (mirrors backend/.env.example; generated
// from `grep -oE '^[A-Z][A-Z0-9_]*=' backend/.env.example`, minus the
// platform-injected RAILWAY_GIT_COMMIT_SHA). preserve() means "keep the
// value already set in the Railway dashboard" — secrets never enter git.
// If a key is absent in Railway, preserve() is a no-op and it stays absent.
const PRESERVED_ENV_KEYS = [
  "SUPABASE_URL",
  "SUPABASE_PUBLISHABLE_KEY",
  "SUPABASE_SECRET_KEY",
  "SUPABASE_JWT_SECRET",
  "OBJECT_STORAGE_ENDPOINT",
  "OBJECT_STORAGE_REGION",
  "OBJECT_STORAGE_ACCESS_KEY_ID",
  "OBJECT_STORAGE_SECRET_ACCESS_KEY",
  "OBJECT_STORAGE_BUCKET",
  "OBJECT_STORAGE_PRESIGN_TTL",
  "PUBLIC_API_BASE_URL",
  "MCP_OAUTH_ISSUER",
  "MCP_JWT_SECRET",
  "MCP_REDIRECT_URI_ALLOWLIST",
  "IMAGE_SERVING_MODE",
  "IMAGE_CDN_BASE_URL",
  "THUMBNAIL_SERVING",
  "THUMBNAILS_BACKFILLED",
  "PINECONE_API_KEY",
  "PINECONE_INDEX_NAME",
  "PINECONE_DIMENSION",
  "AI_DEFAULT_PROVIDER",
  "AI_GEMINI_API_KEY",
  "AI_GEMINI_EMBEDDING_MODEL",
  "AI_GEMINI_CHAT_MODEL",
  "AI_GEMINI_VISION_MODEL",
  "AI_GEMINI_VISION_FALLBACK_MODEL",
  "AI_GEMINI_IMAGE_MODEL",
  "AI_GEMINI_IMAGE_FALLBACK_MODEL",
  "AI_OPENAI_API_URL",
  "AI_OPENAI_API_KEY",
  "AI_OPENAI_CHAT_MODEL",
  "AI_OPENAI_VISION_MODEL",
  "AI_OPENAI_IMAGE_MODEL",
  "AI_CHAT_API_URL",
  "AI_CHAT_API_KEY",
  "AI_CHAT_MODEL",
  "AI_VISION_PROVIDER",
  "AI_VISION_API_URL",
  "AI_VISION_API_KEY",
  "AI_VISION_MODEL",
  "AI_VISION_FALLBACK_API_URL",
  "AI_VISION_FALLBACK_API_KEY",
  "AI_VISION_FALLBACK_MODEL",
  "AI_IMAGE_API_URL",
  "AI_IMAGE_API_KEY",
  "AI_IMAGE_MODEL",
  "AI_IMAGE_FALLBACK_API_URL",
  "AI_IMAGE_FALLBACK_API_KEY",
  "AI_IMAGE_FALLBACK_MODEL",
  "AI_IMAGE_API_STYLE",
  "AGNES_AI_API_KEY",
  "AGNES_IMAGE_MODEL",
  "AGNES_VIDEO_MODEL",
  "AGNES_DAILY_IMAGE_LIMIT",
  "AGNES_DAILY_VIDEO_LIMIT",
  "AI_GEMINI_MAX_REQUESTS_PER_MINUTE",
  "AI_MAX_OUTPUT_TOKENS",
  "AI_DAILY_EXTRACTION_LIMIT",
  "AI_DAILY_GENERATION_LIMIT",
  "AI_DAILY_EMBEDDING_LIMIT",
  "AI_EXTRACTION_CONCURRENCY",
  "AI_GENERATION_CONCURRENCY",
  "AI_IMAGE_PROVIDER_CONCURRENCY",
  "AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE",
  "AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES",
  "AI_IMAGE_GEN_MAX_INPUT_IMAGES",
  "AI_OUTFIT_ITEM_REFERENCE_DOWNLOAD_CONCURRENCY",
  "IMAGE_PROCESS_WORKERS",
  "SSE_QUEUE_MAX_BUFFERED_BYTES",
  "AI_MAX_OUTFIT_ITEMS",
  "AI_OUTFIT_SOURCE_REFERENCE_MAX_IMAGES",
  "AI_OUTFIT_SOURCE_REFERENCE_MIN_SHARED_ITEMS",
  "AI_ENCRYPTION_KEY",
  "DEBUG",
  "FRONTEND_URL",
  "ENABLE_SOCIAL_IMPORT",
  "ENABLE_GAMIFICATION",
  "SOCIAL_IMPORT_MAX_CONCURRENT_JOBS",
  "SOCIAL_IMPORT_MAX_PHOTOS_PER_JOB",
  "SOCIAL_IMPORT_AUTH_SESSION_TTL_MINUTES",
  "SOCIAL_IMPORT_DISCOVERY_PAGE_SIZE",
  "META_OAUTH_CLIENT_ID",
  "META_OAUTH_CLIENT_SECRET",
  "WEATHER_API_KEY",
  "BACKEND_CORS_ORIGINS",
  "BACKEND_CORS_ORIGIN_REGEX",
  "STRIPE_SECRET_KEY",
  "STRIPE_WEBHOOK_SECRET",
  "STRIPE_PLUS_MONTHLY_PRICE_ID",
  "STRIPE_PLUS_YEARLY_PRICE_ID",
  "STRIPE_PRO_MONTHLY_PRICE_ID",
  "STRIPE_PRO_YEARLY_PRICE_ID",
  "STRIPE_GIFT_PRO_1M_PRICE_ID",
  "STRIPE_GIFT_PRO_3M_PRICE_ID",
  "STRIPE_GIFT_PRO_12M_PRICE_ID",
  "GIFT_TOKEN_SECRET",
  "ENABLE_GIFT_VOUCHER_CREATION",
  "APPLE_BUNDLE_ID",
  "APPLE_ISSUER_ID",
  "APPLE_KEY_ID",
  "APPLE_PRIVATE_KEY",
  "APPLE_ENV",
  "GOOGLE_PACKAGE_NAME",
  "GOOGLE_SERVICE_ACCOUNT_JSON",
  "GOOGLE_RTDN_AUDIENCE",
  "PLAN_FREE_MONTHLY_EXTRACTIONS",
  "PLAN_FREE_MONTHLY_GENERATIONS",
  "PLAN_FREE_MONTHLY_EMBEDDINGS",
  "PLAN_PLUS_MONTHLY_EXTRACTIONS",
  "PLAN_PLUS_MONTHLY_GENERATIONS",
  "PLAN_PLUS_MONTHLY_EMBEDDINGS",
  "PLAN_PRO_MONTHLY_EXTRACTIONS",
  "PLAN_PRO_MONTHLY_GENERATIONS",
  "PLAN_PRO_MONTHLY_EMBEDDINGS",
  "PLAN_PLUS_MONTHLY_PRICE",
  "PLAN_PLUS_YEARLY_PRICE",
  "PLAN_PRO_MONTHLY_PRICE",
  "PLAN_PRO_YEARLY_PRICE",
  "PLAN_FREE_DAILY_PHOTOSHOOT_IMAGES",
  "PLAN_PLUS_DAILY_PHOTOSHOOT_IMAGES",
  "PLAN_PRO_DAILY_PHOTOSHOOT_IMAGES",
  "PHOTOSHOOT_CONCURRENCY_LIMIT",
  "REFERRAL_CREDIT_MONTHS",
  "RESEND_API_KEY",
  "FROM_EMAIL",
  "REFERRAL_BASE_URL",
  "LOG_LEVEL",
  "LOG_DIR",
  "SENTRY_DSN",
  "SENTRY_TRACES_SAMPLE_RATE",
] as const;

export default defineRailway(() => {
  const backend = service("backend", {
    source: github("360ghar/fitcheck-ai", {
      branch: "main",
      rootDirectory: "backend",
    }),
    build: {
      builder: "DOCKERFILE",
      dockerfilePath: "Dockerfile",
    },
    deploy: {
      healthcheckPath: "/health",
      healthcheckTimeout: 300,
      restartPolicyType: "ON_FAILURE",
      restartPolicyMaxRetries: 10,
    },
    env: Object.fromEntries(
      PRESERVED_ENV_KEYS.map((key) => [key, preserve()]),
    ),
  });

  return project("fitcheck-ai", {
    resources: [backend],
  });
});
