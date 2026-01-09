/**
 * AIGenerator Component
 *
 * Interface for AI-powered outfit image generation using the backend AI service.
 * Supports multiple AI providers (Gemini, OpenAI, custom) for high-quality fashion visualization.
 */

import { useState } from 'react'
import {
  Wand2,
  Image as ImageIcon,
  Loader2,
  Download,
  RefreshCw,
  Settings,
  Check,
  LayoutGrid,
  Sun,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Switch } from '@/components/ui/switch'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import { generateOutfit, generateMultiPoseOutfit, type PosePreset } from '@/api/ai'
import { useToast } from '@/components/ui/use-toast'
import type { Item } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

interface GenerationOptions {
  style: string
  background: string
  pose: string
  lighting: string
  viewAngle: string
  includeModel: boolean
  modelGender: 'male' | 'female' | 'non-binary'
  modelBodyType: string
  imageStyle: 'photorealistic' | 'illustration' | 'sketch'
}

interface AIGeneratorProps {
  items: Item[]
  onGenerated?: (imageUrl: string, metadata?: Record<string, unknown>) => void
  onClose?: () => void
}

interface GeneratedImage {
  url: string
  prompt: string
  options: GenerationOptions
  timestamp: number
}

// ============================================================================
// CONSTANTS
// =============================================================================

const STYLE_PRESETS = [
  { value: 'casual', label: 'Casual', description: 'Everyday relaxed look' },
  { value: 'formal', label: 'Formal', description: 'Elegant and sophisticated' },
  { value: 'business', label: 'Business', description: 'Professional and polished' },
  { value: 'sporty', label: 'Sporty', description: 'Athletic and active' },
  { value: 'streetwear', label: 'Streetwear', description: 'Urban and trendy' },
  { value: 'bohemian', label: 'Bohemian', description: 'Free-spirited and artistic' },
  { value: 'vintage', label: 'Vintage', description: 'Classic and nostalgic' },
  { value: 'minimalist', label: 'Minimalist', description: 'Clean and simple' },
]

const BACKGROUND_OPTIONS = [
  { value: 'studio white', label: 'Studio White', color: '#ffffff' },
  { value: 'studio gray', label: 'Studio Gray', color: '#e5e7eb' },
  { value: 'urban street', label: 'Urban Street', color: '#374151' },
  { value: 'nature outdoor', label: 'Nature', color: '#86efac' },
  { value: 'beach', label: 'Beach', color: '#fde68a' },
  { value: 'cafe interior', label: 'Cafe', color: '#d4a574' },
  { value: 'minimal', label: 'Minimal', color: '#f3f4f6' },
  { value: 'gradient', label: 'Gradient', color: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' },
]

const POSE_OPTIONS = [
  { value: 'standing front', label: 'Standing Front' },
  { value: 'standing side', label: 'Standing Side' },
  { value: 'walking', label: 'Walking' },
  { value: 'sitting', label: 'Sitting' },
  { value: 'action pose', label: 'Action Pose' },
  { value: 'flat lay', label: 'Flat Lay (No Model)' },
]

const LIGHTING_OPTIONS = [
  { value: 'natural', label: 'Natural Light' },
  { value: 'studio', label: 'Studio Lighting' },
  { value: 'golden hour', label: 'Golden Hour' },
  { value: 'dramatic', label: 'Dramatic' },
  { value: 'soft', label: 'Soft/Diffused' },
  { value: 'office fluorescent', label: 'Office Fluorescent' },
  { value: 'evening warm', label: 'Evening Warm' },
  { value: 'overcast outdoor', label: 'Overcast Outdoor' },
]

/**
 * Lighting scenarios combine lighting + background for common real-world contexts.
 * These are quick presets for visualizing how an outfit looks in different settings.
 */
const LIGHTING_SCENARIOS = [
  {
    value: 'office',
    label: 'Office',
    icon: '🏢',
    description: 'Professional office environment',
    settings: { lighting: 'office fluorescent', background: 'minimal' },
  },
  {
    value: 'outdoor-day',
    label: 'Outdoor Day',
    icon: '☀️',
    description: 'Bright natural daylight',
    settings: { lighting: 'natural', background: 'nature outdoor' },
  },
  {
    value: 'evening-out',
    label: 'Evening Out',
    icon: '🌙',
    description: 'Warm evening restaurant/bar',
    settings: { lighting: 'evening warm', background: 'cafe interior' },
  },
  {
    value: 'golden-hour',
    label: 'Golden Hour',
    icon: '🌅',
    description: 'Perfect sunset lighting',
    settings: { lighting: 'golden hour', background: 'urban street' },
  },
  {
    value: 'studio',
    label: 'Studio',
    icon: '📸',
    description: 'Clean professional studio',
    settings: { lighting: 'studio', background: 'studio white' },
  },
  {
    value: 'cloudy',
    label: 'Cloudy Day',
    icon: '☁️',
    description: 'Soft overcast lighting',
    settings: { lighting: 'overcast outdoor', background: 'urban street' },
  },
  {
    value: 'beach',
    label: 'Beach',
    icon: '🏖️',
    description: 'Bright beach setting',
    settings: { lighting: 'natural', background: 'beach' },
  },
  {
    value: 'dramatic',
    label: 'Dramatic',
    icon: '✨',
    description: 'High contrast editorial',
    settings: { lighting: 'dramatic', background: 'gradient' },
  },
]

const VIEW_ANGLE_OPTIONS = [
  { value: 'front view', label: 'Front View' },
  { value: 'three quarter', label: 'Three-Quarter' },
  { value: 'profile', label: 'Profile' },
  { value: 'full body', label: 'Full Body' },
  { value: 'close up', label: 'Close-Up' },
]

// ============================================================================
// COMPONENT
// ============================================================================

export function AIGenerator({ items, onGenerated, onClose }: AIGeneratorProps) {
  const [isGenerating, setIsGenerating] = useState(false)
  const [isGeneratingMultiPose, setIsGeneratingMultiPose] = useState(false)
  const [progress, setProgress] = useState(0)
  const [generatedImages, setGeneratedImages] = useState<GeneratedImage[]>([])
  const [selectedImage, setSelectedImage] = useState<GeneratedImage | null>(null)
  const [multiPoseImages, setMultiPoseImages] = useState<GeneratedImage[]>([])

  const [customPrompt, setCustomPrompt] = useState('')
  const [options, setOptions] = useState<GenerationOptions>({
    style: 'casual',
    background: 'studio white',
    pose: 'standing front',
    lighting: 'studio',
    viewAngle: 'full body',
    includeModel: true,
    modelGender: 'female',
    modelBodyType: 'average',
    imageStyle: 'photorealistic',
  })

  const [advancedMode, setAdvancedMode] = useState(false)
  const [selectedScenario, setSelectedScenario] = useState<string | null>(null)

  const { toast } = useToast()

  // ============================================================================
  // GENERATION
  // ============================================================================

  const handleApplyScenario = (scenarioValue: string) => {
    const scenario = LIGHTING_SCENARIOS.find((s) => s.value === scenarioValue)
    if (scenario) {
      setOptions((prev) => ({
        ...prev,
        lighting: scenario.settings.lighting,
        background: scenario.settings.background,
      }))
      setSelectedScenario(scenarioValue)
    }
  }

  const handleGenerate = async () => {
    if (items.length === 0) {
      toast({
        title: 'No items',
        description: 'Please add items to the outfit first',
        variant: 'destructive',
      })
      return
    }

    setIsGenerating(true)
    setProgress(0)

    // Simulate progress for UX
    const progressInterval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 90) {
          clearInterval(progressInterval)
          return 90
        }
        return prev + 10
      })
    }, 300)

    try {
      // Convert items to API format
      const itemInputs = items.map((item) => ({
        name: item.name,
        category: item.category,
        colors: item.colors,
        brand: item.brand,
        material: item.material,
        pattern: item.pattern,
      }))

      const result = await generateOutfit(itemInputs, {
        style: options.style,
        background: options.background,
        pose: options.pose,
        include_model: options.includeModel,
        model_gender: options.modelGender,
        lighting: options.lighting,
        view_angle: options.viewAngle,
        custom_prompt: customPrompt || undefined,
      })

      clearInterval(progressInterval)
      setProgress(100)

      // Convert base64 to data URL if needed
      const imageUrl = result.image_url || `data:image/png;base64,${result.image_base64}`

      const newImage: GeneratedImage = {
        url: imageUrl,
        prompt: customPrompt || result.prompt,
        options: { ...options },
        timestamp: Date.now(),
      }

      setGeneratedImages((prev) => [newImage, ...prev])
      setSelectedImage(newImage)

      toast({
        title: 'Image generated!',
        description: 'Your outfit has been visualized',
      })

      onGenerated?.(newImage.url, { prompt: newImage.prompt, options: newImage.options })
    } catch (err) {
      toast({
        title: 'Generation failed',
        description: err instanceof Error ? err.message : 'Failed to generate image',
        variant: 'destructive',
      })
    } finally {
      setIsGenerating(false)
      setProgress(0)
    }
  }

  const handleRegenerate = () => {
    if (selectedImage) {
      setOptions(selectedImage.options)
      setCustomPrompt(selectedImage.prompt)
    }
    handleGenerate()
  }

  const handleGenerateMultiPose = async () => {
    if (items.length === 0) {
      toast({
        title: 'No items',
        description: 'Please add items to the outfit first',
        variant: 'destructive',
      })
      return
    }

    setIsGeneratingMultiPose(true)
    setProgress(0)
    setMultiPoseImages([])

    // Simulate progress for UX
    const progressInterval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 90) {
          clearInterval(progressInterval)
          return 90
        }
        return prev + 5
      })
    }, 500)

    try {
      // Convert items to API format
      const itemInputs = items.map((item) => ({
        name: item.name,
        category: item.category,
        colors: item.colors,
        brand: item.brand,
        material: item.material,
        pattern: item.pattern,
      }))

      // Generate front, side, and back views
      const poses: PosePreset[] = ['front', 'side', 'back']
      const result = await generateMultiPoseOutfit(itemInputs, poses, {
        style: options.style,
        background: options.background,
        include_model: options.includeModel,
        model_gender: options.modelGender,
        lighting: options.lighting,
        custom_prompt: customPrompt || undefined,
      })

      clearInterval(progressInterval)
      setProgress(100)

      // Convert results to GeneratedImage format
      const newImages: GeneratedImage[] = result.poses.map((pose) => {
        const imageUrl = pose.image_url || `data:image/png;base64,${pose.image_base64}`
        return {
          url: imageUrl,
          prompt: pose.prompt,
          options: { ...options, pose: pose.pose || '', viewAngle: pose.view_angle || '' },
          timestamp: Date.now() + Math.random() * 1000,
        }
      })

      setMultiPoseImages(newImages)
      setGeneratedImages((prev) => [...newImages, ...prev])
      if (newImages.length > 0) {
        setSelectedImage(newImages[0])
      }

      toast({
        title: 'Multi-pose generation complete!',
        description: `Generated ${result.total_generated} views${result.failed_poses.length > 0 ? ` (${result.failed_poses.length} failed)` : ''}`,
      })

      if (newImages.length > 0) {
        onGenerated?.(newImages[0].url, { prompt: newImages[0].prompt, options: newImages[0].options, multiPose: true })
      }
    } catch (err) {
      toast({
        title: 'Multi-pose generation failed',
        description: err instanceof Error ? err.message : 'Failed to generate images',
        variant: 'destructive',
      })
    } finally {
      setIsGeneratingMultiPose(false)
      setProgress(0)
    }
  }

  const handleDownload = (imageUrl: string, filename: string) => {
    const link = document.createElement('a')
    link.href = imageUrl
    link.download = filename
    link.click()
  }

  // ============================================================================
  // BUILD PROMPT PREVIEW
  // ============================================================================

  const buildPromptPreview = () => {
    const itemDescriptions = items.map((item) => {
      const parts = [item.name]
      if (item.colors.length) parts.push(item.colors.join(' & '))
      if (item.brand) parts.push(`by ${item.brand}`)
      return parts.join(' ')
    })

    const outfitDesc = `A ${options.style} outfit featuring: ${itemDescriptions.join(', ')}`
    const settings = [
      options.background,
      options.lighting,
      options.pose,
      options.viewAngle,
    ].filter(Boolean).join(', ')

    return `${outfitDesc}. ${settings}. ${options.includeModel ? `Worn by a ${options.modelGender} model` : 'Flat lay'}. High fashion photography.`
  }

  // ============================================================================
  // RENDER
  // ============================================================================

  const promptPreview = buildPromptPreview()

  return (
    <div className="flex flex-col lg:flex-row gap-6">
      {/* Left panel - Options */}
      <div className="w-full lg:w-96 space-y-4">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center justify-between gap-3">
              <span className="flex items-center gap-2">
                <Wand2 className="h-5 w-5 text-indigo-500" />
                AI Image Generator
              </span>
              {onClose && (
                <Button variant="outline" size="sm" onClick={onClose}>
                  Close
                </Button>
              )}
            </CardTitle>
            <CardDescription>
              Generate stunning visuals of your outfits using AI
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Quick style presets */}
            <div>
              <Label>Style Preset</Label>
              <div className="grid grid-cols-2 gap-2 mt-2">
                {STYLE_PRESETS.map((preset) => (
                  <button
                    key={preset.value}
                    onClick={() => setOptions((prev) => ({ ...prev, style: preset.value }))}
                    className={`p-3 rounded-lg border text-left transition-all ${
                      options.style === preset.value
                        ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20'
                        : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                    }`}
                  >
                    <p className="font-medium text-sm text-gray-900 dark:text-white">{preset.label}</p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">{preset.description}</p>
                  </button>
                ))}
              </div>
            </div>

            {/* Background selection */}
            <div>
              <Label>Background</Label>
              <div className="grid grid-cols-4 gap-2 mt-2">
                {BACKGROUND_OPTIONS.map((bg) => (
                  <button
                    key={bg.value}
                    onClick={() => setOptions((prev) => ({ ...prev, background: bg.value }))}
                    className={`aspect-square rounded-lg border-2 overflow-hidden transition-all ${
                      options.background === bg.value
                        ? 'border-indigo-500 ring-2 ring-indigo-200 dark:ring-indigo-800'
                        : 'border-gray-200 dark:border-gray-700'
                    }`}
                    title={bg.label}
                  >
                    <div
                      className="w-full h-full"
                      style={{ background: bg.color }}
                    />
                  </button>
                ))}
              </div>
            </div>

            {/* Lighting Scenarios */}
            <div>
              <Label className="flex items-center gap-2">
                <Sun className="h-4 w-4 text-yellow-500" />
                Lighting Scenario
              </Label>
              <p className="text-xs text-gray-500 dark:text-gray-400 mb-2">
                Quick presets for different environments
              </p>
              <div className="grid grid-cols-4 gap-2">
                {LIGHTING_SCENARIOS.map((scenario) => (
                  <button
                    key={scenario.value}
                    onClick={() => handleApplyScenario(scenario.value)}
                    className={`p-2 rounded-lg border text-center transition-all ${
                      selectedScenario === scenario.value
                        ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20'
                        : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                    }`}
                    title={scenario.description}
                  >
                    <span className="text-lg block">{scenario.icon}</span>
                    <span className="text-xs font-medium text-gray-700 dark:text-gray-300 block mt-1">
                      {scenario.label}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Toggle switches */}
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <Label htmlFor="include-model">Include Model</Label>
                <Switch
                  id="include-model"
                  checked={options.includeModel}
                  onCheckedChange={(checked) =>
                    setOptions((prev) => ({ ...prev, includeModel: checked }))
                  }
                />
              </div>

              {options.includeModel && (
                <div className="pl-4 space-y-3">
                  <div>
                    <Label>Model Gender</Label>
                    <Select
                      value={options.modelGender}
                      onValueChange={(value) =>
                        setOptions((prev) => ({
                          ...prev,
                          modelGender: value as GenerationOptions['modelGender'],
                        }))
                      }
                    >
                      <SelectTrigger className="mt-1">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="female">Female</SelectItem>
                        <SelectItem value="male">Male</SelectItem>
                        <SelectItem value="non-binary">Non-binary</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              )}
            </div>

            {/* Advanced toggle */}
            <Button
              variant="outline"
              className="w-full"
              onClick={() => setAdvancedMode(!advancedMode)}
            >
              <Settings className="h-4 w-4 mr-2" />
              {advancedMode ? 'Hide' : 'Show'} Advanced Options
            </Button>

            {advancedMode && (
              <div className="space-y-4 pt-4 border-t dark:border-gray-700">
                <div>
                  <Label>Pose</Label>
                  <Select
                    value={options.pose}
                    onValueChange={(value) =>
                      setOptions((prev) => ({ ...prev, pose: value }))
                    }
                  >
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {POSE_OPTIONS.map((pose) => (
                        <SelectItem key={pose.value} value={pose.value}>
                          {pose.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>Lighting</Label>
                  <Select
                    value={options.lighting}
                    onValueChange={(value) =>
                      setOptions((prev) => ({ ...prev, lighting: value }))
                    }
                  >
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {LIGHTING_OPTIONS.map((light) => (
                        <SelectItem key={light.value} value={light.value}>
                          {light.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>View Angle</Label>
                  <Select
                    value={options.viewAngle}
                    onValueChange={(value) =>
                      setOptions((prev) => ({ ...prev, viewAngle: value }))
                    }
                  >
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {VIEW_ANGLE_OPTIONS.map((angle) => (
                        <SelectItem key={angle.value} value={angle.value}>
                          {angle.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
            )}

            {/* Custom prompt */}
            <div>
              <Label htmlFor="custom-prompt">Custom Prompt (Optional)</Label>
              <Textarea
                id="custom-prompt"
                value={customPrompt}
                onChange={(e) => setCustomPrompt(e.target.value)}
                placeholder="Add any additional details you want in the generated image..."
                rows={3}
              />
              <p className="mt-2 text-xs text-gray-500 dark:text-gray-400 line-clamp-3">
                <span className="font-medium">Prompt preview:</span> {promptPreview}
              </p>
            </div>

            {/* Generate buttons */}
            <div className="space-y-2">
              <Button
                className="w-full"
                size="lg"
                onClick={handleGenerate}
                disabled={isGenerating || isGeneratingMultiPose || items.length === 0}
              >
                {isGenerating ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Generating...
                  </>
                ) : (
                  <>
                    <Wand2 className="h-4 w-4 mr-2" />
                    Generate Image
                  </>
                )}
              </Button>

              <Button
                className="w-full"
                variant="outline"
                size="lg"
                onClick={handleGenerateMultiPose}
                disabled={isGenerating || isGeneratingMultiPose || items.length === 0}
              >
                {isGeneratingMultiPose ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Generating All Angles...
                  </>
                ) : (
                  <>
                    <LayoutGrid className="h-4 w-4 mr-2" />
                    Generate All Angles (Front, Side, Back)
                  </>
                )}
              </Button>
            </div>

            {(isGenerating || isGeneratingMultiPose) && (
              <div className="space-y-2">
                <Progress value={progress} />
                <p className="text-xs text-center text-gray-500 dark:text-gray-400">
                  Creating your masterpiece...
                </p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Right panel - Preview & Gallery */}
      <div className="flex-1 space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>Preview</CardTitle>
          </CardHeader>
          <CardContent>
            {selectedImage ? (
              <div className="space-y-4">
                <div className="aspect-video rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-700">
                  <ZoomableImage
                    src={selectedImage.url}
                    alt="Generated outfit"
                    className="w-full h-full object-cover"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline">{selectedImage.options.style}</Badge>
                    <Badge variant="outline">{selectedImage.options.background}</Badge>
                  </div>
                  <div className="flex items-center gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={handleRegenerate}
                      disabled={isGenerating}
                    >
                      <RefreshCw className="h-4 w-4 mr-2" />
                      Regenerate
                    </Button>
                    <Button
                      size="sm"
                      onClick={() =>
                        handleDownload(
                          selectedImage.url,
                          `outfit-${Date.now()}.png`
                        )
                      }
                    >
                      <Download className="h-4 w-4 mr-2" />
                      Download
                    </Button>
                  </div>
                </div>

                {selectedImage.prompt && (
                  <div className="p-3 bg-gray-100 dark:bg-gray-800 rounded-lg">
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      <span className="font-medium">Prompt:</span> {selectedImage.prompt}
                    </p>
                  </div>
                )}
              </div>
            ) : (
              <div className="aspect-video rounded-lg bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
                <div className="text-center text-gray-400">
                  <ImageIcon className="h-16 w-16 mx-auto mb-4 opacity-50" />
                  <p>Your generated image will appear here</p>
                  <p className="text-sm mt-2">
                    {items.length === 0
                      ? 'Add items to your outfit first'
                      : 'Configure options and click Generate'}
                  </p>
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Multi-Pose Gallery */}
        {multiPoseImages.length > 0 && (
          <Card className="border-indigo-200 dark:border-indigo-800">
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                <LayoutGrid className="h-5 w-5 text-indigo-500" />
                All Angles View
              </CardTitle>
              <CardDescription>
                Click to view each angle in detail
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-3">
                {multiPoseImages.map((img, index) => {
                  const angleLabels = ['Front', 'Side', 'Back']
                  return (
                    <button
                      key={img.timestamp}
                      onClick={() => setSelectedImage(img)}
                      className={`relative aspect-[3/4] rounded-lg overflow-hidden border-2 transition-all ${
                        selectedImage?.timestamp === img.timestamp
                          ? 'border-indigo-500 ring-2 ring-indigo-200 dark:ring-indigo-800'
                          : 'border-gray-200 dark:border-gray-700 hover:border-gray-300'
                      }`}
                    >
                      <ZoomableImage
                        src={img.url}
                        alt={`Outfit ${angleLabels[index] || 'view'}`}
                        className="w-full h-full object-cover"
                      />
                      <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-2">
                        <span className="text-white text-sm font-medium">
                          {angleLabels[index] || `View ${index + 1}`}
                        </span>
                      </div>
                    </button>
                  )
                })}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Gallery */}
        {generatedImages.length > 1 && (
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Recent Generations</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-4 gap-2">
                {generatedImages.map((img) => (
                  <button
                    key={img.timestamp}
                    onClick={() => setSelectedImage(img)}
                    className={`aspect-square rounded-lg overflow-hidden border-2 ${
                      selectedImage?.timestamp === img.timestamp
                        ? 'border-indigo-500'
                        : 'border-gray-200 dark:border-gray-700'
                    }`}
                  >
                    <img
                      src={img.url}
                      alt="Generated outfit"
                      className="w-full h-full object-cover"
                    />
                  </button>
                ))}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Items in outfit */}
        {items.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Items in Outfit ({items.length})</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex flex-wrap gap-2">
                {items.map((item) => (
                  <Badge key={item.id} variant="secondary" className="gap-1">
                    {item.name}
                    <Check className="h-3 w-3 text-green-500" />
                  </Badge>
                ))}
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  )
}

export default AIGenerator
