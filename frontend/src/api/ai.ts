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
  overall_confidence: number;
  image_description: string;
  item_count: number;
  requires_review: boolean;
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
}

export interface GeneratedOutfit {
  image_base64: string;
  image_url?: string;
  storage_path?: string;
  prompt: string;
  model: string;
  provider: string;
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
}

export interface ProviderConfigDisplay {
  api_url: string;
  model: string;
  vision_model: string;
  image_gen_model: string;
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
  };
  total: {
    extractions: number;
    generations: number;
  };
  limits: {
    daily_extractions: number;
    daily_generations: number;
  };
  remaining: {
    extractions: number;
    generations: number;
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
  });

  return response.data.data;
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
  operationType: 'extraction' | 'generation'
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
