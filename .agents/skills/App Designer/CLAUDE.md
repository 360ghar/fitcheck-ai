# You are installing App Designer

The person in this folder downloaded **App Designer**, a Claude Code skill that designs iPhone apps like an award-winning studio instead of like AI: a real concept, three directions explored, every screen rendered with Apple's own fonts, scanned for AI slop and scored by a critic. Your job right now is to install it, prove it works, and offer to design their first app.

When they say anything (usually "hi"), do this. Keep every message short and friendly.

1. **Say what's about to happen** in one line: "I'll install App Designer (about a minute), then we can design your first app."
2. **Check the machine:**
   - `node --version`. If it's missing or older than 18, ask them to install the LTS from https://nodejs.org, then continue.
   - It must be a Mac (`uname` says `Darwin`) with Google Chrome installed (`ls "/Applications/Google Chrome.app"`). If Chrome is missing, ask them to install it from https://www.google.com/chrome, then continue. On a non-Mac, say plainly that the screen renders need a Mac's fonts and Chrome, and stop.
3. **Install the skill** by copying the `app-designer/` folder in this directory to their personal Claude skills folder, replacing any older copy:
   `mkdir -p ~/.claude/skills && rm -rf ~/.claude/skills/app-designer && cp -R app-designer ~/.claude/skills/app-designer`
4. **Install the renderer** (a small library that drives their own Chrome): `cd ~/.claude/skills/app-designer && npm install --no-fund --no-audit`
5. **Prove it works:** run `node ~/.claude/skills/app-designer/scripts/shoot.mjs ~/.claude/skills/app-designer/assets/check.html --out /tmp/app-designer-check --scale 1`. It must print "Shot 1 screen(s)" and "No FAILs". If it fails, show the error in one line, fix it (usually Chrome missing, or no internet during npm install) and retry. Never skip this check.
6. **Tell them how to use it**, in two lines:
   - "From now on, in any Claude Code session, type **/app-designer** (or just ask me to design your app)."
   - "Each design gets its own folder with the screens as PNGs, a contact sheet, and the design direction written down."
7. **Offer the first app now:** "Want to design one right now? Tell me what it does and who it's for." If they say yes, follow `~/.claude/skills/app-designer/SKILL.md` exactly (the skill may not be registered in this session until Claude Code restarts, so read the file directly). Work in a new folder on their Desktop named after the app.

To uninstall later: delete `~/.claude/skills/app-designer` and `~/.app-designer`.
