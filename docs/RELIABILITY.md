# Reliability

Status: draft  
Last updated: 2026-07-22

## Health and readiness

- `GET /health` reports liveness and schema readiness.
- Startup should not block indefinitely on optional subsystems; see lifespan tests.

## Long-running AI jobs

- Batch extract, photoshoot, and social import use **job stores + SSE** rather than single multi-minute HTTP requests for multi-image work.
- Extract parallelism and **overlapped** product generation have concurrency caps (see batch extraction service).
- Job memory caps exist—respect them when adding new in-memory job types (`test_job_memory_caps.py`).
- Photoshoot concurrency defaults to 2; reference photos are downscaled before gen to limit RAM.
- Railway single-worker process: OS `Killed` after AI bursts usually means OOM. Raise instance memory if kills continue after payload downscale.

## AI providers

- Circuit/health behavior in `ai_provider_health_service`.
- Image generation: primary → fallback model on transient errors; fail fast on policy/auth errors.
- Timeouts and retries should be explicit in provider clients—not infinite loops.
- AI HTTP client uses HTTP/1.1; `LocalProtocolError` / `RemoteProtocolError` rebuild the pooled client and retry.

## Rate limiting

- IP / request rate limit helpers exist; tests cover race and client IP extraction.
- Do not disable rate limits in production configs without a decision log entry.

## Client expectations

- Web: token refresh queue on 401; background job UI (`jobUiStore`) for multi-step AI.
- Clients may save wardrobe items using original photos if studio images are still generating.

## Observability (agent legibility)

- Structured request logging + correlation IDs.
- Log files under `backend/logs/` for local agent debugging.
- No Dockerized local Prometheus/Loki stack in v1; use host logs and any configured hosted monitoring (e.g. Grafana) when available.

## Failure modes to preserve

- Clear error JSON with codes for clients.
- SSE event streams should not silently die without a terminal error/complete event when the server knows the job failed.
