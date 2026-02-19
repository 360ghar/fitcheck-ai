/**
 * Rich Text Editor Component for Blog Content
 * Uses markdown syntax with toolbar buttons for formatting
 */

import { useState, useRef, useCallback } from 'react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  Bold,
  Italic,
  Heading1,
  Heading2,
  Heading3,
  List,
  ListOrdered,
  Link,
  Quote,
  Code,
  Eye,
  Edit3,
  Undo,
  Redo,
} from 'lucide-react';

interface RichTextEditorProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  label?: string;
  error?: string;
  className?: string;
  minHeight?: string;
}

interface ToolbarButtonProps {
  icon: React.ReactNode;
  label: string;
  onClick: () => void;
  active?: boolean;
}

function ToolbarButton({ icon, label, onClick, active }: ToolbarButtonProps) {
  return (
    <Button
      type="button"
      variant="ghost"
      size="sm"
      onClick={onClick}
      className={cn(
        'h-8 w-8 p-0',
        active && 'bg-muted text-primary'
      )}
      title={label}
    >
      {icon}
    </Button>
  );
}

export function RichTextEditor({
  value,
  onChange,
  placeholder = 'Write your content here...',
  label,
  error,
  className,
  minHeight = '400px',
}: RichTextEditorProps) {
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const [history, setHistory] = useState<string[]>([value]);
  const [historyIndex, setHistoryIndex] = useState(0);

  // Save state to history
  const saveToHistory = useCallback((newValue: string) => {
    setHistory(prev => {
      const newHistory = prev.slice(0, historyIndex + 1);
      newHistory.push(newValue);
      // Keep only last 50 states
      if (newHistory.length > 50) {
        newHistory.shift();
      }
      return newHistory;
    });
    setHistoryIndex(prev => Math.min(prev + 1, 49));
  }, [historyIndex]);

  // Undo
  const handleUndo = () => {
    if (historyIndex > 0) {
      const newIndex = historyIndex - 1;
      setHistoryIndex(newIndex);
      onChange(history[newIndex]);
    }
  };

  // Redo
  const handleRedo = () => {
    if (historyIndex < history.length - 1) {
      const newIndex = historyIndex + 1;
      setHistoryIndex(newIndex);
      onChange(history[newIndex]);
    }
  };

  // Insert markdown syntax at cursor position
  const insertMarkdown = useCallback((before: string, after: string = '') => {
    const textarea = textareaRef.current;
    if (!textarea) return;

    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const selectedText = value.substring(start, end);
    const newText = value.substring(0, start) + before + selectedText + after + value.substring(end);

    onChange(newText);
    saveToHistory(newText);

    // Restore focus and set cursor position
    setTimeout(() => {
      textarea.focus();
      const newCursorPos = start + before.length + selectedText.length;
      textarea.setSelectionRange(newCursorPos, newCursorPos);
    }, 0);
  }, [value, onChange, saveToHistory]);

  // Toggle line prefix (for lists, headers)
  const toggleLinePrefix = useCallback((prefix: string) => {
    const textarea = textareaRef.current;
    if (!textarea) return;

    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const selectedText = value.substring(start, end);

    // If no selection, apply to current line
    if (start === end) {
      const lineStart = value.lastIndexOf('\n', start - 1) + 1;
      const lineEnd = value.indexOf('\n', start);
      const actualLineEnd = lineEnd === -1 ? value.length : lineEnd;
      const currentLine = value.substring(lineStart, actualLineEnd);

      let newLine: string;
      if (currentLine.startsWith(prefix)) {
        newLine = currentLine.substring(prefix.length);
      } else {
        // Remove other prefixes if present
        const cleanLine = currentLine.replace(/^(#{1,6}\s|[-*]\s|\d+\.\s|>\s)?/, '');
        newLine = prefix + cleanLine;
      }

      const newText = value.substring(0, lineStart) + newLine + value.substring(actualLineEnd);
      onChange(newText);
      saveToHistory(newText);

      setTimeout(() => {
        textarea.focus();
        const newCursorPos = lineStart + newLine.length;
        textarea.setSelectionRange(newCursorPos, newCursorPos);
      }, 0);
    } else {
      // Apply to each selected line
      const lines = selectedText.split('\n');
      const allStartWithPrefix = lines.every(line => line.startsWith(prefix) || line === '');

      const newLines = lines.map(line => {
        if (line === '') return line;
        if (allStartWithPrefix) {
          return line.startsWith(prefix) ? line.substring(prefix.length) : line;
        } else {
          const cleanLine = line.replace(/^(#{1,6}\s|[-*]\s|\d+\.\s|>\s)?/, '');
          return prefix + cleanLine;
        }
      });

      const newSelectedText = newLines.join('\n');
      const newText = value.substring(0, start) + newSelectedText + value.substring(end);

      onChange(newText);
      saveToHistory(newText);

      setTimeout(() => {
        textarea.focus();
        textarea.setSelectionRange(start, start + newSelectedText.length);
      }, 0);
    }
  }, [value, onChange, saveToHistory]);

  // Toolbar actions
  const actions = {
    bold: () => insertMarkdown('**', '**'),
    italic: () => insertMarkdown('*', '*'),
    h1: () => toggleLinePrefix('# '),
    h2: () => toggleLinePrefix('## '),
    h3: () => toggleLinePrefix('### '),
    bulletList: () => toggleLinePrefix('- '),
    orderedList: () => toggleLinePrefix('1. '),
    link: () => {
      const textarea = textareaRef.current;
      if (!textarea) return;
      const start = textarea.selectionStart;
      const end = textarea.selectionEnd;
      const selectedText = value.substring(start, end);
      const linkText = selectedText || 'link text';
      insertMarkdown(`[${linkText}](`, ')');
    },
    quote: () => toggleLinePrefix('> '),
    code: () => insertMarkdown('`', '`'),
  };

  // Render markdown preview
  const renderPreview = (content: string) => {
    const lines = content.split('\n');
    let inList = false;
    let listType: 'ul' | 'ol' | null = null;
    let listItems: string[] = [];

    const flushList = () => {
      if (!inList || listItems.length === 0) return null;
      const ListTag = listType === 'ul' ? 'ul' : 'ol';
      const result = (
        <ListTag key={`list-${Math.random()}`} className={listType === 'ul' ? 'list-disc' : 'list-decimal'}>
          {listItems.map((item, i) => (
            <li key={i} dangerouslySetInnerHTML={{ __html: formatInlineText(item) }} />
          ))}
        </ListTag>
      );
      inList = false;
      listType = null;
      listItems = [];
      return result;
    };

    const elements: React.ReactNode[] = [];

    lines.forEach((line, index) => {
      const trimmed = line.trim();

      // Handle empty lines
      if (!trimmed) {
        const listElement = flushList();
        if (listElement) elements.push(listElement);
        elements.push(<br key={`br-${index}`} />);
        return;
      }

      // Headers
      if (trimmed.startsWith('# ')) {
        const listElement = flushList();
        if (listElement) elements.push(listElement);
        elements.push(
          <h1 key={index} className="text-3xl font-bold mt-8 mb-4">
            {trimmed.replace('# ', '')}
          </h1>
        );
        return;
      }
      if (trimmed.startsWith('## ')) {
        const listElement = flushList();
        if (listElement) elements.push(listElement);
        elements.push(
          <h2 key={index} className="text-2xl font-bold mt-6 mb-3">
            {trimmed.replace('## ', '')}
          </h2>
        );
        return;
      }
      if (trimmed.startsWith('### ')) {
        const listElement = flushList();
        if (listElement) elements.push(listElement);
        elements.push(
          <h3 key={index} className="text-xl font-bold mt-4 mb-2">
            {trimmed.replace('### ', '')}
          </h3>
        );
        return;
      }

      // Blockquote
      if (trimmed.startsWith('> ')) {
        const listElement = flushList();
        if (listElement) elements.push(listElement);
        elements.push(
          <blockquote key={index} className="border-l-4 border-primary pl-4 italic my-4 text-muted-foreground">
            {trimmed.replace('> ', '')}
          </blockquote>
        );
        return;
      }

      // Bullet list
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        if (!inList || listType !== 'ul') {
          const listElement = flushList();
          if (listElement) elements.push(listElement);
          inList = true;
          listType = 'ul';
        }
        listItems.push(trimmed.substring(2));
        return;
      }

      // Ordered list
      if (/^\d+\.\s/.test(trimmed)) {
        if (!inList || listType !== 'ol') {
          const listElement = flushList();
          if (listElement) elements.push(listElement);
          inList = true;
          listType = 'ol';
        }
        listItems.push(trimmed.replace(/^\d+\.\s/, ''));
        return;
      }

      // Regular paragraph
      const listElement = flushList();
      if (listElement) elements.push(listElement);
      elements.push(
        <p
          key={index}
          className="mb-4 leading-relaxed"
          dangerouslySetInnerHTML={{ __html: formatInlineText(trimmed) }}
        />
      );
    });

    // Flush any remaining list
    const listElement = flushList();
    if (listElement) elements.push(listElement);

    return elements;
  };

  // Format inline text (bold, italic, links, code)
  const formatInlineText = (text: string): string => {
    return text
      .replace(/`([^`]+)`/g, '<code class="bg-muted px-1 py-0.5 rounded text-sm font-mono">$1</code>')
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      .replace(/\*([^*]+)\*/g, '<em>$1</em>')
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" class="text-primary hover:underline" target="_blank" rel="noopener noreferrer">$1</a>');
  };

  return (
    <div className={cn('space-y-2', className)}>
      {label && <Label>{label}</Label>}

      <Tabs defaultValue="edit" className="w-full">
        <div className="flex items-center justify-between mb-2">
          <TabsList>
            <TabsTrigger value="edit" className="flex items-center gap-2">
              <Edit3 className="w-4 h-4" />
              Edit
            </TabsTrigger>
            <TabsTrigger value="preview" className="flex items-center gap-2">
              <Eye className="w-4 h-4" />
              Preview
            </TabsTrigger>
          </TabsList>

          <div className="flex items-center gap-1 border rounded-md p-1">
            <ToolbarButton
              icon={<Undo className="w-4 h-4" />}
              label="Undo"
              onClick={handleUndo}
            />
            <ToolbarButton
              icon={<Redo className="w-4 h-4" />}
              label="Redo"
              onClick={handleRedo}
            />
            <div className="w-px h-4 bg-border mx-1" />
            <ToolbarButton
              icon={<Bold className="w-4 h-4" />}
              label="Bold"
              onClick={actions.bold}
            />
            <ToolbarButton
              icon={<Italic className="w-4 h-4" />}
              label="Italic"
              onClick={actions.italic}
            />
            <div className="w-px h-4 bg-border mx-1" />
            <ToolbarButton
              icon={<Heading1 className="w-4 h-4" />}
              label="Heading 1"
              onClick={actions.h1}
            />
            <ToolbarButton
              icon={<Heading2 className="w-4 h-4" />}
              label="Heading 2"
              onClick={actions.h2}
            />
            <ToolbarButton
              icon={<Heading3 className="w-4 h-4" />}
              label="Heading 3"
              onClick={actions.h3}
            />
            <div className="w-px h-4 bg-border mx-1" />
            <ToolbarButton
              icon={<List className="w-4 h-4" />}
              label="Bullet List"
              onClick={actions.bulletList}
            />
            <ToolbarButton
              icon={<ListOrdered className="w-4 h-4" />}
              label="Numbered List"
              onClick={actions.orderedList}
            />
            <div className="w-px h-4 bg-border mx-1" />
            <ToolbarButton
              icon={<Link className="w-4 h-4" />}
              label="Link"
              onClick={actions.link}
            />
            <ToolbarButton
              icon={<Quote className="w-4 h-4" />}
              label="Quote"
              onClick={actions.quote}
            />
            <ToolbarButton
              icon={<Code className="w-4 h-4" />}
              label="Code"
              onClick={actions.code}
            />
          </div>
        </div>

        <TabsContent value="edit" className="mt-0">
          <Textarea
            ref={textareaRef}
            value={value}
            onChange={(e) => {
              onChange(e.target.value);
              saveToHistory(e.target.value);
            }}
            placeholder={placeholder}
            className={cn(
              'font-mono text-sm resize-y',
              error && 'border-destructive focus-visible:ring-destructive'
            )}
            style={{ minHeight }}
          />
        </TabsContent>

        <TabsContent value="preview" className="mt-0">
          <div
            className="border rounded-md p-4 prose prose-sm dark:prose-invert max-w-none overflow-auto"
            style={{ minHeight }}
          >
            {value ? renderPreview(value) : (
              <p className="text-muted-foreground italic">Nothing to preview...</p>
            )}
          </div>
        </TabsContent>
      </Tabs>

      {error && <p className="text-sm text-destructive">{error}</p>}

      <p className="text-xs text-muted-foreground">
        Use markdown syntax: **bold**, *italic*, # heading, - list, 1. numbered list, [link](url)
      </p>
    </div>
  );
}

export default RichTextEditor;
