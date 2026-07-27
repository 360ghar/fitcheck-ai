"""
Process-wide concurrency gates for AI extraction and generation.

Single source of truth for the asyncio.Semaphore singletons shared across all
concurrent batch jobs (batch_extraction_service.py) and the outfit-variation
fan-out (image_generation_agent.generate_variations). Caps are configurable via
AI_EXTRACTION_CONCURRENCY / AI_GENERATION_CONCURRENCY (see app/core/config.py).

Built eagerly at import. On Python 3.10+ asyncio.Semaphore() no longer
requires a running event loop, so importing this module outside an asyncio
context (e.g. at FastAPI startup) is safe. Floors at 1 so a misconfigured
env (0/negative) cannot deadlock the pipeline by yielding a zero-cap semaphore.
"""

import asyncio

from app.core.config import settings

EXTRACTION_SEMAPHORE: asyncio.Semaphore = asyncio.Semaphore(
    max(1, settings.AI_EXTRACTION_CONCURRENCY)
)
GENERATION_SEMAPHORE: asyncio.Semaphore = asyncio.Semaphore(
    max(1, settings.AI_GENERATION_CONCURRENCY)
)
