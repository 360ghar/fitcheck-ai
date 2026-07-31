import { act, fireEvent, render, renderHook, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

import { CalendarView } from '@/components/calendar/CalendarView'
import { ItemImage } from '@/components/ui/item-image'
import { ItemCard } from '@/components/wardrobe/ItemCard'
import { useItemEditor } from '@/components/wardrobe/useItemEditor'
import { OutfitCard } from '@/components/outfits/OutfitCard'
import { OutfitMetaBar } from '@/components/outfits/create/OutfitMetaBar'
import Pricing from '@/components/landing/Pricing'
import { SearchBar } from '@/components/ui/search-bar'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import type { Item, Outfit } from '@/types'

const item = (id: string, name = id) => ({
  id,
  name,
  category: 'tops',
  condition: 'clean',
  is_favorite: false,
  images: [],
}) as unknown as Item

const outfit = {
  id: 'outfit-1',
  name: 'Weekend look',
  item_ids: [],
  images: [],
  is_favorite: false,
} as unknown as Outfit

describe('PR regression guards', () => {
  it('does not let an old editor save close a newly selected item', async () => {
    let resolveSave!: () => void
    const pendingSave = new Promise<void>((resolve) => {
      resolveSave = resolve
    })
    const onSave = vi.fn(() => pendingSave)
    const { result, rerender } = renderHook(
      ({ selected }) => useItemEditor(selected, onSave),
      { initialProps: { selected: item('first', 'First item') } }
    )

    act(() => result.current.begin())
    let saveTask!: Promise<void>
    act(() => {
      saveTask = result.current.save()
    })

    rerender({ selected: item('second', 'Second item') })
    await waitFor(() => expect(result.current.isEditing).toBe(false))
    act(() => result.current.begin())

    await act(async () => {
      resolveSave()
      await saveTask
    })

    expect(result.current.isEditing).toBe(true)
    expect(result.current.form.name).toBe('Second item')
    expect(onSave).toHaveBeenCalledWith(expect.objectContaining({ id: 'first' }))
  })

  it('keeps favorite controls visible in narrow list rows', () => {
    const { rerender } = render(
      <ItemCard item={item('item-1', 'Linen shirt')} variant="list" />
    )
    expect(screen.getByRole('button', { name: 'Add to favorites' })).toHaveClass(
      'row-cq-favorite'
    )

    rerender(<OutfitCard outfit={outfit} variant="list" />)
    expect(screen.getByRole('button', { name: 'Add to favorites' })).toHaveClass(
      'row-cq-favorite'
    )
  })

  it('recovers from an image error when the selected image URL changes', async () => {
    const first = {
      ...item('item-1', 'First shirt'),
      images: [{ image_url: '/old.webp', thumbnail_url: '/old.webp', is_primary: true }],
    } as unknown as Item
    const second = {
      ...item('item-2', 'Second shirt'),
      images: [{ image_url: '/new.webp', thumbnail_url: '/new.webp', is_primary: true }],
    } as unknown as Item
    const { container, rerender } = render(<ItemImage item={first} size="md" />)

    fireEvent.error(screen.getByAltText('First shirt'))
    const naturalWidth = Object.getOwnPropertyDescriptor(
      HTMLImageElement.prototype,
      'naturalWidth'
    )
    const complete = Object.getOwnPropertyDescriptor(HTMLImageElement.prototype, 'complete')
    Object.defineProperty(HTMLImageElement.prototype, 'naturalWidth', {
      configurable: true,
      get() {
        return this.src.includes('new.webp') ? 640 : 0
      },
    })
    Object.defineProperty(HTMLImageElement.prototype, 'complete', {
      configurable: true,
      get: () => true,
    })

    try {
      rerender(<ItemImage item={second} size="md" />)
      await waitFor(() => {
        expect(screen.getByAltText('Second shirt')).toBeInTheDocument()
        expect(container.querySelector('.animate-pulse')).toBeNull()
      })
    } finally {
      if (naturalWidth) Object.defineProperty(HTMLImageElement.prototype, 'naturalWidth', naturalWidth)
      if (complete) Object.defineProperty(HTMLImageElement.prototype, 'complete', complete)
    }
  })

  it('keeps comma-separated tags raw until blur', async () => {
    const user = userEvent.setup()
    const onTagsChange = vi.fn()
    render(
      <OutfitMetaBar
        name="Weekend look"
        onNameChange={vi.fn()}
        onStyleChange={vi.fn()}
        onSeasonChange={vi.fn()}
        occasion="casual"
        onOccasionChange={vi.fn()}
        tags={['summer']}
        onTagsChange={onTagsChange}
        description=""
        onDescriptionChange={vi.fn()}
      />
    )

    const input = screen.getByRole('textbox', { name: 'Tags, comma separated' })
    await user.clear(input)
    await user.type(input, 'summer, office,  ')
    expect(input).toHaveValue('summer, office,  ')
    expect(onTagsChange).not.toHaveBeenCalled()

    fireEvent.blur(input)
    expect(onTagsChange).toHaveBeenCalledWith(['summer', 'office'])
  })

  it('preserves pricing tier and billing cadence in registration links', async () => {
    const user = userEvent.setup()
    render(
      <MemoryRouter>
        <Pricing />
      </MemoryRouter>
    )

    expect(screen.getByRole('link', { name: 'Get Plus' })).toHaveAttribute(
      'href',
      '/auth/register?plan_type=plus_monthly'
    )
    await user.click(screen.getByRole('switch'))
    expect(screen.getByRole('link', { name: 'Upgrade to Pro' })).toHaveAttribute(
      'href',
      '/auth/register?plan_type=pro_yearly'
    )
  })

  it('renders the calendar event marker and accessible event type', () => {
    const event = {
      id: 'event-1',
      title: 'Team dinner',
      start_time: new Date().toISOString(),
      end_time: new Date(Date.now() + 60 * 60 * 1000).toISOString(),
      event_type: 'formal',
      is_all_day: false,
    }
    render(
      <CalendarView
        events={[event]}
        outfits={[]}
        initialViewMode="week"
      />
    )

    const eventButton = screen.getByTitle('Team dinner')
    expect(eventButton).toHaveTextContent('Event type: formal')
    expect(eventButton.querySelector('.bg-event-formal')).not.toBeNull()
  })

  it('keeps SearchBar and ZoomableImage accessibility invariants', () => {
    const { rerender } = render(
      <SearchBar aria-label="Search wardrobe" type="text" />
    )
    expect(screen.getByRole('searchbox')).toHaveAttribute('type', 'search')

    rerender(
      <ZoomableImage
        src="/thumbnail.webp"
        alt="Linen shirt"
        role="presentation"
        tabIndex={-1}
        decoding="sync"
        aria-label="Caller override"
      />
    )
    const image = screen.getByRole('button', {
      name: 'Open image preview: Linen shirt',
    })
    expect(image).toHaveAttribute('tabindex', '0')
    expect(image).toHaveAttribute('aria-label', 'Open image preview: Linen shirt')
    expect(image).toHaveAttribute('decoding', 'async')
    expect(image).toHaveClass('focus-visible:ring-2')
  })
})
