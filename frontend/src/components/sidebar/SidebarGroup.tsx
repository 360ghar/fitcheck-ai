'use client'

import { useState } from 'react'
import { ChevronDown } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useSidebar } from './sidebar-context'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'

interface SidebarGroupProps {
  id: string
  label: string
  icon: LucideIcon
  defaultOpen?: boolean
  children: React.ReactNode
}

export function SidebarGroup({
  id,
  label,
  icon: Icon,
  defaultOpen = true,
  children,
}: SidebarGroupProps) {
  const { isCollapsed } = useSidebar()
  const [isOpen, setIsOpen] = useState(defaultOpen)

  // When collapsed, show items directly without group header
  if (isCollapsed) {
    return (
      <div className="space-y-1">
        <Tooltip delayDuration={0}>
          <TooltipTrigger asChild>
            <div className="flex justify-center py-2">
              <div className="h-px w-6 bg-border" />
            </div>
          </TooltipTrigger>
          <TooltipContent side="right" sideOffset={10}>
            <p className="font-medium">{label}</p>
          </TooltipContent>
        </Tooltip>
        {children}
      </div>
    )
  }

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen}>
      <CollapsibleTrigger
        className={cn(
          'flex w-full items-center gap-2 rounded-lg px-3 py-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground transition-colors',
          'hover:bg-accent/50 hover:text-accent-foreground',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring'
        )}
        aria-expanded={isOpen}
        aria-controls={`group-${id}-content`}
      >
        <Icon className="h-4 w-4 shrink-0" />
        <span className="flex-1 text-left">{label}</span>
        <ChevronDown
          className={cn(
            'h-4 w-4 shrink-0 transition-transform duration-200',
            isOpen ? 'rotate-0' : '-rotate-90'
          )}
        />
      </CollapsibleTrigger>
      <CollapsibleContent
        id={`group-${id}-content`}
        className="mt-1 space-y-1 overflow-hidden data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down"
      >
        {children}
      </CollapsibleContent>
    </Collapsible>
  )
}
