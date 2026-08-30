import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

import Navbar from '@/components/landing/Navbar'
import { ThemeProvider } from '@/components/theme'
import LandingPage from '@/pages/public/LandingPage'

vi.mock('@/components/seo/SEO', () => ({ default: () => null }))

function renderNavbar() {
  return render(
    <ThemeProvider defaultTheme="light">
      <MemoryRouter>
        <Navbar />
      </MemoryRouter>
    </ThemeProvider>
  )
}

describe('enterprise landing navigation', () => {
  it('opens the Resources menu from the keyboard and exposes every destination', async () => {
    const user = userEvent.setup()
    renderNavbar()

    const resources = screen.getByRole('button', { name: 'Resources' })
    resources.focus()
    await user.keyboard('{Enter}')

    expect(await screen.findByRole('menuitem', { name: 'Guides' })).toHaveAttribute(
      'href',
      '/guides/what-to-wear-today'
    )
    expect(screen.getByRole('menuitem', { name: 'Blog' })).toHaveAttribute('href', '/blog')
    expect(screen.getByRole('menuitem', { name: 'FAQ' })).toHaveAttribute('href', '/faq')
    expect(screen.getByRole('menuitem', { name: 'About' })).toHaveAttribute('href', '/about')
  })

  it('keeps primary and resource links in the mobile menu', async () => {
    const user = userEvent.setup()
    renderNavbar()

    await user.click(screen.getByRole('button', { name: 'Open menu' }))
    const dialog = screen.getByRole('dialog')
    expect(within(dialog).getByRole('link', { name: 'Features' })).toHaveAttribute(
      'href',
      '/features'
    )
    expect(within(dialog).getByRole('link', { name: 'Live demo' })).toHaveAttribute(
      'href',
      '/#demo'
    )
    expect(within(dialog).getByRole('link', { name: 'Guides' })).toBeInTheDocument()
    expect(within(dialog).getByRole('link', { name: 'About' })).toBeInTheDocument()
  })
})

describe('enterprise landing structure', () => {
  it('retains required anchors, one H1, and the flat-lay LCP hint', () => {
    const { container } = render(
      <MemoryRouter>
        <LandingPage />
      </MemoryRouter>
    )

    expect(container.querySelectorAll('h1')).toHaveLength(1)
    for (const id of [
      'demo',
      'features',
      'also-in-app',
      'how-it-works',
      'step-photograph',
      'step-catalog',
      'step-wear',
      'photoshoot-showcase',
      'who-its-for',
      'guides',
      'pricing',
      'faq',
    ]) {
      expect(document.getElementById(id), `missing #${id}`).not.toBeNull()
    }

    const lcpImage = screen.getByAltText(
      'Workday outfit flat lay with a white shirt, navy trousers, brown shoes, and a watch'
    )
    expect(lcpImage).toHaveAttribute('src', '/landing/flatlay-640.webp')
    expect(lcpImage).toHaveAttribute('fetchpriority', 'high')
    expect(lcpImage).toHaveAttribute(
      'sizes',
      '(min-width: 1024px) 42vw, calc(100vw - 32px)'
    )
  })
})
