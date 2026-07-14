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
import { WizardSteps } from '@/components/ui/wizard-steps';

const WIZARD_STEPS = [
  { id: 'upload', label: 'Upload' },
  { id: 'configure', label: 'Configure' },
  { id: 'generating', label: 'Generate' },
  { id: 'results', label: 'Results' },
] as const;

export default function PhotoshootPage() {
  const { currentStep, fetchUsage, setStep } = usePhotoshoot();

  useEffect(() => {
    fetchUsage();
  }, [fetchUsage]);

  return (
    <div className="max-w-4xl mx-auto px-4 md:px-6 py-4 md:py-8">
      <div className="mb-6">
        <h1 className="text-xl md:text-2xl font-bold text-foreground">AI Photoshoot</h1>
        <p className="text-sm text-muted-foreground mt-1">
          {currentStep === 'upload' && 'Upload 1–4 photos of yourself'}
          {currentStep === 'configure' && 'Choose your photoshoot style'}
          {currentStep === 'generating' && 'Creating your images…'}
          {currentStep === 'results' && 'Your images are ready!'}
        </p>
      </div>

      <WizardSteps
        className="mb-6"
        variant="bars"
        steps={[...WIZARD_STEPS]}
        currentStepId={currentStep}
        onStepClick={(id) => {
          // Allow going back to completed steps only
          const order = ['upload', 'configure', 'generating', 'results'] as const;
          const target = order.indexOf(id as (typeof order)[number]);
          const current = order.indexOf(currentStep);
          if (target >= 0 && target < current && id !== 'generating') {
            setStep(id as typeof currentStep);
          }
        }}
      />

      <Card>
        <CardContent className="p-4 sm:p-6">
          {currentStep === 'upload' && <PhotoshootUploadStep />}
          {currentStep === 'configure' && <PhotoshootConfigureStep />}
          {currentStep === 'generating' && <PhotoshootGeneratingStep />}
          {currentStep === 'results' && <PhotoshootResultsStep />}
        </CardContent>
      </Card>
    </div>
  );
}
