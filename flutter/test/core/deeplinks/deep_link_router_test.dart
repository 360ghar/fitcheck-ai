import 'package:fitcheck_ai/app/routes/app_routes.dart';
import 'package:fitcheck_ai/core/deeplinks/deep_link_router.dart';
import 'package:flutter_test/flutter_test.dart';

/// The deep-link contract the custom product pages are written against.
///
/// Each campaign in App Store Connect points at one of these URLs. If a row
/// here stops resolving, a live campaign lands on the wrong screen, so the
/// table is the test.
const Map<String, String> _campaignLinks = {
  'fitcheck.ai://home': Routes.home,
  'fitcheck.ai://wardrobe': Routes.wardrobe,
  'fitcheck.ai://wardrobe/batch-add': Routes.wardrobeBatchAdd,
  'fitcheck.ai://wardrobe/batch-add-social': Routes.wardrobeBatchAddSocial,
  'fitcheck.ai://wardrobe/stats': Routes.wardrobeStats,
  'fitcheck.ai://outfits': Routes.outfits,
  'fitcheck.ai://outfits/build': Routes.outfitBuilder,
  'fitcheck.ai://outfits/collections': Routes.outfitCollections,
  'fitcheck.ai://calendar': Routes.calendar,
  'fitcheck.ai://photoshoot': Routes.photoshoot,
  'fitcheck.ai://try-on': Routes.tryOn,
  'fitcheck.ai://recommendations': Routes.recommendations,
  'fitcheck.ai://subscription': Routes.subscription,
  'fitcheck.ai://referral': Routes.referral,
  'fitcheck.ai://gifts': Routes.gifts,
  'fitcheck.ai://gamification': Routes.gamification,
  'fitcheck.ai://profile': Routes.profile,
  'fitcheck.ai://profile/body-profiles': Routes.bodyProfiles,
  'fitcheck.ai://settings': Routes.settings,
  'fitcheck.ai://settings/language': Routes.language,
  'fitcheck.ai://help': Routes.help,
  'fitcheck.ai://legal': Routes.legal,
  'fitcheck.ai://feedback': Routes.feedback,
  'fitcheck.ai://more': Routes.more,
};

void main() {
  group('resolveDeepLink maps campaign links', () {
    for (final entry in _campaignLinks.entries) {
      test(entry.key, () {
        expect(resolveDeepLink(Uri.parse(entry.key)), entry.value);
      });
    }
  });

  group('resolveDeepLink normalises shapes', () {
    test('three-slash form', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai:///wardrobe/batch-add')),
        Routes.wardrobeBatchAdd,
      );
    });

    test('trailing slash', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://subscription/')),
        Routes.subscription,
      );
    });

    test('duplicate slashes', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://outfits//collections')),
        Routes.outfitCollections,
      );
    });

    test('scheme is case-insensitive', () {
      expect(
        resolveDeepLink(Uri.parse('FITCHECK.AI://subscription')),
        Routes.subscription,
      );
    });

    test('a query string is ignored, not interpreted', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://subscription?pp=campaign-1')),
        Routes.subscription,
      );
    });

    test('a fragment is ignored', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://gifts#top')),
        Routes.gifts,
      );
    });
  });

  group('resolveDeepLink carries one id', () {
    test('shared outfit', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://shared/abc123')),
        '/shared/abc123',
      );
    });

    test('outfit detail', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://outfits/xyz')),
        '/outfits/xyz',
      );
    });

    test('wardrobe item detail', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://wardrobe/abc')),
        '/wardrobe/abc',
      );
    });

    test('the id keeps its case', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://SHARED/AbC-1')),
        '/shared/AbC-1',
      );
    });

    test('static paths win over the :id siblings', () {
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://outfits/build')),
        Routes.outfitBuilder,
      );
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://wardrobe/stats')),
        Routes.wardrobeStats,
      );
    });
  });

  group('resolveDeepLink refuses what it does not own', () {
    test('an unknown path lands on home, never a blank screen', () {
      expect(resolveDeepLink(Uri.parse('fitcheck.ai://nonsense')), Routes.home);
      expect(
        resolveDeepLink(Uri.parse('fitcheck.ai://outfits/a/b')),
        Routes.home,
      );
      expect(resolveDeepLink(Uri.parse('fitcheck.ai://shared/')), Routes.home);
    });

    test('an empty link lands on home', () {
      expect(resolveDeepLink(Uri.parse('fitcheck.ai://')), Routes.home);
    });

    test('another scheme is not ours', () {
      expect(resolveDeepLink(Uri.parse('https://fitcheckaiapp.com/wardrobe')), isNull);
      expect(resolveDeepLink(Uri.parse('fitcheck.something://wardrobe')), isNull);
    });

    // The OAuth callback does session work in
    // batch_extraction_provider.dart, not navigation. If this test ever fails,
    // the generic router has started stealing (or blocking) the social import
    // callback and that flow is broken.
    test('the social import OAuth callback is left to its owner', () {
      const callback = 'fitcheck.ai://social-import-callback'
          '?job_id=social-9&status=success';
      expect(resolveDeepLink(Uri.parse(callback)), isNull);
    });
  });

  group('DeepLinkController', () {
    test('navigates for our links and ignores everything else', () async {
      final visited = <String>[];
      final controller = DeepLinkController(
        onNavigate: visited.add,
        // No platform channel: start() must not throw without one.
        enabled: true,
      );
      addTearDown(controller.dispose);

      expect(controller.handle(Uri.parse('fitcheck.ai://gifts')), isTrue);
      expect(
        controller.handle(
          Uri.parse('fitcheck.ai://social-import-callback?status=success'),
        ),
        isFalse,
      );
      expect(controller.handle(Uri.parse('https://example.com')), isFalse);
      expect(visited, [Routes.gifts]);
    });

    test('does not re-navigate to the screen already shown', () {
      final visited = <String>[];
      final controller = DeepLinkController(
        onNavigate: visited.add,
        navigateTo: () => Routes.subscription,
        enabled: true,
      );
      addTearDown(controller.dispose);

      expect(controller.handle(Uri.parse('fitcheck.ai://subscription')), isFalse);
      expect(visited, isEmpty);
    });

    test('start() is a no-op when disabled', () async {
      final controller = DeepLinkController(
        onNavigate: (_) => fail('must not navigate'),
        enabled: false,
      );
      addTearDown(controller.dispose);
      await controller.start();
    });
  });
}
