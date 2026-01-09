/**
 * Export Dialog Component
 *
 * Provides UI for exporting wardrobe items, outfits, and lookbooks.
 */

import { useState } from 'react'
import {
  Download,
  FileText,
  FileSpreadsheet,
  FileCode,
  Image,
  Book,
  Loader2,
  Check,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Checkbox } from '@/components/ui/checkbox'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog'
import { useToast } from '@/components/ui/use-toast'
import { cn } from '@/lib/utils'
import type { Item, Outfit } from '@/types'
import {
  type ExportFormat,
  exportAndDownload,
  exportLookbookAndDownload,
} from '@/lib/export'

// ============================================================================
// TYPES
// ============================================================================

interface ExportDialogProps {
  isOpen: boolean
  onClose: () => void
  items: Item[]
  outfits: Outfit[]
  selectedOutfitIds?: string[]
}

type ExportType = 'wardrobe' | 'lookbook'

interface FormatOption {
  value: ExportFormat
  label: string
  description: string
  icon: typeof FileText
}

// ============================================================================
// CONSTANTS
// ============================================================================

const FORMAT_OPTIONS: FormatOption[] = [
  {
    value: 'html',
    label: 'HTML',
    description: 'Web page with styling, printable',
    icon: FileCode,
  },
  {
    value: 'pdf',
    label: 'PDF',
    description: 'Print dialog for PDF creation',
    icon: FileText,
  },
  {
    value: 'markdown',
    label: 'Markdown',
    description: 'Plain text with formatting',
    icon: FileText,
  },
  {
    value: 'csv',
    label: 'CSV',
    description: 'Spreadsheet-compatible data',
    icon: FileSpreadsheet,
  },
  {
    value: 'json',
    label: 'JSON',
    description: 'Raw data for developers',
    icon: FileCode,
  },
]

// ============================================================================
// MAIN COMPONENT
// ============================================================================

export function ExportDialog({
  isOpen,
  onClose,
  items,
  outfits,
  selectedOutfitIds,
}: ExportDialogProps) {
  const { toast } = useToast()

  // State
  const [exportType, setExportType] = useState<ExportType>('wardrobe')
  const [format, setFormat] = useState<ExportFormat>('html')
  const [title, setTitle] = useState('My Wardrobe')
  const [author, setAuthor] = useState('')
  const [includeImages, setIncludeImages] = useState(true)
  const [isExporting, setIsExporting] = useState(false)
  const [exportComplete, setExportComplete] = useState(false)

  // Lookbook-specific state
  const [lookbookTitle, setLookbookTitle] = useState('My Lookbook')
  const [lookbookDescription, setLookbookDescription] = useState('')

  // Selected outfits for lookbook
  const selectedOutfits = selectedOutfitIds
    ? outfits.filter((o) => selectedOutfitIds.includes(o.id))
    : outfits

  const handleExport = async () => {
    setIsExporting(true)
    setExportComplete(false)

    try {
      if (exportType === 'wardrobe') {
        await exportAndDownload(items, outfits, format, {
          format,
          title,
          author: author || undefined,
          includeImages,
        })
      } else {
        await exportLookbookAndDownload(selectedOutfits, items, {
          title: lookbookTitle,
          description: lookbookDescription || undefined,
          author: author || undefined,
          format: format === 'pdf' ? 'pdf' : 'html',
        })
      }

      setExportComplete(true)
      toast({
        title: 'Export successful',
        description:
          format === 'pdf'
            ? 'Print dialog opened. Save as PDF to complete export.'
            : 'Your file has been downloaded.',
      })

      // Reset after success
      setTimeout(() => {
        setExportComplete(false)
      }, 2000)
    } catch (error) {
      console.error('Export failed:', error)
      toast({
        title: 'Export failed',
        description: 'There was an error exporting your data. Please try again.',
        variant: 'destructive',
      })
    } finally {
      setIsExporting(false)
    }
  }

  const handleClose = () => {
    if (!isExporting) {
      onClose()
    }
  }

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && handleClose()}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Download className="w-5 h-5" />
            Export
          </DialogTitle>
          <DialogDescription>
            Export your wardrobe data or create a lookbook
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 py-4">
          {/* Export Type Selection */}
          <div className="space-y-3">
            <Label>What would you like to export?</Label>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setExportType('wardrobe')}
                className={cn(
                  'flex flex-col items-center gap-2 p-4 rounded-lg border-2 transition-colors',
                  exportType === 'wardrobe'
                    ? 'border-primary bg-primary/5'
                    : 'border-border hover:border-primary/50'
                )}
              >
                <Image className="w-8 h-8 text-primary" />
                <span className="font-medium">Full Wardrobe</span>
                <span className="text-xs text-muted-foreground text-center">
                  All items & outfits with stats
                </span>
              </button>

              <button
                onClick={() => setExportType('lookbook')}
                className={cn(
                  'flex flex-col items-center gap-2 p-4 rounded-lg border-2 transition-colors',
                  exportType === 'lookbook'
                    ? 'border-primary bg-primary/5'
                    : 'border-border hover:border-primary/50'
                )}
              >
                <Book className="w-8 h-8 text-primary" />
                <span className="font-medium">Lookbook</span>
                <span className="text-xs text-muted-foreground text-center">
                  Styled outfit collection
                </span>
              </button>
            </div>
          </div>

          {/* Format Selection */}
          <div className="space-y-3">
            <Label>Format</Label>
            <div className="grid grid-cols-5 gap-2">
              {FORMAT_OPTIONS.filter((opt) =>
                exportType === 'lookbook'
                  ? opt.value === 'html' || opt.value === 'pdf'
                  : true
              ).map((option) => {
                const Icon = option.icon
                return (
                  <button
                    key={option.value}
                    onClick={() => setFormat(option.value)}
                    className={cn(
                      'flex flex-col items-center gap-1.5 p-3 rounded-lg border transition-colors',
                      format === option.value
                        ? 'border-primary bg-primary/5'
                        : 'border-border hover:border-primary/50'
                    )}
                    title={option.description}
                  >
                    <Icon className="w-5 h-5" />
                    <span className="text-xs font-medium">{option.label}</span>
                  </button>
                )
              })}
            </div>
            <p className="text-xs text-muted-foreground">
              {FORMAT_OPTIONS.find((o) => o.value === format)?.description}
            </p>
          </div>

          {/* Wardrobe Options */}
          {exportType === 'wardrobe' && (
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="export-title">Title</Label>
                <Input
                  id="export-title"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="My Wardrobe"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="export-author">Author (optional)</Label>
                <Input
                  id="export-author"
                  value={author}
                  onChange={(e) => setAuthor(e.target.value)}
                  placeholder="Your name"
                />
              </div>

              {(format === 'html' || format === 'pdf') && (
                <div className="flex items-center gap-2">
                  <Checkbox
                    id="include-images"
                    checked={includeImages}
                    onCheckedChange={(checked) => setIncludeImages(!!checked)}
                  />
                  <Label htmlFor="include-images" className="text-sm cursor-pointer">
                    Include item images (may take longer)
                  </Label>
                </div>
              )}
            </div>
          )}

          {/* Lookbook Options */}
          {exportType === 'lookbook' && (
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="lookbook-title">Lookbook Title</Label>
                <Input
                  id="lookbook-title"
                  value={lookbookTitle}
                  onChange={(e) => setLookbookTitle(e.target.value)}
                  placeholder="My Lookbook"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="lookbook-description">Description (optional)</Label>
                <Input
                  id="lookbook-description"
                  value={lookbookDescription}
                  onChange={(e) => setLookbookDescription(e.target.value)}
                  placeholder="A curated collection of my favorite looks"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="lookbook-author">Author (optional)</Label>
                <Input
                  id="lookbook-author"
                  value={author}
                  onChange={(e) => setAuthor(e.target.value)}
                  placeholder="Your name"
                />
              </div>

              <div className="p-3 rounded-lg bg-muted/50 text-sm">
                <p className="font-medium">
                  {selectedOutfits.length} outfit{selectedOutfits.length !== 1 ? 's' : ''}{' '}
                  will be included
                </p>
                {selectedOutfitIds && selectedOutfitIds.length > 0 ? (
                  <p className="text-muted-foreground text-xs mt-1">
                    Based on your selection
                  </p>
                ) : (
                  <p className="text-muted-foreground text-xs mt-1">
                    All your outfits will be included
                  </p>
                )}
              </div>
            </div>
          )}

          {/* Summary */}
          <div className="p-3 rounded-lg bg-muted/30 border">
            <p className="text-sm">
              <strong>Summary:</strong>{' '}
              {exportType === 'wardrobe'
                ? `Exporting ${items.length} items and ${outfits.length} outfits`
                : `Creating lookbook with ${selectedOutfits.length} looks`}
            </p>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={handleClose} disabled={isExporting}>
            Cancel
          </Button>
          <Button onClick={handleExport} disabled={isExporting || exportComplete}>
            {isExporting ? (
              <>
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                Exporting...
              </>
            ) : exportComplete ? (
              <>
                <Check className="w-4 h-4 mr-2" />
                Done!
              </>
            ) : (
              <>
                <Download className="w-4 h-4 mr-2" />
                Export
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

export default ExportDialog
