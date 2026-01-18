/**
 * Configure Step - Select use case and image count
 */

import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Star } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Slider } from '@/components/ui/slider';
import { Textarea } from '@/components/ui/textarea';
import { usePhotoshoot, usePhotoshootStore, selectEffectiveMaxImages, selectCanGenerate } from '@/stores/photoshootStore';
import { USE_CASE_INFO, PhotoshootUseCase } from '@/api/photoshoot';
import { ReferralBanner } from '@/components/dashboard/ReferralBanner';
import { cn } from '@/lib/utils';

const USE_CASES: PhotoshootUseCase[] = ['linkedin', 'dating_app', 'model_portfolio', 'instagram', 'custom'];

export function PhotoshootConfigureStep() {
  const navigate = useNavigate();
  const {
    useCase,
    setUseCase,
    customPrompt,
    setCustomPrompt,
    numImages,
    setNumImages,
    usage,
    setStep,
    generate,
    error,
  } = usePhotoshoot();
  const effectiveMax = usePhotoshootStore(selectEffectiveMaxImages);
  const canGenerate = usePhotoshootStore(selectCanGenerate);

  const handleBack = () => setStep('upload');

  const handleGenerate = async () => {
    await generate();
  };

  // Check if user is on a pro plan (matches pro_monthly, pro_yearly, etc.)
  const isPro = usage?.plan_type ? /^pro[_-]?/i.test(usage.plan_type) : false;
  const remainingToday = usage?.remaining ?? 10;
  const isOutOfQuota = usage ? remainingToday <= 0 : false;

  return (
    <div className="space-y-6">
      {/* Referral CTA when out of quota */}
      {isOutOfQuota && (
        <div className="space-y-3">
          <ReferralBanner variant="urgent" />
          <div className="flex items-center justify-between text-sm text-muted-foreground">
            <span>Daily limit reached. Comes back at midnight UTC.</span>
            <Button
              variant="link"
              size="sm"
              className="p-0 h-auto"
              onClick={() => navigate('/profile?tab=subscription')}
            >
              Upgrade
            </Button>
          </div>
        </div>
      )}

      {/* Use Case Selection */}
      <div>
        <Label className="text-base font-medium">Choose Your Style</Label>
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 mt-3">
          {USE_CASES.map((uc) => {
            const info = USE_CASE_INFO[uc];
            const isSelected = useCase === uc;
            return (
              <button
                key={uc}
                onClick={() => setUseCase(uc)}
                className={cn(
                  'p-4 rounded-lg border-2 text-center transition-all',
                  isSelected
                    ? 'border-primary bg-primary/5'
                    : 'border-muted hover:border-muted-foreground/50'
                )}
              >
                <span className="text-2xl block mb-1">{info.icon}</span>
                <span
                  className={cn(
                    'text-sm font-medium',
                    isSelected ? 'text-primary' : 'text-foreground'
                  )}
                >
                  {info.label}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Custom Prompt */}
      {useCase === 'custom' && (
        <div>
          <Label htmlFor="custom-prompt" className="text-base font-medium">
            Custom Prompt
          </Label>
          <Textarea
            id="custom-prompt"
            value={customPrompt}
            onChange={(e) => setCustomPrompt(e.target.value)}
            placeholder="Describe the style you want..."
            className="mt-2"
            rows={3}
          />
        </div>
      )}

      {/* Image Count Slider */}
      <div className="bg-muted/50 rounded-lg p-4">
        <div className="flex justify-between items-center mb-4">
          <div>
            <span className="text-2xl font-bold text-primary">{numImages}</span>
            <span className="text-muted-foreground ml-1">images</span>
          </div>
          <span className="text-sm text-muted-foreground">
            {remainingToday} remaining today
          </span>
        </div>
        <Slider
          value={[numImages]}
          onValueChange={([value]) => setNumImages(value)}
          min={1}
          max={effectiveMax}
          step={1}
          className="w-full"
          disabled={isOutOfQuota}
        />
        <div className="flex justify-between mt-2 text-xs text-muted-foreground">
          <span>1</span>
          <span>{effectiveMax}</span>
        </div>
      </div>

      {/* Usage Info */}
      {usage && (
        <div className="flex items-center gap-2 p-3 bg-muted/30 rounded-lg text-sm">
          {isPro ? (
            <>
              <Star className="w-4 h-4 text-amber-500" />
              <span className="text-muted-foreground">
                Pro: {usage.remaining} of {usage.limit_today} images remaining
              </span>
            </>
          ) : (
            <>
              <span className="text-muted-foreground">
                Free: {usage.remaining} of {usage.limit_today} images remaining
              </span>
              <Button
                variant="link"
                size="sm"
                className="ml-auto p-0 h-auto"
                onClick={() => navigate('/profile?tab=subscription')}
              >
                Upgrade
              </Button>
            </>
          )}
        </div>
      )}

      {/* Error */}
      {error && <p className="text-sm text-destructive">{error}</p>}

      {/* Action Buttons */}
      <div className="flex gap-3">
        <Button variant="outline" onClick={handleBack} className="flex-1">
          <ArrowLeft className="w-4 h-4 mr-2" />
          Back
        </Button>
        <Button onClick={handleGenerate} disabled={!canGenerate} className="flex-[2]">
          Generate {numImages} Images
        </Button>
      </div>
    </div>
  );
}
