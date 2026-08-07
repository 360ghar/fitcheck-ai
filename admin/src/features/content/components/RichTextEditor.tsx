import {
  Bold,
  Code,
  Edit3,
  Eye,
  Heading1,
  Heading2,
  Heading3,
  Italic,
  Link,
  List,
  ListOrdered,
  Quote,
  Redo,
  Undo,
} from 'lucide-react'
import { useCallback, useRef } from 'react'

import { Button } from '@/shared/ui/button'
import { Label } from '@/shared/ui/label'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/shared/ui/tabs'
import { Textarea } from '@/shared/ui/textarea'

/**
 * Markdown editor with toolbar + live preview — parity port of
 * `frontend/src/components/admin/RichTextEditor.tsx` onto the admin design
 * system (tabs/textarea/button). Content is stored as markdown; preview is
 * rendered from escaped HTML (no raw HTML is ever injected).
 */

interface RichTextEditorProps {
  value: string
  onChange: (value: string) => void
  placeholder?: string
  label?: string
  error?: string
  minHeight?: string
}

interface ToolbarButtonProps {
  icon: React.ReactNode
  label: string
  onClick: () => void
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

/** Only allow http(s) and mailto targets for markdown links. */
function sanitizeMarkdownUrl(url: string): string {
  if (/^(https?:|mailto:)/i.test(url)) return url
  return '#'
}

function formatInlineText(text: string): string {
  return escapeHtml(text)
    .replace(/`([^`]+)`/g, '<code class="rounded bg-surface-card px-1 py-0.5 font-mono text-xs">$1</code>')
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    .replace(/\*([^*]+)\*/g, '<em>$1</em>')
    .replace(
      /\[([^\]]+)\]\(([^)]+)\)/g,
      (_match, label: string, url: string) =>
        `<a href="${sanitizeMarkdownUrl(url)}" class="text-primary underline-offset-4 hover:underline" target="_blank" rel="noopener noreferrer">${label}</a>`,
    )
}

function renderPreview(content: string): React.ReactNode[] {
  const lines = content.split('\n')
  let inList = false
  let listType: 'ul' | 'ol' | null = null
  let listItems: string[] = []
  let listStartLine = 0

  const flushList = (): React.ReactNode | null => {
    if (!inList || listItems.length === 0) return null
    const ListTag = listType === 'ul' ? 'ul' : 'ol'
    const result = (
      <ListTag
        key={`list-${listStartLine}`}
        className={listType === 'ul' ? 'list-disc pl-5' : 'list-decimal pl-5'}
      >
        {listItems.map((item, i) => (
          <li key={i} dangerouslySetInnerHTML={{ __html: formatInlineText(item) }} />
        ))}
      </ListTag>
    )
    inList = false
    listType = null
    listItems = []
    return result
  }

  const elements: React.ReactNode[] = []

  lines.forEach((line, index) => {
    const trimmed = line.trim()

    if (!trimmed) {
      const listElement = flushList()
      if (listElement) elements.push(listElement)
      elements.push(<br key={`br-${index}`} />)
      return
    }

    if (trimmed.startsWith('# ')) {
      const listElement = flushList()
      if (listElement) elements.push(listElement)
      elements.push(
        <h1 key={index} className="mb-4 mt-8 text-3xl font-bold">
          {trimmed.replace('# ', '')}
        </h1>,
      )
      return
    }
    if (trimmed.startsWith('## ')) {
      const listElement = flushList()
      if (listElement) elements.push(listElement)
      elements.push(
        <h2 key={index} className="mb-3 mt-6 text-2xl font-bold">
          {trimmed.replace('## ', '')}
        </h2>,
      )
      return
    }
    if (trimmed.startsWith('### ')) {
      const listElement = flushList()
      if (listElement) elements.push(listElement)
      elements.push(
        <h3 key={index} className="mb-2 mt-4 text-xl font-bold">
          {trimmed.replace('### ', '')}
        </h3>,
      )
      return
    }

    if (trimmed.startsWith('> ')) {
      const listElement = flushList()
      if (listElement) elements.push(listElement)
      elements.push(
        <blockquote
          key={index}
          className="my-4 border-l-4 border-primary pl-4 italic text-muted-foreground"
        >
          {trimmed.replace('> ', '')}
        </blockquote>,
      )
      return
    }

    if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      if (!inList || listType !== 'ul') {
        const listElement = flushList()
        if (listElement) elements.push(listElement)
        inList = true
        listType = 'ul'
        listStartLine = index
      }
      listItems.push(trimmed.substring(2))
      return
    }

    if (/^\d+\.\s/.test(trimmed)) {
      if (!inList || listType !== 'ol') {
        const listElement = flushList()
        if (listElement) elements.push(listElement)
        inList = true
        listType = 'ol'
        listStartLine = index
      }
      listItems.push(trimmed.replace(/^\d+\.\s/, ''))
      return
    }

    const listElement = flushList()
    if (listElement) elements.push(listElement)
    elements.push(
      <p
        key={index}
        className="mb-4 leading-relaxed"
        dangerouslySetInnerHTML={{ __html: formatInlineText(trimmed) }}
      />,
    )
  })

  const listElement = flushList()
  if (listElement) elements.push(listElement)
  return elements
}

function ToolbarButton({ icon, label, onClick }: ToolbarButtonProps) {
  return (
    <Button type="button" variant="ghost" size="sm" onClick={onClick} title={label} aria-label={label} className="h-8 w-8 p-0">
      {icon}
    </Button>
  )
}

export function RichTextEditor({
  value,
  onChange,
  placeholder = 'Write your content here…',
  label,
  error,
  minHeight = '400px',
}: RichTextEditorProps) {
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const historyRef = useRef<string[]>([value])
  const historyIndexRef = useRef(0)

  const saveToHistory = useCallback((newValue: string) => {
    const newHistory = historyRef.current.slice(0, historyIndexRef.current + 1)
    newHistory.push(newValue)
    if (newHistory.length > 50) newHistory.shift()
    historyRef.current = newHistory
    historyIndexRef.current = Math.min(historyIndexRef.current + 1, 49)
  }, [])

  const handleUndo = (): void => {
    if (historyIndexRef.current > 0) {
      const newIndex = historyIndexRef.current - 1
      historyIndexRef.current = newIndex
      onChange(historyRef.current[newIndex] ?? '')
    }
  }

  const handleRedo = (): void => {
    if (historyIndexRef.current < historyRef.current.length - 1) {
      const newIndex = historyIndexRef.current + 1
      historyIndexRef.current = newIndex
      onChange(historyRef.current[newIndex] ?? '')
    }
  }

  const insertMarkdown = useCallback(
    (before: string, after = '') => {
      const textarea = textareaRef.current
      if (!textarea) return
      const start = textarea.selectionStart
      const end = textarea.selectionEnd
      const selectedText = value.substring(start, end)
      const newText = value.substring(0, start) + before + selectedText + after + value.substring(end)
      onChange(newText)
      saveToHistory(newText)
      setTimeout(() => {
        textarea.focus()
        const newCursorPos = start + before.length + selectedText.length
        textarea.setSelectionRange(newCursorPos, newCursorPos)
      }, 0)
    },
    [value, onChange, saveToHistory],
  )

  const toggleLinePrefix = useCallback(
    (prefix: string) => {
      const textarea = textareaRef.current
      if (!textarea) return
      const start = textarea.selectionStart
      const end = textarea.selectionEnd
      const selectedText = value.substring(start, end)

      if (start === end) {
        const lineStart = value.lastIndexOf('\n', start - 1) + 1
        const lineEnd = value.indexOf('\n', start)
        const actualLineEnd = lineEnd === -1 ? value.length : lineEnd
        const currentLine = value.substring(lineStart, actualLineEnd)

        let newLine: string
        if (currentLine.startsWith(prefix)) {
          newLine = currentLine.substring(prefix.length)
        } else {
          const cleanLine = currentLine.replace(/^(#{1,6}\s|[-*]\s|\d+\.\s|>\s)?/, '')
          newLine = prefix + cleanLine
        }

        const newText = value.substring(0, lineStart) + newLine + value.substring(actualLineEnd)
        onChange(newText)
        saveToHistory(newText)
        setTimeout(() => {
          textarea.focus()
          const newCursorPos = lineStart + newLine.length
          textarea.setSelectionRange(newCursorPos, newCursorPos)
        }, 0)
      } else {
        const lines = selectedText.split('\n')
        const allStartWithPrefix = lines.every((line) => line.startsWith(prefix) || line === '')
        const newLines = lines.map((line) => {
          if (line === '') return line
          if (allStartWithPrefix) {
            return line.startsWith(prefix) ? line.substring(prefix.length) : line
          }
          const cleanLine = line.replace(/^(#{1,6}\s|[-*]\s|\d+\.\s|>\s)?/, '')
          return prefix + cleanLine
        })
        const newSelectedText = newLines.join('\n')
        const newText = value.substring(0, start) + newSelectedText + value.substring(end)
        onChange(newText)
        saveToHistory(newText)
        setTimeout(() => {
          textarea.focus()
          textarea.setSelectionRange(start, start + newSelectedText.length)
        }, 0)
      }
    },
    [value, onChange, saveToHistory],
  )

  const actions = {
    bold: () => insertMarkdown('**', '**'),
    italic: () => insertMarkdown('*', '*'),
    h1: () => toggleLinePrefix('# '),
    h2: () => toggleLinePrefix('## '),
    h3: () => toggleLinePrefix('### '),
    bulletList: () => toggleLinePrefix('- '),
    orderedList: () => toggleLinePrefix('1. '),
    link: () => {
      const textarea = textareaRef.current
      if (!textarea) return
      const start = textarea.selectionStart
      const end = textarea.selectionEnd
      const selectedText = value.substring(start, end)
      const linkText = selectedText || 'link text'
      insertMarkdown(`[${linkText}](`, ')')
    },
    quote: () => toggleLinePrefix('> '),
    code: () => insertMarkdown('`', '`'),
  }

  return (
    <div className="space-y-2">
      {label ? <Label>{label}</Label> : null}

      <Tabs defaultValue="edit" className="w-full">
        <div className="mb-2 flex flex-wrap items-center justify-between gap-2">
          <TabsList>
            <TabsTrigger value="edit" className="gap-2">
              <Edit3 className="size-4" aria-hidden="true" />
              Edit
            </TabsTrigger>
            <TabsTrigger value="preview" className="gap-2">
              <Eye className="size-4" aria-hidden="true" />
              Preview
            </TabsTrigger>
          </TabsList>

          <div className="flex items-center gap-1 rounded-md border border-border p-1">
            <ToolbarButton icon={<Undo className="size-4" />} label="Undo" onClick={handleUndo} />
            <ToolbarButton icon={<Redo className="size-4" />} label="Redo" onClick={handleRedo} />
            <div className="mx-1 h-4 w-px bg-border" />
            <ToolbarButton icon={<Bold className="size-4" />} label="Bold" onClick={actions.bold} />
            <ToolbarButton
              icon={<Italic className="size-4" />}
              label="Italic"
              onClick={actions.italic}
            />
            <div className="mx-1 h-4 w-px bg-border" />
            <ToolbarButton
              icon={<Heading1 className="size-4" />}
              label="Heading 1"
              onClick={actions.h1}
            />
            <ToolbarButton
              icon={<Heading2 className="size-4" />}
              label="Heading 2"
              onClick={actions.h2}
            />
            <ToolbarButton
              icon={<Heading3 className="size-4" />}
              label="Heading 3"
              onClick={actions.h3}
            />
            <div className="mx-1 h-4 w-px bg-border" />
            <ToolbarButton
              icon={<List className="size-4" />}
              label="Bullet list"
              onClick={actions.bulletList}
            />
            <ToolbarButton
              icon={<ListOrdered className="size-4" />}
              label="Numbered list"
              onClick={actions.orderedList}
            />
            <div className="mx-1 h-4 w-px bg-border" />
            <ToolbarButton icon={<Link className="size-4" />} label="Link" onClick={actions.link} />
            <ToolbarButton
              icon={<Quote className="size-4" />}
              label="Quote"
              onClick={actions.quote}
            />
            <ToolbarButton icon={<Code className="size-4" />} label="Code" onClick={actions.code} />
          </div>
        </div>

        <TabsContent value="edit" className="mt-0">
          <Textarea
            ref={textareaRef}
            value={value}
            onChange={(event) => {
              onChange(event.target.value)
              saveToHistory(event.target.value)
            }}
            placeholder={placeholder}
            aria-label={label}
            aria-invalid={error ? true : undefined}
            className="resize-y font-mono text-sm"
            style={{ minHeight }}
          />
        </TabsContent>

        <TabsContent value="preview" className="mt-0">
          <div
            className="max-w-none overflow-auto rounded-md border border-border p-4 text-sm"
            style={{ minHeight }}
          >
            {value ? (
              renderPreview(value)
            ) : (
              <p className="italic text-muted-foreground">Nothing to preview…</p>
            )}
          </div>
        </TabsContent>
      </Tabs>

      {error ? <p className="text-sm font-medium text-destructive">{error}</p> : null}
    </div>
  )
}

export default RichTextEditor
