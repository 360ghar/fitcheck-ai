-- FitCheck AI - Atomic counters and item-image primaries
--
-- Fixes the read-modify-write / two-statement bug class surfaced by the
-- 2026-08 two-wave bug hunt. Each function moves the whole update into one
-- SQL statement (or a row-locked read+write) so concurrent requests cannot
-- lose increments or leave two primary images:
--
--   1. increment_item_worn(item_uuid, user_uuid)
--      POST /items/{id}/wear previously read usage_times_worn in Python and
--      wrote count+1: two concurrent requests could both read N and both
--      write N+1, losing an increment. The UPDATE below does the +1
--      atomically under the row lock and returns the updated row
--      (RETURNING *), so the route reports the new count with no second
--      read. Ownership is enforced by `user_id = user_uuid`; a missing or
--      unowned item returns zero rows.
--
--   2. set_primary_item_image(item_uuid, image_uuid)
--      POST /items/{id}/images cleared the previous primary with a SECOND
--      UPDATE statement after inserting the new image, leaving a window in
--      which two images were primary (and a crash between the two
--      statements left the new image primary with the old one still set).
--      This function flips every flag for the item inside one statement:
--      `is_primary = (id = image_uuid)` — exactly one row is primary when
--      the image belongs to the item, zero when it does not. Returns TRUE
--      when the target image exists on the item.
--
--   3. increment_shared_outfit_views(share_uuid)
--      Public shared-outfit view counting was a Python read-modify-write on
--      shared_outfits.view_count; the UPDATE below increments it in one
--      statement. Returns TRUE when the share row exists.
--
--   4. add_outfit_item(outfit_uuid, item_uuid, user_uuid)
--      remove_outfit_item(outfit_uuid, item_uuid, user_uuid)
--      toggle_outfit_favorite(outfit_uuid, user_uuid)
--      Outfit item-list edits were read-modify-write on outfits.item_ids
--      (a UUID[] column; the POST /outfits/{id}/items-style flows) with the
--      same lost-update hazard. Each function takes the row lock
--      (SELECT ... FOR UPDATE) under the caller's ownership, then appends /
--      removes / toggles. add_outfit_item appends only when the item is not
--      already present; remove_outfit_item is a no-op when absent;
--      toggle_outfit_favorite flips outfits.is_favorite (it takes no item
--      id, so the toggle is the favorite flag, not the item list). All
--      three return TRUE when the outfit was found and owned by the caller,
--      FALSE otherwise (and add_outfit_item also returns FALSE when the
--      item is not found or not owned by the caller, mirroring the
--      create-outfit ownership invariant).
--
-- Security: every function is SECURITY DEFINER (runs as the owner,
-- RLS-exempt) with `SET search_path = public`, and EXECUTE is revoked from
-- PUBLIC/anon/authenticated and granted to service_role only — the backend
-- calls these with the service-role client, so browser roles must not be
-- able to invoke them. Same style as migrations 022/024/026/031.
--
-- Idempotent (CREATE OR REPLACE + guarded DDL): safe to re-run in the SQL
-- editor.
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- RPC: increment_item_worn
-- =============================================================================
CREATE OR REPLACE FUNCTION public.increment_item_worn(
    item_uuid UUID,
    user_uuid UUID
)
RETURNS SETOF public.items AS $$
    UPDATE public.items
    SET usage_times_worn = COALESCE(usage_times_worn, 0) + 1,
        -- usage_last_worn is TIMESTAMP (no tz); store the UTC wall clock so
        -- values stay comparable with the backend's utcnow_iso() writes.
        usage_last_worn = NOW() AT TIME ZONE 'UTC',
        updated_at = NOW() AT TIME ZONE 'UTC'
    WHERE id = item_uuid AND user_id = user_uuid
    RETURNING *;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- =============================================================================
-- RPC: set_primary_item_image
-- =============================================================================
CREATE OR REPLACE FUNCTION public.set_primary_item_image(
    item_uuid UUID,
    image_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    target_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM public.item_images
        WHERE id = image_uuid AND item_id = item_uuid
    ) INTO target_exists;

    -- One statement, one transaction: exactly one row of the item's images
    -- ends up primary (the target when it exists, none otherwise).
    UPDATE public.item_images
    SET is_primary = (id = image_uuid)
    WHERE item_id = item_uuid;

    RETURN target_exists;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =============================================================================
-- RPC: increment_shared_outfit_views
-- =============================================================================
CREATE OR REPLACE FUNCTION public.increment_shared_outfit_views(
    share_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    updated INTEGER;
BEGIN
    UPDATE public.shared_outfits
    SET view_count = COALESCE(view_count, 0) + 1
    WHERE id = share_uuid;
    GET DIAGNOSTICS updated = ROW_COUNT;
    RETURN updated > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =============================================================================
-- RPC: add_outfit_item
-- =============================================================================
CREATE OR REPLACE FUNCTION public.add_outfit_item(
    outfit_uuid UUID,
    item_uuid UUID,
    user_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    current_ids public.outfits.item_ids%TYPE;
BEGIN
    -- Row lock: concurrent add/remove calls serialize on the outfit row, so
    -- no edit can be lost between the read and the write.
    SELECT item_ids INTO current_ids
    FROM public.outfits
    WHERE id = outfit_uuid AND user_id = user_uuid
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    -- The outfit may only reference items the caller owns (same invariant as
    -- create-outfit's ownership verification).
    IF NOT EXISTS (
        SELECT 1 FROM public.items
        WHERE id = item_uuid AND user_id = user_uuid
    ) THEN
        RETURN FALSE;
    END IF;

    IF NOT (item_uuid = ANY (COALESCE(current_ids, ARRAY[]::UUID[]))) THEN
        UPDATE public.outfits
        SET item_ids = COALESCE(current_ids, ARRAY[]::UUID[]) || item_uuid,
            updated_at = NOW() AT TIME ZONE 'UTC'
        WHERE id = outfit_uuid;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =============================================================================
-- RPC: remove_outfit_item
-- =============================================================================
CREATE OR REPLACE FUNCTION public.remove_outfit_item(
    outfit_uuid UUID,
    item_uuid UUID,
    user_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    current_ids public.outfits.item_ids%TYPE;
BEGIN
    SELECT item_ids INTO current_ids
    FROM public.outfits
    WHERE id = outfit_uuid AND user_id = user_uuid
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    UPDATE public.outfits
    SET item_ids = array_remove(COALESCE(current_ids, ARRAY[]::UUID[]), item_uuid),
        updated_at = NOW() AT TIME ZONE 'UTC'
    WHERE id = outfit_uuid;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =============================================================================
-- RPC: toggle_outfit_favorite
-- =============================================================================
CREATE OR REPLACE FUNCTION public.toggle_outfit_favorite(
    outfit_uuid UUID,
    user_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    current_flag BOOLEAN;
BEGIN
    SELECT is_favorite INTO current_flag
    FROM public.outfits
    WHERE id = outfit_uuid AND user_id = user_uuid
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    UPDATE public.outfits
    SET is_favorite = NOT COALESCE(current_flag, FALSE),
        updated_at = NOW() AT TIME ZONE 'UTC'
    WHERE id = outfit_uuid;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =============================================================================
-- Harden RPC privileges (same policy as 022/024/026/031: the backend calls
-- these with the service-role client, so browser roles must not be able to
-- invoke them).
-- =============================================================================

REVOKE EXECUTE ON FUNCTION public.increment_item_worn(UUID, UUID)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.set_primary_item_image(UUID, UUID)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.increment_shared_outfit_views(UUID)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.add_outfit_item(UUID, UUID, UUID)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.remove_outfit_item(UUID, UUID, UUID)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.toggle_outfit_favorite(UUID, UUID)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.increment_item_worn(UUID, UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.set_primary_item_image(UUID, UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.increment_shared_outfit_views(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.add_outfit_item(UUID, UUID, UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.remove_outfit_item(UUID, UUID, UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.toggle_outfit_favorite(UUID, UUID) TO service_role;

COMMIT;
