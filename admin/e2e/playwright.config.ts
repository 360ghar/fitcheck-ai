import { defineConfig, devices } from '@playwright/test'

/**
 * Playwright e2e (spec §10): 8 critical admin journeys, chromium only,
 * against a production build served by `vite preview` on :4173. No MSW —
 * every `/api/**` call is stubbed with Playwright route interception
 * (e2e/helpers.ts) using the same fixture objects as the unit tests
 * (e2e/fixtures.ts imports from src/test/msw/handlers/*).
 *
 * The config lives under e2e/ so the repo's eslint project-service picks it
 * up via e2e/tsconfig.json; the webServer command therefore prefixes npm
 * with `..` (config dir → admin/).
 */
export default defineConfig({
  testDir: '.',
  // `*.e2e.ts` (not `*.spec.ts`) so vitest's default include — which does
  // not know about Playwright — never tries to collect these files.
  testMatch: /\.e2e\.ts$/,
  // Shared dev server + mutable mock state: keep it serial.
  fullyParallel: false,
  workers: 1,
  timeout: 60_000,
  expect: {
    timeout: 10_000,
  },
  reporter: [
    ['list'],
    // Artifacts live under dist/ so they are gitignored (admin/.gitignore).
    ['html', { outputFolder: '../dist/e2e/playwright-report', open: 'never' }],
  ],
  outputDir: '../dist/e2e/test-results',
  use: {
    baseURL: 'http://localhost:4173',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  webServer: {
    command: 'npm --prefix .. run build && npm --prefix .. run preview -- --port 4173 --strictPort',
    url: 'http://localhost:4173',
    reuseExistingServer: !process.env.CI,
    timeout: 180_000,
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
})
