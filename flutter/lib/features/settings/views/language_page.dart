import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/i18n/locale_registry.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';

/// The language picker.
///
/// Lists all 50 locales the app ships, in native script, with the English name
/// underneath so someone who landed in the wrong language can find their way
/// back. The first row restores "follow the device", which is the default and
/// what the App Store listing promises: the app opens in the language the phone
/// is already using.
class LanguagePage extends ConsumerStatefulWidget {
  const LanguagePage({super.key});

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  String _query = '';

  bool _matches(AppLocale entry) {
    if (_query.trim().isEmpty) return true;
    final query = _query.toLowerCase();
    return entry.nativeName.toLowerCase().contains(query)
        || entry.englishName.toLowerCase().contains(query)
        || entry.asc.toLowerCase().contains(query);
  }

  Future<void> _select(String? asc) async {
    try {
      await ref.read(localeControllerProvider.notifier).setLocale(asc);
      if (!mounted) return;
      // Through ErrorHandler, not a raw SnackBar: the snackbar-policy test
      // requires every toast to come from one place.
      ErrorHandler.showSuccess(context.l10n.languageChanged);
    } catch (_) {
      // setLocale only throws on a programming error (an unknown code), and
      // that must not leave the screen in a half-changed state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(localeControllerProvider);
    final current = LocaleRegistry.forLocale(Localizations.localeOf(context));
    final tokens = PaperTokens.of(context);
    final locales = LocaleRegistry.pickerOrder
        .where(LocaleRegistry.shipsCatalog)
        .where(_matches)
        .toList();

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.languageTitle)),
        body: AppPageBackground(
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing16,
              AppConstants.spacing32,
            ),
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: context.l10n.languageSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              PaperSurface(
                padding: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    children: [
                      _LanguageRow(
                        title: context.l10n.languageSystem,
                        subtitle: context.l10n.languageSystemBody,
                        selected: selection.followsDevice,
                        onTap: () => _select(null),
                      ),
                      const Divider(height: 1),
                      for (final entry in locales) ...[
                        _LanguageRow(
                          title: entry.nativeName,
                          subtitle:
                              '${entry.englishName} · ${entry.asc}'
                              '${entry.rtl ? ' · RTL' : ''}',
                          selected: !selection.followsDevice
                              && selection.asc == entry.asc,
                          onTap: () => _select(entry.asc),
                        ),
                        if (entry != locales.last) const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
              ),
              if (current != null && current.tier > 1) ...[
                const SizedBox(height: AppConstants.spacing16),
                Text(
                  context.l10n.languageReviewNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return ListTile(
      minVerticalPadding: AppConstants.spacing12,
      onTap: onTap,
      title: Text(
        title,
        textDirection: _textDirectionFor(title),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: tokens.textMuted),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: tokens.stock.accent)
          : null,
    );
  }

  /// Each row shows its language in that language's own direction, so Arabic
  /// reads right-to-left even while the surrounding UI is English. The
  /// alternative — forcing every row to the UI direction — makes the list look
  /// broken to exactly the users it is meant to help.
  TextDirection _textDirectionFor(String text) {
    final first = text.runes.isEmpty ? 0 : text.runes.first;
    // Hebrew, Arabic, Syriac, Thaana, NKo and the Arabic presentation forms.
    final isRtl = (first >= 0x0590 && first <= 0x08FF)
        || (first >= 0xFB1D && first <= 0xFDFF)
        || (first >= 0xFE70 && first <= 0xFEFF);
    return isRtl ? TextDirection.rtl : TextDirection.ltr;
  }
}
