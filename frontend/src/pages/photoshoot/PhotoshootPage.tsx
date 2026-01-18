/**
 * AI Photoshoot Generator Page
 *
 * Generates professional-styled images from uploaded photos.
 * Features:
 * - Upload 1-4 reference photos
 * - Select use case (LinkedIn, Dating App, Portfolio, Instagram, Custom)
 * - Slider for image count (1-10)
 * - Download individual or all images
 */

import { useEffect } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { usePhotoshoot } from '@/stores/photoshootStore';
import { PhotoshootUploadStep } from './components/PhotoshootUploadStep';
import { PhotoshootConfigureStep } from './components/PhotoshootConfigureStep';
import { PhotoshootGeneratingStep } from './components/PhotoshootGeneratingStep';
import { PhotoshootResultsStep } from './components/PhotoshootResultsStep';
import { cn } from '@/lib/utils';

const STEPS = ['Upload', 'Configure', 'Generate', 'Results'] as const;
const STEP_INDEX = { upload: 0, configure: 1, generating: 2, results: 3 };

export default function PhotoshootPage() {
  const { currentStep, fetchUsage } = usePhotoshoot();

  // Fetch usage on mount
  useEffect(() => {
    fetchUsage();
  }, [fetchUsage]);

  const currentIndex = STEP_INDEX[currentStep];

  return (
    <div className="max-w-4xl mx-auto px-4 py-6">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center gap-2 mb-2">
          <h1 className="text-2xl font-bold">AI Photoshoot</h1>
          <span className="text-2xl">📸</span>
        </div>
        <p className="text-muted-foreground">
          {currentStep === 'upload' && 'Upload 1-4 photos of yourself'}
          {currentStep === 'configure' && 'Choose your photoshoot style'}
          {currentStep === 'generating' && 'Creating your images...'}
          {currentStep === 'results' && 'Your images are ready!'}
        </p>
      </div>

      {/* Step Indicator */}
      <div className="mb-6">
        <div className="flex gap-2">
          {STEPS.map((step, index) => (
            <div key={step} className="flex-1">
              <div
                className={cn(
                  'h-1 rounded-full transition-colors',
                  index <= currentIndex ? 'bg-primary' : 'bg-muted'
                )}
              />
              <p
                className={cn(
                  'text-xs mt-1 text-center',
                  index === currentIndex ? 'text-primary font-medium' : 'text-muted-foreground'
                )}
              >
                {step}
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Content */}
      <Card>
        <CardContent className="p-6">
          {currentStep === 'upload' && <PhotoshootUploadStep />}
          {currentStep === 'configure' && <PhotoshootConfigureStep />}
          {currentStep === 'generating' && <PhotoshootGeneratingStep />}
          {currentStep === 'results' && <PhotoshootResultsStep />}
        </CardContent>
      </Card>
    </div>
  );
}
