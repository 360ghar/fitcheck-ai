/**
 * AI API client for item extraction and image generation.
 *
 * All AI processing is done server-side using configurable providers.
 */

import { apiClient } from './client';

// =============================================================================
// TYPES
// =============================================================================

export interface BoundingBox {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface DetectedItem {
  temp_id: string;
  person_id?: string;
  person_label?: string;
  is_current_user_person?: boolean;
  include_in_wardrobe?: boolean;
  category: string;
  sub_category?: string;
  colors: string[];
  material?: string;
  pattern?: string;
  brand?: string;
  confidence: number;
  bounding_box?: BoundingBox;
  detailed_description?: string;
  status: string;
}

export interface ExtractItemsResult {
  items: DetectedItem[];
  people?: Array<{
    person_id: string;
    person_label: string;
    is_current_user_person: boolean;
    confidence: number;
  }>;
  overall_confidence: number;
  image_description: string;
  item_count: number;
  requires_review: boolean;
  has_profile_reference?: boolean;
  profile_match_found?: boolean;
}

export interface ExtractSingleItemResult {
  category: string;
  sub_category?: string;
  colors: string[];
  material?: string;
  pattern?: string;
  brand?: string;
  confidence: number;
  description?: string;
}

export interface OutfitItemInput {
  name: string;
  category?: string;
  colors?: string[];
  brand?: string;
  material?: string;
  pattern?: string;
}

export interface GenerateOutfitOptions {
  style?: string;
  background?: string;
  pose?: string;
  lighting?: string;
  view_angle?: string;
  include_model?: boolean;
  model_gender?: string;
  custom_prompt?: string;
  save_to_storage?: boolean;
  include_user_face?: boolean;  // Use avatar for face consistency when available
  use_body_profile?: boolean;   // Use body profile data if available
}

export interface GeneratedOutfit {
  image_base64: string;
  image_url?: string;
  storage_path?: string;
  prompt: string;
  model: string;
  provider: string;
  view_angle?: string;
  pose?: string;
}

export interface MultiPoseOutfitResult {
  poses: GeneratedOutfit[];
  total_generated: number;
  failed_poses: string[];
}

export interface GenerateProductImageOptions {
  item_description: string;
  category: string;
  sub_category?: string;
  colors?: string[];
  material?: string;
  background?: string;
  view_angle?: string;
  include_shadows?: boolean;
  save_to_storage?: boolean;
}

export interface GeneratedProductImage {
  image_base64: string;
  image_url?: string;
  storage_path?: string;
  prompt: string;
  model: string;
  provider: string;
}

// Try-On Types
export interface TryOnOptions {
  clothing_description?: string;
  style?: string;
  background?: string;
  pose?: string;
  lighting?: string;
  save_to_storage?: boolean;
}

export interface TryOnResult {
  image_base64: string;
  image_url?: string;
  storage_path?: string;
  prompt: string;
  model: string;
  provider: string;
}

// AI Settings Types
export interface ProviderConfigInput {
  api_url?: string;
  api_key?: string;
  model?: string;
  vision_model?: string;
  image_gen_model?: string;
  embedding_model?: string;
}

export interface ProviderConfigDisplay {
  api_url: string;
  model: string;
  vision_model: string;
  image_gen_model: string;
  embedding_model: string;
  api_key_set: boolean;
}

export interface AISettings {
  default_provider: string;
  provider_configs: Record<string, ProviderConfigDisplay>;
  usage?: UsageStats;
}

export interface UsageStats {
  daily: {
    extractions: number;
    generations: number;
    embeddings: number;
  };
  total: {
    extractions: number;
    generations: number;
    embeddings: number;
  };
  limits: {
    daily_extractions: number;
    daily_generations: number;
    daily_embeddings: number;
  };
  remaining: {
    extractions: number;
    generations: number;
    embeddings: number;
  };
}

export interface TestProviderResult {
  success: boolean;
  message: string;
  model?: string;
  response?: string;
}

export interface RateLimitCheck {
  allowed: boolean;
  current_count: number;
  limit: number;
  remaining: number;
}

export interface AvailableModels {
  gemini: Record<string, string[]>;
  openai: Record<string, string[]>;
  custom: Record<string, string[]>;
}

// =============================================================================
// EMBEDDING TYPES
// =============================================================================

export interface EmbeddingRequest {
  text: string;
  model?: string;
}

export interface EmbeddingResult {
  embedding: number[];
  model: string;
  dimensions: number;
  provider: string;
}

export interface BatchEmbeddingRequest {
  texts: string[];
  model?: string;
}

export interface BatchEmbeddingResult {
  embeddings: number[][];
  model: string;
  dimensions: number;
  provider: string;
  count: number;
}

export interface SimilaritySearchRequest {
  text?: string;
  embedding?: number[];
  category?: string;
  colors?: string[];
  top_k?: number;
  min_score?: number;
}

export interface SimilarItem {
  item_id: string;
  score: number;
  metadata: Record<string, unknown>;
}

export interface SimilaritySearchResult {
  items: SimilarItem[];
  query_embedding_dimensions: number;
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/**
 * Convert a File to base64 string.
 */
export async function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
      const result = reader.result as string;
      // Remove data URL prefix if present
      const base64 = result.includes(',') ? result.split(',')[1] : result;
      resolve(base64);
    };
    reader.onerror = (error) => reject(error);
  });
}

// =============================================================================
// ITEM EXTRACTION
// =============================================================================

/**
 * Extract multiple items from an image.
 */
export async function extractItems(imageFile: File): Promise<ExtractItemsResult> {
  const imageBase64 = await fileToBase64(imageFile);

  const response = await apiClient.post<{ data: ExtractItemsResult }>('/api/v1/ai/extract-items', {
    image: imageBase64,
  });

  return response.data.data;
}

/**
 * Extract multiple items from a base64 image.
 */
export async function extractItemsFromBase64(imageBase64: string): Promise<ExtractItemsResult> {
  const response = await apiClient.post<{ data: ExtractItemsResult }>('/api/v1/ai/extract-items', {
    image: imageBase64,
  });

  return response.data.data;
}

/**
 * Extract a single item from an image.
 */
export async function extractSingleItem(
  imageFile: File,
  categoryHint?: string
): Promise<ExtractSingleItemResult> {
  const imageBase64 = await fileToBase64(imageFile);

  const response = await apiClient.post<{ data: ExtractSingleItemResult }>(
    '/api/v1/ai/extract-single-item',
    {
      image: imageBase64,
      category_hint: categoryHint,
    }
  );

  return response.data.data;
}

// =============================================================================
// IMAGE GENERATION
// =============================================================================

/**
 * Generate an outfit visualization image.
 */
export async function generateOutfit(
  items: OutfitItemInput[],
  options: GenerateOutfitOptions = {}
): Promise<GeneratedOutfit> {
  const response = await apiClient.post<{ data: GeneratedOutfit }>('/api/v1/ai/generate-outfit', {
    items,
    style: options.style ?? 'casual',
    background: options.background ?? 'studio white',
    pose: options.pose ?? 'standing front',
    lighting: options.lighting ?? 'professional studio lighting',
    view_angle: options.view_angle ?? 'full body',
    include_model: options.include_model ?? true,
    model_gender: options.model_gender ?? 'female',
    custom_prompt: options.custom_prompt,
    save_to_storage: options.save_to_storage ?? false,
    include_user_face: options.include_user_face ?? true,
    use_body_profile: options.use_body_profile ?? true,
  });

  return response.data.data;
}

/**
 * Available pose presets for multi-pose generation.
 */
export const POSE_PRESETS = {
  front: { pose: 'standing front', view_angle: 'full body front view' },
  side: { pose: 'standing side profile', view_angle: 'full body side view' },
  back: { pose: 'standing back view', view_angle: 'full body back view' },
  'three-quarter': { pose: 'standing three-quarter angle', view_angle: 'full body 3/4 view' },
  seated: { pose: 'seated relaxed', view_angle: 'full body seated view' },
  walking: { pose: 'walking casual', view_angle: 'full body action shot' },
} as const;

export type PosePreset = keyof typeof POSE_PRESETS;

/**
 * Generate outfit visualization from multiple angles/poses.
 *
 * Generates the outfit from multiple viewing angles in parallel for
 * a comprehensive visualization.
 */
export async function generateMultiPoseOutfit(
  items: OutfitItemInput[],
  poses: PosePreset[] = ['front', 'side', 'back'],
  options: Omit<GenerateOutfitOptions, 'pose' | 'view_angle'> = {}
): Promise<MultiPoseOutfitResult> {
  const results: GeneratedOutfit[] = [];
  const failedPoses: string[] = [];

  // Generate poses in parallel (limit to 3 at a time to avoid rate limits)
  const batchSize = 3;
  for (let i = 0; i < poses.length; i += batchSize) {
    const batch = poses.slice(i, i + batchSize);

    const batchResults = await Promise.allSettled(
      batch.map(async (posePreset) => {
        const presetConfig = POSE_PRESETS[posePreset];
        const result = await generateOutfit(items, {
          ...options,
          pose: presetConfig.pose,
          view_angle: presetConfig.view_angle,
        });
        return {
          ...result,
          view_angle: posePreset,
          pose: presetConfig.pose,
        };
      })
    );

    for (let j = 0; j < batchResults.length; j++) {
      const result = batchResults[j];
      if (result.status === 'fulfilled') {
        results.push(result.value);
      } else {
        failedPoses.push(batch[j]);
        console.error(`Failed to generate pose ${batch[j]}:`, result.reason);
      }
    }
  }

  return {
    poses: results,
    total_generated: results.length,
    failed_poses: failedPoses,
  };
}

/**
 * Generate a product image for a single item.
 */
export async function generateProductImage(
  options: GenerateProductImageOptions
): Promise<GeneratedProductImage> {
  const response = await apiClient.post<{ data: GeneratedProductImage }>(
    '/api/v1/ai/generate-product-image',
    {
      item_description: options.item_description,
      category: options.category,
      sub_category: options.sub_category,
      colors: options.colors ?? [],
      material: options.material,
      background: options.background ?? 'white',
      view_angle: options.view_angle ?? 'front',
      include_shadows: options.include_shadows ?? false,
      save_to_storage: options.save_to_storage ?? false,
    }
  );

  return response.data.data;
}

/**
 * Generate a try-on visualization.
 *
 * Uses the user's profile picture to show how they would look
 * wearing the uploaded clothing.
 *
 * @throws ApiError with code "AVATAR_REQUIRED" if user has no profile picture
 */
export async function generateTryOn(
  clothingImage: File,
  options: TryOnOptions = {}
): Promise<TryOnResult> {
  const clothingBase64 = await fileToBase64(clothingImage);

  const response = await apiClient.post<{ data: TryOnResult }>(
    '/api/v1/ai/try-on',
    {
      clothing_image: clothingBase64,
      clothing_description: options.clothing_description,
      style: options.style ?? 'casual',
      background: options.background ?? 'studio white',
      pose: options.pose ?? 'standing front',
      lighting: options.lighting ?? 'professional studio lighting',
      save_to_storage: options.save_to_storage ?? false,
    }
  );

  return response.data.data;
}

/**
 * Generate a try-on visualization from a base64 image.
 *
 * @throws ApiError with code "AVATAR_REQUIRED" if user has no profile picture
 */
export async function generateTryOnFromBase64(
  clothingBase64: string,
  options: TryOnOptions = {}
): Promise<TryOnResult> {
  const response = await apiClient.post<{ data: TryOnResult }>(
    '/api/v1/ai/try-on',
    {
      clothing_image: clothingBase64,
      clothing_description: options.clothing_description,
      style: options.style ?? 'casual',
      background: options.background ?? 'studio white',
      pose: options.pose ?? 'standing front',
      lighting: options.lighting ?? 'professional studio lighting',
      save_to_storage: options.save_to_storage ?? false,
    }
  );

  return response.data.data;
}

/**
 * Get available AI models by provider.
 */
export async function getAvailableModels(): Promise<AvailableModels> {
  const response = await apiClient.get<{ data: AvailableModels }>('/api/v1/ai/models');
  return response.data.data;
}

// =============================================================================
// AI SETTINGS
// =============================================================================

/**
 * Get AI settings for the current user.
 */
export async function getAISettings(): Promise<AISettings> {
  const response = await apiClient.get<{ data: AISettings }>('/api/v1/ai/settings');
  return response.data.data;
}

/**
 * Update AI settings for the current user.
 */
export async function updateAISettings(settings: {
  default_provider?: string;
  provider_configs?: Record<string, ProviderConfigInput>;
}): Promise<AISettings> {
  const response = await apiClient.put<{ data: AISettings }>('/api/v1/ai/settings', settings);
  return response.data.data;
}

/**
 * Test a provider configuration.
 */
export async function testProviderConfig(
  apiUrl: string,
  apiKey: string,
  model: string
): Promise<TestProviderResult> {
  const response = await apiClient.post<{ data: TestProviderResult }>('/api/v1/ai/settings/test', {
    api_url: apiUrl,
    api_key: apiKey,
    model,
  });
  return response.data.data;
}

/**
 * Get AI usage statistics.
 */
export async function getUsageStats(): Promise<UsageStats> {
  const response = await apiClient.get<{ data: UsageStats }>('/api/v1/ai/settings/usage');
  return response.data.data;
}

/**
 * Check rate limit for a specific operation.
 */
export async function checkRateLimit(
  operationType: 'extraction' | 'generation' | 'embedding'
): Promise<RateLimitCheck> {
  const response = await apiClient.get<{ data: RateLimitCheck }>(
    `/api/v1/ai/settings/rate-limit/${operationType}`
  );
  return response.data.data;
}

/**
 * Reset a provider configuration to defaults.
 */
export async function resetProviderConfig(provider: string): Promise<void> {
  await apiClient.post(`/api/v1/ai/settings/reset-provider/${provider}`);
}

// =============================================================================
// EMBEDDINGS API
// =============================================================================

/**
 * Generate an embedding for a single text.
 */
export async function generateEmbedding(text: string, model?: string): Promise<EmbeddingResult> {
  const response = await apiClient.post<{ data: EmbeddingResult }>('/api/v1/ai/embeddings', {
    text,
    model,
  });
  return response.data.data;
}

/**
 * Generate embeddings for multiple texts in batch.
 */
export async function generateBatchEmbeddings(
  texts: string[],
  model?: string
): Promise<BatchEmbeddingResult> {
  const response = await apiClient.post<{ data: BatchEmbeddingResult }>(
    '/api/v1/ai/embeddings/batch',
    {
      texts,
      model,
    }
  );
  return response.data.data;
}

/**
 * Search for similar items using text or embedding.
 */
export async function searchSimilarItems(
  request: SimilaritySearchRequest
): Promise<SimilaritySearchResult> {
  const response = await apiClient.post<{ data: SimilaritySearchResult }>(
    '/api/v1/ai/embeddings/search',
    request
  );
  return response.data.data;
}

/**
 * Test an embedding model configuration.
 */
export async function testEmbeddingModel(
  provider: string,
  model: string
): Promise<TestProviderResult> {
  const response = await apiClient.post<{ data: TestProviderResult }>(
    '/api/v1/ai/embeddings/test',
    {
      provider,
      model,
    }
  );
  return response.data.data;
}
