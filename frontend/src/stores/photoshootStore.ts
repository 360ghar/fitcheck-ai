/**
 * Zustand store for Photoshoot feature
 */

import { create } from 'zustand';
import {
  startPhotoshootJob,
  getPhotoshootJobStatus,
  cancelPhotoshootJob,
  subscribeToPhotoshootEvents,
  getPhotoshootUsage,
  PhotoshootUsage,
  PhotoshootUseCase,
  PhotoshootJobStatusResponse,
  GeneratedImage,
} from '@/api/photoshoot';
import { getApiError, RATE_LIMIT_EXCEEDED } from '@/lib/errors';
import { logger } from '@/lib/logger';
import { fileToReplayablePreview } from '@/lib/replayable-preview';
import { fileToBase64 } from '@/lib/utils';
import { ensureSessionRecording, setPersonProperties, trackEvent } from '@/lib/analytics';
import { useJobUiStore } from '@/stores/jobUiStore';

// Types
export type PhotoshootStep = 'upload' | 'configure' | 'generating' | 'results';

/** Progress floor once generation starts; the remaining span maps to per-image completion. */
const PROGRESS_BASE = 10;
const PROGRESS_SPAN = 90;

const clampNumImages = (remaining: number) => Math.max(1, Math.min(10, remaining));

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/** True when two image lists hold the same images in the same order (id-based, cheap). */
const sameImages = (a: GeneratedImage[], b: GeneratedImage[]) =>
  a.length === b.length && a.every((img, i) => img.id === b[i]?.id && img.index === b[i]?.index);

const sameFailedIndices = (a: number[], b: number[]) =>
  a.length === b.length && a.every((v, i) => v === b[i]);

/**
 * Bounded poller for async jobs: fetches status until a terminal status,
 * `maxAttempts` is exhausted, or `shouldContinue` stops the loop (in which
 * case it returns null — the caller's settle callbacks already resolved the
 * in-flight promise). Used by the SSE-fallback path in `generate` and by the
 * failed-slot retry path.
 */
const pollJob = async (
  jobId: string,
  options: {
    maxAttempts: number;
    intervalMs?: number;
    retryDelayMs?: number;
    timeoutMessage?: string;
    shouldContinue?: () => boolean;
    onUpdate?: (status: PhotoshootJobStatusResponse) => void;
  }
): Promise<PhotoshootJobStatusResponse | null> => {
  const {
    maxAttempts,
    intervalMs = 2000,
    retryDelayMs = 3000,
    timeoutMessage = 'Lost connection while generating. Please try again.',
    shouldContinue,
    onUpdate,
  } = options;
  let attempt = 0;
  while (attempt < maxAttempts) {
    let status: PhotoshootJobStatusResponse;
    try {
      status = await getPhotoshootJobStatus(jobId);
    } catch (err) {
      attempt += 1;
      if (attempt >= maxAttempts) throw err;
      await sleep(retryDelayMs);
      continue;
    }
    onUpdate?.(status);
    if (status.status !== 'pending' && status.status !== 'processing') {
      return status;
    }
    attempt += 1;
    if (attempt >= maxAttempts) {
      throw new Error(timeoutMessage);
    }
    if (shouldContinue && !shouldContinue()) {
      return null;
    }
    await sleep(intervalMs);
  }
  throw new Error(timeoutMessage);
};

interface PhotoshootState {
  // Step state
  currentStep: PhotoshootStep;

  // Upload state
  photos: File[];

  // Configuration state
  useCase: PhotoshootUseCase;
  customPrompt: string;
  numImages: number;

  // Usage state
  usage: PhotoshootUsage | null;
  isLoadingUsage: boolean;

  // Generation state
  isGenerating: boolean;
  /** Honest stage label (not a fake percent) */
  statusMessage: string;
  /** Optional real progress 0–100; null means indeterminate */
  progress: number | null;
  /** Object URLs for source previews during generation */
  photoPreviewUrls: string[];
  /** Current async job id (null when idle) */
  jobId: string;
  /** Scene label currently being generated, e.g. "Sunlit cafe, seated" */
  currentSceneLabel: string | null;
  /** Estimated seconds remaining (rolling average of per-image latency) */
  etaSeconds: number | null;

  // Results state
  sessionId: string;
  generatedImages: GeneratedImage[];
  failedIndices: number[];
  failedCount: number;
  partialSuccess: boolean;
  retryingFailedIndex: number | null;

  // Error state
  error: string | null;

  /** Internal: aborts the in-flight SSE stream (set during generate) */
  _abortSse?: (() => void) | null;
  /**
   * Internal: settles the in-flight generate() promise (set during generate).
   * Lets cancelGeneration resolve the run even when the SSE abort races the
   * job_cancelled event and the stream never delivers a terminal event.
   */
  _settleGeneration?: ((images: GeneratedImage[] | null) => void) | null;

  // Actions
  setStep: (step: PhotoshootStep) => void;
  addPhotos: (files: File[]) => void;
  removePhoto: (index: number) => void;
  setUseCase: (useCase: PhotoshootUseCase) => void;
  setCustomPrompt: (prompt: string) => void;
  setNumImages: (count: number) => void;
  fetchUsage: () => Promise<void>;
  generate: () => Promise<GeneratedImage[] | null>;
  cancelGeneration: () => Promise<void>;
  retryFailedSlot: (index: number) => Promise<void>;
  reset: () => void;
}

const initialState = {
  currentStep: 'upload' as PhotoshootStep,
  photos: [] as File[],
  useCase: 'linkedin' as PhotoshootUseCase,
  customPrompt: '',
  numImages: 10,
  usage: null,
  isLoadingUsage: false,
  isGenerating: false,
  progress: null,
  statusMessage: '',
  photoPreviewUrls: [] as string[],
  jobId: '',
  currentSceneLabel: null,
  etaSeconds: null,
  sessionId: '',
  generatedImages: [],
  failedIndices: [],
  failedCount: 0,
  partialSuccess: false,
  retryingFailedIndex: null,
  error: null,
  _abortSse: null,
  _settleGeneration: null,
};

export const usePhotoshootStore = create<PhotoshootState>()((set, get) => {
  // Shared terminal settle for cancelled runs: the SSE job_cancelled event,
  // the poll fallback, and the local cancelGeneration action all land here.
  const settleCancelled = () => {
    set({
      isGenerating: false,
      currentStep: 'configure',
      statusMessage: '',
      progress: null,
      currentSceneLabel: null,
      etaSeconds: null,
    });
    useJobUiStore.getState().clearJob('photoshoot');
  };

  return {
    ...initialState,

    setStep: (step) => set({ currentStep: step }),

    addPhotos: (files) => {
      const current = get().photos;
      const maxPhotos = 4;
      const newPhotos = [...current, ...files].slice(0, maxPhotos);
      set({ photos: newPhotos, error: null });
    },

    removePhoto: (index) => {
      const current = get().photos;
      set({ photos: current.filter((_, i) => i !== index) });
    },

    setUseCase: (useCase) => {
      set({ useCase });
      if (useCase !== 'custom') {
        set({ customPrompt: '' });
      }
    },

    setCustomPrompt: (prompt) => set({ customPrompt: prompt }),

    setNumImages: (count) => {
      const maxImages = clampNumImages(get().usage?.remaining ?? 10);
      set({ numImages: Math.max(1, Math.min(count, maxImages)) });
    },

    fetchUsage: async () => {
      set({ isLoadingUsage: true });
      try {
        const usage = await getPhotoshootUsage();
        set({ usage, isLoadingUsage: false });

        // Adjust numImages if needed
        const { numImages } = get();
        if (numImages > usage.remaining) {
          set({ numImages: clampNumImages(usage.remaining) });
        }
      } catch (error) {
        logger.warn('Failed to fetch photoshoot usage:', error);
        // Never invent a free-plan entitlement when the usage service is down.
        // Generation must wait until the server confirms the user's allowance.
        set({
          isLoadingUsage: false,
          usage: null,
          error: 'We could not confirm your photoshoot allowance. Try again before generating.',
        });
      }
    },

    generate: async () => {
      const { photos, useCase, customPrompt, numImages, usage, isGenerating } = get();

      // Guard against a second run while one is already in flight. The wizard
      // lets the user step back to configure during generation, and the Generate
      // button is gated on `isGenerating` via `selectCanGenerate` — this store
      // guard is the backstop so a double-click / re-entry can never burn the
      // daily quota twice or race the results.
      if (isGenerating) return null;

      if (photos.length === 0) {
        set({ error: 'Please add at least one photo' });
        return null;
      }

      if (useCase === 'custom' && !customPrompt.trim()) {
        set({ error: 'Please enter a custom prompt' });
        return null;
      }

      if (!usage) {
        set({ error: 'We could not confirm your photoshoot allowance. Try again before generating.' });
        return null;
      }

      if (numImages > usage.remaining) {
        set({ error: 'Not enough images remaining today' });
        return null;
      }

      // Revoke prior previews for the wait surface (they are replay-safe data
      // URLs, downscaled, so they survive PostHog session recordings — blob URLs
      // would render blank at replay time).
      get().photoPreviewUrls.forEach((url) => {
        try {
          URL.revokeObjectURL(url);
        } catch {
          // ignore
        }
      });

      // Set isGenerating BEFORE the async preview build. The `isGenerating` guard
      // above is only meaningful once this flag is set; leaving it until after the
      // `await` would leave a window where a double-click passes the guard and
      // starts a second request (double quota burn).
      set({
        isGenerating: true,
        error: null,
        progress: null,
        statusMessage: 'Preparing your photos…',
        currentStep: 'generating',
        jobId: '',
        currentSceneLabel: null,
        etaSeconds: null,
      });

      const photoPreviewUrls = await Promise.all(photos.map(fileToReplayablePreview));
      set({ photoPreviewUrls });

      ensureSessionRecording();
      trackEvent('photoshoot_session_started', {
        use_case: useCase,
        num_images: numImages,
        photo_count: photos.length,
        source: 'web_app',
      });

      try {
        set({ statusMessage: 'Encoding photos…', progress: null });

        const photosBase64 = await Promise.all(photos.map(fileToBase64));

        set({
          statusMessage: `Starting ${numImages} image${numImages === 1 ? '' : 's'}…`,
          progress: null,
        });

        // Start the async job; the backend returns immediately with a job_id.
        const start = await startPhotoshootJob({
          photos: photosBase64,
          use_case: useCase,
          custom_prompt: useCase === 'custom' ? customPrompt : undefined,
          num_images: numImages,
        });

        set({ jobId: start.job_id, statusMessage: 'Planning your scenes…' });

        // Drive the run from SSE events. Returns a promise that resolves with
        // the final images on a terminal event, or rejects on failure.
        const images = await new Promise<GeneratedImage[] | null>((resolve, reject) => {
          let settled = false;
          let sawTerminal = false;
          let pollStarted = false;
          // Rolling per-image latency samples for the ETA (seconds per image).
          const latencySamples: number[] = [];
          let lastImageAt = Date.now();
          // scene labels per index from batch_started, so the "now generating"
          // line shows the real scene while its slot is in flight.
          let sceneLabels: Record<string, string> = {};

          const finish = (result: GeneratedImage[] | null) => {
            if (settled) return;
            settled = true;
            resolve(result);
          };

          // Expose the settle callback so cancelGeneration can resolve the run
          // even if the SSE abort beats the job_cancelled event (the abort does
          // not fire onClose, so the stream would otherwise never settle it).
          get()._settleGeneration = finish;

          const fail = (err: unknown) => {
            if (settled) return;
            settled = true;
            reject(err);
          };

          // Terminal settle helpers — shared by the SSE switch and the poll
          // fallback so both paths land in the same state/analytics code.
          const settleComplete = (
            sessionId: string,
            images: GeneratedImage[],
            failedIndices: number[],
            failedCount: number,
            partialSuccess: boolean,
            usageData: PhotoshootUsage | null
          ) => {
            set({
              progress: 100,
              statusMessage: 'Done',
              etaSeconds: null,
              currentSceneLabel: null,
              sessionId,
              failedCount,
              failedIndices,
              partialSuccess,
              currentStep: 'results',
              isGenerating: false,
            });
            if (usageData) set({ usage: usageData });
            trackEvent('photoshoot_session_completed', {
              session_id: sessionId,
              use_case: useCase,
              num_images: numImages,
              generated_count: images.length,
              failed_count: failedCount,
              partial_success: partialSuccess,
              source: 'web_app',
            });
            setPersonProperties({
              last_photoshoot_session_id: sessionId,
              last_photoshoot_at: new Date().toISOString(),
              last_photoshoot_use_case: useCase,
            });
            useJobUiStore.getState().clearJob('photoshoot');
          };

          const settleFailed = (message: string) => {
            set({
              error: message,
              isGenerating: false,
              progress: null,
              statusMessage: 'Generation failed',
              currentSceneLabel: null,
              etaSeconds: null,
              // Stay on generating surface so user can retry without losing photos
              currentStep: 'generating',
            });
            trackEvent('photoshoot_session_failed', {
              use_case: useCase,
              num_images: numImages,
              error_message: message,
              source: 'web_app',
            });
            useJobUiStore.getState().clearJob('photoshoot');
          };

          const computeEta = () => {
            const remaining = numImages - get().generatedImages.length;
            if (latencySamples.length < 2 || remaining <= 0) {
              set({ etaSeconds: null });
              return;
            }
            const avgMs =
              latencySamples.reduce((sum, v) => sum + v, 0) / latencySamples.length;
            set({ etaSeconds: Math.round((avgMs * remaining) / 1000) });
          };

          // Show the next scene whose slot has not produced an image yet.
          const updateCurrentScene = () => {
            const done = new Set(get().generatedImages.map((img) => img.index));
            const label = Object.entries(sceneLabels)
              .map(([index, value]) => ({ index: Number(index), value }))
              .sort((a, b) => a.index - b.index)
              .find((entry) => !done.has(entry.index))?.value;
            set({ currentSceneLabel: label ?? null });
          };

          // Mirror poll progress into the store, skipping no-op updates so
          // zustand subscribers are not notified every tick.
          const applyPollUpdate = (status: PhotoshootJobStatusResponse) => {
            const pollImages = [...status.images].sort((a, b) => a.index - b.index);
            if (pollImages.length > 0 && !sameImages(get().generatedImages, pollImages)) {
              set({ generatedImages: pollImages });
            }
            if (status.total_count > 0) {
              const progress = Math.min(
                100,
                PROGRESS_BASE + (status.generated_count / status.total_count) * PROGRESS_SPAN
              );
              if (progress !== get().progress) set({ progress });
            }
            const failedIndices = [...status.failed_indices].sort((a, b) => a - b);
            if (!sameFailedIndices(get().failedIndices, failedIndices)) {
              set({
                failedIndices,
                failedCount: status.failed_count ?? failedIndices.length,
                partialSuccess: Boolean(status.partial_success ?? failedIndices.length > 0),
              });
            }
          };

          const startPollFallback = () => {
            pollStarted = true;
            void (async () => {
              try {
                const terminal = await pollJob(start.job_id, {
                  maxAttempts: 90, // ~3 minutes at 2s cadence
                  shouldContinue: () => get().isGenerating && !settled,
                  onUpdate: applyPollUpdate,
                });
                // null means the run was cancelled mid-poll; already settled.
                if (terminal === null) return;
                const pollImages = [...terminal.images].sort((a, b) => a.index - b.index);
                if (terminal.status === 'complete') {
                  // The status payload does not carry session_id; the job id
                  // is the stable identifier used for the session.
                  settleComplete(
                    start.job_id,
                    pollImages,
                    [...terminal.failed_indices].sort((a, b) => a - b),
                    terminal.failed_count ?? terminal.failed_indices.length,
                    Boolean(terminal.partial_success ?? terminal.failed_indices.length > 0),
                    terminal.usage ?? null
                  );
                  finish(pollImages);
                } else if (terminal.status === 'failed') {
                  settleFailed(terminal.error ?? 'Generation failed');
                  // Resolve (not reject): the failure state + analytics were
                  // already handled here; rejecting would re-enter the outer
                  // catch and double-track the session_failed event.
                  finish(null);
                } else if (terminal.status === 'cancelled') {
                  settleCancelled();
                  finish(null);
                }
              } catch (err) {
                fail(err);
              }
            })();
          };

          const disconnect = subscribeToPhotoshootEvents(
            start.job_id,
            (event) => {
              const data = (event.data ?? {}) as Record<string, unknown>;
              switch (event.type) {
                case 'generation_started':
                  set({
                    statusMessage: `Generating ${numImages} image${numImages === 1 ? '' : 's'}…`,
                    progress: PROGRESS_BASE,
                  });
                  break;

                case 'batch_started':
                  if (data.scene_labels && typeof data.scene_labels === 'object') {
                    sceneLabels = data.scene_labels as Record<string, string>;
                    updateCurrentScene();
                  }
                  break;

                case 'image_complete': {
                  const image = data as unknown as GeneratedImage;
                  if (!image?.id) return;
                  const next = [
                    ...get().generatedImages.filter((img) => img.index !== image.index),
                    image,
                  ].sort((a, b) => a.index - b.index);
                  const now = Date.now();
                  latencySamples.push(now - lastImageAt);
                  lastImageAt = now;
                  set({
                    generatedImages: next,
                    progress: Math.min(100, PROGRESS_BASE + (next.length / numImages) * PROGRESS_SPAN),
                    statusMessage: `Generated ${next.length}/${numImages} image${next.length === 1 ? '' : 's'}…`,
                  });
                  updateCurrentScene();
                  computeEta();
                  break;
                }

                case 'image_failed': {
                  const index = data.index as number | undefined;
                  if (index === undefined) return;
                  // Replay-safe: never append a duplicate failed index.
                  const failedIndices = get().failedIndices.includes(index)
                    ? get().failedIndices
                    : [...get().failedIndices, index].sort((a, b) => a - b);
                  const failedCount = (data.failed_count as number | undefined) ?? failedIndices.length;
                  set({ failedIndices, failedCount, partialSuccess: failedCount > 0 });
                  break;
                }

                case 'job_complete': {
                  sawTerminal = true;
                  const usageData = (data.usage ?? null) as PhotoshootUsage | null;
                  const finalImages = get().generatedImages;
                  const failedIndices = [
                    ...((data.failed_indices as number[] | undefined) ?? get().failedIndices),
                  ].sort((a, b) => a - b);
                  const failedCount = (data.failed_count as number | undefined) ?? failedIndices.length;
                  settleComplete(
                    (data.session_id as string | undefined) ?? start.job_id,
                    finalImages,
                    failedIndices,
                    failedCount,
                    Boolean(data.partial_success ?? failedCount > 0),
                    usageData
                  );
                  finish(finalImages);
                  break;
                }

                case 'job_failed': {
                  sawTerminal = true;
                  settleFailed((data.error as string | undefined) || 'Generation failed');
                  // Resolve (not reject): the failure state + analytics were
                  // already handled here; rejecting would re-enter the outer
                  // catch and double-track the session_failed event.
                  finish(null);
                  break;
                }

                case 'job_cancelled': {
                  sawTerminal = true;
                  settleCancelled();
                  finish(null);
                  break;
                }

                default:
                  break;
              }
            },
            () => {
              // SSE connection error — fall back to polling (bounded).
              if (!sawTerminal && !pollStarted) {
                startPollFallback();
              }
            },
            (sawTerminalOnClose) => {
              // Stream ended without a terminal event: reconcile via polling.
              if (!sawTerminalOnClose && !sawTerminal && !pollStarted && !settled) {
                startPollFallback();
              }
            }
          );

          // Keep the connection open until a terminal event settles the promise.
          // If the run is cancelled locally, abort the stream.
          get()._abortSse = disconnect;
        });

        // The promise resolved above; if the run was cancelled, images is null.
        if (images === null) return null;

        set({ generatedImages: images });
        return images;
      } catch (error) {
        const apiError = getApiError(error);
        set({
          // Friendly copy only — the backend logs the diagnostic detail. The
          // user's own plan limit and upstream capacity failures must not be
          // conflated: the former is a quota wall, the latter "try again".
          error:
            apiError.code === RATE_LIMIT_EXCEEDED
              ? 'You have reached your daily photoshoot limit. It resets at midnight UTC.'
              : apiError.errorKind === 'upstream_quota' || apiError.errorKind === 'transient'
                ? 'Our AI service is busy. Please try again in a few minutes.'
                : apiError.message,
          isGenerating: false,
          progress: null,
          statusMessage: 'Generation failed',
          currentSceneLabel: null,
          etaSeconds: null,
          // Stay on generating surface so user can retry without losing photos
          currentStep: 'generating',
        });
        // A hard quota wall means the stored `usage.remaining` is now stale —
        // refresh it so the configure step renders the real 0-remaining wall and
        // the "Try again" button cannot loop into another 429.
        if (apiError.code === RATE_LIMIT_EXCEEDED) {
          void get().fetchUsage();
        }
        trackEvent('photoshoot_session_failed', {
          use_case: useCase,
          num_images: numImages,
          error_message: apiError.message,
          source: 'web_app',
        });
        useJobUiStore.getState().clearJob('photoshoot');
        return null;
      } finally {
        // Always release the SSE stream once the promise settles.
        try {
          get()._abortSse?.();
        } catch {
          // ignore
        }
        get()._settleGeneration = null;
      }
    },

    cancelGeneration: async () => {
      const { jobId } = get();
      if (!jobId) return;

      try {
        await cancelPhotoshootJob(jobId);
      } catch (e) {
        logger.warn('Failed to cancel photoshoot job:', e);
      }

      // Abort the SSE stream; the terminal job_cancelled event (or the abort
      // itself) settles the run.
      try {
        get()._abortSse?.();
      } catch {
        // ignore
      }

      // Settle the in-flight generate() promise. If the job_cancelled SSE event
      // already fired, this is a no-op (settled guard); if the abort won the
      // race, this is the only thing that resolves the run.
      try {
        get()._settleGeneration?.(null);
      } catch {
        // ignore
      }
      get()._settleGeneration = null;

      settleCancelled();
      set({ jobId: '' });
    },

    retryFailedSlot: async (index) => {
      const { photos, useCase, customPrompt, usage, failedIndices, generatedImages } = get();

      if (!failedIndices.includes(index)) return;
      if (photos.length === 0) return;
      if (usage && usage.remaining <= 0) {
        set({ error: 'Not enough images remaining today' });
        return;
      }

      set({ retryingFailedIndex: index, error: null });

      try {
        const photosBase64 = await Promise.all(photos.map(fileToBase64));

        // Retry the single failed slot through the async job flow (same path as
        // generate): start a 1-image job, then poll status until terminal.
        const start = await startPhotoshootJob({
          photos: photosBase64,
          use_case: useCase,
          custom_prompt: useCase === 'custom' ? customPrompt : undefined,
          num_images: 1,
        });

        const terminal = await pollJob(start.job_id, {
          maxAttempts: 120, // ~4 minutes at 2s cadence
          timeoutMessage: 'Retry timed out. Please try again.',
        });
        // Never null here: retries pass no `shouldContinue`, so the loop only
        // exits on a terminal status or an exhausted attempt budget.
        if (terminal === null) {
          throw new Error('Retry timed out. Please try again.');
        }

        const imgs = [...terminal.images].sort((a, b) => a.index - b.index);
        if (imgs.length === 0) {
          if (terminal.status === 'failed' || terminal.status === 'cancelled') {
            throw new Error(terminal.error ?? 'Retry failed. Please try again.');
          }
          throw new Error('Retry completed but returned no image. Please try again.');
        }

        const retriedImage = imgs[0];
        const patchedImage: GeneratedImage = { ...retriedImage, index };
        const nextImages = [...generatedImages.filter((img) => img.index !== index), patchedImage]
          .sort((a, b) => a.index - b.index);
        const nextFailed = failedIndices.filter((i) => i !== index).sort((a, b) => a - b);

        set({
          generatedImages: nextImages,
          failedIndices: nextFailed,
          failedCount: nextFailed.length,
          partialSuccess: nextFailed.length > 0,
          retryingFailedIndex: null,
        });

        // The 1-image retry job reports usage only through the status payload.
        if (terminal.usage) {
          set({ usage: terminal.usage });
        }
      } catch (error) {
        const apiError = getApiError(error);
        set({
          error:
            apiError.code === RATE_LIMIT_EXCEEDED
              ? 'You have reached your daily photoshoot limit. It resets at midnight UTC.'
              : apiError.message,
          retryingFailedIndex: null,
        });
        // Same stale-usage refresh as `generate`: don't let a retry loop into 429s.
        if (apiError.code === RATE_LIMIT_EXCEEDED) {
          void get().fetchUsage();
        }
      }
    },

    reset: () => {
      // Abort any in-flight SSE stream before tearing state down.
      try {
        get()._abortSse?.();
      } catch {
        // ignore
      }
      try {
        get()._settleGeneration?.(null);
      } catch {
        // ignore
      }
      get()._settleGeneration = null;
      get().photoPreviewUrls.forEach((url) => {
        try {
          URL.revokeObjectURL(url);
        } catch {
          // ignore
        }
      });
      set({
        ...initialState,
        usage: get().usage, // Preserve usage info
        photoPreviewUrls: [],
      });
      // Fire and forget - don't block reset on usage fetch
      void get().fetchUsage();
    },
  };
});

// Selectors
export const selectCanGenerate = (state: PhotoshootState) => {
  const { photos, useCase, customPrompt, numImages, usage, isGenerating } = state;
  if (isGenerating) return false;
  if (photos.length === 0) return false;
  if (useCase === 'custom' && !customPrompt.trim()) return false;
  if (!usage) return false;
  if (numImages > usage.remaining) return false;
  return true;
};

export const selectEffectiveMaxImages = (state: PhotoshootState) =>
  clampNumImages(state.usage?.remaining ?? 10);

// Hooks
export function usePhotoshoot() {
  return usePhotoshootStore();
}

export function useCanGenerate() {
  return usePhotoshootStore(selectCanGenerate);
}
