"""
Image Generation Agent - Backend AI agent for outfit and product image generation.

This agent replaces the frontend outfitGenerationAgent that used Puter.js txt2img.

Features:
- Generate outfit visualization
- Generate product images for individual items
- Generate flat lay compositions
- Generate variations
"""

import base64
import uuid
from typing import Any, Dict, List, Optional

from app.agents.prompt_fidelity import (
    OUTFIT_LOCK,
    PERSON_REFERENCE_FIDELITY,
    PRODUCT_REFERENCE_LOCK,
    SHORT_NEGATIVES,
)
from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.services.ai_provider_service import AIProviderService
from app.services.ai_settings_service import AISettingsService
from app.services.storage_service import StorageService
from app.utils.parallel import parallel_with_retry

logger = get_context_logger(__name__)


# =============================================================================
# DATA CLASSES
# =============================================================================


class GeneratedImage:
    """Result of an image generation operation."""

    def __init__(
        self,
        image_base64: str,
        prompt: str,
        model: str,
        provider: str,
        image_url: Optional[str] = None,
        storage_path: Optional[str] = None,
    ):
        self.image_base64 = image_base64
        self.prompt = prompt
        self.model = model
        self.provider = provider
        self.image_url = image_url
        self.storage_path = storage_path

    def to_dict(self) -> Dict[str, Any]:
        return {
            "image_base64": self.image_base64,
            "image_url": self.image_url,
            "storage_path": self.storage_path,
            "prompt": self.prompt,
            "model": self.model,
            "provider": self.provider,
        }


# =============================================================================
# IMAGE GENERATION AGENT
# =============================================================================


class ImageGenerationAgent:
    """Agent for generating outfit and product images."""

    def __init__(self, ai_service: AIProviderService):
        """Initialize with an AI service instance."""
        self.ai_service = ai_service

    @staticmethod
    def _build_outfit_inventory(items: List[Dict[str, Any]]) -> str:
        """Build a detailed, deterministic outfit inventory for prompt fidelity."""
        if not items:
            return "Outfit inventory: none provided."

        lines = ["OUTFIT INVENTORY (MUST BE MATCHED EXACTLY):"]
        for idx, item in enumerate(items, start=1):
            name = str(item.get("name") or "unspecified item").strip()
            category = str(item.get("category") or "other").strip() or "other"
            colors = [str(c).strip() for c in (item.get("colors") or []) if str(c).strip()]
            material = str(item.get("material") or "").strip()
            pattern = str(item.get("pattern") or "").strip()
            brand = str(item.get("brand") or "").strip()

            lines.append(f"- Item {idx}: {name} (category: {category})")
            lines.append(f"  - colors: {', '.join(colors) if colors else 'unspecified'}")
            lines.append(f"  - material: {material if material else 'unspecified'}")
            lines.append(f"  - pattern: {pattern if pattern else 'unspecified'}")
            lines.append(f"  - brand/details: {brand if brand else 'unspecified'}")

        lines.append("- Include every listed item exactly once unless naturally hidden by layering.")
        lines.append("- Do not add any extra clothing, footwear, accessories, or props.")
        return "\n".join(lines)

    async def generate_outfit(
        self,
        items: List[Dict[str, Any]],
        style: str = "casual",
        background: str = "studio white",
        pose: str = "standing front",
        lighting: str = "professional studio lighting",
        view_angle: str = "full body",
        include_model: bool = True,
        model_gender: str = "female",
        custom_prompt: Optional[str] = None,
        user_avatar_base64: Optional[str] = None,
        body_profile: Optional[Dict[str, Any]] = None,
    ) -> GeneratedImage:
        """
        Generate an outfit visualization image.

        Args:
            items: List of items with name, category, colors, brand, material, pattern
            style: Overall style (casual, formal, streetwear, etc.)
            background: Background description
            pose: Model pose
            lighting: Lighting description
            view_angle: Camera angle
            include_model: Whether to include a model or flat lay
            model_gender: Gender of model
            custom_prompt: Additional prompt instructions
            user_avatar_base64: Optional user avatar for face consistency
            body_profile: Optional body profile dict with height_cm, body_shape, skin_tone

        Returns:
            GeneratedImage with the result
        """
        logger.debug(
            "Generating outfit image",
            item_count=len(items),
            style=style,
            include_model=include_model,
            has_avatar=user_avatar_base64 is not None,
            has_body_profile=body_profile is not None,
        )

        wants_flat_lay = not include_model or "flat lay" in pose.lower()

        # Build item descriptions
        item_descriptions = []
        for item in items:
            parts = [item.get("name", "item")]
            if item.get("brand"):
                parts.append(f"by {item['brand']}")
            if item.get("category"):
                parts.append(f"({item['category']})")
            if item.get("colors"):
                parts.append(f"colors: {', '.join(item['colors'])}")
            if item.get("material"):
                parts.append(f"material: {item['material']}")
            if item.get("pattern"):
                parts.append(f"pattern: {item['pattern']}")
            item_descriptions.append(" ".join(parts))

        items_list = "; ".join(item_descriptions)
        outfit_inventory = self._build_outfit_inventory(items)

        # Build body profile description if available
        body_desc = ""
        if body_profile:
            parts = []
            if body_profile.get("skin_tone"):
                parts.append(f"skin tone: {body_profile['skin_tone']}")
            if body_profile.get("body_shape"):
                parts.append(f"body shape: {body_profile['body_shape']}")
            if body_profile.get("height_cm"):
                parts.append(f"height: approximately {int(body_profile['height_cm'])}cm")
            if parts:
                body_desc = f"\nModel physical characteristics: {', '.join(parts)}"

        # Build prompt based on whether we have user avatar
        if wants_flat_lay:
            prompt = f"""Professional flat lay fashion photo of a cohesive {style} outfit: {items_list}.

{outfit_inventory}

{OUTFIT_LOCK}

Style:
- Background: {background}
- Pose: flat lay (top-down)
- View angle: {view_angle}
- Lighting: {lighting}
- Sharp focus, realistic fabric textures, accurate colors

{SHORT_NEGATIVES}

{f"Additional instructions: {custom_prompt}" if custom_prompt else ""}""".strip()

            return await self._generate_image(prompt)

        elif user_avatar_base64:
            # Reference image = identity source; text inventory = garments only
            base_prompt = f"""REFERENCE IMAGE = person identity (source of truth for face/body/hair/skin).
TASK: Photoreal fashion photo of that same person wearing the outfit below.

{PERSON_REFERENCE_FIDELITY}

{outfit_inventory}
{body_desc}

SCENE (change only these):
- Style: {style}
- Background: {background}
- Pose: {pose} (face clearly visible; front or slight 3/4; no sunglasses)
- View angle: {view_angle}
- Lighting: {lighting} (even face light; no beauty-filter look)
- Clothing fits naturally with realistic draping and shadows

{f"Additional instructions: {custom_prompt}" if custom_prompt else ""}""".strip()

            # Use multi-modal generation with avatar image
            try:
                avatar_url = f"data:image/jpeg;base64,{user_avatar_base64}" if not user_avatar_base64.startswith("data:") else user_avatar_base64

                content = [
                    {"type": "image_url", "image_url": {"url": avatar_url}},
                    {"type": "text", "text": base_prompt},
                ]

                from app.services.ai_provider_service import ChatMessage

                messages = [ChatMessage(role="user", content=content)]

                response = await self.ai_service.chat(
                    messages=messages,
                    model=self.ai_service.config.get_image_gen_model(),
                    response_modalities=["TEXT", "IMAGE"],
                )

                if not response.images:
                    raise AIServiceError("AI generated no images for outfit with avatar")

                return GeneratedImage(
                    image_base64=response.images[0],
                    prompt=base_prompt,
                    model=response.model,
                    provider=response.provider,
                )

            except AIServiceError:
                raise
            except Exception as e:
                logger.error("Outfit generation with avatar failed", error=str(e))
                raise AIServiceError(f"Outfit generation with avatar failed: {str(e)}")

        else:
            # Generic model generation (no avatar)
            prompt = f"""Professional fashion photo of a {model_gender} model wearing a cohesive {style} outfit: {items_list}.

{outfit_inventory}

{OUTFIT_LOCK}
{body_desc}

Style:
- Background: {background}
- Pose: {pose}
- View angle: {view_angle}
- Lighting: {lighting}
- Sharp focus, realistic fabric textures, accurate colors

{SHORT_NEGATIVES}

{f"Additional instructions: {custom_prompt}" if custom_prompt else ""}""".strip()

            return await self._generate_image(prompt)

    async def generate_product_image(
        self,
        item_description: str,
        category: str,
        sub_category: Optional[str] = None,
        colors: Optional[List[str]] = None,
        material: Optional[str] = None,
        background: str = "white",
        view_angle: str = "front",
        include_shadows: bool = False,
        reference_image: Optional[str] = None,
    ) -> GeneratedImage:
        """
        Generate a clean e-commerce style product image for a single clothing item.

        Args:
            item_description: Detailed description of the item
            category: Item category
            sub_category: Item sub-category
            colors: List of colors
            material: Material type
            background: Background style
            view_angle: Camera angle
            include_shadows: Whether to include shadows
            reference_image: Optional base64 reference image for exact matching

        Returns:
            GeneratedImage with the result
        """
        logger.debug(
            "Generating product image",
            category=category,
            sub_category=sub_category,
            has_reference=reference_image is not None,
        )

        background_map = {
            "white": "pure white studio background",
            "gray": "light gray seamless studio background",
            "gradient": "subtle gray-to-white gradient background",
            "transparent": "clean white background",
        }

        view_map = {
            "front": "front view, straight-on angle",
            "side": "three-quarter view angle",
            "flat-lay": "flat lay top-down view",
        }

        category_name = sub_category or category
        color_desc = " and ".join(colors) if colors else ""

        if reference_image:
            prompt = f"""REFERENCE IMAGE = product appearance source of truth.
Extract ONLY the {category_name} item into a clean e-commerce product photo.

{PRODUCT_REFERENCE_LOCK}

Item details: {item_description}

Output:
- {background_map.get(background, background_map["white"])}
- {view_map.get(view_angle, view_map["front"])}
- {"Subtle natural drop shadow" if include_shadows else "No shadows; fully isolated"}
- Soft studio light, sharp focus, catalog quality
- Flat or invisible mannequin; no person""".strip()
        else:
            prompt = f"""Professional e-commerce product photo of a single {category_name}:

{item_description}

Specs:
- {background_map.get(background, background_map["white"])}
- {view_map.get(view_angle, view_map["front"])}
- {"Subtle natural drop shadow" if include_shadows else "No shadows; fully isolated"}
- Accurate colors{f": {color_desc}" if color_desc else ""}, realistic fabric{f" ({material})" if material else ""}
- Soft studio light, sharp focus
- Only this item; no model or extra garments

{SHORT_NEGATIVES}""".strip()

        return await self._generate_image(prompt, reference_image=reference_image)

    async def generate_flat_lay(
        self,
        items: List[Dict[str, Any]],
        style: str = "casual",
        background: str = "white",
        lighting: str = "soft natural light",
    ) -> GeneratedImage:
        """
        Generate a flat lay composition of items.

        Args:
            items: List of items to include
            style: Overall style
            background: Background description
            lighting: Lighting description

        Returns:
            GeneratedImage with the result
        """
        return await self.generate_outfit(
            items=items,
            style=style,
            background=background,
            pose="flat lay",
            lighting=lighting,
            include_model=False,
        )

    async def generate_variations(
        self,
        items: List[Dict[str, Any]],
        styles: Optional[List[str]] = None,
    ) -> List[GeneratedImage]:
        """
        Generate multiple style variations of an outfit in parallel.

        Args:
            items: List of items
            styles: List of styles to generate

        Returns:
            List of GeneratedImage results (only successful ones)
        """
        if styles is None:
            styles = ["casual", "formal", "streetwear"]

        logger.debug(
            "Generating style variations in parallel",
            style_count=len(styles),
            item_count=len(items),
        )

        # Process all styles in parallel with retry
        results = await parallel_with_retry(
            styles,
            lambda style, _: self.generate_outfit(items=items, style=style),
            max_retries=3,
            initial_delay=2.0,  # AI operations need longer delays
            backoff_factor=2.0,
            retryable_exceptions=(AIServiceError, Exception),
        )

        # Log failures
        failed = [r for r in results if not r.success]
        if failed:
            for r in failed:
                logger.error(
                    "Failed to generate variation after retries",
                    style=styles[r.index],
                    error=str(r.error),
                )

        # Return only successful results
        successful = [r.data for r in results if r.success]

        logger.info(
            "Completed parallel variation generation",
            successful=len(successful),
            failed=len(failed),
            total=len(styles),
        )

        return successful

    async def _generate_image(
        self, prompt: str, reference_image: Optional[str] = None
    ) -> GeneratedImage:
        """
        Internal method to generate an image from a prompt.

        Args:
            prompt: The generation prompt
            reference_image: Optional base64 reference image for image-to-image generation

        Returns:
            GeneratedImage with the result
        """
        try:
            response = await self.ai_service.generate_image(
                prompt, reference_image=reference_image
            )

            if not response.images:
                raise AIServiceError("AI generated no images")

            return GeneratedImage(
                image_base64=response.images[0],
                prompt=prompt,
                model=response.model,
                provider=response.provider,
            )

        except AIServiceError:
            raise
        except Exception as e:
            logger.error("Image generation failed", error=str(e))
            raise AIServiceError(f"Image generation failed: {str(e)}")

    async def generate_try_on(
        self,
        user_avatar_base64: str,
        clothing_image_base64: str,
        clothing_description: Optional[str] = None,
        style: str = "casual",
        background: str = "studio white",
        pose: str = "standing front",
        lighting: str = "professional studio lighting",
    ) -> GeneratedImage:
        """
        Generate a virtual try-on visualization.

        Combines user's profile picture with uploaded clothing to show
        how the user would look wearing those clothes.

        Args:
            user_avatar_base64: Base64-encoded user profile picture
            clothing_image_base64: Base64-encoded clothing image
            clothing_description: Optional description of the clothing
            style: Overall style (casual, formal, etc.)
            background: Background description
            pose: Model pose
            lighting: Lighting description

        Returns:
            GeneratedImage with the try-on visualization
        """
        logger.debug(
            "Generating try-on image",
            has_clothing_description=clothing_description is not None,
            style=style,
            pose=pose,
        )

        clothing_desc = f"\nGarment notes: {clothing_description}" if clothing_description else ""

        prompt = f"""REFERENCE A (first image) = person identity (face/body/hair/skin source of truth).
REFERENCE B (second image) = garment appearance only.

TASK: Photoreal photo of person A wearing garment B.

{PERSON_REFERENCE_FIDELITY}

GARMENT LOCK (from reference B):
- Same colors, pattern, cut, fabric look, logos, seams, and hardware as reference B.
- Do not invent or restyle the garment.
{clothing_desc}

SCENE (change only these):
- Style: {style}
- Background: {background}
- Pose: {pose} (face clearly visible; front or slight 3/4; no sunglasses)
- Lighting: {lighting} (even face light; no beauty-filter look)
- Natural fit, draping, and shadows

Output one cohesive image of THIS same person wearing that exact garment."""

        try:
            # Use chat_with_vision for multi-image input with image generation
            # Build message content with two images
            avatar_url = f"data:image/jpeg;base64,{user_avatar_base64}" if not user_avatar_base64.startswith("data:") else user_avatar_base64
            clothing_url = f"data:image/jpeg;base64,{clothing_image_base64}" if not clothing_image_base64.startswith("data:") else clothing_image_base64

            content = [
                {"type": "image_url", "image_url": {"url": avatar_url}},
                {"type": "image_url", "image_url": {"url": clothing_url}},
                {"type": "text", "text": prompt},
            ]

            from app.services.ai_provider_service import ChatMessage

            messages = [ChatMessage(role="user", content=content)]

            response = await self.ai_service.chat(
                messages=messages,
                model=self.ai_service.config.get_image_gen_model(),
                response_modalities=["TEXT", "IMAGE"],
            )

            if not response.images:
                raise AIServiceError("AI generated no images for try-on")

            return GeneratedImage(
                image_base64=response.images[0],
                prompt=prompt,
                model=response.model,
                provider=response.provider,
            )

        except AIServiceError:
            raise
        except Exception as e:
            logger.error("Try-on image generation failed", error=str(e))
            raise AIServiceError(f"Try-on generation failed: {str(e)}")


# =============================================================================
# STORAGE HELPER
# =============================================================================


async def save_generated_image(
    generated: GeneratedImage,
    user_id: str,
    image_type: str = "outfit",
    db=None,
) -> Dict[str, str]:
    """
    Save a generated image to Supabase Storage.

    Args:
        generated: The GeneratedImage result
        user_id: User ID for path
        image_type: Type of image (outfit, product)
        db: Supabase client

    Returns:
        Dict with image_url and storage_path
    """
    if not db:
        return {"image_url": "", "storage_path": ""}

    try:
        # Decode base64 image
        image_data = base64.b64decode(generated.image_base64)

        # Generate unique filename
        filename = f"{user_id}/generated/{image_type}/{uuid.uuid4().hex}.png"

        # Upload to storage
        storage = StorageService()
        result = await storage.upload_file(
            file_data=image_data,
            file_path=filename,
            content_type="image/png",
            db=db,
        )

        return {
            "image_url": result.get("public_url", ""),
            "storage_path": filename,
        }

    except Exception as e:
        logger.error("Failed to save generated image", error=str(e))
        return {"image_url": "", "storage_path": ""}


# =============================================================================
# FACTORY FUNCTION
# =============================================================================


async def get_image_generation_agent(
    user_id: str,
    db,
) -> ImageGenerationAgent:
    """
    Get an image generation agent configured for a user.

    Args:
        user_id: The user's ID
        db: Supabase client

    Returns:
        Configured ImageGenerationAgent
    """
    ai_service = await AISettingsService.get_ai_service_for_user(user_id, db)
    return ImageGenerationAgent(ai_service)
