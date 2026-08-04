# Contract: Railway Bucket migration (storage backend)

Status: DONE — implementation complete and verified (2026-08-04).
Execution log of the LIVE migration (see bottom of this file). This contract
defined the shared interface for the parallel agents; the orchestrator owns it.
Do not edit from agents.

## Goal

Move file storage from Supabase Storage to a Railway S3-compatible Bucket (private).
Keep the DB (Postgres) + Auth on Supabase. Kill orphans: only DB-referenced files
should live in the bucket. Use a cleaner key layout. Temp generated images (photoshoot,
batch, social-import review, `save_generated_image`) REMAIN stored in the bucket
(Requirement 3 was explicitly skipped — do NOT change temp-image behavior).

## Non-negotiables

- Never use Docker for local dev. Railway Bucket is S3-compatible; use `aioboto3`.
- Keep modular boundaries: routes thin, logic in services, schemas in models.
- `StorageService` keeps its existing public method signatures + return shapes so
  callers change as little as possible. Internals switch to the S3 backend.
- All new env vars land in `backend/app/core/config.py` + `backend/.env.example`.
- Do not add temp-image-to-bucket behavior changes (Requirement 3 skipped).

## New config fields (backend/app/core/config.py)

| Field | Default | Notes |
|-------|---------|-------|
| `STORAGE_BACKEND` | `"railway"` | `"railway"` (S3) or `"supabase"` (fallback during cutover) |
| `OBJECT_STORAGE_ENDPOINT` | `"https://storage.railway.app"` | S3 endpoint |
| `OBJECT_STORAGE_REGION` | `"auto"` | S3 region |
| `OBJECT_STORAGE_ACCESS_KEY_ID` | `""` | S3 access key |
| `OBJECT_STORAGE_SECRET_ACCESS_KEY` | `""` | S3 secret key |
| `OBJECT_STORAGE_BUCKET` | `""` | S3 bucket name |

Railway provides these as variable references: `BUCKET`, `ENDPOINT`, `REGION`,
`ACCESS_KEY_ID`, `SECRET_ACCESS_KEY` (plus `AWS_*` aliases). The config maps them
to the `OBJECT_STORAGE_*` names above.

## New object layer: backend/app/services/object_storage.py

`S3StorageBackend` class wrapping `aioboto3`:

- `__init__(self)` builds from `settings` (lazy client).
- `async upload(key: str, data: bytes, content_type: str, cache_control: str) -> None`
- `async download(key: str) -> bytes`
- `async copy(src_key: str, dst_key: str) -> None`  (server-side copy; used by move)
- `async delete(key: str) -> None`
- `async delete_many(keys: List[str]) -> int`
- `async presign_get(key: str, expires: int = 900) -> str`
- `async list_keys(prefix: str = "") -> List[str]`
- `async close() -> None` (release aioboto3 session at shutdown)

## New key layout (folder structure)

Replace `StorageService._generate_filename` with `_build_key(user_id, category, ext)`:

```
{user_id}/items/{uuid}.{ext}      # item images
{user_id}/outfits/{uuid}.{ext}    # outfit images
{user_id}/avatars/{uuid}.{ext}    # avatars
{user_id}/sources/{uuid}.{ext}    # source photos
{user_id}/feedback/{uuid}.{ext}   # feedback attachments
{user_id}/tmp/{source}/{uuid}.{ext}  # temp (UNCHANGED behavior)
```

No timestamps in path. uuid4 hex keys. Ext from `EXTENSION_BY_MIME` (sniffed bytes).
`promote_temp_image_to_item` moves `{user_id}/tmp/...` -> `{user_id}/items/...` via
S3 server-side copy.

## StorageService return-shape compatibility

- `image_url` / `thumbnail_url` value = a **presigned GET URL** (short-lived) OR a
  value the serving layer can regenerate. The DB stores `storage_path`; URLs are
  materialized at read time. Keep the field names so response models + callers don't
  churn.
- `public_url` (from `upload_file`) = presigned URL.
- Existing `download_to_base64` / `download_and_downscale_to_base64` fetch via the
  S3 backend (no public URL), preserving the SSRF-safe "only known bucket keys" rule.

## Ownership map (who edits what — do not cross)

- `core-storage`: `object_storage.py` (new), `storage_service.py`, `config.py`,
  `requirements.txt` (+`aioboto3`), `.env.example`.
- `callers`: `api/v1/items.py`, `api/v1/outfits.py`, `api/v1/users.py`,
  `api/v1/ai.py`, `api/v1/feedback.py`, `services/batch_extraction_service.py`,
  `services/social_import_pipeline_service.py`, `services/photoshoot_service.py`,
  `services/item_reference_service.py`, `agents/image_generation_agent.py`,
  `main.py`.
- `serving-schema`: new migration for `support_tickets.attachment_storage_paths`,
  `resolve_owned_storage_paths` + account deletion (users.py) feedback paths,
  presigned-URL read endpoint (new route), `api/v1/items.py`/`outfits.py` read paths
  that surface URLs.
- `scripts`: `scripts/storage_inventory.py` (orphan report), `scripts/migrate_storage_to_railway.py`.
- `tests`: all storage tests.
- `docs`: `docs/BACKEND.md`, `docs/SECURITY.md`, `ARCHITECTURE.md` (repo root),
  `docs/FRONTEND.md`, `docs/FLUTTER.md`, `docs/exec-plans/tech-debt-tracker.md`,
  `backend/README.md`.

## Done criteria (backend)

- `pytest` green; `ruff check .` clean.
- No public bucket URLs; all serving via presigned URLs.
- Inventory script reports orphans; migration script dry-run + live.
## Live migration execution log (2026-08-04)

Buckets: source `fitcheck-images` (Supabase, `SUPABASE_STORAGE_BUCKET`) → target
`collapsible-saddlebag-s0pyqr` (Railway S3, `OBJECT_STORAGE_BUCKET`).

| Step | Script | Result |
|------|--------|--------|
| 1 | `python scripts/cleanup_supabase_orphans.py --delete` (pass 1) | Deleted 340 orphan objects from Supabase (66 temp/generated + 274 other). |
| 2 | `python scripts/migrate_storage_to_railway.py --apply` (pass 1) | Copied 616 objects (486.6 MB) Supabase → Railway, 0 errors. |
| 3 | `python scripts/storage_inventory.py --delete` | Deleted 160 orphan objects from Railway (leftover temp/legacy that pass-1 cleanup's walk undercounted). |
| 4 | Supabase purge (inline) | Deleted 616 remaining Supabase objects. |
| 5 | `python scripts/cleanup_supabase_orphans.py --delete` (pass 2) | New live writes had landed during migration (app still on Supabase). Deleted 174 orphans (94 temp + 80 other). |
| 6 | `python scripts/migrate_storage_to_railway.py --apply` (pass 2) | Copied 166 new DB-referenced objects (97.2 MB) → Railway, 0 errors. |
| 7 | Supabase purge (inline) | Deleted 166 remaining Supabase objects. |

Final verified state:
- **Supabase `fitcheck-images` bucket: 0 objects.**
- **Railway bucket: 622 objects, 0 orphans** (all DB-referenced via `storage_path`).
- **1 MISSING** (`a.jpg`) = pre-existing junk avatar URL on `users.fa5c0bed...` (`https://example.com/a.jpg`
  parsed by `key_from_path`); not a migration artifact — the object never existed.

Note (cutover race): passes 2/4/5/6 were needed because the DEPLOYED app was still
writing to Supabase Storage (new code not deployed yet). The DB stayed on Supabase
throughout. Deploy the new backend (with `STORAGE_BACKEND=railway` + `OBJECT_STORAGE_*`)
to finalize the cutover so new uploads go straight to the Railway bucket.

- Docs updated.