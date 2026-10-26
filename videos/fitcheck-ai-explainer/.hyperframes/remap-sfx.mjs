// Remap storyboard sfx cue names to the bundled SFX library's actual files.
import { readFileSync, writeFileSync } from "node:fs";

const PROJECT = "/Users/sakshammittal/Documents/360ghar/github/archived/fitcheck-ai/videos/fitcheck-ai-explainer";
const REMAP = {
  1: "pop, whoosh-short",
  2: "click, click, click",
  3: "sparkle, pop",
  4: "click, chime, key-press",
  5: "key-press, sparkle",
  6: "click, sparkle",
  7: "whoosh-short, pop",
  8: "whoosh-short, click",
  9: "sparkle, whoosh-short",
  10: "chime, click",
  11: "whoosh-short",
  12: "click, chime",
  13: "impact-bass-1",
};

let sb = readFileSync(`${PROJECT}/STORYBOARD.md`, "utf8");
const tokens = sb.split(/(?=^## Frame\s)/m);
let n = 0;
for (let i = 0; i < tokens.length; i++) {
  const head = tokens[i].match(/^## Frame\s+([^\n]+)$/m);
  if (!head) continue;
  const m = head[1].match(/^(\d+)/);
  if (!m) continue;
  const num = Number(m[1]);
  if (!REMAP[num]) continue;
  const before = tokens[i];
  tokens[i] = tokens[i].replace(/^- sfx: .*$/m, "- sfx: " + REMAP[num]);
  if (tokens[i] !== before) n++;
}
sb = tokens.join("");
writeFileSync(`${PROJECT}/STORYBOARD.md`, sb);
console.log(`remapped ${n} sfx fields to bundled-library names`);
