/**
 * Auto-create one outfit per uploaded photo after its extracted closet items are saved.
 *
 * Grouping key is the source image (batch flow: `DetectedItem.sourceImageId`; social
 * flow: the approved photo). Each group becomes an outfit named after its pieces, then
 * a single AI render of the person wearing it is kicked off — mirroring the outfit
 * builder's auto-generation, so uploads land on the Outfits page ready-made.
 */

import { logger } from '@/lib/logger';
import * as outfitsApi from '@/api/outfits';
import { useOutfitStore } from '@/stores/outfitStore';
import type { Category } from '@/types';

/** Display label for a category (used to build outfit names). */
export function categoryDisplayName(category: string): string {
  const map: Record<string, string> = {
    tops: 'Top',
    bottoms: 'Bottom',
    shoes: 'Shoes',
    accessories: 'Accessory',
    outerwear: 'Outerwear',
    swimwear: 'Swimwear',
    activewear: 'Activewear',
    other: 'Item',
  };
  return map[category] ?? 'Item';
}

export interface UploadedOutfitPiece {
  id: string;
  category: Category | string;
}

/**
 * Build a readable outfit name from the pieces in one photo.
 * Picks up to two distinct categories: "Top + Bottom look", "Top look".
 */
export function buildOutfitName(pieces: UploadedOutfitPiece[]): string {
  const seen = new Set<string>();
  const labels: string[] = [];
  for (const p of pieces) {
    const label = categoryDisplayName(String(p.category));
    if (!seen.has(label)) {
      seen.add(label);
      labels.push(label);
    }
    if (labels.length === 2) break;
  }
  if (labels.length === 0) return 'Uploaded look';
  return `${labels.join(' + ')} look`;
}

/**
 * Create an outfit from one photo's saved items and fire its AI render.
 * Never throws — failures are logged so the item-save path is unaffected.
 * Returns the created outfit id, or null on failure.
 */
export async function createOutfitFromSavedItems(
  pieces: UploadedOutfitPiece[]
): Promise<string | null> {
  if (pieces.length === 0) return null;
  try {
    const outfit = await outfitsApi.createOutfit({
      name: buildOutfitName(pieces),
      item_ids: pieces.map((p) => p.id),
      tags: ['from-upload'],
      is_favorite: false,
    });

    // Add to the store so the list updates immediately, mark as generating, then run the
    // same single-look render path the outfit builder uses (use_body_profile, clean bg).
    const store = useOutfitStore.getState();
    const generating = new Map(store.generatingOutfits);
    generating.set(outfit.id, { status: 'pending' });
    useOutfitStore.setState({
      outfits: [outfit, ...store.outfits],
      generatingOutfits: generating,
    });
    store.startGenerationForNewOutfit(outfit.id);

    return outfit.id;
  } catch (err) {
    logger.warn('Failed to auto-create outfit from uploaded photo', err);
    return null;
  }
}

/**
 * Create one outfit per source-image group (fire-and-forget). `groups` maps a source
 * image/photo id to that photo's saved pieces. Returns the ids of created outfits.
 */
export async function createOutfitsFromUploads(
  groups: Map<string, UploadedOutfitPiece[]>
): Promise<string[]> {
  const created: string[] = [];
  for (const pieces of groups.values()) {
    const id = await createOutfitFromSavedItems(pieces);
    if (id) created.push(id);
  }
  return created;
}
