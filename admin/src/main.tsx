import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

import App from '@/App'
import { env } from '@/config/env'

import '@/shared/i18n'
import '@/index.css'

// Sentry is opt-in via VITE_SENTRY_DSN; beforeSend scrubs request bodies
// (they can carry PII) before anything leaves the browser.
async function initSentry(): Promise<void> {
  if (!env.VITE_SENTRY_DSN) return
  const Sentry = await import('@sentry/react')
  Sentry.init({
    dsn: env.VITE_SENTRY_DSN,
    environment: import.meta.env.MODE,
    beforeSend(event) {
      if (event.request) {
        delete event.request.data
      }
      return event
    },
  })
}

const rootElement = document.getElementById('root')
if (!rootElement) {
  throw new Error('#root element not found — index.html is missing the app mount point')
}

void initSentry().then(() => {
  createRoot(rootElement).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
})
