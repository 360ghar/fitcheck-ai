import { cn } from '@/lib/utils'

interface GlassCardProps {
  children: React.ReactNode
  className?: string
}

export function GlassCard({ children, className }: GlassCardProps) {
  return (
    <div
      className={cn(
        'bg-white/80 dark:bg-navy-900/80 backdrop-blur-xl rounded-2xl border border-navy-100/30 dark:border-navy-700/30 shadow-lg',
        className
      )}
    >
      {children}
    </div>
  )
}
