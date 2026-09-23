import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/photoshoot_models.dart';
import '../providers/photoshoot_provider.dart';
import 'referral_limit_dialog.dart';

/// Step 2: style, format and image count.
class PhotoshootConfigureStep extends ConsumerStatefulWidget {
  const PhotoshootConfigureStep({super.key});

  @override
  ConsumerState<PhotoshootConfigureStep> createState() =>
      _PhotoshootConfigureStepState();
}

class _PhotoshootConfigureStepState
    extends ConsumerState<PhotoshootConfigureStep> {
  late final TextEditingController _prompt = TextEditingController(
    text: ref.read(photoshootProvider).customPrompt,
  );

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(photoshootProvider);
    final notifier = ref.read(photoshootProvider.notifier);
    final text = Theme.of(context).textTheme;
    final tokens = PaperTokens.of(context);
    // A reset clears the prompt in the state; mirror it in the field.
    if (s.customPrompt.isEmpty && _prompt.text.isNotEmpty) _prompt.clear();

    Widget title(String label) => Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: Text(
        label,
        style: text.titleMedium?.copyWith(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title('Style'),
        _StyleGrid(selected: s.useCase, onSelect: notifier.setUseCase),
        if (s.useCase == PhotoshootUseCase.custom) ...[
          const SizedBox(height: AppConstants.spacing16),
          TextField(
            controller: _prompt,
            onChanged: notifier.setCustomPrompt,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Your prompt',
              hintText: 'Golden hour on a rooftop, linen shirt',
            ),
          ),
        ],
        const SizedBox(height: AppConstants.spacing24),
        title('Format'),
        _FormatRow(selected: s.aspectRatio, onSelect: notifier.setAspectRatio),
        const SizedBox(height: AppConstants.spacing24),
        title('How many'),
        _CountCard(state: s, onChanged: notifier.setNumImages),
        const SizedBox(height: AppConstants.spacing12),
        _UsageLine(state: s, onRetry: notifier.fetchUsage),
        const SizedBox(height: AppConstants.spacing24),
        Row(
          children: [
            TextButton(
              onPressed: notifier.backToUpload,
              style: TextButton.styleFrom(minimumSize: const Size(88, 52)),
              child: const Text('Back'),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: ElevatedButton(
                onPressed: s.photos.isEmpty
                    ? null
                    : () => startPhotoshoot(context, ref),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  'Create ${s.numImages} '
                  '${s.numImages == 1 ? 'photo' : 'photos'}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StyleGrid extends StatelessWidget {
  const _StyleGrid({required this.selected, required this.onSelect});

  final PhotoshootUseCase selected;
  final ValueChanged<PhotoshootUseCase> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstants.spacing12,
        crossAxisSpacing: AppConstants.spacing12,
        mainAxisExtent: 84,
      ),
      itemCount: PhotoshootUseCase.values.length,
      itemBuilder: (context, i) {
        final useCase = PhotoshootUseCase.values[i];
        final on = useCase == selected;
        return PaperSurface(
          onTap: () => onSelect(useCase),
          semanticLabel: '${useCase.label}${on ? ', selected' : ''}',
          color: on ? tokens.stock.tint : null,
          lift: on ? 0.4 : 1,
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacing12,
            AppConstants.spacing12,
            AppConstants.spacing8,
            AppConstants.spacing12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      useCase.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        color: on ? tokens.stock.accent : tokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      useCase.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
                child: on
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: tokens.stock.accent,
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FormatRow extends StatelessWidget {
  const _FormatRow({required this.selected, required this.onSelect});

  final PhotoshootAspectRatio selected;
  final ValueChanged<PhotoshootAspectRatio> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    const box = 28.0;
    return Row(
      children: [
        for (final (i, ratio) in PhotoshootAspectRatio.values.indexed) ...[
          if (i > 0) const SizedBox(width: AppConstants.spacing8),
          Expanded(
            child: Builder(
              builder: (context) {
                final on = ratio == selected;
                final value = ratio.aspectRatioValue;
                return PaperSurface(
                  onTap: () => onSelect(ratio),
                  semanticLabel:
                      '${ratio.label}, ${ratio.ratio}${on ? ', selected' : ''}',
                  color: on ? tokens.stock.tint : null,
                  lift: on ? 0.4 : 1,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacing12,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: box,
                        child: Center(
                          child: Container(
                            width: value >= 1 ? box : box * value,
                            height: value >= 1 ? box / value : box,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: on
                                    ? tokens.stock.accent
                                    : tokens.textMuted,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        ratio.ratio,
                        style: text.labelMedium?.copyWith(
                          color: on ? tokens.stock.accent : tokens.textPrimary,
                          fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.state, required this.onChanged});

  final PhotoshootState state;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    const min = PhotoshootNotifier.minImages;
    final max = state.effectiveMaxImages;
    return PaperSurface(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing12,
        AppConstants.spacing16,
        AppConstants.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${state.numImages}',
                style: text.displaySmall?.copyWith(color: tokens.textPrimary),
              ),
              const SizedBox(width: AppConstants.spacing8),
              Expanded(
                child: Text(
                  state.numImages == 1 ? 'photo' : 'photos',
                  style: text.bodyLarge?.copyWith(color: tokens.textSecondary),
                ),
              ),
            ],
          ),
          Slider(
            value: state.numImages.clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: (max > min ? max : min + 1).toDouble(),
            divisions: max > min ? max - min : null,
            label: '${state.numImages}',
            onChanged: max > min ? (v) => onChanged(v.round()) : null,
          ),
        ],
      ),
    );
  }
}

class _UsageLine extends StatelessWidget {
  const _UsageLine({required this.state, required this.onRetry});

  final PhotoshootState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary);
    final usage = state.usage;
    if (usage == null && state.usageLoading) {
      return const SkeletonPulse(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SkeletonBox(width: 220, height: 14),
        ),
      );
    }
    if (usage == null) {
      return Row(
        children: [
          Expanded(
            child: Text("We couldn't check today's limit.", style: style),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    }
    final isPro = RegExp(
      r'^pro',
      caseSensitive: false,
    ).hasMatch(usage.planType);
    return Row(
      children: [
        Expanded(
          child: Text(
            '${isPro ? 'Pro' : 'Free'} plan: ${usage.remaining} of '
            '${usage.limitToday} left today',
            style: style,
          ),
        ),
        // Hidden while the paywall is off (App Store 3.1.1).
        if (!isPro && EnvConfig.paywallEnabled)
          TextButton(
            onPressed: () => context.push(Routes.subscription),
            child: const Text('Upgrade'),
          ),
      ],
    );
  }
}
