/**
 * Care Instructions Service
 *
 * Provides care instruction management for wardrobe items.
 * Includes washing, drying, ironing, and special care guidelines.
 */

import type { Category } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface CareInstructions {
  washing: WashingInstruction
  drying: DryingInstruction
  ironing: IroningInstruction
  dryClean: boolean
  specialCare: string[]
  notes?: string
}

export type WashingInstruction =
  | 'machine-hot'
  | 'machine-warm'
  | 'machine-cold'
  | 'hand-wash'
  | 'dry-clean-only'
  | 'do-not-wash'

export type DryingInstruction =
  | 'tumble-high'
  | 'tumble-low'
  | 'tumble-no-heat'
  | 'hang-dry'
  | 'lay-flat'
  | 'do-not-dry'

export type IroningInstruction =
  | 'high-heat'
  | 'medium-heat'
  | 'low-heat'
  | 'steam-only'
  | 'do-not-iron'

export interface CareSymbol {
  id: string
  symbol: string
  name: string
  description: string
  category: 'wash' | 'dry' | 'iron' | 'bleach' | 'special'
}

export interface MaterialCareGuide {
  material: string
  washing: WashingInstruction
  drying: DryingInstruction
  ironing: IroningInstruction
  tips: string[]
}

// ============================================================================
// CONSTANTS
// ============================================================================

const CARE_STORAGE_KEY = 'fitcheck-care-instructions'

export const WASHING_OPTIONS: { value: WashingInstruction; label: string; icon: string; description: string }[] = [
  { value: 'machine-hot', label: 'Machine Wash Hot', icon: '🔥', description: 'Hot water (60°C/140°F)' },
  { value: 'machine-warm', label: 'Machine Wash Warm', icon: '♨️', description: 'Warm water (40°C/104°F)' },
  { value: 'machine-cold', label: 'Machine Wash Cold', icon: '❄️', description: 'Cold water (30°C/86°F)' },
  { value: 'hand-wash', label: 'Hand Wash Only', icon: '🤲', description: 'Gentle hand washing' },
  { value: 'dry-clean-only', label: 'Dry Clean Only', icon: '🧹', description: 'Professional cleaning' },
  { value: 'do-not-wash', label: 'Do Not Wash', icon: '🚫', description: 'Spot clean only' },
]

export const DRYING_OPTIONS: { value: DryingInstruction; label: string; icon: string; description: string }[] = [
  { value: 'tumble-high', label: 'Tumble Dry High', icon: '🔥', description: 'High heat dryer' },
  { value: 'tumble-low', label: 'Tumble Dry Low', icon: '♨️', description: 'Low heat dryer' },
  { value: 'tumble-no-heat', label: 'Tumble No Heat', icon: '🌀', description: 'Air fluff only' },
  { value: 'hang-dry', label: 'Hang to Dry', icon: '👕', description: 'Air dry on hanger' },
  { value: 'lay-flat', label: 'Lay Flat to Dry', icon: '📋', description: 'Dry flat to prevent stretching' },
  { value: 'do-not-dry', label: 'Do Not Tumble Dry', icon: '🚫', description: 'No machine drying' },
]

export const IRONING_OPTIONS: { value: IroningInstruction; label: string; icon: string; description: string }[] = [
  { value: 'high-heat', label: 'High Heat', icon: '🔥', description: 'Cotton/linen setting' },
  { value: 'medium-heat', label: 'Medium Heat', icon: '♨️', description: 'Wool/silk setting' },
  { value: 'low-heat', label: 'Low Heat', icon: '🌡️', description: 'Synthetic setting' },
  { value: 'steam-only', label: 'Steam Only', icon: '💨', description: 'Use steamer, no direct contact' },
  { value: 'do-not-iron', label: 'Do Not Iron', icon: '🚫', description: 'Heat will damage' },
]

export const SPECIAL_CARE_OPTIONS: string[] = [
  'Wash inside out',
  'Use gentle detergent',
  'Do not bleach',
  'Wash with similar colors',
  'Use mesh laundry bag',
  'Avoid fabric softener',
  'Iron on reverse side',
  'Store folded, not hung',
  'Keep away from direct sunlight',
  'Use garment steamer',
  'Professional alterations only',
  'Avoid contact with perfume/deodorant',
  'Handle with care when wet',
  'Do not wring',
]

export const CARE_SYMBOLS: CareSymbol[] = [
  { id: 'wash-30', symbol: '🌊', name: 'Wash 30°C', description: 'Machine wash at 30°C', category: 'wash' },
  { id: 'wash-40', symbol: '♨️', name: 'Wash 40°C', description: 'Machine wash at 40°C', category: 'wash' },
  { id: 'wash-60', symbol: '🔥', name: 'Wash 60°C', description: 'Machine wash at 60°C', category: 'wash' },
  { id: 'hand-wash', symbol: '🤲', name: 'Hand Wash', description: 'Hand wash only', category: 'wash' },
  { id: 'no-wash', symbol: '🚫', name: 'Do Not Wash', description: 'Cannot be washed', category: 'wash' },
  { id: 'tumble-dry', symbol: '⭕', name: 'Tumble Dry', description: 'Can tumble dry', category: 'dry' },
  { id: 'no-tumble', symbol: '❌', name: 'No Tumble Dry', description: 'Do not tumble dry', category: 'dry' },
  { id: 'hang-dry', symbol: '👕', name: 'Hang Dry', description: 'Hang to dry', category: 'dry' },
  { id: 'iron-low', symbol: '•', name: 'Iron Low', description: 'Iron at low temperature', category: 'iron' },
  { id: 'iron-med', symbol: '••', name: 'Iron Medium', description: 'Iron at medium temperature', category: 'iron' },
  { id: 'iron-high', symbol: '•••', name: 'Iron High', description: 'Iron at high temperature', category: 'iron' },
  { id: 'no-iron', symbol: '🚫', name: 'Do Not Iron', description: 'Cannot be ironed', category: 'iron' },
  { id: 'no-bleach', symbol: '△', name: 'No Bleach', description: 'Do not bleach', category: 'bleach' },
  { id: 'dry-clean', symbol: '○', name: 'Dry Clean', description: 'Dry clean recommended', category: 'special' },
]

export const MATERIAL_GUIDES: MaterialCareGuide[] = [
  {
    material: 'Cotton',
    washing: 'machine-warm',
    drying: 'tumble-low',
    ironing: 'high-heat',
    tips: ['Durable and easy to care for', 'May shrink in hot water', 'Prone to wrinkling'],
  },
  {
    material: 'Linen',
    washing: 'machine-cold',
    drying: 'hang-dry',
    ironing: 'high-heat',
    tips: ['Wrinkles easily (it\'s part of the charm!)', 'Gets softer with each wash', 'Iron while slightly damp'],
  },
  {
    material: 'Silk',
    washing: 'hand-wash',
    drying: 'lay-flat',
    ironing: 'low-heat',
    tips: ['Very delicate', 'Use silk-specific detergent', 'Keep away from deodorant'],
  },
  {
    material: 'Wool',
    washing: 'hand-wash',
    drying: 'lay-flat',
    ironing: 'steam-only',
    tips: ['Can felt if agitated', 'Store with cedar to prevent moths', 'Let rest between wears'],
  },
  {
    material: 'Cashmere',
    washing: 'hand-wash',
    drying: 'lay-flat',
    ironing: 'steam-only',
    tips: ['Extremely delicate', 'Use cashmere comb for pilling', 'Fold, never hang'],
  },
  {
    material: 'Polyester',
    washing: 'machine-cold',
    drying: 'tumble-low',
    ironing: 'low-heat',
    tips: ['Durable and wrinkle-resistant', 'Can hold odors', 'Quick-drying'],
  },
  {
    material: 'Nylon',
    washing: 'machine-cold',
    drying: 'hang-dry',
    ironing: 'low-heat',
    tips: ['Strong and elastic', 'Can melt under high heat', 'Static-prone'],
  },
  {
    material: 'Denim',
    washing: 'machine-cold',
    drying: 'hang-dry',
    ironing: 'high-heat',
    tips: ['Wash inside out to preserve color', 'Wash infrequently to maintain shape', 'Air out between wears'],
  },
  {
    material: 'Leather',
    washing: 'do-not-wash',
    drying: 'do-not-dry',
    ironing: 'do-not-iron',
    tips: ['Professional cleaning only', 'Condition regularly', 'Store in breathable bag'],
  },
  {
    material: 'Suede',
    washing: 'do-not-wash',
    drying: 'do-not-dry',
    ironing: 'do-not-iron',
    tips: ['Use suede brush', 'Protect with spray', 'Avoid water'],
  },
  {
    material: 'Rayon/Viscose',
    washing: 'dry-clean-only',
    drying: 'hang-dry',
    ironing: 'medium-heat',
    tips: ['Weakens when wet', 'Shrinks easily', 'Some can be gently hand-washed'],
  },
  {
    material: 'Spandex/Elastane',
    washing: 'hand-wash',
    drying: 'hang-dry',
    ironing: 'do-not-iron',
    tips: ['Avoid chlorine bleach', 'Don\'t leave in direct sun', 'Loses elasticity over time'],
  },
]

// ============================================================================
// STORAGE
// ============================================================================

interface StoredCareInstructions {
  [itemId: string]: CareInstructions
}

function getStoredCareInstructions(): StoredCareInstructions {
  try {
    const stored = localStorage.getItem(CARE_STORAGE_KEY)
    if (!stored) return {}
    return JSON.parse(stored) as StoredCareInstructions
  } catch {
    return {}
  }
}

function saveCareInstructions(data: StoredCareInstructions): void {
  try {
    localStorage.setItem(CARE_STORAGE_KEY, JSON.stringify(data))
  } catch (error) {
    console.error('Failed to save care instructions:', error)
  }
}

// ============================================================================
// CARE INSTRUCTION MANAGEMENT
// ============================================================================

/**
 * Get care instructions for an item.
 */
export function getItemCareInstructions(itemId: string): CareInstructions | null {
  const stored = getStoredCareInstructions()
  return stored[itemId] || null
}

/**
 * Save care instructions for an item.
 */
export function saveItemCareInstructions(itemId: string, instructions: CareInstructions): void {
  const stored = getStoredCareInstructions()
  stored[itemId] = instructions
  saveCareInstructions(stored)
}

/**
 * Delete care instructions for an item.
 */
export function deleteItemCareInstructions(itemId: string): void {
  const stored = getStoredCareInstructions()
  delete stored[itemId]
  saveCareInstructions(stored)
}

/**
 * Get default care instructions based on material.
 */
export function getDefaultCareForMaterial(material: string): CareInstructions {
  const guide = MATERIAL_GUIDES.find(
    (g) => g.material.toLowerCase() === material.toLowerCase()
  )

  if (guide) {
    return {
      washing: guide.washing,
      drying: guide.drying,
      ironing: guide.ironing,
      dryClean: guide.washing === 'dry-clean-only',
      specialCare: guide.tips,
    }
  }

  // Default for unknown materials
  return {
    washing: 'machine-cold',
    drying: 'hang-dry',
    ironing: 'low-heat',
    dryClean: false,
    specialCare: ['Check garment label', 'When in doubt, hand wash'],
  }
}

/**
 * Get default care instructions based on category.
 */
export function getDefaultCareForCategory(category: Category): CareInstructions {
  const categoryDefaults: Record<Category, Partial<CareInstructions>> = {
    tops: { washing: 'machine-cold', drying: 'hang-dry', ironing: 'medium-heat' },
    bottoms: { washing: 'machine-cold', drying: 'hang-dry', ironing: 'medium-heat' },
    shoes: { washing: 'do-not-wash', drying: 'do-not-dry', ironing: 'do-not-iron', specialCare: ['Wipe clean with damp cloth', 'Use shoe trees'] },
    outerwear: { washing: 'dry-clean-only', drying: 'hang-dry', ironing: 'steam-only' },
    accessories: { washing: 'hand-wash', drying: 'lay-flat', ironing: 'do-not-iron' },
    activewear: { washing: 'machine-cold', drying: 'hang-dry', ironing: 'do-not-iron', specialCare: ['Wash after each use', 'Avoid fabric softener'] },
    swimwear: { washing: 'hand-wash', drying: 'lay-flat', ironing: 'do-not-iron', specialCare: ['Rinse immediately after use', 'Avoid wringing'] },
    other: { washing: 'hand-wash', drying: 'hang-dry', ironing: 'low-heat' },
  }

  const defaults = categoryDefaults[category] || categoryDefaults.other

  return {
    washing: defaults.washing || 'machine-cold',
    drying: defaults.drying || 'hang-dry',
    ironing: defaults.ironing || 'low-heat',
    dryClean: defaults.washing === 'dry-clean-only',
    specialCare: defaults.specialCare || [],
  }
}

/**
 * Get material care guide.
 */
export function getMaterialGuide(material: string): MaterialCareGuide | null {
  return MATERIAL_GUIDES.find(
    (g) => g.material.toLowerCase() === material.toLowerCase()
  ) || null
}

/**
 * Format care instructions as readable text.
 */
export function formatCareInstructions(instructions: CareInstructions): string {
  const washing = WASHING_OPTIONS.find((o) => o.value === instructions.washing)
  const drying = DRYING_OPTIONS.find((o) => o.value === instructions.drying)
  const ironing = IRONING_OPTIONS.find((o) => o.value === instructions.ironing)

  const lines: string[] = []

  if (washing) lines.push(`${washing.icon} Washing: ${washing.label}`)
  if (drying) lines.push(`${drying.icon} Drying: ${drying.label}`)
  if (ironing) lines.push(`${ironing.icon} Ironing: ${ironing.label}`)

  if (instructions.dryClean) {
    lines.push('🧹 Professional dry cleaning recommended')
  }

  if (instructions.specialCare.length > 0) {
    lines.push('')
    lines.push('Special care:')
    instructions.specialCare.forEach((tip) => lines.push(`  • ${tip}`))
  }

  if (instructions.notes) {
    lines.push('')
    lines.push(`Notes: ${instructions.notes}`)
  }

  return lines.join('\n')
}

/**
 * Get care summary icons.
 */
export function getCareIcons(instructions: CareInstructions): string[] {
  const icons: string[] = []

  const washing = WASHING_OPTIONS.find((o) => o.value === instructions.washing)
  const drying = DRYING_OPTIONS.find((o) => o.value === instructions.drying)
  const ironing = IRONING_OPTIONS.find((o) => o.value === instructions.ironing)

  if (washing) icons.push(washing.icon)
  if (drying) icons.push(drying.icon)
  if (ironing) icons.push(ironing.icon)

  return icons
}
