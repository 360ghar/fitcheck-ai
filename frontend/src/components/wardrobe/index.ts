/**
 * Wardrobe Components Index
 *
 * Exports all wardrobe-related components for easier importing.
 */

// Main upload flow
export { MultiItemExtractionFlow, type ItemUploadResult } from './MultiItemExtractionFlow'
export { ItemUpload } from './ItemUpload'
export { SocialImportUrlPane } from './SocialImportUrlPane'
export { SocialImportAuthPrompt } from './SocialImportAuthPrompt'
export { SocialImportQueueReview } from './SocialImportQueueReview'
export { SocialImportProgress } from './SocialImportProgress'

// Progress components
export { DetectionProgress } from './DetectionProgress'
export { GenerationProgress } from './GenerationProgress'

// Review components
export { ExtractedItemsGrid } from './ExtractedItemsGrid'
export { ExtractedItemCard } from './ExtractedItemCard'

// Duplicate detection
export { DuplicateDetection } from './DuplicateDetection'

// Occasion filtering
export { OccasionQuickFilter } from './OccasionQuickFilter'

// Care instructions
export { CareInstructionsEditor, CareInstructionsDisplay, MaterialGuideCard } from './CareInstructionsEditor'

// Laundry tracking
export { LaundryTracker, ItemLaundryPanel } from './LaundryTracker'

// Other wardrobe components
export { FilterPanel } from './FilterPanel'
export { ItemDetailModal } from './ItemDetailModal'
