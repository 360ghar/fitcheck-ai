import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import {
  GiftPriorityCard,
  resolveGiftPriority,
} from './GiftPriorityCard'
import type { GiftAllowance, GiftDashboardSummary, GiftVoucher } from '@/api/gifts'

const allowance: GiftAllowance = {
  duration_months: 1,
  granted_count: 3,
  used_count: 2,
  remaining_count: 1,
}

const incoming: GiftVoucher = {
  id: 'gift-1',
  public_id: 'public-1',
  duration_months: 3,
  retail_value_cents: 6000,
  currency: 'USD',
  from_name: 'Alex',
  to_name: 'Taylor',
  status: 'issued',
  created_at: '2026-08-30T00:00:00Z',
  artwork_version: 1,
  og_image_url: '/gift.png',
}

describe('gift dashboard priority', () => {
  it('shows incoming gifts before free invitations', () => {
    const priority = resolveGiftPriority({ allowances: [allowance], incoming: [incoming] })

    expect(priority?.incoming?.id).toBe('gift-1')
    expect(priority?.allowance).toBeUndefined()
  })

  it('falls back to the first available free invitation', () => {
    const summary: GiftDashboardSummary = { allowances: [allowance], incoming: [] }

    expect(resolveGiftPriority(summary)).toEqual({ allowance })
    expect(resolveGiftPriority(null)).toBeNull()
  })

  it('deep-links to the selected incoming gift', () => {
    render(
      <MemoryRouter>
        <GiftPriorityCard incoming={incoming} incomingCount={1} />
      </MemoryRouter>,
    )

    expect(screen.getByRole('link', { name: /a gift is waiting/i })).toHaveAttribute(
      'href',
      '/gifts?claim=gift-1',
    )
  })

  it('includes an incoming occasion greeting', () => {
    render(
      <MemoryRouter>
        <GiftPriorityCard
          incoming={{ ...incoming, occasion: 'birthday' }}
          incomingCount={1}
        />
      </MemoryRouter>,
    )

    expect(screen.getByText(/Happy Birthday/)).toBeVisible()
  })
})
