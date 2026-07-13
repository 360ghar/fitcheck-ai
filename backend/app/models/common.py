"""
Shared response envelope used across the API: {"data": ..., "message": "OK"}.
"""

from typing import Generic, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class DataResponse(BaseModel, Generic[T]):
    """Generic wrapper for the {"data": ..., "message": "..."} envelope,
    so a route can declare `response_model=DataResponse[SomeModel]` and get
    real validation/OpenAPI docs on `data` without changing the envelope
    shape existing clients already parse."""

    data: T
    message: str = "OK"
