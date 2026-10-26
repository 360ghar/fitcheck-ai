// One-off: (1) re-transcribe frame 1's WAV (its first pass returned 0 words),
// (2) re-time STORYBOARD.md — frame durations = real VO duration + design pad,
// and each Scene's time range re-anchored to the actual VO cue word times so
// reveals land on the spoken words. Then rebuild packets downstream.
import { readFileSync, writeFileSync } from "node:fs";

const { transcribeWav } = await import(
  "file:///Users/sakshammittal/.config/opencode/skills/media-use/audio/scripts/lib/tts.mjs"
);

const PROJECT = "/Users/sakshammittal/Documents/360ghar/github/archived/fitcheck-ai/videos/fitcheck-ai-explainer";

// ── 1. Fix frame 1 words ────────────────────────────────────────────
const meta = JSON.parse(readFileSync(`${PROJECT}/audio_meta.json`, "utf8"));
const f1 = meta.voices.find((v) => v.frame === 1);
if (!f1.words || f1.words.length === 0) {
  const words = await transcribeWav({ wavRel: "assets/voice/01-2.wav", lang: "en", hyperframesDir: PROJECT });
  if (!words || words.length === 0) throw new Error("frame 1 re-transcription returned no words");
  f1.words = words.map((w, i) => ({ id: `01-w${i}`, text: w.text, start: w.start, end: w.end }));
  writeFileSync(`${PROJECT}/audio_meta.json`, JSON.stringify(meta, null, 2));
  console.log(`✓ frame 1 re-transcribed: ${f1.words.length} words`);
} else {
  console.log(`· frame 1 already has ${f1.words.length} words`);
}

// ── 2. Re-time the storyboard ───────────────────────────────────────
const PAD = { 1: 3.2, 11: 3.0, 13: 3.5 };
const DEFAULT_PAD = 2.5;
const CUES = {
  1: ["every", "two", "nothing"],
  2: ["fifteen", "3", "half"],
  3: ["meet", "ai", "your"],
  4: ["snap", "extracts", "color"],
  5: ["your", "cataloged", "matches"],
  6: ["mix", "one", "generates"],
  7: ["plan", "checks", "never"],
  8: ["see", "virtual", "images"],
  9: ["it", "gaps", "scores"],
  10: ["share", "build", "climb"],
  11: ["emma", "marcus", "priya"],
  12: ["start", "unlock", "yearly"],
  13: ["fitcheck", "worn", "decided"],
};
const norm = (s) => s.toLowerCase().replace(/[.,!?…%:;—–-]+$/, "").replace(/^[-–—]+/, "").trim();

let sb = readFileSync(`${PROJECT}/STORYBOARD.md`, "utf8");
const tokens = sb.split(/(?=^## Frame\s)/m);
let total = 0;
const report = [];

for (let i = 0; i < tokens.length; i++) {
  const tok = tokens[i];
  const head = tok.match(/^## Frame\s+([^\n]+)$/m);
  if (!head) continue;
  const num = Number(head[1].match(/^(\d+)/)[1]);
  const voice = meta.voices.find((v) => v.frame === num);
  if (!voice) throw new Error(`frame ${num}: no voice in audio_meta.json`);
  const dur = Math.round((voice.duration_s + (PAD[num] ?? DEFAULT_PAD)) * 100) / 100;
  total += dur;

  // cue word start times
  const words = voice.words ?? [];
  const cueStarts = [];
  let prevIdx = -1;
  let missing = false;
  for (const cue of CUES[num] ?? []) {
    const c = norm(cue);
    let idx = -1;
    for (let j = prevIdx + 1; j < words.length; j++) {
      if (norm(words[j].text) === c) { idx = j; break; }
    }
    if (idx < 0) { missing = true; break; }
    prevIdx = idx;
    cueStarts.push(words[idx].start);
  }

  let ranges;
  if (missing || cueStarts.length < 2) {
    // fallback: proportional split of the new duration into 3 scenes
    console.warn(`⚠ frame ${num}: cues not fully matched — proportional split`);
    ranges = [[0, dur / 3], [dur / 3, (2 * dur) / 3], [(2 * dur) / 3, dur]];
  } else {
    const t2 = Math.max(0.1, cueStarts[1]);
    const t3 = Math.max(t2 + 0.1, cueStarts[2]);
    ranges = [
      [0, t2],
      [t2, t3],
      [t3, dur],
    ];
  }
  const r = ranges.map(([a, b]) => [Math.round(a * 10) / 10, Math.round(b * 10) / 10]);
  // clamp monotonic
  for (let k = 1; k < 3; k++) if (r[k][0] <= r[k - 1][1]) r[k][0] = Math.round((r[k - 1][1] + 0.1) * 10) / 10;

  let out = tok.replace(
    /Scene (\d+) \(([\d.]+)[–-]([\d.]+)s\)/g,
    (mm, n) => `Scene ${n} (${r[Number(n) - 1][0]}–${r[Number(n) - 1][1]}s)`,
  );
  out = out.replace(/^(\s*[-*]\s+duration\s*:\s*).*$/m, `$1${dur.toFixed(2)}s`);
  tokens[i] = out;
  report.push(`F${String(num).padStart(2)} ${dur.toFixed(2)}s  scenes ${r.map((x) => `${x[0]}–${x[1]}`).join(" | ")}${missing ? "  (proportional)" : ""}`);
}

sb = tokens.join("");
sb = sb.replace(/^duration: .*/m, `duration: ${total.toFixed(1)}s`);
writeFileSync(`${PROJECT}/STORYBOARD.md`, sb);
console.log(`✓ storyboard re-timed — total ${total.toFixed(1)}s`);
console.log(report.join("\n"));
