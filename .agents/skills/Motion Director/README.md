# Motion Director

**Type an idea. Answer a couple of questions. Get a finished video.**

Motion Director is a skill for Claude Code. It turns an idea into a 10–20 second video with an original soundtrack in about 10 minutes: vertical for X, TikTok, Reels and Shorts, or landscape, square or 4:5.

There's no stock footage, no editing app and no template. Claude directs, animates and scores every video from scratch, as code:
- it develops the idea into something with a twist,
- writes the animation and the music,
- checks every frame it made with its own eyes,
- and saves a crisp MP4 (1080p, H.264, mastered audio) to your Desktop.

---

## Install (one time, about 2 minutes)

1. Unzip this folder.
2. Open a terminal in it and run `claude`.
3. Type `hi`. Claude installs Motion Director and checks everything works.

You need a **Mac** (Windows and Linux should work but haven't been tested yet), **Claude Code** (it comes with a paid Claude plan) and **Node.js 18+** (https://nodejs.org). Motion Director fetches its own renderer (a headless Chromium and ffmpeg) the first time, into `~/.motion-director`.

## Make a video

In any Claude Code session, type **`/motion-director`**, or just ask: *"make me a video announcing our launch on Monday"*.

1. Claude asks **where it's going** (vertical, landscape, square, 4:5), **how long** (10, 15 or 20 s), and **what it should do** (announce, explain, tell a story, tease).
2. It quietly develops the idea: the hook, the twist, the beat structure, the palette, the sound.
3. It asks about **style**:
   - **Kinetic typography:** bold words slamming on the beat.
   - **Motion-graphics explainer:** clean shapes, icons and charts.
   - **Neon / cinematic:** light, particles, a big reveal.
   - **Hand-drawn ink:** a charming illustrated short.

   It also asks about **sound**, **words** and **colours** (bring your brand colours or a logo file if you have them).
4. About 10 minutes later the MP4 opens, saved in **Desktop → Motion Director Videos**.

Want changes? Just say *"faster"*, *"change the headline to …"*, *"make a square version"*, and it re-renders.

## Good to know

- **Yours to use.** Every video and soundtrack is generated fresh, so there's no stock or licensed music inside. Use them commercially. The bundled fonts are open-licensed (see `motion-director/engine/fonts/FONTS.md`).
- **Editable.** Each video is a small project folder (`film/scenes.js` for the picture, `film/score.js` for the sound). Open `film.html` in Chrome to scrub through it frame by frame.
- **Your assets.** Give Claude the path to a logo or product image and it will animate it in.
- **Offline rendering.** Nothing is uploaded anywhere. Rendering happens on your computer.
- **Uninstall:** delete `~/.claude/skills/motion-director` and `~/.motion-director`.

## What's in this folder

| | |
|---|---|
| `START HERE.txt` | the 3-step install |
| `CLAUDE.md` | tells Claude how to install Motion Director when you say "hi" |
| `motion-director/` | the skill: `SKILL.md` (the workflow), `references/` (the craft playbook), `engine/` (animation, audio and render engine) |
| Example videos | four finished videos made with Motion Director, one per style: https://www.tobiadonadon.com/projects/construct/material/skills/motion-director (their source code is in `motion-director/examples/`) |
