/**
 * FeedbackPanel Component
 *
 * Displays and manages user feedback on shared outfits.
 * Features:
 * - Star ratings
 * - Comments
 * - Helpful/unhelpful votes
 * - Style suggestions
 *
 * @see https://docs.fitcheck.ai/features/social/feedback
 */

import { useState } from 'react'
import {
  Star,
  MessageSquare,
  ThumbsUp,
  ThumbsDown,
  User,
  TrendingUp,
  Sparkles,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Textarea } from '@/components/ui/textarea'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { useToast } from '@/components/ui/use-toast'

// ============================================================================
// TYPES
// ============================================================================

export interface Feedback {
  id: string
  user_id: string
  user_name: string
  user_avatar?: string
  rating: number
  comment?: string
  helpful_count: number
  is_helpful?: boolean | null
  created_at: string
  suggestions?: string[]
}

export interface FeedbackStats {
  average_rating: number
  total_ratings: number
  rating_distribution: Record<number, number>
  top_compliments: string[]
  top_suggestions: string[]
}

interface FeedbackPanelProps {
  feedback: Feedback[]
  stats: FeedbackStats
  onSubmitFeedback?: (rating: number, comment?: string) => Promise<void>
  onVoteHelpful?: (feedbackId: string, isHelpful: boolean) => Promise<void>
  readOnly?: boolean
}

// ============================================================================
// COMPONENTS
// ============================================================================

function StarRating({ value, size = 4 }: { value: number; size?: number }) {
  return (
    <div className="flex gap-0.5">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          className={`h-${size} w-${size} ${
            star <= value
              ? 'fill-yellow-400 text-yellow-400'
              : 'text-gray-300 dark:text-gray-600'
          }`}
        />
      ))}
    </div>
  )
}

function FeedbackForm({ onSubmit, isLoading }: { onSubmit: (rating: number, comment?: string) => void; isLoading?: boolean }) {
  const [rating, setRating] = useState(0)
  const [hoverRating, setHoverRating] = useState(0)
  const [comment, setComment] = useState('')

  const handleSubmit = () => {
    if (rating === 0) return
    onSubmit(rating, comment || undefined)
    setRating(0)
    setComment('')
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg">Leave Feedback</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div>
          <label className="text-sm font-medium text-gray-900 dark:text-white">Your Rating</label>
          <div
            className="flex gap-1 mt-2"
            onMouseLeave={() => setHoverRating(0)}
          >
            {[1, 2, 3, 4, 5].map((star) => (
              <button
                key={star}
                onMouseEnter={() => setHoverRating(star)}
                onClick={() => setRating(star)}
                className="focus:outline-none transition-transform hover:scale-110"
              >
                <Star
                  className={`h-6 w-6 ${
                    star <= (hoverRating || rating)
                      ? 'fill-yellow-400 text-yellow-400'
                      : 'text-gray-300 dark:text-gray-600'
                  }`}
                />
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="text-sm font-medium text-gray-900 dark:text-white">Comment (Optional)</label>
          <Textarea
            placeholder="Share your thoughts about this outfit..."
            value={comment}
            onChange={(e) => setComment(e.target.value)}
            rows={3}
          />
        </div>

        <Button
          onClick={handleSubmit}
          disabled={rating === 0 || isLoading}
          className="w-full"
        >
          {isLoading ? 'Submitting...' : 'Submit Feedback'}
        </Button>
      </CardContent>
    </Card>
  )
}

// ============================================================================
// MAIN COMPONENT
// ============================================================================

export function FeedbackPanel({
  feedback,
  stats,
  onSubmitFeedback,
  onVoteHelpful,
  readOnly = false,
}: FeedbackPanelProps) {
  const [activeTab, setActiveTab] = useState<'ratings' | 'stats'>('ratings')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const { toast } = useToast()

  const handleSubmit = async (rating: number, comment?: string) => {
    if (!onSubmitFeedback) return

    setIsSubmitting(true)
    try {
      await onSubmitFeedback(rating, comment)
      toast({
        title: 'Feedback submitted',
        description: 'Thank you for sharing your thoughts!',
      })
    } catch (err) {
      toast({
        title: 'Failed to submit',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleVote = async (feedbackId: string, isHelpful: boolean) => {
    if (!onVoteHelpful) return
    try {
      await onVoteHelpful(feedbackId, isHelpful)
    } catch (err) {
      toast({
        title: 'Vote failed',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    }
  }

  return (
    <div className="space-y-4">
      {/* Summary */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center justify-between">
            <div>
              <div className="flex items-center gap-2">
                <span className="text-3xl font-bold text-gray-900 dark:text-white">
                  {stats.average_rating.toFixed(1)}
                </span>
                <StarRating value={Math.round(stats.average_rating)} />
              </div>
              <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                {stats.total_ratings} rating{stats.total_ratings !== 1 ? 's' : ''}
              </p>
            </div>

            <div className="text-right">
              <p className="text-sm font-medium text-gray-900 dark:text-white">Top compliments</p>
              <div className="flex flex-wrap gap-1 mt-1 justify-end">
                {stats.top_compliments.slice(0, 3).map((compliment, i) => (
                  <Badge key={i} variant="secondary" className="text-xs">
                    <Sparkles className="h-3 w-3 mr-1" />
                    {compliment}
                  </Badge>
                ))}
              </div>
            </div>
          </div>

          {/* Rating distribution */}
          <div className="mt-4 space-y-1">
            {[5, 4, 3, 2, 1].map((star) => {
              const count = stats.rating_distribution[star] || 0
              const percentage = stats.total_ratings > 0
                ? (count / stats.total_ratings) * 100
                : 0

              return (
                <div key={star} className="flex items-center gap-2">
                  <span className="text-xs w-12 text-gray-700 dark:text-gray-300">{star} star</span>
                  <div className="flex-1 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-yellow-400"
                      style={{ width: `${percentage}%` }}
                    />
                  </div>
                  <span className="text-xs w-8 text-right text-gray-700 dark:text-gray-300">{count}</span>
                </div>
              )
            })}
          </div>
        </CardContent>
      </Card>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={(v) => setActiveTab(v as 'ratings' | 'stats')}>
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="ratings">
            Feedback ({feedback.length})
          </TabsTrigger>
          <TabsTrigger value="stats">
            Insights
          </TabsTrigger>
        </TabsList>

        {/* Ratings Tab */}
        <TabsContent value="ratings" className="space-y-4">
          {!readOnly && onSubmitFeedback && (
            <FeedbackForm onSubmit={handleSubmit} isLoading={isSubmitting} />
          )}

          {feedback.length === 0 ? (
            <Card>
              <CardContent className="pt-12 text-center text-gray-500 dark:text-gray-400">
                <MessageSquare className="h-12 w-12 mx-auto mb-4 opacity-50" />
                <p>No feedback yet</p>
                <p className="text-sm">Be the first to share your thoughts!</p>
              </CardContent>
            </Card>
          ) : (
            <div className="space-y-3">
              {feedback.map((item) => (
                <Card key={item.id}>
                  <CardContent className="pt-4">
                    <div className="flex gap-3">
                      <Avatar>
                        {item.user_avatar ? (
                          <AvatarImage src={item.user_avatar} />
                        ) : (
                          <AvatarFallback>
                            <User className="h-4 w-4" />
                          </AvatarFallback>
                        )}
                      </Avatar>

                      <div className="flex-1">
                        <div className="flex items-center justify-between">
                          <p className="font-medium text-gray-900 dark:text-white">{item.user_name}</p>
                          <StarRating value={item.rating} size={3} />
                        </div>

                        {item.comment && (
                          <p className="text-sm mt-1 text-gray-700 dark:text-gray-300">
                            {item.comment}
                          </p>
                        )}

                        {item.suggestions && item.suggestions.length > 0 && (
                          <div className="flex flex-wrap gap-1 mt-2">
                            {item.suggestions.map((suggestion, i) => (
                              <Badge key={i} variant="outline" className="text-xs">
                                <TrendingUp className="h-3 w-3 mr-1" />
                                {suggestion}
                              </Badge>
                            ))}
                          </div>
                        )}

                        <div className="flex items-center justify-between mt-3 text-xs text-gray-500 dark:text-gray-400">
                          <span>
                            {new Date(item.created_at).toLocaleDateString()}
                          </span>

                          {onVoteHelpful && (
                            <div className="flex items-center gap-2">
                              <span>Helpful?</span>
                              <div className="flex items-center gap-1">
                                <button
                                  onClick={() => handleVote(item.id, true)}
                                  className={`p-1 rounded transition-colors ${
                                    item.is_helpful === true
                                      ? 'bg-green-100 dark:bg-green-900/30 text-green-600 dark:text-green-400'
                                      : 'hover:bg-gray-100 dark:hover:bg-gray-700'
                                  }`}
                                >
                                  <ThumbsUp className="h-3 w-3" />
                                </button>
                                <span>{item.helpful_count}</span>
                                <button
                                  onClick={() => handleVote(item.id, false)}
                                  className={`p-1 rounded transition-colors ${
                                    item.is_helpful === false
                                      ? 'bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400'
                                      : 'hover:bg-gray-100 dark:hover:bg-gray-700'
                                  }`}
                                >
                                  <ThumbsDown className="h-3 w-3" />
                                </button>
                              </div>
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </TabsContent>

        {/* Stats Tab */}
        <TabsContent value="stats" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Style Insights</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <p className="text-sm font-medium mb-2 text-gray-900 dark:text-white">Most Complimented</p>
                <div className="flex flex-wrap gap-2">
                  {stats.top_compliments.map((compliment, i) => (
                    <Badge key={i} className="gap-1">
                      <Sparkles className="h-3 w-3" />
                      {compliment}
                    </Badge>
                  ))}
                  {stats.top_compliments.length === 0 && (
                    <p className="text-sm text-gray-500 dark:text-gray-400">No data yet</p>
                  )}
                </div>
              </div>

              <div>
                <p className="text-sm font-medium mb-2 text-gray-900 dark:text-white">Suggested Improvements</p>
                <div className="flex flex-wrap gap-2">
                  {stats.top_suggestions.map((suggestion, i) => (
                    <Badge key={i} variant="outline" className="gap-1">
                      <TrendingUp className="h-3 w-3" />
                      {suggestion}
                    </Badge>
                  ))}
                  {stats.top_suggestions.length === 0 && (
                    <p className="text-sm text-gray-500 dark:text-gray-400">No suggestions yet</p>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}

export default FeedbackPanel
