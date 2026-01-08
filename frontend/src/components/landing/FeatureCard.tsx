import { cn } from '@/lib/utils'
import { Card, CardContent } from '@/components/ui/card'
import { LucideIcon } from 'lucide-react'

interface FeatureCardProps {
  icon: LucideIcon
  title: string
  description: string
  gradient: string
}

export function FeatureCard({ icon: Icon, title, description, gradient }: FeatureCardProps) {
  return (
    <Card className="group relative overflow-hidden border-0 bg-white dark:bg-gray-800 hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
      {/* Gradient accent on hover */}
      <div
        className={cn(
          'absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-5 transition-opacity',
          gradient
        )}
      />

      <CardContent className="p-6">
        <div
          className={cn(
            'w-12 h-12 rounded-xl flex items-center justify-center mb-4 bg-gradient-to-br',
            gradient
          )}
        >
          <Icon className="w-6 h-6 text-white" />
        </div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">{title}</h3>
        <p className="text-gray-600 dark:text-gray-400 text-sm">{description}</p>
      </CardContent>
    </Card>
  )
}
