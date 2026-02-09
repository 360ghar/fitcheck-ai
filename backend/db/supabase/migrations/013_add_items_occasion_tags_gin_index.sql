-- Add a GIN index to speed up occasion tag contains queries.
CREATE INDEX IF NOT EXISTS idx_items_occasion_tags
ON public.items
USING GIN (occasion_tags);
