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
  Shield,
  ExternalLink,
  Trash2,
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
  { value: 'bug_report', labelKey: 'support.cat.bugReport', icon: Bug, color: 'text-tint-coral' },
  { value: 'feature_request', labelKey: 'support.cat.featureRequest', icon: Lightbulb, color: 'text-tint-amber' },
  { value: 'general_feedback', labelKey: 'support.cat.generalFeedback', icon: MessageSquare, color: 'text-tint-blue' },
  { value: 'support_request', labelKey: 'support.cat.supportRequest', icon: HelpCircle, color: 'text-tint-teal' },
] as const

const STATUS_BADGES: Record<string, { labelKey: string; variant: 'default' | 'secondary' | 'outline' }> = {
  open: { labelKey: 'support.status.open', variant: 'default' },
  in_progress: { labelKey: 'support.status.inProgress', variant: 'secondary' },
  resolved: { labelKey: 'support.status.resolved', variant: 'outline' },
  closed: { labelKey: 'support.status.closed', variant: 'outline' },
}

import { formatDate, useTranslation } from '@/i18n'

export function SupportPanel() {
  const { t } = useTranslation()
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
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="space-y-4 md:space-y-6">
      <div>
        <h3 className="text-base md:text-lg font-medium text-foreground">{t('support.title')}</h3>
        <p className="text-sm text-muted-foreground">
          {t('support.subtitle')}
        </p>
      </div>

      {/* Success Message */}
      {showSuccess && (
        <div className="p-4 bg-success-pale border border-success/30 rounded-lg flex items-center gap-3">
          <CheckCircle className="h-5 w-5 text-success" />
          <div>
            <p className="text-success font-medium">{t('support.thanks')}</p>
            <p className="text-success text-sm">{t('support.thanksBody')}</p>
          </div>
        </div>
      )}

      {/* Submit Feedback Form */}
      <Card>
        <CardHeader className="px-4 py-4 md:px-6 md:py-6">
          <CardTitle className="flex items-center gap-2">
            <MessageSquare className="h-5 w-5 text-primary" />
            {t('support.submit')}
          </CardTitle>
          <CardDescription>
            {t('support.submitValue')}
          </CardDescription>
        </CardHeader>
        <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Category Selection */}
            <div>
              <label htmlFor="support-category" className="block text-sm font-medium text-foreground mb-2">
                {t('support.categoryLabel')}
              </label>
              <Select value={category} onValueChange={(v) => setCategory(v as TicketCategory)}>
                <SelectTrigger id="support-category">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {CATEGORIES.map((cat) => (
                    <SelectItem key={cat.value} value={cat.value}>
                      <div className="flex items-center gap-2">
                        <cat.icon className={`h-4 w-4 ${cat.color}`} />
                        {t(cat.labelKey)}
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Subject */}
            <div>
              <label htmlFor="support-subject" className="block text-sm font-medium text-foreground mb-2">
                {t('support.subjectLabel')}
              </label>
              <Input
                id="support-subject"
                value={subject}
                onChange={(e) => setSubject(e.target.value)}
                placeholder={t('support.subjectPlaceholder')}
                maxLength={200}
                disabled={isSubmitting}
              />
            </div>

            {/* Description */}
            <div>
              <label htmlFor="support-description" className="block text-sm font-medium text-foreground mb-2">
                {t('support.descriptionLabel')}
              </label>
              <Textarea
                id="support-description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder={
                  category === 'bug_report'
                    ? t('support.bugPlaceholder')
                    : category === 'feature_request'
                    ? t('support.featurePlaceholder')
                    : t('support.generalPlaceholder')
                }
                rows={5}
                maxLength={5000}
                disabled={isSubmitting}
              />
              <p className="text-xs text-muted-foreground mt-1">
                {t('support.charCount', { count: description.length })}
              </p>
            </div>

            {/* Attachments */}
            <div>
              <label htmlFor="support-attachments" className="block text-sm font-medium text-foreground mb-2">
                {t('support.attachments')}
              </label>
              <input
                id="support-attachments"
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
                    key={`${file.name}-${file.size}-${file.lastModified}`}
                    className="flex items-center gap-2 bg-muted px-3 py-1.5 rounded-md text-sm"
                  >
                    <Paperclip className="h-3 w-3" />
                    <span className="max-w-[150px] truncate">{file.name}</span>
                    <button
                      type="button"
                      onClick={() => removeAttachment(index)}
                      className="touch-target flex items-center justify-center text-muted-foreground hover:text-foreground"
                      aria-label={t('support.removeAttachment', { name: file.name })}
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
                    <Paperclip className="h-4 w-4 me-2" />
                    {t('support.addScreenshot')}
                  </Button>
                )}
              </div>
              <p className="text-xs text-muted-foreground mt-1">
                {t('support.attachmentHint')}
              </p>
            </div>

            {/* Submit Button */}
            <div className="flex justify-end">
              <Button type="submit" disabled={isSubmitting} className="w-full sm:w-auto">
                {isSubmitting ? (
                  <>
                    <Loader2 className="h-4 w-4 me-2 animate-spin" />
                    {t('support.submitting')}
                  </>
                ) : (
                  <>
                    <Send className="h-4 w-4 me-2" />
                    {t('support.submit')}
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
              <Clock className="h-5 w-5 text-primary" />
              {t('support.yourSubmissions')}
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
                      className="flex items-center justify-between gap-3 p-3 bg-muted/50 rounded-lg"
                    >
                      <div className="flex items-center gap-3 min-w-0">
                        {cat && <cat.icon className={`h-4 w-4 shrink-0 ${cat.color}`} />}
                        <div className="min-w-0">
                          <p className="font-medium truncate">{ticket.subject}</p>
                          <p className="text-xs text-muted-foreground">
                            {formatDate(new Date(ticket.created_at))}
                          </p>
                        </div>
                      </div>
                      <Badge variant={status?.variant || 'default'} className="shrink-0 whitespace-nowrap">
                        {status?.labelKey ? t(status.labelKey) : ticket.status}
                      </Badge>
                    </div>
                  )
                })}
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Legal Links */}
      <Card>
        <CardHeader className="px-4 py-4 md:px-6 md:py-6">
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5 text-primary" />
            {t('support.legal')}
          </CardTitle>
          <CardDescription>
            {t('support.legalDesc')}
          </CardDescription>
        </CardHeader>
        <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
          <div className="space-y-2">
            <a
              href="/privacy"
              target="_blank"
              rel="noopener noreferrer"
              className="touch-target flex w-full items-center gap-2 px-2 py-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              <ExternalLink className="h-4 w-4" />
              {t('support.privacyPolicy')}
            </a>
            <a
              href="/terms"
              target="_blank"
              rel="noopener noreferrer"
              className="touch-target flex w-full items-center gap-2 px-2 py-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              <ExternalLink className="h-4 w-4" />
              {t('support.termsOfService')}
            </a>
            <a
              href="mailto:info@fitcheckaiapp.com?subject=Account%20Deletion%20Request&body=Please%20delete%20my%20account%20and%20all%20associated%20data."
              className="touch-target flex w-full items-center gap-2 px-2 py-2 text-sm text-destructive/80 hover:text-destructive transition-colors"
            >
              <Trash2 className="h-4 w-4" />
              {t('support.requestDeletion')}
            </a>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

export default SupportPanel
