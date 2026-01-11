/**
 * DetectionProgress Component
 *
 * Shows progress during the multi-item detection phase.
 * Displays animated spinner and status text while AI analyzes the image.
 */

import { Loader2, Sparkles, Search } from 'lucide-react'
import { Progress } from '@/components/ui/progress'
import { Card, CardContent } from '@/components/ui/card'
import { ZoomableImage } from '@/components/ui/zoomable-image'

interface DetectionProgressProps {
  /** Progress percentage (0-100) */
  progress: number
  /** Original image preview URL */
  imageUrl: string
  /** Status message to display */
  statusMessage?: string
}

export function DetectionProgress({
  progress,
  imageUrl,
  statusMessage = 'Analyzing image for clothing items...',
}: DetectionProgressProps) {
  return (
    <div className="flex flex-col items-center justify-center py-8 space-y-6">
      {/* Image being analyzed */}
      <div className="relative">
        <ZoomableImage
          src={imageUrl}
          alt="Analyzing"
          className="w-64 h-64 object-cover rounded-lg shadow-lg opacity-80"
        />
        <div className="absolute inset-0 flex items-center justify-center bg-black/20 rounded-lg pointer-events-none">
          <div className="bg-white/90 dark:bg-gray-800/90 rounded-full p-4">
            <Search className="h-8 w-8 text-indigo-500 animate-pulse" />
          </div>
        </div>
      </div>

      {/* Progress indicator */}
      <Card className="w-full max-w-md">
        <CardContent className="pt-6 space-y-4">
          <div className="flex items-center justify-center gap-3">
            <Loader2 className="h-5 w-5 animate-spin text-indigo-500" />
            <span className="text-lg font-medium text-gray-900 dark:text-white">{statusMessage}</span>
          </div>

          <Progress value={progress} className="h-2" />

          <p className="text-center text-sm text-gray-500 dark:text-gray-400">
            <Sparkles className="inline h-4 w-4 mr-1" />
            Using Gemini 3 Pro to identify clothing items
          </p>
        </CardContent>
      </Card>
    </div>
  )
}

export default DetectionProgress
