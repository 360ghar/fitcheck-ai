import { describe, it, expect, vi, afterEach } from 'vitest';
import { fileToReplayablePreview } from '@/lib/replayable-preview';

function makeFile(size: number, type = 'image/jpeg', name = 'photo.jpg'): File {
  return new File([new Uint8Array(size)], name, { type });
}

afterEach(() => {
  vi.restoreAllMocks();
});

// jsdom does not implement createObjectURL/revokeObjectURL, createImageBitmap,
// or real canvas drawing. Stub them so the interesting paths can be exercised.
URL.createObjectURL ??= vi.fn(() => `blob:mock-${Math.random().toString(36).slice(2)}`);
URL.revokeObjectURL ??= vi.fn();

function stubCanvas(ctx: Record<string, unknown>) {
  Object.defineProperty(HTMLCanvasElement.prototype, 'getContext', {
    configurable: true,
    value: vi.fn(() => ctx),
  });
}

describe('fileToReplayablePreview', () => {
  it('returns a data URL for small images without canvas work', async () => {
    const file = makeFile(1000);
    const url = await fileToReplayablePreview(file);
    expect(url.startsWith('data:image/jpeg;base64,')).toBe(true);
  });

  it('downscales large images through the canvas to a data URL', async () => {
    // jsdom cannot decode images; the canvas path is reached via the
    // createImageBitmap stub (which resolves), then canvas.toDataURL is
    // stubbed per-instance (overriding jsdom's generated wrapper).
    const ctx = {
      fillStyle: '',
      fillRect: vi.fn(),
      drawImage: vi.fn(),
    };
    stubCanvas(ctx);
    const toDataURL = vi.fn(() => 'data:image/jpeg;base64,stub');
    Object.defineProperty(HTMLCanvasElement.prototype, 'toDataURL', {
      configurable: true,
      value: toDataURL,
    });
    vi.stubGlobal(
      'createImageBitmap',
      vi.fn(async () => ({ width: 1600, height: 1200, close: vi.fn() }))
    );

    const file = makeFile(500_000);
    const url = await fileToReplayablePreview(file);
    expect(url.startsWith('data:')).toBe(true);
    expect(toDataURL).toHaveBeenCalledWith('image/jpeg', 0.8);
  });

  it('re-encodes large files even when dimensions are already small', async () => {
    // A >200KB file with small dimensions (e.g. animated GIF) must still go
    // through the canvas so a multi-MB raw data URL cannot bloat recordings.
    const toDataURL = vi.fn(() => 'data:image/jpeg;base64,stub');
    Object.defineProperty(HTMLCanvasElement.prototype, 'toDataURL', {
      configurable: true,
      value: toDataURL,
    });
    stubCanvas({ fillStyle: '', fillRect: vi.fn(), drawImage: vi.fn() });
    vi.stubGlobal(
      'createImageBitmap',
      vi.fn(async () => ({ width: 320, height: 240, close: vi.fn() }))
    );

    const file = makeFile(500_000, 'image/gif', 'anim.gif');
    const url = await fileToReplayablePreview(file);
    expect(url.startsWith('data:')).toBe(true);
    expect(toDataURL).toHaveBeenCalledWith('image/jpeg', 0.8);
  });

  it('falls back to a blob URL when the image cannot be decoded', async () => {
    // Decode fails both via createImageBitmap and the <img> fallback (jsdom
    // cannot decode images and never fires onload/onerror) — so loadImage
    // rejects and fileToReplayablePreview falls back to a blob URL.
    const file = makeFile(500_000, 'image/png', 'broken.png');
    vi.stubGlobal('createImageBitmap', vi.fn().mockRejectedValue(new Error('decode failed')));
    vi.useFakeTimers();

    const promise = fileToReplayablePreview(file);
    await vi.advanceTimersByTimeAsync(10_001); // loadImage's 10s decode timeout
    const url = await promise;

    vi.useRealTimers();
    expect(url.startsWith('blob:')).toBe(true);
  });

  it('falls back to a blob URL when canvas encoding is unavailable', async () => {
    // Force the jsdom generated canvas.toDataURL to return null (its native
    // behavior without the canvas npm package) so the helper falls back.
    Object.defineProperty(HTMLCanvasElement.prototype, 'toDataURL', {
      configurable: true,
      value: vi.fn(() => null),
    });
    const ctx = {
      fillStyle: '',
      fillRect: vi.fn(),
      drawImage: vi.fn(),
    };
    stubCanvas(ctx);
    vi.stubGlobal(
      'createImageBitmap',
      vi.fn(async () => ({ width: 1600, height: 1200, close: vi.fn() }))
    );

    const file = makeFile(500_000);
    const url = await fileToReplayablePreview(file);
    expect(url.startsWith('blob:')).toBe(true);
  });
});
