/**
 * Generating Step - Progress display during image generation
 */

import { Camera, Sparkles } from 'lucide-react';
import { Progress } from '@/components/ui/progress';
import { usePhotoshoot } from '@/stores/photoshootStore';

export function PhotoshootGeneratingStep() {
  const { progress, statusMessage, numImages } = usePhotoshoot();

  return (
    <div className="py-12 text-center space-y-8">
      {/* Animated Icon */}
      <div className="relative mx-auto w-24 h-24">
        <div className="absolute inset-0 bg-primary/10 rounded-full animate-pulse" />
        <div className="absolute inset-0 flex items-center justify-center">
          <Camera className="w-12 h-12 text-primary" />
        </div>
      </div>

      {/* Status */}
      <div>
        <h3 className="text-lg font-semibold mb-2">{statusMessage || 'Processing...'}</h3>
        <p className="text-sm text-muted-foreground">This may take a moment</p>
      </div>

      {/* Progress Bar */}
      <div className="max-w-xs mx-auto space-y-2">
        <Progress value={progress} className="h-2" />
        <p className="text-sm text-muted-foreground">{progress}%</p>
      </div>

      {/* Info */}
      <div className="bg-muted/50 rounded-lg p-4 max-w-sm mx-auto">
        <div className="flex items-center gap-2 justify-center">
          <Sparkles className="w-4 h-4 text-primary" />
          <span className="text-sm text-muted-foreground">
            AI is creating {numImages} unique professional images just for you...
          </span>
        </div>
      </div>
    </div>
  );
}
