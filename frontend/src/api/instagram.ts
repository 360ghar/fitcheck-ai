/**
 * Instagram Import API client.
 *
 * Provides functions for Instagram URL validation, scraping, and batch preparation.
 */

import { apiClient, getAccessToken } from './client';

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  import.meta.env.VITE_API_URL ||
  'http://localhost:8000';

// =============================================================================
// TYPES
// =============================================================================

export type InstagramURLType = 'profile' | 'post' | 'reel';

export interface InstagramURLValidation {
  valid: boolean;
  url_type?: InstagramURLType;
  identifier?: string;
  error?: string;
}

export interface InstagramProfileInfo {
  username: string;
  is_public: boolean;
  post_count: number;
  profile_pic_url?: string;
  full_name?: string;
  bio?: string;
  error?: string;
}

export interface InstagramImageMeta {
  image_id: string;
  image_url: string;
  thumbnail_url?: string;
  post_shortcode: string;
  post_url: string;
  caption?: string;
  timestamp?: string;
  is_video: boolean;
  width?: number;
  height?: number;
}

export interface InstagramScrapeJobResponse {
  job_id: string;
  status: string;
  url_type: InstagramURLType;
  identifier: string;
  sse_url: string;
  message: string;
}

export interface InstagramScrapeImagesResponse {
  images: InstagramImageMeta[];
  total: number;
  offset: number;
  limit: number;
  has_more: boolean;
}

export interface InstagramBatchResponse {
  batch_job_id: string;
  sse_url: string;
  image_count: number;
  message: string;
}

// SSE Event Data Types
export interface InstagramScrapeProgressData {
  scraped: number;
  total: number;
  images: InstagramImageMeta[];
  timestamp: string;
}

export interface InstagramScrapeCompleteData {
  job_id: string;
  total_images: number;
  has_more: boolean;
  timestamp: string;
}

// Authentication Types
export interface InstagramLoginResponse {
  success: boolean;
  username?: string;
  error?: string;
}

export interface InstagramCredentialsStatus {
  has_credentials: boolean;
  is_valid: boolean;
  username?: string;
  last_used?: string;
}

export interface InstagramEnsureSessionResponse {
  success: boolean;
  message?: string;
  error?: string;
}

// =============================================================================
// API FUNCTIONS
// =============================================================================

/**
 * Validate an Instagram URL.
 *
 * @param url - Instagram URL to validate
 * @returns Validation result with URL type and identifier
 */
export async function validateInstagramUrl(url: string): Promise<InstagramURLValidation> {
  const response = await apiClient.post<InstagramURLValidation>(
    '/api/v1/instagram/validate-url',
    { url }
  );
  return response.data;
}

/**
 * Check if an Instagram profile is public and get basic info.
 *
 * @param username - Instagram username
 * @returns Profile info including post count
 */
export async function checkInstagramProfile(
  username: string
): Promise<InstagramProfileInfo> {
  const response = await apiClient.post<InstagramProfileInfo>(
    '/api/v1/instagram/check-profile',
    { username }
  );
  return response.data;
}

/**
 * Start scraping images from an Instagram URL.
 *
 * @param url - Instagram URL (profile or post)
 * @param maxPosts - Maximum posts to scrape for profiles
 * @returns Job response with SSE URL
 */
export async function startInstagramScrape(
  url: string,
  maxPosts: number = 200
): Promise<InstagramScrapeJobResponse> {
  const response = await apiClient.post<InstagramScrapeJobResponse>(
    '/api/v1/instagram/scrape',
    { url, max_posts: maxPosts }
  );
  return response.data;
}

/**
 * Cancel a running Instagram scrape job.
 *
 * @param jobId - The job ID to cancel
 */
export async function cancelInstagramScrape(jobId: string): Promise<void> {
  await apiClient.post(`/api/v1/instagram/scrape/${jobId}/cancel`);
}

/**
 * Get paginated list of scraped images.
 *
 * @param jobId - The job ID
 * @param offset - Pagination offset
 * @param limit - Number of images to fetch
 * @returns Paginated images
 */
export async function getScrapedImages(
  jobId: string,
  offset: number = 0,
  limit: number = 50
): Promise<InstagramScrapeImagesResponse> {
  const response = await apiClient.get<InstagramScrapeImagesResponse>(
    `/api/v1/instagram/scrape/${jobId}/images`,
    { params: { offset, limit } }
  );
  return response.data;
}

/**
 * Prepare selected Instagram images for batch extraction.
 *
 * Downloads images and starts a batch extraction job.
 *
 * @param jobId - Instagram scrape job ID
 * @param selectedImageIds - Array of image IDs to process
 * @returns Batch job response with SSE URL
 */
export async function prepareBatchFromInstagram(
  jobId: string,
  selectedImageIds: string[]
): Promise<InstagramBatchResponse> {
  const response = await apiClient.post<InstagramBatchResponse>(
    '/api/v1/instagram/prepare-batch',
    { job_id: jobId, selected_image_ids: selectedImageIds }
  );
  return response.data;
}

// =============================================================================
// SSE CONNECTION
// =============================================================================

/**
 * Create an authenticated SSE connection for Instagram scraping progress.
 *
 * @param jobId - The job ID to connect to
 * @param onMessage - Callback for each SSE message
 * @param onError - Callback for errors
 * @returns Abort function to close the connection
 */
export function createInstagramSSEConnection(
  jobId: string,
  onMessage: (event: { type: string; data: unknown }) => void,
  onError?: (error: Error) => void
): () => void {
  const controller = new AbortController();
  const token = getAccessToken();
  const url = `${API_BASE_URL}/api/v1/instagram/scrape/${jobId}/events`;

  const connect = async () => {
    try {
      const response = await fetch(url, {
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: 'text/event-stream',
        },
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new Error(`SSE connection failed: ${response.status}`);
      }

      const reader = response.body?.getReader();
      if (!reader) {
        throw new Error('No response body');
      }

      const decoder = new TextDecoder();
      let buffer = '';
      let currentEvent = '';
      let dataLines: string[] = [];

      const dispatchEvent = () => {
        if (!currentEvent && dataLines.length === 0) return;

        const payload = dataLines.join('\n');
        const eventType = currentEvent || 'message';

        if (payload) {
          try {
            const parsed = JSON.parse(payload);
            onMessage({ type: eventType, data: parsed });
          } catch {
            onMessage({ type: eventType, data: payload });
          }
        } else {
          onMessage({ type: eventType, data: null });
        }

        currentEvent = '';
        dataLines = [];
      };

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const rawLine of lines) {
          const line = rawLine.replace(/\r$/, '');

          if (line.startsWith('event:')) {
            currentEvent = line.slice(6).trim();
            continue;
          }

          if (line.startsWith('data:')) {
            dataLines.push(line.slice(5).trimStart());
            continue;
          }

          if (line === '') {
            dispatchEvent();
          }
        }
      }

      dispatchEvent();
    } catch (error) {
      if ((error as Error).name !== 'AbortError') {
        onError?.(error as Error);
      }
    }
  };

  connect();

  return () => {
    controller.abort();
  };
}

// =============================================================================
// AUTHENTICATION
// =============================================================================

/**
 * Login to Instagram with username and password.
 *
 * Credentials are encrypted and stored server-side for future use.
 *
 * @param username - Instagram username
 * @param password - Instagram password
 * @returns Login response
 */
export async function loginInstagram(
  username: string,
  password: string
): Promise<InstagramLoginResponse> {
  const response = await apiClient.post<InstagramLoginResponse>(
    '/api/v1/instagram/login',
    { username, password }
  );
  return response.data;
}

/**
 * Logout from Instagram and delete stored credentials.
 */
export async function logoutInstagram(): Promise<void> {
  await apiClient.post('/api/v1/instagram/logout');
}

/**
 * Get status of stored Instagram credentials.
 *
 * @returns Credentials status
 */
export async function getInstagramCredentialsStatus(): Promise<InstagramCredentialsStatus> {
  const response = await apiClient.get<InstagramCredentialsStatus>(
    '/api/v1/instagram/credentials-status'
  );
  return response.data;
}

/**
 * Ensure Instagram session is active.
 *
 * Attempts to restore session or re-login using stored credentials.
 *
 * @returns Session status
 */
export async function ensureInstagramSession(): Promise<InstagramEnsureSessionResponse> {
  const response = await apiClient.post<InstagramEnsureSessionResponse>(
    '/api/v1/instagram/ensure-session'
  );
  return response.data;
}
