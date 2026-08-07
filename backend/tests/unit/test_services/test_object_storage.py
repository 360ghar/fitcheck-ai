"""
Tests for the S3-compatible object storage backend
(``app.services.object_storage``).

``aioboto3.Session`` is patched so ``_get_client`` builds against a fake
client whose methods are AsyncMocks; paginator pages are real async
generators so ``async for`` in ``list_keys`` / ``scan_keys`` works. No real
S3 endpoint is ever touched (the suite-wide socket guard enforces this).
"""

import asyncio
from unittest.mock import AsyncMock, Mock

import pytest

from app.core.config import settings
from app.services import object_storage as obj_storage
from app.services.object_storage import (
    S3StorageBackend,
    close_storage_backend,
    get_storage_backend,
)


@pytest.fixture(autouse=True)
def _reset_backend(monkeypatch):
    """Each test starts with a fresh module-level backend singleton."""
    monkeypatch.setattr(obj_storage, "_backend", None)


def _fake_client() -> Mock:
    """An S3 client stand-in whose awaited methods are AsyncMocks."""
    client = Mock()
    client.put_object = AsyncMock()
    client.get_object = AsyncMock()
    client.copy_object = AsyncMock()
    client.delete_object = AsyncMock()
    client.delete_objects = AsyncMock()
    client.generate_presigned_url = AsyncMock()
    client.close = AsyncMock()
    client.get_paginator = Mock()
    return client


def _install_fake_session(monkeypatch, client) -> Mock:
    """Patch aioboto3.Session so ``_get_client`` wires up ``client``."""
    session = Mock()
    ctx = Mock()
    ctx.__aenter__ = AsyncMock(return_value=client)
    session.client.return_value = ctx
    monkeypatch.setattr(obj_storage.aioboto3, "Session", Mock(return_value=session))
    return session


def _paginator_for(*pages) -> Mock:
    """A paginator whose ``paginate`` returns an async generator of pages."""
    paginator = Mock()

    async def _pages():
        for page in pages:
            yield page

    paginator.paginate.return_value = _pages()
    return paginator


# ---------------------------------------------------------------------------
# Construction
# ---------------------------------------------------------------------------


def test_init_defaults_from_settings(monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "default-bucket")
    monkeypatch.setattr(settings, "OBJECT_STORAGE_ENDPOINT", "https://s3.example.com")
    monkeypatch.setattr(settings, "OBJECT_STORAGE_REGION", "us-east-1")
    monkeypatch.setattr(settings, "OBJECT_STORAGE_ACCESS_KEY_ID", "default-key")
    monkeypatch.setattr(settings, "OBJECT_STORAGE_SECRET_ACCESS_KEY", "default-secret")

    backend = S3StorageBackend()

    assert backend.bucket == "default-bucket"
    assert backend.endpoint_url == "https://s3.example.com"
    assert backend.region_name == "us-east-1"
    assert backend.aws_access_key_id == "default-key"
    assert backend.aws_secret_access_key == "default-secret"
    assert backend._client is None
    assert backend._session is None


def test_init_explicit_overrides_win(monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "default-bucket")

    backend = S3StorageBackend(
        endpoint_url="https://other.example.com",
        region_name="eu-west-1",
        aws_access_key_id="override-key",
        aws_secret_access_key="override-secret",
        bucket="other-bucket",
    )

    assert backend.bucket == "other-bucket"
    assert backend.endpoint_url == "https://other.example.com"
    assert backend.region_name == "eu-west-1"
    assert backend.aws_access_key_id == "override-key"
    assert backend.aws_secret_access_key == "override-secret"


# ---------------------------------------------------------------------------
# Lazy client creation
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_client_creates_and_caches(monkeypatch):
    client = _fake_client()
    session = _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    first = await backend._get_client()
    second = await backend._get_client()

    assert first is client
    assert second is client
    assert backend._session is session
    session.client.assert_called_once()
    call = session.client.call_args
    assert call.args[0] == "s3"
    assert call.kwargs["endpoint_url"] == settings.OBJECT_STORAGE_ENDPOINT
    assert call.kwargs["region_name"] == settings.OBJECT_STORAGE_REGION
    assert call.kwargs["aws_access_key_id"] == settings.OBJECT_STORAGE_ACCESS_KEY_ID
    assert call.kwargs["aws_secret_access_key"] == settings.OBJECT_STORAGE_SECRET_ACCESS_KEY
    assert call.kwargs["config"] is obj_storage._BOTO_CONFIG


@pytest.mark.asyncio
async def test_get_client_created_once_under_concurrency(monkeypatch):
    client = _fake_client()
    session = _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    c1, c2 = await asyncio.gather(backend._get_client(), backend._get_client())

    assert c1 is client
    assert c2 is client
    session.client.assert_called_once()


@pytest.mark.asyncio
async def test_get_client_second_caller_finds_client_inside_lock(monkeypatch):
    """A caller that passes the outer None-check while creation is in flight
    must skip creation once it acquires the lock (inner re-check)."""
    client = _fake_client()
    session = _install_fake_session(monkeypatch, client)
    ctx = session.client.return_value
    backend = S3StorageBackend()

    started = asyncio.Event()
    release = asyncio.Event()

    async def _slow_enter():
        started.set()
        await release.wait()
        return client

    # side_effect (not direct assignment): Mock binds a plain function like a
    # method and would pass `self`, so route through an AsyncMock.
    ctx.__aenter__ = AsyncMock(side_effect=_slow_enter)

    first_task = asyncio.create_task(backend._get_client())
    await started.wait()  # first caller is now mid-creation, inside the lock

    second_task = asyncio.create_task(backend._get_client())
    await asyncio.sleep(0)  # let the second caller reach the lock
    release.set()

    first, second = await asyncio.gather(first_task, second_task)

    assert first is client
    assert second is client
    session.client.assert_called_once()


# ---------------------------------------------------------------------------
# Object operations
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_upload_sets_content_type_and_cache_control(monkeypatch):
    client = _fake_client()
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    await backend.upload("user-1/items/a.png", b"data", "image/png", "3600")

    client.put_object.assert_awaited_once_with(
        Bucket=settings.OBJECT_STORAGE_BUCKET,
        Key="user-1/items/a.png",
        Body=b"data",
        ContentType="image/png",
        CacheControl="max-age=3600",
    )


@pytest.mark.asyncio
async def test_upload_omits_empty_optional_params(monkeypatch):
    client = _fake_client()
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    await backend.upload("key", b"data", "", "")

    kwargs = client.put_object.await_args.kwargs
    assert kwargs["Bucket"] == settings.OBJECT_STORAGE_BUCKET
    assert kwargs["Key"] == "key"
    assert kwargs["Body"] == b"data"
    assert "ContentType" not in kwargs
    assert "CacheControl" not in kwargs


@pytest.mark.asyncio
async def test_download_returns_body_bytes(monkeypatch):
    client = _fake_client()
    body = Mock()
    body.read = AsyncMock(return_value=b"payload")
    client.get_object.return_value = {"Body": body}
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    data = await backend.download("user-1/items/a.png")

    assert data == b"payload"
    client.get_object.assert_awaited_once_with(
        Bucket=settings.OBJECT_STORAGE_BUCKET, Key="user-1/items/a.png"
    )
    body.read.assert_awaited_once()


@pytest.mark.asyncio
async def test_copy_uses_server_side_copy_source(monkeypatch):
    client = _fake_client()
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    await backend.copy("src-key", "dst-key")

    client.copy_object.assert_awaited_once_with(
        Bucket=settings.OBJECT_STORAGE_BUCKET,
        CopySource={"Bucket": settings.OBJECT_STORAGE_BUCKET, "Key": "src-key"},
        Key="dst-key",
    )


@pytest.mark.asyncio
async def test_delete_single_object(monkeypatch):
    client = _fake_client()
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    await backend.delete("user-1/items/a.png")

    client.delete_object.assert_awaited_once_with(
        Bucket=settings.OBJECT_STORAGE_BUCKET, Key="user-1/items/a.png"
    )


# ---------------------------------------------------------------------------
# Batch delete
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_delete_many_empty_returns_zero(monkeypatch):
    client = _fake_client()
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    assert await backend.delete_many([]) == 0
    client.delete_objects.assert_not_awaited()


@pytest.mark.asyncio
async def test_delete_many_batches_at_1000_object_limit(monkeypatch):
    client = _fake_client()
    client.delete_objects.side_effect = [{"Errors": []}, {"Errors": []}]
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    keys = [f"key-{i}" for i in range(1001)]
    assert await backend.delete_many(keys) == 1001

    assert client.delete_objects.await_count == 2
    first_chunk = client.delete_objects.await_args_list[0].kwargs["Delete"]["Objects"]
    second_chunk = client.delete_objects.await_args_list[1].kwargs["Delete"]["Objects"]
    assert len(first_chunk) == 1000
    assert len(second_chunk) == 1
    assert first_chunk[0] == {"Key": "key-0"}
    assert second_chunk[0] == {"Key": "key-1000"}
    for call in client.delete_objects.await_args_list:
        assert call.kwargs["Delete"]["Quiet"] is True


@pytest.mark.asyncio
async def test_delete_many_counts_reported_errors(monkeypatch):
    client = _fake_client()
    client.delete_objects.return_value = {
        "Errors": [{"Key": "key-1", "Code": "NoSuchKey"}]
    }
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    assert await backend.delete_many(["key-1", "key-2", "key-3"]) == 2


# ---------------------------------------------------------------------------
# Presigning and listing
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_presign_get_default_and_custom_expiry(monkeypatch):
    client = _fake_client()
    client.generate_presigned_url.return_value = "https://presigned.example/key"
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    url = await backend.presign_get("user-1/items/a.png")
    assert url == "https://presigned.example/key"
    client.generate_presigned_url.assert_awaited_once_with(
        "get_object",
        Params={"Bucket": settings.OBJECT_STORAGE_BUCKET, "Key": "user-1/items/a.png"},
        ExpiresIn=900,
    )

    await backend.presign_get("user-1/items/a.png", expires=60)
    assert (
        client.generate_presigned_url.await_args_list[1].kwargs["ExpiresIn"] == 60
    )


@pytest.mark.asyncio
async def test_list_keys_paginates_and_concatenates(monkeypatch):
    client = _fake_client()
    client.get_paginator.return_value = _paginator_for(
        {"Contents": [{"Key": "a"}, {"Key": "b"}]},
        {"Contents": []},
        {"Contents": [{"Key": "c"}]},
    )
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    keys = await backend.list_keys(prefix="user-1/")

    assert keys == ["a", "b", "c"]
    client.get_paginator.assert_called_once_with("list_objects_v2")
    paginate_call = client.get_paginator.return_value.paginate.call_args
    assert paginate_call.kwargs["Bucket"] == settings.OBJECT_STORAGE_BUCKET
    assert paginate_call.kwargs["Prefix"] == "user-1/"


@pytest.mark.asyncio
async def test_scan_keys_maps_metadata_and_breaks_at_max_pages(monkeypatch):
    client = _fake_client()
    client.get_paginator.return_value = _paginator_for(
        {
            "Contents": [
                {"Key": "k1", "Size": 10, "LastModified": "2026-01-01T00:00:00Z"},
                {"Key": "k2"},
            ]
        },
        {"Contents": [{"Key": "k3", "Size": 5, "LastModified": None}]},
    )
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    scanned = await backend.scan_keys(prefix="tmp/", max_pages=2)

    # Both pages scanned (pages < max_pages after the first), then the
    # max_pages guard fired at the second page boundary.
    assert scanned == [
        {"key": "k1", "size": 10, "last_modified": "2026-01-01T00:00:00Z"},
        {"key": "k2", "size": 0, "last_modified": None},
        {"key": "k3", "size": 5, "last_modified": None},
    ]
    paginate_call = client.get_paginator.return_value.paginate.call_args
    assert paginate_call.kwargs["PaginationConfig"] == {"PageSize": 1000}


@pytest.mark.asyncio
async def test_scan_keys_halts_at_max_pages(monkeypatch):
    client = _fake_client()
    client.get_paginator.return_value = _paginator_for(
        {"Contents": [{"Key": "k1", "Size": 1, "LastModified": None}]},
        {"Contents": [{"Key": "k2", "Size": 2, "LastModified": None}]},
    )
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    scanned = await backend.scan_keys(max_pages=1)

    assert [entry["key"] for entry in scanned] == ["k1"]


@pytest.mark.asyncio
async def test_scan_keys_exhausts_paginator_naturally(monkeypatch):
    client = _fake_client()
    client.get_paginator.return_value = _paginator_for(
        {"Contents": [{"Key": "k1", "Size": 1, "LastModified": None}]},
    )
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    scanned = await backend.scan_keys()

    assert [entry["key"] for entry in scanned] == ["k1"]


# ---------------------------------------------------------------------------
# Teardown
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_close_releases_client_and_is_idempotent(monkeypatch):
    client = _fake_client()
    _install_fake_session(monkeypatch, client)
    backend = S3StorageBackend()

    await backend._get_client()
    await backend.close()

    client.close.assert_awaited_once()
    assert backend._client is None
    assert backend._session is None

    await backend.close()
    client.close.assert_awaited_once()


# ---------------------------------------------------------------------------
# Module-level singleton helpers
# ---------------------------------------------------------------------------


def test_get_storage_backend_returns_singleton():
    first = get_storage_backend()
    second = get_storage_backend()

    assert isinstance(first, S3StorageBackend)
    assert first is second


@pytest.mark.asyncio
async def test_close_storage_backend_closes_and_resets_singleton(monkeypatch):
    backend = Mock()
    backend.close = AsyncMock()
    monkeypatch.setattr(obj_storage, "_backend", backend)

    await close_storage_backend()

    backend.close.assert_awaited_once()
    assert obj_storage._backend is None

    # Idempotent when there is nothing to close.
    await close_storage_backend()
    backend.close.assert_awaited_once()
