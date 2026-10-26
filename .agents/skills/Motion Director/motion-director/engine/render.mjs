#!/usr/bin/env node
// render.mjs — render a Motion Director project.
//   node render.mjs <projectDir>              full render -> <projectDir>/<folder-name>.mp4
//   node render.mjs <projectDir> --qc         fast check: 12 frames + contact sheet + audio check -> <projectDir>/qc/
//   node render.mjs <projectDir> --qc --at 0.5,2,4.25    check specific moments (seconds)
// Options: --workers N  --out file.mp4  --open  --no-audio  --crf 17
// Frames are streamed straight into ffmpeg (no temporary PNG files on disk).
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawn } from 'node:child_process';
import vm from 'node:vm';
import { once } from 'node:events';
import { pathToFileURL } from 'node:url';
import { loadRuntime } from './runtime.mjs';

const argv = process.argv.slice(2);
const flag = (k) => argv.includes('--' + k);
const opt = (k, d) => { const i = argv.indexOf('--' + k); return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : d; };
const positional = argv.filter((a, i) => !a.startsWith('--') && !(i > 0 && argv[i - 1].startsWith('--') && ['workers', 'out', 'crf', 'at'].includes(argv[i - 1].slice(2))));
const proj = path.resolve(positional[0] || '.');
const html = path.join(proj, 'film.html');
if (!fs.existsSync(html)) { console.error(`No film.html in ${proj}`); process.exit(1); }

const { chromium, ffmpeg } = loadRuntime();
const T0 = Date.now();
const errors = [];

// Turn a browser-side exception into one clear line: what, where (film file + line), when, and a
// "did you mean" for misspelled names, instead of a Node stack trace.
async function explain(e, page) {
  const raw = String((e && (e.stack || e.message)) || e).replace(/^(?:(?:page\.evaluate|Error): )+/gm, '');
  const at = (raw.match(/^FILMERR t=([\d.]+)/m) || [])[1];
  const msg = (raw.split('\n').find((l) => l.trim() && !/^FILMERR|^\s+at /.test(l)) || raw.split('\n')[0]).trim();
  const loc = raw.match(/(scenes|score|config)\.js:(\d+)(?::\d+)?/);
  let hint = '';
  const missing = (msg.match(/^ReferenceError: (\S+) is not defined/) || [])[1];
  const member = msg.match(/^TypeError: (?:[\w$.]*\.)?([\w$]+)\.([\w$]+) is not a function/);
  if (member && page) {      // e.g. A.kik(...) → did you mean A.kick?
    let keys = await page.evaluate((o) => { try { const v = (0, eval)(o); return v ? Object.keys(v).concat(Object.getOwnPropertyNames(Object.getPrototypeOf(v) || {})) : []; } catch { return []; } }, member[1]).catch(() => []);
    if (!keys.length) {      // not a global (e.g. the score's A): fall back to the names defined in the engine source
      const src = ['engine/audio.js', 'engine/motion.js'].map((f) => { try { return fs.readFileSync(path.join(proj, f), 'utf8'); } catch { return ''; } }).join('\n');
      const kw = new Set(['if', 'for', 'while', 'switch', 'catch', 'function', 'return', 'else', 'case', 'default', 'try', 'new', 'typeof']);
      keys = [...src.matchAll(/^\s*([A-Za-z_$][\w$]*)\s*(?:\(|:)/gm)].map((m) => m[1]).filter((k) => !kw.has(k));
    }
    const dd = (a, b) => { const m = [...Array(b.length + 1).keys()]; for (let i = 1; i <= a.length; i++) { let p = m[0]; m[0] = i; for (let j = 1; j <= b.length; j++) { const t = m[j]; m[j] = Math.min(m[j] + 1, m[j - 1] + 1, p + (a[i - 1].toLowerCase() === b[j - 1].toLowerCase() ? 0 : 1)); p = t; } } return m[b.length]; };
    const near = [...new Set(keys)].filter((k) => k !== 'constructor' && dd(member[2], k) <= Math.max(2, Math.floor(member[2].length / 3))).sort((a, b) => dd(member[2], a) - dd(member[2], b)).slice(0, 3);
    if (near.length) hint = `  Did you mean: ${near.map((k) => member[1] + '.' + k).join(', ')}? (see references/${member[1] === 'A' ? 'audio' : 'api'}.md)`;
  }
  if (missing && page) {
    // candidate names = identifiers in the engine and film sources that really exist in the page's global scope
    const d = (a, b) => { const m = [...Array(b.length + 1).keys()]; for (let i = 1; i <= a.length; i++) { let p = m[0]; m[0] = i; for (let j = 1; j <= b.length; j++) { const t = m[j]; m[j] = Math.min(m[j] + 1, m[j - 1] + 1, p + (a[i - 1].toLowerCase() === b[j - 1].toLowerCase() ? 0 : 1)); p = t; } } return m[b.length]; };
    const src = ['engine/motion.js', 'engine/audio.js', 'film/scenes.js', 'film/score.js'].map((f) => { try { return fs.readFileSync(path.join(proj, f), 'utf8'); } catch { return ''; } }).join('\n');
    const close = [...new Set(src.match(/\b[A-Za-z_$][\w$]{2,}\b/g) || [])].filter((n) => n !== missing && d(missing, n) <= Math.max(2, Math.floor(missing.length / 3))).sort((a, b) => d(missing, a) - d(missing, b));
    const near = (await page.evaluate((names) => names.filter((n) => { try { return (0, eval)('typeof ' + n) !== 'undefined'; } catch { return false; } }), close).catch(() => [])).slice(0, 3);
    hint = near.length ? `  Did you mean: ${near.join(', ')}? (see references/api.md)` : '  Not an engine function: check references/api.md or define it.';
  }
  return `✗ Film error${at ? ` at t = ${at} s` : ''}${loc ? ` in film/${loc[1]}.js line ${loc[2]}` : ''}: ${msg}${hint ? '\n' + hint : ''}`;
}
// syntax errors: the browser doesn't say where, so parse the film files here to get the line
function syntaxWhere() {
  for (const f of ['film/config.js', 'film/scenes.js', 'film/score.js']) {
    try { new vm.Script(fs.readFileSync(path.join(proj, f), 'utf8'), { filename: f }); }
    catch (e) { if (e instanceof SyntaxError) { const l = String(e.stack).match(new RegExp(f.replace('.', '\\.') + ':(\\d+)')); return `${f}${l ? ' line ' + l[1] : ''}: SyntaxError: ${e.message}`; } }
  }
  return '';
}
let dead = false; const onDie = [];
async function die(e, page) {
  if (dead) return new Promise(() => {});        // parallel workers: report the first error only
  dead = true; console.error(await explain(e, page));
  onDie.forEach((f) => { try { f(); } catch {} });
  await browser.close().catch(() => {}); process.exit(1);
}
const browser = await chromium.launch({ args: ['--force-color-profile=srgb', '--font-render-hinting=none', '--disable-lcd-text'] });

async function openPage() {
  const page = await browser.newPage({ viewport: { width: 640, height: 640 }, deviceScaleFactor: 1 });
  page.on('pageerror', (e) => { const l = String(e.stack || '').match(/(scenes|score|config)\.js:(\d+)/); errors.push(e.message + (l ? ` (film/${l[1]}.js line ${l[2]})` : '')); });
  page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });
  await page.goto(pathToFileURL(html).href + '?render');
  try { await page.evaluate(() => window.__reelReady); }
  catch (e) { const syn = syntaxWhere(); console.error('✗ The film failed to start:\n  ' + (syn || errors.join('\n  ') || (await explain(e, page)).replace(/^✗ /, ''))); await browser.close(); process.exit(1); }
  return page;
}
const page0 = await openPage();
const meta = await page0.evaluate(() => ({ frames: window.__reel.frames, fps: window.__reel.fps, w: window.__reel.w, h: window.__reel.h, seconds: window.__reel.seconds }));
const { frames: F, fps, w: W, h: H } = meta;

// ------------------------------------------------------------------ QC: contact sheet + checks
if (flag('qc')) {
  const qcDir = opt('at') ? path.join(proj, 'qc', 'at') : path.join(proj, 'qc');
  fs.rmSync(qcDir, { recursive: true, force: true }); fs.mkdirSync(qcDir, { recursive: true });
  let list = opt('at') ? opt('at').split(',').map((s) => Math.min(F - 1, Math.max(0, Math.round(parseFloat(s) * fps)))) : null;
  if (!list) {
    // evenly spaced moments (8 when the film names its key moments, else 12) plus the film's own key moments
    // (const QC_AT = [seconds...] in scenes.js, up to 8): at most 16 tiles, so the sheet stays readable
    const keyT = await page0.evaluate(() => (typeof QC_AT !== 'undefined' && Array.isArray(QC_AT)) ? QC_AT : []);
    const n = keyT.length >= 4 ? 8 : 12; list = Array.from({ length: n }, (_, i) => Math.round(i * (F - 1) / (n - 1)));
    for (const kt of keyT.slice(0, 8)) {
      const kf = Math.min(F - 1, Math.max(0, Math.round(kt * fps)));
      if (!list.some((f) => Math.abs(f - kf) <= 2)) list.push(kf);
    }
    list = [...new Set(list)].sort((a, b) => a - b);
  }
  const res = await page0.evaluate(async (list) => {
    const S = window.__safe || null;
    const W = window.__reel.w, H = window.__reel.h, src = document.getElementById('c');
    const cols = W >= H ? 3 : 4, gap = 14, lab = 30, sheetW = 1800;
    const tw = Math.floor((sheetW - gap * (cols + 1)) / cols), th = Math.round(tw * H / W), rows = Math.ceil(list.length / cols);
    const sheet = document.createElement('canvas'); sheet.width = sheetW; sheet.height = gap + rows * (th + lab + gap);
    const g = sheet.getContext('2d'); g.fillStyle = '#1b1b1f'; g.fillRect(0, 0, sheet.width, sheet.height);
    const probe = document.createElement('canvas'); probe.width = 48; probe.height = Math.max(8, Math.round(48 * H / W)); const pg = probe.getContext('2d', { willReadFrequently: true });
    const out = [];
    list.forEach((n, i) => {
      try { window.__reel.renderFrame(n); } catch (e) { throw new Error('FILMERR t=' + (n / window.__reel.fps).toFixed(2) + '\n' + (e.stack || e.message)); }
      const x = gap + (i % cols) * (tw + gap), y = gap + Math.floor(i / cols) * (th + lab + gap);
      g.drawImage(src, x, y + lab, tw, th);
      if (S) { const k = tw / W; g.save(); g.setLineDash([6, 5]); g.strokeStyle = 'rgba(255,60,60,0.55)'; g.lineWidth = 1.5; g.strokeRect(x + S.x0 * k, y + lab + S.y0 * k, (S.x1 - S.x0) * k, (S.y1 - S.y0) * k); g.restore(); }
      g.fillStyle = '#e8e8e8'; g.font = '600 19px system-ui, sans-serif'; g.fillText(`${(n / window.__reel.fps).toFixed(2)}s  ·  #${n}`, x + 2, y + 21);
      pg.drawImage(src, 0, 0, probe.width, probe.height);
      const d = pg.getImageData(0, 0, probe.width, probe.height).data; let s = 0, s2 = 0, c = 0;
      for (let k = 0; k < d.length; k += 4) { const l = 0.2126 * d[k] + 0.7152 * d[k + 1] + 0.0722 * d[k + 2]; s += l; s2 += l * l; c++; }
      const mean = s / c, sd = Math.sqrt(Math.max(0, s2 / c - mean * mean));
      out.push({ n, t: n / window.__reel.fps, png: src.toDataURL('image/png').slice(22), mean, sd });
    });
    return { sheet: sheet.toDataURL('image/png').slice(22), frames: out };
  }, list).catch((e) => die(e, page0));
  fs.writeFileSync(path.join(qcDir, 'sheet.png'), Buffer.from(res.sheet, 'base64'));
  const warn = [];
  for (const f of res.frames) {
    fs.writeFileSync(path.join(qcDir, `t${f.t.toFixed(2).padStart(6, '0')}s.png`), Buffer.from(f.png, 'base64'));
    if (f.sd < 1.5 && f.n > 0 && f.n < F - 1) warn.push(`frame at ${f.t.toFixed(2)}s is a flat colour (blank?)`);
  }
  let audioLine = 'no score';
  if (!flag('no-audio')) {
    try {
      const a = await page0.evaluate(() => window.__reel.audioWav());
      if (a) {
        fs.writeFileSync(path.join(qcDir, 'audio.wav'), Buffer.from(a.base64, 'base64')); audioLine = `ok, ${a.lufs.toFixed(1)} LUFS (target -14)`;
        if (a.sections && a.sections.length) audioLine += '\nsections (between your S marks, dB RMS): ' + a.sections.map((x) => `${x.name} ${x.t0.toFixed(2)}s ${x.db < -60 ? 'silent' : x.db}`).join(' · ');
        if (a.hits && a.hits.length) audioLine += '\nloudest hits (50 ms): ' + a.hits.map((h) => `${h.t.toFixed(2)} s ${h.db} dB${h.near ? ` (${h.near})` : ''}`).join(' · ');
        if (a.timeline) audioLine += '\nlevels (dB RMS per 0.5 s, from 0 s): ' + a.timeline.filter((_, i) => i % 2 === 0).map((v, i) => (i % 4 === 0 ? `| ${i / 2}s ` : '') + Math.max(-60, v)).join(' ');
      }
    } catch (e) { errors.push((await explain(e, page0)).replace(/^✗ Film error/, 'Score error')); audioLine = 'FAILED'; }
  }
  await browser.close();
  console.log(`QC  ${W}x${H} · ${fps} fps · ${meta.seconds.toFixed(2)} s · ${res.frames.length} frames checked in ${((Date.now() - T0) / 1000).toFixed(1)} s`);
  console.log(`sheet: ${path.join(qcDir, 'sheet.png')}`);
  console.log(`frames: ${qcDir}/t*.png`);
  console.log(`audio: ${audioLine}`);
  warn.forEach((w) => console.log('⚠ ' + w));
  if (errors.length) { console.log('✗ errors:\n  ' + [...new Set(errors)].join('\n  ')); process.exit(1); }
  process.exit(0);
}

// ------------------------------------------------------------------ full render
const N = Math.max(1, +opt('workers', Math.min(4, Math.max(1, os.cpus().length - 2))));
const pages = [page0, ...(await Promise.all(Array.from({ length: N - 1 }, openPage)))];
const tmp = path.join(proj, '.motion-director'); fs.mkdirSync(tmp, { recursive: true });
let wav = null;
if (!flag('no-audio')) {
  const a = await page0.evaluate(() => window.__reel.audioWav()).catch((e) => die(e, page0));
  if (a) { wav = path.join(tmp, 'audio.wav'); fs.writeFileSync(wav, Buffer.from(a.base64, 'base64')); console.log(`audio: ${a.lufs.toFixed(1)} LUFS`); }
}
const out = path.resolve(opt('out', path.join(proj, path.basename(proj) + '.mp4')));
const ff = spawn(ffmpeg, [
  '-y', '-hide_banner', '-loglevel', 'error',
  '-f', 'image2pipe', '-framerate', String(fps), '-c:v', 'png', '-i', 'pipe:0',
  ...(wav ? ['-i', wav] : []),
  '-map', '0:v', ...(wav ? ['-map', '1:a'] : []),
  '-c:v', 'libx264', '-profile:v', 'high', '-preset', 'medium', '-crf', String(opt('crf', 17)), '-pix_fmt', 'yuv420p',
  '-color_primaries', 'bt709', '-color_trc', 'bt709', '-colorspace', 'bt709', '-r', String(fps),
  ...(wav ? ['-c:a', 'aac', '-b:a', '256k', '-ar', '48000', '-shortest'] : ['-an']),
  '-frames:v', String(F), '-movflags', '+faststart', out,
], { stdio: ['pipe', 'inherit', 'inherit'] });
const ffDone = once(ff, 'close');
onDie.push(() => { ff.stdin.destroy(); ff.kill('SIGKILL'); fs.rmSync(out, { force: true }); });

const ready = new Map(); let next = 0, writing = Promise.resolve(), lastPct = -1;
const pump = () => { writing = writing.then(async () => {
  while (ready.has(next)) {
    const buf = ready.get(next); ready.delete(next); next++;
    if (!ff.stdin.write(buf)) await once(ff.stdin, 'drain');
    const pct = Math.floor(next / F * 10);
    if (pct !== lastPct) { lastPct = pct; const el = (Date.now() - T0) / 1000; console.log(`frame ${next}/${F}  ${(next / el).toFixed(1)} fps`); }
  }
}); };
async function worker(page, k) {
  for (let n = k; n < F; n += N) {
    while (n - next > 40) await new Promise((r) => setTimeout(r, 4));      // don't run too far ahead of the encoder
    const b64 = await page.evaluate((n) => {
      try { window.__reel.renderFrame(n); } catch (e) { throw new Error('FILMERR t=' + (n / window.__reel.fps).toFixed(2) + '\n' + (e.stack || e.message)); }
      return document.getElementById('c').toDataURL('image/png').slice(22);
    }, n).catch((e) => die(e, page));
    ready.set(n, Buffer.from(b64, 'base64')); pump();
  }
}
await Promise.all(pages.map((p, k) => worker(p, k)));
await writing; ff.stdin.end();
const [code] = await ffDone;
await browser.close();
fs.rmSync(tmp, { recursive: true, force: true });
if (errors.length) console.log('⚠ page errors during render:\n  ' + [...new Set(errors)].join('\n  '));
if (code !== 0) { console.error('✗ ffmpeg failed'); process.exit(1); }
const mb = (fs.statSync(out).size / 1e6).toFixed(1), secs = ((Date.now() - T0) / 1000).toFixed(1);
console.log(`✓ ${out}\n  ${W}x${H} · ${fps} fps · ${meta.seconds.toFixed(2)} s · ${mb} MB · rendered in ${secs} s with ${N} workers`);
if (flag('open')) spawn(process.platform === 'darwin' ? 'open' : process.platform === 'win32' ? 'explorer' : 'xdg-open', [out], { stdio: 'ignore', detached: true }).unref();
