/**
 * ItemUpload Component
 *
 * Re-exports the MultiItemExtractionFlow component for backward compatibility.
 * The multi-item extraction flow handles:
 * - Uploading clothing images
 * - AI-powered detection of ALL clothing items in the image
 * - Product image generation for each detected item
 * - Review and edit extracted data
 * - Saving multiple items to wardrobe
 *
 * @see MultiItemExtractionFlow for the full implementation
 */

export {
  MultiItemExtractionFlow as ItemUpload,
  MultiItemExtractionFlow as default,
  type ItemUploadResult,
} from './MultiItemExtractionFlow'
