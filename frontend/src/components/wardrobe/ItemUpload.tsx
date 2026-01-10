/**
 * ItemUpload Component
 *
 * Re-exports the BatchExtractionFlow component for multi-image batch upload.
 * The batch extraction flow handles:
 * - Uploading up to 50 clothing images at once
 * - AI-powered detection of ALL clothing items in parallel
 * - Batched product image generation (5 at a time)
 * - Review and edit extracted data
 * - Saving multiple items to wardrobe
 *
 * @see BatchExtractionFlow for the full implementation
 */

export {
  BatchExtractionFlow as ItemUpload,
  BatchExtractionFlow as default,
  type ItemUploadResult,
} from './BatchExtractionFlow'
