import { fireEvent, render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { useState } from 'react'
import { describe, expect, it } from 'vitest'
import { Shirt } from 'lucide-react'

import AppLayout from '@/components/layout/AppLayout'
import { ThemeProvider } from '@/components/theme/ThemeProvider'
import { StatCard } from '@/components/dashboard/StatCard'
import {
  BottomSheet,
  BottomSheetContent,
  BottomSheetDescription,
  BottomSheetTitle,
} from '@/components/ui/bottom-sheet'
import { Button } from '@/components/ui/button'
import { ItemImage } from '@/components/ui/item-image'
import { LocationInput } from '@/components/settings/LocationInput'
import { ActionStatusLabel } from '@/components/ui/action-status'
import { ScrollableTab, ScrollableTabs } from '@/components/ui/scrollable-tabs'
import { FilterPanel } from '@/components/wardrobe/FilterPanel'
import type { Item } from '@/types'

describe('shared UI accessibility and responsive contracts', () => {
  it('maps the wardrobe mobile sheet large height to a valid viewport size', () => {
    render(
      <BottomSheet open>
        <BottomSheetContent height="large">
          <BottomSheetTitle>Filters & Sort</BottomSheetTitle>
          <BottomSheetDescription>Choose how to browse your wardrobe.</BottomSheetDescription>
        </BottomSheetContent>
      </BottomSheet>
    )

    const dialog = screen.getByRole('dialog')
    expect(dialog).toHaveClass('h-[85vh]')
    expect(dialog.style.height).toBe('')
  })

  it('keeps the real wardrobe filter consumer on the named mobile sheet size', async () => {
    render(
      <FilterPanel
        filters={{
          search: '',
          category: 'all',
          color: '',
          occasion: '',
          condition: 'all',
          isFavorite: false,
        }}
        sort={{ sortBy: 'date_added', sortOrder: 'desc', isGridView: true }}
        onFilterChange={() => undefined}
        onSortChange={() => undefined}
        onResetFilters={() => undefined}
      />
    )

    await userEvent.click(screen.getByRole('button', { name: 'Filters and sort' }))
    expect(screen.getByRole('dialog')).toHaveClass('h-[85vh]')
  })

  it('supports roving keyboard navigation for horizontally scrollable tabs', async () => {
    function TabsHarness() {
      const [active, setActive] = useState('first')
      return (
        <ScrollableTabs aria-label="Example tabs" showFade={false}>
          {['first', 'second', 'third'].map((tab) => (
            <ScrollableTab
              key={tab}
              isActive={active === tab}
              onClick={() => setActive(tab)}
            >
              {tab}
            </ScrollableTab>
          ))}
        </ScrollableTabs>
      )
    }

    render(<TabsHarness />)
    const first = screen.getByRole('tab', { name: 'first' })
    const second = screen.getByRole('tab', { name: 'second' })

    first.focus()
    fireEvent.keyDown(first, { key: 'ArrowRight' })

    expect(second).toHaveFocus()
    expect(second).toHaveAttribute('aria-selected', 'true')
    expect(first).toHaveAttribute('aria-selected', 'false')
  })

  it('exposes a real label, autofill name, and live error for location input', () => {
    render(
      <LocationInput
        value=""
        onChange={() => undefined}
        error="Location could not be detected"
      />
    )

    const input = screen.getByRole('textbox', { name: 'Location' })
    expect(input).toHaveAttribute('name', 'location')
    expect(input).toHaveAttribute('autocomplete', 'address-level2')
    expect(input).toHaveAttribute('aria-invalid', 'true')
    expect(screen.getByRole('alert')).toHaveTextContent('Location could not be detected')
  })

  it('keeps shared actions at the documented 44px target', () => {
    render(<Button size="icon" aria-label="Open menu"><Shirt aria-hidden="true" /></Button>)
    expect(screen.getByRole('button', { name: 'Open menu' })).toHaveClass('h-11', 'w-11', 'min-w-[44px]')
  })

  it('provides labeled landmarks and a skip link in the authenticated shell', () => {
    render(
      <MemoryRouter>
        <ThemeProvider defaultTheme="light">
          <AppLayout />
        </ThemeProvider>
      </MemoryRouter>
    )

    expect(screen.getByRole('link', { name: 'Skip to main content' })).toHaveAttribute(
      'href',
      '#main-content'
    )
    expect(screen.getByRole('main')).toHaveAttribute('id', 'main-content')
    expect(screen.getByRole('navigation', { name: 'Primary navigation' })).toBeInTheDocument()
  })

  it('announces async status while remaining a visible static state under reduced motion', () => {
    render(
      <ActionStatusLabel
        loading
        phaseText="Uploading photo…"
        elapsedSeconds={0}
        idleText="Upload photo"
      />
    )

    expect(screen.getByRole('status')).toHaveTextContent('Uploading photo…')
    expect(screen.getByRole('status')).not.toHaveClass('opacity-0')
  })

  it('reserves image dimensions and lazy loading in the shared item image', () => {
    const item = {
      id: 'item-1',
      name: 'Linen shirt',
      images: [{ image_url: '/linen.webp', thumbnail_url: '/linen-thumb.webp', is_primary: true }],
    } as unknown as Item

    render(<ItemImage item={item} size="md" />)

    const image = screen.getByAltText('Linen shirt')
    expect(image).toHaveAttribute('width', '64')
    expect(image).toHaveAttribute('height', '64')
    expect(image).toHaveAttribute('loading', 'lazy')
  })

  it('uses semantic foreground tokens instead of generic gradient contrast', () => {
    const { container } = render(
      <StatCard name="Items" value={12} icon={Shirt} gradient="primary" />
    )

    expect(container.querySelector('.bg-primary.text-primary-foreground')).not.toBeNull()
    expect(container.querySelector('[class*="bg-gradient"]')).toBeNull()
    expect(container.querySelector('svg')).toHaveAttribute('aria-hidden', 'true')
  })
})
