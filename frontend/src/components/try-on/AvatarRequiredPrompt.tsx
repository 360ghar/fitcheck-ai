/**
 * AvatarRequiredPrompt - Displayed when user attempts to use Try My Look without a profile picture.
 */

import { useNavigate } from 'react-router-dom';
import { Camera, User } from 'lucide-react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

interface AvatarRequiredPromptProps {
  onGoToProfile?: () => void;
}

export function AvatarRequiredPrompt({ onGoToProfile }: AvatarRequiredPromptProps) {
  const navigate = useNavigate();

  const handleGoToProfile = () => {
    if (onGoToProfile) {
      onGoToProfile();
    } else {
      navigate('/profile');
    }
  };

  return (
    <div className="flex items-center justify-center min-h-[60vh] p-4">
      <Card className="max-w-md w-full">
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 h-16 w-16 rounded-full bg-gold-100 dark:bg-gold-900/30 flex items-center justify-center">
            <Camera className="h-8 w-8 text-gold-600 dark:text-gold-400" />
          </div>
          <CardTitle className="text-xl">Profile Picture Required</CardTitle>
          <CardDescription className="mt-2">
            To use "Try My Look", we need your profile picture to show how you'd look in the clothes.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="flex flex-col items-center gap-4 p-6 bg-muted rounded-lg">
            <div className="h-24 w-24 rounded-full bg-muted-foreground/20 flex items-center justify-center">
              <User className="h-12 w-12 text-muted-foreground" />
            </div>
            <p className="text-sm text-muted-foreground text-center">
              Your profile picture will be used to create personalized try-on visualizations showing how clothes look on you.
            </p>
          </div>
          <Button
            className="w-full"
            onClick={handleGoToProfile}
          >
            <Camera className="h-4 w-4 mr-2" />
            Go to Profile to Upload
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}

export default AvatarRequiredPrompt;
