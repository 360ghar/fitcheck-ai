import { cn } from '@/lib/utils'
import { Card, CardContent } from '@/components/ui/card'
import { LucideIcon } from 'lucide-react'

interface FeatureCardProps {
  icon: LucideIcon
  title: string
  description: string
  variant?: 'navy' | 'gold'
}

export function FeatureCard({ icon: Icon, title, description, variant = 'navy' }: FeatureCardProps) {
  const iconStyles = {
    navy: 'bg-navy-800 dark:bg-navy-700',
    gold: 'bg-gradient-to-br from-gold-400 to-gold-600',
  }

  const iconTextStyles = {
    navy: 'text-white',
    gold: 'text-navy-900',
  }

  return (
    <Card className="group relative overflow-hidden border-0 bg-white dark:bg-navy-800 hover:shadow-elevated transition-all duration-300 hover:-translate-y-0.5">
      {/* Subtle hover accent */}
      <div
        className={cn(
          'absolute inset-0 opacity-0 group-hover:opacity-[0.03] transition-opacity',
          variant === 'gold' ? 'bg-gold-400' : 'bg-navy-600'
        )}
      />

      <CardContent className="p-6">
        <div
          className={cn(
            'w-12 h-12 rounded-lg flex items-center justify-center mb-4',
            iconStyles[variant]
          )}
        >
          <Icon className={cn('w-6 h-6', iconTextStyles[variant])} />
        </div>
        <h3 className="text-lg font-semibold text-navy-800 dark:text-white mb-2">{title}</h3>
        <p className="text-navy-500 dark:text-navy-300 text-sm">{description}</p>
      </CardContent>
    </Card>
  )
}
