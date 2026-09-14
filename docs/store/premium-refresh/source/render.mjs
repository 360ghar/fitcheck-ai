// Run from the repo root with Node and Playwright available. No UI is redrawn:
// captures come from the opt-in Flutter store export test; this adds editable type.
import fs from 'node:fs/promises';
import path from 'node:path';
import http from 'node:http';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';

const require=createRequire(import.meta.url);
const {chromium}=require('playwright');
const source=path.dirname(fileURLToPath(import.meta.url));
const folder=path.dirname(source);
const repo=path.resolve(folder,'../../..');
const config=JSON.parse(await fs.readFile(path.join(source,'screens.json'),'utf8'));
const types={'.html':'text/html','.json':'application/json','.png':'image/png','.jpg':'image/jpeg','.ttf':'font/ttf'};
const server=http.createServer(async(req,res)=>{
  try {
    const pathname=decodeURIComponent(new URL(req.url,'http://localhost').pathname);
    const filename=path.resolve(repo,`.${pathname}`);
    if(!filename.startsWith(repo+path.sep)) {res.writeHead(403).end();return;}
    const body=await fs.readFile(filename);
    res.writeHead(200,{'Content-Type':types[path.extname(filename)]||'application/octet-stream'}).end(body);
  } catch {res.writeHead(404).end();}
});
await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
const base=`http://127.0.0.1:${server.address().port}/docs/store/premium-refresh/source/poster.html`;
const browser=await chromium.launch({headless:true});
const page=await browser.newPage({deviceScaleFactor:1});
const manifest=[];
try {
  for(const preset of config.presets) {
    await fs.mkdir(path.join(folder,'exports',preset.id),{recursive:true});
    for(const screen of config.screens) {
      await page.setViewportSize({width:preset.width,height:preset.height});
      await page.goto(`${base}?preset=${preset.id}&screen=${screen.id}`);
      await page.waitForFunction(()=>window.artworkReady===true);
      await page.evaluate(()=>{
        const title=document.querySelector('.title');
        if(getComputedStyle(title).display==='none') return;
        const image=document.querySelector('.screen').getBoundingClientRect();
        const subtitle=document.querySelector('.subtitle');
        const heading=title.getBoundingClientRect();
        if(heading.bottom>image.top || title.scrollWidth>title.clientWidth+1) throw Error('Headline does not fit');
        if(getComputedStyle(subtitle).display!=='none') {
          const sub=subtitle.getBoundingClientRect();
          if(heading.bottom>sub.top || sub.bottom>image.top) throw Error('Caption overlaps content');
        }
      });
      const filename=`exports/${preset.id}/${screen.id}.jpg`;
      await page.screenshot({path:path.join(folder,filename),type:'jpeg',quality:96});
      manifest.push({file:filename,width:preset.width,height:preset.height,store:preset.store,device:preset.device,alt:screen.alt});
      process.stdout.write(`${filename}\n`);
    }
  }
  await page.setViewportSize({width:1024,height:500});
  await page.goto(`${base}?preset=feature`);
  await page.waitForFunction(()=>window.artworkReady===true);
  await page.screenshot({path:path.join(folder,'exports/play-store-feature.jpg'),type:'jpeg',quality:96});
  manifest.push({file:'exports/play-store-feature.jpg',width:1024,height:500,store:'Google Play',device:'Feature graphic',alt:'FitCheck AI wardrobe and outfit tools with an ecru shirt and charcoal trousers.'});
  await fs.writeFile(path.join(folder,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
  await fs.mkdir(path.join(folder,'review'),{recursive:true});
  for(const preset of config.presets) {
    await page.setViewportSize({width:1480,height:700});
    await page.goto(base.replace('source/poster.html',`gallery.html?preset=${preset.id}&capture=1`));
    await page.waitForFunction(()=>window.galleryReady===true);
    await page.screenshot({path:path.join(folder,'review',`${preset.id}.jpg`),type:'jpeg',quality:92,fullPage:true});
  }
} finally {
  await browser.close();
  await new Promise(resolve=>server.close(resolve));
}
