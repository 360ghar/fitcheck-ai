"""
Photoshoot service for AI-powered photoshoot generation.

Handles prompt generation, image generation via AIProviderService,
and usage tracking for daily limits.
"""

import asyncio
import base64
import json
import uuid
from datetime import datetime, date, timedelta, timezone
from app.utils.datetime_util import utcnow, utcnow_iso, utc_today
from app.utils.db import execute_with_reconnect, unwrap_rpc_bool
from app.utils.json_utils import extract_json_block
from app.core.concurrency import image_gen_slot
from app.utils.image_processing import to_data_url
from typing import Any, List, Optional, Tuple

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
        return utc_today()

    @staticmethod
    def _get_daily_limit(plan_type: PlanType) -> int:
        """Get the daily photoshoot image limit for a plan type."""
        if plan_type in (PlanType.PRO_MONTHLY, PlanType.PRO_YEARLY):
            return settings.PLAN_PRO_DAILY_PHOTOSHOOT_IMAGES
        if plan_type in (PlanType.PLUS_MONTHLY, PlanType.PLUS_YEARLY):
            return settings.PLAN_PLUS_DAILY_PHOTOSHOOT_IMAGES
        return settings.PLAN_FREE_DAILY_PHOTOSHOOT_IMAGES

    @staticmethod
    async def get_or_create_daily_usage(user_id: str, db: Client) -> dict:
        """Get or create daily photoshoot usage record."""
        period_start = SubscriptionService._get_current_period_start()

        try:
            # Ensure monthly usage record exists
            await SubscriptionService.get_or_create_usage_record(user_id, db)

            # Prefer DB-side reset for correctness/atomicity (migration 010).
            # Read-only/idempotent (resets the daily counter when stale), so
            # rebuilding + retrying once on a dead pooled connection is
            # exact-once safe (observed 2026-08-03: "Error getting daily usage
            # for user ...: 45" -> photoshoot generate 500).
            try:
                await execute_with_reconnect(
                    lambda d: d.rpc(
                        "reset_daily_photoshoot_if_needed",
                        {
                            "p_user_id": user_id,
                            "p_period_start": period_start.isoformat(),
                        },
                    ).execute(),
                    db,
                    extra={"operation": "reset_daily_photoshoot_if_needed", "user_id": user_id},
                )
            except Exception as e:
                # Migration may not be applied yet; fall back to app-side reset in get_usage().
                logger.debug(f"RPC reset_daily_photoshoot_if_needed not available: {e}")

            result = await execute_with_reconnect(
                lambda d: d.table("subscription_usage")
                .select("*")
                .eq("user_id", user_id)
                .eq("period_start", period_start.isoformat())
                .single()
                .execute(),
                db,
                extra={"operation": "get_daily_usage", "user_id": user_id},
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
                        await asyncio.to_thread(db.table("subscription_usage").update(
                            {
                                "daily_photoshoot_images": 0,
                                "last_photoshoot_reset": today.isoformat(),
                            }
                        ).eq("user_id", user_id).eq(
                            "period_start", period_start.isoformat()
                        ).execute)
                        used_today = 0
                except Exception as e:
                    logger.debug(f"Failed to parse last_photoshoot_reset date: {e}")

            # Calculate reset time (midnight UTC)
            tomorrow = today + timedelta(days=1)
            resets_at = datetime.combine(tomorrow, datetime.min.time(), tzinfo=timezone.utc)

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
    async def reserve_daily_usage(
        user_id: str,
        num_images: int,
        db: Client,
    ) -> Tuple[bool, PhotoshootUsage]:
        """Atomically reserve daily photoshoot images before provider work."""
        if num_images <= 0:
            raise ValueError("num_images must be positive")
        subscription = await SubscriptionService.get_subscription(user_id, db)
        daily_limit = PhotoshootService._get_daily_limit(subscription.plan_type)
        await PhotoshootService.get_or_create_daily_usage(user_id, db)
        period_start = SubscriptionService._get_current_period_start()
        try:
            result = await asyncio.to_thread(
                db.rpc(
                    "reserve_daily_photoshoot_usage",
                    {
                        "p_user_id": user_id,
                        "p_period_start": period_start.isoformat(),
                        "p_count": num_images,
                        "p_limit": daily_limit,
                    },
                ).execute
            )
        except Exception as error:
            logger.error("Failed to reserve photoshoot usage", user_id=user_id, error=str(error))
            raise DatabaseError("Failed to reserve photoshoot usage") from error

        # `reserve_daily_photoshoot_usage` returns a scalar BOOLEAN, so
        # PostgREST keys the result by the function name.
        reserved = unwrap_rpc_bool(result, "reserve_daily_photoshoot_usage")
        usage = await PhotoshootService.get_usage(user_id, db)
        return reserved is True, usage

    @staticmethod
    async def release_daily_usage(
        user_id: str,
        num_images: int,
        db: Client,
    ) -> None:
        """Return unused daily photoshoot quota after a partial run.

        The reservation claims the full requested count up front; failures and
        cancellations must hand the unused share back so users can retry the
        images that never produced output. Best-effort: a failed release must
        not mask the pipeline outcome.
        """
        if num_images <= 0:
            return
        try:
            period_start = SubscriptionService._get_current_period_start()
            await asyncio.to_thread(
                db.rpc(
                    "release_daily_photoshoot_usage",
                    {
                        "p_user_id": user_id,
                        "p_period_start": period_start.isoformat(),
                        "p_count": num_images,
                    },
                ).execute
            )
        except Exception as error:
            logger.error(
                "Failed to release unused photoshoot usage",
                user_id=user_id,
                error=str(error),
            )

    @staticmethod
    async def increment_usage(
        user_id: str,
        num_images: int,
        db: Client,
    ) -> None:
        """Reserve daily photoshoot usage through the atomic hosted RPC."""
        try:
            reserved, _ = await PhotoshootService.reserve_daily_usage(user_id, num_images, db)
            if not reserved:
                raise RateLimitError("Daily photoshoot limit exceeded")

        except RateLimitError:
            raise
        except Exception as e:
            logger.error(f"Error incrementing photoshoot usage for user {user_id}: {e}")
            raise DatabaseError("Failed to reserve photoshoot usage") from e

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

        def _user_text(strict_json: bool) -> str:
            base = (
                f"Use case guidance:\n{guidance}\n\n"
                f"Analyze this person and generate {num_prompts} scene plans as JSON. "
                "Be factual about identity; only invent diversity in setting/outfit/pose/lighting."
                if reference_photo
                else (
                    f"{guidance}\n\nGenerate {num_prompts} scene plans as JSON. "
                    "Without a reference photo, use a neutral adult subject_lock and keep it consistent."
                )
            )
            if strict_json:
                return (
                    base
                    + "\n\nReturn ONLY a JSON object matching the schema. "
                    "No markdown fences, no prose before or after the JSON."
                )
            return base

        # Downscale the reference photo ONCE, before the 2-attempt parse-retry
        # loop below (both attempts reuse the same reference image). CPU-bound
        # decode + re-encode; run on the bounded image executor so it never
        # stalls the event loop (see app/core/image_executor).
        ref_url: Optional[str] = None
        if reference_photo:
            from app.core.image_executor import run_image_op
            from app.utils.image_processing import downscale_base64_image

            photo = reference_photo
            if "," in photo and photo.strip().lower().startswith("data:"):
                photo = photo.split(",", 1)[1]
            downscaled = await run_image_op(downscale_base64_image, photo)
            ref_url = to_data_url(downscaled)

        async def _build_user_content(strict_json: bool):
            if ref_url is None:
                return _user_text(strict_json)
            return [
                {"type": "image_url", "image_url": {"url": ref_url}},
                {"type": "text", "text": _user_text(strict_json)},
            ]

        try:
            ai_service = await get_ai_service()
            response_data: Any = None
            try:
                last_parse_error: Optional[Exception] = None
                # Attempt 0: normal. Attempt 1: stricter "JSON only" nudge after parse failure.
                for attempt in range(2):
                    strict = attempt == 1
                    response = await ai_service.chat(
                        messages=[
                            ChatMessage(role="system", content=system_prompt),
                            ChatMessage(role="user", content=await _build_user_content(strict)),
                        ],
                        temperature=0.3,
                        response_format={"type": "json_object"},
                    )
                    content = (response.text or "").strip()
                    if not content:
                        last_parse_error = AIServiceError("Prompt generation returned empty response")
                        if attempt == 0:
                            logger.warning("Prompt generation empty; retrying with strict JSON instruction")
                            continue
                        raise last_parse_error
                    try:
                        json_str = extract_json_block(content)
                        response_data = json.loads(json_str)
                        break
                    except (AIServiceError, ValueError, json.JSONDecodeError) as parse_err:
                        last_parse_error = parse_err
                        if attempt == 0:
                            logger.warning(
                                "Prompt generation JSON parse failed; retrying once",
                                error=str(parse_err),
                            )
                            continue
                        raise
                else:
                    raise last_parse_error or AIServiceError("Prompt generation failed")
            finally:
                await ai_service.close()

            if response_data is None:
                raise AIServiceError("Prompt generation returned no parseable JSON")

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
                "Prompt generation incomplete, using fallback prompts",
                requested=num_prompts,
                generated=len(prompts),
                use_case=use_case.value,
                has_reference_photo=reference_photo is not None,
            )
            return PhotoshootService._fallback_prompts(
                use_case=use_case,
                num_prompts=num_prompts,
                custom_prompt=custom_prompt,
                subject_hint=subject_hint,
            )

        except json.JSONDecodeError as e:
            logger.warning(
                "Failed to parse prompts JSON after retry; using fallback",
                error=str(e)[:300],
                use_case=use_case.value,
                has_reference_photo=reference_photo is not None,
            )
            return PhotoshootService._fallback_prompts(
                use_case=use_case,
                num_prompts=num_prompts,
                custom_prompt=custom_prompt,
                subject_hint=subject_hint,
            )
        except Exception as e:
            logger.warning(
                "Error generating prompts; using fallback",
                error=str(e)[:300],
                error_type=type(e).__name__,
                use_case=use_case.value,
                has_reference_photo=reference_photo is not None,
            )
            return PhotoshootService._fallback_prompts(
                use_case=use_case,
                num_prompts=num_prompts,
                custom_prompt=custom_prompt,
                subject_hint=subject_hint,
            )

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

        # Normalize + downscale reference photos (cut multi-MB base64 payloads that
        # drive LocalProtocolError and OOM under concurrent generation).
        # Downscale runs on the bounded image executor: PIL decode is CPU-bound
        # and can allocate tens of MB per photo.
        from app.core.image_executor import run_image_op
        from app.utils.image_processing import downscale_base64_image

        normalized_refs = []
        for photo in reference_photos:
            if photo and "," in photo and photo.strip().lower().startswith("data:"):
                raw = photo.split(",", 1)[1]
            else:
                raw = photo.strip() if photo else ""
            if raw:
                normalized_refs.append(raw)
        if normalized_refs:
            normalized_refs = list(
                await asyncio.gather(
                    *(run_image_op(downscale_base64_image, raw) for raw in normalized_refs)
                )
            )

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
                    ref_url = to_data_url(ref_photo)
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
                    model=ai_service.get_image_gen_model(),
                    response_modalities=["TEXT", "IMAGE"],
                )

                if not response.images:
                    logger.warning(
                        "No images generated for photoshoot prompt (possible silent refusal)",
                        prompt_index=prompt.index,
                        response_model=response.model,
                        response_provider=response.provider,
                    )
                    return None

                return GeneratedImage(
                    id=f"img_{uuid.uuid4().hex[:8]}",
                    index=prompt.index,
                    image_base64=response.images[0],
                    image_url=None,
                )

            # Process with concurrency control. The LOCAL semaphore keeps the
            # photoshoot fan-out at PHOTOSHOOT_CONCURRENCY_LIMIT; the SHARED
            # image_gen_slot() (GENERATION_SEMAPHORE, reentrant) adds the
            # process-wide ceiling so photoshoot + try-on + outfit + batch
            # generation share ONE budget (2026-08-03 container OOM - TD-044).
            concurrency_limit = settings.PHOTOSHOOT_CONCURRENCY_LIMIT
            semaphore = asyncio.Semaphore(concurrency_limit)

            async def generate_with_semaphore(prompt: PhotoshootPrompt) -> Optional[GeneratedImage]:
                async with image_gen_slot(), semaphore:
                    try:
                        return await generate_single(prompt)
                    except Exception as e:
                        logger.error(
                            "Failed to generate photoshoot image",
                            prompt_index=prompt.index,
                            error=str(e),
                            error_type=type(e).__name__,
                        )
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
                    logger.error(
                        "Photoshoot image generation failed with exception",
                        prompt_index=prompt_index,
                        error=error_text,
                        error_type=type(result).__name__,
                    )
                    failures.append(ImageGenerationFailure(index=prompt_index, error=error_text))
                else:
                    error_text = "Image generation returned no result"
                    logger.warning(
                        "Photoshoot image generation returned no result",
                        prompt_index=prompt_index,
                    )
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
        reservation_made = False

        try:
            # Validate custom prompt requirement
            if use_case == PhotoshootUseCase.CUSTOM and not custom_prompt:
                raise ValidationError("Custom prompt is required for custom use case")

            # Check daily limit
            allowed, usage = await PhotoshootService.reserve_daily_usage(user_id, num_images, db)
            if not allowed:
                raise RateLimitError(
                    message=f"Daily limit exceeded. You have {usage.remaining} images remaining today.",
                    retry_after=int((usage.resets_at - utcnow()).total_seconds()) if usage.resets_at else 86400,
                )
            reservation_made = True

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

            # Reconcile the reservation with what was actually produced:
            # failed images must not consume daily quota so the user can
            # retry them.
            unused = num_images - len(images)
            if unused > 0:
                await PhotoshootService.release_daily_usage(user_id, unused, db)

            # The reservation RPC already reflects today's usage; reuse the
            # usage object returned by reserve_daily_usage instead of paying a
            # redundant read after generation.
            updated_usage = usage

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
            # A failure after the reservation (e.g. prompt generation) must
            # hand the full quota back; RateLimitError from a failed admission
            # never reserved anything.
            if reservation_made:
                await PhotoshootService.release_daily_usage(user_id, num_images, db)
            raise
        except Exception as e:
            logger.exception(
                "Error in photoshoot generation",
                user_id=user_id,
                use_case=use_case.value,
                num_images=num_images,
                session_id=session_id,
                elapsed_seconds=round(time.time() - start_time, 2),
                error=str(e)[:300],
            )
            # The reservation was made before generation; hand it back so a
            # failed run never burns the user's daily photoshoot quota.
            if reservation_made:
                await PhotoshootService.release_daily_usage(user_id, num_images, db)
            raise ServiceError("Photoshoot generation failed", service_name="photoshoot")


# =============================================================================
# Streaming Photoshoot Service (SSE-based for Flutter app)
# =============================================================================


def _scene_label(prompt: PhotoshootPrompt) -> str:
    """Short human label for a scene prompt ("sunlit cafe, seated upper body").

    Sent in SSE batch/image events so clients can show which scene is being
    generated instead of a bare percent. Prefer setting+pose, fall back to
    style/mood.
    """
    parts = [part for part in (prompt.setting, prompt.pose) if part]
    if parts:
        label = ", ".join(parts)
        if len(label) > 48:
            label = label[:48].rsplit(",", 1)[0] + ", …"
        return label
    fallback = prompt.style or prompt.mood or f"Scene {prompt.index + 1}"
    return fallback


class PhotoshootStreamingService:
    """Service for streaming photoshoot generation with SSE updates.

    This service manages the async generation pipeline and broadcasts
    progress events to SSE subscribers via PhotoshootJobService.
    """

    def __init__(self, user_id: str, db: Client, is_demo: bool = False):
        self.user_id = user_id
        self.db = db
        self.is_demo = is_demo

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

        reservation_made = False
        try:
            await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.PROCESSING)

            # Check daily limit. Demo jobs are quota-exempt: the IP rate limit
            # was enforced at job creation (demo path), so no reservation.
            if not self.is_demo:
                allowed, usage = await PhotoshootService.reserve_daily_usage(
                    self.user_id, job.num_images, self.db
                )
                if not allowed:
                    raise RateLimitError(
                        message=f"Daily limit exceeded. You have {usage.remaining} images remaining today.",
                        retry_after=86400,
                    )
                reservation_made = True

            # Broadcast generation started
            await PhotoshootJobService.broadcast_event(job.job_id, "generation_started", {
                "job_id": job.job_id,
                "total_images": job.num_images,
                "total_batches": job.total_batches,
                "timestamp": utcnow_iso(),
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

            # Reconcile the reservation with what was actually produced:
            # failed and cancelled images must not consume daily quota so the
            # user can retry them.
            unused = job.num_images - job.generated_count
            if not self.is_demo and unused > 0:
                await PhotoshootService.release_daily_usage(self.user_id, unused, self.db)

            # Check cancellation
            if job.is_cancelled():
                return

            # Read the POST-RELEASE usage so completion/failure payloads never
            # carry the reservation-time numbers. A 0-image run releases the
            # FULL reservation; broadcasting the stale pre-release usage made
            # clients report "limit deducted" after a failed run (observed
            # 2026-08-04: photoshoot 0-images RCA). Demo jobs have no usage.
            usage_dict = None
            if not self.is_demo:
                try:
                    updated_usage = await PhotoshootService.get_usage(self.user_id, self.db)
                except Exception:
                    # A failed usage re-read must not kill the terminal event:
                    # fall back to the reservation-time snapshot (pre-RCA
                    # behavior) and let the client refetch usage itself.
                    # Without this guard the generic pipeline except below
                    # would broadcast job_failed with the usage error and
                    # release the FULL reservation on top of the partial
                    # release already done above (double release).
                    logger.warning(
                        "Failed to re-read photoshoot usage after release; "
                        "falling back to reservation-time snapshot",
                        exc_info=True,
                    )
                    updated_usage = usage
                usage_dict = updated_usage.model_dump(mode="json")
            await PhotoshootJobService.set_usage(job.job_id, usage_dict)

            if job.generated_count == 0:
                # A run that produced nothing is a FAILURE, not a partial
                # success: parity with the sync path (generate_photoshoot
                # raises ServiceError("All image generations failed")). The
                # error carries the first retained provider detail so the
                # client dialog (and the operator) see why every slot failed.
                first_error = await PhotoshootJobService.get_first_error(job.job_id)
                error_msg = (
                    f"No images were generated (0 of {job.num_images})."
                    + (f" Provider error: {first_error}" if first_error else "")
                )
                await PhotoshootJobService.set_error(job.job_id, error_msg)
                await PhotoshootJobService.broadcast_event(job.job_id, "job_failed", {
                    "job_id": job.job_id,
                    "error": error_msg,
                    "usage": usage_dict,
                    "failed_indices": sorted(job.failed_indices),
                    "timestamp": utcnow_iso(),
                })
                await PhotoshootJobService.clear_event_history(job.job_id)
                await PhotoshootJobService.release_generated_payloads(job.job_id)
                return

            # Mark complete
            await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.COMPLETE)

            # Broadcast completion
            generated_count = job.generated_count
            await PhotoshootJobService.broadcast_event(job.job_id, "job_complete", {
                "job_id": job.job_id,
                "session_id": job.session_id,
                "generated_count": generated_count,
                "failed_count": job.failed_count,
                "failed_indices": sorted(job.failed_indices),
                "partial_success": job.failed_count > 0,
                "usage": usage_dict,
                "timestamp": utcnow_iso(),
            })
            # Keep generated images for GET status / poll fallback; drop
            # the SSE replay buffer which duplicates base64 payloads. Images
            # with a durable URL also drop their base64 now — a finished job
            # no longer pins multi-MB payloads for the whole finished TTL.
            await PhotoshootJobService.clear_event_history(job.job_id)
            await PhotoshootJobService.release_generated_payloads(job.job_id)

        except RateLimitError as e:
            from app.services.photoshoot_job_service import PhotoshootJobService
            await PhotoshootJobService.set_error(job.job_id, str(e))
            await PhotoshootJobService.broadcast_event(job.job_id, "job_failed", {
                "job_id": job.job_id,
                "error": str(e),
                "timestamp": utcnow_iso(),
            })
            await PhotoshootJobService.release_reference_photos(job.job_id)
            await PhotoshootJobService.clear_event_history(job.job_id)
            await PhotoshootJobService.release_generated_payloads(job.job_id)
        except Exception as e:
            from app.services.photoshoot_job_service import PhotoshootJobService
            logger.exception(f"Photoshoot pipeline failed: {e}")
            # The whole run failed after reserving; hand the full reservation
            # back so the user can retry.
            if reservation_made:
                await PhotoshootService.release_daily_usage(self.user_id, job.num_images, self.db)
            await PhotoshootJobService.set_error(job.job_id, str(e))
            await PhotoshootJobService.broadcast_event(job.job_id, "job_failed", {
                "job_id": job.job_id,
                "error": str(e),
                "timestamp": utcnow_iso(),
            })
            await PhotoshootJobService.release_reference_photos(job.job_id)
            await PhotoshootJobService.clear_event_history(job.job_id)
            await PhotoshootJobService.release_generated_payloads(job.job_id)

    async def _generate_images_streaming(
        self,
        job: PhotoshootJob,
        prompts: List[PhotoshootPrompt],
    ) -> None:
        """Generate images in batches, broadcasting progress via SSE."""
        from app.services.ai_settings_service import AISettingsService
        from app.services.photoshoot_job_service import PhotoshootJobService

        # Demo jobs have no DB-backed user AI settings; use the system
        # default provider config (same as the old demo endpoint path).
        if self.is_demo or self.db is None:
            from app.services.ai_provider_service import get_ai_service

            ai_service = await get_ai_service()
        else:
            ai_service = await AISettingsService.get_ai_service_for_user(self.user_id, self.db)

        try:
            # Normalize + downscale reference photos (see generate_images).
            # Downscale runs on the bounded image executor: PIL decode is
            # CPU-bound and can allocate tens of MB per photo.
            from app.core.image_executor import run_image_op
            from app.utils.image_processing import downscale_base64_image

            normalized_refs = []
            for photo in job.photos:
                if photo and "," in photo and photo.strip().lower().startswith("data:"):
                    raw = photo.split(",", 1)[1]
                else:
                    raw = photo.strip() if photo else ""
                if raw:
                    normalized_refs.append(raw)
            if normalized_refs:
                normalized_refs = list(
                    await asyncio.gather(
                        *(run_image_op(downscale_base64_image, raw) for raw in normalized_refs)
                    )
                )

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

                scene_labels = {str(p.index): _scene_label(p) for p in batch_prompts}

                # Broadcast batch start
                await PhotoshootJobService.broadcast_event(job.job_id, "batch_started", {
                    "job_id": job.job_id,
                    "batch_index": batch_num,
                    "batch_number": batch_num + 1,
                    "total_batches": job.total_batches,
                    "images_in_batch": len(batch_prompts),
                    "scene_labels": scene_labels,
                    "timestamp": utcnow_iso(),
                })

                # Generate batch images concurrently. Local semaphore =
                # photoshoot fan-out cap; shared image_gen_slot() = process-
                # wide generation budget shared with try-on/outfit/batch
                # (2026-08-03 container OOM - TD-044).
                concurrency_limit = settings.PHOTOSHOOT_CONCURRENCY_LIMIT
                semaphore = asyncio.Semaphore(concurrency_limit)

                async def generate_single(prompt: PhotoshootPrompt):
                    async with image_gen_slot(), semaphore:
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
                    "timestamp": utcnow_iso(),
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
                ref_url = to_data_url(ref_photo)
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
                model=ai_service.get_image_gen_model(),
                response_modalities=["TEXT", "IMAGE"],
            )

            if not response.images:
                raise ServiceError(f"No image generated for prompt {prompt.index}")

            image_id = f"img_{uuid.uuid4().hex[:8]}"
            image_base64 = response.images[0]

            # Persist a durable URL when the job has a persistence DB so a
            # recovered job can still return generated images (base64 payloads
            # are never serialized to the durable row). Best-effort: a failed
            # upload degrades to base64-only delivery, not a failed image.
            image_url = None
            if getattr(job, "persistence_db", None) is not None:
                try:
                    from app.services.storage_service import StorageService

                    raw = image_base64.split("base64,", 1)[-1] if "base64," in image_base64 else image_base64
                    upload = await StorageService.upload_temp_generated_image(
                        db=job.persistence_db,
                        user_id=job.user_id,
                        file_data=base64.b64decode(raw),
                        source="photoshoot",
                    )
                    image_url = upload.get("image_url")
                except Exception as upload_error:
                    logger.warning(
                        "Failed to persist photoshoot image URL; continuing base64-only",
                        extra={
                            "job_id": job.job_id,
                            "image_id": image_id,
                            "error": str(upload_error),
                        },
                    )

            # Add to job
            await PhotoshootJobService.add_generated_image(
                job.job_id,
                image_id,
                prompt.index,
                image_base64=image_base64,
                image_url=image_url,
            )

            # Get updated job state for accurate counts
            updated_job = await PhotoshootJobService.get_job_by_id(job.job_id)
            generated_count = updated_job.generated_count if updated_job else 0

            # Broadcast success
            await PhotoshootJobService.broadcast_event(job.job_id, "image_complete", {
                "job_id": job.job_id,
                "id": image_id,
                "index": prompt.index,
                "label": _scene_label(prompt),
                "image_base64": image_base64,
                "image_url": image_url,
                "generated_count": generated_count,
                "total_count": job.num_images,
                "timestamp": utcnow_iso(),
            })

            return GeneratedImage(
                id=image_id,
                index=prompt.index,
                image_base64=image_base64,
            )

        except Exception as e:
            logger.error(
                "Failed to generate streaming photoshoot image",
                prompt_index=prompt.index,
                error=str(e),
                error_type=type(e).__name__,
            )

            await PhotoshootJobService.mark_image_failed(job.job_id, prompt.index, str(e))

            # Get updated job state for accurate counts
            updated_job = await PhotoshootJobService.get_job_by_id(job.job_id)
            generated_count = updated_job.generated_count if updated_job else 0
            failed_count = updated_job.failed_count if updated_job else 0

            # Broadcast failure
            await PhotoshootJobService.broadcast_event(job.job_id, "image_failed", {
                "job_id": job.job_id,
                "index": prompt.index,
                "label": _scene_label(prompt),
                "error": str(e),
                "generated_count": generated_count,
                "failed_count": failed_count,
                "total_count": job.num_images,
                "timestamp": utcnow_iso(),
            })

            return None
