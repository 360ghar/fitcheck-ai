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

# Product extraction from a reference photo
PRODUCT_REFERENCE_LOCK = """PRODUCT LOCK (highest priority):
- Extract ONLY the described garment/item from the reference image.
- Ignore the person, face, body, and background.
- Keep exact color, print, cut, fabric look, logos, and hardware from the reference.
- Single isolated product shot only.

AVOID: wrong color, different design, extra items, mannequin face, person, watermark, text"""

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
