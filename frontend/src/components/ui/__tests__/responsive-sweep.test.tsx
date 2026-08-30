import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { Shirt } from 'lucide-react'
import { describe, expect, it, vi } from 'vitest'

import DemoSection from '@/components/landing/DemoSection'
import Hero from '@/components/landing/Hero'
import PhotoshootShowcase from '@/components/landing/PhotoshootShowcase'
import TrustBar from '@/components/landing/TrustBar'
import { FeaturePageTemplate } from '@/components/landing/FeaturePageTemplate'
import { WizardSteps } from '@/components/ui/wizard-steps'
import BlogPostPage from '@/pages/blog/BlogPostPage'

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
