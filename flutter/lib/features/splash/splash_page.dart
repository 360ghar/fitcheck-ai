import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers/auth_provider.dart';

/// First screen: the wordmark over a paper landscape while the session is
/// restored. Everything is painted on the first frame; only the garments on
/// the line sway. The router leaves this page once the session is restored.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      precachePaperGrain(context);
    }
  }

  void _initializeApp() => ref.read(authProvider.notifier).initialize();

  @override
  Widget build(BuildContext context) {
    return PaperStockScope(
      stock: PaperStockId.ink,
      child: Builder(
        builder: (context) {
          final tokens = PaperTokens.of(context);
          final dark = Theme.of(context).brightness == Brightness.dark;
          final display = Theme.of(context).textTheme.displayMedium;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: Scaffold(
              backgroundColor: tokens.stock.page,
              body: PaperScene(
                preset: PaperScenes.auth,
                height: null,
                parallax: 0,
                child: SafeArea(
                  child: Align(
                    alignment: const Alignment(0, -0.3),
                    child: Semantics(
                      label: 'FitCheck AI',
                      header: true,
                      excludeSemantics: true,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'FitCheck'),
                              TextSpan(
                                text: ' ai',
                                style: TextStyle(color: tokens.stock.accent),
                              ),
                            ],
                          ),
                          style: display,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
