import { Card, CardContent } from '@/components/ui/card'
import { LucideIcon } from 'lucide-react'

interface FeatureCardProps {
  icon: LucideIcon
  title: string
  description: string
  /** @deprecated Kept for call-site compatibility; accent is solid indigo. */
  gradient?: string
}

export function FeatureCard({ icon: Icon, title, description }: FeatureCardProps) {
  return (
    <Card className="group relative overflow-hidden border border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900 transition-colors hover:border-indigo-300 dark:hover:border-indigo-700">
      <CardContent className="p-6">
        <div className="w-12 h-12 rounded-xl flex items-center justify-center mb-4 bg-indigo-50 text-indigo-600 dark:bg-indigo-950/60 dark:text-indigo-400">
          <Icon className="w-6 h-6" />
        </div>
        <h3 className="text-lg font-semibold text-stone-900 dark:text-stone-50 mb-2">{title}</h3>
        <p className="text-stone-600 dark:text-stone-400 text-sm">{description}</p>
      </CardContent>
    </Card>
  )
}
