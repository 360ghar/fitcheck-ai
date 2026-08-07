/// <reference types="vitest/config" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
// Config is a function so the SSR build (scripts/prerender-html.mjs runs
// `vite build --ssr src/entry-prerender.tsx`) can opt out of manualChunks:
// react and friends are external in an SSR build, and Rollup errors if an
// external module is named in a manual chunk.
export default defineConfig(({ isSsrBuild }) => ({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
      "@/components": path.resolve(__dirname, "./src/components"),
      "@/lib": path.resolve(__dirname, "./src/lib"),
      "@/hooks": path.resolve(__dirname, "./src/hooks"),
      "@/stores": path.resolve(__dirname, "./src/stores"),
      "@/types": path.resolve(__dirname, "./src/types"),
      "@/pages": path.resolve(__dirname, "./src/pages"),
      "@/api": path.resolve(__dirname, "./src/api"),
      "@/agents": path.resolve(__dirname, "./src/agents"),
      "@/assets": path.resolve(__dirname, "./src/assets"),
    },
  },
  server: {
    host: '0.0.0.0',
    port: 3000,
    watch: {
      usePolling: true,
    },
    proxy: {
      // Proxy API requests to backend
      '/api': {
        target: process.env.VITE_API_URL || 'http://localhost:8000',
        changeOrigin: true,
      },
    },
  },
  build: {
    target: 'esnext',
    minify: 'esbuild',
    // Emitted so scripts/prerender-html.mjs can resolve hashed chunk names and
    // inject per-route <link rel="modulepreload"> (e.g. the blog chunk graph
    // on /blog) instead of guessing filenames.
    manifest: true,
    // Public sourcemaps served the whole frontend source to anyone who asked:
    // dist/assets/index-*.js.map was HTTP 200 in production, 9.4 MB across 92
    // files. 'hidden' would not fix it — the maps still land in dist/ and get
    // published, just without the sourceMappingURL comment. There is no
    // upload step in `npm run build`, so emit nothing. If Sentry map upload is
    // added later, switch to 'hidden' AND delete dist/**/*.map after upload.
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: isSsrBuild
          ? undefined
          : {
              // Separate vendor chunks for better caching.
              'react-vendor': ['react', 'react-dom', 'react-router-dom'],
              'ui-vendor': ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu', '@radix-ui/react-select'],
              'query-vendor': ['@tanstack/react-query', 'axios'],
              'state-vendor': ['zustand'],
            },
      },
    },
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'react-router-dom', '@tanstack/react-query', 'zustand'],
  },
  ssr: {
    // Vite externalizes deps in an SSR build by default, which breaks on
    // CJS-only packages under Node ESM: `import { HelmetProvider } from
    // 'react-helmet-async'` throws "Named export not found". Bundling
    // everything sidesteps CJS/ESM interop entirely, and the prerender output
    // never ships to a browser so its size is free.
    //
    // Gated on isSsrBuild because Vitest reads this same config, and an
    // unconditional `noExternal: true` inlines the test runner's own modules —
    // every test file then collects as "No test suite found".
    noExternal: isSsrBuild ? true : undefined,
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    css: false,
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
  },
}))
