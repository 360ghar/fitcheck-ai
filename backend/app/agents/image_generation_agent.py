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
import re
import uuid
from typing import Any, Dict, List, Optional

from app.agents.prompt_fidelity import (
    GARMENT_REFERENCE_LOCK,
    OUTFIT_LOCK,
    PERSON_REFERENCE_FIDELITY,
    PRODUCT_REFERENCE_LOCK,
    SHORT_NEGATIVES,
)
from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.core.concurrency import GENERATION_SEMAPHORE
from app.services.ai_provider_service import AIProviderService, ChatMessage
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

    # Key set on each item dict by
    # app/services/item_reference_service.resolve_outfit_item_references.
    # References ride INSIDE the item dicts rather than in a parallel list so
    # label/image misalignment is structurally impossible, and the delegating
    # entry points (generate_flat_lay, generate_variations) inherit the
    # feature without signature changes.
    REFERENCE_KEY = "reference_image_base64"

    @staticmethod
    def _as_data_url(image_base64: str) -> str:
        """Normalize bare base64 to the data URL the content parts expect."""
        if image_base64.startswith("data:"):
            return image_base64
        return f"data:image/jpeg;base64,{image_base64}"

    @staticmethod
    def _tidy_prompt(prompt: str) -> str:
        """Collapse the runs of blank lines left by empty optional blocks.

        Several prompt slots (garment references, body profile, custom
        instructions) are empty for most requests; without this the model gets
        three or four blank lines where a section would have been.
        """
        return re.sub(r"\n{3,}", "\n\n", prompt).strip()

    @classmethod
    def _collect_garment_references(
        cls,
        items: List[Dict[str, Any]],
        first_image_number: int,
    ) -> tuple[List[str], Dict[int, int]]:
        """Split items into ordered garment reference images plus their labels.

        Args:
            items: Item dicts, some carrying REFERENCE_KEY.
            first_image_number: The IMAGE number the first garment gets — 2
                when a person reference occupies IMAGE 1, else 1.

        Returns:
            (images, image_numbers) where `images` is in item order and
            `image_numbers` maps a 1-based item index (the same numbering
            _build_outfit_inventory uses) to the 1-based IMAGE number the
            model sees.
        """
        images: List[str] = []
        image_numbers: Dict[int, int] = {}
        for idx, item in enumerate(items, start=1):
            reference = item.get(cls.REFERENCE_KEY)
            if not reference:
                continue
            image_numbers[idx] = first_image_number + len(images)
            images.append(reference)
        return images, image_numbers

    @classmethod
    def _build_reference_map(
        cls,
        items: List[Dict[str, Any]],
        image_numbers: Dict[int, int],
        *,
        person_image: bool,
    ) -> str:
        """Numbered map of what each inline image is.

        Without this the model has to guess which image is which garment.
        Returns the pre-existing single-line person header verbatim when there
        are no garment references, so the prompt that works today is
        unchanged for clients that send no item_ids.
        """
        if not image_numbers:
            if person_image:
                return "REFERENCE IMAGE = person identity (source of truth for face/body/hair/skin)."
            return ""

        lines = ["REFERENCE IMAGES (in order):"]
        if person_image:
            lines.append(
                "- IMAGE 1 = the person: identity source of truth "
                "(face, body, hair, skin). Not a garment."
            )
        for idx, item in enumerate(items, start=1):
            number = image_numbers.get(idx)
            if not number:
                continue
            name = str(item.get("name") or "unspecified item").strip()
            category = str(item.get("category") or "other").strip() or "other"
            lines.append(
                f'- IMAGE {number} = Item {idx} "{name}" ({category}): garment appearance only.'
            )

        missing = [str(idx) for idx in range(1, len(items) + 1) if idx not in image_numbers]
        if missing:
            lines.append(
                f"Item {missing[0]} has no reference image - "
                "render it from its inventory description."
                if len(missing) == 1
                else f"Items {', '.join(missing)} have no reference image - "
                "render them from their inventory descriptions."
            )
        return "\n".join(lines)

    @staticmethod
    def _build_outfit_inventory(
        items: List[Dict[str, Any]],
        image_numbers: Optional[Dict[int, int]] = None,
    ) -> str:
        """Build a detailed, deterministic outfit inventory for prompt fidelity.

        When `image_numbers` is provided (see _collect_garment_references) each
        item also states which inline IMAGE carries its true appearance, so the
        model binds garment to image instead of guessing.
        """
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
            if image_numbers:
                number = image_numbers.get(idx)
                lines.append(
                    f"  - appearance reference: IMAGE {number} — copy this garment exactly"
                    if number
                    else "  - appearance reference: none — render from this description"
                )

        lines.append("- Include every listed item exactly once unless naturally hidden by layering.")
        lines.append("- Do not add any extra clothing, footwear, accessories, or props.")
        return "\n".join(lines)

    async def generate_outfit(
        self,
        items: List[Dict[str, Any]],
        style: str = "casual",
        background: str = "seamless clean light background",
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
            items: List of items with name, category, colors, brand, material,
                pattern, and optionally REFERENCE_KEY holding that item's own
                image as base64 (set by item_reference_service). Items with a
                reference are sent to the model as labelled garment images so
                the output reproduces the real garment; items without one are
                still rendered from their text description.
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
            item_reference_count=sum(1 for i in items if i.get(self.REFERENCE_KEY)),
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

        # Garment references: the items' own stored images, numbered so the
        # prompt can bind IMAGE n -> Item n. The person reference (when used)
        # takes IMAGE 1, so garments start at 2.
        uses_person_reference = bool(user_avatar_base64) and not wants_flat_lay
        garment_images, image_numbers = self._collect_garment_references(
            items, first_image_number=2 if uses_person_reference else 1
        )
        outfit_inventory = self._build_outfit_inventory(items, image_numbers=image_numbers)
        reference_map = self._build_reference_map(
            items, image_numbers, person_image=uses_person_reference
        )
        garment_block = f"\n{GARMENT_REFERENCE_LOCK}\n" if garment_images else ""
        # Only warn about collaging reference images when references exist -
        # otherwise the line names inputs the model was never given.
        no_collage = (
            " — not a collage, grid, or copy of the reference images side by side"
            if garment_images
            else ""
        )

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

{reference_map}
{garment_block}
{outfit_inventory}

{OUTFIT_LOCK}

Style:
- Background: {background}
- Pose: flat lay (top-down)
- View angle: {view_angle}
- Lighting: {lighting}
- Sharp focus, realistic fabric textures, accurate colors

Composition: ONE single flat lay photograph of these garments arranged together on the background{no_collage}.

{SHORT_NEGATIVES}

{f"Additional instructions: {custom_prompt}" if custom_prompt else ""}"""

            return await self._generate_with_references(
                self._tidy_prompt(prompt), garment_images, context="outfit flat lay"
            )

        elif user_avatar_base64:
            # IMAGE 1 = identity source. Garment images (when the items have
            # stored photos) follow it and are the appearance source for the
            # clothes; the text inventory still identifies every item and is
            # the only source for items with no image. PERSON_REFERENCE_
            # FIDELITY stays ahead of the garment block so IDENTITY_LOCK keeps
            # top priority.
            # A multi-line reference map wants a blank line before TASK; the
            # single-line legacy header sat directly above it, and keeping that
            # exact spacing means a client sending no item_ids gets byte-for-byte
            # the prompt that works today.
            person_header = reference_map + ("\n\n" if image_numbers else "\n")
            base_prompt = f"""{person_header}TASK: Photoreal fashion photo of that same person wearing the outfit below.

{PERSON_REFERENCE_FIDELITY}
{garment_block}
{outfit_inventory}
{body_desc}

SCENE (change only these):
- Style: {style}
- Background: {background}
- Pose: {pose} (face clearly visible; front or slight 3/4; no sunglasses)
- View angle: {view_angle}
- Lighting: {lighting} (even face light; no beauty-filter look)
- Clothing fits naturally with realistic draping and shadows

{f"Additional instructions: {custom_prompt}" if custom_prompt else ""}"""

            return await self._generate_with_references(
                self._tidy_prompt(base_prompt),
                [user_avatar_base64, *garment_images],
                context="outfit with avatar",
            )

        else:
            # Generic model generation (no avatar)
            prompt = f"""Professional fashion photo of a {model_gender} model wearing a cohesive {style} outfit: {items_list}.

{reference_map}
{garment_block}
{outfit_inventory}

{OUTFIT_LOCK}
{body_desc}

Style:
- Background: {background}
- Pose: {pose}
- View angle: {view_angle}
- Lighting: {lighting}
- Sharp focus, realistic fabric textures, accurate colors

Composition: ONE single photograph of the model wearing this outfit{no_collage}.

{SHORT_NEGATIVES}

{f"Additional instructions: {custom_prompt}" if custom_prompt else ""}"""

            return await self._generate_with_references(
                self._tidy_prompt(prompt), garment_images, context="outfit"
            )

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
            reference_image: Optional base64 of the source photo. Used ONLY as
                the appearance source of truth to replicate the single item
                described by item_description; the description identifies which
                item, the photo supplies its look.

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
            # The item is IDENTIFIED by its dense description below, and
            # REPLICATED from the reference photo. This function itself never
            # sees or uses bbox coordinates as text/region-attention hints in
            # the prompt - that was tried and is weak, models don't reliably
            # attend to a described region within a busy photo. Instead,
            # callers (batch_extraction_service.py, social_import_pipeline_
            # service.py, via resolve_product_reference_image in
            # app/utils/image_processing.py) now physically pre-crop the
            # reference image to the item's bbox before it ever reaches this
            # function whenever the source photo has multiple items and the
            # bbox is trustworthy - or drop the reference entirely and rely on
            # the description alone when it isn't. So `reference_image` here
            # is already either a single-item photo, a cropped close-up, or
            # absent; this prompt is defense-in-depth for whichever it is.
            tokens = category_name
            if color_desc:
                tokens += f"; colors: {color_desc}"
            if material:
                tokens += f"; material: {material}"

            prompt = f"""REFERENCE IMAGE = the source photo. Use it ONLY as the appearance source of truth to replicate the ONE item described below.

IDENTIFY the item to reproduce from this dense description (NOT any other item in the photo):
{item_description}

{PRODUCT_REFERENCE_LOCK}

Item: {tokens}.

Output:
- {background_map.get(background, background_map["white"])}
- {view_map.get(view_angle, view_map["front"])}
- {"Subtle natural drop shadow" if include_shadows else "No shadows; fully isolated"}
- Soft studio light, sharp focus, catalog quality
- Reproduce ONLY that single item, exactly as it appears in the reference photo. Ignore every other garment, footwear, accessory, prop, person, and background visible in the photo. One isolated product shot; no second or partial second item.
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
- Only this single item; no model, extra garments, or second item

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

        # Gate the per-style fan-out through the process-wide
        # GENERATION_SEMAPHORE so variations share the same concurrency
        # budget as batch product-image generation (AI_GENERATION_CONCURRENCY).
        async def _generate_one_style(style, _):
            async with GENERATION_SEMAPHORE:
                return await self.generate_outfit(items=items, style=style)

        # Process all styles in parallel with retry
        results = await parallel_with_retry(
            styles,
            _generate_one_style,
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

    async def _generate_with_references(
        self,
        prompt: str,
        images: Optional[List[str]] = None,
        *,
        context: str = "image",
    ) -> GeneratedImage:
        """
        Generate one image from a prompt plus N inline reference images.

        Args:
            prompt: The generation prompt. Its "IMAGE n" labels must match the
                order of `images`.
            images: Base64 (or data URL) references, IMAGE 1 first. Multi-image
                input has to go through chat() because
                ai_provider_service.generate_image() takes a SINGLE
                reference_image, so with no images this delegates to
                _generate_image and the text-only path is untouched.
            context: Shapes the error message and log ("outfit with avatar").

        Returns:
            GeneratedImage with the result
        """
        if not images:
            return await self._generate_image(prompt)

        try:
            # Images first, then the text - mirrors the working try-on path and
            # the Gemini provider's part ordering.
            content: List[Dict[str, Any]] = [
                {"type": "image_url", "image_url": {"url": self._as_data_url(image)}}
                for image in images
            ]
            content.append({"type": "text", "text": prompt})

            response = await self.ai_service.chat(
                messages=[ChatMessage(role="user", content=content)],
                model=self.ai_service.get_image_gen_model(),
                response_modalities=["TEXT", "IMAGE"],
            )

            if not response.images:
                # 200-with-no-images is usually a transient silent moderation
                # refusal - retryable so the caller's retry round gets a chance
                # (matches the provider's own no-images classification).
                raise AIServiceError(
                    f"AI generated no images for {context}", retryable=True
                )

            return GeneratedImage(
                image_base64=response.images[0],
                prompt=prompt,
                model=response.model,
                provider=response.provider,
            )

        except AIServiceError:
            raise
        except Exception as e:
            logger.error(
                "Reference image generation failed",
                context=context,
                error=str(e),
                error_type=type(e).__name__,
                image_count=len(images),
                prompt_length=len(prompt),
            )
            raise AIServiceError(f"{context} generation failed: {str(e)}")

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
                # Transient silent refusal - retryable (see avatar path comment).
                raise AIServiceError("AI generated no images", retryable=True)

            return GeneratedImage(
                image_base64=response.images[0],
                prompt=prompt,
                model=response.model,
                provider=response.provider,
            )

        except AIServiceError:
            raise
        except Exception as e:
            logger.error(
                "Image generation failed",
                error=str(e),
                error_type=type(e).__name__,
                prompt_length=len(prompt),
                has_reference_image=reference_image is not None,
            )
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
            content = [
                {"type": "image_url", "image_url": {"url": self._as_data_url(user_avatar_base64)}},
                {"type": "image_url", "image_url": {"url": self._as_data_url(clothing_image_base64)}},
                {"type": "text", "text": prompt},
            ]

            messages = [ChatMessage(role="user", content=content)]

            response = await self.ai_service.chat(
                messages=messages,
                model=self.ai_service.get_image_gen_model(),
                response_modalities=["TEXT", "IMAGE"],
            )

            if not response.images:
                # Transient silent refusal - retryable (see avatar path comment).
                raise AIServiceError("AI generated no images for try-on", retryable=True)

            return GeneratedImage(
                image_base64=response.images[0],
                prompt=prompt,
                model=response.model,
                provider=response.provider,
            )

        except AIServiceError:
            raise
        except Exception as e:
            logger.error(
                "Try-on image generation failed",
                error=str(e),
                error_type=type(e).__name__,
                style=style,
                pose=pose,
                has_clothing_description=clothing_description is not None,
            )
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
        logger.error(
            "Failed to save generated image",
            error=str(e),
            error_type=type(e).__name__,
            user_id=user_id,
            image_type=image_type,
        )
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
