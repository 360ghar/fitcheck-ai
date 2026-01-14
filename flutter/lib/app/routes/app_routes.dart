/// App route constants
class Routes {
  Routes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const oauthCallback = '/oauth-callback';

  // Main app routes
  static const home = '/home';
  static const wardrobe = '/wardrobe';
  static const wardrobeAdd = '/wardrobe/add';
  static const wardrobeBatchAdd = '/wardrobe/batch-add';
  static const wardrobeBatchProgress = '/wardrobe/batch-progress';
  static const wardrobeBatchReview = '/wardrobe/batch-review';
  static const wardrobeItemDetail = '/wardrobe/:id';
  static const wardrobeItemEdit = '/wardrobe/:id/edit';
  static const outfits = '/outfits';
  static const outfitDetail = '/outfits/:id';
  static const outfitEdit = '/outfits/:id/edit';
  static const outfitBuilder = '/outfits/build';
  static const calendar = '/calendar';
  static const recommendations = '/recommendations';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const settings = '/settings';
  static const aiSettings = '/settings/ai';
  static const tryOn = '/try-on';
  static const more = '/more';
  static const gamification = '/gamification';
  static const subscription = '/subscription';
  static const referral = '/referral';
  static const bodyProfiles = '/profile/body-profiles';
  static const help = '/help';
  static const feedback = '/feedback';
  static const sharedOutfit = '/shared/:id';
}
