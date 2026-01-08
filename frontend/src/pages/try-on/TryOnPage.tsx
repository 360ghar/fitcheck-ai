/**
 * TryOnPage - Main page for "Try My Look" feature.
 *
 * Allows users to upload a clothing image and see how they would look wearing it.
 */

import { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { Download, Upload, RefreshCw, Loader2, Sparkles, X } from 'lucide-react';
import { useUserAvatar } from '@/stores/authStore';
import { generateTryOn, TryOnOptions, TryOnResult } from '@/api/ai';
import { AvatarRequiredPrompt } from '@/components/try-on';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useToast } from '@/components/ui/use-toast';

type TryOnStep = 'upload' | 'options' | 'generating' | 'result';

const STYLE_OPTIONS = [
  { value: 'casual', label: 'Casual' },
  { value: 'formal', label: 'Formal' },
  { value: 'business', label: 'Business' },
  { value: 'sporty', label: 'Sporty' },
  { value: 'streetwear', label: 'Streetwear' },
  { value: 'elegant', label: 'Elegant' },
];

const BACKGROUND_OPTIONS = [
  { value: 'studio white', label: 'Studio White' },
  { value: 'studio gray', label: 'Studio Gray' },
  { value: 'urban street', label: 'Urban Street' },
  { value: 'nature outdoor', label: 'Nature' },
  { value: 'minimal', label: 'Minimal' },
];

const POSE_OPTIONS = [
  { value: 'standing front', label: 'Standing Front' },
  { value: 'standing side', label: 'Standing Side' },
  { value: 'walking', label: 'Walking' },
  { value: 'casual pose', label: 'Casual' },
];

export default function TryOnPage() {
  const userAvatar = useUserAvatar();
  const { toast } = useToast();

  const [step, setStep] = useState<TryOnStep>('upload');
  const [clothingFile, setClothingFile] = useState<File | null>(null);
  const [clothingPreview, setClothingPreview] = useState<string | null>(null);
  const [clothingDescription, setClothingDescription] = useState('');
  const [style, setStyle] = useState('casual');
  const [background, setBackground] = useState('studio white');
  const [pose, setPose] = useState('standing front');
  const [isGenerating, setIsGenerating] = useState(false);
  const [result, setResult] = useState<TryOnResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Check for avatar - show prompt if missing
  if (!userAvatar) {
    return <AvatarRequiredPrompt />;
  }

  const onDrop = useCallback((acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    if (file) {
      setClothingFile(file);
      setClothingPreview(URL.createObjectURL(file));
      setStep('options');
      setError(null);
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.webp', '.gif'],
    },
    multiple: false,
    maxSize: 10 * 1024 * 1024, // 10MB
  });

  const handleGenerate = async () => {
    if (!clothingFile) return;

    setIsGenerating(true);
    setStep('generating');
    setError(null);

    try {
      const options: TryOnOptions = {
        clothing_description: clothingDescription || undefined,
        style,
        background,
        pose,
      };

      const tryOnResult = await generateTryOn(clothingFile, options);
      setResult(tryOnResult);
      setStep('result');
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to generate try-on image';
      setError(errorMessage);
      toast({
        title: 'Generation Failed',
        description: errorMessage,
        variant: 'destructive',
      });
      setStep('options');
    } finally {
      setIsGenerating(false);
    }
  };

  const handleReset = () => {
    setClothingFile(null);
    setClothingPreview(null);
    setClothingDescription('');
    setResult(null);
    setError(null);
    setStep('upload');
  };

  const handleDownload = () => {
    if (!result) return;

    const link = document.createElement('a');
    link.href = result.image_url || `data:image/png;base64,${result.image_base64}`;
    link.download = `try-on-${Date.now()}.png`;
    link.click();
  };

  const handleRegenerate = () => {
    setResult(null);
    handleGenerate();
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Try My Look</h1>
        <p className="mt-1 text-gray-600 dark:text-gray-400">
          Upload a picture of clothes to see how you would look wearing them.
        </p>
      </div>

      {/* Upload Step */}
      {step === 'upload' && (
        <Card>
          <CardHeader>
            <CardTitle>Upload Clothing Image</CardTitle>
            <CardDescription>
              Upload a photo of the clothes you want to try on. Works best with clear, well-lit images.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div
              {...getRootProps()}
              className={`border-2 border-dashed rounded-lg p-12 text-center cursor-pointer transition-colors ${
                isDragActive
                  ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20'
                  : 'border-gray-300 dark:border-gray-700 hover:border-indigo-400'
              }`}
            >
              <input {...getInputProps()} />
              <Upload className="mx-auto h-12 w-12 text-gray-400" />
              <p className="mt-4 text-lg font-medium text-gray-900 dark:text-gray-100">
                {isDragActive ? 'Drop the image here' : 'Drag & drop a clothing image'}
              </p>
              <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
                or click to browse (PNG, JPG, WEBP up to 10MB)
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Options Step */}
      {step === 'options' && clothingPreview && (
        <div className="grid gap-6 md:grid-cols-2">
          {/* Preview */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center justify-between">
                Clothing Preview
                <Button variant="ghost" size="sm" onClick={handleReset}>
                  <X className="h-4 w-4 mr-1" />
                  Change
                </Button>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <img
                src={clothingPreview}
                alt="Clothing preview"
                className="w-full h-64 object-contain rounded-lg bg-gray-100 dark:bg-gray-800"
              />
            </CardContent>
          </Card>

          {/* Options */}
          <Card>
            <CardHeader>
              <CardTitle>Generation Options</CardTitle>
              <CardDescription>
                Customize how your try-on image will look.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="description">Description (optional)</Label>
                <Input
                  id="description"
                  placeholder="e.g., Blue denim jacket with brass buttons"
                  value={clothingDescription}
                  onChange={(e) => setClothingDescription(e.target.value)}
                />
                <p className="text-xs text-gray-500">
                  Adding a description helps improve accuracy.
                </p>
              </div>

              <div className="space-y-2">
                <Label>Style</Label>
                <Select value={style} onValueChange={setStyle}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {STYLE_OPTIONS.map((opt) => (
                      <SelectItem key={opt.value} value={opt.value}>
                        {opt.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label>Background</Label>
                <Select value={background} onValueChange={setBackground}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {BACKGROUND_OPTIONS.map((opt) => (
                      <SelectItem key={opt.value} value={opt.value}>
                        {opt.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label>Pose</Label>
                <Select value={pose} onValueChange={setPose}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {POSE_OPTIONS.map((opt) => (
                      <SelectItem key={opt.value} value={opt.value}>
                        {opt.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {error && (
                <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
              )}

              <Button
                className="w-full mt-4"
                onClick={handleGenerate}
                disabled={isGenerating}
              >
                <Sparkles className="h-4 w-4 mr-2" />
                Generate Try-On
              </Button>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Generating Step */}
      {step === 'generating' && (
        <Card>
          <CardContent className="py-16">
            <div className="flex flex-col items-center justify-center">
              <Loader2 className="h-12 w-12 text-indigo-600 animate-spin" />
              <p className="mt-4 text-lg font-medium text-gray-900 dark:text-gray-100">
                Generating your try-on image...
              </p>
              <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
                This may take a minute. We're combining your profile picture with the clothing.
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Result Step */}
      {step === 'result' && result && (
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center justify-between">
                Your Try-On Result
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" onClick={handleRegenerate}>
                    <RefreshCw className="h-4 w-4 mr-1" />
                    Regenerate
                  </Button>
                  <Button variant="outline" size="sm" onClick={handleDownload}>
                    <Download className="h-4 w-4 mr-1" />
                    Download
                  </Button>
                </div>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <img
                src={result.image_url || `data:image/png;base64,${result.image_base64}`}
                alt="Try-on result"
                className="w-full max-h-[600px] object-contain rounded-lg"
              />
            </CardContent>
          </Card>

          <div className="flex justify-center">
            <Button onClick={handleReset}>
              <Upload className="h-4 w-4 mr-2" />
              Try Another Look
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
