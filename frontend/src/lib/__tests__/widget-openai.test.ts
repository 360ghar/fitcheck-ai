import { describe, expect, it } from 'vitest'

import { extractList } from '../../../../widgets/src/lib/openai'

describe('widget API output normalization', () => {
  it('extracts item and outfit lists from the standard API data envelope', () => {
    const items = [{ id: 'item-1', name: 'Blue shirt' }]
    const outfits = [{ id: 'outfit-1', name: 'Weekend casual' }]

    expect(extractList({ data: { items } })).toEqual(items)
    expect(extractList({ data: { outfits } })).toEqual(outfits)
  })
})
