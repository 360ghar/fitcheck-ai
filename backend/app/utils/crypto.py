"""
Purpose-scoped key derivation from a single root secret (AI_ENCRYPTION_KEY).

Previously three services independently derived from the same raw secret:
- ai_settings_service.py and social_auth_service.py both did
  sha256(raw_key) -> base64 -> Fernet key (the *same* derived key for two
  unrelated ciphertext domains: user AI-provider API keys vs. social-scraper
  auth sessions).
- social_oauth_service.py used the raw key bytes directly as an HMAC secret
  for OAuth CSRF state signing (a third domain, no derivation at all).

One key controlling three cryptographic purposes means rotating it to
contain a leak in one subsystem invalidates the other two as well. HKDF with
a distinct `purpose` label per caller derives independent keys from the same
root secret, so a leak or rotation in one domain doesn't touch the others.
"""

import base64
import hashlib
from typing import Optional

from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF


def _raw_key_bytes(secret: str) -> bytes:
    """Match the pre-existing convention: a 64-char value is treated as a
    hex-encoded 32-byte key, anything else as a raw passphrase."""
    if len(secret) == 64:
        try:
            return bytes.fromhex(secret)
        except ValueError:
            pass
    return secret.encode("utf-8")


def derive_key(secret: str, purpose: bytes, length: int = 32) -> bytes:
    """HKDF-derive a purpose-specific key from a single root secret."""
    raw = _raw_key_bytes(secret)
    return HKDF(algorithm=hashes.SHA256(), length=length, salt=None, info=purpose).derive(raw)


def derive_fernet_key(secret: str, purpose: bytes) -> bytes:
    """HKDF-derive a purpose-specific, base64-encoded Fernet key."""
    return base64.urlsafe_b64encode(derive_key(secret, purpose))


def legacy_derive_fernet_key(secret: str) -> Optional[bytes]:
    """The pre-domain-separation derivation: sha256(raw_key) -> base64.

    Kept ONLY as a decrypt fallback so ciphertext written before this change
    remains readable. Never use this for new encryption - new writes always
    go through derive_fernet_key with a purpose label.
    """
    if not secret:
        return None
    raw = _raw_key_bytes(secret)
    return base64.urlsafe_b64encode(hashlib.sha256(raw).digest())
