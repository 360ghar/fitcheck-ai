/**
 * Type definitions for FitCheck AI
 */

// ============================================================================
// COMMON TYPES
// ============================================================================

export type UUID = string;

export interface ApiResponse<T> {
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
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
  size?: string;
  price?: number;
  purchase_date?: string;
  purchase_location?: string;
  tags: string[];
  notes?: string;
  condition: Condition;
  is_favorite: boolean;
  usage_times_worn: number;
  usage_last_worn?: string;
  cost_per_wear?: number;
  created_at: string;
  updated_at: string;
  images: ItemImage[];
}

export interface ItemCreate {
  name: string;
  category: Category;
  sub_category?: string;
  brand?: string;
  colors: string[];
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
  is_primary?: boolean;
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

export interface OutfitItem {
  item_id: UUID;
  position?: string;
  notes?: string;
}

export interface OutfitImage {
  id: UUID;
  outfit_id: UUID;
  image_url: string;
  thumbnail_url?: string;
  generation_type: 'ai' | 'manual';
  is_primary: boolean;
  width?: number;
  height?: number;
  metadata?: Record<string, unknown>;
  created_at: string;
}

export interface Outfit {
  id: UUID;
  user_id: UUID;
  name: string;
  description?: string;
  items: OutfitItem[];
  style?: Style;
  season?: Season;
  occasion?: string;
  tags: string[];
  is_favorite: boolean;
  is_public: boolean;
  image_url?: string;
  times_worn: number;
  last_worn?: string;
  created_at: string;
  updated_at: string;
  images: OutfitImage[];
}

export type GenerationStatus = 'pending' | 'processing' | 'completed' | 'failed';

export interface GenerationRequest {
  outfit_id: UUID;
  prompt?: string;
  style?: string;
  background?: string;
  include_model?: boolean;
  model_gender?: string;
  model_body_type?: string;
  lighting?: string;
  view_angle?: string;
}

export interface GenerationResponse {
  generation_id: string;
  outfit_id: UUID;
  status: GenerationStatus;
  image_url?: string;
  estimated_time?: number;
  created_at: string;
}

// ============================================================================
// USER TYPES
// ============================================================================

export interface User {
  id: UUID;
  email: string;
  full_name?: string;
  avatar_url?: string;
  is_active: boolean;
  email_verified: boolean;
  created_at: string;
  updated_at?: string;
  last_login_at?: string;
}

export interface UserPreferences {
  id: UUID;
  user_id: UUID;
  favorite_colors: string[];
  preferred_styles: string[];
  liked_brands: string[];
  disliked_patterns: string[];
  style_notes?: string;
  created_at: string;
  updated_at: string;
}

export interface UserSettings {
  id: UUID;
  user_id: UUID;
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
  height?: number;
  weight?: number;
  body_type?: string;
  skin_tone?: string;
  hair_color?: string;
  eye_color?: string;
  notes?: string;
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
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  user: User;
}

// ============================================================================
// RECOMMENDATION TYPES
// ============================================================================

export interface MatchResult {
  item_id: UUID;
  item_name: string;
  image_url?: string;
  category: Category;
  score: number;
  reasons: MatchReason[];
}

export interface MatchReason {
  type: string;
  description: string;
  confidence: number;
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
  name: string;
  description?: string;
  items: SuggestedItem[];
  style?: string;
  occasion?: string;
  confidence: number;
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

// ============================================================================
// FILTER TYPES
// ============================================================================

export interface ItemFilters {
  category?: Category;
  color?: string;
  condition?: Condition;
  search?: string;
  is_favorite?: boolean;
  page?: number;
  page_size?: number;
}

export interface OutfitFilters {
  style?: Style;
  season?: Season;
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
