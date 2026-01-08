"""
Backend AI agents for FitCheck AI.

These agents replace the frontend Puter.js-based agents with server-side
AI processing using configurable providers (Gemini, OpenAI, custom).
"""

from app.agents.item_extraction_agent import (
    get_item_extraction_agent,
    ItemExtractionAgent,
)
from app.agents.image_generation_agent import (
    get_image_generation_agent,
    save_generated_image,
    ImageGenerationAgent,
)

__all__ = [
    "get_item_extraction_agent",
    "ItemExtractionAgent",
    "get_image_generation_agent",
    "save_generated_image",
    "ImageGenerationAgent",
]
