# FitCheck AI Backend Dockerfile
# Multi-stage build for optimized image size

# Stage 1: Builder - Install dependencies
FROM python:3.12-slim as builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime - Final production image
FROM python:3.12-slim

# Set environment variables - PATH updated for appuser
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH=/home/appuser/.local/bin:$PATH

# Memory-budget tuning for the single 512 MB Railway worker:
# - MALLOC_ARENA_MAX=2: glibc creates one arena per thread (up to 8x cores);
#   each arena reserves its own heap, so a multi-threaded Python process on a
#   many-core host wastes RSS. Capping arenas bounds that fragmentation.
# - MALLOC_TRIM_THRESHOLD_=0: return freed memory to the OS promptly so RSS
#   falls back to baseline after AI bursts instead of staying inflated.
ENV MALLOC_ARENA_MAX=2 \
    MALLOC_TRIM_THRESHOLD_=0

# Create a non-root user with home directory
RUN groupadd -r appuser && useradd -r -g appuser -m appuser

# Set working directory
WORKDIR /app

# Copy Python dependencies to appuser's home directory with correct ownership
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Create logs directory with correct ownership (for session logging)
RUN mkdir -p /app/logs && chown appuser:appuser /app/logs

# Copy application code
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Expose port (Railway sets $PORT dynamically)
EXPOSE 8000

# Run the application (supports Railway's $PORT)
# Railway's healthcheck is configured in railway.json
# --proxy-headers --forwarded-allow-ips='*': the container is only ever
# reachable through Railway's edge proxy (never directly from the internet),
# so the proxy is the sole possible TCP peer. NOTE (A5-01): uvicorn resolves
# request.client.host from the FIRST X-Forwarded-For entry, which any direct
# peer could forge; the app's get_client_ip therefore parses the LAST entry
# itself (the hop only the edge proxy can append) instead of trusting the
# resolved host.
# --limit-concurrency: shed load before the single process OOMs under
# image/AI bursts (in-memory batch/photoshoot jobs hold large base64).
# --timeout-keep-alive: free idle connections faster on Railway's edge.
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000} --proxy-headers --forwarded-allow-ips='*' --limit-concurrency 50 --timeout-keep-alive 5"]
