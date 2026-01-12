/**
 * LoginPromptModal Component
 *
 * Modal that prompts users to login/register after using demo features.
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
import { Sparkles, ArrowRight, Check } from 'lucide-react'

interface LoginPromptModalProps {
  isOpen: boolean
  onClose: () => void
  feature: string
}

export function LoginPromptModal({ isOpen, onClose, feature }: LoginPromptModalProps) {
  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <div className="flex justify-center mb-4">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-gold-400 to-gold-600 flex items-center justify-center">
              <Sparkles className="w-8 h-8 text-navy-900" />
            </div>
          </div>
          <DialogTitle className="text-center text-xl font-display">
            Unlock Full Access
          </DialogTitle>
          <DialogDescription className="text-center">
            Create a free account to {feature} and enjoy unlimited AI features.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 mt-4">
          <ul className="space-y-2 text-sm text-navy-500 dark:text-navy-300">
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-gold-500" />
              Unlimited item extractions
            </li>
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-gold-500" />
              Unlimited virtual try-ons
            </li>
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-gold-500" />
              Save items to your wardrobe
            </li>
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-gold-500" />
              AI outfit recommendations
            </li>
          </ul>

          <div className="flex flex-col gap-2">
            <Button
              variant="gold"
              className="w-full"
              asChild
            >
              <Link to="/auth/register">
                Use It Free
                <ArrowRight className="w-4 h-4 ml-2" />
              </Link>
            </Button>
            <Button variant="ghost" className="w-full text-navy-500 hover:text-navy-700 dark:text-navy-300 dark:hover:text-navy-100" asChild>
              <Link to="/auth/login">Already have an account? Sign in</Link>
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
