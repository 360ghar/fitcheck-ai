#!/usr/bin/env node
// setup.mjs — one-time install of Motion Director's render runtime into ~/.motion-director/runtime:
// Playwright's headless Chromium (draws the frames) + a bundled ffmpeg (encodes the MP4).
// Safe to run any time: it only installs what's missing, then verifies everything works.
//   node setup.mjs          install if needed, then verify
//   node setup.mjs --check  verify only; exit 1 if not ready (fast, installs nothing)
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { RUNTIME, PINS, runtimeReady } from './runtime.mjs';

const check = process.argv.includes('--check');
const say = (s) => console.log(s);
const fail = (s) => { console.error('\n✗ ' + s); process.exit(1); };

const [maj] = process.versions.node.split('.').map(Number);
if (maj < 18) fail(`Node.js ${process.versions.node} is too old. Install Node 18 or newer from https://nodejs.org, then run this again.`);

const npm = process.platform === 'win32' ? 'npm.cmd' : 'npm';
function run(cmd, args, opts = {}) {
  const r = spawnSync(cmd, args, { cwd: RUNTIME, stdio: opts.quiet ? 'pipe' : 'inherit', encoding: 'utf8', shell: process.platform === 'win32' });
  if (r.status !== 0) fail(`${cmd} ${args.join(' ')} failed.${r.stderr ? '\n' + r.stderr.slice(-800) : ''}`);
  return r;
}

if (!runtimeReady()) {
  if (check) fail('runtime not installed');
  say('Installing the Motion Director render runtime (one time, about a minute)...');
  fs.mkdirSync(RUNTIME, { recursive: true });
  fs.writeFileSync(path.join(RUNTIME, 'package.json'), JSON.stringify({ name: 'motion-director-runtime', private: true, version: '1.0.0', dependencies: PINS }, null, 2));
  run(npm, ['install', '--no-audit', '--no-fund', '--loglevel=error']);
}

// Chromium: Playwright downloads it into its own cache on first use; only-shell = the small headless build.
const cli = path.join(RUNTIME, 'node_modules', 'playwright', 'cli.js');
const { createRequire } = await import('node:module');
const req = createRequire(path.join(RUNTIME, 'package.json'));
const { chromium } = req('playwright');
let exe = '';
try { exe = chromium.executablePath(); } catch { /* not installed */ }
if (!exe || !fs.existsSync(exe)) {
  // `install --only-shell` installs the small headless shell, which
  // executablePath() does not report (it names the full browser). So before
  // deciding the browser is missing, try launching the one we actually use;
  // otherwise --check fails on every fresh install and setup reruns each time.
  const launches = await chromium.launch().then((b) => b.close().then(() => true), () => false);
  if (!launches) {
    if (check) fail('browser not installed');
    say('Downloading headless Chromium (one time)...');
    run(process.execPath, [cli, 'install', '--only-shell', 'chromium']);
  }
}

// Verify: a real browser page can draw on a canvas, and ffmpeg can encode H.264.
const browser = await chromium.launch().catch((e) => fail('Chromium would not start: ' + e.message.split('\n')[0] +
  (process.platform === 'linux' ? `\nOn Linux this usually means missing system libraries. Install them once with:  sudo "${process.execPath}" "${cli}" install-deps chromium` : '')));
const page = await browser.newPage();
const ok = await page.evaluate(() => { const c = document.createElement('canvas'); c.width = 8; c.height = 8; const g = c.getContext('2d'); g.fillStyle = '#f00'; g.fillRect(0, 0, 8, 8); return c.toDataURL('image/png').length > 50; });
await browser.close();
if (!ok) fail('Chromium started but could not draw.');
const ffmpeg = req('ffmpeg-static');
const enc = spawnSync(ffmpeg, ['-hide_banner', '-encoders'], { encoding: 'utf8' });
if (enc.status !== 0 || !/libx264/.test(enc.stdout)) fail('The bundled ffmpeg is missing the H.264 encoder.');
say('✓ Motion Director is ready (runtime: ' + RUNTIME + ')');
