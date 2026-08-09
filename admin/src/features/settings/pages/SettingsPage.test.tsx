import { screen, within } from '@testing-library/react'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'

import { SettingsPage } from './SettingsPage'

import { useSessionStore } from '@/shared/stores/sessionStore'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

/** Mirrors GET /api/v1/admin/settings (backend deployment_settings). */
const settingsResponse = {
  app_name: 'FitCheck AI',
  version: '1.0.0',
  commit: 'abc1234',
  environment: 'development',
  feature_toggles: { ENABLE_SEARCH: true },
  billing: { stripe: true, apple: false, google: false },
  storage: {
    bucket: 'fitcheck-media',
    serving_mode: 'presign',
    presign_ttl_seconds: 900,
    configured: true,
  },
  limits: {
    free_monthly: { extractions: 5, generations: 10, embeddings: 50 },
    plus_monthly: { extractions: 50, generations: 200, embeddings: 1000 },
    pro_monthly: { extractions: 200, generations: 1000, embeddings: 5000 },
  },
}

function mockSettings(): void {
  server.use(
    http.get('*/api/v1/admin/settings', () => HttpResponse.json(settingsResponse)),
  )
}

describe('SettingsPage', () => {
  beforeEach(() => {
    authedAs(['*'])
    mockSettings()
  })

  it('renders plan limit cards from the backend plan keys (free_monthly/plus_monthly/pro_monthly)', async () => {
    renderWithProviders(<SettingsPage />)

    expect(await screen.findByText('Free')).toBeInTheDocument()
    expect(screen.getByText('Plus monthly')).toBeInTheDocument()
    expect(screen.getByText('Pro monthly')).toBeInTheDocument()

    // Free card renders its real values instead of dashes — regression for
    // the frontend reading `limits.free` while the backend sends
    // `limits.free_monthly`.
    const freeCard = screen.getByText('Free').closest('.rounded-md') as HTMLElement
    expect(within(freeCard).getByText('Extractions')).toBeInTheDocument()
    expect(within(freeCard).getByText('5')).toBeInTheDocument()
    expect(within(freeCard).getByText('10')).toBeInTheDocument()
    expect(within(freeCard).getByText('50')).toBeInTheDocument()
    expect(within(freeCard).queryByText('—')).not.toBeInTheDocument()

    // Other cards map to their own backend keys (not the free values).
    const plusCard = screen.getByText('Plus monthly').closest('.rounded-md') as HTMLElement
    expect(within(plusCard).getByText('50')).toBeInTheDocument()
    expect(within(plusCard).getByText('200')).toBeInTheDocument()
    const proCard = screen.getByText('Pro monthly').closest('.rounded-md') as HTMLElement
    expect(within(proCard).getByText('200')).toBeInTheDocument()
    expect(within(proCard).getByText('5,000')).toBeInTheDocument()
  })
})
