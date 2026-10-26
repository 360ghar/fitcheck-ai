# You are installing Motion Director

The person in this folder bought **Motion Director**, a Claude Code skill that turns an idea into a finished 10–20 second video (MP4, original soundtrack) in about 10 minutes. Your job right now is to install it, prove it works, and get them their first video.

When they say anything (usually "hi"), do this. Keep every message short and friendly.

1. **Say what's about to happen** in one line: "I'll install Motion Director (about a minute), then we can make your first video."
2. **Check Node.js:** run `node --version`. If it's missing or older than 18, ask them to install the LTS from https://nodejs.org, then continue.
3. **Install the skill** by copying the `motion-director/` folder in this directory to their personal Claude skills folder, replacing any older copy:
   - macOS / Linux: `mkdir -p ~/.claude/skills && rm -rf ~/.claude/skills/motion-director && cp -R motion-director ~/.claude/skills/motion-director`
   - Windows (PowerShell): `New-Item -ItemType Directory -Force "$HOME\.claude\skills" | Out-Null; Remove-Item -Recurse -Force "$HOME\.claude\skills\motion-director" -ErrorAction SilentlyContinue; Copy-Item -Recurse motion-director "$HOME\.claude\skills\motion-director"`
4. **Install the renderer:** `node ~/.claude/skills/motion-director/engine/setup.mjs` (Windows: `node "$HOME\.claude\skills\motion-director\engine\setup.mjs"`). It downloads a headless Chromium and ffmpeg into `~/.motion-director/runtime` the first time, which takes about a minute. It must end with "✓ Motion Director is ready".
5. **Tell them how to use it**, in two lines:
   - "From now on, in any Claude Code session, type **/motion-director** (or just ask for a video) and I'll make one."
   - "Videos are saved in the **Motion Director Videos** folder on your Desktop."
6. **Offer the first video now:** "Want to make one right now? Tell me what it's about." If they say yes, follow `motion-director/SKILL.md` exactly (the skill may not be registered in this session until Claude Code restarts, so read the file directly). ENGINE is `~/.claude/skills/motion-director/engine`.

If anything fails, show the exact error in one line, fix it (usually a missing Node, no internet, or a permissions issue on `~/.claude`), and retry that step. Never skip step 4's check.

To uninstall later: delete `~/.claude/skills/motion-director` and `~/.motion-director`.
