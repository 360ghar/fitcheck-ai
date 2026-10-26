# App Designer

**iPhone apps that don't look like AI made them.**

App Designer is a skill for Claude Code. Ask an AI to design an app and you get the same app every time: a greeting at the top, a purple or lime accent, a stack of rounded cards, an icon in a tinted square on every row, emoji for icons. Nothing in it is wrong. Nothing in it was decided either.

App Designer gives Claude the process an award-winning studio would follow:

- **A concept, not a theme.** Every app starts as something real: an athletics track, a village going to sleep, a paper cut-out. That one idea decides the type, the colour and the motion.
- **Three directions, then one.** It designs your main screen three genuinely different ways (light, dark, a colour field; three type families; three kinds of imagery) before it commits.
- **Real content first.** Real names, uneven numbers, a believable state. Never lorem ipsum.
- **iOS 26, done properly.** Liquid Glass on the navigation layer only, Apple's own fonts (SF Pro in all its widths, New York, SF Rounded, SF Mono), Dynamic Type sizes, 44 pt targets, dark mode designed rather than inverted.
- **One signature interaction**, storyboarded with timing and haptics.
- **It checks its own work.** Every screen is rendered at iPhone resolution and scanned for the tells of AI design (emoji icons, purple gradients, confetti colour, greeting headers, card stacks, clipped or colliding text, weak contrast measured on the actual pixels). Then a separate critic scores it against a twelve-line rubric, and it iterates.

It can also carry the design into **SwiftUI** and into **App Store screenshot panels**.

---

## Install (one time, about a minute)

1. Unzip this folder.
2. Open a terminal in it and run `claude`.
3. Type `hi`. Claude installs App Designer and checks it works.

You need a **Mac** with **Google Chrome**, **Claude Code** (it comes with a paid Claude plan) and **Node.js 18+** (https://nodejs.org).

## Design an app

In any Claude Code session, type **`/app-designer`**, or just ask: *"design my app, it's a habit tracker for people who hate habit trackers"*.

1. Claude asks a few short questions: what the app is, the one thing people do every day in it, how it should feel, and what you already have.
2. It renders your main screen three different ways and tells you which it would pick and why.
3. It designs the full set: the main screen, a detail screen, the signature moment, dark mode, the app icon.
4. Every screen is scanned and scored, fixed, and scanned again. You get the folder: PNGs at iPhone resolution, a contact sheet, the direction, and the critique.

Want changes? Say *"warmer"*, *"try it dark"* or *"now the App Store screenshots"*.

## Good to know

- Everything runs on your computer. Nothing is uploaded.
- It remembers the directions it has used in `~/.app-designer/history.md`, so your next app doesn't come out looking like your last one.
- Uninstall: delete `~/.claude/skills/app-designer` and `~/.app-designer`.
