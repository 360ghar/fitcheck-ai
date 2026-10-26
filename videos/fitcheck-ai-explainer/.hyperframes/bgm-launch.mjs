// Launch the detached BGM generate (local MusicGen) with a phantom voice in the
// sidecar so totalDuration targets the real video length (93.57s). The engine
// reads the sidecar at startup; the phantom is removed by the orchestrator
// after the engine run completes (before fetch-sfx rebuilds audio_meta.json).
import { readFileSync, writeFileSync, openSync, mkdirSync } from "node:fs";
import { spawn } from "node:child_process";

const PROJECT = "/Users/sakshammittal/Documents/360ghar/github/archived/fitcheck-ai/videos/fitcheck-ai-explainer";
const ENGINE = "/Users/sakshammittal/.config/opencode/skills/media-use/audio/scripts/audio.mjs";
const TARGET = 93.57;

const sidecar = `${PROJECT}/audio_engine_meta.json`;
const meta = JSON.parse(readFileSync(sidecar, "utf8"));
const voSum = Math.round(meta.voices.reduce((a, v) => a + (v.duration_s || 0), 0) * 1000) / 1000;
const phantom = Math.round((TARGET - voSum) * 100) / 100;
meta.voices.push({ id: "99", path: "assets/voice/99.wav", duration_s: phantom, words: [] });
writeFileSync(sidecar, JSON.stringify(meta, null, 2));

writeFileSync(
  `${PROJECT}/audio_request.json`,
  JSON.stringify(
    {
      lines: [],
      bgm: {
        mode: "generate",
        prompt:
          "upbeat playful modern pop instrumental, bright plucked synths, light percussion and handclaps, optimistic groovy fashion-commercial energy, 118 bpm, clean and punchy, no vocals",
      },
    },
    null,
    2,
  ),
);

mkdirSync(`${PROJECT}/assets/bgm`, { recursive: true });
const log = openSync(`${PROJECT}/assets/bgm/engine-run.log`, "w");
const child = spawn(
  process.execPath,
  [ENGINE, "--request", `${PROJECT}/audio_request.json`, "--hyperframes", PROJECT, "--out", sidecar, "--only", "bgm"],
  { detached: true, stdio: ["ignore", log, log], env: { ...process.env, GEMINI_API_KEY: "", GOOGLE_API_KEY: "", HYPERFRAMES_PYTHON: `${process.env.HOME}/.kokoro-venv/bin/python` } },
);
child.unref();
console.log(`✓ BGM engine launched detached (pid ${child.pid})`);
console.log(`  VO ${voSum}s + phantom ${phantom}s → target bed ${TARGET}s (seed 28s × 4 crossfade loops)`);
console.log(`  log: assets/bgm/engine-run.log · track will land at assets/bgm/track.wav`);
console.log(`  REMEMBER: remove phantom voice id=99 from audio_engine_meta.json after the engine run completes, before fetch-sfx`);
