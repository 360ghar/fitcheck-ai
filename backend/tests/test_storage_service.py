import threading

import pytest

from app.services.storage_service import StorageService


class FakeBucket:
    def __init__(self):
        self.upload_calls = []
        self.upload_thread_id = None

    def upload(self, path, file, file_options=None):
        self.upload_thread_id = threading.get_ident()
        self.upload_calls.append((path, file))

    def get_public_url(self, path):
        return f"https://example.com/{path}"


class FakeStorage:
    def __init__(self):
        self.bucket = FakeBucket()

    def from_(self, bucket_name):
        return self.bucket


class FakeDB:
    def __init__(self):
        self.storage = FakeStorage()


@pytest.mark.asyncio
async def test_upload_item_image_offloads_blocking_call_to_thread():
    # ponytail: regression check for the asyncio.to_thread wrap — a blocking
    # supabase call back on the event-loop thread serializes concurrent uploads.
    db = FakeDB()
    main_thread_id = threading.get_ident()

    result = await StorageService.upload_item_image(
        db=db,
        user_id="user-1",
        filename="shirt.jpg",
        file_data=b"fake-bytes",
    )

    assert db.storage.bucket.upload_calls
    assert db.storage.bucket.upload_thread_id != main_thread_id
    assert result["image_url"] == f"https://example.com/{db.storage.bucket.upload_calls[0][0]}"
