// runtime.mjs — locate Motion Director's one-time runtime (Playwright + ffmpeg), installed by setup.mjs.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createRequire } from 'node:module';

export const RUNTIME = process.env.MOTION_DIRECTOR_RUNTIME || path.join(os.homedir(), '.motion-director', 'runtime');
export const PINS = { playwright: '1.63.0', 'ffmpeg-static': '5.3.0' };

export function runtimeReady() {
  return fs.existsSync(path.join(RUNTIME, 'node_modules', 'playwright', 'package.json')) &&
         fs.existsSync(path.join(RUNTIME, 'node_modules', 'ffmpeg-static', 'package.json'));
}

export function loadRuntime() {
  if (!runtimeReady()) {
    console.error('Motion Director runtime not installed. Run: node "' + path.join(path.dirname(new URL(import.meta.url).pathname), 'setup.mjs') + '"');
    process.exit(2);
  }
  const req = createRequire(path.join(RUNTIME, 'package.json'));
  const { chromium } = req('playwright');
  const ffmpeg = req('ffmpeg-static');
  return { chromium, ffmpeg };
}
