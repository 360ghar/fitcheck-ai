// Patch F1/F2 scene ranges to the real VO cue times (F1: "200" token; F2: "15" token).
import { readFileSync, writeFileSync } from "node:fs";

const PROJECT = "/Users/sakshammittal/Documents/360ghar/github/archived/fitcheck-ai/videos/fitcheck-ai-explainer";
// F1 cues: Every@0.04 · 200@0.86 · nothing@1.98 | F2 cues: 15@0.08 · 3@1.62 · half@3.35
const FIX = {
  1: [[0, 0.9], [0.9, 2.0], [2.0, 6.02]],
  2: [[0, 1.6], [1.6, 3.4], [3.4, 7.19]],
};

let sb = readFileSync(`${PROJECT}/STORYBOARD.md`, "utf8");
const tokens = sb.split(/(?=^## Frame\s)/m);
for (let i = 0; i < tokens.length; i++) {
  const head = tokens[i].match(/^## Frame\s+([^\n]+)$/m);
  if (!head) continue;
  const num = Number(head[1].match(/^(\d+)/)[1]);
  const ranges = FIX[num];
  if (!ranges) continue;
  tokens[i] = tokens[i].replace(
    /Scene (\d+) \(([\d.]+)[–-]([\d.]+)s\)/g,
    (mm, n) => `Scene ${n} (${ranges[Number(n) - 1][0]}–${ranges[Number(n) - 1][1]}s)`,
  );
}
sb = tokens.join("");
writeFileSync(`${PROJECT}/STORYBOARD.md`, sb);
console.log("✓ F1/F2 scene ranges patched to real cue times");
console.log("F1: 0–0.9 | 0.9–2.0 | 2.0–6.02");
console.log("F2: 0–1.6 | 1.6–3.4 | 3.4–7.19");
