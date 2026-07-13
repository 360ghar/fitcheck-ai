/**
 * LoginPromptModal - shown after demo features that need an account to save work.
 */

import { Link } from 'react-router-dom'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Shirt, ArrowRight, Check } from 'lucide-react'

interface LoginPromptModalProps {
  isOpen: boolean
  onClose: () => void
  feature: string
}

export function LoginPromptModal({ isOpen, onClose, feature }: LoginPromptModalProps) {
  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-md border-stone-200 dark:border-stone-800">
        <DialogHeader>
          <div className="flex justify-center mb-4">
            <div className="w-14 h-14 rounded-xl bg-indigo-600 flex items-center justify-center">
              <Shirt className="w-7 h-7 text-white" />
            </div>
          </div>
          <DialogTitle className="text-center text-xl font-semibold text-stone-900 dark:text-stone-50">
            Save your work
          </DialogTitle>
          <DialogDescription className="text-center text-stone-600 dark:text-stone-400">
            Create a free account to {feature}. Your demo result stays ready after you sign up.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 mt-4">
          <ul className="space-y-2 text-sm text-stone-600 dark:text-stone-400">
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-indigo-600 dark:text-indigo-400 shrink-0" />
              Keep extracted items in your wardrobe
            </li>
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-indigo-600 dark:text-indigo-400 shrink-0" />
              Save try-ons and photoshoot results
            </li>
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-indigo-600 dark:text-indigo-400 shrink-0" />
              Daily outfit recommendations
            </li>
          </ul>

          <div className="flex flex-col gap-2">
            <Button
              className="w-full bg-indigo-600 hover:bg-indigo-700 text-white shadow-none"
              asChild
            >
              <Link to="/auth/register">
                Use free
                <ArrowRight className="w-4 h-4 ml-2" />
              </Link>
            </Button>
            <Button variant="ghost" className="w-full text-stone-600 dark:text-stone-400" asChild>
              <Link to="/auth/login">Already have an account? Log in</Link>
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
