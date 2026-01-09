/**
 * Care Instructions Editor Component
 *
 * Displays and allows editing of care instructions for wardrobe items.
 * Shows washing, drying, ironing instructions with material-specific guides.
 */

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import {
  type CareInstructions,
  WASHING_OPTIONS,
  DRYING_OPTIONS,
  IRONING_OPTIONS,
  SPECIAL_CARE_OPTIONS,
  getItemCareInstructions,
  saveItemCareInstructions,
  getDefaultCareForMaterial,
  getDefaultCareForCategory,
  getMaterialGuide,
  getCareIcons,
} from '@/lib/care-instructions'
import type { Category } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

interface CareInstructionsEditorProps {
  itemId: string
  material?: string
  category?: Category
  variant?: 'full' | 'compact' | 'inline' | 'dialog'
  onSave?: (instructions: CareInstructions) => void
  className?: string
}

interface CareInstructionsDisplayProps {
  instructions: CareInstructions
  variant?: 'full' | 'compact' | 'icons'
  className?: string
}

interface MaterialGuideCardProps {
  material: string
  className?: string
}

// ============================================================================
// HELPER COMPONENTS
// ============================================================================

function InstructionSelect<T extends string>({
  label,
  value,
  options,
  onChange,
}: {
  label: string
  value: T
  options: { value: T; label: string; icon: string; description: string }[]
  onChange: (value: T) => void
}) {
  return (
    <div className="space-y-2">
      <Label className="text-sm font-medium">{label}</Label>
      <div className="grid grid-cols-2 gap-2">
        {options.map((option) => (
          <button
            key={option.value}
            type="button"
            onClick={() => onChange(option.value)}
            className={cn(
              'flex items-start gap-2 p-3 rounded-lg border text-left transition-all',
              value === option.value
                ? 'border-primary bg-primary/5 ring-1 ring-primary'
                : 'border-border hover:border-primary/50 hover:bg-muted/50'
            )}
          >
            <span className="text-xl">{option.icon}</span>
            <div className="flex-1 min-w-0">
              <div className="font-medium text-sm truncate">{option.label}</div>
              <div className="text-xs text-muted-foreground truncate">
                {option.description}
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  )
}

function SpecialCareSelector({
  selected,
  onChange,
}: {
  selected: string[]
  onChange: (selected: string[]) => void
}) {
  const toggleCare = (care: string) => {
    if (selected.includes(care)) {
      onChange(selected.filter((c) => c !== care))
    } else {
      onChange([...selected, care])
    }
  }

  return (
    <div className="space-y-2">
      <Label className="text-sm font-medium">Special Care Instructions</Label>
      <div className="flex flex-wrap gap-2">
        {SPECIAL_CARE_OPTIONS.map((care) => (
          <Badge
            key={care}
            variant={selected.includes(care) ? 'default' : 'outline'}
            className="cursor-pointer transition-all hover:scale-105"
            onClick={() => toggleCare(care)}
          >
            {care}
          </Badge>
        ))}
      </div>
    </div>
  )
}

// ============================================================================
// DISPLAY COMPONENTS
// ============================================================================

export function CareInstructionsDisplay({
  instructions,
  variant = 'full',
  className,
}: CareInstructionsDisplayProps) {
  const washing = WASHING_OPTIONS.find((o) => o.value === instructions.washing)
  const drying = DRYING_OPTIONS.find((o) => o.value === instructions.drying)
  const ironing = IRONING_OPTIONS.find((o) => o.value === instructions.ironing)

  if (variant === 'icons') {
    const icons = getCareIcons(instructions)
    return (
      <div className={cn('flex items-center gap-1', className)}>
        {icons.map((icon, i) => (
          <span key={i} className="text-lg" title="Care instruction">
            {icon}
          </span>
        ))}
        {instructions.dryClean && (
          <span className="text-lg" title="Dry clean recommended">
            🧹
          </span>
        )}
      </div>
    )
  }

  if (variant === 'compact') {
    return (
      <div className={cn('space-y-1', className)}>
        <div className="flex items-center gap-2 text-sm">
          <span>{washing?.icon}</span>
          <span>{washing?.label}</span>
        </div>
        <div className="flex items-center gap-2 text-sm">
          <span>{drying?.icon}</span>
          <span>{drying?.label}</span>
        </div>
        <div className="flex items-center gap-2 text-sm">
          <span>{ironing?.icon}</span>
          <span>{ironing?.label}</span>
        </div>
      </div>
    )
  }

  return (
    <div className={cn('space-y-4', className)}>
      {/* Main instructions */}
      <div className="grid grid-cols-3 gap-4">
        <div className="text-center p-3 bg-muted/50 rounded-lg">
          <div className="text-2xl mb-1">{washing?.icon}</div>
          <div className="text-xs font-medium">{washing?.label}</div>
          <div className="text-xs text-muted-foreground">{washing?.description}</div>
        </div>
        <div className="text-center p-3 bg-muted/50 rounded-lg">
          <div className="text-2xl mb-1">{drying?.icon}</div>
          <div className="text-xs font-medium">{drying?.label}</div>
          <div className="text-xs text-muted-foreground">{drying?.description}</div>
        </div>
        <div className="text-center p-3 bg-muted/50 rounded-lg">
          <div className="text-2xl mb-1">{ironing?.icon}</div>
          <div className="text-xs font-medium">{ironing?.label}</div>
          <div className="text-xs text-muted-foreground">{ironing?.description}</div>
        </div>
      </div>

      {/* Dry clean notice */}
      {instructions.dryClean && (
        <div className="flex items-center gap-2 p-3 bg-yellow-500/10 border border-yellow-500/20 rounded-lg">
          <span className="text-xl">🧹</span>
          <span className="text-sm font-medium text-yellow-700 dark:text-yellow-400">
            Professional dry cleaning recommended
          </span>
        </div>
      )}

      {/* Special care */}
      {instructions.specialCare.length > 0 && (
        <div className="space-y-2">
          <div className="text-sm font-medium">Special Care</div>
          <div className="flex flex-wrap gap-1">
            {instructions.specialCare.map((care) => (
              <Badge key={care} variant="secondary" className="text-xs">
                {care}
              </Badge>
            ))}
          </div>
        </div>
      )}

      {/* Notes */}
      {instructions.notes && (
        <div className="space-y-1">
          <div className="text-sm font-medium">Notes</div>
          <p className="text-sm text-muted-foreground">{instructions.notes}</p>
        </div>
      )}
    </div>
  )
}

export function MaterialGuideCard({ material, className }: MaterialGuideCardProps) {
  const guide = getMaterialGuide(material)

  if (!guide) {
    return null
  }

  return (
    <div className={cn('p-4 bg-muted/30 rounded-lg border', className)}>
      <div className="flex items-center gap-2 mb-3">
        <span className="text-lg">📖</span>
        <h4 className="font-medium">{guide.material} Care Guide</h4>
      </div>
      <ul className="space-y-1">
        {guide.tips.map((tip, i) => (
          <li key={i} className="text-sm text-muted-foreground flex items-start gap-2">
            <span className="text-primary">•</span>
            {tip}
          </li>
        ))}
      </ul>
    </div>
  )
}

// ============================================================================
// EDITOR COMPONENT
// ============================================================================

function CareInstructionsForm({
  instructions,
  onChange,
  material,
}: {
  instructions: CareInstructions
  onChange: (instructions: CareInstructions) => void
  material?: string
}) {
  const guide = material ? getMaterialGuide(material) : null

  return (
    <div className="space-y-6">
      {/* Material guide hint */}
      {guide && (
        <MaterialGuideCard material={material!} />
      )}

      {/* Washing */}
      <InstructionSelect
        label="Washing"
        value={instructions.washing}
        options={WASHING_OPTIONS}
        onChange={(value) => onChange({ ...instructions, washing: value })}
      />

      {/* Drying */}
      <InstructionSelect
        label="Drying"
        value={instructions.drying}
        options={DRYING_OPTIONS}
        onChange={(value) => onChange({ ...instructions, drying: value })}
      />

      {/* Ironing */}
      <InstructionSelect
        label="Ironing"
        value={instructions.ironing}
        options={IRONING_OPTIONS}
        onChange={(value) => onChange({ ...instructions, ironing: value })}
      />

      {/* Dry clean toggle */}
      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={() => onChange({ ...instructions, dryClean: !instructions.dryClean })}
          className={cn(
            'w-12 h-6 rounded-full transition-colors relative',
            instructions.dryClean ? 'bg-primary' : 'bg-muted'
          )}
        >
          <div
            className={cn(
              'absolute top-1 w-4 h-4 rounded-full bg-white transition-transform',
              instructions.dryClean ? 'translate-x-7' : 'translate-x-1'
            )}
          />
        </button>
        <Label className="text-sm">Recommend dry cleaning</Label>
      </div>

      {/* Special care */}
      <SpecialCareSelector
        selected={instructions.specialCare}
        onChange={(selected) => onChange({ ...instructions, specialCare: selected })}
      />

      {/* Notes */}
      <div className="space-y-2">
        <Label htmlFor="care-notes" className="text-sm font-medium">
          Additional Notes
        </Label>
        <Textarea
          id="care-notes"
          placeholder="Any additional care instructions..."
          value={instructions.notes || ''}
          onChange={(e) => onChange({ ...instructions, notes: e.target.value })}
          rows={3}
        />
      </div>
    </div>
  )
}

export function CareInstructionsEditor({
  itemId,
  material,
  category,
  variant = 'dialog',
  onSave,
  className,
}: CareInstructionsEditorProps) {
  const [instructions, setInstructions] = useState<CareInstructions | null>(null)
  const [isEditing, setIsEditing] = useState(false)
  const [editedInstructions, setEditedInstructions] = useState<CareInstructions | null>(null)

  // Load instructions on mount
  useEffect(() => {
    const stored = getItemCareInstructions(itemId)
    if (stored) {
      setInstructions(stored)
    } else if (material) {
      setInstructions(getDefaultCareForMaterial(material))
    } else if (category) {
      setInstructions(getDefaultCareForCategory(category))
    }
  }, [itemId, material, category])

  const handleEdit = () => {
    setEditedInstructions(instructions)
    setIsEditing(true)
  }

  const handleSave = () => {
    if (editedInstructions) {
      saveItemCareInstructions(itemId, editedInstructions)
      setInstructions(editedInstructions)
      setIsEditing(false)
      onSave?.(editedInstructions)
    }
  }

  const handleCancel = () => {
    setEditedInstructions(null)
    setIsEditing(false)
  }

  const handleApplyDefaults = () => {
    if (material) {
      setEditedInstructions(getDefaultCareForMaterial(material))
    } else if (category) {
      setEditedInstructions(getDefaultCareForCategory(category))
    }
  }

  // Inline variant - just shows icons
  if (variant === 'inline') {
    if (!instructions) return null
    return (
      <div className={cn('flex items-center gap-2', className)}>
        <CareInstructionsDisplay instructions={instructions} variant="icons" />
        <Dialog open={isEditing} onOpenChange={(open) => !open && handleCancel()}>
          <DialogTrigger asChild>
            <Button variant="ghost" size="sm" onClick={handleEdit}>
              Edit
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Care Instructions</DialogTitle>
              <DialogDescription>
                Set washing, drying, and ironing instructions for this item.
              </DialogDescription>
            </DialogHeader>
            {editedInstructions && (
              <CareInstructionsForm
                instructions={editedInstructions}
                onChange={setEditedInstructions}
                material={material}
              />
            )}
            <div className="flex justify-between pt-4">
              <Button variant="outline" onClick={handleApplyDefaults}>
                Apply Defaults
              </Button>
              <div className="flex gap-2">
                <Button variant="outline" onClick={handleCancel}>
                  Cancel
                </Button>
                <Button onClick={handleSave}>Save</Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>
    )
  }

  // Compact variant - shows compact display with edit button
  if (variant === 'compact') {
    return (
      <div className={cn('space-y-2', className)}>
        {instructions ? (
          <>
            <CareInstructionsDisplay instructions={instructions} variant="compact" />
            <Button variant="outline" size="sm" onClick={handleEdit}>
              Edit Care Instructions
            </Button>
          </>
        ) : (
          <Button variant="outline" size="sm" onClick={handleEdit}>
            Add Care Instructions
          </Button>
        )}

        <Dialog open={isEditing} onOpenChange={(open) => !open && handleCancel()}>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Care Instructions</DialogTitle>
              <DialogDescription>
                Set washing, drying, and ironing instructions for this item.
              </DialogDescription>
            </DialogHeader>
            {editedInstructions && (
              <CareInstructionsForm
                instructions={editedInstructions}
                onChange={setEditedInstructions}
                material={material}
              />
            )}
            <div className="flex justify-between pt-4">
              <Button variant="outline" onClick={handleApplyDefaults}>
                Apply Defaults
              </Button>
              <div className="flex gap-2">
                <Button variant="outline" onClick={handleCancel}>
                  Cancel
                </Button>
                <Button onClick={handleSave}>Save</Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>
    )
  }

  // Dialog variant - button that opens full editor
  if (variant === 'dialog') {
    return (
      <Dialog open={isEditing} onOpenChange={(open) => !open && handleCancel()}>
        <DialogTrigger asChild>
          <Button
            variant="outline"
            className={cn('gap-2', className)}
            onClick={handleEdit}
          >
            <span>🧺</span>
            {instructions ? 'Care Instructions' : 'Add Care Instructions'}
            {instructions && (
              <CareInstructionsDisplay instructions={instructions} variant="icons" />
            )}
          </Button>
        </DialogTrigger>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Care Instructions</DialogTitle>
            <DialogDescription>
              Set washing, drying, and ironing instructions for this item.
            </DialogDescription>
          </DialogHeader>
          {editedInstructions && (
            <CareInstructionsForm
              instructions={editedInstructions}
              onChange={setEditedInstructions}
              material={material}
            />
          )}
          <div className="flex justify-between pt-4">
            <Button variant="outline" onClick={handleApplyDefaults}>
              Apply Defaults
            </Button>
            <div className="flex gap-2">
              <Button variant="outline" onClick={handleCancel}>
                Cancel
              </Button>
              <Button onClick={handleSave}>Save</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    )
  }

  // Full variant - shows everything inline
  return (
    <div className={cn('space-y-4', className)}>
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold flex items-center gap-2">
          <span>🧺</span>
          Care Instructions
        </h3>
        {!isEditing && (
          <Button variant="outline" size="sm" onClick={handleEdit}>
            {instructions ? 'Edit' : 'Add'}
          </Button>
        )}
      </div>

      {isEditing && editedInstructions ? (
        <div className="space-y-4">
          <CareInstructionsForm
            instructions={editedInstructions}
            onChange={setEditedInstructions}
            material={material}
          />
          <div className="flex justify-between">
            <Button variant="outline" onClick={handleApplyDefaults}>
              Apply Defaults
            </Button>
            <div className="flex gap-2">
              <Button variant="outline" onClick={handleCancel}>
                Cancel
              </Button>
              <Button onClick={handleSave}>Save</Button>
            </div>
          </div>
        </div>
      ) : instructions ? (
        <CareInstructionsDisplay instructions={instructions} variant="full" />
      ) : (
        <p className="text-sm text-muted-foreground">
          No care instructions set. Click "Add" to specify how to care for this item.
        </p>
      )}
    </div>
  )
}

export default CareInstructionsEditor
