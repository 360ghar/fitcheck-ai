import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/photoshoot_provider.dart';
import '../photoshoot_l10n.dart';
import 'photoshoot_configure_step.dart';
import 'photoshoot_generating_step.dart';
import 'photoshoot_results_step.dart';
import 'photoshoot_upload_step.dart';
import 'referral_limit_dialog.dart';

/// Photoshoot tab. The shell supplies the Scaffold and the clay stock.
class PhotoshootContent extends ConsumerWidget {
  const PhotoshootContent({super.key});

  static String _subtitle(AppLocalizations l10n, PhotoshootState s) =>
      switch (s.step) {
        PhotoshootStep.upload => l10n.photoshootSubtitleUpload,
        PhotoshootStep.configure => l10n.photoshootSubtitleConfigure,
        PhotoshootStep.generating => l10n.photoshootSubtitleGenerating,
        PhotoshootStep.results =>
          s.failedCount > 0
              ? '${s.images.length} ready, ${s.failedCount} failed'
              : '${s.images.length} photos ready',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(photoshootProvider.select((s) => s.step));
    final subtitle = ref.watch(
      photoshootProvider.select((s) => _subtitle(context.l10n, s)),
    );
    final error = ref.watch(photoshootProvider.select((s) => s.error));
    final failed = ref.watch(photoshootProvider.select((s) => s.failedCount));
    final banner = switch (step) {
      PhotoshootStep.configure when error != null => AppErrorBanner(
        error: error,
        onRetry: () => startPhotoshoot(context, ref),
      ),
      PhotoshootStep.results when failed > 0 => AppErrorBanner(
        message: failed == 1
            ? context.l10n.photoshootOneFailed
            : context.l10n.photoshootManyFailed(failed),
      ),
      _ => null,
    };

    return AppPageBackground(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppTabHeader(
              title: context.l10n.tabPhotoshoot,
              subtitle: subtitle,
              scene: PaperScenes.studio,
              sceneHeight: 112,
            ),
          ),
          SliverToBoxAdapter(child: _StepTrack(step: step)),
          if (banner != null)
            SliverPadding(
              padding: const EdgeInsets.only(top: AppConstants.spacing8),
              sliver: SliverToBoxAdapter(child: banner),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              banner == null ? AppConstants.spacing16 : AppConstants.spacing4,
              AppConstants.spacing16,
              AppConstants.spacing32,
            ),
            sliver: SliverToBoxAdapter(
              child: switch (step) {
                PhotoshootStep.upload => const PhotoshootUploadStep(),
                PhotoshootStep.configure => const PhotoshootConfigureStep(),
                PhotoshootStep.generating => const PhotoshootGeneratingStep(),
                PhotoshootStep.results => const PhotoshootResultsStep(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// "Step 2 of 4" and a thin rounded track.
class _StepTrack extends StatelessWidget {
  const _StepTrack({required this.step});

  final PhotoshootStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final index = step.index;
    final names = photoshootStepNames(context.l10n);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppConstants.spacing20,
        AppConstants.spacing12,
        AppConstants.spacing20,
        0,
      ),
      child: Semantics(
        label: context.l10n.photoshootStepOf(
          index + 1,
          names.length,
          names[index],
        ),
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  names[index],
                  style: text.titleSmall?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n.photoshootStepOfFour(index + 1),
                  style: text.bodySmall?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (index + 1) / 4,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
