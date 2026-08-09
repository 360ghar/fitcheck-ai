-- FitCheck AI - Client idempotency keys for item/outfit image creation
--
-- The frontend save flows retry createItem / uploadOutfitImage on
-- transport-level failures (408/429/5xx/network). When the first attempt
-- actually committed before the response was lost, the retry used to insert
-- a duplicate item row (and duplicate promoted image objects) or a duplicate
-- outfit_images row (and duplicate storage objects). A per-user
-- client_request_id lets the create endpoints replay the original row
-- instead of inserting a second one (F1-07).
--
-- Target: Supabase Postgres

BEGIN;

ALTER TABLE public.items
    ADD COLUMN client_request_id TEXT;

-- One idempotency key per user. Partial so historical rows (NULL keys) never
-- collide; the create endpoint only replays rows that are not deleted.
CREATE UNIQUE INDEX IF NOT EXISTS items_user_client_request_id_key
    ON public.items (user_id, client_request_id)
    WHERE client_request_id IS NOT NULL;

ALTER TABLE public.outfit_images
    ADD COLUMN client_request_id TEXT;

-- outfit_images has no user_id column; outfit_id is already user-scoped
-- (outfits.user_id), so the key is unique per outfit.
CREATE UNIQUE INDEX IF NOT EXISTS outfit_images_outfit_client_request_id_key
    ON public.outfit_images (outfit_id, client_request_id)
    WHERE client_request_id IS NOT NULL;

COMMIT;
