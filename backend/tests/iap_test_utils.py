"""Shared helpers for mobile IAP tests.

Generates throwaway EC/RSA keys and certificates so the JWS verification
code can be exercised with real signatures (a real Apple-signed payload is
not available in tests).
"""
import base64
import json
from datetime import datetime, timedelta, timezone

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec, rsa
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature
from cryptography.x509.oid import NameOID


def b64u(data: bytes) -> str:
    """Encode bytes as unpadded base64url."""
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def make_ca_cert(key, name="Test Root CA"):
    """Create a self-signed CA certificate for the given key."""
    subject = issuer = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, name)])
    return (
        x509.CertificateBuilder()
        .subject_name(subject)
        .issuer_name(issuer)
        .public_key(key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(datetime.now(timezone.utc) - timedelta(days=1))
        .not_valid_after(datetime.now(timezone.utc) + timedelta(days=365))
        .add_extension(x509.BasicConstraints(ca=True, path_length=None), critical=True)
        .sign(key, hashes.SHA256())
    )


def make_leaf_cert(leaf_key, ca_key, ca_cert, name="Test Leaf", not_valid_after=None):
    """Create a leaf certificate issued by the given CA."""
    subject = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, name)])
    return (
        x509.CertificateBuilder()
        .subject_name(subject)
        .issuer_name(ca_cert.subject)
        .public_key(leaf_key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(datetime.now(timezone.utc) - timedelta(days=1))
        .not_valid_after(not_valid_after or (datetime.now(timezone.utc) + timedelta(days=30)))
        .add_extension(x509.BasicConstraints(ca=False, path_length=None), critical=True)
        .sign(ca_key, hashes.SHA256())
    )


def cert_der(cert) -> str:
    """DER-encode a certificate as base64 (x5c array element shape)."""
    return base64.b64encode(cert.public_bytes(serialization.Encoding.DER)).decode("ascii")


def sign_jws(payload: dict, leaf_key, chain_certs) -> str:
    """Sign a payload as an ES256 JWS with an x5c chain (leaf first)."""
    header = {
        "alg": "ES256",
        "x5c": [cert_der(cert) for cert in chain_certs],
    }
    signing_input = f"{b64u(json.dumps(header).encode())}.{b64u(json.dumps(payload).encode())}"
    der_signature = leaf_key.sign(signing_input.encode("ascii"), ec.ECDSA(hashes.SHA256()))
    r, s = decode_dss_signature(der_signature)
    signature = r.to_bytes(32, "big") + s.to_bytes(32, "big")
    return f"{signing_input}.{b64u(signature)}"


def make_ec_key():
    """A fresh P-256 private key (Apple's notification signing curve)."""
    return ec.generate_private_key(ec.SECP256R1())


def make_ec_key_pem():
    """A fresh P-256 private key as PKCS8 PEM (App Store API key shape)."""
    key = make_ec_key()
    return key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption(),
    ).decode("utf-8")


def make_rsa_key_pem():
    """A fresh RSA private key as PKCS8 PEM (Google service account shape)."""
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    return key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption(),
    ).decode("utf-8")


def make_rsa_public_pem(key):
    """The public key PEM for an RSA key (OIDC cert shape)."""
    return key.public_key().public_bytes(
        serialization.Encoding.PEM,
        serialization.PublicFormat.SubjectPublicKeyInfo,
    ).decode("utf-8")
