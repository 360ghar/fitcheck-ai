/**
 * Demo API client for landing page features.
 *
 * No authentication required - uses IP-based rate limiting.
 * Separate from main apiClient to avoid auth interceptors.
 */

import axios, { AxiosError } from 'axios';

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  import.meta.env.VITE_API_URL ||
  'http://localhost:8000';

// Create a separate axios instance for demo (no auth interceptors)
const demoClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 120000, // 2 minutes for AI operations
  headers: {
    'Content-Type': 'application/json',
  },
});

// =============================================================================
// TYPES
// =============================================================================

export interface DemoDetectedItem {
  category: string;
  sub_category?: string;
  colors: string[];
  material?: string;
  pattern?: string;
  confidence: number;
  detailed_description?: string;
}

export interface DemoExtractItemsResult {
  items: DemoDetectedItem[];
  overall_confidence: number;
  image_description: string;
  item_count: number;
}

export interface DemoTryOnResult {
  image_base64: string;
  prompt: string;
}

export interface DemoPhotoshootResult {
  session_id: string;
  status: 'pending' | 'generating' | 'complete' | 'failed';
  images: Array<{
    id: string;
    index: number;
    image_url?: string;
    image_base64?: string;
  }>;
  generated_count?: number;
  failed_count?: number;
  image_failures?: Array<{ index: number; error: string }>;
  partial_success?: boolean;
  remaining_today: number;
  signup_cta: string;
}

export interface DemoApiError {
  message: string;
  code?: string;
  isRateLimit: boolean;
}

// =============================================================================
// HELPERS
// =============================================================================

/**
 * Convert a File to base64 string (without data URL prefix).
 */
async function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
      const result = reader.result as string;
      // Remove the data URL prefix (e.g., "data:image/jpeg;base64,")
      const base64 = result.includes(',') ? result.split(',')[1] : result;
      resolve(base64);
    };
    reader.onerror = (error) => reject(error);
  });
}

/**
 * Extract a normalized error from axios error.
 */
function getDemoError(error: unknown): DemoApiError {
  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError<{
      error?: string;
      message?: string;
      code?: string;
    }>;
    const status = axiosError.response?.status;
    const data = axiosError.response?.data;

    return {
      message:
        data?.error ||
        data?.message ||
        axiosError.message ||
        'An error occurred',
      code: data?.code,
      isRateLimit: status === 429,
    };
  }

  if (error instanceof Error) {
    return { message: error.message, isRateLimit: false };
  }

  return { message: 'An unknown error occurred', isRateLimit: false };
}

// =============================================================================
// API FUNCTIONS
// =============================================================================

/**
 * Extract clothing items from an image (demo mode).
 *
 * @param imageFile - The image file to analyze
 * @returns Extracted items with details
 * @throws DemoApiError on failure
 */
export async function demoExtractItems(
  imageFile: File
): Promise<DemoExtractItemsResult> {
  try {
    const imageBase64 = await fileToBase64(imageFile);

    const response = await demoClient.post<{ data: DemoExtractItemsResult }>(
      '/api/v1/demo/extract-items',
      { image: imageBase64 }
    );

    return response.data.data;
  } catch (error) {
    throw getDemoError(error);
  }
}

/**
 * Generate a virtual try-on image (demo mode).
 *
 * @param personImage - The person's photo
 * @param clothingImage - The clothing/outfit photo
 * @param clothingDescription - Optional description of the clothing
 * @param style - Style preference (casual, formal, etc.)
 * @returns Generated try-on image in base64
 * @throws DemoApiError on failure
 */
export async function demoTryOn(
  personImage: File,
  clothingImage: File,
  clothingDescription?: string,
  style: string = 'casual'
): Promise<DemoTryOnResult> {
  try {
    const [personBase64, clothingBase64] = await Promise.all([
      fileToBase64(personImage),
      fileToBase64(clothingImage),
    ]);

    const response = await demoClient.post<{ data: DemoTryOnResult }>(
      '/api/v1/demo/try-on',
      {
        person_image: personBase64,
        clothing_image: clothingBase64,
        clothing_description: clothingDescription,
        style,
      }
    );

    return response.data.data;
  } catch (error) {
    throw getDemoError(error);
  }
}

/**
 * Generate a demo photoshoot (2 images for anonymous users).
 *
 * @param photo - Single photo file for the demo
 * @param useCase - Optional use case for the photoshoot (defaults to aesthetic on backend)
 * @returns Generated images
 * @throws DemoApiError on failure
 */
export async function demoPhotoshoot(
  photo: File,
  useCase?: 'linkedin' | 'dating_app' | 'model_portfolio' | 'instagram' | 'aesthetic'
): Promise<DemoPhotoshootResult> {
  try {
    const photoBase64 = await fileToBase64(photo);

    const response = await demoClient.post<{ data: DemoPhotoshootResult }>(
      '/api/v1/photoshoot/demo',
      {
        photo: photoBase64,
        ...(useCase && { use_case: useCase }),
      }
    );

    return response.data.data;
  } catch (error) {
    throw getDemoError(error);
  }
}
