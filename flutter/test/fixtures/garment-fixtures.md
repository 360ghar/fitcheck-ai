# Synthetic garment fixtures

These images are synthetic sample artwork for UI tests and the September 2026
store listing pack. They are not real user garments or shipped app assets.
The built-in OpenAI imagegen tool generated all four
images on 2026-09-05. No reference images or existing brands were used.

| File | Subject | Format | Size | Fully transparent pixels |
|---|---|---|---|---|
| `garment-ecru-shirt.png` | Ecru linen shirt | 1122×1402 RGBA PNG | 1,945,296 bytes | 32.6% |
| `garment-charcoal-trousers.png` | Charcoal tailored trousers | 1122×1402 RGBA PNG | 1,721,408 bytes | 50.1% |
| `garment-tobacco-loafers.png` | Tobacco suede loafers | 1122×1402 RGBA PNG | 1,870,042 bytes | 50.1% |
| `garment-sage-overshirt.png` | Muted sage cotton overshirt | 1122×1402 RGBA PNG | 1,932,691 bytes | 42.0% |

Each file has an alpha range of 0–255 and fully transparent corners. The PNGs were
copied without modification. Their backgrounds contain real alpha transparency,
not a rendered checkerboard. The tool returned larger images than requested.

A subsequent overshirt edge-cleanup attempt produced an RGB image with a rendered
checkerboard. That output was rejected. The retained overshirt file is the
original RGBA generation with verified alpha.

## Prompts

### Tobacco loafers

Use case: product-mockup. Asset type: synthetic garment fixture for a mobile wardrobe catalogue UI test. Generate ONE pair of tobacco-brown suede penny loafers, both shoes seen from above at a subtle three-quarter angle, arranged side by side with a small gap, toes pointing upward. Entire pair visible and centered with a small even margin. Clearly show fine suede nap, restrained penny straps, clean stitching, and thin dark brown soles. Premium understated footwear with no visible branding. The pair is the ONLY subject: no feet, person, socks, clothing, box, accessories, ground, tabletop, border, typography, or cast shadow outside the shoes. Neutral diffuse studio lighting on the suede itself. Deliver a PNG with a genuinely transparent alpha background around the pair and in the gap between shoes; empty space must have alpha=0. Do not render any checkerboard pattern or solid background. Keep the shoes opaque and the cutout edges clean. Aim for a compact 512 by 640 pixel portrait image suitable for a test fixture, not a large poster.

### Sage overshirt

Use case: product-mockup. Asset type: synthetic garment fixture for a mobile wardrobe catalogue UI test. Generate ONE photorealistic muted sage cotton-twill overshirt jacket, shown from the front in a natural flat-lay cutout arrangement, sleeves angled slightly down and out, entire jacket visible and centered with a small even margin. The jacket has a simple point collar, two restrained chest patch pockets, tonal buttons, a straight hem, and long sleeves with cuffs. Clearly show subtle cotton weave and soft natural fabric folds. Premium understated clothing in a low-saturation grey-green sage colour with no visible branding. The jacket is the ONLY object: no hanger, person, mannequin, other clothing, accessories, ground, tabletop, border, typography, or cast shadow outside the garment. Neutral diffuse studio lighting on the fabric itself. Deliver a PNG with a genuinely transparent alpha background around the garment and in gaps between sleeves and torso; empty space must have alpha=0. Do not render any checkerboard pattern or solid background. Keep the garment opaque and the cutout edge clean. Aim for a compact 512 by 640 pixel portrait image suitable for a test fixture, not a large poster.

### Ecru shirt

Use case: product-mockup. Asset type: synthetic garment fixture for a mobile wardrobe catalogue UI test. Generate ONE photorealistic ecru linen long-sleeve button-up shirt, shown from the front in a natural flat-lay cutout arrangement, sleeves angled slightly down and out, entire shirt visible and centered with a small even margin. Clearly show the linen weave, soft natural fabric folds, collar, tonal buttons, and rounded hem. Premium understated clothing with no visible branding. The shirt is the ONLY object: no hanger, person, mannequin, accessories, ground, tabletop, border, typography, or cast shadow outside the garment. Neutral diffuse studio lighting on the fabric itself. Deliver a PNG with a genuinely transparent alpha background around the garment and in gaps between sleeves and torso; empty space must have alpha=0. Do not render any checkerboard pattern or solid background. Keep the garment opaque and the cutout edge clean. Aim for a compact 512 by 640 pixel portrait image suitable for a test fixture, not a large poster.

### Charcoal trousers

Use case: product-mockup. Asset type: synthetic garment fixture for a mobile wardrobe catalogue UI test. Generate ONE photorealistic pair of charcoal wool tailored trousers, shown front-on in a natural flat-lay cutout arrangement, both legs visible with slight separation and a straight full-length silhouette. Entire garment centered with a small even margin. Clearly show subtle wool texture, waistband, belt loops, single pleats, pockets, fly, and natural fabric folds. Premium understated clothing with no visible branding. The trousers are the ONLY object: no hanger, person, mannequin, shoes, belt, accessories, ground, tabletop, border, typography, or cast shadow outside the garment. Neutral diffuse studio lighting on the fabric itself. Deliver a PNG with a genuinely transparent alpha background around the garment and between the legs; empty space must have alpha=0. Do not render any checkerboard pattern or solid background. Keep the garment opaque and the cutout edge clean. Aim for a compact 512 by 640 pixel portrait image suitable for a test fixture, not a large poster.
