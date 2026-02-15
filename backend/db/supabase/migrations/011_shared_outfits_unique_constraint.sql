-- Migration: Add unique constraint on shared_outfits for upsert support
-- This constraint ensures a user can only have one share record per outfit,
-- enabling proper upsert behavior with on_conflict="outfit_id,user_id"

-- Add unique constraint on (outfit_id, user_id) combination
-- This prevents duplicate share records and enables upsert operations
ALTER TABLE public.shared_outfits
ADD CONSTRAINT shared_outfits_outfit_user_unique
UNIQUE (outfit_id, user_id);

-- Add index to improve lookup performance for this common query pattern
CREATE INDEX IF NOT EXISTS idx_shared_outfits_outfit_user
ON public.shared_outfits(outfit_id, user_id);
