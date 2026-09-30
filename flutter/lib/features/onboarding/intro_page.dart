import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_ui.dart';
import '../auth/views/widgets/auth_ui.dart';
import 'intro_seen_provider.dart';
import 'paper_progress.dart';

class _Slide {
  const _Slide(this.stock, this.scene, this.title, this.body);

  final PaperStockId stock;
  final PaperScenePreset scene;
  final String title;
  final String body;
}

const _slides = [
  _Slide(
    PaperStockId.moss,
    PaperScenes.closet,
    'Snap your closet once.',
    'Photograph a pile of clothes. Every piece is cut out and filed for you.',
  ),
  _Slide(
    PaperStockId.marigold,
    PaperScenes.outfits,
    'Get dressed faster.',
    'Outfits from what you own, matched to your plans and the weather.',
  ),
  _Slide(
    PaperStockId.clay,
    PaperScenes.studio,
    'See it before you wear it.',
    'Try looks on your own photo, or shoot them like a campaign.',
  ),
];

/// Three intro sheets shown once, before the first sign-in. Each sheet is
/// cut from its own paper stock, so a swipe moves from sheet to sheet.
class IntroPage extends ConsumerStatefulWidget {
  const IntroPage({super.key});

  @override
  ConsumerState<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends ConsumerState<IntroPage> {
  final _pages = PageController();
  int _index = 0;

  bool get _last => _index == _slides.length - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(introSeenProvider.notifier).markSeen();
    if (mounted) context.go(Routes.onboarding);
  }

  void _next() {
    if (_last) {
      _finish();
      return;
    }
    _pages.nextPage(
      duration: MediaQuery.disableAnimationsOf(context)
          ? const Duration(milliseconds: 1)
          : const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: PaperStockScope(
        stock: _slides[_index].stock,
        child: Builder(
          builder: (context) {
            final tokens = PaperTokens.of(context);
            final gutter = MediaQuery.sizeOf(context).width < 360
                ? AppConstants.spacing16
                : AppConstants.spacing24;
            return Scaffold(
              backgroundColor: tokens.stock.page,
              body: Stack(
                children: [
                  PageView(
                    controller: _pages,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      for (final slide in _slides)
                        _IntroSheet(slide: slide, gutter: gutter),
                    ],
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing4),
                        child: AnimatedOpacity(
                          opacity: _last ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            ignoring: _last,
                            child: TextButton(
                              onPressed: _finish,
                              style: TextButton.styleFrom(
                                foregroundColor: tokens.textPrimary,
                              ),
                              child: const Text('Skip'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          gutter,
                          0,
                          gutter,
                          AppConstants.spacing16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PaperProgress(index: _index, count: _slides.length),
                            const SizedBox(height: AppConstants.spacing24),
                            AuthPrimaryButton(
                              label: _last ? 'Get started' : 'Next',
                              onPressed: _next,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One sheet: the stock's paper scene over the top, the line under it.
class _IntroSheet extends StatelessWidget {
  const _IntroSheet({required this.slide, required this.gutter});

  final _Slide slide;
  final double gutter;

  /// Room left under the copy for the progress strips and the button.
  static const _controlsHeight = 132.0;

  @override
  Widget build(BuildContext context) {
    return PaperStockScope(
      stock: slide.stock,
      child: Builder(
        builder: (context) {
          final tokens = PaperTokens.of(context);
          final text = Theme.of(context).textTheme;
          final top = MediaQuery.paddingOf(context).top;
          final grain = BoxDecoration(image: paperGrain(context));
          // The grain lies over the scene and its open sky as one layer,
          // and under the copy, so no band shows where the scene starts.
          return ColoredBox(
            color: tokens.stock.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: grain,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: top + kMinInteractiveDimension,
                      ),
                      // The presets are drawn for a header band; past ~320
                      // the sky between the pieces goes empty, so the extra
                      // height sits above the scene as open sky.
                      child: LayoutBuilder(
                        builder: (context, box) => Align(
                          alignment: Alignment.bottomCenter,
                          child: PaperScene(
                            preset: slide.scene,
                            height: box.maxHeight.clamp(0, 320).toDouble(),
                            parallax: 0,
                            background: Colors.transparent,
                            grain: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: grain,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      AppConstants.spacing24,
                      gutter,
                      _controlsHeight + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            slide.title,
                            maxLines: 2,
                            style: text.displaySmall?.copyWith(height: 1.1),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing12),
                        Text(
                          slide.body,
                          style: text.bodyLarge?.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
