"""
Photoshoot service for AI-powered photoshoot generation.

Handles prompt generation, image generation via AIProviderService,
and usage tracking for daily limits.
"""

import asyncio
import json
import re
import uuid
from datetime import datetime, date, timedelta
from typing import List, Optional, Tuple

from supabase import Client

from app.agents.prompt_fidelity import (
    FACE_VISIBLE_POSE_RULE,
    IDENTITY_SAFE_DIVERSITY_RULE,
    PHOTOSHOOT_FIDELITY_APPENDIX,
    SUBJECT_LOCK_FIELDS,
    sandwich_prompt,
)
from app.core.config import settings
from app.core.exceptions import AIServiceError, DatabaseError, RateLimitError, ServiceError, ValidationError
from app.core.logging_config import get_context_logger
from app.models.photoshoot import (
    PhotoshootUseCase,
    PhotoshootStatus,
    PhotoshootPrompt,
    GeneratedImage,
    ImageGenerationFailure,
    PhotoshootUsage,
    PhotoshootResultResponse,
    UseCaseInfo,
)
from app.models.subscription import PlanType
from app.services.photoshoot_job_service import PhotoshootJob
from app.services.subscription_service import SubscriptionService

logger = get_context_logger(__name__)


# =============================================================================
# Use Case Templates
# =============================================================================

_IDENTITY_SAFE_SUFFIX = f"""
IDENTITY RULES (mandatory for every prompt):
- {IDENTITY_SAFE_DIVERSITY_RULE}
- {FACE_VISIBLE_POSE_RULE}
- Outfit descriptions must be item-level (top, bottom, outerwear, footwear, accessories) with color shade, material, and silhouette — never vague "stylish look".
"""

USE_CASE_TEMPLATES = {
    PhotoshootUseCase.LINKEDIN: {
        "name": "LinkedIn Profile",
        "description": "Professional headshots for LinkedIn and business profiles",
        "prompt_guidance": """Generate diverse professional headshot prompts for LinkedIn. Vary ONLY setting, outfit, pose, and lighting:
- Indoor office/modern workspace with large windows
- Outdoor professional settings (city architecture, urban backgrounds)
- Neutral studio backgrounds (white, gray, gradient)
Outfits: business formal (suits, blazers) and business casual (button-downs)
Expressions: confident, approachable, natural smile — keep the same face identity
Angles: front view or slight 3/4 only
Lighting: soft natural or soft studio light, even on the face
""" + _IDENTITY_SAFE_SUFFIX,
        "example_prompts": [
            "Professional headshot in modern office",
            "Business portrait with city skyline background",
            "Corporate photo with neutral backdrop",
        ],
    },
    PhotoshootUseCase.DATING_APP: {
        "name": "Dating App Profile",
        "description": "Attractive, genuine photos for dating profiles",
        "prompt_guidance": """Generate diverse dating profile photo prompts. Vary ONLY setting, outfit, pose, and lighting:
- Casual outdoor settings (cafes, parks, beaches, city streets)
- Lifestyle activities (travel, hobbies) with face still clearly visible
- Well-lit indoor settings with warm ambiance
Outfits: casual everyday with concrete item detail
Shots: upper body and full body; avoid face occlusion and sunglasses
Mood: warm, approachable, authentic — not glamorized or beauty-filtered
""" + _IDENTITY_SAFE_SUFFIX,
        "example_prompts": [
            "Casual portrait at a coffee shop",
            "Outdoor photo in a park at golden hour",
            "Travel photo with scenic background",
        ],
    },
    PhotoshootUseCase.MODEL_PORTFOLIO: {
        "name": "Model Portfolio",
        "description": "High-fashion model portfolio shots",
        "prompt_guidance": """Generate diverse portfolio prompts. Vary ONLY setting, outfit, pose, and lighting — keep the same real person (not a generic model face):
- Studio setups and on-location editorial settings
- Outdoor locations (rooftops, architecture, urban)
Outfits: couture, streetwear, formal — item-level detail required
Poses: confident/editorial but face still readable (avoid extreme profile)
Lighting can be dramatic but keep face features recognizable
""" + _IDENTITY_SAFE_SUFFIX,
        "example_prompts": [
            "Editorial fashion shot in studio",
            "Fashion portrait with dramatic lighting",
            "Streetwear lookbook style photo",
        ],
    },
    PhotoshootUseCase.INSTAGRAM: {
        "name": "Instagram Content",
        "description": "Trendy, aesthetic Instagram-worthy content",
        "prompt_guidance": """Generate diverse Instagram-style prompts. Vary ONLY setting, outfit, pose, and lighting:
- Cafes, rooftops, urban and natural backdrops
- Golden hour / blue hour lighting with face still evenly lit enough to recognize
Outfits: on-trend with concrete item detail
Mix portrait, 3/4, and full body — face must remain clearly visible
Avoid beauty-filter language and idealized skin
""" + _IDENTITY_SAFE_SUFFIX,
        "example_prompts": [
            "Cafe photo with good lighting",
            "Golden hour portrait in the city",
            "Lifestyle shot at a trendy location",
        ],
    },
    PhotoshootUseCase.AESTHETIC: {
        "name": "Aesthetic",
        "description": "Trendy, artistic aesthetic photos with creative styling",
        "prompt_guidance": """Generate diverse aesthetic prompts. Vary ONLY setting, outfit, pose, and lighting:
- Minimalist backgrounds, pastel or moody palettes, architectural textures
- Soft diffused light with gentle shadows (face still recognizable)
Outfits: curated with item-level detail
Poses can be creative but not extreme profile; no face occlusion
Do not invent a different face or idealized beauty look
""" + _IDENTITY_SAFE_SUFFIX,
        "example_prompts": [
            "Minimalist portrait with soft natural light",
            "Soft aesthetic photo at golden hour",
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
        """Generate diverse prompts for photoshoot images using a single multimodal LLM call.

        This combines subject analysis and prompt generation into one API call for efficiency.
        """
        from app.services.ai_provider_service import ChatMessage, get_ai_service

        # Get the prompt guidance for this use case
        if use_case == PhotoshootUseCase.CUSTOM and custom_prompt:
            guidance = (
                f"User's custom request: {custom_prompt}\n\n"
                f"Generate diverse variations based on this theme.\n{_IDENTITY_SAFE_SUFFIX}"
            )
        else:
            template = USE_CASE_TEMPLATES.get(use_case, USE_CASE_TEMPLATES[PhotoshootUseCase.LINKEDIN])
            guidance = template["prompt_guidance"]

        # Combined system prompt: low-creativity identity analysis + scene diversity
        system_prompt = f"""You are a professional fashion photographer planning a photoshoot for a WEAK image model.
Your job is to lock identity tightly and only vary setting/outfit/pose/lighting.

TASK: Analyze the person in the reference image AND generate {num_prompts} photoshoot scene plans.

STEP 1 - SUBJECT LOCK (identity source of truth):
{SUBJECT_LOCK_FIELDS}
Also set subject_description to the same subject_lock text.

STEP 2 - SCENE PLANS:
Generate exactly {num_prompts} diverse scenes. Diversity = setting, outfit, pose, lighting only.
For each scene, outfit must list concrete items:
- top(s), bottom(s), outerwear (if any), footwear, accessories
- color shades, materials, textures, silhouette/fit, notable details
- never vague phrases like "stylish look"

Return a JSON object with this exact structure:
{{
  "subject_lock": "Dense biometric paragraph from Step 1 (concrete visual tokens only)",
  "subject_description": "Same as subject_lock",
  "prompts": [
    {{
      "index": 0,
      "setting": "Location/background only",
      "outfit": "Item-level clothing inventory",
      "pose": "Pose with face clearly visible",
      "lighting": "Lighting setup",
      "style": "Overall style category",
      "mood": "Mood (do not describe a new face)",
      "scene_body": "Setting + outfit + pose + lighting + style + mood only — NO person description"
    }}
  ]
}}

RULES:
- {IDENTITY_SAFE_DIVERSITY_RULE}
- {FACE_VISIBLE_POSE_RULE}
- Do NOT invent facial features not visible in the reference
- Do NOT put person identity text in scene_body (we sandwich subject_lock in code)
- Keep subject_lock factual and dense; avoid beauty language
"""

        subject_hint = ""  # Will be extracted from response if available

        try:
            ai_service = await get_ai_service()
            try:
                # Build the message content - multimodal if we have a reference photo
                if reference_photo:
                    # Normalize the photo (strip data URL prefix if present)
                    photo = reference_photo
                    if "," in photo and photo.strip().lower().startswith("data:"):
                        photo = photo.split(",", 1)[1]

                    # Create multimodal content with image + text
                    ref_url = f"data:image/jpeg;base64,{photo}" if not photo.startswith("data:") else photo
                    user_content = [
                        {
                            "type": "image_url",
                            "image_url": {"url": ref_url}
                        },
                        {
                            "type": "text",
                            "text": (
                                f"Use case guidance:\n{guidance}\n\n"
                                f"Analyze this person and generate {num_prompts} scene plans as JSON. "
                                "Be factual about identity; only invent diversity in setting/outfit/pose/lighting."
                            ),
                        }
                    ]

                    response = await ai_service.chat(
                        messages=[
                            ChatMessage(role="system", content=system_prompt),
                            ChatMessage(role="user", content=user_content),
                        ],
                        # Low temperature: identity extraction must not invent features
                        temperature=0.3,
                    )
                else:
                    # No reference photo - use text-only prompt with fallback
                    response = await ai_service.chat(
                        messages=[
                            ChatMessage(role="system", content=system_prompt),
                            ChatMessage(
                                role="user",
                                content=(
                                    f"{guidance}\n\nGenerate {num_prompts} scene plans as JSON. "
                                    "Without a reference photo, use a neutral adult subject_lock and keep it consistent."
                                ),
                            ),
                        ],
                        temperature=0.3,
                    )
            finally:
                await ai_service.close()

            content = response.text or ""
            if not content:
                raise AIServiceError("Prompt generation returned empty response")

            # Extract JSON object from response
            json_str = PhotoshootService._extract_json_object(content)
            response_data = json.loads(json_str)

            # Handle both old array format and new object format
            if isinstance(response_data, list):
                prompts_data = response_data
                subject_lock = ""
            elif isinstance(response_data, dict):
                subject_lock = (
                    (response_data.get("subject_lock") or "").strip()
                    or (response_data.get("subject_description") or "").strip()
                )
                subject_hint = subject_lock
                prompts_data = response_data.get("prompts", [])
            else:
                raise AIServiceError("Prompt generation response was not valid JSON")

            prompts: List[PhotoshootPrompt] = []
            for i, p in enumerate(prompts_data[:num_prompts]):
                if not isinstance(p, dict):
                    continue
                setting = (p.get("setting") or "").strip()
                outfit = (p.get("outfit") or "").strip()
                pose = (p.get("pose") or "").strip()
                lighting = (p.get("lighting") or "").strip()
                style = (p.get("style") or "").strip()
                mood = (p.get("mood") or "").strip()

                # Prefer model-provided scene_body; otherwise compose from fields
                scene_body = (p.get("scene_body") or "").strip()
                if not scene_body:
                    scene_parts = []
                    if setting:
                        scene_parts.append(f"Setting: {setting}")
                    if outfit:
                        scene_parts.append(f"Outfit inventory: {outfit}")
                    if pose:
                        scene_parts.append(f"Pose: {pose}")
                    if lighting:
                        scene_parts.append(f"Lighting: {lighting}")
                    if style:
                        scene_parts.append(f"Style: {style}")
                    if mood:
                        scene_parts.append(f"Mood: {mood}")
                    scene_body = ". ".join(scene_parts)

                # Prefer sandwich(subject_lock, scene); fall back to legacy full_prompt
                if subject_lock and scene_body:
                    full_prompt = sandwich_prompt(subject_lock, scene_body)
                else:
                    full_prompt = (p.get("full_prompt") or "").strip()
                    if full_prompt and subject_lock and subject_lock not in full_prompt:
                        full_prompt = sandwich_prompt(subject_lock, full_prompt)
                    elif not full_prompt and scene_body:
                        full_prompt = sandwich_prompt(subject_lock, scene_body)

                if not full_prompt:
                    continue
                prompts.append(
                    PhotoshootPrompt(
                        index=int(p.get("index", i)),
                        setting=setting,
                        outfit=outfit,
                        pose=pose,
                        lighting=lighting,
                        style=style,
                        mood=mood,
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
    def _extract_json_object(text: str) -> str:
        """
        Extract the first top-level JSON object or array from a model response.

        Handles responses wrapped in markdown fences or with extra prose.
        """
        if not text:
            raise AIServiceError("Empty prompt generation response")

        # Remove markdown code fences if present
        fenced = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text, re.IGNORECASE)
        if fenced:
            text = fenced.group(1)

        # Try to find JSON object first, then array
        obj_start = text.find("{")
        arr_start = text.find("[")

        if obj_start < 0 and arr_start < 0:
            raise AIServiceError("Prompt generation response did not contain JSON")

        # Use whichever comes first (object or array)
        if obj_start >= 0 and (arr_start < 0 or obj_start < arr_start):
            start = obj_start
            open_char, close_char = "{", "}"
        else:
            start = arr_start
            open_char, close_char = "[", "]"

        depth = 0
        for i in range(start, len(text)):
            ch = text[i]
            if ch == open_char:
                depth += 1
            elif ch == close_char:
                depth -= 1
                if depth == 0:
                    return text[start : i + 1]

        raise AIServiceError("Unterminated JSON in prompt generation response")

    @staticmethod
    def _fallback_prompts(
        use_case: PhotoshootUseCase,
        num_prompts: int,
        custom_prompt: Optional[str],
        subject_hint: str,
    ) -> List[PhotoshootPrompt]:
        subject_lock = (subject_hint or "").strip() or (
            "Same adult person as the reference photo(s); keep exact face, hair, skin, age, and body proportions."
        )

        if use_case == PhotoshootUseCase.CUSTOM and custom_prompt:
            theme = f"Theme: {custom_prompt.strip()}."
        else:
            theme = f"Use case: {use_case.value}."

        seeds = [
            (
                "modern studio",
                "black structured blazer over ivory silk blouse, high-waisted black tailored trousers, black pointed-toe loafers, slim silver watch and stud earrings",
                "front to slight 3/4 portrait, face clear, eyes near camera",
                "softbox key light, even on face",
                "editorial",
                "confident",
            ),
            (
                "sunlit cafe",
                "light blue button-down shirt with rolled sleeves, beige straight-leg chinos, white low-top sneakers, brown leather belt, minimal bracelet",
                "seated upper body, face clearly visible",
                "natural window light, soft",
                "lifestyle",
                "approachable",
            ),
            (
                "city street",
                "charcoal tailored blazer, crisp white crew-neck tee, dark indigo slim jeans, black Chelsea boots, matte black crossbody bag",
                "standing mid-step, face toward camera",
                "golden hour, soft fill on face",
                "street style",
                "energetic",
            ),
            (
                "office",
                "navy suit jacket and matching trousers, pale blue shirt, polished brown oxford shoes, subtle tie clip, classic wristwatch",
                "front-facing headshot, face large in frame",
                "soft natural light",
                "corporate",
                "professional",
            ),
            (
                "rooftop",
                "structured monochrome trench coat, fitted mock-neck top, tailored wide-leg pants, clean leather ankle boots, geometric statement earrings",
                "power stance, face clear, slight 3/4",
                "rim light with soft front fill",
                "fashion",
                "bold",
            ),
            (
                "park",
                "olive utility jacket over white tee, medium-wash straight jeans, tan sneakers, canvas tote bag, simple necklace",
                "relaxed smile, face fully visible, no sunglasses",
                "diffused daylight",
                "candid",
                "warm",
            ),
            (
                "neutral backdrop",
                "classic black sheath dress with clean neckline, fitted blazer layer, black closed-toe heels, pearl studs, slim bracelet",
                "close-up portrait, face dominant in frame",
                "soft studio lighting",
                "headshot",
                "friendly",
            ),
            (
                "hotel lobby",
                "deep emerald evening blazer, satin camisole, tailored tapered trousers, black heeled sandals, metallic clutch, layered pendant necklace",
                "three-quarter body, face toward camera",
                "warm ambient light with soft key",
                "luxury",
                "poised",
            ),
            (
                "beach",
                "light linen button shirt, sand-colored relaxed shorts, minimalist leather sandals, woven hat held in hand (not covering face)",
                "looking near camera, face unobstructed",
                "sunset light with soft fill",
                "travel",
                "joyful",
            ),
            (
                "gallery",
                "cream oversized blazer over black turtleneck, pleated midi skirt, pointed ankle boots, sculptural ring set, structured mini bag",
                "standing portrait, face clear, slight 3/4",
                "soft spotlight with gentle fill",
                "editorial",
                "thoughtful",
            ),
        ]

        prompts: List[PhotoshootPrompt] = []
        for i in range(num_prompts):
            setting, outfit, pose, lighting, style, mood = seeds[i % len(seeds)]
            scene_body = (
                f"{theme} Setting: {setting}. Outfit inventory: {outfit}. "
                f"Pose: {pose}. Lighting: {lighting}. Style: {style}. Mood: {mood}."
            )
            full_prompt = sandwich_prompt(subject_lock, scene_body)
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
    ) -> Tuple[List[GeneratedImage], List[ImageGenerationFailure]]:
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

                # Add the generation prompt with strict identity + outfit fidelity controls
                enhanced_prompt = f"""{prompt.full_prompt}

{PHOTOSHOOT_FIDELITY_APPENDIX}"""

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

            # Filter successful and failed results
            successful: List[GeneratedImage] = []
            failures: List[ImageGenerationFailure] = []
            for i, result in enumerate(results):
                prompt_index = prompts[i].index if i < len(prompts) else i
                if isinstance(result, GeneratedImage):
                    successful.append(result)
                elif isinstance(result, Exception):
                    error_text = str(result).strip() or result.__class__.__name__
                    logger.error(f"Image {prompt_index} generation failed with exception: {error_text}")
                    failures.append(ImageGenerationFailure(index=prompt_index, error=error_text))
                else:
                    error_text = "Image generation returned no result"
                    logger.warning(f"Image {prompt_index} generation returned None")
                    failures.append(ImageGenerationFailure(index=prompt_index, error=error_text))

            if not successful:
                raise ServiceError("All image generations failed")

            # Sort by index
            successful.sort(key=lambda img: img.index)

            logger.info(
                f"Successfully generated {len(successful)}/{len(prompts)} images"
            )
            return successful, failures

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
            images, failures = await PhotoshootService.generate_images(
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
                generated_count=len(images),
                failed_count=len(failures),
                image_failures=failures,
                partial_success=len(failures) > 0,
            )

        except (ValidationError, RateLimitError, ServiceError, DatabaseError):
            raise
        except Exception as e:
            logger.exception(f"Error in photoshoot generation for user {user_id}: {e}")
            raise ServiceError("Photoshoot generation failed", service_name="photoshoot")


# =============================================================================
# Streaming Photoshoot Service (SSE-based for Flutter app)
# =============================================================================


class PhotoshootStreamingService:
    """Service for streaming photoshoot generation with SSE updates.

    This service manages the async generation pipeline and broadcasts
    progress events to SSE subscribers via PhotoshootJobService.
    """

    def __init__(self, user_id: str, db: Client):
        self.user_id = user_id
        self.db = db

    async def run_pipeline(self, job: PhotoshootJob) -> None:
        """Run the photoshoot generation pipeline with SSE updates.

        1. Validate and check limits
        2. Generate prompts
        3. Generate images in batches, broadcasting each completion
        4. Update usage and broadcast completion
        """
        from app.services.photoshoot_job_service import (
            PhotoshootJobService,
            PhotoshootJobStatus,
        )

        try:
            await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.PROCESSING)

            # Check daily limit
            allowed, usage = await PhotoshootService.check_daily_limit(
                self.user_id, job.num_images, self.db
            )
            if not allowed:
                raise RateLimitError(
                    message=f"Daily limit exceeded. You have {usage.remaining} images remaining today.",
                    retry_after=86400,
                )

            # Broadcast generation started
            await PhotoshootJobService.broadcast_event(job.job_id, "generation_started", {
                "job_id": job.job_id,
                "total_images": job.num_images,
                "total_batches": job.total_batches,
                "timestamp": datetime.utcnow().isoformat(),
            })

            # Generate prompts
            prompts = await PhotoshootService.generate_prompts(
                use_case=PhotoshootUseCase(job.use_case),
                num_prompts=job.num_images,
                custom_prompt=job.custom_prompt,
                reference_photo=job.photos[0] if job.photos else None,
            )

            # Generate images in batches with streaming
            await self._generate_images_streaming(job, prompts)

            # Reference photos are no longer needed after generation
            await PhotoshootJobService.release_reference_photos(job.job_id)

            # Check cancellation
            if job.is_cancelled():
                return

            # Increment usage for successfully generated images
            generated_count = job.generated_count
            if generated_count > 0:
                await PhotoshootService.increment_usage(self.user_id, generated_count, self.db)

            # Get updated usage
            updated_usage = await PhotoshootService.get_usage(self.user_id, self.db)
            usage_dict = updated_usage.model_dump(mode="json")
            await PhotoshootJobService.set_usage(job.job_id, usage_dict)

            # Mark complete
            await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.COMPLETE)

            # Broadcast completion
            await PhotoshootJobService.broadcast_event(job.job_id, "job_complete", {
                "job_id": job.job_id,
                "session_id": job.session_id,
                "generated_count": generated_count,
                "failed_count": job.failed_count,
                "failed_indices": sorted(job.failed_indices),
                "partial_success": job.failed_count > 0,
                "usage": usage_dict,
                "timestamp": datetime.utcnow().isoformat(),
            })
            # Keep generated images for GET status / poll fallback; drop
            # the SSE replay buffer which duplicates base64 payloads.
            await PhotoshootJobService.clear_event_history(job.job_id)

        except RateLimitError as e:
            from app.services.photoshoot_job_service import PhotoshootJobService
            await PhotoshootJobService.set_error(job.job_id, str(e))
            await PhotoshootJobService.broadcast_event(job.job_id, "job_failed", {
                "job_id": job.job_id,
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat(),
            })
            await PhotoshootJobService.release_reference_photos(job.job_id)
            await PhotoshootJobService.clear_event_history(job.job_id)
        except Exception as e:
            from app.services.photoshoot_job_service import PhotoshootJobService
            logger.exception(f"Photoshoot pipeline failed: {e}")
            await PhotoshootJobService.set_error(job.job_id, str(e))
            await PhotoshootJobService.broadcast_event(job.job_id, "job_failed", {
                "job_id": job.job_id,
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat(),
            })
            await PhotoshootJobService.release_reference_photos(job.job_id)
            await PhotoshootJobService.clear_event_history(job.job_id)

    async def _generate_images_streaming(
        self,
        job: PhotoshootJob,
        prompts: List[PhotoshootPrompt],
    ) -> None:
        """Generate images in batches, broadcasting progress via SSE."""
        from app.services.ai_settings_service import AISettingsService
        from app.services.photoshoot_job_service import PhotoshootJobService

        # Get AI service
        ai_service = await AISettingsService.get_ai_service_for_user(self.user_id, self.db)

        try:
            # Normalize reference photos
            normalized_refs = []
            for photo in job.photos:
                if photo and "," in photo and photo.strip().lower().startswith("data:"):
                    normalized_refs.append(photo.split(",", 1)[1])
                else:
                    normalized_refs.append(photo.strip() if photo else "")
            normalized_refs = [p for p in normalized_refs if p]

            # Process in batches
            batch_size = job.batch_size
            for batch_num in range(job.total_batches):
                if job.is_cancelled():
                    return

                start_idx = batch_num * batch_size
                end_idx = min(start_idx + batch_size, len(prompts))
                batch_prompts = prompts[start_idx:end_idx]

                # Update current batch
                await PhotoshootJobService.update_current_batch(job.job_id, batch_num + 1)

                # Broadcast batch start
                await PhotoshootJobService.broadcast_event(job.job_id, "batch_started", {
                    "job_id": job.job_id,
                    "batch_index": batch_num,
                    "batch_number": batch_num + 1,
                    "total_batches": job.total_batches,
                    "images_in_batch": len(batch_prompts),
                    "timestamp": datetime.utcnow().isoformat(),
                })

                # Generate batch images concurrently
                concurrency_limit = getattr(settings, 'PHOTOSHOOT_CONCURRENCY_LIMIT', 3)
                semaphore = asyncio.Semaphore(concurrency_limit)

                async def generate_single(prompt: PhotoshootPrompt):
                    async with semaphore:
                        if job.is_cancelled():
                            return None
                        return await self._generate_single_image(
                            job, prompt, ai_service, normalized_refs
                        )

                tasks = [generate_single(p) for p in batch_prompts]
                await asyncio.gather(*tasks, return_exceptions=True)

                # Broadcast batch complete
                # Refresh job state to get current counts
                updated_job = await PhotoshootJobService.get_job_by_id(job.job_id)
                generated_count = updated_job.generated_count if updated_job else 0

                await PhotoshootJobService.broadcast_event(job.job_id, "batch_complete", {
                    "job_id": job.job_id,
                    "batch_index": batch_num,
                    "batch_number": batch_num + 1,
                    "total_batches": job.total_batches,
                    "generated_count": generated_count,
                    "timestamp": datetime.utcnow().isoformat(),
                })
        finally:
            await ai_service.close()

    async def _generate_single_image(
        self,
        job: PhotoshootJob,
        prompt: PhotoshootPrompt,
        ai_service,
        normalized_refs: List[str],
    ) -> Optional[GeneratedImage]:
        """Generate a single image and broadcast result."""
        from app.services.ai_provider_service import ChatMessage
        from app.services.photoshoot_job_service import PhotoshootJobService

        try:
            # Build multi-image content
            content = []
            for ref_photo in normalized_refs:
                ref_url = f"data:image/jpeg;base64,{ref_photo}" if not ref_photo.startswith("data:") else ref_photo
                content.append({
                    "type": "image_url",
                    "image_url": {"url": ref_url}
                })

            # Enhanced prompt with strict identity + outfit fidelity controls
            enhanced_prompt = f"""{prompt.full_prompt}

{PHOTOSHOOT_FIDELITY_APPENDIX}"""

            content.append({"type": "text", "text": enhanced_prompt})
            messages = [ChatMessage(role="user", content=content)]

            response = await ai_service.chat(
                messages=messages,
                model=ai_service.config.get_image_gen_model(),
                response_modalities=["TEXT", "IMAGE"],
            )

            if not response.images:
                raise ServiceError(f"No image generated for prompt {prompt.index}")

            image_id = f"img_{uuid.uuid4().hex[:8]}"
            image_base64 = response.images[0]

            # Add to job
            await PhotoshootJobService.add_generated_image(
                job.job_id,
                image_id,
                prompt.index,
                image_base64=image_base64,
            )

            # Get updated job state for accurate counts
            updated_job = await PhotoshootJobService.get_job_by_id(job.job_id)
            generated_count = updated_job.generated_count if updated_job else 0

            # Broadcast success
            await PhotoshootJobService.broadcast_event(job.job_id, "image_complete", {
                "job_id": job.job_id,
                "id": image_id,
                "index": prompt.index,
                "image_base64": image_base64,
                "image_url": None,
                "generated_count": generated_count,
                "total_count": job.num_images,
                "timestamp": datetime.utcnow().isoformat(),
            })

            return GeneratedImage(
                id=image_id,
                index=prompt.index,
                image_base64=image_base64,
            )

        except Exception as e:
            logger.error(f"Failed to generate image {prompt.index}: {e}")

            await PhotoshootJobService.mark_image_failed(job.job_id, prompt.index, str(e))

            # Get updated job state for accurate counts
            updated_job = await PhotoshootJobService.get_job_by_id(job.job_id)
            generated_count = updated_job.generated_count if updated_job else 0
            failed_count = updated_job.failed_count if updated_job else 0

            # Broadcast failure
            await PhotoshootJobService.broadcast_event(job.job_id, "image_failed", {
                "job_id": job.job_id,
                "index": prompt.index,
                "error": str(e),
                "generated_count": generated_count,
                "failed_count": failed_count,
                "total_count": job.num_images,
                "timestamp": datetime.utcnow().isoformat(),
            })

            return None
