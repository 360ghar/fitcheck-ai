/**
 * InstagramScrapeProgress Component
 *
 * Progress indicator during Instagram scraping.
 */

import { Loader2, X, Radio } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';

interface InstagramScrapeProgressProps {
  progress: { scraped: number; total: number };
  onCancel: () => void;
  isConnected?: boolean;
}

export function InstagramScrapeProgress({
  progress,
  onCancel,
  isConnected = true,
}: InstagramScrapeProgressProps) {
  const percentage = progress.total > 0
    ? Math.round((progress.scraped / progress.total) * 100)
    : 0;

  return (
    <div className="space-y-4 py-8">
      {/* Live indicator */}
      <div className="flex items-center justify-center gap-2">
        <div className="flex items-center gap-2 px-3 py-1.5 bg-green-50 dark:bg-green-900/20 rounded-full">
          {isConnected ? (
            <>
              <Radio className="h-3 w-3 text-green-500 animate-pulse" />
              <span className="text-xs font-medium text-green-700 dark:text-green-400">
                Live
              </span>
            </>
          ) : (
            <>
              <Loader2 className="h-3 w-3 text-muted-foreground animate-spin" />
              <span className="text-xs font-medium text-muted-foreground">
                Connecting...
              </span>
            </>
          )}
        </div>
      </div>

      {/* Progress indicator */}
      <div className="flex flex-col items-center space-y-4">
        <div className="relative">
          <Loader2 className="h-12 w-12 animate-spin text-gold-500" />
        </div>

        <div className="text-center space-y-1">
          <p className="text-lg font-medium text-foreground">
            Scraping Instagram Images
          </p>
          <p className="text-sm text-muted-foreground">
            {progress.scraped} of {progress.total > 0 ? progress.total : '...'} posts processed
          </p>
        </div>

        {/* Progress bar */}
        <div className="w-full max-w-xs space-y-2">
          <Progress value={percentage} className="h-2" />
          <p className="text-center text-xs text-muted-foreground">
            {percentage}% complete
          </p>
        </div>

        {/* Cancel button */}
        <Button
          variant="outline"
          size="sm"
          onClick={onCancel}
          className="mt-4"
        >
          <X className="h-4 w-4 mr-2" />
          Cancel
        </Button>
      </div>

      {/* Info text */}
      <p className="text-center text-xs text-muted-foreground max-w-sm mx-auto">
        This may take a moment for profiles with many posts.
        You can cancel and start over at any time.
      </p>
    </div>
  );
}

export default InstagramScrapeProgress;
