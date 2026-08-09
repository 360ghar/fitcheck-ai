/**
 * URL-first success path (the 2026-08-09 default): the backend persists the
 * render and returns `{ image_base64: "", image_url: <presigned>, ... }`.
 *
 * Regression lock: a URL-first response must advance the wizard to the Result
 * step and render the image from `image_url` — the page must NOT bounce back
 * to the Options step, and must NOT render the base64 fallback when the URL
 * is present.
 */
import { describe, it, expect, vi, beforeEach, beforeAll } from 'vitest'
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react'

let dropClothes: ((file: File) => void) | null = null

beforeAll(() => {
  // jsdom's URL lacks the object-URL helpers; TryOnPage's unmount cleanup
  // (and the blob fallback path) call them when a preview was set.
  if (typeof URL.createObjectURL !== 'function') {
    URL.createObjectURL = () => 'blob:test-stub'
  }
  if (typeof URL.revokeObjectURL !== 'function') {
    URL.revokeObjectURL = () => {}
  }
})

vi.mock('react-dropzone', () => ({
  useDropzone: (opts: { onDrop: (files: File[]) => void }) => {
    dropClothes = (file: File) => opts.onDrop([file])
    return {
      getRootProps: () => ({ 'data-testid': 'dropzone' }),
      getInputProps: () => ({}),
      isDragActive: false,
    }
  },
}))

vi.mock('@/api/ai', () => ({ generateTryOn: vi.fn() }))
vi.mock('@/api/users', () => ({ uploadAvatar: vi.fn() }))
vi.mock('@/api/images', () => ({ getPresignedUrl: vi.fn() }))
vi.mock('@/lib/replayable-preview', () => ({
  fileToReplayablePreview: async () => 'data:image/jpeg;base64,preview',
}))

const authState = { setUser: vi.fn(), user: { id: 'u1' } }
vi.mock('@/stores/authStore', () => ({
  useAuthStore: (selector: (s: unknown) => unknown) => selector(authState),
  useCurrentUser: () => authState.user,
  useUserAvatar: () => 'https://example.test/avatar.png',
}))

import { generateTryOn } from '@/api/ai'
import { getPresignedUrl } from '@/api/images'
import { useJobUiStore } from '@/stores/jobUiStore'
import TryOnPage from '@/pages/try-on/TryOnPage'

const URL_FIRST_RESULT = {
  image_base64: '',
  image_url: 'https://f56a221d7170a3355732d3ea52d2164a.r2.cloudflarestorage.com/fitcheck-images/generated/u1/try-on/abc.webp?X-Amz-Signature=deadbeef',
  storage_path: 'generated/u1/try-on/abc.webp',
  prompt: 'Photoreal photo of person A wearing garment B.',
  model: 'agnes-image-2.1-flash',
  provider: 'https://apihub.agnes-ai.com/v1',
}

async function reachOptionsStep() {
  render(<TryOnPage />)
  expect(dropClothes).toBeTruthy()
  await act(async () => {
    dropClothes!(new File(['x'], 'cloth.png', { type: 'image/png' }))
  })
  await screen.findByRole('button', { name: /Generate Try-On/i })
}

beforeEach(() => {
  vi.clearAllMocks()
  useJobUiStore.setState({ job: null })
  dropClothes = null
})

describe('TryOnPage URL-first success path', () => {
  it('advances to the Result step and renders the image from image_url', async () => {
    vi.mocked(generateTryOn).mockResolvedValue(URL_FIRST_RESULT as never)

    await reachOptionsStep()

    fireEvent.click(screen.getByRole('button', { name: /Generate Try-On/i }))

    // Generating surface shows while in flight, then the Result step lands.
    expect(await screen.findByText(/Generating your try-on/i)).toBeTruthy()
    // ZoomableImage renders the img with role="button" when zoomable, so the
    // result image is located by its alt text, not by role.
    const resultImg = await screen.findByAltText('Try-on result')
    expect(resultImg.getAttribute('src')).toBe(URL_FIRST_RESULT.image_url)
    // Not the base64 fallback, and not an empty/broken data URL.
    expect(resultImg.getAttribute('src')).not.toContain('data:image/png;base64,')

    // The wizard stays on Result — never back on Options/Generate.
    expect(screen.queryByRole('button', { name: /Generate Try-On/i })).toBeNull()
    expect(await screen.findByText(/Your Try-On Result/i)).toBeTruthy()
    // The shared job pill was retired.
    expect(useJobUiStore.getState().job).toBeNull()
  })

  it('falls back to the inline base64 data URL when image_url is missing', async () => {
    vi.mocked(generateTryOn).mockResolvedValue({
      ...URL_FIRST_RESULT,
      image_url: '',
      storage_path: '',
      image_base64: 'aGVsbG8=',
    } as never)

    await reachOptionsStep()
    fireEvent.click(screen.getByRole('button', { name: /Generate Try-On/i }))

    const resultImg = await screen.findByAltText('Try-on result')
    expect(resultImg.getAttribute('src')).toBe('data:image/png;base64,aGVsbG8=')
  })

  it('surfaces a visible error instead of a result when the response carries no image at all', async () => {
    // Regression: a 200 with empty image_base64 AND empty image_url used to
    // land a broken Result step with nothing to render. It must fail loudly
    // on Options with a retryable message.
    vi.mocked(generateTryOn).mockResolvedValue({
      ...URL_FIRST_RESULT,
      image_url: '',
      storage_path: '',
      image_base64: '',
    } as never)

    await reachOptionsStep()
    fireEvent.click(screen.getByRole('button', { name: /Generate Try-On/i }))

    expect(await screen.findByText(/came back empty/i)).toBeTruthy()
    // Back on Options (Generate button visible), never a broken Result.
    expect(await screen.findByRole('button', { name: /Generate Try-On/i })).toBeTruthy()
    expect(screen.queryByText(/Your Try-On Result/i)).toBeNull()
  })

  it('re-mints a fresh presigned URL once when the result image fails to load', async () => {
    vi.mocked(generateTryOn).mockResolvedValue(URL_FIRST_RESULT as never)
    vi.mocked(getPresignedUrl).mockResolvedValue('https://example.test/fresh-presigned.webp')

    await reachOptionsStep()
    fireEvent.click(screen.getByRole('button', { name: /Generate Try-On/i }))

    const resultImg = await screen.findByAltText('Try-on result')
    fireEvent.error(resultImg)

    // One re-mint from the durable storage_path, then the img retries.
    await waitFor(() => {
      expect(getPresignedUrl).toHaveBeenCalledTimes(1)
      expect(getPresignedUrl).toHaveBeenCalledWith(URL_FIRST_RESULT.storage_path)
    })
    await waitFor(() => {
      expect(resultImg.getAttribute('src')).toBe('https://example.test/fresh-presigned.webp')
    })
    // Still on the Result step, no error card.
    expect(screen.queryByText(/couldn't load the generated image/i)).toBeNull()
  })

  it('shows a visible error card when the result image fails and no storage_path exists', async () => {
    vi.mocked(generateTryOn).mockResolvedValue({
      ...URL_FIRST_RESULT,
      storage_path: '',
    } as never)

    await reachOptionsStep()
    fireEvent.click(screen.getByRole('button', { name: /Generate Try-On/i }))

    const resultImg = await screen.findByAltText('Try-on result')
    fireEvent.error(resultImg)

    // No storage_path → no re-mint; the broken image is replaced by an error
    // card with a regenerate action instead of a silent broken img.
    expect(getPresignedUrl).not.toHaveBeenCalled()
    expect(await screen.findByText(/couldn't load the generated image/i)).toBeTruthy()
    // The error card's own regenerate action renders (header one included).
    expect(screen.getAllByRole('button', { name: /Regenerate/i }).length).toBeGreaterThanOrEqual(1)
  })

  it('shows a clear error instead of a silent bounce when the API returns an unusable response shape', async () => {
    // generateTryOn normalizes the response wrapper; a shape it cannot
    // unwrap rejects with a coded error. The page must show THAT message on
    // Options — a 200 must never bounce the wizard with a generic failure.
    const err = new Error(
      'Unexpected response format from image generation API'
    ) as Error & { code?: string }
    err.code = 'UNEXPECTED_RESPONSE_FORMAT'
    vi.mocked(generateTryOn).mockRejectedValue(err)

    await reachOptionsStep()
    fireEvent.click(screen.getByRole('button', { name: /Generate Try-On/i }))

    expect(await screen.findByText(/unexpected response format/i)).toBeTruthy()
    expect(await screen.findByRole('button', { name: /Generate Try-On/i })).toBeTruthy()
    expect(screen.queryByText(/Your Try-On Result/i)).toBeNull()
  })

  it('lands the result on a remounted page instead of bouncing to Options', async () => {
    // The response resolves AFTER the page unmounts (navigation/HMR): the
    // module-level result must let the live instance land on Result.
    let resolveGen: ((v: typeof URL_FIRST_RESULT) => void) | null = null
    vi.mocked(generateTryOn).mockImplementation(
      () => new Promise((res) => { resolveGen = res }) as never
    )

    const first = render(<TryOnPage />)
    expect(dropClothes).toBeTruthy()
    await act(async () => {
      dropClothes!(new File(['x'], 'cloth.png', { type: 'image/png' }))
    })
    await screen.findByRole('button', { name: /Generate Try-On/i })
    fireEvent.click(screen.getByRole('button', { name: /Generate Try-On/i }))
    expect(await screen.findByText(/Generating your try-on/i)).toBeTruthy()

    // Remount mid-flight: the shared job pill restores the generating state.
    first.unmount()
    render(<TryOnPage />)
    expect(await screen.findByText(/Generating your try-on/i)).toBeTruthy()

    // The in-flight response resolves on the DEAD instance.
    await act(async () => {
      resolveGen!(URL_FIRST_RESULT)
    })

    // The live instance must land the result — never silently bounce.
    const resultImg = await screen.findByAltText('Try-on result')
    expect(resultImg.getAttribute('src')).toBe(URL_FIRST_RESULT.image_url)
    expect(screen.queryByRole('button', { name: /Generate Try-On/i })).toBeNull()
    expect(useJobUiStore.getState().job).toBeNull()
  })
})
