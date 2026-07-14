/**
 * AvatarRequiredPrompt - Displayed when user attempts to use Try My Look without a profile picture.
 */

import { useNavigate } from 'react-router-dom'
import { Camera, User, Sun, UserCircle } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'

interface AvatarRequiredPromptProps {
  onGoToProfile?: () => void
}

export function AvatarRequiredPrompt({ onGoToProfile }: AvatarRequiredPromptProps) {
  const navigate = useNavigate()

  const handleGoToProfile = () => {
    if (onGoToProfile) {
      onGoToProfile()
    } else {
      navigate('/profile?tab=account')
    }
  }

  return (
    <div className="flex items-center justify-center min-h-[60vh] p-4">
      <Card className="max-w-md w-full">
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 h-16 w-16 rounded-full bg-primary/10 flex items-center justify-center">
            <Camera className="h-8 w-8 text-primary" />
          </div>
          <CardTitle className="text-xl">Profile photo required</CardTitle>
          <CardDescription className="mt-2">
            Upload a clear full-body or waist-up photo so we can show how clothes look on you.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="flex flex-col items-center gap-4 p-6 bg-muted rounded-lg">
            <div className="h-24 w-24 rounded-full bg-background border border-border flex items-center justify-center">
              <User className="h-12 w-12 text-muted-foreground" />
            </div>
            <ul className="text-sm text-muted-foreground space-y-2 w-full">
              <li className="flex items-start gap-2">
                <Sun className="h-4 w-4 mt-0.5 shrink-0 text-primary" />
                Good lighting, face and torso visible
              </li>
              <li className="flex items-start gap-2">
                <UserCircle className="h-4 w-4 mt-0.5 shrink-0 text-primary" />
                Neutral pose, minimal background clutter
              </li>
            </ul>
          </div>
          <Button className="w-full" onClick={handleGoToProfile}>
            <Camera className="h-4 w-4 mr-2" />
            Go to profile to upload
          </Button>
        </CardContent>
      </Card>
    </div>
  )
}

export default AvatarRequiredPrompt
