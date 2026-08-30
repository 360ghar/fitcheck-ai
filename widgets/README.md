# FitCheck ChatGPT widgets

Single-file HTML bundles for the ChatGPT Apps-SDK mount (`/mcp/chatgpt`).
Each widget is an iframe rendered inside ChatGPT; data comes from the tool's
`structuredContent` via `window.openai`, follow-ups run through
`window.openai.callTool` (no direct API calls, no CORS surface).

## Build

```bash
npm install
npm run build   # → backend/app/mcp/static/<name>.html
```

The backend exposes each bundle as a `ui://fitcheck/<name>.html` MCP resource
(`app/mcp/widgets.py`); tools reference them via
`_meta["openai/outputTemplate"]` (`app/mcp/curated.py`).

## Adding a widget

1. Add `<name>.html` + `src/<name>.tsx` and register the input in `vite.config.ts`.
2. `npm run build`.
3. Point a curated tool's `widget` at `<name>.html`.
