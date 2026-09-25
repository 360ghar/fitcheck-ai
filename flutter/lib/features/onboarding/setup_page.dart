import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/error_handler.dart';
import '../../core/widgets/app_ui.dart';
import '../../domain/enums/style.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/views/widgets/auth_ui.dart';
import '../profile/repositories/profile_repository.dart';
import '../settings/providers/settings_provider.dart';
import 'paper_progress.dart';
import 'setup_gate.dart';

const _genders = [
  ('female', 'Women'),
  ('male', 'Men'),
  ('non_binary', 'Non-binary'),
  ('prefer_not_to_say', 'Prefer not to say'),
];

/// First-run setup for a new account: who we style, what they wear, then
/// the first closet upload. The shell pushes it once (see setup_gate.dart).
/// Every step can be skipped.
class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  int _step = 0;
  String? _gender;
  final _styles = <String>{};
  final _occasions = <String>{};
  bool _saving = false;

  Future<void> _finish({bool addClothes = false}) async {
    final id = ref.read(authProvider).user?.id;
    if (id != null) await markSetupDone(id);
    if (!mounted) return;
    if (addClothes) {
      context.pushReplacement(Routes.wardrobeAdd);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  Future<void> _save(Future<void> Function() call) async {
    setState(() => _saving = true);
    try {
      await call();
      if (mounted) setState(() => _step++);
    } catch (e, st) {
      ErrorHandler.showError(e, title: 'Could not save', stackTrace: st);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _continue() {
    switch (_step) {
      case 0:
        _save(() => ProfileRepository().updateProfile(gender: _gender));
      case 1:
        _save(
          () => ref
              .read(settingsRepositoryProvider)
              .updateStyleChoices(
                styles: _styles.toList(),
                occasions: _occasions.toList(),
              ),
        );
      default:
        _finish(addClothes: true);
    }
  }

  bool get _canContinue => switch (_step) {
    0 => _gender != null,
    1 => _styles.isNotEmpty || _occasions.isNotEmpty,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: PaperStockScope(
        stock: PaperStockId.ink,
        child: Builder(
          builder: (context) {
            final tokens = PaperTokens.of(context);
            final text = Theme.of(context).textTheme;
            final gutter = MediaQuery.sizeOf(context).width < 360
                ? AppConstants.spacing16
                : AppConstants.spacing24;
            final (title, body) = switch (_step) {
              0 => (
                'Who are we styling?',
                'Sets the model for try-on and photoshoots. You can change '
                    'it in your profile.',
              ),
              1 => (
                'What do you wear most?',
                'Pick any. Outfit ideas start from these.',
              ),
              _ => (
                'Add your first pieces.',
                'Photograph a few clothes, or a pile of them. Each piece is '
                    'cut out and filed for you.',
              ),
            };
            return Scaffold(
              backgroundColor: tokens.stock.page,
              body: DecoratedBox(
                decoration: BoxDecoration(image: paperGrain(context)),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          gutter,
                          AppConstants.spacing8,
                          AppConstants.spacing8,
                          0,
                        ),
                        child: Row(
                          children: [
                            const Expanded(child: BrandWordmark(size: 22)),
                            TextButton(
                              onPressed: _saving ? null : () => _finish(),
                              style: TextButton.styleFrom(
                                foregroundColor: tokens.textPrimary,
                              ),
                              child: const Text('Skip setup'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(
                            gutter,
                            AppConstants.spacing24,
                            gutter,
                            AppConstants.spacing24,
                          ),
                          children: [
                            PaperProgress(index: _step, count: 3),
                            const SizedBox(height: AppConstants.spacing24),
                            Semantics(
                              header: true,
                              child: Text(
                                title,
                                style: text.displaySmall?.copyWith(
                                  fontSize: 30,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacing12),
                            Text(
                              body,
                              style: text.bodyLarge?.copyWith(
                                color: tokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacing24),
                            ..._stepBody(context),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          gutter,
                          0,
                          gutter,
                          AppConstants.spacing8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthPrimaryButton(
                              label: _step == 2 ? 'Add clothes' : 'Continue',
                              isLoading: _saving,
                              onPressed: _canContinue ? _continue : null,
                            ),
                            TextButton(
                              onPressed: _saving
                                  ? null
                                  : () => _step == 2
                                        ? _finish()
                                        : setState(() => _step++),
                              style: TextButton.styleFrom(
                                foregroundColor: tokens.textPrimary,
                              ),
                              child: Text(_step == 2 ? 'Later' : 'Skip'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _stepBody(BuildContext context) {
    final label = Theme.of(context).textTheme.titleSmall;
    Widget chips(Iterable<Widget> children) => Wrap(
      spacing: AppConstants.spacing8,
      runSpacing: AppConstants.spacing8,
      children: children.toList(),
    );
    Widget multi(Set<String> selected, List<String> options) => chips(
      options.map(
        (o) => FilterChip(
          label: Text(o),
          selected: selected.contains(o),
          showCheckmark: false,
          onSelected: (on) =>
              setState(() => on ? selected.add(o) : selected.remove(o)),
        ),
      ),
    );
    return switch (_step) {
      0 => [
        chips(
          _genders.map(
            (g) => ChoiceChip(
              label: Text(g.$2),
              selected: _gender == g.$1,
              showCheckmark: false,
              onSelected: (_) => setState(() => _gender = g.$1),
            ),
          ),
        ),
      ],
      1 => [
        Text('Styles', style: label),
        const SizedBox(height: AppConstants.spacing8),
        multi(_styles, onboardingStyleNames),
        const SizedBox(height: AppConstants.spacing24),
        Text('Occasions', style: label),
        const SizedBox(height: AppConstants.spacing8),
        multi(_occasions, onboardingOccasionNames),
      ],
      _ => [
        // Scene grain must cover the solid garment shapes as well.
        const PaperScene(
          preset: PaperScenes.closet,
          parallax: 0,
        ),
      ],
    };
  }
}
