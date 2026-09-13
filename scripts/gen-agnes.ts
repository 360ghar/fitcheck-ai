#!/usr/bin/env npx tsx
/**
 * scripts/gen-agnes.ts — Batch-generate landing visuals via Agnes image API.
 *
 * Node-only (no npm deps, uses global fetch — requires Node 18+).
 * Key hygiene: reads AGNES_API_KEY from env ONLY. Never hardcode, never log.
 *
 * Usage:
 *   export AGNES_API_KEY='<key>'   # never commit this
 *   npx tsx scripts/gen-agnes.ts                  # generate all clay assets (skips existing raw files)
 *   npx tsx scripts/gen-agnes.ts --force          # regenerate everything
 *   npx tsx scripts/gen-agnes.ts --only=office    # generate one entry by id
 *
 * Raw PNGs land in /tmp/agnes-raw/<filename>.png — convert with:
 *   cwebp -q 82 <raw>.png -o frontend/public/generated/<name>.webp
 *   cwebp -q 82 -resize 640 0 <raw>.png -o frontend/public/generated/<name>-640.webp
 *
 * API contract: POST https://apihub.agnes-ai.com/v1/images/generations
 *   headers: Authorization: Bearer $AGNES_API_KEY + Content-Type: application/json
 *   body: {model:'agnes-image-2.5-flash', prompt, size, ratio,
 *          extra_body:{response_format:'url'}}
 *   read: data[0].url (expires — download immediately).
 * Docs: https://www.agnes-ai.com/en/docs/agnes-image-25-flash
 */

const API_URL = "https://apihub.agnes-ai.com/v1/images/generations";
const MODEL = "agnes-image-2.5-flash";
const TIMEOUT_MS = 120_000;
const GAP_MS = 2_000;
const MAX_RETRIES = 3;
const RAW_DIR = "/tmp/agnes-raw";

// clay-rebuild illustration direction: objects and scenes only — no faces, no hands.
const STYLE_SUFFIX =
  "handmade claymation-style 3D illustration, matte clay material, rounded organic shapes, soft studio light, warm cream background, tactile, playful, no text, no logos, no watermark, no people";

interface Asset {
  id: string;
  file: string; // raw png basename (without dir)
  size: "2K" | "1K";
  ratio: "4:3" | "3:4" | "1:1" | "16:9";
  prompt: string;
}

// NOTE (2026-09-13, clay-rebuild Wave 1): the previous photographic asset set
// (office/evening/festive/studio/avatar/howitworks/demobase) is retired from
// this script — its webp outputs already exist in frontend/public/generated/
// and its /tmp raws were cleared, so keeping the entries here would only
// re-generate photography the new direction replaces.
const ASSETS: Asset[] = [
  {
    id: "hero-machine",
    file: "hero-machine.png",
    size: "2K",
    ratio: "16:9",
    prompt: `A whimsical Rube-Goldberg-style wardrobe contraption: a wooden clothes rail with rounded clay hangers holding tiny folded knits, a small circular weather badge, playful ramps and rolling balls, the whole contraption resting on soft rolling green hills under a pastel cream sky, wide landscape composition with generous negative space. ${STYLE_SUFFIX}`,
  },
  {
    id: "primitive-catalog",
    file: "primitive-catalog.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A tidy row of rounded catalog cards made of soft clay, each card holding a miniature folded garment — a tiny sweater, a tiny pair of jeans, a tiny jacket — with one garment caught mid-transformation, half garment and half card, floating gently above a warm cream surface. ${STYLE_SUFFIX}`,
  },
  {
    id: "primitive-plan",
    file: "primitive-plan.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A weekly planner board made of soft clay, blank rounded pastel capsules arranged in a neat grid, tiny clay garments and sneakers resting on some capsules while the other capsules stay empty, one capsule slightly lifted out of its slot, plain unmarked capsule surfaces, warm cream surface below. ${STYLE_SUFFIX}, no letters, no numbers, no characters`,
  },
  {
    id: "primitive-preview",
    file: "primitive-preview.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A rounded freestanding clay mirror with a chunky frame, reflecting only a simple outfit silhouette — a shirt and trousers shape — in flat matte clay color, the mirror standing on a warm cream floor beside a small potted plant, no reflection of any person. ${STYLE_SUFFIX}`,
  },
  {
    id: "primitive-create",
    file: "primitive-create.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A playful flat-lay scene on a warm cream table where two chunky rounded gripper arms on articulated clay joints arrange garments — a folded shirt, rolled socks, small shoes — into a neat outfit layout, no humans, just the mechanical arms and the clothes. ${STYLE_SUFFIX}`,
  },
  {
    id: "primitive-understand",
    file: "primitive-understand.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A large chunky clay magnifying glass hovering over a neat stack of folded knits in pastel colors, small rounded clay chart shapes and dots floating beside the stack like soft analytics badges, warm cream surface. ${STYLE_SUFFIX}`,
  },
  {
    id: "empty-closet",
    file: "empty-closet.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A charming small empty wardrobe closet with rounded clay doors swung wide open, its rail completely bare except for one single clay hanger in a soft accent color, a cozy warm cream room around it with a tiny rug. ${STYLE_SUFFIX}`,
  },
  {
    id: "empty-outfit",
    file: "empty-outfit.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A rounded blank outfit canvas board lying flat on a warm cream surface, with a few scattered clay garments waiting at its edges — a folded sweater, a single shoe, a rolled sock, a small hat — plenty of empty space in the center. ${STYLE_SUFFIX}`,
  },
  {
    id: "doodle-stitch",
    file: "doodle-stitch.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A single playful hand-stitched dashed squiggle line in thick yarn running across a plain warm cream background, ending in one chunky sewn-on clay button, centered, extremely minimal, generous empty space around it. ${STYLE_SUFFIX}`,
  },
  {
    id: "doodle-star",
    file: "doodle-star.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A small chunky clay four-point star and a tiny round sparkle floating side by side on a plain warm cream background, centered, extremely minimal, generous empty space around them. ${STYLE_SUFFIX}`,
  },
  {
    id: "avatar-wardrobe-1",
    file: "avatar-wardrobe-1.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A cute rounded clay wardrobe cabinet character standing upright with chunky little feet, a pair of tiny sunglasses resting on its flat top, completely smooth surface with no facial features at all, one door slightly ajar showing a folded knit inside, warm cream background. ${STYLE_SUFFIX}, no eyes, no mouth, no face`,
  },
  {
    id: "weather-sun-cloud",
    file: "weather-sun-cloud.png",
    size: "1K",
    ratio: "1:1",
    prompt: `A chunky clay sun with soft rounded rays peeking behind a puffy clay cloud, and below them a tiny garment on a small clay hanger, floating over a warm cream background, simple weather motif, centered composition. ${STYLE_SUFFIX}`,
  },
  {
    id: "demo-strip-bg",
    file: "demo-strip-bg.png",
    size: "1K",
    ratio: "4:3",
    prompt: `A soft warm cream clay-textured backdrop, almost entirely empty, with a folded pastel sweater and a hanging shirt heavily blurred and barely visible in the far corners, extremely low contrast, calm and quiet, plain cream space across the middle. ${STYLE_SUFFIX}, muted, subtle, low contrast, barely visible, objects only, no figures, no characters`,
  },
];

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

async function generateOne(
  apiKey: string,
  asset: Asset,
): Promise<{ url: string; latencyMs: number }> {
  let lastErr = "";
  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    const t0 = Date.now();
    try {
      const res = await fetch(API_URL, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: MODEL,
          prompt: asset.prompt,
          size: asset.size,
          ratio: asset.ratio,
          extra_body: { response_format: "url" },
        }),
        signal: AbortSignal.timeout(TIMEOUT_MS),
      });
      if (res.status === 429 || res.status >= 500) {
        lastErr = `HTTP ${res.status} (retryable)`;
        console.error(`  [${asset.id}] attempt ${attempt}: ${lastErr} — backing off`);
        await sleep(GAP_MS * 2 ** attempt);
        continue;
      }
      if (!res.ok) {
        const body = (await res.text()).slice(0, 500);
        throw new Error(`HTTP ${res.status}: ${body}`);
      }
      const json = (await res.json()) as { data?: { url: string }[] };
      const url = json?.data?.[0]?.url;
      if (!url) throw new Error(`no data[0].url in response: ${JSON.stringify(json).slice(0, 300)}`);
      return { url, latencyMs: Date.now() - t0 };
    } catch (e) {
      lastErr = e instanceof Error ? e.message : String(e);
      if (/HTTP 4\d\d/.test(lastErr) && !/429/.test(lastErr)) throw e; // non-retryable 4xx
      console.error(`  [${asset.id}] attempt ${attempt} failed: ${lastErr.slice(0, 200)}`);
      if (attempt < MAX_RETRIES) await sleep(GAP_MS * 2 ** attempt);
    }
  }
  throw new Error(`[${asset.id}] exhausted retries. Last: ${lastErr.slice(0, 200)}`);
}

async function downloadNow(url: string, dest: string): Promise<number> {
  const res = await fetch(url, { signal: AbortSignal.timeout(TIMEOUT_MS) });
  if (!res.ok) throw new Error(`download HTTP ${res.status} for ${dest}`);
  const buf = Buffer.from(await res.arrayBuffer());
  const { writeFile, mkdir } = await import("node:fs/promises");
  const { dirname } = await import("node:path");
  await mkdir(dirname(dest), { recursive: true });
  await writeFile(dest, buf);
  return buf.length;
}

async function main() {
  const apiKey = process.env.AGNES_API_KEY;
  if (!apiKey) {
    console.error("FATAL: AGNES_API_KEY is not set. export AGNES_API_KEY='...' and retry.");
    process.exit(1);
  }
  const args = process.argv.slice(2);
  const force = args.includes("--force");
  const onlyArg = args.find((a) => a.startsWith("--only="))?.split("=")[1];
  const { existsSync } = await import("node:fs");

  const queue = onlyArg ? ASSETS.filter((a) => a.id === onlyArg) : ASSETS;
  if (onlyArg && queue.length === 0) {
    console.error(`FATAL: unknown --only=${onlyArg}. Valid: ${ASSETS.map((a) => a.id).join(", ")}`);
    process.exit(1);
  }

  console.log(`gen-agnes: ${queue.length} asset(s), model=${MODEL}, raw dir=${RAW_DIR}`);
  const tAll = Date.now();
  for (const [i, asset] of queue.entries()) {
    const dest = `${RAW_DIR}/${asset.file}`;
    if (!force && existsSync(dest)) {
      console.log(`[${i + 1}/${queue.length}] ${asset.id}: raw exists, skipping (use --force to redo)`);
      continue;
    }
    console.log(`[${i + 1}/${queue.length}] ${asset.id}: generating (${asset.size} ${asset.ratio})…`);
    const { url, latencyMs } = await generateOne(apiKey, asset);
    const bytes = await downloadNow(url, dest); // immediate — URLs expire
    console.log(`  -> ${(bytes / 1024).toFixed(0)}KB raw in ${(latencyMs / 1000).toFixed(1)}s gen: ${dest}`);
    if (i < queue.length - 1) await sleep(GAP_MS);
  }
  console.log(`gen-agnes done in ${((Date.now() - tAll) / 1000).toFixed(0)}s. Next: cwebp -q 82 to webp + 640w variants.`);
}

main().catch((e) => {
  console.error("FATAL:", e instanceof Error ? e.message : e);
  process.exit(1);
});
