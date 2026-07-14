import { X } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { useState } from 'react'

export interface ChipGroupProps {
  label: string
  labelId?: string
  value: string[]
  onChange: (next: string[]) => void
  suggestions?: string[]
  placeholder?: string
  description?: string
  className?: string
}

function normalize(token: string): string {
  return token.trim().replace(/\s+/g, ' ')
}

export function ChipGroup({
  label,
  labelId,
  value,
  onChange,
  suggestions = [],
  placeholder = 'Add…',
  description,
  className,
}: ChipGroupProps) {
  const [draft, setDraft] = useState('')
  const id = labelId || label.toLowerCase().replace(/\s+/g, '-')

  const add = (raw: string) => {
    const token = normalize(raw)
    if (!token) return
    const exists = value.some((v) => v.toLowerCase() === token.toLowerCase())
    if (exists) {
      setDraft('')
      return
    }
    onChange([...value, token])
    setDraft('')
  }

  const remove = (token: string) => {
    onChange(value.filter((v) => v !== token))
  }

  const unusedSuggestions = suggestions.filter(
    (s) => !value.some((v) => v.toLowerCase() === s.toLowerCase())
  )

  return (
    <div className={cn('space-y-2', className)}>
      <label htmlFor={id} className="block text-sm font-medium text-foreground">
        {label}
      </label>
      {description && (
        <p className="text-xs text-muted-foreground">{description}</p>
      )}

      {value.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {value.map((token) => (
            <span
              key={token}
              className="inline-flex items-center gap-1 rounded-full bg-primary/10 text-primary px-2.5 py-1 text-xs font-medium"
            >
              {token}
              <button
                type="button"
                onClick={() => remove(token)}
                className="rounded-full p-0.5 hover:bg-primary/20 touch-target"
                aria-label={`Remove ${token}`}
              >
                <X className="h-3 w-3" />
              </button>
            </span>
          ))}
        </div>
      )}

      {unusedSuggestions.length > 0 && (
        <div className="flex flex-wrap gap-1.5">
          {unusedSuggestions.map((s) => (
            <button
              key={s}
              type="button"
              onClick={() => add(s)}
              className="rounded-full border border-border px-2.5 py-1 text-xs text-muted-foreground hover:border-primary/40 hover:text-foreground transition-colors"
            >
              + {s}
            </button>
          ))}
        </div>
      )}

      <div className="flex gap-2">
        <Input
          id={id}
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              e.preventDefault()
              add(draft)
            }
          }}
          placeholder={placeholder}
          className="flex-1"
        />
        <Button type="button" variant="outline" onClick={() => add(draft)}>
          Add
        </Button>
      </div>
    </div>
  )
}
