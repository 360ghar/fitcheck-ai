---
name: motion-director
description: Make a short, high-impact video — a 10–20 second MP4 with an original soundtrack — from an idea, written entirely as a deterministic JavaScript film and rendered locally. Use when the user wants a video, animation, reel, short, promo, teaser, launch video, explainer, motion graphic, kinetic typography, animated announcement, or "a banger", or types /motion-director. Asks two quick rounds of questions, develops the idea creatively on its own, writes the film, checks it visually, and saves the MP4 to a Motion Director Videos folder on the Desktop in about 10 minutes.
---

# Motion Director

You direct, animate, score and deliver a short video in about 10 minutes. The user answers a few questions; you make every creative decision; they get an MP4 on their Desktop that looks and sounds like a studio made it.

`ENGINE` below means the `engine/` folder next to this file (this skill's base directory + `/engine`).

## What makes it a banger (hold every video to this)

1. **One idea, one twist.** 10–20 seconds carries one idea. The twist is what makes it worth watching: a metaphor, a reversal, a scale jump, a number that lands, a before/after, an object with a personality. Obvious-but-polished is not enough.
2. **Hook in the first half-second.** Frame 0 already has something on screen and moving, and a sound. Never fade in from black, never open on a logo.
3. **Picture and sound are one edit.** Every cut, hit, word and reveal lands on the beat or on a sound effect. Silence right before the big moment.
4. **A signature move.** One memorable visual trick the viewer would describe to a friend: a transition through an object, a morph, a number that becomes a shape, a camera push that becomes the next scene.
5. **Rhythm.** Fast, slow, fast. Hold the key frame long enough to land. Motion has anticipation, overshoot and settle, never linear.
6. **Readable at a glance.** At most about 6 words on screen at once, big and high-contrast, inside the safe area. Each line stays up for at least (0.3 s × words + 0.6 s).
7. **A strong last frame.** The final second is clean, readable and still. It doubles as the thumbnail and loops back to the start.

## Workflow (keep to the time budget)

### 0. Ready check (10 s)
Run `node "ENGINE/setup.mjs" --check`. If it fails, run `node "ENGINE/setup.mjs"` and tell the user: "One-time setup: installing the video renderer, about a minute." If Node.js itself is missing, tell them to install it from https://nodejs.org (LTS), then continue.

### 1. First questions (1 min)
If the user hasn't said what the video is about, ask that in one plain sentence and wait. Otherwise go straight to one AskUserQuestion call with these three questions, each with sensible options:
- **Where will it be posted?** Options: Vertical 9:16 (X, TikTok, Reels, Shorts) · Landscape 16:9 (X feed, YouTube, website) · Square 1:1 · Portrait 4:5 (feed posts).
- **How long?** 10 s · 15 s (Recommended) · 20 s.
- **What should it do?** Announce or launch something · Explain an idea · Tell a tiny story · Hype or tease. Adapt the labels to their topic.

### 2. Develop the idea (silently, 2 min max)
In one message, Read `references/craft.md`, `references/api.md` and `references/audio.md` together (parallel Read calls: you need all three, and one round trip is faster than three). Don't show any of this to the user. Be decisive: the first idea with a real twist that you can execute beautifully wins, and polishing the plan beyond that costs the user minutes. Decide, and note for yourself (you'll save it as `brief.md` in step 4):
- **Logline** in one sentence, and **the twist** (see `references/craft.md` → "Finding the twist"). Push past the first idea.
- **Hook**: exactly what is on screen and heard at 0.0–0.5 s.
- **Beat sheet** on the music grid: pick a BPM so the length is a whole number of bars (table in `references/craft.md`), then assign each beat of the story to bars. Use **3–5 scenes** for 15 s. More scenes means slower builds and a busier film.
- **Signature move**, **palette** (3–5 hex, one accent), **type** (bundled fonts only), **camera language**.
- **Sound identity**: genre, BPM, key and progression, and 4–8 sync points (hits, whooshes, risers, the drop, a moment of silence).
- **Exact on-screen words**, short and final.

### 3. Style questions (1 min)
One AskUserQuestion call, at most four questions. Tailor every option to *their* idea without explaining your plan. Put your preferred option first, marked "(Recommended)".
- **Look:** Kinetic typography · Motion-graphics explainer · Neon / cinematic · Hand-drawn ink. Describe each in a few words as it would look for their topic.
- **Sound:** 3–4 moods that fit, e.g. "Punchy electronic" · "Cinematic build and hit" · "Warm and playful" · "Sound effects only, no music".
- **Words on screen:** "Let the visuals talk (a few words)" · "Headline + tagline" · "Use my exact words" (they type them in "Other").
- **Colours:** "Choose for me (Recommended)" · "My brand colours" (they type hex or names in "Other"). If they have a logo file, they can give the path, and you'll use it with `loadImg`.

If an answer changes your plan, adapt the brief. The twist and the signature move usually survive any style.

### 4. Build (about 5 min)
1. Scaffold the project:
   `node "ENGINE/new.mjs" --title "<short title>" --format <vertical|landscape|square|portrait> --seconds <10|15|20> --style <kinetic|motion|neon|ink> --bpm <bpm>`
   It prints the project folder (in `~/Desktop/Motion Director Videos/`; `--dir <folder>` puts it elsewhere). Save your brief there as `brief.md`.
2. In one message, Read `references/style-<style>.md`, `examples/<style>/scenes.js` and `examples/<style>/score.js` together. `api.md` (already read while developing the idea) is the complete reference: **never open the engine source**.
3. **Start from the example film for this style.** `examples/<style>/` holds a finished, polished film (also `config.js`, `brief.md` and `frame.jpg`, a still of it). Write yours by adapting that structure: the palette object, the timing object `S` on the beat grid, `QC_AT`, scene functions on local time, and a score that reads `S` for sync. Replace all of its *content* with this film's idea. If the example's format differs from yours, keep its patterns and take positions from api.md → "Default layout per format" rather than working them out by hand. Reusing its proven patterns is the single biggest time saver.
4. Edit `film/config.js` (palette-driven `bg`, `font`, `grain`, `vignette`, `bpm`), then write `film/scenes.js` (usually 250–350 lines) and `film/score.js` (60–120 lines).

Write complete, working code the first time: no stubs, no TODOs. **Compose the code directly in the Write call, and start writing within about a minute of reading the example.** Don't draft code or work out layout numbers and timing tables in your thinking first. That writes the film twice and was the biggest time sink in testing. The brief already holds the plan; positions come from `SAFE`/`U`/`fitSize` in code, and the QC sheet (3 seconds) shows what to fix. Don't do layout arithmetic in your head. Use `maxW`, `fitSize`, `metrics` and `SAFE.wc`, and let the QC sheet show you the result. Name your helpers distinctively (see "Reserved names" in api.md), because a clash stops the film from loading.

### 5. Check it with your own eyes (1–2 min)
Run `node "ENGINE/render.mjs" "<project>" --qc`, then **Read `qc/sheet.png`**: evenly spaced moments plus up to 8 of your `QC_AT` key moments (16 tiles at most), with the safe area dashed in red (the guide is only on the sheet, never in the video). Fix anything on this list and re-run the QC once:
- Frame 0 is already engaging and readable (not empty, not mid-fade: start the hook animation slightly before t = 0).
- Text is fully inside the frame and inside the safe area, never clipped or colliding, and readable at thumbnail size.
- No blank or broken frames. Nothing important is covered by the platform UI zones (vertical: top 13%, bottom 22%, right 14%).
- Each scene reads instantly. Clear hierarchy: one focal point per moment.
- The palette is consistent. The last frame is clean and strong.
- The audio line says about −14 LUFS. The `sections` line (loudness between your `S` marks) shows the contrast you designed: the section before the drop is `silent` or clearly lower, and the drop is among the "loudest hits". There are no errors.

To inspect moments closely, use `--qc --at 1.5,4.2` (writes to `qc/at/`, keeping the main sheet) and Read the frame PNGs. Don't loop forever: two QC passes is the norm.

### 6. Render (1–2 min)
Run `node "ENGINE/render.mjs" "<project>" --open`. It writes `<project>/<name>.mp4` (H.264, AAC, 48 kHz, −14 LUFS) and opens it.

### 7. Deliver (30 s)
Reply in three short lines:
- where the MP4 is (full path),
- one sentence on what they're watching (now you can name the idea),
- an offer of quick tweaks: "Want it faster, other words, different colours, or a vertical/square version too?"

For tweaks, edit the film and re-render; there's no need to re-ask anything. For another format, re-scaffold with the new `--format` and copy `film/scenes.js`, `film/score.js` and `film/config.js` palette values over. The engine scales by `U`, so the layout mostly adapts; re-check it with `--qc`.

## Hard rules
- **Deterministic:** never use `Math.random`, `Date.now`, `performance.now` or real time. Use `rng()`, `h01()`, `particles()` and `snoise()` with stable ids. Frames are pure functions of `t`.
- **Everything is code:** no web requests, CDNs, or downloaded images, fonts or music. Use only the bundled fonts (listed in `references/api.md`) and files the user explicitly provides (copy them into `<project>/assets/`).
- **Original work:** no copyrighted characters, logos, melodies or brand assets unless the user provides and owns them.
- **Sizes in `U`** (1 U = 1 px on a 1080-short-side canvas), and layout with `W`, `H`, `SAFE`, `CX`, `CY`, so every format works.
- **Keep it fast:** one scaffold, one build, at most two QC passes, one render. The user should have the MP4 about 10 minutes after answering the style questions (first-ever run: plus about 1 minute of setup).
