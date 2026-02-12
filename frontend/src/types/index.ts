/**
 * Type definitions for FitCheck AI
 */

// ============================================================================
// COMMON TYPES
// ============================================================================

export type UUID = string;

export interface ApiEnvelope<T> {
  data: T;
  message?: string;
  meta?: Record<string, unknown>;
}

export interface ApiErrorEnvelope {
  error: string;
  code?: string;
  details?: unknown;
}

export interface PaginatedItemsResponse<T> {
  items: T[];
  total: number;
  page: number;
  total_pages: number;
  has_next: boolean;
  has_prev: boolean;
}

export interface PaginatedOutfitsResponse<T> {
  outfits: T[];
  total: number;
  page: number;
  total_pages: number;
  has_next: boolean;
  has_prev: boolean;
}

// ============================================================================
// ITEM TYPES
// ============================================================================

export type Category =
  | 'tops'
  | 'bottoms'
  | 'shoes'
  | 'accessories'
  | 'outerwear'
  | 'swimwear'
  | 'activewear'
  | 'other';

export type Condition = 'clean' | 'dirty' | 'laundry' | 'repair' | 'donate';

export type Style =
  | 'casual'
  | 'formal'
  | 'business'
  | 'sporty'
  | 'bohemian'
  | 'streetwear'
  | 'vintage'
  | 'minimalist'
  | 'romantic'
  | 'edgy'
  | 'preppy'
  | 'artsy'
  | 'other';

export type Season = 'spring' | 'summer' | 'fall' | 'winter' | 'all-season';

export interface ItemImage {
  id: UUID;
  item_id: UUID;
  image_url: string;
  thumbnail_url?: string;
  storage_path?: string;
  is_primary: boolean;
  width?: number;
  height?: number;
  created_at: string;
}

export interface Item {
  id: UUID;
  user_id: UUID;
  name: string;
  category: Category;
  sub_category?: string;
  brand?: string;
  colors: string[];
  style?: string;
  material?: string;
  materials: string[];
  pattern?: string;
  seasonal_tags: string[];
  occasion_tags: string[];
  size?: string;
  price?: number;
  /** @deprecated Use price instead. Alias for backward compatibility. */
  purchase_price?: number;
  purchase_date?: string;
  purchase_location?: string;
  tags: string[];
  notes?: string;
  condition: Condition;
  is_favorite: boolean;
  usage_times_worn: number;
  usage_last_worn?: string;
  cost_per_wear?: number;
  /** Season for the item (derived from seasonal_tags if needed) */
  season?: Season;
  created_at: string;
  updated_at: string;
  images: ItemImage[];
  /** Primary image URL (convenience accessor) */
  image_url?: string;
}

export interface ItemCreate {
  name: string;
  category: Category;
  sub_category?: string;
  brand?: string;
  colors: string[];
  style?: string;
  material?: string;
  materials?: string[];
  pattern?: string;
  seasonal_tags?: string[];
  occasion_tags?: string[];
  size?: string;
  price?: number;
  purchase_date?: string;
  purchase_location?: string;
  tags: string[];
  notes?: string;
  condition?: Condition;
  is_favorite?: boolean;
  images?: ItemImageBase[];
}

export interface ItemImageBase {
  image_url: string;
  thumbnail_url?: string;
  storage_path?: string;
  is_primary?: boolean;
  width?: number;
  height?: number;
}

export interface ExtractedItem {
  id: UUID;
  image_url?: string;
  category: Category;
  sub_category?: string;
  colors: string[];
  confidence: number;
  bounding_box?: Record<string, number>;
}

// ============================================================================
// OUTFIT TYPES
// ============================================================================

export interface OutfitImage {
  id: UUID;
  outfit_id: UUID;
  image_url: string;
  thumbnail_url?: string;
  storage_path?: string;
  pose: string;
  lighting?: string;
  body_profile_id?: UUID;
  generation_type: 'ai' | 'manual' | string;
  is_primary: boolean;
  width?: number;
  height?: number;
  generation_metadata?: Record<string, unknown>;
  created_at: string;
}

export interface Outfit {
  id: UUID;
  user_id: UUID;
  name: string;
  description?: string;
  item_ids: UUID[];
  /** Populated items (when joined/expanded) */
  items?: Item[];
  style?: string;
  season?: string;
  occasion?: string;
  tags: string[];
  is_favorite: boolean;
  is_draft: boolean;
  is_public: boolean;
  worn_count: number;
  last_worn_at?: string;
  created_at: string;
  updated_at: string;
  images: OutfitImage[];
}

export type GenerationStatus = 'pending' | 'processing' | 'completed' | 'failed';

export interface GenerationRequest {
  pose?: string;
  variations?: number;
  lighting?: string;
  body_profile_id?: UUID;
}

export interface GenerationResponse {
  generation_id: string;
  status: GenerationStatus | string;
  estimated_time?: number;
}

// ============================================================================
// USER TYPES
// ============================================================================

export type Gender = 'male' | 'female' | 'non_binary' | 'prefer_not_to_say';

export interface User {
  id: UUID;
  email: string;
  full_name?: string;
  avatar_url?: string;
  gender?: Gender | null;
  birth_date?: string | null;
  birth_time?: string | null;
  birth_place?: string | null;
  is_active: boolean;
  email_verified: boolean;
  created_at: string;
  updated_at?: string;
  last_login_at?: string;
}

export interface UserPreferences {
  user_id: UUID;
  favorite_colors: string[];
  preferred_styles: string[];
  liked_brands: string[];
  disliked_patterns: string[];
  preferred_occasions: string[];
  color_temperature?: string;
  style_personality?: string;
  data_points_collected: number;
  last_updated: string;
}

export interface UserSettings {
  user_id: UUID;
  default_location?: string;
  timezone?: string;
  language: string;
  measurement_units: 'imperial' | 'metric';
  notifications_enabled: boolean;
  email_marketing: boolean;
  dark_mode: boolean;
  created_at: string;
  updated_at: string;
}

export interface BodyProfile {
  id: UUID;
  user_id: UUID;
  name: string;
  height_cm: number;
  weight_kg: number;
  body_shape: string;
  skin_tone: string;
  is_default: boolean;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// AUTH TYPES
// ============================================================================

export interface AuthTokens {
  access_token: string;
  refresh_token: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  full_name?: string;
  referral_code?: string;
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  user: User;
  requires_email_confirmation?: boolean;
  referral?: {
    success: boolean;
    message: string;
    credit_months: number;
  };
}

// ============================================================================
// RECOMMENDATION TYPES
// ============================================================================

export interface MatchResult {
  item: Item;
  score: number;
  reasons: string[];
}

export interface SuggestedItem {
  item_id: UUID;
  item_name: string;
  image_url?: string;
  category: Category;
  position: string;
  confidence: number;
}

export interface CompleteLookSuggestion {
  items: Item[];
  match_score: number;
  description: string;
  style?: string;
  occasion?: string;
}

export interface SimilarItemResult {
  item_id: UUID;
  item_name: string;
  image_url?: string;
  category: Category;
  sub_category?: string;
  brand?: string;
  colors: string[];
  similarity: number;
  reasons: string[];
}

export interface WeatherRecommendation {
  temperature: number;
  temp_category: string;
  weather_state: string;
  preferred_categories: Category[];
  avoid_categories: Category[];
  preferred_materials: string[];
  suggested_layers: number;
  additional_items: string[];
  items_to_avoid: string[];
  notes: string[];
  color_suggestions: string[];
}

export type AstrologyRecommendationMode = 'daily' | 'important_meeting';
export type AstrologyRecommendationStatus = 'ready' | 'profile_required';

export interface AstrologyColorSuggestion {
  name: string;
  hex: string;
  reason: string;
  confidence: number;
}

export interface AstrologyContext {
  weekday: string;
  ruling_planet: string;
  moon_sign?: string | null;
  ascendant?: string | null;
  sidereal_sun_sign?: string | null;
}

export interface AstrologyWardrobePick {
  category: Category | string;
  items: Item[];
}

export interface AstrologyOutfitSuggestion {
  description: string;
  item_ids: UUID[];
  match_score: number;
}

export interface AstrologyRecommendation {
  status: AstrologyRecommendationStatus;
  target_date: string;
  mode: AstrologyRecommendationMode;
  astrology_mode: 'vedic_full' | 'vedic_lite';
  missing_fields: string[];
  context: AstrologyContext;
  lucky_colors: AstrologyColorSuggestion[];
  avoid_colors: AstrologyColorSuggestion[];
  wardrobe_picks: AstrologyWardrobePick[];
  suggested_outfits: AstrologyOutfitSuggestion[];
  notes: string[];
}

// ============================================================================
// FILTER TYPES
// ============================================================================

export interface ItemFilters {
  category?: Category;
  color?: string;
  occasion?: string;
  condition?: Condition;
  brand?: string;
  search?: string;
  is_favorite?: boolean;
  page?: number;
  page_size?: number;
}

export interface OutfitFilters {
  style?: string;
  season?: string;
  is_favorite?: boolean;
  search?: string;
  page?: number;
  page_size?: number;
}

// ============================================================================
// FORM TYPES
// ============================================================================

export interface ItemFormData {
  name: string;
  category: Category;
  sub_category?: string;
  brand?: string;
  colors: string[];
  occasion_tags?: string[];
  size?: string;
  price?: number;
  purchase_date?: string;
  purchase_location?: string;
  tags: string[];
  notes?: string;
  condition: Condition;
  is_favorite: boolean;
}

export interface OutfitFormData {
  name: string;
  description?: string;
  item_ids: UUID[];
  style?: Style;
  season?: Season;
  occasion?: string;
  tags: string[];
  is_favorite: boolean;
  generate_ai_image?: boolean;
}

export interface OutfitCreate {
  name: string;
  description?: string;
  item_ids: UUID[];
  style?: string;
  season?: string;
  occasion?: string;
  tags: string[];
  is_favorite?: boolean;
  is_public?: boolean;
}

// ============================================================================
// MULTI-ITEM EXTRACTION TYPES
// ============================================================================

/**
 * Bounding box coordinates as percentages (0-100) of image dimensions
 */
export interface BoundingBox {
  x: number;
  y: number;
  width: number;
  height: number;
}

/**
 * Status of a detected item during the extraction flow
 */
export type DetectedItemStatus =
  | 'detected'
  | 'generating'
  | 'generated'
  | 'failed'
  | 'deleted';

/**
 * Individual item detected during multi-item extraction
 */
export interface DetectedItem {
  /** Temporary ID for tracking during review */
  tempId: string;
  /** Source image ID for batch workflows */
  sourceImageId?: string;
  /** Person identifier in source image */
  personId?: string;
  /** Human-readable person label */
  personLabel?: string;
  /** Whether this item belongs to current user match */
  isCurrentUserPerson?: boolean;
  /** Whether item should be included when saving */
  includeInWardrobe?: boolean;
  /** Category of the item */
  category: Category;
  /** Sub-category (e.g., "t-shirt", "jeans") */
  sub_category?: string;
  /** Detected colors */
  colors: string[];
  /** Material type */
  material?: string;
  /** Pattern type */
  pattern?: string;
  /** Brand if visible */
  brand?: string;
  /** Detection confidence 0-1 */
  confidence: number;
  /** Approximate location in original image */
  boundingBox?: BoundingBox;
  /** Detailed description for image generation */
  detailedDescription: string;
  /** Status of this item in the extraction flow */
  status: DetectedItemStatus;
  /** Generated product image URL (data URL or blob URL) */
  generatedImageUrl?: string;
  /** Generation error message if failed */
  generationError?: string;
  /** User-editable name for the item */
  name?: string;
  /** User-editable tags */
  tags?: string[];
  /** User-editable use cases */
  occasion_tags?: string[];
}

/**
 * Result from multi-item detection step
 */
export interface MultiItemDetectionResult {
  /** All detected items */
  items: DetectedItem[];
  /** Whether profile reference image was used */
  hasProfileReference?: boolean;
  /** Whether user profile was matched in extraction image */
  profileMatchFound?: boolean;
  /** Overall analysis confidence */
  overallConfidence: number;
  /** Description of the full image */
  imageDescription: string;
  /** Total items detected */
  itemCount: number;
  /** Whether any items need manual review (low confidence) */
  requiresReview: boolean;
}

/**
 * State for the multi-item extraction flow
 */
export interface MultiItemExtractionState {
  /** Current step in the flow */
  step: 'upload' | 'detecting' | 'generating' | 'review' | 'saving';
  /** Original uploaded file */
  originalFile: File | null;
  /** Original image preview URL */
  originalPreviewUrl: string | null;
  /** All detected items */
  detectedItems: DetectedItem[];
  /** Detection progress (0-100) */
  detectionProgress: number;
  /** Image generation progress (0-100) */
  generationProgress: number;
  /** Saving progress (0-100) */
  savingProgress: number;
  /** Error message if any step fails */
  error: string | null;
}

/**
 * Options for product image generation
 */
export interface ProductImageGenerationOptions {
  /** Background style */
  background?: 'white' | 'gray' | 'gradient' | 'transparent';
  /** View angle */
  viewAngle?: 'front' | 'side' | 'flat-lay';
  /** Include shadows */
  includeShadows?: boolean;
  /** Image size */
  size?: { width: number; height: number };
}

// ============================================================================
// BATCH PROCESSING TYPES
// ============================================================================

/**
 * Status of a batch processing job
 */
export type BatchJobStatus =
  | 'pending'
  | 'extracting'
  | 'generating'
  | 'completed'
  | 'cancelled'
  | 'failed';

/**
 * Status of a single image in batch processing
 */
export type BatchImageStatus =
  | 'pending'
  | 'uploading'
  | 'extracting'
  | 'completed'
  | 'failed';

/**
 * Single image in a batch upload
 */
export interface BatchImageInput {
  /** Client-generated unique ID for tracking */
  imageId: string;
  /** Original file */
  file: File;
  /** Preview URL for display */
  previewUrl: string;
  /** Current status */
  status: BatchImageStatus;
  /** Error message if failed */
  error?: string;
  /** Items detected from this image */
  detectedItems?: DetectedItem[];
}

/**
 * Response from starting a batch job
 */
export interface BatchJobResponse {
  job_id: string;
  status: BatchJobStatus;
  total_images: number;
  sse_url: string;
  message: string;
}

/**
 * SSE event types for batch processing
 */
export type BatchSSEEventType =
  | 'connected'
  | 'heartbeat'
  | 'extraction_started'
  | 'image_extraction_complete'
  | 'image_extraction_failed'
  | 'all_extractions_complete'
  | 'generation_started'
  | 'batch_generation_started'
  | 'item_generation_complete'
  | 'item_generation_failed'
  | 'batch_generation_complete'
  | 'all_generations_complete'
  | 'job_complete'
  | 'job_failed'
  | 'job_cancelled';

/**
 * Generic SSE event structure
 */
export interface BatchSSEEvent<T = unknown> {
  event: BatchSSEEventType;
  data: T;
}

/**
 * Data for extraction_started event
 */
export interface ExtractionStartedData {
  job_id: string;
  total_images: number;
  timestamp: string;
}

/**
 * Data for image_extraction_complete event
 */
export interface ImageExtractionCompleteData {
  job_id: string;
  image_id: string;
  items: Array<{
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
  }>;
  items_count: number;
  completed_count: number;
  total_images: number;
  timestamp: string;
}

/**
 * Data for image_extraction_failed event
 */
export interface ImageExtractionFailedData {
  job_id: string;
  image_id: string;
  error: string;
  completed_count: number;
  failed_count: number;
  total_images: number;
  timestamp: string;
}

/**
 * Data for all_extractions_complete event
 */
export interface AllExtractionsCompleteData {
  job_id: string;
  total_images: number;
  successful: number;
  failed: number;
  total_items_detected: number;
  timestamp: string;
}

/**
 * Data for generation_started event
 */
export interface GenerationStartedData {
  job_id: string;
  total_items: number;
  batch_size: number;
  total_batches: number;
  timestamp: string;
}

/**
 * Data for batch_generation_started event
 */
export interface BatchGenerationStartedData {
  job_id: string;
  batch_number: number;
  total_batches: number;
  items_in_batch: number;
  item_ids: string[];
  start_index: number;
  end_index: number;
  timestamp: string;
}

/**
 * Data for item_generation_complete event
 */
export interface ItemGenerationCompleteData {
  job_id: string;
  temp_id: string;
  image_id: string;
  generated_image_base64: string;
  completed_count: number;
  total_items: number;
  timestamp: string;
}

/**
 * Data for item_generation_failed event
 */
export interface ItemGenerationFailedData {
  job_id: string;
  temp_id: string;
  image_id: string;
  error: string;
  completed_count: number;
  failed_count: number;
  total_items: number;
  timestamp: string;
}

/**
 * Data for job_complete event
 */
export interface JobCompleteData {
  job_id: string;
  total_images: number;
  total_items_detected: number;
  successful_extractions: number;
  failed_extractions: number;
  successful_generations: number;
  failed_generations: number;
  items: Array<{
    temp_id: string;
    image_id: string;
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
    generated_image_base64?: string;
    generated_image_url?: string;
    generation_error?: string;
  }>;
  timestamp: string;
}

/**
 * State for the batch extraction flow
 */
export interface BatchExtractionState {
  /** Current step in the flow */
  step: 'select' | 'uploading' | 'extracting' | 'generating' | 'review' | 'saving';
  /** All selected images */
  images: BatchImageInput[];
  /** Current job ID */
  jobId: string | null;
  /** All detected items from all images */
  allDetectedItems: DetectedItem[];

  // Progress tracking
  /** Extraction progress (0-100) */
  extractionProgress: number;
  /** Generation progress (0-100) */
  generationProgress: number;
  /** Current batch number during generation */
  currentBatch: number;
  /** Total number of batches */
  totalBatches: number;

  // Stats
  /** Number of images that completed extraction */
  imagesCompleted: number;
  /** Number of images that failed extraction */
  imagesFailed: number;
  /** Number of items that completed generation */
  itemsGenerated: number;
  /** Number of items that failed generation */
  itemsFailed: number;

  /** Error message if any */
  error: string | null;
}

// ============================================================================
// SOCIAL IMPORT TYPES
// ============================================================================

export type SocialPlatform = 'instagram' | 'facebook'

export type SocialImportJobStatus =
  | 'created'
  | 'discovering'
  | 'awaiting_auth'
  | 'processing'
  | 'paused_rate_limited'
  | 'completed'
  | 'cancelled'
  | 'failed'

export type SocialImportPhotoStatus =
  | 'queued'
  | 'processing'
  | 'awaiting_review'
  | 'buffered_ready'
  | 'approved'
  | 'rejected'
  | 'failed'

export type SocialImportItemStatus = 'generated' | 'edited' | 'failed' | 'saved' | 'discarded'

export interface SocialImportItem {
  id: string
  temp_id: string
  name?: string
  category: Category
  sub_category?: string
  colors: string[]
  material?: string
  pattern?: string
  brand?: string
  confidence: number
  bounding_box?: BoundingBox
  detailed_description?: string
  generated_image_url?: string
  generated_storage_path?: string
  generation_error?: string
  status: SocialImportItemStatus
  saved_item_id?: string
}

export interface SocialImportPhoto {
  id: string
  ordinal: number
  source_photo_url: string
  source_thumb_url?: string
  status: SocialImportPhotoStatus
  error_message?: string
  items: SocialImportItem[]
}

export interface SocialImportJobData {
  id: string
  status: SocialImportJobStatus
  platform: SocialPlatform
  source_url: string
  normalized_url: string
  total_photos: number
  discovered_photos: number
  processed_photos: number
  approved_photos: number
  rejected_photos: number
  failed_photos: number
  auth_required: boolean
  discovery_completed: boolean
  error_message?: string
  awaiting_review_photo?: SocialImportPhoto | null
  buffered_photo?: SocialImportPhoto | null
  processing_photo?: SocialImportPhoto | null
  queued_count: number
}

export type SocialImportEventType =
  | 'connected'
  | 'job_updated'
  | 'photo_discovered'
  | 'photo_processing_started'
  | 'photo_ready_for_review'
  | 'photo_buffered_ready'
  | 'photo_approved'
  | 'photo_rejected'
  | 'photo_failed'
  | 'auth_required'
  | 'auth_accepted'
  | 'rate_limit_paused'
  | 'job_completed'
  | 'job_failed'
  | 'job_cancelled'
  | 'heartbeat'

export interface SocialImportSSEEvent<T = unknown> {
  type: SocialImportEventType
  data: T
  id?: number
}

// ============================================================================
// SUBSCRIPTION TYPES
// ============================================================================

export type PlanType = 'free' | 'pro_monthly' | 'pro_yearly';

export type SubscriptionStatus = 'active' | 'cancelled' | 'past_due' | 'trial';

export interface Subscription {
  id: UUID;
  user_id: UUID;
  plan_type: PlanType;
  status: SubscriptionStatus;
  current_period_start: string;
  current_period_end?: string;
  cancel_at_period_end: boolean;
  trial_end?: string;
  referral_credit_months: number;
  created_at: string;
  updated_at: string;
}

export interface UsageLimits {
  monthly_extractions: number;
  monthly_extractions_limit: number;
  monthly_extractions_remaining: number;
  monthly_generations: number;
  monthly_generations_limit: number;
  monthly_generations_remaining: number;
  monthly_embeddings: number;
  monthly_embeddings_limit: number;
  monthly_embeddings_remaining: number;
  period_start: string;
  period_end: string;
}

export interface SubscriptionWithUsage {
  subscription: Subscription;
  usage: UsageLimits;
}

export interface ReferralCode {
  code: string;
  share_url: string;
  times_used: number;
  created_at: string;
}

export interface ReferredUser {
  email: string;
  full_name?: string;
  redeemed_at: string;
  credit_applied: boolean;
}

export interface ReferralStats {
  code: string;
  share_url: string;
  times_used: number;
  credits_earned: number;
  referred_users: ReferredUser[];
}

export interface ValidateReferralResponse {
  valid: boolean;
  referrer_name?: string;
  message: string;
}

export interface RedeemReferralResponse {
  success: boolean;
  message: string;
  credit_months: number;
}

export interface CheckoutSession {
  checkout_url: string;
  session_id: string;
}

export interface PortalSession {
  portal_url: string;
}

export interface PlanDetails {
  id: string;
  name: string;
  price_monthly: number;
  price_yearly: number;
  savings_yearly?: number;
  limits: {
    monthly_extractions: number;
    monthly_generations: number;
    monthly_embeddings: number;
  };
  features: string[];
}

export interface PlansResponse {
  plans: PlanDetails[];
}
