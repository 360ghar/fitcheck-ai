# Reliability

Status: draft  
Last updated: 2026-07-25

## Health and readiness

- `GET /health` reports liveness (and `rss_mb` + deploy `commit` SHA).
- `GET /ready` reports schema readiness.
- Startup should not block indefinitely on optional subsystems; see lifespan tests.

## Long-running AI jobs

- Batch extract, photoshoot, and social import use **job stores + SSE** rather than single multi-minute HTTP requests for multi-image work.
- Extract / generation concurrency caps (batch extraction service):
  - `EXTRACTION_SEMAPHORE = 3` (Agnes-style gateways 429/503 under parallel multi-MB vision POSTs)
  - `GENERATION_SEMAPHORE = 3` (caps peak base64 buffers on the single worker)
- Job memory caps exist—respect them when adding new in-memory job types (`test_job_memory_caps.py`).
- Photoshoot concurrency defaults to 2; reference photos are downscaled before gen to limit RAM.
- Railway single-worker process: OS `Killed` after AI bursts usually means OOM.
  - Code mitigations: downscale payloads, job caps, HTTP/1.1 AI client, lower AI semaphores, release base64 after use.
  - If kills continue after those: **raise Railway instance memory**.
  - Idle RSS above ~350 MB after completed jobs is a smell; check unreleased job maps / caches.

## AI providers

- Circuit/health behavior in `ai_provider_health_service`.
- Default chat `max_tokens` is **4096** (not multi-10k). Override per call if a path needs more.
- Chat and image paths retry transient HTTP statuses: **408, 429, 502, 503** (honor `Retry-After` when present).
- Permanent 4xx (auth, policy, bad model) set `AIServiceError(retryable=False)` and **fail fast** through outer `with_retry` via `is_retryable_error`.
- Image generation: primary → fallback model on transient errors; fail fast on policy/auth errors.
- AI HTTP client uses **HTTP/1.1**; `LocalProtocolError` / `RemoteProtocolError` rebuild the pooled client and retry.
- Prefer message text that includes `status=` + body snippet so Railway/log UIs that only show `message` still surface the cause.

## Rate limiting

- IP / request rate limit helpers exist; tests cover race and client IP extraction.
- Do not disable rate limits in production configs without a decision log entry.

## Client expectations

- Web: token refresh queue on 401; background job UI (`jobUiStore`) for multi-step AI.
- Duplicate checks: use `checkDuplicatesQueued` (3-slot concurrency queue) during batch save—not unbounded parallel embedding calls. Per-card one-shot keys live in `ExtractedItemCard`, not the queue itself.
- Empty wardrobe: server short-circuits `POST /items/check-duplicates` without embedding/Pinecone.
- Clients may save wardrobe items using original photos if studio images are still generating.

## Observability (agent legibility)

- Structured request logging + correlation IDs.
- Log files under `backend/logs/` for **local** agent debugging (not production).
- Production logs: Railway dashboard, or after `railway login`:
  ```bash
  cd backend && npx @railway/cli logs --since 24h
  ```
- No Dockerized local Prometheus/Loki stack in v1.
- Uvicorn writes INFO to stderr; Railway labels that `[err]`—startup lines are usually noise, not failures. Process `Killed` with no traceback is OOM.

## Failure modes to preserve

- Clear error JSON with codes for clients.
- SSE event streams should not silently die without a terminal error/complete event when the server knows the job failed.
