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
  static const wardrobeStats = '/wardrobe/stats';
  static const wardrobeAdd = '/wardrobe/add';
  static const wardrobeBatchAdd = '/wardrobe/batch-add';
  static const wardrobeBatchAddSocial = '/wardrobe/batch-add-social';
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
  static const photoshoot = '/photoshoot';
  static const more = '/more';
  static const gamification = '/gamification';
  static const subscription = '/subscription';
  static const referral = '/referral';
  static const bodyProfiles = '/profile/body-profiles';
  static const help = '/help';
  static const legal = '/legal';
  static const feedback = '/feedback';
  static const sharedOutfit = '/shared/:id';
  static const outfitCollections = '/outfits/collections';
}
