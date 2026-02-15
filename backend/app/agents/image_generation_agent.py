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

from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.services.ai_provider_service import AIProviderService
from app.services.ai_settings_service import AISettingsService
from app.services.storage_service import StorageService
from app.utils.parallel import parallel_with_retry

logger = get_context_logger(__name__)


# =============================================================================
# NEGATIVE PROMPTS FOR IMAGE QUALITY
# =============================================================================

NEGATIVE_PROMPTS = """
AVOID these issues:

FACE IDENTITY (CRITICAL):
- Do NOT change any facial features from the reference image - face must be IDENTICAL
- Do NOT alter eye shape, eye color, eye spacing, eyebrows, or eyelid appearance
- Do NOT modify nose shape, nose size, nostril shape, or nose bridge
- Do NOT change lip shape, lip fullness, mouth width, or smile characteristics
- Do NOT alter face shape, jawline, chin, cheekbones, or bone structure
- Do NOT change apparent age - maintain exact same age appearance
- Do NOT change or ambiguate gender presentation
- Do NOT smooth, filter, or idealize skin - preserve exact texture and features
- Do NOT remove or add moles, freckles, scars, or distinguishing marks

OUTFIT AND ITEM FIDELITY (CRITICAL):
- Do NOT add, remove, replace, or restyle any required clothing item
- Do NOT add or remove footwear, accessories, jewelry, bags, hats, belts, watches, or eyewear
- Do NOT change garment silhouette, fit, cut, length, or layering structure
- Do NOT change color shades, patterns, textures, stitching, trims, or fabric appearance
- Do NOT modify logos, labels, hardware, laces, buckles, zippers, buttons, or embellishments

SKIN AND BODY:
- Do NOT alter skin tone - match reference exactly
- Do NOT generate extra limbs, fingers, or distorted body parts
- AVOID uncanny valley effects or plastic-looking skin
- AVOID inconsistent lighting between face and body

TECHNICAL:
- Do NOT create floating or disconnected clothing
- Do NOT blend face features unnaturally
- Do NOT generate text, watermarks, or logos
"""

QUALITY_CONTROL_PROMPT = """
MANDATORY PRE-GENERATION QUALITY CONTROL (INTERNAL):
- Think twice before you generate.
- Re-evaluate the requirements (and reference image(s), if provided) a second time before rendering.
- Build a detailed internal checklist for face identity and every outfit item (tops, bottoms, outerwear, footwear, accessories, and other visible items).
- Verify no required item is missing, altered, swapped, or invented.
- If anything is ambiguous, use the reference image as the source of truth when available.
- Do not output your checklist or analysis; output only the final generated image.
"""


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
            base_prompt = f"Professional flat lay fashion photography of a cohesive {style} outfit: {items_list}."
            prompt = f"""{base_prompt}

{outfit_inventory}

CRITICAL OUTFIT FIDELITY:
- Match every listed item exactly, including apparel, footwear, and accessories.
- Preserve exact colors, patterns, textures, silhouettes, trims, logos, and small design details.
- Do not add or remove items.

Style specifications:
- Background: {background}
- Pose: flat lay (top-down)
- View angle: {view_angle}
- Lighting: {lighting}
- Image quality: high-end editorial fashion photography, sharp focus, realistic fabric textures, accurate colors

{QUALITY_CONTROL_PROMPT}

{NEGATIVE_PROMPTS}

{f"Additional instructions: {custom_prompt}" if custom_prompt else ""}""".strip()

            return await self._generate_image(prompt)

        elif user_avatar_base64:
            # Use Try-On style prompt with comprehensive face identity preservation
            base_prompt = f"""Create a photorealistic fashion photograph showing the person from the reference image wearing a cohesive {style} outfit featuring: {items_list}.

CRITICAL REQUIREMENTS:
1. PRESERVE EXACT FACE IDENTITY (MOST IMPORTANT):
   - This must look like the EXACT SAME PERSON from the reference image
   - Maintain identical facial structure: face shape, jawline, chin, cheekbones
   - Preserve exact eye features: eye shape, color, spacing, eyebrows, eyelids
   - Keep identical nose: shape, bridge, nostrils, size, proportions
   - Maintain exact mouth: lip shape, fullness, width, smile characteristics
   - Preserve exact skin tone, texture, and any distinguishing marks (moles, freckles)
   - Keep the same apparent age and gender presentation
   - Match hair color, style, texture, and hairline exactly

2. CLOTHING ACCURACY: Render the outfit items exactly as described with accurate colors, patterns, textures, and styling.
   - Match each inventory item exactly: tops, bottoms, outerwear, footwear, accessories, and other pieces
   - Preserve exact silhouette, fit, layering, logos, labels, hardware, and small details
   - Do not omit any listed item and do not add any unlisted item

3. NATURAL INTEGRATION: The clothing should fit naturally on the person's body with realistic draping, shadows, and fabric behavior.

4. SINGLE OUTPUT: Generate one cohesive image of the person wearing the complete outfit.
{outfit_inventory}
{body_desc}

Style specifications:
- Background: {background}
- Pose: {pose}
- View angle: {view_angle}
- Lighting: {lighting}
- Image quality: High-end editorial fashion photography, sharp focus, realistic fabric textures, accurate colors

{NEGATIVE_PROMPTS}

{QUALITY_CONTROL_PROMPT}

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
            base_prompt = f"Professional fashion photography of a {model_gender} model wearing a cohesive {style} outfit featuring: {items_list}."
            prompt = f"""{base_prompt}

{outfit_inventory}

CRITICAL OUTFIT FIDELITY:
- Keep the listed clothing items exactly as specified.
- Match apparel, footwear, and accessories precisely (colors, patterns, materials, silhouettes, and detail work).
- Do not add extra garments, accessories, or props.
- Do not remove any required outfit item.
{body_desc}

Style specifications:
- Background: {background}
- Pose: {pose}
- View angle: {view_angle}
- Lighting: {lighting}
- Image quality: high-end editorial fashion photography, sharp focus, realistic fabric textures, accurate colors

{QUALITY_CONTROL_PROMPT}

{NEGATIVE_PROMPTS}

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
            # Image-to-image prompt: extract exact item from reference
            prompt = f"""Look at the reference image and extract ONLY the {category_name} item. Create a clean e-commerce product photo of this EXACT item.

CRITICAL - The generated item must be IDENTICAL to the one in the reference image:
- EXACT same colors, shades, and tones
- EXACT same pattern, print, or design details
- EXACT same style, cut, and silhouette
- EXACT same fabric texture and material appearance
- EXACT same brand logos, labels, or embellishments if visible
- EXACT same proportions and fit
- EXACT same accessories/hardware/details if part of the item (laces, buckles, straps, buttons, zippers, jewelry clasps, etc.)

MANDATORY QUALITY CONTROL (INTERNAL):
- Think twice before you generate.
- Re-evaluate the reference image and item details twice before rendering.
- Build a detailed internal blueprint of the item (shape, seams, trims, closures, logos, texture, color zones) and verify all details match.
- If uncertain, copy the reference detail rather than inventing.

Item details from reference: {item_description}

Output specifications:
- {background_map.get(background, background_map["white"])}
- {view_map.get(view_angle, view_map["front"])}
- {"Subtle natural drop shadow for depth" if include_shadows else "No shadows, completely clean and isolated"}
- Professional studio lighting with soft highlights
- Display flat or on an invisible mannequin
- ONLY this single {category_name} - remove the person/model completely
- High-end fashion catalog quality, sharp focus
- Clean, isolated product shot suitable for an online store""".strip()
        else:
            # Text-to-image prompt: generate from description only
            prompt = f"""Professional e-commerce product photography of a single clothing item:

{item_description}

Photography specifications:
- {background_map.get(background, background_map["white"])}
- {view_map.get(view_angle, view_map["front"])}
- {"Subtle natural drop shadow for depth" if include_shadows else "No shadows, completely clean and isolated"}
- High-end fashion catalog quality
- Sharp focus throughout
- Accurate, true-to-life colors{f": {color_desc}" if color_desc else ""}
- Realistic fabric textures{f" showing {material} clearly" if material else ""}
- Professional studio lighting with soft highlights
- The item should be displayed flat or on an invisible mannequin
- ONLY this single {category_name} should be visible
- No model, no other clothing items, no accessories unless part of this item
- Clean, isolated product shot suitable for an online store listing

MANDATORY QUALITY CONTROL (INTERNAL):
- Think twice before you generate.
- Re-evaluate the item description before rendering.
- Internally verify category, shape, materials, colors, and all specified details match exactly.""".strip()

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

        clothing_desc = f"\n\nClothing details: {clothing_description}" if clothing_description else ""

        prompt = f"""Create a photorealistic fashion photograph showing the person from the first image wearing the clothing item shown in the second image.

CRITICAL REQUIREMENTS:
1. PRESERVE EXACT FACE IDENTITY (MOST IMPORTANT):
   - This must look like the EXACT SAME PERSON from the first (reference) image
   - Maintain identical facial structure: face shape, jawline, chin, cheekbones
   - Preserve exact eye features: eye shape, color, spacing, eyebrows, eyelids
   - Keep identical nose: shape, bridge, nostrils, size, proportions
   - Maintain exact mouth: lip shape, fullness, width, smile characteristics
   - Preserve exact skin tone, texture, and any distinguishing marks (moles, freckles)
   - Keep the same apparent age and gender presentation
   - Match hair color, style, texture, and hairline exactly

2. CLOTHING ACCURACY: The clothing item must be rendered exactly as shown in the second image - same colors, patterns, textures, style, and fit.
   - Keep exact garment/accessory/footwear details if visible (logos, seams, stitching, hardware, laces, buckles, zippers, embellishments)
   - Do not add or remove any clothing element
   - Do not swap style, cut, silhouette, or layer structure

3. NATURAL INTEGRATION: The clothing should fit naturally on the person's body with realistic draping, shadows, and fabric behavior.

4. SINGLE OUTPUT: Generate one cohesive image of the person wearing the clothes.

Style specifications:
- Overall style: {style}
- Background: {background}
- Pose: {pose}
- Lighting: {lighting}
- Image quality: High-end editorial fashion photography, sharp focus, realistic fabric textures, accurate colors{clothing_desc}

{NEGATIVE_PROMPTS}

{QUALITY_CONTROL_PROMPT}

Output a single, high-quality photorealistic image that looks like a professional fashion photograph of THIS EXACT PERSON wearing these specific clothes."""

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
