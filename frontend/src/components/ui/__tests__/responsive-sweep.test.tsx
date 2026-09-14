import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { Shirt } from 'lucide-react'
import { describe, expect, it, vi } from 'vitest'

import DemoSection from '@/components/landing/DemoSection'
import AppLayout from '@/components/layout/AppLayout'
import { ThemeProvider } from '@/components/theme/ThemeProvider'
import Hero from '@/components/landing/Hero'
import PhotoshootShowcase from '@/components/landing/PhotoshootShowcase'
import TrustBar from '@/components/landing/TrustBar'
import { FeaturePageTemplate } from '@/components/landing/FeaturePageTemplate'
import BottomNav from '@/components/navigation/BottomNav'
import { WizardSteps } from '@/components/ui/wizard-steps'
import {
  Dialog,
  DialogContent,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Sheet,
  SheetContent,
  SheetTitle,
} from '@/components/ui/sheet'
import { Slider } from '@/components/ui/slider'
import { Textarea } from '@/components/ui/textarea'
import { ToastProvider, ToastViewport } from '@/components/ui/toast'
import { ExtractedItemsGrid } from '@/components/wardrobe/ExtractedItemsGrid'
import { ItemCard } from '@/components/wardrobe/ItemCard'
import {
  BottomSheet,
  BottomSheetContent,
  BottomSheetTitle,
} from '@/components/ui/bottom-sheet'
import type { DetectedItem, Item } from '@/types'
import BlogPostPage from '@/pages/blog/BlogPostPage'

// Radix popper positions the open dropdown via ResizeObserver, which jsdom
// does not implement. Stub it before any component renders.
if (typeof globalThis.ResizeObserver === 'undefined') {
  class ResizeObserverStub {
    observe(): void {}
    unobserve(): void {}
    disconnect(): void {}
  }
  Object.defineProperty(globalThis, 'ResizeObserver', {
    value: ResizeObserverStub,
    configurable: true,
    writable: true,
  })
}

const { useBlogPost, useBlogPosts } = vi.hoisted(() => ({
  useBlogPost: vi.fn(),
  useBlogPosts: vi.fn(() => ({ data: undefined })),
}))

vi.mock('@/hooks/useBlog', () => ({ useBlogPost, useBlogPosts }))
vi.mock('@/components/landing/AnimatedSection', () => ({
  AnimatedSection: ({ children }: { children: React.ReactNode }) => <>{children}</>,
}))
vi.mock('@/components/seo/SEO', () => ({ default: () => null }))
vi.mock('@/components/seo/JsonLd', () => ({
  BreadcrumbJsonLd: () => null,
  buildHowToSchema: () => ({}),
  buildArticleSchema: () => ({}),
}))

// Grid (default-variant) card fixture for the mobile-chrome compaction locks.
const sweepCardItem = {
  id: 'i1',
  user_id: 'u1',
  name: 'Black Tee',
  category: 'tops',
  colors: ['Black'],
  materials: [],
  seasonal_tags: [],
  occasion_tags: [],
  tags: [],
  condition: 'clean',
  is_favorite: false,
  usage_times_worn: 0,
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-01T00:00:00Z',
  images: [{ image_url: 'blob:full', thumbnail_url: 'blob:thumb', is_primary: true }],
} as unknown as Item

describe('responsive sweep regression guards', () => {
  it('keeps the landing hero on a minmax(0, 1fr) track on narrow screens', () => {
    const { container } = render(
      <MemoryRouter>
        <Hero />
      </MemoryRouter>
    )
    const heroGrid = container.querySelector('section > div > .grid')
    expect(heroGrid).toHaveClass('grid-cols-1')
    expect(heroGrid?.children[0]).toHaveClass('min-w-0')
    expect(heroGrid?.children[1]).toHaveClass('min-w-0')
  })

  it('stacks the trust facts before the two- and four-column layouts', () => {
    const { container } = render(
      <MemoryRouter>
        <TrustBar />
      </MemoryRouter>
    )
    const list = container.querySelector('ul')
    expect(list).toHaveClass('grid-cols-1')
    expect(list).toHaveClass('sm:grid-cols-2')
    expect(list).toHaveClass('lg:grid-cols-4')
    expect(screen.getByRole('link', { name: /Private by default/ })).toHaveAttribute(
      'href',
      '/privacy'
    )
    expect(screen.getByRole('link', { name: /No-card trial/ })).toHaveAttribute(
      'href',
      '#faq'
    )
  })

  it('shows example photoshoot results without a before-and-after claim', () => {
    render(
      <MemoryRouter>
        <PhotoshootShowcase />
      </MemoryRouter>
    )
    const section = document.getElementById('photoshoot-showcase')
    expect(section?.querySelectorAll('figure')).toHaveLength(2)
    expect(section?.querySelector('figure img')).toHaveClass('aspect-[4/5]')
    // Both figures are labeled examples; neither may claim a before/after.
    for (const figure of section?.querySelectorAll('figure') ?? []) {
      expect(figure.textContent).toMatch(/example result/i)
    }
    expect(section?.textContent).not.toMatch(/before(?!\s*(\/after|-and-after))/i)
  })

  it('keeps all three demos mounted in a local mobile snap rail', () => {
    const { container } = render(<DemoSection />)
    const rail = container.querySelector('[data-testid="demo-rail"]')
    expect(rail).toHaveClass('snap-x')
    expect(rail).toHaveClass('overflow-x-auto')
    expect(rail).toHaveClass('lg:grid-cols-3')
    expect(rail?.parentElement).toHaveClass('[contain:paint]')
    expect(rail?.children).toHaveLength(3)
  })

  it('pads the feature-page trust strip on mobile', () => {
    render(
      <MemoryRouter>
        <FeaturePageTemplate
          title="AI Wardrobe Extraction"
          description="desc"
          canonicalPath="/features/ai-wardrobe-extraction"
          keywords="k"
          eyebrow="eyebrow"
          heroImage="/hero.webp"
          heroImageAlt="hero"
          preparationTitle="Prep"
          preparation={['a']}
          features={[{ icon: Shirt, title: 'f', description: 'd' }]}
          steps={[{ title: 's', description: 'd' }]}
          contextTitle="ctx"
          contextDescription="d"
          contextItems={['i']}
          relatedFeatures={[]}
        />
      </MemoryRouter>
    )
    // The trust strip is the only section whose grid is a hairline (gap-px)
    // composite; its section wrapper must carry the page padding ladder.
    const strip = document.querySelector('section .gap-px')?.closest('section')
    expect(strip).toHaveClass('px-4')
    expect(strip).toHaveClass('sm:px-6')
    expect(strip).toHaveClass('lg:px-8')
  })

  it('keeps a readable blog hero aspect on phones', () => {
    useBlogPost.mockReturnValue({
      data: {
        slug: 'post',
        title: 'A post',
        excerpt: 'e',
        author: 'A',
        date: '2026-01-01',
        read_time: '4 min',
        category: 'Guides',
        emoji: '👕',
        featured_image_url: '',
        content: 'Hello world.',
        keywords: [],
      },
      isLoading: false,
      error: null,
      refetch: vi.fn(),
    })
    const { container } = render(
      <MemoryRouter initialEntries={['/blog/post']}>
        <Routes>
          <Route path="/blog/:slug" element={<BlogPostPage />} />
        </Routes>
      </MemoryRouter>
    )
    const hero = container.querySelector('[class*="aspect-[16/9]"]')
    expect(hero).not.toBeNull()
    expect(hero).toHaveClass('md:aspect-[21/9]')
  })

  it('hides wizard bar labels below xs while keeping them accessible', () => {
    render(
      <WizardSteps
        variant="bars"
        currentStepId="two"
        steps={[
          { id: 'one', label: 'Upload' },
          { id: 'two', label: 'Configure' },
        ]}
      />
    )
    const label = screen.getByText('Configure')
    expect(label).toHaveClass('hidden')
    expect(label).toHaveClass('xs:block')
    // The full step name stays available to screen readers via the button.
    expect(screen.getByRole('button', { name: 'Configure' })).toBeInTheDocument()
  })
})

describe('app shell + primitive mobile contract', () => {
  it('renders the shared textarea on the mobile body type scale (no iOS zoom)', () => {
    render(<Textarea aria-label="Notes" placeholder="Notes" />)
    const textarea = screen.getByRole('textbox', { name: 'Notes' })
    expect(textarea).toHaveClass('type-body-md')
    expect(textarea.className).not.toContain('text-sm')
  })

  it('gives the dialog close button a touch target and safe-area offset', () => {
    render(
      <Dialog open>
        <DialogContent aria-describedby={undefined}>
          <DialogTitle>Example</DialogTitle>
        </DialogContent>
      </Dialog>
    )
    const closeButton = screen.getByText('Close').closest('button')
    expect(closeButton?.className).toContain('touch-target')
    expect(closeButton?.className).toContain('safe-area-top')
  })

  it('gives the sheet close button a touch target and safe-area offset', () => {
    render(
      <Sheet open>
        <SheetContent aria-describedby={undefined}>
          <SheetTitle>Example</SheetTitle>
        </SheetContent>
      </Sheet>
    )
    const closeButton = screen.getByText('Close').closest('button')
    expect(closeButton?.className).toContain('touch-target')
    expect(closeButton?.className).toContain('safe-area-top')
  })

  it('left-aligns wizard bars on mobile and centers them at md+', () => {
    const { container } = render(
      <WizardSteps
        variant="bars"
        currentStepId="two"
        steps={[
          { id: 'one', label: 'Upload' },
          { id: 'two', label: 'Configure' },
        ]}
      />
    )
    const list = container.querySelector('ul')
    expect(list).toHaveClass('justify-start')
    expect(list).toHaveClass('md:justify-center')
  })

  it('keeps the bottom nav mobile-only and below all overlay layers', () => {
    const { container } = render(
      <MemoryRouter initialEntries={['/dashboard']}>
        <BottomNav />
      </MemoryRouter>
    )
    const nav = container.querySelector('nav')
    expect(nav).toHaveClass('z-30')
    expect(nav).toHaveClass('md:hidden')
  })

  it('offsets the toast viewport below the mobile header and safe area', () => {
    render(
      <ToastProvider>
        <ToastViewport data-testid="toast-viewport" />
      </ToastProvider>
    )
    const viewport = screen.getByTestId('toast-viewport')
    expect(viewport.className).toContain(
      'top-[calc(var(--mobile-header-height)+var(--safe-area-top))]'
    )
    expect(viewport).toHaveClass('z-[100]')
  })

  it('keeps dropdown menu items on the 44px touch scale', () => {
    render(
      <DropdownMenu open>
        <DropdownMenuTrigger>Menu</DropdownMenuTrigger>
        <DropdownMenuContent>
          <DropdownMenuItem>Archive</DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    )
    const item = screen.getByRole('menuitem', { name: 'Archive' })
    expect(item.className).toContain('min-h-[44px]')
  })

  it('keeps pan-gesture blocking on the slider thumb, not the track', () => {
    const { container } = render(<Slider defaultValue={[50]} aria-label="Zoom" />)
    const root = container.firstElementChild as HTMLElement
    const thumb = screen.getByRole('slider')
    expect(root.className).not.toContain('touch-none')
    expect(thumb).toHaveClass('touch-none')
  })

  it('stacks the wardrobe review grid one card per row below xs', () => {
    const item: DetectedItem = {
      tempId: 't1',
      category: 'tops',
      colors: ['Black'],
      confidence: 0.9,
      detailedDescription: 'A black tee',
      status: 'generated',
      name: 'Black Tee',
      includeInWardrobe: true,
      generatedImageUrl: 'blob:generated',
    }
    const { container } = render(
      <ExtractedItemsGrid
        items={[item]}
        onItemUpdate={vi.fn()}
        onItemDelete={vi.fn()}
        onItemRegenerate={vi.fn()}
        onSaveAll={vi.fn()}
        onBack={vi.fn()}
        isSaving={false}
      />
    )
    const grid = container.querySelector('[class*="xs:grid-cols-2"]')
    expect(grid).not.toBeNull()
    expect(grid).toHaveClass('grid')
    // 360px phones get one readable card per row; 375px+ (xs) may go two-up.
    expect(grid).toHaveClass('grid-cols-1')
    expect(grid).toHaveClass('xs:grid-cols-2')
    expect(grid).toHaveClass('sm:grid-cols-3')
  })

  it('keeps the review-grid save footer pinned while scrolling', () => {
    const { container } = render(
      <ExtractedItemsGrid
        items={[]}
        onItemUpdate={vi.fn()}
        onItemDelete={vi.fn()}
        onItemRegenerate={vi.fn()}
        onSaveAll={vi.fn()}
        onBack={vi.fn()}
        isSaving={false}
      />
    )
    // Save used to sit at the bottom of a multi-viewport scroll; it must pin
    // to the dialog scroller's visible bottom instead.
    const footer = container.querySelector('div.sticky.bottom-0')
    expect(footer).not.toBeNull()
    expect(footer).toHaveClass('z-10', 'bg-background')
  })

  it('reserves item card height before the image decodes', () => {
    render(<ItemCard item={sweepCardItem} />)
    // The name is the tile's accessible label, not visible text (pure-image
    // card), so the img itself is decorative.
    const img = screen.getByRole('button', { name: 'Black Tee' }).querySelector('img')
    expect(img).not.toBeNull()
    // The backend ships image width/height as null, so this aspect box is the
    // only thing keeping the card taller than a ~2px sliver pre-decode.
    expect(img).toHaveClass('aspect-[3/4]')
  })

  it('renders the grid card as a pure image tile — no text, no buttons', () => {
    // Cards are matted cutouts; every action lives in the detail surface and a
    // long-press starts bulk selection. The tile itself carries no chrome.
    const { container } = render(<ItemCard item={sweepCardItem} />)
    expect(container.querySelector('button')).toBeNull()
    expect(screen.queryByText('Black Tee')).not.toBeInTheDocument()
    expect(screen.queryByLabelText(/favorites/i)).not.toBeInTheDocument()
    expect(screen.queryByLabelText(/Select item/i)).not.toBeInTheDocument()
  })

  it('shows selection chrome only while a bulk selection is active', () => {
    const { container, rerender } = render(<ItemCard item={sweepCardItem} isSelecting />)
    expect(container.querySelector('[data-testid="item-card-selected-badge"]')).toBeNull()
    expect(container.firstElementChild).not.toHaveClass('ring-2')

    rerender(<ItemCard item={sweepCardItem} isSelecting isSelected />)
    expect(
      container.querySelector('[data-testid="item-card-selected-badge"]')
    ).not.toBeNull()
    expect(container.firstElementChild).toHaveClass('ring-2', 'ring-primary')
  })

  it('keeps min-w-0 on the AppLayout main flex item', () => {
    // Without it a wide intrinsic child (the wardrobe chip rail sums to ~780px
    // of min-content) grew `main` to 810px on a 360px phone, rendering a
    // clipped desktop layout under body's overflow-x-hidden.
    render(
      <MemoryRouter>
        <ThemeProvider defaultTheme="light">
          <AppLayout />
        </ThemeProvider>
      </MemoryRouter>
    )
    expect(screen.getByRole('main')).toHaveClass('min-w-0', 'flex-1')
  })

  it('pins the bottom-sheet footer outside the scroll region', () => {
    render(
      <BottomSheet open>
        <BottomSheetContent
          height="large"
          footer={<button type="button">Apply Filters</button>}
        >
          <BottomSheetTitle className="sr-only">Filters</BottomSheetTitle>
          <div>Filters body</div>
        </BottomSheetContent>
      </BottomSheet>
    )
    const apply = screen.getByText('Apply Filters')
    // The footer must be a sibling of the scroller, not a child — inside the
    // scroller it scrolled away with the body (mt-auto was a no-op there).
    expect(apply.closest('.overflow-y-auto')).toBeNull()
    expect(apply.closest('.shrink-0')).not.toBeNull()
  })
})
