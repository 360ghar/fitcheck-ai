"""
Shared prompt templates for identity-preserving image generation.

Optimized for weaker image models: short lock/free constraints, dense subject
locks, sandwich structure, and minimal negative lists. Avoid long "think twice"
meta-instructions — they waste context and do not improve weak model fidelity.
"""

# Short identity lock for person + reference image workflows
IDENTITY_LOCK = """IDENTITY LOCK (highest priority):
- Same person as the reference image. Do not redesign the face.
- KEEP UNCHANGED: face geometry, eyes, nose, mouth, skin tone/texture, age, gender presentation, hair identity, body proportions.
- CHANGE ONLY: clothing, pose, background, and lighting listed in the scene.
- No beautification, skin smoothing, face morph, or generic "model face".
- If text conflicts with the reference image for face/body/hair/skin, follow the image."""

# Ultra-short negatives (weak models handle 5–8 better than long essays)
SHORT_NEGATIVES = (
    "AVOID: different person, face morph, beauty filter, plastic skin, "
    "wrong age, wrong ethnicity, extra limbs, distorted hands, watermark, text"
)

# Outfit fidelity when inventory is provided
OUTFIT_LOCK = """OUTFIT LOCK:
- Match every listed clothing/footwear/accessory item exactly.
- Preserve color shades, materials, patterns, silhouette, fit, logos, and hardware.
- Do not add, remove, swap, or invent items."""

# Combined appendix for photoshoot image generation (appended after full_prompt)
PHOTOSHOOT_FIDELITY_APPENDIX = f"""{IDENTITY_LOCK}

{OUTFIT_LOCK}

{SHORT_NEGATIVES}

Output one photoreal image of THIS exact person. Face must stay clearly visible."""

# Compact block for outfit/try-on prompts that already include inventory
PERSON_REFERENCE_FIDELITY = f"""{IDENTITY_LOCK}

{OUTFIT_LOCK}

{SHORT_NEGATIVES}"""

# Product extraction from a reference photo. Stronger than the old version:
# enumerates every visual category the extraction prompt captures, so the
# generator cannot drift on print, texture, hardware, or branding.
PRODUCT_REFERENCE_LOCK = """PRODUCT LOCK (highest priority):
- Reproduce ONLY the single item described in the prompt, EXACTLY as it
  appears in the reference image: same colors, print, graphic content,
  pattern geometry, collar/neckline, sleeves, hem length and shape, pockets,
  fabric weave and weight, surface texture, sheen, distress, hardware color
  and finish, logo/branding placement and scale, and fit.
- The dense description in the prompt identifies WHICH item to reproduce and
  is the source of truth for those tokens.
- Ignore EVERY other garment, footwear, accessory, prop, person, face, body,
  and background visible in the reference photo. Output one item only.
- Single isolated product shot only: the item sits alone on a pure flat #FFFFFF
  field with a crisp, clean silhouette edge and nothing touching it - no cast
  shadow, no contact shadow, no reflection, no floor or table plane, no
  gradient, no vignette.

AVOID: extra items, second garment, partial second item, wrong color,
       different design, restyled cut, mannequin face, person, watermark,
       text, beautification, fabric smoothing, drop shadow, cast shadow,
       reflection, gradient background, vignette, gray backdrop, floor plane."""

# Product prompts that intentionally request a non-white background cannot
# reuse PRODUCT_REFERENCE_LOCK: its pure-white clause would contradict the
# caller and the post-generation matte. Keep the item fidelity constraints,
# but let the requested backdrop and shadow policy win.
PRODUCT_CUSTOM_BACKGROUND_LOCK = """PRODUCT LOCK (highest priority):
- Reproduce ONLY the single item described in the prompt, EXACTLY as it
  appears in the reference image: same colors, print, graphic content,
  pattern geometry, collar/neckline, sleeves, hem length and shape, pockets,
  fabric weave and weight, surface texture, sheen, distress, hardware color
  and finish, logo/branding placement and scale, and fit.
- The dense description in the prompt identifies WHICH item to reproduce and
  is the source of truth for those tokens.
- Ignore EVERY other garment, footwear, accessory, prop, person, face, body,
  and background visible in the reference photo. Output one item only.
- Output one opaque product photograph on the requested background; do not
  replace it with white, transparency, or a different scene.

AVOID: extra items, second garment, partial second item, wrong color,
       different design, restyled cut, mannequin face, person, watermark,
       text, beautification, fabric smoothing."""

# The backdrop clause above is not cosmetic: app/utils/background_removal.py
# cuts the alpha out of these images with a near-white threshold plus a
# border-connected flood fill, so a gradient, a vignette or a cast shadow
# directly degrades the cut (a contact shadow in particular survives as a
# detached grey blob). Never pass include_shadows=True on a matted path.

# Garment references for outfit generation. Unlike the busy multi-item source
# photos that broke single-item product extraction (see
# resolve_product_reference_image in app/utils/image_processing.py), these are
# the clean per-item studio shots stored on item_images.image_url, so they can
# be trusted as literal appearance sources. The text inventory still IDENTIFIES
# each item and remains the only source for items that have no image.
GARMENT_REFERENCE_LOCK = """GARMENT REFERENCE LOCK:
- Each numbered garment image shows exactly ONE item of this outfit, isolated. It is the appearance source of truth for THAT item only.
- Copy from each garment image: exact colors, print and graphic content, pattern geometry, collar/neckline, sleeves, hem length and shape, pockets, fabric weave and sheen, hardware color and finish, logo placement and scale, and cut.
- If the text inventory conflicts with a garment image, follow the image. Face, body, hair, and skin still come from the person image only.
- Keep the items separate: never merge two garments into one, never repeat a garment, never place a garment on the wrong part of the body.
- Take garment appearance only: ignore each garment image's background, mannequin, hanger, prop, crop, and any person visible in it.
- Items in the inventory with no reference image must be rendered from their text description alone.
- Output ONE cohesive photograph of the worn/arranged outfit.

AVOID: collage, grid, contact sheet, split screen, side-by-side panels,
       product tiles, duplicated garment, garment on the wrong body part,
       invented or extra garments."""

# The original uploaded photo the outfit's items were extracted from, sent as
# ONE extra reference on the upload flow only (GenerateOutfitRequest.
# use_source_photo -> resolve_outfit_source_reference). Unlike the per-item
# studio shots, this photo shows the garments AS WORN TOGETHER: real fit,
# draping, and layering that isolated product shots cannot carry. It is
# deliberately NOT an identity source — the person in the photo may not be the
# user — so face/body/hair/skin still come only from the person reference
# image (when one is present).
SOURCE_PHOTO_REFERENCE_LOCK = """SOURCE PHOTO LOCK (original uploaded photo):
- The source photo shows the exact outfit being worn. Copy EVERY listed garment exactly as it appears there: colors, print and graphic content, pattern geometry, collar/neckline, sleeves, hem length and shape, pockets, fabric weave and sheen, hardware color and finish, logo placement and scale, cut, AND how each piece fits, drapes, and layers over the others.
- Change ONLY the scene: pose, background, lighting, and camera angle listed in the scene instructions.
- The photo may show other garments, people, or props not in the outfit inventory - ignore them; never add, swap, merge, or repeat items.
- Face, body, hair, and skin come from the person reference image only (if one is present), never from this photo.
- If the source photo and a garment image disagree, the source photo wins for how the clothes are worn; the garment image still supplies isolated detail.

AVOID: copying the source photo's background, pose, or composition; adding unseen items; restyling the garments; changing how pieces layer or fit."""

# Shared instructions for the photoshoot *text* planner (LLM, not image model)
SUBJECT_LOCK_FIELDS = """Write subject_lock as one dense paragraph with concrete visual tokens:
face shape; jaw/chin/cheekbones; eye shape/color/spacing/brows; nose shape/bridge/size;
lip shape/fullness; exact skin tone and texture; moles/freckles/marks if any;
hair color/texture/style/part/hairline and facial hair if any; apparent age band;
gender presentation; body build/proportions; distinctive features.
Use specific words (e.g. "warm medium-brown skin", "hooded brown eyes", "center-part straight black hair") — not vague praise."""

FACE_VISIBLE_POSE_RULE = (
    "Pose/framing must keep the face clearly visible: prefer front or slight 3/4 turn "
    "(about 0–30°), eyes near camera, no sunglasses, no heavy face shadow, no extreme profile."
)

IDENTITY_SAFE_DIVERSITY_RULE = (
    "Never alter facial identity. Diversity comes only from setting, outfit, pose, and lighting. "
    "Do not use words that invent a new face (beautiful face, glamorous, perfect skin, idealized, model looks)."
)


def sandwich_prompt(
    subject_lock: str,
    scene_body: str,
    *,
    include_outfit_lock: bool = True,
) -> str:
    """Build identity-first / scene / identity-last prompt for weak image models."""
    subject = (subject_lock or "").strip()
    scene = (scene_body or "").strip()
    parts = []
    if subject:
        parts.append(f"SUBJECT LOCK (copy exactly):\n{subject}")
    parts.append(IDENTITY_LOCK)
    if include_outfit_lock:
        parts.append(OUTFIT_LOCK)
    if scene:
        parts.append(f"SCENE (change only these):\n{scene}")
    if subject:
        parts.append(f"SUBJECT LOCK (repeat — same person):\n{subject}")
    parts.append(SHORT_NEGATIVES)
    parts.append(
        "Output one photoreal photo of THIS same person. Do not invent a new face."
    )
    return "\n\n".join(parts)
