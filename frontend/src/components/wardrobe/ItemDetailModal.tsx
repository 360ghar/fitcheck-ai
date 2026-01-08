/**
 * ItemDetailModal Component
 *
 * Displays detailed information about a wardrobe item.
 * Features:
 * - Full item details with edit capability
 * - Image gallery
 * - Usage statistics (times worn, cost per wear)
 * - Quick actions (edit, delete, mark as worn, favorite)
 *
 * @see https://docs.fitcheck.ai/features/wardrobe/item-management
 */

import { useState } from 'react'
import {
  Shirt,
  Edit,
  Trash2,
  Heart,
  Check,
  X,
  Calendar,
  DollarSign,
  Zap,
  Image as ImageIcon,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Card, CardContent } from '@/components/ui/card'
import type { Item, Category, Condition } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

interface ItemDetailModalProps {
  item: Item | null
  isOpen: boolean
  onClose: () => void
  onEdit?: (item: Item) => void
  onDelete?: (itemId: string) => void
  onToggleFavorite?: (itemId: string) => void
  onMarkAsWorn?: (itemId: string) => void
  onImageUpload?: (itemId: string, file: File) => Promise<void>
}

const CATEGORIES: { value: Category; label: string }[] = [
  { value: 'tops', label: 'Tops' },
  { value: 'bottoms', label: 'Bottoms' },
  { value: 'shoes', label: 'Shoes' },
  { value: 'accessories', label: 'Accessories' },
  { value: 'outerwear', label: 'Outerwear' },
  { value: 'swimwear', label: 'Swimwear' },
  { value: 'activewear', label: 'Activewear' },
  { value: 'other', label: 'Other' },
]

const CONDITIONS: { value: Condition; label: string; className: string }[] = [
  { value: 'clean', label: 'Clean', className: 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300' },
  { value: 'dirty', label: 'Dirty', className: 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300' },
  { value: 'laundry', label: 'In Laundry', className: 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300' },
  { value: 'repair', label: 'Needs Repair', className: 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300' },
  { value: 'donate', label: 'To Donate', className: 'bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-300' },
]

// ============================================================================
// COMPONENT
// ============================================================================

export function ItemDetailModal({
  item,
  isOpen,
  onClose,
  onEdit,
  onDelete,
  onToggleFavorite,
  onMarkAsWorn,
}: ItemDetailModalProps) {
  const [isEditing, setIsEditing] = useState(false)
  const [editForm, setEditForm] = useState<Partial<Item>>({})

  if (!item) return null

  const conditionInfo = CONDITIONS.find((c) => c.value === item.condition)

  const handleEdit = () => {
    setEditForm(item)
    setIsEditing(true)
  }

  const handleSave = () => {
    onEdit?.(editForm as Item)
    setIsEditing(false)
  }

  const handleCancel = () => {
    setIsEditing(false)
    setEditForm({})
  }

  const updateField = <K extends keyof Item>(field: K, value: Item[K]) => {
    setEditForm((prev) => ({ ...prev, [field]: value }))
  }

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-w-3xl max-h-[90vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle className="flex items-center justify-between">
            <span>{isEditing ? 'Edit Item' : item.name}</span>
            <div className="flex items-center gap-2">
              {!isEditing && (
                <>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => onToggleFavorite?.(item.id)}
                  >
                    <Heart
                      className={`h-5 w-5 ${item.is_favorite ? 'fill-pink-500 text-pink-500' : ''}`}
                    />
                  </Button>
                  <Button variant="ghost" size="icon" onClick={handleEdit}>
                    <Edit className="h-5 w-5" />
                  </Button>
                </>
              )}
            </div>
          </DialogTitle>
          <DialogDescription>
            {isEditing ? 'Update the item details below.' : `Added on ${new Date(item.created_at).toLocaleDateString()}`}
          </DialogDescription>
        </DialogHeader>

        <div className="flex-1 overflow-y-auto">
          <Tabs defaultValue="details" className="w-full">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="details">Details</TabsTrigger>
              <TabsTrigger value="images">Images</TabsTrigger>
              <TabsTrigger value="stats">Statistics</TabsTrigger>
            </TabsList>

            {/* Details Tab */}
            <TabsContent value="details" className="space-y-4">
              <div className="grid md:grid-cols-2 gap-6">
                {/* Image */}
                <div className="aspect-square rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-700">
                  {item.images.length > 0 ? (
                    <img
                      src={item.images[0].image_url}
                      alt={item.name}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center">
                      <Shirt className="h-24 w-24 text-gray-300 dark:text-gray-500" />
                    </div>
                  )}
                </div>

                {/* Form */}
                <div className="space-y-4">
                  {isEditing ? (
                    <>
                      <div>
                        <Label htmlFor="edit-name">Name</Label>
                        <Input
                          id="edit-name"
                          value={editForm.name}
                          onChange={(e) => updateField('name', e.target.value)}
                        />
                      </div>

                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <Label htmlFor="edit-category">Category</Label>
                          <Select
                            value={editForm.category}
                            onValueChange={(value) => updateField('category', value as Category)}
                          >
                            <SelectTrigger id="edit-category">
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              {CATEGORIES.map((cat) => (
                                <SelectItem key={cat.value} value={cat.value}>
                                  {cat.label}
                                </SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                        </div>
                        <div>
                          <Label htmlFor="edit-condition">Condition</Label>
                          <Select
                            value={editForm.condition}
                            onValueChange={(value) => updateField('condition', value as Condition)}
                          >
                            <SelectTrigger id="edit-condition">
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              {CONDITIONS.map((cond) => (
                                <SelectItem key={cond.value} value={cond.value}>
                                  {cond.label}
                                </SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                        </div>
                      </div>

                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <Label htmlFor="edit-brand">Brand</Label>
                          <Input
                            id="edit-brand"
                            value={editForm.brand || ''}
                            onChange={(e) => updateField('brand', e.target.value)}
                            placeholder="Optional"
                          />
                        </div>
                        <div>
                          <Label htmlFor="edit-size">Size</Label>
                          <Input
                            id="edit-size"
                            value={editForm.size || ''}
                            onChange={(e) => updateField('size', e.target.value)}
                            placeholder="Optional"
                          />
                        </div>
                      </div>

                      <div>
                        <Label htmlFor="edit-notes">Notes</Label>
                        <Textarea
                          id="edit-notes"
                          value={editForm.notes || ''}
                          onChange={(e) => updateField('notes', e.target.value)}
                          rows={3}
                        />
                      </div>
                    </>
                  ) : (
                    <>
                      <div>
                        <Label className="text-sm text-gray-500 dark:text-gray-400">Category</Label>
                        <p className="font-medium capitalize text-gray-900 dark:text-white">{item.category}</p>
                        {item.sub_category && (
                          <p className="text-sm text-gray-600 dark:text-gray-400 capitalize">{item.sub_category}</p>
                        )}
                      </div>

                      <div>
                        <Label className="text-sm text-gray-500 dark:text-gray-400">Condition</Label>
                        <Badge className={conditionInfo?.className}>{conditionInfo?.label}</Badge>
                      </div>

                      {item.brand && (
                        <div>
                          <Label className="text-sm text-gray-500 dark:text-gray-400">Brand</Label>
                          <p className="font-medium text-gray-900 dark:text-white">{item.brand}</p>
                        </div>
                      )}

                      {item.size && (
                        <div>
                          <Label className="text-sm text-gray-500 dark:text-gray-400">Size</Label>
                          <p className="font-medium text-gray-900 dark:text-white">{item.size}</p>
                        </div>
                      )}

                      {item.colors.length > 0 && (
                        <div>
                          <Label className="text-sm text-gray-500 dark:text-gray-400">Colors</Label>
                          <div className="flex flex-wrap gap-1 mt-1">
                            {item.colors.map((color) => (
                              <Badge key={color} variant="outline">
                                {color}
                              </Badge>
                            ))}
                          </div>
                        </div>
                      )}

                      {item.tags.length > 0 && (
                        <div>
                          <Label className="text-sm text-gray-500 dark:text-gray-400">Tags</Label>
                          <div className="flex flex-wrap gap-1 mt-1">
                            {item.tags.map((tag) => (
                              <Badge key={tag} variant="secondary">
                                {tag}
                              </Badge>
                            ))}
                          </div>
                        </div>
                      )}

                      {item.notes && (
                        <div>
                          <Label className="text-sm text-gray-500 dark:text-gray-400">Notes</Label>
                          <p className="text-sm text-gray-700 dark:text-gray-300">{item.notes}</p>
                        </div>
                      )}

                      {item.price && (
                        <div>
                          <Label className="text-sm text-gray-500 dark:text-gray-400">Price</Label>
                          <p className="font-medium text-gray-900 dark:text-white">${item.price.toFixed(2)}</p>
                        </div>
                      )}
                    </>
                  )}
                </div>
              </div>
            </TabsContent>

            {/* Images Tab */}
            <TabsContent value="images">
              <Card>
                <CardContent className="pt-6">
                  {item.images.length > 0 ? (
                    <div className="grid grid-cols-3 gap-4">
                      {item.images.map((image) => (
                        <div key={image.id} className="aspect-square rounded-lg overflow-hidden">
                          <img
                            src={image.image_url}
                            alt={item.name}
                            className="w-full h-full object-cover"
                          />
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="text-center py-12 text-gray-500 dark:text-gray-400">
                      <ImageIcon className="h-12 w-12 mx-auto mb-4 opacity-50" />
                      <p>No additional images</p>
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>

            {/* Statistics Tab */}
            <TabsContent value="stats">
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <Card>
                  <CardContent className="pt-6 text-center">
                    <Zap className="h-8 w-8 mx-auto text-indigo-500 mb-2" />
                    <p className="text-2xl font-bold text-gray-900 dark:text-white">{item.usage_times_worn}</p>
                    <p className="text-sm text-gray-600 dark:text-gray-400">Times Worn</p>
                  </CardContent>
                </Card>

                {item.cost_per_wear && (
                  <Card>
                    <CardContent className="pt-6 text-center">
                      <DollarSign className="h-8 w-8 mx-auto text-green-500 mb-2" />
                      <p className="text-2xl font-bold text-gray-900 dark:text-white">${item.cost_per_wear.toFixed(2)}</p>
                      <p className="text-sm text-gray-600 dark:text-gray-400">Cost Per Wear</p>
                    </CardContent>
                  </Card>
                )}

                {item.usage_last_worn && (
                  <Card>
                    <CardContent className="pt-6 text-center">
                      <Calendar className="h-8 w-8 mx-auto text-blue-500 mb-2" />
                      <p className="text-sm font-medium text-gray-900 dark:text-white">{new Date(item.usage_last_worn).toLocaleDateString()}</p>
                      <p className="text-sm text-gray-600 dark:text-gray-400">Last Worn</p>
                    </CardContent>
                  </Card>
                )}

                {item.price && (
                  <Card>
                    <CardContent className="pt-6 text-center">
                      <DollarSign className="h-8 w-8 mx-auto text-purple-500 mb-2" />
                      <p className="text-2xl font-bold text-gray-900 dark:text-white">${item.price.toFixed(2)}</p>
                      <p className="text-sm text-gray-600 dark:text-gray-400">Purchase Price</p>
                    </CardContent>
                  </Card>
                )}
              </div>
            </TabsContent>
          </Tabs>
        </div>

        <DialogFooter className="border-t dark:border-gray-700 pt-4">
          {isEditing ? (
            <>
              <Button variant="outline" onClick={handleCancel}>
                <X className="h-4 w-4 mr-2" />
                Cancel
              </Button>
              <Button onClick={handleSave}>
                <Check className="h-4 w-4 mr-2" />
                Save Changes
              </Button>
            </>
          ) : (
            <>
              <Button variant="outline" onClick={() => onMarkAsWorn?.(item.id)}>
                <Check className="h-4 w-4 mr-2" />
                Mark as Worn
              </Button>
              <Button variant="destructive" onClick={() => onDelete?.(item.id)}>
                <Trash2 className="h-4 w-4 mr-2" />
                Delete
              </Button>
            </>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

export default ItemDetailModal
