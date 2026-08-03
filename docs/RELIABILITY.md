# Reliability

Status: draft  
Last updated: 2026-07-31

The [user-story ledger](./product-specs/user-story-ledger.md) is the source of
truth for verification status. Current tests are primarily unit/service/widget
tests; they do not prove hosted Supabase, proxy buffering, external-provider,
Stripe, browser-E2E, mobile integration, or production-load behavior.

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
  - 2026-08-03 deep pass (see `docs/exec-plans/active/2026-08-03-512mb-memory-budget.md`):
    - `/health` and `log_memory` report **current RSS** (`VmRSS` from
      `/proc/self/status`; getrusage fallback on macOS) — `ru_maxrss` was the
      all-time peak and never decreased, so it hid whether memory actually
      returned to baseline.
    - CPU-bound image work (downscale, bbox crop, matte, storage validation)
      runs on a **bounded executor** (`app/core/image_executor.py`,
      `IMAGE_PROCESS_WORKERS`, default 4). `asyncio.to_thread` uses the
      default pool sized to host cores (up to 32 on Railway), which let that
      many full-res decodes run concurrently.
    - Reference images travel **bare base64** through multimodal messages;
      the OpenAI-compatible path wraps to a data URL only at wire
      serialization and Gemini sniffs the mime from the first bytes. No
      full-size data-URL copy per image per call.
    - Job lifecycle frees payloads at the right time: per-image source base64
      is released as each extraction finishes, generated images are uploaded
      to a storage URL at generation time, and terminal job state drops
      `generated_image_base64` (upload failure keeps it). SSE live events
      still carry base64; history/status are URL-only.
    - SSE subscriber queues enforce a **byte budget**
      (`SSE_QUEUE_MAX_BUFFERED_BYTES`, default 16 MB) on top of the 100-event
      cap; `event_history` stores base64-stripped, bounded events.
    - Stored exceptions drop their tracebacks (`__traceback__ = None`) so
      `ParallelResult.error` cannot pin multi-MB frame locals.
    - Allocator + GC: `MALLOC_ARENA_MAX=2`, `MALLOC_TRIM_THRESHOLD_=0`,
      `gc.freeze()` + `gc.set_threshold(700, 5, 5)` at startup, one
      `gc.collect()` after background startup.
  - Memory targets: baseline ≤ ~250 MB, storm peak < ~450 MB on the 512 MB
    instance, RSS returns to baseline after jobs finish.
  - If kills continue after those: **raise Railway instance memory**.
  - Idle RSS above ~350 MB after completed jobs is a smell; check unreleased job maps / caches.

## AI providers

- Circuit/health behavior in `ai_provider_health_service`.
- Default chat `max_tokens` is **32768** (configurable via `AI_MAX_OUTPUT_TOKENS`; both providers support >=64K output). The old hardcoded 4096 default truncated large structured extractions. Structured-output (`response_format`) calls raise `AIServiceError` on `finish_reason="length"` instead of returning truncated JSON that parses to empty results.
- Chat and image paths retry transient HTTP statuses: **408, 429, 500, 502, 503, 504** (500/504 = edge timeouts on slow vision POSTs).
- Retry budget: the provider layer retries a transient failure **once** internally (chat honors `Retry-After`, image path uses fixed backoff), then the call site's `with_retry` adds **one more round** — ~4 gateway attempts total per failing call. Do not raise either layer's `max_retries` without lowering the other; they multiply (previously 3×3 → up to 12 POSTs per stuck call, amplifying 429 storms).
- Permanent 4xx (auth, policy, bad model) set `AIServiceError(retryable=False)` and **fail fast** through outer `with_retry` via `is_retryable_error`. "200 with no images" is classified retryable (silent moderation refusal — worth one more round / the fallback model).
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

## Error tracking

| App | SDK | Status |
|-----|-----|--------|
| Backend (FastAPI) | — | **Not integrated.** `sentry-sdk` is not in `requirements.txt`. Structured logging with correlation IDs provides request tracing, but there is no centralized error tracking/alerting. |
| Frontend (React) | `@sentry/react` | **Integrated 2026-07-25.** Initializes only when `VITE_SENTRY_DSN` is set. `ErrorBoundary.componentDidCatch` reports to Sentry. Add the DSN to the deployment environment to activate. |
| Flutter (mobile) | `sentry_flutter ^9.0.0` | **Fully integrated.** Initializes from `EnvConfig.sentryDsn`; wraps `runApp` in `SentryFlutter.init` with `runZonedGuarded` for uncaught async errors. |

## Verification boundaries and residual debt

- The bounded repository harness is `./scripts/check_all.sh`; it runs the
  architecture, docs, theme, backend lint/tests, web lint/tests, and Flutter
  analyze/tests checks when their existing toolchains are available. It never
  starts Docker or local Supabase. The web build is opt-in because its prebuild
  writes tracked `frontend/public/sitemap.xml`.
- Batch extraction and asynchronous photoshoot jobs persist ownership-scoped
  metadata, progress, and final storage URLs in hosted Supabase. A process
  restart does not resume an active provider call; clients receive a durable
  `job_recovered` snapshot for polling and retry UX. Social-import workers
  remain process-local, and synchronous photoshoot generation plus advisory
  cancellation remain known contract gaps (TD-009/TD-018/TD-019).
- Provider garment-reference count remains unverified and the current backend
  caps resolved references at 12 (TD-033); SSE terminal names and status enums
  still differ between streams (TD-020/TD-021).
- The Flutter dashboard now isolates optional streak loading from the main
  dashboard request (TD-034 resolved). The local SDK cache may still be
  unwritable in the default sandbox; verification with a writable SDK cache
  passed, while CI remains the reproducible release boundary.

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

## SSE fan-out policy (decided 2026-07-26)

One rule for all three event streams, in `app/utils/sse_queue.py`:
**bounded queue (100), `put_nowait`, and drop the subscriber on `QueueFull`**
with a single terminal `stream_overflow` event.

The failure this replaces was the same decision answered two opposite ways.
Batch used a bounded queue with `await queue.put`, so a client that stopped
reading back-pressured the **extraction pipeline** rather than itself.
Photoshoot and social import used unbounded queues fed with base64 image
payloads, so the same client grew RSS instead. `remove_subscriber` cannot
rescue either: it only runs in the SSE generator's `finally`, which a client
that never reads never reaches.

A slow client degrades **itself** — never the pipeline, never the process.

`stream_overflow` is deliberately distinct from `job_failed`: the clients act
on `job_failed` (the Flutter photoshoot controller resets to the configure
step, batch cancels its subscription), and the job is still running with
images already billed. It is server-side terminal only; clients see a plain
stream close and recover through their existing replay / `/status` path.

All three responses carry `ping=15` and `X-Accel-Buffering: no` /
`Cache-Control: no-transform`. The app-level 30s heartbeat is longer than many
proxy idle timeouts, so it is not sufficient on its own.
