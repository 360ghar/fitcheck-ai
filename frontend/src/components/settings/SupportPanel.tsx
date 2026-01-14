/**
 * SupportPanel Component
 *
 * Settings panel for submitting feedback, bug reports, and viewing ticket history.
 */

import { useState, useRef, useEffect } from 'react'
import {
  MessageSquare,
  Bug,
  Lightbulb,
  HelpCircle,
  Send,
  Paperclip,
  X,
  Loader2,
  CheckCircle,
  Clock,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { useToast } from '@/components/ui/use-toast'
import { submitFeedback, getMyTickets, type TicketCategory, type TicketListItem } from '@/api/feedback'

const CATEGORIES = [
  { value: 'bug_report', label: 'Bug Report', icon: Bug, color: 'text-red-500' },
  { value: 'feature_request', label: 'Feature Request', icon: Lightbulb, color: 'text-amber-500' },
  { value: 'general_feedback', label: 'General Feedback', icon: MessageSquare, color: 'text-blue-500' },
  { value: 'support_request', label: 'Support Request', icon: HelpCircle, color: 'text-green-500' },
] as const

const STATUS_BADGES: Record<string, { label: string; variant: 'default' | 'secondary' | 'outline' }> = {
  open: { label: 'Open', variant: 'default' },
  in_progress: { label: 'In Progress', variant: 'secondary' },
  resolved: { label: 'Resolved', variant: 'outline' },
  closed: { label: 'Closed', variant: 'outline' },
}

export function SupportPanel() {
  const { toast } = useToast()
  const fileInputRef = useRef<HTMLInputElement>(null)

  // Form state
  const [category, setCategory] = useState<TicketCategory>('general_feedback')
  const [subject, setSubject] = useState('')
  const [description, setDescription] = useState('')
  const [attachments, setAttachments] = useState<File[]>([])
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [showSuccess, setShowSuccess] = useState(false)

  // Ticket history state
  const [tickets, setTickets] = useState<TicketListItem[]>([])
  const [isLoadingTickets, setIsLoadingTickets] = useState(false)

  // Load user's tickets
  useEffect(() => {
    loadTickets()
  }, [])

  const loadTickets = async () => {
    setIsLoadingTickets(true)
    try {
      const response = await getMyTickets()
      setTickets(response.tickets)
    } catch {
      // Ignore errors - user might not be authenticated
    } finally {
      setIsLoadingTickets(false)
    }
  }

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    const validFiles = files.filter(f => {
      if (f.size > 5 * 1024 * 1024) {
        toast({ title: 'File too large', description: `${f.name} exceeds 5MB limit`, variant: 'destructive' })
        return false
      }
      return true
    })
    setAttachments(prev => [...prev, ...validFiles].slice(0, 5))
  }

  const removeAttachment = (index: number) => {
    setAttachments(prev => prev.filter((_, i) => i !== index))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!subject.trim() || !description.trim()) {
      toast({ title: 'Please fill in all required fields', variant: 'destructive' })
      return
    }

    setIsSubmitting(true)
    try {
      await submitFeedback({
        category,
        subject: subject.trim(),
        description: description.trim(),
        attachments,
        deviceInfo: {
          platform: 'web',
          browser: navigator.userAgent,
          screen_size: `${window.innerWidth}x${window.innerHeight}`,
        },
      })

      // Reset form
      setCategory('general_feedback')
      setSubject('')
      setDescription('')
      setAttachments([])
      setShowSuccess(true)

      // Reload tickets
      loadTickets()

      setTimeout(() => setShowSuccess(false), 5000)
    } catch (error) {
      toast({
        title: 'Failed to submit feedback',
        description: error instanceof Error ? error.message : 'Please try again',
        variant: 'destructive',
      })
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-base md:text-lg font-medium text-foreground">Support & Feedback</h3>
        <p className="text-sm text-muted-foreground">
          Report bugs, request features, or share your feedback
        </p>
      </div>

      {/* Success Message */}
      {showSuccess && (
        <div className="p-4 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-800 rounded-lg flex items-center gap-3">
          <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
          <div>
            <p className="text-green-800 dark:text-green-200 font-medium">Thank you for your feedback!</p>
            <p className="text-green-600 dark:text-green-300 text-sm">We'll review it and get back to you if needed.</p>
          </div>
        </div>
      )}

      {/* Submit Feedback Form */}
      <Card>
        <CardHeader className="px-4 py-4 md:px-6 md:py-6">
          <CardTitle className="flex items-center gap-2">
            <MessageSquare className="h-5 w-5 text-indigo-500" />
            Submit Feedback
          </CardTitle>
          <CardDescription>
            We value your input and read every submission
          </CardDescription>
        </CardHeader>
        <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Category Selection */}
            <div>
              <label className="block text-sm font-medium text-foreground mb-2">
                Category *
              </label>
              <Select value={category} onValueChange={(v) => setCategory(v as TicketCategory)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {CATEGORIES.map((cat) => (
                    <SelectItem key={cat.value} value={cat.value}>
                      <div className="flex items-center gap-2">
                        <cat.icon className={`h-4 w-4 ${cat.color}`} />
                        {cat.label}
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Subject */}
            <div>
              <label className="block text-sm font-medium text-foreground mb-2">
                Subject *
              </label>
              <Input
                value={subject}
                onChange={(e) => setSubject(e.target.value)}
                placeholder="Brief summary of your feedback"
                maxLength={200}
                disabled={isSubmitting}
              />
            </div>

            {/* Description */}
            <div>
              <label className="block text-sm font-medium text-foreground mb-2">
                Description *
              </label>
              <Textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder={
                  category === 'bug_report'
                    ? "Describe the bug: What happened? What did you expect? Steps to reproduce?"
                    : category === 'feature_request'
                    ? "Describe the feature you'd like and how it would help you"
                    : "Share your thoughts, suggestions, or questions"
                }
                rows={5}
                maxLength={5000}
                disabled={isSubmitting}
              />
              <p className="text-xs text-muted-foreground mt-1">
                {description.length}/5000 characters
              </p>
            </div>

            {/* Attachments */}
            <div>
              <label className="block text-sm font-medium text-foreground mb-2">
                Attachments (optional)
              </label>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                multiple
                onChange={handleFileSelect}
                className="hidden"
              />
              <div className="flex flex-wrap gap-2">
                {attachments.map((file, index) => (
                  <div
                    key={index}
                    className="flex items-center gap-2 bg-muted px-3 py-1.5 rounded-md text-sm"
                  >
                    <Paperclip className="h-3 w-3" />
                    <span className="max-w-[150px] truncate">{file.name}</span>
                    <button
                      type="button"
                      onClick={() => removeAttachment(index)}
                      className="text-muted-foreground hover:text-foreground"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </div>
                ))}
                {attachments.length < 5 && (
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => fileInputRef.current?.click()}
                    disabled={isSubmitting}
                  >
                    <Paperclip className="h-4 w-4 mr-2" />
                    Add Screenshot
                  </Button>
                )}
              </div>
              <p className="text-xs text-muted-foreground mt-1">
                Up to 5 images, max 5MB each
              </p>
            </div>

            {/* Submit Button */}
            <div className="flex justify-end">
              <Button type="submit" disabled={isSubmitting}>
                {isSubmitting ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Submitting...
                  </>
                ) : (
                  <>
                    <Send className="h-4 w-4 mr-2" />
                    Submit Feedback
                  </>
                )}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      {/* Ticket History */}
      {tickets.length > 0 && (
        <Card>
          <CardHeader className="px-4 py-4 md:px-6 md:py-6">
            <CardTitle className="flex items-center gap-2">
              <Clock className="h-5 w-5 text-indigo-500" />
              Your Submissions
            </CardTitle>
          </CardHeader>
          <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
            {isLoadingTickets ? (
              <div className="flex justify-center py-4">
                <Loader2 className="h-6 w-6 animate-spin" />
              </div>
            ) : (
              <div className="space-y-3">
                {tickets.map((ticket) => {
                  const cat = CATEGORIES.find(c => c.value === ticket.category)
                  const status = STATUS_BADGES[ticket.status]
                  return (
                    <div
                      key={ticket.id}
                      className="flex items-center justify-between p-3 bg-muted/50 rounded-lg"
                    >
                      <div className="flex items-center gap-3 min-w-0">
                        {cat && <cat.icon className={`h-4 w-4 shrink-0 ${cat.color}`} />}
                        <div className="min-w-0">
                          <p className="font-medium truncate">{ticket.subject}</p>
                          <p className="text-xs text-muted-foreground">
                            {new Date(ticket.created_at).toLocaleDateString()}
                          </p>
                        </div>
                      </div>
                      <Badge variant={status?.variant || 'default'}>
                        {status?.label || ticket.status}
                      </Badge>
                    </div>
                  )
                })}
              </div>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  )
}

export default SupportPanel
