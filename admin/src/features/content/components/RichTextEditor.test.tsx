import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { useState } from 'react'
import { describe, expect, it, vi } from 'vitest'
import { axe } from 'vitest-axe'

import { RichTextEditor } from './RichTextEditor'

import { renderWithProviders } from '@/test/utils'

/**
 * The formatting toolbar is a single row of icon buttons (~600px wide) that
 * must scroll horizontally on phone viewports instead of overflowing the
 * page (regression guard for the `overflow-x-auto` fix).
 */
const TOOLBAR_BUTTON_LABELS = [
  'Undo',
  'Redo',
  'Bold',
  'Italic',
  'Heading 1',
  'Heading 2',
  'Heading 3',
  'Bullet list',
  'Numbered list',
  'Link',
  'Quote',
  'Code',
] as const

describe('RichTextEditor', () => {
  it('renders every toolbar control inside a horizontally scrollable row', () => {
    const { container } = renderWithProviders(
      <RichTextEditor value="" onChange={vi.fn()} label="Content" />,
    )
    for (const label of TOOLBAR_BUTTON_LABELS) {
      expect(screen.getByRole('button', { name: label })).toBeInTheDocument()
    }
    const toolbar = container.querySelector('.overflow-x-auto')
    expect(toolbar).not.toBeNull()
    expect(toolbar?.querySelectorAll('button').length).toBe(TOOLBAR_BUTTON_LABELS.length)
  })

  it('applies markdown from the toolbar without crashing', async () => {
    const user = userEvent.setup()
    function Harness() {
      const [value, setValue] = useState('hello')
      return <RichTextEditor value={value} onChange={setValue} label="Content" />
    }
    const { container } = renderWithProviders(<Harness />)
    const textarea = container.querySelector('textarea')
    if (!textarea) throw new Error('editor textarea did not render')
    textarea.setSelectionRange(0, 5)
    await user.click(screen.getByRole('button', { name: 'Bold' }))
    expect(textarea.value).toBe('**hello**')
    await user.click(screen.getByRole('button', { name: 'Heading 1' }))
    expect(textarea.value).toBe('# **hello**')
  })

  it('has no axe violations (WCAG 2.1 AA)', async () => {
    const { container } = renderWithProviders(
      <RichTextEditor value="" onChange={vi.fn()} label="Content" />,
    )
    expect(await axe(container)).toHaveNoViolations()
  })
})
