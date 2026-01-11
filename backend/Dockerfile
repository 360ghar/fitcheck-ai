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
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
