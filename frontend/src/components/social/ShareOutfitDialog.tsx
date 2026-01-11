/**
 * ShareOutfitDialog Component
 *
 * Allows users to share their outfits with others.
 * Features:
 * - Share to social media
 * - Generate shareable link
 * - Copy outfit image
 * - Enable/disable feedback requests
 *
 * @see https://docs.fitcheck.ai/features/social/sharing
 */

import { useEffect, useState } from 'react'
import {
  Share2,
  Link as LinkIcon,
  Download,
  Facebook,
  Twitter,
  MessageCircle,
  Mail,
  Check,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Switch } from '@/components/ui/switch'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { useToast } from '@/components/ui/use-toast'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import { shareOutfit } from '@/api/outfits'
import type { Outfit } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

interface ShareOutfitDialogProps {
  isOpen: boolean
  onClose: () => void
  outfit: Outfit | null
  onShare?: (platform: string, options: ShareOptions) => Promise<void>
}

export interface ShareOptions {
  isPublic: boolean
  allowFeedback: boolean
  allowComments: boolean
  caption?: string
  tags?: string[]
}

// ============================================================================
// COMPONENT
// ============================================================================

export function ShareOutfitDialog({
  isOpen,
  onClose,
  outfit,
  onShare,
}: ShareOutfitDialogProps) {
  const [shareOptions, setShareOptions] = useState<ShareOptions>({
    isPublic: true,
    allowFeedback: true,
    allowComments: true,
    caption: '',
    tags: [],
  })

  const [copiedLink, setCopiedLink] = useState(false)
  const [isSharing, setIsSharing] = useState(false)
  const [shareLinkUrl, setShareLinkUrl] = useState<string | null>(null)

  const { toast } = useToast()

  useEffect(() => {
    setShareLinkUrl(null)
  }, [outfit?.id])

  const ensureShareUrl = async (): Promise<string> => {
    if (!outfit) throw new Error('No outfit selected')
    if (shareLinkUrl) return shareLinkUrl

    const link = await shareOutfit(outfit.id, {
      visibility: shareOptions.isPublic ? 'public' : 'private',
      allow_feedback: shareOptions.allowFeedback,
      custom_caption: shareOptions.caption || undefined,
    })
    setShareLinkUrl(link.url)
    return link.url
  }

  const openExternal = (url: string) => {
    window.open(url, '_blank', 'noopener,noreferrer')
  }

  const handleShare = async (platform: string) => {
    if (!outfit) return

    setIsSharing(true)
    try {
      if (onShare) {
        await onShare(platform, shareOptions)
      } else {
        const url = await ensureShareUrl()
        const encodedUrl = encodeURIComponent(url)
        const captionText =
          (shareOptions.caption && shareOptions.caption.trim()) ||
          `Check out my outfit "${outfit.name}" on FitCheck AI`
        const encodedText = encodeURIComponent(captionText)

        switch (platform) {
          case 'twitter':
            openExternal(`https://twitter.com/intent/tweet?text=${encodedText}&url=${encodedUrl}`)
            break
          case 'facebook':
            openExternal(`https://www.facebook.com/sharer/sharer.php?u=${encodedUrl}`)
            break
          case 'whatsapp':
            openExternal(`https://wa.me/?text=${encodedText}%20${encodedUrl}`)
            break
          case 'email':
            openExternal(`mailto:?subject=${encodeURIComponent('FitCheck AI Outfit')}&body=${encodedText}%0A${encodedUrl}`)
            break
          case 'instagram':
          default:
            await navigator.clipboard.writeText(url)
            toast({
              title: 'Link copied',
              description: 'Instagram sharing requires manual posting. Link copied to clipboard.',
            })
            break
        }
      }

      toast({
        title: 'Shared successfully',
        description: `Your outfit has been shared to ${platform}`,
      })
      onClose()
    } catch (err) {
      toast({
        title: 'Share failed',
        description: err instanceof Error ? err.message : 'Failed to share outfit',
        variant: 'destructive',
      })
    } finally {
      setIsSharing(false)
    }
  }

  const handleCopyLink = async () => {
    try {
      const url = await ensureShareUrl()
      await navigator.clipboard.writeText(url)
      setCopiedLink(true)
      setTimeout(() => setCopiedLink(false), 2000)
      toast({
        title: 'Link copied',
        description: 'Shareable link copied to clipboard',
      })
    } catch (err) {
      toast({
        title: 'Copy failed',
        description: 'Failed to copy link to clipboard',
        variant: 'destructive',
      })
    }
  }

  const handleDownloadImage = () => {
    if (!outfit?.images?.length) return

    const primary = outfit.images.find((img) => img.is_primary) || outfit.images[0]
    if (!primary?.image_url) return

    const link = document.createElement('a')
    link.href = primary.image_url
    link.download = `outfit-${outfit.name.toLowerCase().replace(/\s+/g, '-')}.png`
    link.click()

    toast({
      title: 'Image downloaded',
      description: 'Outfit image has been saved',
    })
  }

  const shareUrl = shareLinkUrl || (outfit ? `${window.location.origin}/shared/outfits/${outfit.id}` : '')

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Share2 className="h-5 w-5" />
            Share Outfit
          </DialogTitle>
          <DialogDescription>
            Share your style with the world or get feedback from friends
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6">
          {/* Outfit preview */}
          {outfit && (
            <div className="flex gap-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <div className="w-32 h-32 rounded-lg overflow-hidden bg-white dark:bg-gray-700 flex-shrink-0">
                {outfit.images?.length ? (
                  <ZoomableImage
                    src={(outfit.images.find((img) => img.is_primary) || outfit.images[0]).image_url}
                    alt={outfit.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-gray-400">
                    No image
                  </div>
                )}
              </div>
              <div className="flex-1">
                <h3 className="font-semibold text-lg text-gray-900 dark:text-white">{outfit.name}</h3>
                {outfit.description && (
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                    {outfit.description}
                  </p>
                )}
                <div className="flex flex-wrap gap-2 mt-2">
                  {outfit.style && (
                    <Badge variant="secondary" className="capitalize">
                      {outfit.style}
                    </Badge>
                  )}
                  {outfit.season && (
                    <Badge variant="secondary" className="capitalize">
                      {outfit.season}
                    </Badge>
                  )}
                  {outfit.tags.slice(0, 3).map((tag) => (
                    <Badge key={tag} variant="outline" className="capitalize">
                      {tag}
                    </Badge>
                  ))}
                </div>
              </div>
            </div>
          )}

          <Tabs defaultValue="social" className="w-full">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="social">Social Media</TabsTrigger>
              <TabsTrigger value="link">Share Link</TabsTrigger>
              <TabsTrigger value="options">Options</TabsTrigger>
            </TabsList>

            {/* Social Media Tab */}
            <TabsContent value="social" className="space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <Button
                  variant="outline"
                  className="h-20 flex-col gap-2"
                  onClick={() => handleShare('twitter')}
                  disabled={isSharing}
                >
                  <Twitter className="h-6 w-6 text-blue-400" />
                  <span>Twitter</span>
                </Button>
                <Button
                  variant="outline"
                  className="h-20 flex-col gap-2"
                  onClick={() => handleShare('facebook')}
                  disabled={isSharing}
                >
                  <Facebook className="h-6 w-6 text-blue-600" />
                  <span>Facebook</span>
                </Button>
                <Button
                  variant="outline"
                  className="h-20 flex-col gap-2"
                  onClick={() => handleShare('instagram')}
                  disabled={isSharing}
                >
                  <Share2 className="h-6 w-6 text-pink-500" />
                  <span>Instagram</span>
                </Button>
                <Button
                  variant="outline"
                  className="h-20 flex-col gap-2"
                  onClick={() => handleShare('whatsapp')}
                  disabled={isSharing}
                >
                  <MessageCircle className="h-6 w-6 text-green-500" />
                  <span>WhatsApp</span>
                </Button>
                <Button
                  variant="outline"
                  className="h-20 flex-col gap-2"
                  onClick={() => handleShare('email')}
                  disabled={isSharing}
                >
                  <Mail className="h-6 w-6 text-gray-600 dark:text-gray-400" />
                  <span>Email</span>
                </Button>
                <Button
                  variant="outline"
                  className="h-20 flex-col gap-2"
                  onClick={handleDownloadImage}
                >
                  <Download className="h-6 w-6 text-gray-600 dark:text-gray-400" />
                  <span>Download</span>
                </Button>
              </div>
            </TabsContent>

            {/* Share Link Tab */}
            <TabsContent value="link" className="space-y-4">
              <Card>
                <CardContent className="pt-6">
                  <Label>Shareable Link</Label>
                  <div className="flex gap-2 mt-2">
                    <Input
                      value={shareUrl}
                      readOnly
                      className="flex-1 font-mono text-sm"
                    />
                    <Button onClick={handleCopyLink} variant="outline">
                      {copiedLink ? (
                        <>
                          <Check className="h-4 w-4 mr-2" />
                          Copied
                        </>
                      ) : (
                        <>
                          <LinkIcon className="h-4 w-4 mr-2" />
                          Copy
                        </>
                      )}
                    </Button>
                  </div>
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
                    Anyone with this link can view your outfit
                  </p>
                </CardContent>
              </Card>

              {/* QR Code placeholder */}
              <Card>
                <CardContent className="pt-6">
                  <Label>QR Code</Label>
                  <div className="mt-2 aspect-square max-w-[200px] mx-auto bg-gray-100 dark:bg-gray-700 rounded-lg flex items-center justify-center">
                    <p className="text-sm text-gray-500 dark:text-gray-400 text-center px-4">
                      QR Code would be generated here
                    </p>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Options Tab */}
            <TabsContent value="options" className="space-y-4">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <Label className="text-gray-900 dark:text-white">Public Outfit</Label>
                    <p className="text-sm text-gray-500 dark:text-gray-400">
                      Allow anyone to find and view this outfit
                    </p>
                  </div>
                  <Switch
                    checked={shareOptions.isPublic}
                    onCheckedChange={(checked) =>
                      setShareOptions((prev) => ({ ...prev, isPublic: checked }))
                    }
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <Label className="text-gray-900 dark:text-white">Allow Feedback</Label>
                    <p className="text-sm text-gray-500 dark:text-gray-400">
                      Let others rate and comment on your outfit
                    </p>
                  </div>
                  <Switch
                    checked={shareOptions.allowFeedback}
                    onCheckedChange={(checked) =>
                      setShareOptions((prev) => ({ ...prev, allowFeedback: checked }))
                    }
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <Label className="text-gray-900 dark:text-white">Allow Comments</Label>
                    <p className="text-sm text-gray-500 dark:text-gray-400">
                      Enable comments on your shared outfit
                    </p>
                  </div>
                  <Switch
                    checked={shareOptions.allowComments}
                    onCheckedChange={(checked) =>
                      setShareOptions((prev) => ({ ...prev, allowComments: checked }))
                    }
                  />
                </div>

                <div>
                  <Label htmlFor="caption">Caption (Optional)</Label>
                  <Textarea
                    id="caption"
                    placeholder="Tell others about this outfit..."
                    value={shareOptions.caption}
                    onChange={(e) =>
                      setShareOptions((prev) => ({ ...prev, caption: e.target.value }))
                    }
                    rows={3}
                  />
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </div>
      </DialogContent>
    </Dialog>
  )
}

export default ShareOutfitDialog
