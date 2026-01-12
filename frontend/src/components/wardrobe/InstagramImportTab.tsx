/**
 * InstagramImportTab Component
 *
 * Main container for the Instagram import flow.
 * Orchestrates: Auth check → URL input → scraping → image selection → batch preparation.
 */

import { useState, useCallback, useEffect } from 'react';
import { Loader2 } from 'lucide-react';
import { InstagramURLInput } from './InstagramURLInput';
import { InstagramScrapeProgress } from './InstagramScrapeProgress';
import { InstagramImageGrid } from './InstagramImageGrid';
import { InstagramLoginForm } from './InstagramLoginForm';
import type { InstagramImageMeta, InstagramProfileInfo } from '@/types';
import {
  startInstagramScrape,
  cancelInstagramScrape,
  createInstagramSSEConnection,
  prepareBatchFromInstagram,
  loginInstagram,
  logoutInstagram,
  getInstagramCredentialsStatus,
  ensureInstagramSession,
  type InstagramScrapeProgressData,
  type InstagramCredentialsStatus,
} from '@/api/instagram';

type ImportStep = 'auth' | 'input' | 'loading' | 'scraping' | 'selecting' | 'preparing';

interface InstagramImportTabProps {
  onBatchReady: (batchJobId: string, sseUrl: string) => void;
  maxImages?: number;
  disabled?: boolean;
}

export function InstagramImportTab({
  onBatchReady,
  maxImages = 50,
  disabled = false,
}: InstagramImportTabProps) {
  const [step, setStep] = useState<ImportStep>('auth');
  const [url, setUrl] = useState('');
  const [urlError, setUrlError] = useState<string | null>(null);
  const [profileInfo, setProfileInfo] = useState<InstagramProfileInfo | null>(null);

  // Auth state
  const [credentialsStatus, setCredentialsStatus] = useState<InstagramCredentialsStatus | null>(null);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);

  // Scraping state
  const [jobId, setJobId] = useState<string | null>(null);
  const [scrapedImages, setScrapedImages] = useState<InstagramImageMeta[]>([]);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [scrapeProgress, setScrapeProgress] = useState({ scraped: 0, total: 0 });
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Cleanup SSE on unmount
  const [disconnectSSE, setDisconnectSSE] = useState<(() => void) | null>(null);

  useEffect(() => {
    return () => {
      if (disconnectSSE) {
        disconnectSSE();
      }
    };
  }, [disconnectSSE]);

  // Check auth status on mount
  useEffect(() => {
    const checkAuth = async () => {
      setIsCheckingAuth(true);
      try {
        const status = await getInstagramCredentialsStatus();
        setCredentialsStatus(status);

        if (status.has_credentials && status.is_valid) {
          setStep('input');
        } else {
          setStep('auth');
        }
      } catch {
        setStep('auth');
      } finally {
        setIsCheckingAuth(false);
      }
    };

    checkAuth();
  }, []);

  // Handle login
  const handleLogin = useCallback(async (username: string, password: string) => {
    try {
      const result = await loginInstagram(username, password);
      if (result.success) {
        setCredentialsStatus({
          has_credentials: true,
          is_valid: true,
          username: result.username,
        });
        setStep('input');
      }
      return result;
    } catch (err) {
      return { success: false, error: err instanceof Error ? err.message : 'Login failed' };
    }
  }, []);

  // Handle logout
  const handleLogout = useCallback(async () => {
    try {
      await logoutInstagram();
    } catch {
      // Ignore errors
    }
    setCredentialsStatus(null);
    setStep('auth');
  }, []);

  // Handle URL validation
  const handleValidated = useCallback((_type: 'profile' | 'post' | 'reel', _id: string) => {
    setUrlError(null);
  }, []);

  // Handle profile check
  const handleProfileChecked = useCallback((profile: InstagramProfileInfo) => {
    setProfileInfo(profile);
  }, []);

  // Start scraping
  const handleStartScraping = useCallback(async () => {
    if (!url || urlError) return;

    setStep('loading');
    setError(null);
    setScrapedImages([]);
    setSelectedIds(new Set());
    setScrapeProgress({ scraped: 0, total: 0 });

    try {
      // Ensure session is active before scraping
      const sessionResult = await ensureInstagramSession();
      if (!sessionResult.success) {
        setError(sessionResult.error || 'Session expired. Please login again.');
        setStep('auth');
        setCredentialsStatus(prev => prev ? { ...prev, is_valid: false } : null);
        return;
      }

      const response = await startInstagramScrape(url, 200);
      setJobId(response.job_id);
      setStep('scraping');

      // Connect to SSE
      const disconnect = createInstagramSSEConnection(
        response.job_id,
        (event) => {
          switch (event.type) {
            case 'connected':
              setIsConnected(true);
              break;

            case 'scrape_progress': {
              const data = event.data as InstagramScrapeProgressData;
              setScrapeProgress({ scraped: data.scraped, total: data.total });
              setScrapedImages(prev => [...prev, ...data.images]);
              break;
            }

            case 'scrape_complete':
              setIsConnected(false);
              setStep('selecting');
              break;

            case 'scrape_error': {
              const data = event.data as { error?: string };
              setError(data.error || 'Scraping failed');
              setIsConnected(false);
              setStep('input');
              break;
            }

            case 'scrape_cancelled':
              setIsConnected(false);
              setStep('input');
              break;
          }
        },
        (err) => {
          setError(err.message);
          setIsConnected(false);
          setStep('input');
        }
      );

      setDisconnectSSE(() => disconnect);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to start scraping');
      setStep('input');
    }
  }, [url, urlError]);

  // Cancel scraping
  const handleCancelScraping = useCallback(async () => {
    if (disconnectSSE) {
      disconnectSSE();
      setDisconnectSSE(null);
    }

    if (jobId) {
      try {
        await cancelInstagramScrape(jobId);
      } catch {
        // Ignore errors
      }
    }

    setStep('input');
    setIsConnected(false);
    setJobId(null);
    setScrapedImages([]);
    setScrapeProgress({ scraped: 0, total: 0 });
  }, [jobId, disconnectSSE]);

  // Image selection
  const handleImageSelect = useCallback((imageId: string, selected: boolean) => {
    setSelectedIds(prev => {
      const next = new Set(prev);
      if (selected && next.size < maxImages) {
        next.add(imageId);
      } else if (!selected) {
        next.delete(imageId);
      }
      return next;
    });
  }, [maxImages]);

  const handleSelectAll = useCallback(() => {
    const nonVideoImages = scrapedImages.filter(img => !img.is_video);
    const idsToSelect = nonVideoImages.slice(0, maxImages).map(img => img.image_id);
    setSelectedIds(new Set(idsToSelect));
  }, [scrapedImages, maxImages]);

  const handleClearSelection = useCallback(() => {
    setSelectedIds(new Set());
  }, []);

  // Prepare batch for extraction
  const handleConfirmSelection = useCallback(async () => {
    if (selectedIds.size === 0 || !jobId) return;

    setStep('preparing');
    setError(null);

    try {
      const response = await prepareBatchFromInstagram(jobId, Array.from(selectedIds));
      onBatchReady(response.batch_job_id, response.sse_url);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to prepare images');
      setStep('selecting');
    }
  }, [jobId, selectedIds, onBatchReady]);

  // Loading state while checking auth
  if (isCheckingAuth) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
        <p className="mt-3 text-sm text-muted-foreground">
          Checking Instagram connection...
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Error display */}
      {error && step === 'input' && (
        <div className="p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
          <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
        </div>
      )}

      {/* Auth Step */}
      {step === 'auth' && (
        <InstagramLoginForm
          onLogin={handleLogin}
          onLogout={handleLogout}
          credentialsStatus={credentialsStatus}
          isLoading={disabled}
        />
      )}

      {/* URL Input Step */}
      {step === 'input' && (
        <>
          {/* Show connected status */}
          {credentialsStatus?.has_credentials && credentialsStatus?.is_valid && (
            <div className="flex items-center justify-between p-2 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg text-sm">
              <span className="text-green-700 dark:text-green-400">
                Connected as @{credentialsStatus.username}
              </span>
              <button
                onClick={handleLogout}
                className="text-xs text-muted-foreground hover:text-foreground underline"
              >
                Disconnect
              </button>
            </div>
          )}
          <InstagramURLInput
            value={url}
            onChange={setUrl}
            onValidated={handleValidated}
            onProfileChecked={handleProfileChecked}
            error={urlError}
            setError={setUrlError}
            disabled={disabled}
            onSubmit={handleStartScraping}
            profileInfo={profileInfo}
          />
        </>
      )}

      {/* Loading Step */}
      {step === 'loading' && (
        <div className="flex flex-col items-center justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
          <p className="mt-3 text-sm text-muted-foreground">
            Starting Instagram import...
          </p>
        </div>
      )}

      {/* Scraping Step */}
      {step === 'scraping' && (
        <InstagramScrapeProgress
          progress={scrapeProgress}
          onCancel={handleCancelScraping}
          isConnected={isConnected}
        />
      )}

      {/* Selection Step */}
      {step === 'selecting' && (
        <InstagramImageGrid
          images={scrapedImages}
          selectedIds={selectedIds}
          onSelect={handleImageSelect}
          onSelectAll={handleSelectAll}
          onClearSelection={handleClearSelection}
          onConfirm={handleConfirmSelection}
          maxSelectable={maxImages}
        />
      )}

      {/* Preparing Step */}
      {step === 'preparing' && (
        <div className="flex flex-col items-center justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-gold-500" />
          <p className="mt-3 text-sm font-medium text-foreground">
            Downloading {selectedIds.size} images...
          </p>
          <p className="mt-1 text-xs text-muted-foreground">
            This may take a moment
          </p>
        </div>
      )}
    </div>
  );
}

export default InstagramImportTab;
