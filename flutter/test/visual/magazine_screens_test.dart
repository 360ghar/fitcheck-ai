import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/core/services/theme_service.dart';
import 'package:fitcheck_ai/core/widgets/app_bottom_navigation_bar.dart';
import 'package:fitcheck_ai/core/widgets/app_ui.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/auth/controllers/auth_controller.dart';
import 'package:fitcheck_ai/features/auth/models/user_model.dart';
import 'package:fitcheck_ai/features/auth/services/auth_service.dart';
import 'package:fitcheck_ai/features/auth/services/referral_service.dart';
import 'package:fitcheck_ai/features/auth/services/user_initialization_service.dart';
import 'package:fitcheck_ai/features/auth/views/auth_entry_page.dart';
import 'package:fitcheck_ai/features/subscription/repositories/subscription_repository.dart';
import 'package:fitcheck_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:fitcheck_ai/features/dashboard/models/dashboard_models.dart';
import 'package:fitcheck_ai/features/dashboard/views/dashboard_content.dart';
import 'package:fitcheck_ai/features/gifts/controllers/gift_controller.dart';
import 'package:fitcheck_ai/features/photoshoot/controllers/photoshoot_controller.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_list_controller.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_generation_controller.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/views/outfits_content.dart';
import 'package:fitcheck_ai/features/profile/views/profile_content.dart';
import 'package:fitcheck_ai/features/settings/controllers/settings_controller.dart';
import 'package:fitcheck_ai/features/shell/controllers/main_shell_controller.dart';
import 'package:fitcheck_ai/features/shell/views/studio_content.dart';
import 'package:fitcheck_ai/features/shell/views/main_shell_page.dart';
import 'package:fitcheck_ai/features/tryon/controllers/tryon_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/wardrobe_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/views/wardrobe_content.dart';

// Fixture controllers only suppress network/plugin startup; views and state are real.
class _Network extends NetworkService {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Wardrobe extends WardrobeController {
  _Wardrobe() : super(networkService: _Network());
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Dashboard extends DashboardController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Outfits extends OutfitListController {
  _Outfits() : super(networkService: _Network());
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Auth extends AuthController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Settings extends SettingsController {
  _Settings() : super(themeService: ThemeService());
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Gifts extends GiftController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Photoshoot extends PhotoshootController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _TryOn extends TryOnController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String flatlay;
  late String outfit;
  late String shirt;
  late String trousers;
  late String loafers;
  late String overshirt;

  setUpAll(() async {
    shirt =
        'data:image/png;base64,${base64Encode(await File('test/fixtures/garment-ecru-shirt.png').readAsBytes())}';
    trousers =
        'data:image/png;base64,${base64Encode(await File('test/fixtures/garment-charcoal-trousers.png').readAsBytes())}';
    loafers =
        'data:image/png;base64,${base64Encode(await File('test/fixtures/garment-tobacco-loafers.png').readAsBytes())}';
    overshirt =
        'data:image/png;base64,${base64Encode(await File('test/fixtures/garment-sage-overshirt.png').readAsBytes())}';
    flatlay =
        'data:image/webp;base64,${base64Encode(await File('test/fixtures/flatlay.webp').readAsBytes())}';
    outfit =
        'data:image/webp;base64,${base64Encode(await File('test/fixtures/outfit.webp').readAsBytes())}';
    await (FontLoader(
      'BodoniModa',
    )..addFont(rootBundle.load('assets/fonts/BodoniModa.ttf'))).load();
    // Use the SDK's pinned fonts so CI and macOS do not render Ahem test glyphs.
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    for (final font in [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
    ]) {
      final bytes = await File(
        '$sdk/bin/cache/artifacts/material_fonts/$font',
      ).readAsBytes();
      await (FontLoader(
        'Roboto',
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    final icons = await File(
      '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ).readAsBytes();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(Future.value(ByteData.sublistView(icons)))).load();
  });

  setUp(() {
    Get.testMode = true;
    Get.put<AuthService>(AuthService());
    Get.put<ReferralService>(
      ReferralService(
        persistence: PersistenceService(),
        userInitService: UserInitializationService(
          subscriptionRepo: SubscriptionRepository(),
        ),
      ),
    );
    Get.put<AuthController>(_Auth());
    Get.put<SettingsController>(_Settings());
    Get.put<GiftController>(_Gifts()..hasLoaded.value = true);
    Get.put<MainShellController>(MainShellController());
    Get.put<PhotoshootController>(_Photoshoot());
    Get.put<TryOnController>(_TryOn());
    Get.put<OutfitGenerationController>(OutfitGenerationController());
    Get.put<OutfitListController>(
      _Outfits()
        ..hasMore.value = false
        ..totalOutfits.value = 2
        ..outfits.assignAll([
          OutfitModel(
            id: 'weekend',
            userId: 'fixture',
            name: 'The weekend edit',
            itemIds: const ['piece'],
            outfitImages: [OutfitImage(id: 'look', url: outfit)],
          ),
          OutfitModel(
            id: 'essentials',
            userId: 'fixture',
            name: 'Everyday essentials',
            itemIds: const ['piece'],
            outfitImages: [OutfitImage(id: 'flat', url: flatlay)],
          ),
        ]),
    );
    Get.put<DashboardController>(
      _Dashboard()
        ..dashboard.value = DashboardData(
          statistics: const DashboardStats(
            totalItems: 24,
            totalOutfits: 6,
            itemsAddedThisMonth: 4,
            outfitsCreatedThisMonth: 2,
            favoriteItemsCount: 3,
            favoriteOutfitsCount: 2,
          ),
          recentActivity: const [],
          suggestions: DashboardSuggestions(
            weatherBased: null,
            outfitOfTheDay: DashboardOutfitOfTheDay(
              id: 'look',
              name: 'The weekend edit',
              imageUrl: outfit,
            ),
          ),
        ),
    );
    Get.put<WardrobeController>(
      _Wardrobe()
        ..hasMore.value = false
        ..totalItems.value = 4
        ..items.assignAll([
          ItemModel(
            id: 'piece',
            userId: 'fixture',
            name: 'Ecru linen shirt',
            category: Category.tops,
            condition: domain.Condition.clean,
            brand: 'Your wardrobe',
            itemImages: [ItemImage(id: 'photo', url: shirt, isPrimary: true)],
          ),
          ItemModel(
            id: 'look',
            userId: 'fixture',
            name: 'Charcoal tailored trousers',
            category: Category.bottoms,
            condition: domain.Condition.clean,
            isFavorite: true,
            itemImages: [
              ItemImage(id: 'photo2', url: trousers, isPrimary: true),
            ],
          ),
          ItemModel(
            id: 'shoes',
            userId: 'fixture',
            name: 'Tobacco suede loafers',
            category: Category.shoes,
            condition: domain.Condition.clean,
            itemImages: [
              ItemImage(id: 'photo3', url: loafers, isPrimary: true),
            ],
          ),
          ItemModel(
            id: 'jacket',
            userId: 'fixture',
            name: 'Sage overshirt',
            category: Category.outerwear,
            condition: domain.Condition.clean,
            itemImages: [
              ItemImage(id: 'photo4', url: overshirt, isPrimary: true),
            ],
          ),
        ]),
    );
  });
  tearDown(() => Get.reset());

  Future<void> pump(
    WidgetTester tester,
    Widget body, {
    double width = 390,
    double height = 844,
    double pixelRatio = 1,
    TargetPlatform platform = TargetPlatform.android,
    bool dark = false,
    double scale = 1,
    int tab = 0,
    int? tool,
    bool shell = true,
    bool liveShell = false,
  }) async {
    tester.view.physicalSize = Size(width * pixelRatio, height * pixelRatio);
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: (dark ? AppTheme.darkTheme : AppTheme.lightTheme).copyWith(
          platform: platform,
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: child!,
        ),
        getPages: [
          GetPage(
            name: '/wardrobe/:id',
            page: () => const Scaffold(body: Text('Item detail fixture')),
          ),
        ],
        home: RepaintBoundary(
          key: const ValueKey('screen'),
          child: liveShell
              ? MainShellPage(initialTab: tab, initialStudioTool: tool)
              : shell
              ? Scaffold(
                  body: body,
                  bottomNavigationBar: AppBottomNavigationBar(
                    currentIndex: tab,
                    onTabChanged: (_) {},
                  ),
                )
              : body,
        ),
      ),
    );
    // The shell selects a lazy destination after its first frame. Mount that
    // destination before waiting for its image codecs, which use real async.
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future.wait([
        for (final element in find.byType(Image).evaluate())
          precacheImage((element.widget as Image).image, element),
      ]).timeout(const Duration(seconds: 10));
    });
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<RawImage>(find.byType(RawImage))
          .every((image) => image.image != null),
      isTrue,
      reason: 'Visual fixtures must contain decoded images before capture.',
    );
    expect(tester.takeException(), isNull);
  }

  // Opt-in exports use the same real views, controllers, and local image
  // fixtures as the visual tests. They never update the checked-in goldens.
  // flutter test --dart-define=STORE_EXPORTS=true test/visual/magazine_screens_test.dart
  if (const bool.fromEnvironment('STORE_EXPORTS')) {
    const presets = [
      (
        name: 'ios-phone',
        width: 390.0,
        height: 844.0,
        pixelRatio: 3.0,
        platform: TargetPlatform.iOS,
      ),
      (
        name: 'ios-ipad',
        width: 1032.0,
        height: 1376.0,
        pixelRatio: 2.0,
        platform: TargetPlatform.iOS,
      ),
      (
        name: 'android-phone',
        width: 390.0,
        height: 720.0,
        pixelRatio: 3.0,
        platform: TargetPlatform.android,
      ),
      (
        name: 'android-tablet7',
        width: 720.0,
        height: 1280.0,
        pixelRatio: 2.0,
        platform: TargetPlatform.android,
      ),
      (
        name: 'android-tablet10',
        width: 900.0,
        height: 1600.0,
        pixelRatio: 2.0,
        platform: TargetPlatform.android,
      ),
    ];
    const screens = [
      (name: '01-closet', tab: 1, tool: 0, dark: false),
      (name: '02-home', tab: 0, tool: 0, dark: false),
      (name: '03-outfits', tab: 2, tool: 0, dark: false),
      (name: '04-tryon', tab: 3, tool: 1, dark: false),
      (name: '05-photoshoot', tab: 3, tool: 0, dark: false),
      (name: '06-dark-closet', tab: 1, tool: 0, dark: true),
    ];
    for (final preset in presets) {
      for (final screen in screens) {
        testWidgets('Store export ${preset.name}/${screen.name}', (
          tester,
        ) async {
          // Store captures describe the same sample collection on every tab.
          // Keep the broader regression fixtures above unchanged.
          final items = Get.find<WardrobeController>().items;
          final outfits = Get.find<OutfitListController>().outfits;
          final dashboard = Get.find<DashboardController>();
          final sample = dashboard.dashboard.value!;
          final addedItem = items.firstWhere((item) => item.id == 'piece');
          final createdOutfit = outfits.firstWhere(
            (outfit) => outfit.id == 'weekend',
          );
          dashboard.dashboard.value = DashboardData(
            statistics: DashboardStats(
              totalItems: items.length,
              totalOutfits: outfits.length,
              itemsAddedThisMonth: items.length,
              outfitsCreatedThisMonth: outfits.length,
              favoriteItemsCount: items.where((item) => item.isFavorite).length,
              favoriteOutfitsCount: outfits
                  .where((outfit) => outfit.isFavorite)
                  .length,
            ),
            // Synthetic manual activity references the same sample pieces.
            // These captures do not claim an AI generation result.
            recentActivity: [
              DashboardActivity(
                type: 'outfit_created',
                description: 'Created ${createdOutfit.name}',
                timestamp: DateTime(2026, 9, 5),
                imageUrl: createdOutfit.outfitImages!.first.url,
              ),
              DashboardActivity(
                type: 'item_created',
                description: 'Added ${addedItem.name}',
                timestamp: DateTime(2026, 9, 5),
                imageUrl: addedItem.itemImages!.first.url,
              ),
            ],
            suggestions: sample.suggestions,
          );
          dashboard.streak.value = const StreakData(
            currentStreak: 0,
            longestStreak: 0,
            streakFreezesRemaining: 0,
            streakSkipsRemaining: 0,
            nextMilestone: null,
          );
          final stats = dashboard.dashboard.value!.statistics;
          expect(
            (
              stats.totalItems,
              stats.totalOutfits,
              stats.itemsAddedThisMonth,
              stats.outfitsCreatedThisMonth,
              stats.favoriteItemsCount,
              stats.favoriteOutfitsCount,
            ),
            (4, 2, 4, 2, 1, 0),
            reason: 'Store statistics must match the shared sample collection.',
          );
          if (screen.tool == 1) {
            final avatar = File('test/fixtures/outfit.webp');
            final garment = File('test/fixtures/garment-ecru-shirt.png');
            // FileImage starts filesystem I/O as well as a codec. Resolve it
            // in real async before a fake-async frame starts that same load.
            await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
            final context = tester.element(find.byType(MaterialApp));
            await tester.runAsync(
              () => Future.wait([
                precacheImage(FileImage(avatar), context),
                precacheImage(FileImage(garment), context),
              ]).timeout(const Duration(seconds: 10)),
            );
            Get.find<TryOnController>()
              ..userAvatarUrl.value = avatar.path
              ..isAvatarReady.value = true
              ..clothingImage.value = garment;
          }
          await pump(
            tester,
            const SizedBox.shrink(),
            width: preset.width,
            height: preset.height,
            pixelRatio: preset.pixelRatio,
            platform: preset.platform,
            dark: screen.dark,
            tab: screen.tab,
            tool: screen.tool,
            liveShell: true,
          );
          expect(
            Get.find<MainShellController>().currentIndex.value,
            screen.tab,
          );
          expect(Get.find<MainShellController>().studioTool.value, screen.tool);
          expect(find.byType(RawImage), findsAtLeastNWidgets(1));
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('screen')),
          );
          await tester.runAsync(() async {
            final capture = await boundary.toImage(
              pixelRatio: preset.pixelRatio,
            );
            try {
              expect(capture.width, (preset.width * preset.pixelRatio).round());
              expect(
                capture.height,
                (preset.height * preset.pixelRatio).round(),
              );
              final bytes = await capture.toByteData(
                format: ui.ImageByteFormat.png,
              );
              expect(bytes, isNotNull);
              final directory = Directory(
                '../docs/store/premium-refresh/raw/${preset.name}',
              );
              await directory.create(recursive: true);
              await File('${directory.path}/${screen.name}.png').writeAsBytes(
                bytes!.buffer.asUint8List(
                  bytes.offsetInBytes,
                  bytes.lengthInBytes,
                ),
              );
            } finally {
              capture.dispose();
            }
          });
        });
      }
    }
    return;
  }

  testWidgets('lazy Closet images are decoded before visual capture', (
    tester,
  ) async {
    await pump(tester, const WardrobeContent(), tab: 1, liveShell: true);
    final images = tester.widgetList<RawImage>(find.byType(RawImage));
    expect(images, isNotEmpty);
    expect(
      images.every((image) => image.image != null),
      isTrue,
      reason:
          'A golden must contain decoded garment pixels, not empty image frames.',
    );
  });

  for (final dark in [false, true]) {
    for (final entry in [
      ('auth', const AuthEntryPage(), 0),
      ('home', const DashboardContent(), 0),
      ('closet', const WardrobeContent(), 1),
      ('outfits', const OutfitsContent(), 2),
      ('studio', const StudioContent(), 3),
      ('profile', const ProfileContent(), 4),
    ]) {
      testWidgets('${entry.$1} ${dark ? 'dark' : 'light'} visual', (
        tester,
      ) async {
        if (entry.$1 == 'profile') {
          Get.find<AuthController>().user.value = const UserModel(
            id: 'fixture',
            email: 'alex@example.com',
            fullName: 'Alex Morgan',
          );
        }
        await pump(
          tester,
          entry.$2,
          dark: dark,
          tab: entry.$3,
          shell: entry.$1 != 'auth',
          liveShell: entry.$1 != 'auth',
        );
        await expectLater(
          find.byKey(const ValueKey('screen')),
          matchesGoldenFile(
            'goldens/${entry.$1}_${dark ? 'dark' : 'light'}.png',
          ),
        );
      });
    }
  }
  for (final width in [320.0, 1024.0]) {
    testWidgets('Home at ${width.toInt()}px visual', (tester) async {
      await pump(
        tester,
        const DashboardContent(),
        width: width,
        liveShell: true,
      );
      await expectLater(
        find.byKey(const ValueKey('screen')),
        matchesGoldenFile('goldens/home_${width.toInt()}.png'),
      );
    });
  }
  testWidgets('narrow screens remain usable at 200 percent text', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      for (final body in [
        const AuthEntryPage(),
        const DashboardContent(),
        const WardrobeContent(),
        const OutfitsContent(),
        const StudioContent(),
        const ProfileContent(),
      ]) {
        await pump(
          tester,
          body,
          width: 320,
          scale: 2,
          dark: dark,
          shell: body is! AuthEntryPage,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    }
  });
  testWidgets('magazine pages adapt to tablet content widths', (tester) async {
    for (final body in [
      const DashboardContent(),
      const WardrobeContent(),
      const OutfitsContent(),
      const StudioContent(),
      const ProfileContent(),
    ]) {
      await pump(tester, body, width: 1024, scale: 2);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });
  testWidgets('closet photo tap opens the item rather than the viewer', (
    tester,
  ) async {
    await pump(tester, const WardrobeContent(), tab: 1);
    await tester.tap(find.byType(AppImage).first);
    await tester.pump();
    expect(Get.currentRoute, '/wardrobe/piece');
  });
  testWidgets('closet and outfit menus wrap at 200 percent text', (
    tester,
  ) async {
    for (final body in [const WardrobeContent(), const OutfitsContent()]) {
      await pump(tester, body, width: 320, scale: 2);
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      Get.back<void>();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
  testWidgets('empty lists and long list categories remain scrollable', (
    tester,
  ) async {
    Get.find<OutfitListController>().outfits.clear();
    await pump(tester, const OutfitsContent(), width: 320, scale: 2);
    expect(find.text('No outfits yet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    final closet = Get.find<WardrobeController>();
    closet.viewMode.value = 'list';
    closet.items.assignAll([
      closet.items.first.copyWith(
        category: Category.accessories,
        isFavorite: true,
      ),
    ]);
    await pump(tester, const WardrobeContent(), width: 320, scale: 2);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
