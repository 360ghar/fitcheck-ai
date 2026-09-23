/// App route constants
class Routes {
  Routes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Main app routes
  static const home = '/home';
  static const wardrobe = '/wardrobe';
  static const wardrobeStats = '/wardrobe/stats';
  static const wardrobeAdd = '/wardrobe/add';
  static const wardrobeBatchAdd = '/wardrobe/batch-add';
  static const wardrobeBatchAddSocial = '/wardrobe/batch-add-social';
  static const wardrobeBatchProgress = '/wardrobe/batch-progress';
  static const wardrobeBatchReview = '/wardrobe/batch-review';
  static String item(String id) => '/wardrobe/$id';
  static String itemEdit(String id) => '/wardrobe/edit/$id';
  static const outfits = '/outfits';
  static String outfit(String id) => '/outfits/$id';
  static String outfitEdit(String id) => '/outfits/edit/$id';
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
  static const gifts = '/gifts';
  static const bodyProfiles = '/profile/body-profiles';
  static const help = '/help';
  static const legal = '/legal';
  static const feedback = '/feedback';
  static const sharedOutfit = '/shared/:id';

  /// Shell tab roots, in bottom-bar order.
  static const tabs = [home, photoshoot, wardrobe, outfits, more];
  static const outfitCollections = '/outfits/collections';
}
