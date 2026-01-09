/**
 * Embeddings Service
 *
 * Frontend service for managing embeddings, caching, and similarity calculations.
 * Integrates with the backend embedding API for generating embeddings and
 * provides local utilities for similarity search.
 */

import {
  generateEmbedding,
  generateBatchEmbeddings,
  searchSimilarItems,
  type EmbeddingResult,
  type BatchEmbeddingResult,
  type SimilaritySearchRequest,
  type SimilaritySearchResult,
} from '@/api/ai';

// ============================================================================
// TYPES
// ============================================================================

export interface EmbeddingCache {
  text: string;
  embedding: number[];
  model: string;
  timestamp: number;
}

export interface ItemEmbeddingInput {
  name: string;
  category: string;
  colors?: string[];
  brand?: string;
  material?: string;
  pattern?: string;
}

export interface SimilarityResult {
  index: number;
  score: number;
}

export interface ItemSimilarityResult {
  itemId: string;
  score: number;
}

// ============================================================================
// CONSTANTS
// ============================================================================

const EMBEDDING_CACHE_KEY = 'fitcheck-embedding-cache';
const CACHE_MAX_AGE_MS = 7 * 24 * 60 * 60 * 1000; // 7 days
const CACHE_MAX_ENTRIES = 500;

// ============================================================================
// CACHE MANAGEMENT
// ============================================================================

interface EmbeddingCacheStore {
  [textHash: string]: EmbeddingCache;
}

/**
 * Generate a simple hash for a text string.
 */
function hashText(text: string): string {
  let hash = 0;
  for (let i = 0; i < text.length; i++) {
    const char = text.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32bit integer
  }
  return hash.toString(36);
}

/**
 * Get the embedding cache from local storage.
 */
function getEmbeddingCacheStore(): EmbeddingCacheStore {
  try {
    const stored = localStorage.getItem(EMBEDDING_CACHE_KEY);
    if (!stored) return {};
    return JSON.parse(stored) as EmbeddingCacheStore;
  } catch {
    return {};
  }
}

/**
 * Save the embedding cache to local storage.
 */
function saveEmbeddingCacheStore(cache: EmbeddingCacheStore): void {
  try {
    localStorage.setItem(EMBEDDING_CACHE_KEY, JSON.stringify(cache));
  } catch (error) {
    console.error('Failed to save embedding cache:', error);
  }
}

/**
 * Get a cached embedding for a text.
 */
export function getCachedEmbedding(text: string): number[] | null {
  const cache = getEmbeddingCacheStore();
  const hash = hashText(text);
  const entry = cache[hash];

  if (!entry) return null;

  // Check if cache entry is still valid
  const age = Date.now() - entry.timestamp;
  if (age > CACHE_MAX_AGE_MS) {
    // Entry expired, remove it
    delete cache[hash];
    saveEmbeddingCacheStore(cache);
    return null;
  }

  return entry.embedding;
}

/**
 * Cache an embedding for a text.
 */
export function cacheEmbedding(text: string, embedding: number[], model: string): void {
  const cache = getEmbeddingCacheStore();
  const hash = hashText(text);

  // Prune old entries if cache is too large
  const entries = Object.entries(cache);
  if (entries.length >= CACHE_MAX_ENTRIES) {
    // Remove oldest entries
    const sorted = entries.sort((a, b) => a[1].timestamp - b[1].timestamp);
    const toRemove = sorted.slice(0, entries.length - CACHE_MAX_ENTRIES + 1);
    for (const [key] of toRemove) {
      delete cache[key];
    }
  }

  cache[hash] = {
    text,
    embedding,
    model,
    timestamp: Date.now(),
  };

  saveEmbeddingCacheStore(cache);
}

/**
 * Clear the entire embedding cache.
 */
export function clearEmbeddingCache(): void {
  try {
    localStorage.removeItem(EMBEDDING_CACHE_KEY);
  } catch (error) {
    console.error('Failed to clear embedding cache:', error);
  }
}

/**
 * Get cache statistics.
 */
export function getEmbeddingCacheStats(): {
  entries: number;
  oldestTimestamp: number | null;
  newestTimestamp: number | null;
} {
  const cache = getEmbeddingCacheStore();
  const entries = Object.values(cache);

  if (entries.length === 0) {
    return { entries: 0, oldestTimestamp: null, newestTimestamp: null };
  }

  const timestamps = entries.map((e) => e.timestamp);
  return {
    entries: entries.length,
    oldestTimestamp: Math.min(...timestamps),
    newestTimestamp: Math.max(...timestamps),
  };
}

// ============================================================================
// SIMILARITY CALCULATIONS
// ============================================================================

/**
 * Calculate cosine similarity between two vectors.
 */
export function cosineSimilarity(a: number[], b: number[]): number {
  if (a.length !== b.length) {
    throw new Error(`Vector dimensions must match: ${a.length} vs ${b.length}`);
  }

  let dotProduct = 0;
  let normA = 0;
  let normB = 0;

  for (let i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }

  normA = Math.sqrt(normA);
  normB = Math.sqrt(normB);

  if (normA === 0 || normB === 0) {
    return 0;
  }

  return dotProduct / (normA * normB);
}

/**
 * Calculate Euclidean distance between two vectors.
 */
export function euclideanDistance(a: number[], b: number[]): number {
  if (a.length !== b.length) {
    throw new Error(`Vector dimensions must match: ${a.length} vs ${b.length}`);
  }

  let sum = 0;
  for (let i = 0; i < a.length; i++) {
    const diff = a[i] - b[i];
    sum += diff * diff;
  }

  return Math.sqrt(sum);
}

/**
 * Find the most similar vectors to a target vector.
 */
export function findMostSimilar(
  target: number[],
  candidates: number[][],
  topK: number = 5
): SimilarityResult[] {
  const results: SimilarityResult[] = [];

  for (let i = 0; i < candidates.length; i++) {
    const score = cosineSimilarity(target, candidates[i]);
    results.push({ index: i, score });
  }

  // Sort by score descending
  results.sort((a, b) => b.score - a.score);

  return results.slice(0, topK);
}

/**
 * Find similar items locally using a map of item embeddings.
 */
export function findSimilarItemsLocally(
  targetEmbedding: number[],
  itemEmbeddings: Map<string, number[]>,
  topK: number = 5,
  minScore: number = 0.5
): ItemSimilarityResult[] {
  const results: ItemSimilarityResult[] = [];

  for (const [itemId, embedding] of itemEmbeddings) {
    const score = cosineSimilarity(targetEmbedding, embedding);
    if (score >= minScore) {
      results.push({ itemId, score });
    }
  }

  // Sort by score descending
  results.sort((a, b) => b.score - a.score);

  return results.slice(0, topK);
}

// ============================================================================
// HIGH-LEVEL FUNCTIONS
// ============================================================================

/**
 * Create a text description for an item suitable for embedding.
 */
export function createItemDescription(item: ItemEmbeddingInput): string {
  const parts: string[] = [];

  if (item.name) parts.push(item.name);
  if (item.category) parts.push(item.category);
  if (item.colors && item.colors.length > 0) {
    parts.push(item.colors.join(' '));
  }
  if (item.brand) parts.push(item.brand);
  if (item.material) parts.push(item.material);
  if (item.pattern) parts.push(item.pattern);

  return parts.join(' ');
}

/**
 * Get an embedding for an item, using cache if available.
 */
export async function getItemEmbedding(item: ItemEmbeddingInput): Promise<number[]> {
  const description = createItemDescription(item);

  // Check cache first
  const cached = getCachedEmbedding(description);
  if (cached) {
    return cached;
  }

  // Generate new embedding
  const result = await generateEmbedding(description);

  // Cache the result
  cacheEmbedding(description, result.embedding, result.model);

  return result.embedding;
}

/**
 * Get embeddings for multiple items, using cache where available.
 */
export async function getItemEmbeddings(
  items: ItemEmbeddingInput[]
): Promise<Map<number, number[]>> {
  const results = new Map<number, number[]>();
  const toGenerate: { index: number; description: string }[] = [];

  // Check cache for each item
  for (let i = 0; i < items.length; i++) {
    const description = createItemDescription(items[i]);
    const cached = getCachedEmbedding(description);

    if (cached) {
      results.set(i, cached);
    } else {
      toGenerate.push({ index: i, description });
    }
  }

  // Generate embeddings for uncached items
  if (toGenerate.length > 0) {
    const texts = toGenerate.map((t) => t.description);
    const batchResult = await generateBatchEmbeddings(texts);

    for (let i = 0; i < toGenerate.length; i++) {
      const { index, description } = toGenerate[i];
      const embedding = batchResult.embeddings[i];

      // Cache and store
      cacheEmbedding(description, embedding, batchResult.model);
      results.set(index, embedding);
    }
  }

  return results;
}

/**
 * Find similar items using the backend vector search.
 */
export async function findSimilarItems(
  request: SimilaritySearchRequest
): Promise<SimilaritySearchResult> {
  return searchSimilarItems(request);
}

/**
 * Check if two items are duplicates based on embedding similarity.
 */
export async function checkDuplicateByEmbedding(
  item1: ItemEmbeddingInput,
  item2: ItemEmbeddingInput,
  threshold: number = 0.9
): Promise<{ isDuplicate: boolean; similarity: number }> {
  const [embedding1, embedding2] = await Promise.all([
    getItemEmbedding(item1),
    getItemEmbedding(item2),
  ]);

  const similarity = cosineSimilarity(embedding1, embedding2);

  return {
    isDuplicate: similarity >= threshold,
    similarity,
  };
}

/**
 * Cluster items by similarity.
 */
export async function clusterItemsBySimilarity(
  items: ItemEmbeddingInput[],
  similarityThreshold: number = 0.7
): Promise<number[][]> {
  const embeddings = await getItemEmbeddings(items);
  const clusters: number[][] = [];
  const assigned = new Set<number>();

  for (let i = 0; i < items.length; i++) {
    if (assigned.has(i)) continue;

    const cluster = [i];
    assigned.add(i);

    const embedding = embeddings.get(i);
    if (!embedding) continue;

    for (let j = i + 1; j < items.length; j++) {
      if (assigned.has(j)) continue;

      const otherEmbedding = embeddings.get(j);
      if (!otherEmbedding) continue;

      const similarity = cosineSimilarity(embedding, otherEmbedding);
      if (similarity >= similarityThreshold) {
        cluster.push(j);
        assigned.add(j);
      }
    }

    clusters.push(cluster);
  }

  return clusters;
}

// ============================================================================
// RE-EXPORTS
// ============================================================================

export type {
  EmbeddingResult,
  BatchEmbeddingResult,
  SimilaritySearchRequest,
  SimilaritySearchResult,
};

export {
  generateEmbedding,
  generateBatchEmbeddings,
  searchSimilarItems,
};
