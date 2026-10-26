#!/usr/bin/env node
// new.mjs — create a new Motion Director video project (a self-contained folder you can preview and re-render).
//   node new.mjs --title "Launch day" --format vertical --seconds 15 --style kinetic [--bpm 120] [--fps 30] [--dir <parent>]
// Prints JSON: { dir, w, h, fps, seconds, style }.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ENGINE = path.dirname(fileURLToPath(import.meta.url));
const argv = process.argv.slice(2), arg = (k, d) => { const i = argv.indexOf('--' + k); return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : d; };

const FORMATS = { vertical: [1080, 1920], landscape: [1920, 1080], square: [1080, 1080], portrait: [1080, 1350] };
const STYLE_DEFAULTS = {
  kinetic: { fps: 30, bg: '#0d0d0d', grain: 0.06, vignette: 0, twos: false, bpm: 124, font: 'Bricolage Grotesque' },
  motion:  { fps: 30, bg: '#f4f1ea', grain: 0, vignette: 0, twos: false, bpm: 110, font: 'Outfit' },
  neon:    { fps: 30, bg: '#05050a', grain: 0.1, vignette: 0.45, twos: false, bpm: 128, font: 'Tektur' },
  ink:     { fps: 24, bg: '#e9e5da', grain: 0.35, vignette: 0.15, twos: true, bpm: 100, font: 'Instrument Serif' },
};
const title = arg('title', 'Untitled');
const format = arg('format', 'vertical');
const style = arg('style', 'kinetic');
if (!FORMATS[format]) { console.error('format must be one of: ' + Object.keys(FORMATS).join(', ')); process.exit(1); }
if (!STYLE_DEFAULTS[style]) { console.error('style must be one of: ' + Object.keys(STYLE_DEFAULTS).join(', ')); process.exit(1); }
const sd = STYLE_DEFAULTS[style];
const seconds = Math.max(3, Math.min(60, +arg('seconds', 15)));
const fps = +arg('fps', sd.fps), bpm = +arg('bpm', sd.bpm);
const [w, h] = FORMATS[format];

const desktop = path.join(os.homedir(), 'Desktop');
const parent = arg('dir', path.join(fs.existsSync(desktop) ? desktop : os.homedir(), 'Motion Director Videos'));
const slug = title.toLowerCase().normalize('NFKD').replace(/[^\w\s-]/g, '').trim().replace(/[\s_]+/g, '-').replace(/-+/g, '-').slice(0, 48) || 'video';
let dir = path.join(parent, slug), k = 2;
while (fs.existsSync(dir)) dir = path.join(parent, `${slug}-${k++}`);

fs.mkdirSync(path.join(dir, 'film'), { recursive: true });
fs.mkdirSync(path.join(dir, 'engine', 'fonts'), { recursive: true });
fs.copyFileSync(path.join(ENGINE, 'film.html'), path.join(dir, 'film.html'));
for (const f of ['motion.js', 'audio.js']) fs.copyFileSync(path.join(ENGINE, f), path.join(dir, 'engine', f));
for (const f of fs.readdirSync(path.join(ENGINE, 'fonts'))) fs.copyFileSync(path.join(ENGINE, 'fonts', f), path.join(dir, 'engine', 'fonts', f));

const cfg = { title, style, format, w, h, fps, seconds, bpm, bg: sd.bg, grain: sd.grain, vignette: sd.vignette, twos: sd.twos, font: sd.font };
fs.writeFileSync(path.join(dir, 'film', 'config.js'),
  `// Film settings. The engine reads these before anything else.\nwindow.FILM_CONFIG = ${JSON.stringify(cfg, null, 2)};\n`);
// A tiny working placeholder so the project renders before the real film is written.
fs.writeFileSync(path.join(dir, 'film', 'scenes.js'), `'use strict';
// Placeholder — replace with the film. frame(t) draws one frame at time t (seconds).
function frame(t) {
  const u = eOutQuint(seg(t, 0.2, 1.2));
  text(FILM.title, CX, CY, 110 * U, { align: 'center', base: 'middle', color: '#ffffff', alpha: u });
}
`);
fs.writeFileSync(path.join(dir, 'film', 'score.js'), `'use strict';
// Placeholder score — replace with the film's soundtrack. See references/audio.md.
function score(A) {
  A.pad(0, A.chord('Am7', 3), A.dur, 0.6);
}
`);
fs.writeFileSync(path.join(dir, 'README.txt'), `${title}
Made with Motion Director.

Preview:   open film.html in Chrome (scrub / play; no sound in preview).
Re-render: node "${path.join(ENGINE, 'render.mjs')}" "${dir}"
Edit:      film/scenes.js (picture), film/score.js (sound), film/config.js (format, length, colours).
`);
console.log(JSON.stringify({ dir, w, h, fps, seconds, style, bpm }, null, 2));
