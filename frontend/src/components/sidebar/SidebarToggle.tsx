import { PanelLeftClose, PanelLeft } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useSidebar } from './sidebar-context'
import { Button } from '@/components/ui/button'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'

interface SidebarToggleProps {
  className?: string
}

export function SidebarToggle({ className }: SidebarToggleProps) {
  const { isCollapsed, toggleCollapsed } = useSidebar()

  const button = (
    <Button
      variant="ghost"
      size="icon"
      onClick={toggleCollapsed}
      className={cn('h-9 w-9 shrink-0', className)}
      aria-label={isCollapsed ? 'Expand sidebar' : 'Collapse sidebar'}
      aria-expanded={!isCollapsed}
    >
      {isCollapsed ? (
        <PanelLeft className="h-5 w-5" />
      ) : (
        <PanelLeftClose className="h-5 w-5" />
      )}
    </Button>
  )

  if (isCollapsed) {
    return (
      <Tooltip delayDuration={0}>
        <TooltipTrigger asChild>{button}</TooltipTrigger>
        <TooltipContent side="right" sideOffset={10}>
          <p>Expand sidebar</p>
        </TooltipContent>
      </Tooltip>
    )
  }

  return button
}
