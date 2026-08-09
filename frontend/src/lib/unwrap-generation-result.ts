/**
 * Normalize an AI generation response payload to the result object.
 *
 * The canonical envelope is `{data: T, message}` — but production has also
 * been observed returning an ARRAY (`[{data: T}]` / `[T]`) for the same call
 * (response-shape drift between deployments), and legacy surfaces return the
 * bare object. A 200 with a wrapper-shape mismatch used to resolve to
 * `undefined`, which bounced the try-on wizard back to Options with a generic
 * error (or a blank Result step before the result-path hardening). Accept all
 * three shapes; throw a descriptive, coded error for anything else so callers
 * surface a real message instead of a silent blank result.
 *
 * Lives in `lib/` (pure, zero imports) so the public landing page's demo
 * calls can share it without pulling the API client into that bundle.
 *
 * @throws Error with `code === 'UNEXPECTED_RESPONSE_FORMAT'` when the payload
 *         carries no usable result object.
 */
export function unwrapGenerationResult<T>(payload: unknown): T {
  if (Array.isArray(payload)) {
    const first = payload[0];
    if (first && typeof first === 'object') {
      const data = (first as { data?: unknown }).data;
      if (data && typeof data === 'object') return data as T;
      return first as T;
    }
  } else if (payload && typeof payload === 'object') {
    const data = (payload as { data?: unknown }).data;
    if (data && typeof data === 'object') return data as T;
    return payload as T;
  }
  const err = new Error(
    'Unexpected response format from image generation API'
  ) as Error & { code?: string };
  err.code = 'UNEXPECTED_RESPONSE_FORMAT';
  throw err;
}
