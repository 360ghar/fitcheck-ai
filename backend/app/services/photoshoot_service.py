"""
Photoshoot service for AI-powered photoshoot generation.

Handles prompt generation, image generation via AIProviderService,
and usage tracking for daily limits.
"""

import asyncio
import json
import logging
import re
import uuid
from datetime import datetime, date, timedelta
from typing import List, Optional, Tuple

from supabase import Client

from app.core.config import settings
from app.core.exceptions import AIServiceError, DatabaseError, RateLimitError, ServiceError, ValidationError
from app.models.photoshoot import (
    PhotoshootUseCase,
    PhotoshootStatus,
    PhotoshootPrompt,
    GeneratedImage,
    PhotoshootUsage,
    PhotoshootResultResponse,
    UseCaseInfo,
)
from app.models.subscription import PlanType
from app.services.subscription_service import SubscriptionService

logger = logging.getLogger(__name__)


# =============================================================================
# Use Case Templates
# =============================================================================

USE_CASE_TEMPLATES = {
    PhotoshootUseCase.LINKEDIN: {
        "name": "LinkedIn Profile",
        "description": "Professional headshots for LinkedIn and business profiles",
        "prompt_guidance": """Generate diverse professional headshot prompts for LinkedIn. Include variations of:
- Indoor office/modern workspace settings with floor-to-ceiling windows
- Outdoor professional settings (city architecture, urban backgrounds)
- Neutral studio backgrounds (white, gray, gradient)
Mix of:
- Business formal attire (tailored suits, blazers, professional dresses)
- Business casual (button-down shirts, smart casual)
- Confident, approachable expressions with natural smiles
- Various angles (front view, 3/4 view, slight turn)
Lighting should be professional, flattering, soft natural or studio lighting.""",
        "example_prompts": [
            "Professional headshot in modern office",
            "Business portrait with city skyline background",
            "Corporate photo with neutral backdrop",
        ],
    },
    PhotoshootUseCase.DATING_APP: {
        "name": "Dating App Profile",
        "description": "Attractive, genuine photos for dating profiles",
        "prompt_guidance": """Generate diverse dating profile photo prompts. Include variations of:
- Casual outdoor settings (trendy cafes, parks, beaches, city streets)
- Lifestyle activities (travel destinations, hobbies, social settings)
- Well-lit indoor settings with warm ambiance
Mix of:
- Casual, stylish everyday attire
- Relaxed, genuine smiles showing personality
- Full body and upper body shots
- Candid-style action shots that feel natural
Mood should be warm, inviting, approachable, and authentic.""",
        "example_prompts": [
            "Casual portrait at a coffee shop",
            "Outdoor photo in a park at golden hour",
            "Travel photo with scenic background",
        ],
    },
    PhotoshootUseCase.MODEL_PORTFOLIO: {
        "name": "Model Portfolio",
        "description": "High-fashion model portfolio shots",
        "prompt_guidance": """Generate diverse high-fashion model portfolio prompts. Include variations of:
- Professional studio setups with dramatic lighting
- Editorial/magazine-style on-location settings
- High-fashion outdoor locations (rooftops, architecture, urban)
Mix of:
- Various editorial poses (confident, artistic, dynamic)
- Different outfit styles (haute couture, streetwear, formal wear, avant-garde)
- Dramatic and high-contrast lighting setups
- Full body, 3/4 length, and dramatic close-up shots
Style should be high-end fashion photography with editorial quality.""",
        "example_prompts": [
            "Editorial fashion shot in studio",
            "High-fashion portrait with dramatic lighting",
            "Streetwear lookbook style photo",
        ],
    },
    PhotoshootUseCase.INSTAGRAM: {
        "name": "Instagram Content",
        "description": "Trendy, aesthetic Instagram-worthy content",
        "prompt_guidance": """Generate diverse Instagram-worthy photo prompts. Include variations of:
- Aesthetic cafes, rooftops, Instagrammable spots
- Golden hour and blue hour lighting conditions
- Trendy urban and natural backdrops
Mix of:
- Lifestyle and candid moments that feel curated
- Fashion-forward, on-trend outfits
- Flattering angles and poses that photograph well
- Mix of portrait, full body, and environmental shots
Aesthetic should be curated, cohesive, and scroll-stopping with high visual appeal.""",
        "example_prompts": [
            "Aesthetic cafe photo with good lighting",
            "Golden hour portrait in the city",
            "Lifestyle shot at a trendy location",
        ],
    },
    PhotoshootUseCase.AESTHETIC: {
        "name": "Aesthetic",
        "description": "Trendy, artistic aesthetic photos with creative styling",
        "prompt_guidance": """Generate diverse aesthetic photo prompts with artistic flair. Include variations of:
- Minimalist backgrounds with clean compositions
- Soft pastel or moody color palettes
- Artistic architectural elements and textures
- Natural settings with dreamy, ethereal quality
Mix of:
- Fashion-forward, curated outfit styling
- Artistic and creative poses
- Soft, diffused lighting with gentle shadows
- Mix of close-ups and environmental portraits
Style should be visually cohesive, Instagram-worthy, and artistically compelling.""",
        "example_prompts": [
            "Minimalist portrait with soft natural light",
            "Dreamy aesthetic photo at golden hour",
            "Artistic portrait with pastel backdrop",
        ],
    },
    PhotoshootUseCase.CUSTOM: {
        "name": "Custom",
        "description": "Create your own custom photoshoot theme",
        "prompt_guidance": "",  # Will be replaced with user's custom prompt
        "example_prompts": [],
    },
}


class PhotoshootService:
    """Service for managing photoshoot generation and usage tracking."""

    # =========================================================================
    # Use Case Information
    # =========================================================================

    @staticmethod
    def get_use_cases() -> List[UseCaseInfo]:
        """Get all available use cases with descriptions."""
        return [
            UseCaseInfo(
                id=use_case.value,
                name=info["name"],
                description=info["description"],
                example_prompts=info.get("example_prompts", []),
            )
            for use_case, info in USE_CASE_TEMPLATES.items()
        ]

    # =========================================================================
    # Daily Usage Tracking
    # =========================================================================

    @staticmethod
    def _get_today() -> date:
        """Get today's date in UTC."""
        return datetime.utcnow().date()

    @staticmethod
    def _get_daily_limit(plan_type: PlanType) -> int:
        """Get the daily photoshoot image limit for a plan type."""
        if plan_type in (PlanType.PRO_MONTHLY, PlanType.PRO_YEARLY):
            return settings.PLAN_PRO_DAILY_PHOTOSHOOT_IMAGES
        return settings.PLAN_FREE_DAILY_PHOTOSHOOT_IMAGES

    @staticmethod
    async def get_or_create_daily_usage(user_id: str, db: Client) -> dict:
        """Get or create daily photoshoot usage record."""
        period_start = SubscriptionService._get_current_period_start()

        try:
            # Ensure monthly usage record exists
            await SubscriptionService.get_or_create_usage_record(user_id, db)

            # Prefer DB-side reset for correctness/atomicity (migration 010)
            try:
                db.rpc(
                    "reset_daily_photoshoot_if_needed",
                    {
                        "p_user_id": user_id,
                        "p_period_start": period_start.isoformat(),
                    },
                ).execute()
            except Exception as e:
                # Migration may not be applied yet; fall back to app-side reset in get_usage().
                logger.debug(f"RPC reset_daily_photoshoot_if_needed not available: {e}")

            result = (
                db.table("subscription_usage")
                .select("*")
                .eq("user_id", user_id)
                .eq("period_start", period_start.isoformat())
                .single()
                .execute()
            )

            return result.data or {}

        except Exception as e:
            logger.error(f"Error getting daily usage for user {user_id}: {e}")
            raise DatabaseError(f"Failed to get daily usage: {str(e)}")

    @staticmethod
    async def get_usage(user_id: str, db: Client) -> PhotoshootUsage:
        """Get user's photoshoot usage for today."""
        try:
            subscription = await SubscriptionService.get_subscription(user_id, db)
            daily_limit = PhotoshootService._get_daily_limit(subscription.plan_type)

            usage_record = await PhotoshootService.get_or_create_daily_usage(user_id, db)
            used_today = usage_record.get("daily_photoshoot_images", 0) or 0

            # Fallback daily reset if DB function isn't available/applied.
            today = PhotoshootService._get_today()
            last_reset = usage_record.get("last_photoshoot_reset")
            if last_reset:
                try:
                    last_reset_date = (
                        date.fromisoformat(last_reset)
                        if isinstance(last_reset, str)
                        else last_reset
                    )
                    if last_reset_date < today:
                        period_start = SubscriptionService._get_current_period_start()
                        db.table("subscription_usage").update(
                            {
                                "daily_photoshoot_images": 0,
                                "last_photoshoot_reset": today.isoformat(),
                            }
                        ).eq("user_id", user_id).eq(
                            "period_start", period_start.isoformat()
                        ).execute()
                        used_today = 0
                except Exception as e:
                    logger.debug(f"Failed to parse last_photoshoot_reset date: {e}")

            # Calculate reset time (midnight UTC)
            tomorrow = today + timedelta(days=1)
            resets_at = datetime.combine(tomorrow, datetime.min.time())

            return PhotoshootUsage(
                used_today=used_today,
                limit_today=daily_limit,
                remaining=max(0, daily_limit - used_today),
                plan_type=subscription.plan_type.value,
                resets_at=resets_at,
            )

        except Exception as e:
            logger.error(f"Error getting photoshoot usage for user {user_id}: {e}")
            raise DatabaseError(f"Failed to get photoshoot usage: {str(e)}")

    @staticmethod
    async def check_daily_limit(
        user_id: str,
        num_images: int,
        db: Client,
    ) -> Tuple[bool, PhotoshootUsage]:
        """Check if user can generate the requested number of images."""
        usage = await PhotoshootService.get_usage(user_id, db)

        if num_images > usage.remaining:
            return False, usage

        return True, usage

    @staticmethod
    async def increment_usage(
        user_id: str,
        num_images: int,
        db: Client,
    ) -> None:
        """Increment daily photoshoot usage."""
        try:
            period_start = SubscriptionService._get_current_period_start()

            # Ensure usage record exists
            await SubscriptionService.get_or_create_usage_record(user_id, db)

            # Use atomic increment via RPC when available (migration 010)
            try:
                db.rpc(
                    "increment_usage",
                    {
                        "p_user_id": user_id,
                        "p_period_start": period_start.isoformat(),
                        "p_field": "daily_photoshoot_images",
                        "p_count": num_images,
                    },
                ).execute()
                return
            except Exception as rpc_err:
                logger.debug(f"RPC increment_usage not available, using fallback: {rpc_err}")

            # Fallback: Use SQL UPDATE with increment expression for atomicity
            # This is safer than read-then-write but still not fully atomic
            try:
                db.table("subscription_usage").update(
                    {"daily_photoshoot_images": db.func("daily_photoshoot_images + %s", num_images)}
                ).eq("user_id", user_id).eq("period_start", period_start.isoformat()).execute()
            except Exception:
                # Final fallback: non-atomic update (best-effort)
                usage_record = await PhotoshootService.get_or_create_daily_usage(user_id, db)
                current = usage_record.get("daily_photoshoot_images", 0) or 0
                db.table("subscription_usage").update(
                    {"daily_photoshoot_images": current + num_images}
                ).eq("user_id", user_id).eq("period_start", period_start.isoformat()).execute()

            logger.debug(f"Incremented photoshoot usage for user {user_id} by {num_images}")

        except Exception as e:
            logger.error(f"Error incrementing photoshoot usage for user {user_id}: {e}")
            # Don't raise - usage tracking failure shouldn't block the operation

    # =========================================================================
    # Prompt Generation
    # =========================================================================

    @staticmethod
    async def generate_prompts(
        use_case: PhotoshootUseCase,
        num_prompts: int,
        custom_prompt: Optional[str] = None,
        reference_photo: Optional[str] = None,
    ) -> List[PhotoshootPrompt]:
        """Generate diverse prompts for photoshoot images using LLM."""
        from app.services.ai_provider_service import ChatMessage, get_ai_service, quick_vision

        # Get the prompt guidance for this use case
        if use_case == PhotoshootUseCase.CUSTOM and custom_prompt:
            guidance = f"User's custom request: {custom_prompt}\n\nGenerate diverse variations based on this theme."
        else:
            template = USE_CASE_TEMPLATES.get(use_case, USE_CASE_TEMPLATES[PhotoshootUseCase.LINKEDIN])
            guidance = template["prompt_guidance"]

        subject_hint = ""
        if reference_photo:
            try:
                photo = reference_photo
                if "," in photo and photo.strip().lower().startswith("data:"):
                    photo = photo.split(",", 1)[1]
                subject_hint = await quick_vision(
                    prompt=(
                        "Analyze this person's appearance in detail for photoshoot generation. "
                        "Provide a comprehensive description including:\n"
                        "1. FACE: Face shape (oval/round/square/heart/oblong), jawline definition, chin shape, cheekbone prominence\n"
                        "2. EYES: Eye shape, eye color, eye spacing, eyebrow shape and thickness, eyelid type\n"
                        "3. NOSE: Nose shape, nose bridge (high/low/straight/curved), nostril shape, nose size\n"
                        "4. MOUTH: Lip shape, lip fullness, mouth width, any distinctive smile characteristics\n"
                        "5. SKIN: Skin tone (specific shade), skin texture, any visible marks, moles, freckles, or scars\n"
                        "6. HAIR: Hair color (specific shade), hair texture (straight/wavy/curly), hairstyle, hairline, facial hair if any\n"
                        "7. GENDER & AGE: Apparent gender presentation, approximate age range\n"
                        "8. BUILD: Body type, build, approximate proportions\n"
                        "9. DISTINCTIVE FEATURES: Any other unique or distinguishing characteristics\n\n"
                        "Be specific and detailed - this description will be used to ensure the generated images "
                        "look exactly like this person, not just someone similar."
                    ),
                    image_base64=photo,
                )
            except Exception as e:
                logger.debug(f"Failed to extract subject hint from reference photo: {e}")
                subject_hint = ""

        system_prompt = f"""You are a professional fashion photographer planning a photoshoot.
Generate exactly {num_prompts} diverse, detailed image generation prompts.

IMPORTANT: You will receive a detailed description of the person from the reference photo.
You MUST include this complete person description at the START of every full_prompt.

Return a JSON array with this exact structure:
[
  {{
    "index": 0,
    "setting": "Description of the location/background",
    "outfit": "Description of the clothing/attire",
    "pose": "Description of the pose and body position",
    "lighting": "Description of the lighting setup",
    "style": "Overall style category",
    "mood": "The emotional tone/mood",
    "full_prompt": "Complete detailed prompt - MUST start with the person description, then the scene"
  }}
]

Each prompt should be unique and cover different aspects of the use case.
The full_prompt should be a detailed, cohesive description suitable for an AI image generator.

CRITICAL - PERSON DESCRIPTION REQUIREMENT:
Each full_prompt MUST begin with the complete person description provided in Subject notes.
This ensures every generated image depicts the EXACT SAME PERSON with identical:
- Facial features (face shape, eyes, nose, mouth, jawline)
- Skin tone and texture
- Hair color, style, and texture
- Apparent age and gender
- Body type and proportions
- Any distinguishing marks or features

The scene description (setting, outfit, pose, etc.) comes AFTER the person description.
"""

        try:
            ai_service = await get_ai_service()
            try:
                if subject_hint:
                    user_prompt = f"""{guidance}

=== PERSON DESCRIPTION (from reference photo) ===
{subject_hint}
=== END PERSON DESCRIPTION ===

IMPORTANT: Include this complete person description at the START of every full_prompt you generate.
"""
                else:
                    user_prompt = guidance

                response = await ai_service.chat(
                    messages=[
                        ChatMessage(role="system", content=system_prompt),
                        ChatMessage(role="user", content=user_prompt),
                    ],
                    temperature=0.8,
                )
            finally:
                await ai_service.close()

            content = response.text or ""
            if not content:
                raise AIServiceError("Prompt generation returned empty response")

            json_str = PhotoshootService._extract_json_array(content)
            prompts_data = json.loads(json_str)
            if not isinstance(prompts_data, list):
                raise AIServiceError("Prompt generation response was not a JSON array")

            prompts: List[PhotoshootPrompt] = []
            for i, p in enumerate(prompts_data[:num_prompts]):
                if not isinstance(p, dict):
                    continue
                full_prompt = (p.get("full_prompt") or "").strip()
                if not full_prompt:
                    continue
                prompts.append(
                    PhotoshootPrompt(
                        index=int(p.get("index", i)),
                        setting=(p.get("setting") or "").strip(),
                        outfit=(p.get("outfit") or "").strip(),
                        pose=(p.get("pose") or "").strip(),
                        lighting=(p.get("lighting") or "").strip(),
                        style=(p.get("style") or "").strip(),
                        mood=(p.get("mood") or "").strip(),
                        full_prompt=full_prompt,
                    )
                )

            if len(prompts) >= num_prompts:
                return prompts[:num_prompts]

            # Fall back to templates if the model under-generated or returned invalid JSON entries
            logger.warning(
                f"Prompt generation incomplete, using fallback prompts (want={num_prompts}, got={len(prompts)})"
            )
            fallback = PhotoshootService._fallback_prompts(
                use_case=use_case,
                num_prompts=num_prompts,
                custom_prompt=custom_prompt,
                subject_hint=subject_hint,
            )
            return fallback

        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse prompts JSON: {e}")
            return PhotoshootService._fallback_prompts(
                use_case=use_case,
                num_prompts=num_prompts,
                custom_prompt=custom_prompt,
                subject_hint=subject_hint,
            )
        except Exception as e:
            logger.error(f"Error generating prompts: {e}")
            return PhotoshootService._fallback_prompts(
                use_case=use_case,
                num_prompts=num_prompts,
                custom_prompt=custom_prompt,
                subject_hint=subject_hint,
            )

    @staticmethod
    def _extract_json_array(text: str) -> str:
        """
        Extract the first top-level JSON array from a model response.

        Handles responses wrapped in markdown fences or with extra prose.
        """
        if not text:
            raise AIServiceError("Empty prompt generation response")

        # Remove markdown code fences if present
        fenced = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text, re.IGNORECASE)
        if fenced:
            text = fenced.group(1)

        start = text.find("[")
        if start < 0:
            raise AIServiceError("Prompt generation response did not contain a JSON array")

        depth = 0
        for i in range(start, len(text)):
            ch = text[i]
            if ch == "[":
                depth += 1
            elif ch == "]":
                depth -= 1
                if depth == 0:
                    return text[start : i + 1]

        raise AIServiceError("Unterminated JSON array in prompt generation response")

    @staticmethod
    def _fallback_prompts(
        use_case: PhotoshootUseCase,
        num_prompts: int,
        custom_prompt: Optional[str],
        subject_hint: str,
    ) -> List[PhotoshootPrompt]:
        base = "Professional photorealistic portrait photo of the same person as the reference photos."
        if subject_hint:
            base = f"{base} {subject_hint}"

        if use_case == PhotoshootUseCase.CUSTOM and custom_prompt:
            theme = f"Theme: {custom_prompt.strip()}."
        else:
            theme = f"Use case: {use_case.value}."

        seeds = [
            ("modern studio", "minimalist monochrome outfit", "3/4 angle portrait", "softbox key light", "editorial", "confident"),
            ("sunlit cafe", "smart casual", "candid seated", "natural window light", "lifestyle", "approachable"),
            ("city street", "tailored blazer", "walking mid-step", "golden hour", "street style", "energetic"),
            ("office", "business formal", "front-facing headshot", "soft natural light", "corporate", "professional"),
            ("rooftop", "fashion-forward look", "power stance", "dramatic rim light", "high-fashion", "bold"),
            ("park", "casual layered outfit", "relaxed smile", "diffused daylight", "candid", "warm"),
            ("neutral backdrop", "classic formal", "close-up portrait", "studio lighting", "headshot", "friendly"),
            ("hotel lobby", "elevated evening wear", "three-quarter body", "warm ambient light", "luxury", "poised"),
            ("beach", "summer casual", "looking over shoulder", "sunset light", "travel", "joyful"),
            ("gallery", "modern chic", "artistic pose", "moody spotlight", "editorial", "thoughtful"),
        ]

        prompts: List[PhotoshootPrompt] = []
        for i in range(num_prompts):
            setting, outfit, pose, lighting, style, mood = seeds[i % len(seeds)]
            full_prompt = (
                f"{base} {theme} "
                f"Setting: {setting}. Outfit: {outfit}. Pose: {pose}. "
                f"Lighting: {lighting}. Style: {style}. Mood: {mood}. "
                "High-end professional photography, sharp focus, flattering composition."
            )
            prompts.append(
                PhotoshootPrompt(
                    index=i,
                    setting=setting,
                    outfit=outfit,
                    pose=pose,
                    lighting=lighting,
                    style=style,
                    mood=mood,
                    full_prompt=full_prompt,
                )
            )
        return prompts

    # =========================================================================
    # Image Generation (using AIProviderService)
    # =========================================================================

    @staticmethod
    async def generate_images(
        reference_photos: List[str],
        prompts: List[PhotoshootPrompt],
        user_id: Optional[str] = None,
        db: Optional[Client] = None,
    ) -> List[GeneratedImage]:
        """Generate photoshoot images using AIProviderService.

        Uses the existing image generation infrastructure with identity preservation
        via reference images and parallel processing with concurrency control.
        """
        from app.services.ai_provider_service import ChatMessage, get_ai_service
        from app.services.ai_settings_service import AISettingsService

        # Normalize reference photos (strip data URL prefix if present)
        normalized_refs = []
        for photo in reference_photos:
            if photo and "," in photo and photo.strip().lower().startswith("data:"):
                normalized_refs.append(photo.split(",", 1)[1])
            else:
                normalized_refs.append(photo.strip() if photo else "")
        normalized_refs = [p for p in normalized_refs if p]

        if not normalized_refs:
            raise ServiceError("At least one reference photo is required")

        # Get AI service (user-specific if available, otherwise system default)
        if user_id and db:
            ai_service = await AISettingsService.get_ai_service_for_user(user_id, db)
        else:
            ai_service = await get_ai_service()

        try:
            async def generate_single(prompt: PhotoshootPrompt) -> Optional[GeneratedImage]:
                """Generate a single photoshoot image with identity preservation."""
                # Build multi-image content for identity preservation
                content = []

                # Add reference images
                for ref_photo in normalized_refs:
                    ref_url = f"data:image/jpeg;base64,{ref_photo}" if not ref_photo.startswith("data:") else ref_photo
                    content.append({
                        "type": "image_url",
                        "image_url": {"url": ref_url}
                    })

                # Add the generation prompt with comprehensive face adherence
                enhanced_prompt = f"""{prompt.full_prompt}

CRITICAL FACE ADHERENCE REQUIREMENTS:
This is a photoshoot of the EXACT SAME PERSON shown in the reference image(s).
The generated image MUST be this specific individual - not someone who looks similar.

FACE IDENTITY - MANDATORY EXACT MATCH:
- EXACT facial structure: face shape, jawline, chin, cheekbones must be identical
- EXACT eye features: eye shape, eye color, eye spacing, eyebrows, eyelid shape
- EXACT nose: nose shape, nose bridge, nostril shape, nose size and proportions
- EXACT mouth: lip shape, lip fullness, mouth width, smile characteristics
- EXACT skin: skin tone, skin texture, any visible marks, moles, or features
- EXACT hair: hair color, hair texture, hairstyle, hairline, facial hair if any
- EXACT age appearance: maintain the same apparent age - do not make younger or older
- EXACT gender presentation: maintain the same gender appearance

STRUCTURAL PRESERVATION:
- Face proportions and symmetry must match reference exactly
- Head shape and size relative to body must be consistent
- Ear shape and position if visible must match
- Neck proportions must be consistent with reference

DO NOT:
- Idealize, beautify, or modify any facial features
- Change apparent age, gender, or ethnicity
- Alter face shape or bone structure
- Smooth, filter, or modify skin texture unnaturally
- Change any distinguishing facial characteristics

Generate a single high-quality photorealistic image of THIS EXACT PERSON."""

                content.append({"type": "text", "text": enhanced_prompt})

                messages = [ChatMessage(role="user", content=content)]

                response = await ai_service.chat(
                    messages=messages,
                    model=ai_service.config.get_image_gen_model(),
                    response_modalities=["TEXT", "IMAGE"],
                )

                if not response.images:
                    logger.warning(f"No images generated for prompt {prompt.index}")
                    return None

                return GeneratedImage(
                    id=f"img_{uuid.uuid4().hex[:8]}",
                    index=prompt.index,
                    image_base64=response.images[0],
                    image_url=None,
                )

            # Process with concurrency control (configurable via settings)
            concurrency_limit = getattr(settings, 'PHOTOSHOOT_CONCURRENCY_LIMIT', 3)
            semaphore = asyncio.Semaphore(concurrency_limit)

            async def generate_with_semaphore(prompt: PhotoshootPrompt) -> Optional[GeneratedImage]:
                async with semaphore:
                    try:
                        return await generate_single(prompt)
                    except Exception as e:
                        logger.error(f"Failed to generate image {prompt.index}: {e}")
                        return None

            tasks = [generate_with_semaphore(p) for p in prompts]
            results = await asyncio.gather(*tasks, return_exceptions=True)

            # Filter successful results
            successful: List[GeneratedImage] = []
            for i, result in enumerate(results):
                if isinstance(result, GeneratedImage):
                    successful.append(result)
                elif isinstance(result, Exception):
                    logger.error(f"Image {i} generation failed with exception: {result}")
                else:
                    logger.warning(f"Image {i} generation returned None")

            if not successful:
                raise ServiceError("All image generations failed")

            # Sort by index
            successful.sort(key=lambda img: img.index)

            logger.info(f"Successfully generated {len(successful)}/{len(prompts)} images")
            return successful

        finally:
            await ai_service.close()

    # =========================================================================
    # Full Photoshoot Generation Flow
    # =========================================================================

    @staticmethod
    async def generate_photoshoot(
        user_id: str,
        photos: List[str],
        use_case: PhotoshootUseCase,
        num_images: int,
        db: Client,
        custom_prompt: Optional[str] = None,
    ) -> PhotoshootResultResponse:
        """Generate a complete photoshoot with the specified parameters."""
        import time

        start_time = time.time()
        session_id = f"ps_{uuid.uuid4().hex[:12]}"

        try:
            # Validate custom prompt requirement
            if use_case == PhotoshootUseCase.CUSTOM and not custom_prompt:
                raise ValidationError("Custom prompt is required for custom use case")

            # Check daily limit
            allowed, usage = await PhotoshootService.check_daily_limit(user_id, num_images, db)
            if not allowed:
                raise RateLimitError(
                    message=f"Daily limit exceeded. You have {usage.remaining} images remaining today.",
                    retry_after=int((usage.resets_at - datetime.utcnow()).total_seconds()) if usage.resets_at else 86400,
                )

            # Generate prompts
            prompts = await PhotoshootService.generate_prompts(
                use_case=use_case,
                num_prompts=num_images,
                custom_prompt=custom_prompt,
                reference_photo=photos[0] if photos else None,
            )

            # Generate images using AIProviderService
            images = await PhotoshootService.generate_images(
                reference_photos=photos,
                prompts=prompts,
                user_id=user_id,
                db=db,
            )

            # Increment usage
            await PhotoshootService.increment_usage(user_id, len(images), db)

            # Get updated usage
            updated_usage = await PhotoshootService.get_usage(user_id, db)

            generation_time = time.time() - start_time

            return PhotoshootResultResponse(
                session_id=session_id,
                status=PhotoshootStatus.COMPLETE,
                images=images,
                usage=updated_usage,
                generation_time_seconds=round(generation_time, 2),
            )

        except (ValidationError, RateLimitError, ServiceError, DatabaseError):
            raise
        except Exception as e:
            logger.exception(f"Error in photoshoot generation for user {user_id}: {e}")
            raise ServiceError("Photoshoot generation failed", service_name="photoshoot")
