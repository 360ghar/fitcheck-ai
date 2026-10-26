#!/usr/bin/env python3
"""Agnes AI text transport, a drop-in replacement for `call_gemini`.

The Gemini free tier is 500 requests per DAY per model, and one full
localization pass over 49 locales at 30 keys per request needs roughly 1,000.
Three models on the same key all return `DAILY QUOTA SPENT` partway through, so
the catalog pass cannot finish in a day. Agnes `agnes-3.0-flash` allows 1,500
requests per 5 hours, which covers a full pass with room for retries.

The public surface matches `translate_listings.call_gemini` exactly —
`(api_key, prompt, retries=3, system=None, max_output_tokens=8192)` returning a
string — so `translate_arb.py` can swap transports without knowing which one ran.
`api_key` is accepted and ignored: Agnes reads `AGNES_AI_API_KEY` from the
environment, and keeping the parameter means no caller changes.
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ENDPOINT = "https://apihub.agnes-ai.com/v1/chat/completions"
MODEL = "agnes-3.0-flash"

# 429 means the per-minute allowance is gone; 5xx means the model is busy. Both
# clear in seconds, unlike a daily cap, so a short backoff is the right shape.
RETRYABLE = {429, 500, 502, 503, 504}


def api_key() -> str:
    """The key from the environment, or from `~/.zshrc` where it normally lives.

    Shell startup files are read as a last resort because this runs from cron,
    CI and background jobs where `~/.zshrc` was never sourced.
    """
    value = os.environ.get("AGNES_AI_API_KEY")
    if value:
        return value.strip()
    zshrc = Path.home() / ".zshrc"
    if zshrc.exists():
        for line in zshrc.read_text(encoding="utf-8", errors="ignore").splitlines():
            line = line.strip()
            if line.startswith("export "):
                line = line[len("export ") :]
            if line.startswith("AGNES_AI_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    raise RuntimeError("AGNES_AI_API_KEY is not set and was not found in ~/.zshrc")


def call_agnes(
    api_key_ignored: str | None,
    prompt: str,
    retries: int = 3,
    system: str | None = None,
    max_output_tokens: int = 8192,
) -> str:
    """One chat completion, returning the assistant text.

    Raises RuntimeError on a non-retryable failure so the caller can decide
    whether to halve the chunk, same as the Gemini path.
    """
    key = api_key()
    body = {
        "model": MODEL,
        "messages": [
            {"role": "system", "content": system or "You translate application strings."},
            {"role": "user", "content": prompt},
        ],
        "temperature": 0.2,
        "max_tokens": max_output_tokens,
        # `response_format` belongs in `extra_body`, never at the top level. Its
        # value is the object form: the bare string "json_object" is rejected
        # with "expected internally tagged enum ResponseFormat".
        "extra_body": {"response_format": {"type": "json_object"}},
    }
    payload = json.dumps(body).encode("utf-8")
    last_error = ""
    for attempt in range(retries + 1):
        request = urllib.request.Request(
            ENDPOINT,
            data=payload,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {key}",
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=180) as response:
                data = json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as error:
            detail = error.read().decode("utf-8", errors="ignore")
            last_error = f"HTTP {error.code}: {detail[:300]}"
            if error.code in RETRYABLE and attempt < retries:
                time.sleep(min(60, 5 * (2**attempt)))
                continue
            raise RuntimeError(last_error) from None
        except (urllib.error.URLError, TimeoutError) as error:
            last_error = str(error)
            if attempt < retries:
                time.sleep(min(60, 5 * (2**attempt)))
                continue
            raise RuntimeError(last_error) from None
        try:
            return data["choices"][0]["message"]["content"]
        except (KeyError, IndexError):
            raise RuntimeError(f"unexpected response shape: {json.dumps(data)[:300]}") from None
    raise RuntimeError(last_error or "agnes call failed")


if __name__ == "__main__":
    print(call_agnes(None, sys.argv[1] if len(sys.argv) > 1 else "Say OK"))
