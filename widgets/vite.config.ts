import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { viteSingleFile } from "vite-plugin-singlefile";
import { resolve } from "path";
import { readdirSync } from "fs";

// Each widget builds to ONE self-contained .html (JS+CSS inlined) in
// backend/app/mcp/static/ — the MCP widget resources serve exactly these
// files, and ChatGPT renders them in an iframe (one request per widget).
//
// vite-plugin-singlefile requires a single entry per build, so `npm run
// build` loops over every root <name>.html (see package.json) and sets
// WIDGET=<name> for each pass.
const widget = process.env.WIDGET;
if (!widget) {
  throw new Error("WIDGET env var required (set by `npm run build`)");
}

export default defineConfig({
  plugins: [react(), viteSingleFile()],
  build: {
    outDir: resolve(__dirname, "../backend/app/mcp/static"),
    emptyOutDir: widget === listWidgets()[0],
    rollupOptions: {
      input: resolve(__dirname, `${widget}.html`),
    },
  },
});

function listWidgets(): string[] {
  return readdirSync(__dirname)
    .filter((file) => file.endsWith(".html"))
    .map((file) => file.replace(/\.html$/, ""));
}
