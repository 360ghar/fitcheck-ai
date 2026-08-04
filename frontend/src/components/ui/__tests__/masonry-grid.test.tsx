import { describe, expect, it } from 'vitest'
import { render } from '@testing-library/react'
import { MasonryGrid } from '../masonry-grid'

/**
 * Cards are keyed divs so we can track which COLUMN wrapper each one lives in.
 * In jsdom there is no ResizeObserver and no layout, so every column measures
 * 0px — which routes the binning through the cold-start round-robin path. That
 * path is exactly what we want to assert: it spreads page 1 evenly and, on
 * append, CONTINUES the round-robin without ever moving an already-placed card.
 */
function Card({ id }: { id: string }) {
  return <div data-testid={`card-${id}`}>card {id}</div>
}

/** The flex column wrapper that owns a card (MasonrGrid renders one per column). */
function columnOf(getByText: (t: string) => HTMLElement, text: string): Element {
  return getByText(text).parentElement as Element
}

describe('MasonryGrid', () => {
  it('spreads page 1 round-robin across columns', () => {
    const { getByText, container } = render(
      <MasonryGrid columnCount={3} resetKey="base">
        {['a', 'b', 'c', 'd', 'e', 'f'].map((id) => (
          <Card key={id} id={id} />
        ))}
      </MasonryGrid>
    )

    const flex = container.firstElementChild as HTMLElement
    expect(flex.children.length).toBe(3)

    // Cold-start round-robin: a,d → col0 ; b,e → col1 ; c,f → col2.
    const col0 = flex.children[0]
    const col1 = flex.children[1]
    const col2 = flex.children[2]

    expect(columnOf(getByText, 'card a')).toBe(col0)
    expect(columnOf(getByText, 'card b')).toBe(col1)
    expect(columnOf(getByText, 'card c')).toBe(col2)
    expect(columnOf(getByText, 'card d')).toBe(col0)
    expect(columnOf(getByText, 'card e')).toBe(col1)
    expect(columnOf(getByText, 'card f')).toBe(col2)
  })

  it('never moves an existing card when more cards are appended', () => {
    const { getByText, container, rerender } = render(
      <MasonryGrid columnCount={3} resetKey="base">
        {['a', 'b', 'c', 'd'].map((id) => (
          <Card key={id} id={id} />
        ))}
      </MasonryGrid>
    )

    // Capture each original card's column node BEFORE appending.
    const before = {
      a: columnOf(getByText, 'card a'),
      b: columnOf(getByText, 'card b'),
      c: columnOf(getByText, 'card c'),
      d: columnOf(getByText, 'card d'),
    }

    // Append two new cards (a load-more page). resetKey is unchanged.
    rerender(
      <MasonryGrid columnCount={3} resetKey="base">
        {['a', 'b', 'c', 'd', 'e', 'f'].map((id) => (
          <Card key={id} id={id} />
        ))}
      </MasonryGrid>
    )

    // The flex container still has exactly 3 columns.
    expect((container.firstElementChild as HTMLElement).children.length).toBe(3)

    // Every original card is in the SAME column node it started in.
    expect(columnOf(getByText, 'card a')).toBe(before.a)
    expect(columnOf(getByText, 'card b')).toBe(before.b)
    expect(columnOf(getByText, 'card c')).toBe(before.c)
    expect(columnOf(getByText, 'card d')).toBe(before.d)
  })

  it('re-spreads every card when resetKey changes', () => {
    const { getByText, container, rerender } = render(
      <MasonryGrid columnCount={3} resetKey="one">
        {['a', 'b', 'c'].map((id) => (
          <Card key={id} id={id} />
        ))}
      </MasonryGrid>
    )

    const firstColBefore = (container.firstElementChild as HTMLElement).children[0]
    expect(columnOf(getByText, 'card a')).toBe(firstColBefore)

    // Same children, new resetKey → the binning is invalidated and re-done.
    // With a fresh round-robin and only 'a','b','c', the order is unchanged,
    // so we instead assert the reset re-bins by changing the count and order.
    rerender(
      <MasonryGrid columnCount={2} resetKey="two">
        {['a', 'b', 'c', 'd'].map((id) => (
          <Card key={id} id={id} />
        ))}
      </MasonryGrid>
    )

    const flex = container.firstElementChild as HTMLElement
    expect(flex.children.length).toBe(2)
    // Round-robin across 2 columns: a,c → col0 ; b,d → col1.
    expect(columnOf(getByText, 'card a')).toBe(flex.children[0])
    expect(columnOf(getByText, 'card b')).toBe(flex.children[1])
    expect(columnOf(getByText, 'card c')).toBe(flex.children[0])
    expect(columnOf(getByText, 'card d')).toBe(flex.children[1])
  })
})
