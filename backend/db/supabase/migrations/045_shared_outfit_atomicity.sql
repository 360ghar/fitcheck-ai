-- FitCheck AI - Shared-outfit atomicity
--
-- Second wave of the 2026-08 two-wave bug hunt. The share/unshare flow in
-- POST /outfits/{id}/share and GET /outfits/public/{id} was a chain of
-- independent Python statements:
--
--   1. POST /outfits/{id}/share wrote outfits.is_public, then upserted
--      shared_outfits, then returned the row. A crash (or a failed upsert)
--      between the two left the outfit public with no share row, or a share
--      row with is_public=false. The upsert also sent `updated_at`, a column
--      that does not exist on shared_outfits (001 defines only created_at),
--      so the endpoint 500'd on every share after the unique-constraint
--      migration 011.
--
--   2. GET /outfits/public/{id} incremented view_count with a Python
--      read-modify-write (count + 1, then UPDATE) - the same lost-update
--      class fixed for outfits.items in 044. 044 provides
--      increment_shared_outfit_views, which this migration does NOT redefine.
--
--   3. There was no unshare path: deleting a share row left
--      outfits.is_public=true, so the outfit stayed visible at its public
--      URL with a dead share row.
--
-- This migration makes the whole lifecycle atomic on the server:
--
--   upsert_shared_outfit(outfit_uuid, user_uuid, visibility, expires_at,
--                        caption, allow_feedback, share_url)
--       One transaction: ownership check -> is_public=true -> upsert the
--       share row. Rejects non-'public' visibility (MVP supports public
--       only; the old Python wrote 'friends'/'private' rows that the public
--       route could never serve). Returns the share row, or zero rows when
--       the outfit is missing/unowned or the visibility is rejected.
--
--   remove_shared_outfit(share_uuid, user_uuid)
--       One transaction: delete the share row (owned by the caller) and
--       reset outfits.is_public=false, so the outfit stops being served at
--       its public URL the moment it is unshared. Returns TRUE when a row
--       was deleted. (Deleting the whole outfit still cascades to
--       shared_outfits via the 001 ON DELETE CASCADE FK; this RPC covers
--       the unshare-without-delete path.)
--
-- Security: SECURITY DEFINER, search_path pinned, EXECUTE revoked from
-- PUBLIC/anon/authenticated and granted to service_role only (same policy
-- as migrations 022/024/026/031/044). Idempotent (CREATE OR REPLACE +
-- guarded DDL).
--
-- Target: Supabase Postgres

BEGIN;

-- The backend has sent `updated_at` in the share upsert since 011; the
-- column never existed, so every share upsert failed. Add it (nullable,
-- backfill created_at so existing rows get a sane value).
ALTER TABLE public.shared_outfits
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP;

-- Natural no-op on rerun (updated_at is backfilled once); wrapped in a DO
-- block to keep top-level DML out of the migration (re-runnability contract).
DO $$
BEGIN
  UPDATE public.shared_outfits
  SET updated_at = created_at
  WHERE updated_at IS NULL;
END;
$$;

-- =============================================================================
-- RPC: set_primary_outfit_image
-- =============================================================================
-- POST /outfits/{id}/images (upload_outfit_image) inserted the new image and
-- then cleared is_primary on the outfit's OTHER images with a SECOND UPDATE:
-- a window where two images were primary, or both stayed set if the process
-- died between the statements. 044 fixed the identical race for item_images;
-- this is the outfit_images twin, kept here so the outfit-image flow depends
-- on a migration it owns. One statement/transaction:
-- is_primary = (id = image_uuid); returns TRUE when the image belongs to
-- the outfit, FALSE when it does not.
CREATE OR REPLACE FUNCTION public.set_primary_outfit_image(
    outfit_uuid UUID,
    image_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    target_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM public.outfit_images
        WHERE id = image_uuid AND outfit_id = outfit_uuid
    ) INTO target_exists;

    -- Exactly one row of the outfit's images ends up primary (the target
    -- when it exists, none otherwise).
    UPDATE public.outfit_images
    SET is_primary = (id = image_uuid)
    WHERE outfit_id = outfit_uuid;

    RETURN target_exists;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =============================================================================
-- RPC: upsert_shared_outfit
-- =============================================================================
CREATE OR REPLACE FUNCTION public.upsert_shared_outfit(
    outfit_uuid UUID,
    user_uuid UUID,
    p_visibility VARCHAR,
    p_expires_at TIMESTAMP,
    p_caption TEXT,
    p_allow_feedback BOOLEAN,
    p_share_url TEXT
)
RETURNS SETOF public.shared_outfits AS $$
DECLARE
    v_share public.shared_outfits;
BEGIN
    -- Ownership: an outfit may only be shared by its owner.
    IF NOT EXISTS (
        SELECT 1 FROM public.outfits
        WHERE id = outfit_uuid AND user_id = user_uuid
    ) THEN
        RETURN;
    END IF;

    -- MVP: only public visibility is supported. Reject anything else instead
    -- of persisting a row the public route can never serve.
    IF p_visibility IS DISTINCT FROM 'public' THEN
        RETURN;
    END IF;

    -- Same transaction: make the outfit publicly readable and upsert the
    -- share row, so the two can never disagree (crashes included).
    UPDATE public.outfits
    SET is_public = TRUE,
        updated_at = NOW() AT TIME ZONE 'UTC'
    WHERE id = outfit_uuid;

    INSERT INTO public.shared_outfits (
        user_id, outfit_id, share_url, visibility, expires_at,
        caption, allow_feedback, created_at, updated_at
    )
    VALUES (
        user_uuid, outfit_uuid, p_share_url, 'public', p_expires_at,
        p_caption, p_allow_feedback,
        NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'
    )
    ON CONFLICT (outfit_id, user_id) DO UPDATE SET
        visibility = 'public',
        expires_at = EXCLUDED.expires_at,
        caption = EXCLUDED.caption,
        allow_feedback = EXCLUDED.allow_feedback,
        share_url = EXCLUDED.share_url,
        updated_at = NOW() AT TIME ZONE 'UTC'
    RETURNING * INTO v_share;

    RETURN NEXT v_share;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =============================================================================
-- RPC: remove_shared_outfit
-- =============================================================================
CREATE OR REPLACE FUNCTION public.remove_shared_outfit(
    share_uuid UUID,
    user_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_outfit_id UUID;
    deleted INTEGER;
BEGIN
    SELECT outfit_id INTO v_outfit_id
    FROM public.shared_outfits
    WHERE id = share_uuid AND user_id = user_uuid;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    DELETE FROM public.shared_outfits WHERE id = share_uuid;
    GET DIAGNOSTICS deleted = ROW_COUNT;
    IF deleted = 0 THEN
        RETURN FALSE;
    END IF;

    -- The outfit's only owner is user_uuid, so no other share row can keep
    -- it public; take it off the public URL in the same transaction.
    UPDATE public.outfits
    SET is_public = FALSE,
        updated_at = NOW() AT TIME ZONE 'UTC'
    WHERE id = v_outfit_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =============================================================================
-- Harden RPC privileges (same policy as 022/024/026/031/044)
-- =============================================================================

REVOKE EXECUTE ON FUNCTION public.upsert_shared_outfit(UUID, UUID, VARCHAR, TIMESTAMP, TEXT, BOOLEAN, TEXT)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.remove_shared_outfit(UUID, UUID)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.set_primary_outfit_image(UUID, UUID)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.upsert_shared_outfit(UUID, UUID, VARCHAR, TIMESTAMP, TEXT, BOOLEAN, TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.remove_shared_outfit(UUID, UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.set_primary_outfit_image(UUID, UUID) TO service_role;

COMMIT;
