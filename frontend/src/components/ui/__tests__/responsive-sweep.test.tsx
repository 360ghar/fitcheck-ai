import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { Shirt } from 'lucide-react'
import { describe, expect, it, vi } from 'vitest'

import DemoSection from '@/components/landing/DemoSection'
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

  it('shows one honest photoshoot result instead of a before-and-after claim', () => {
    render(
      <MemoryRouter>
        <PhotoshootShowcase />
      </MemoryRouter>
    )
    const section = document.getElementById('photoshoot-showcase')
    expect(section?.querySelectorAll('figure')).toHaveLength(1)
    expect(section?.querySelector('figure img')).toHaveClass('aspect-[4/5]')
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
})
