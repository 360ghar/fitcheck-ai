import { describe, it, expect } from 'vitest';
import { buildOutfitName, categoryDisplayName } from '@/lib/outfit-from-upload';

describe('outfit-from-upload naming', () => {
  it('maps categories to display labels', () => {
    expect(categoryDisplayName('tops')).toBe('Top');
    expect(categoryDisplayName('bottoms')).toBe('Bottom');
    expect(categoryDisplayName('other')).toBe('Item');
    expect(categoryDisplayName('unknown-thing')).toBe('Item');
  });

  it('builds "Top + Bottom look" from two distinct categories', () => {
    expect(
      buildOutfitName([
        { id: '1', category: 'tops' },
        { id: '2', category: 'bottoms' },
        { id: '3', category: 'shoes' },
      ])
    ).toBe('Top + Bottom look');
  });

  it('builds a single-label name for one category', () => {
    expect(buildOutfitName([{ id: '1', category: 'outerwear' }])).toBe('Outerwear look');
  });

  it('dedupes repeated categories', () => {
    expect(
      buildOutfitName([
        { id: '1', category: 'tops' },
        { id: '2', category: 'tops' },
      ])
    ).toBe('Top look');
  });

  it('falls back to "Uploaded look" when empty', () => {
    expect(buildOutfitName([])).toBe('Uploaded look');
  });
});
