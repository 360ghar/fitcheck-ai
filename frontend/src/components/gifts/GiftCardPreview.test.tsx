import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { GiftCardPreview } from './GiftCardPreview'

describe('GiftCardPreview', () => {
  it('shows truthful value and neutral no-expiry language', () => {
    render(
      <GiftCardPreview
        fromName="Alex Morgan"
        toName="Taylor Reed"
        message="For every outfit still waiting to happen."
        duration={12}
        retailValueCents={20_000}
      />,
    )

    expect(screen.getByRole('article', { name: 'FitCheck Pro gift for Taylor Reed' })).toBeVisible()
    expect(screen.getByText('$200 retail value')).toBeVisible()
    expect(screen.getByText('Gift voucher · no expiry before claim')).toBeVisible()
    expect(screen.queryByText(/purchased/i)).not.toBeInTheDocument()
  })

  it('shows the claim deadline for a promotional gift', () => {
    render(
      <GiftCardPreview
        fromName="Alex Morgan"
        toName="Taylor Reed"
        duration={1}
        retailValueCents={2_000}
        expiresAt="2030-01-15T20:00:00Z"
      />,
    )

    // toLocaleDateString output order varies by runtime locale ("Jan 15, 2030" / "15 Jan 2030").
    expect(screen.getByText(/Promotional gift · claim by (Jan 15, 2030|15 Jan 2030)/i)).toBeVisible()
  })

  it('keeps a no-occasion card free of a default greeting or message', () => {
    render(
      <GiftCardPreview
        fromName="Alex Morgan"
        toName="Taylor Reed"
        duration={1}
        retailValueCents={2_000}
      />,
    )

    expect(screen.queryByText(/private invitation to make getting dressed/i)).not.toBeInTheDocument()
    expect(screen.queryByText('Happy Birthday')).not.toBeInTheDocument()
  })

  it('uses the selected occasion greeting', () => {
    render(
      <GiftCardPreview
        fromName="Alex Morgan"
        toName="Taylor Reed"
        occasion="other"
        occasionGreeting="Happy Diwali!"
        duration={3}
        retailValueCents={6_000}
      />,
    )

    expect(screen.getByText('Happy Diwali!')).toBeVisible()
  })

  it('pins the exact fixed birthday greeting (kept in sync with backend artwork)', () => {
    render(
      <GiftCardPreview
        fromName="Alex Morgan"
        toName="Taylor Reed"
        occasion="birthday"
        duration={3}
        retailValueCents={6_000}
      />,
    )

    expect(screen.getByText('Happy Birthday')).toBeVisible()
  })
})
