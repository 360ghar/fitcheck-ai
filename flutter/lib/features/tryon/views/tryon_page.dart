import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/report_content_sheet.dart';
import '../providers/tryon_provider.dart';

String _sentence(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Virtual try-on: one garment photo on the user's own photo.
class TryOnPage extends ConsumerWidget {
  const TryOnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(tryOnProvider);
    final notifier = ref.read(tryOnProvider.notifier);

    return PaperStockScope(
      stock: PaperStockId.clay,
      child: Scaffold(
        appBar: AppBar(title: const Text('Virtual try-on')),
        body: AppPageBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing16,
              AppConstants.spacing24,
            ),
            children: const [
              _AvatarCard(),
              SizedBox(height: AppConstants.spacing16),
              _GarmentCard(),
              SizedBox(height: AppConstants.spacing16),
              _OptionsCard(),
              SizedBox(height: AppConstants.spacing16),
              _ResultCard(),
            ],
          ),
        ),
        bottomNavigationBar: _BottomBar(
          canGenerate: s.garment != null && !s.generating,
          generating: s.generating,
          hasResult: s.hasResult,
          onGenerate: notifier.generate,
          onSave: notifier.downloadResult,
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      color: PaperTokens.of(context).textPrimary,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _AvatarCard extends ConsumerWidget {
  const _AvatarCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = ref.watch(tryOnAvatarProvider);
    final notifier = ref.read(tryOnAvatarProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final value = avatar.value;

    Widget body;
    if (value == null && avatar.hasError) {
      body = Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: tokens.textSecondary),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Text(
              "We couldn't load your photo.",
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          ),
          TextButton(onPressed: notifier.refresh, child: const Text('Retry')),
        ],
      );
    } else if (value == null) {
      body = const SkeletonPulse(
        child: Row(
          children: [
            SkeletonBox(width: 72, height: 96),
            SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 160, height: 14),
                  SizedBox(height: AppConstants.spacing12),
                  SkeletonBox(width: 110, height: 14),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      final path = value.pendingPath;
      final url = value.url;
      final Widget? image = path != null
          ? Image.file(File(path), fit: BoxFit.cover)
          : url != null
          ? AppNetworkImage(
              url,
              fit: BoxFit.cover,
              cacheWidth: 216,
              errorWidget: (_, _, _) => const _AvatarPlaceholder(),
            )
          : null;
      body = Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: SizedBox(
              width: 72,
              height: 96,
              child: image ?? const _AvatarPlaceholder(),
            ),
          ),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.isUploading
                      ? 'Uploading your photo'
                      : url == null
                      ? 'Add a full-body photo of yourself'
                      : 'A full-body photo works best',
                  style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
                const SizedBox(height: AppConstants.spacing4),
                TextButton.icon(
                  onPressed: value.isUploading ? null : notifier.upload,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(
                      right: AppConstants.spacing8,
                    ),
                  ),
                  icon: value.isUploading
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_camera_outlined, size: 20),
                  label: Text(url == null ? 'Add photo' : 'Change photo'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Title('Your photo'),
          const SizedBox(height: AppConstants.spacing12),
          body,
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return ColoredBox(
      color: tokens.stock.sunk,
      child: Icon(
        Icons.person_outline_rounded,
        size: 36,
        color: tokens.textMuted,
      ),
    );
  }
}

class _GarmentCard extends ConsumerWidget {
  const _GarmentCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garment = ref.watch(tryOnProvider.select((s) => s.garment));
    final generating = ref.watch(tryOnProvider.select((s) => s.generating));
    final notifier = ref.read(tryOnProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;

    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Title('Garment'),
          const SizedBox(height: AppConstants.spacing12),
          if (garment == null)
            PaperSurface(
              onTap: notifier.pickGarment,
              semanticLabel: 'Choose a garment photo',
              lift: 0,
              color: tokens.stock.sunk,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing24,
                horizontal: AppConstants.spacing16,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.checkroom_rounded,
                    size: 32,
                    color: tokens.stock.accent,
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Text(
                    'Choose one garment photo',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'A flat lay or a hanger shot works best',
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius8),
              child: ColoredBox(
                color: tokens.stock.sunk,
                child: Image.file(
                  garment,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          const SizedBox(height: AppConstants.spacing8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: generating ? null : notifier.pickGarment,
                icon: const Icon(Icons.photo_library_outlined, size: 20),
                label: Text(garment == null ? 'Gallery' : 'Change'),
              ),
              TextButton.icon(
                onPressed: generating ? null : notifier.pickGarmentFromCamera,
                icon: const Icon(Icons.photo_camera_outlined, size: 20),
                label: const Text('Camera'),
              ),
              if (garment != null)
                TextButton(
                  onPressed: generating
                      ? null
                      : () => notifier.setGarment(null),
                  child: const Text('Remove'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionsCard extends ConsumerWidget {
  const _OptionsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(tryOnProvider);
    final notifier = ref.read(tryOnProvider.notifier);

    Widget dropdown(
      String label,
      String value,
      List<String> options,
      ValueChanged<String> onChanged,
    ) => DropdownButtonFormField<String>(
      // A new key rebuilds the field when the value changes elsewhere.
      key: ValueKey('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final o in options)
          DropdownMenuItem(value: o, child: Text(_sentence(o))),
      ],
      onChanged: s.generating
          ? null
          : (v) {
              if (v != null) onChanged(v);
            },
    );

    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Title('Look'),
          const SizedBox(height: AppConstants.spacing16),
          dropdown('Style', s.style, TryOnNotifier.styles, notifier.setStyle),
          const SizedBox(height: AppConstants.spacing12),
          dropdown(
            'Background',
            s.background,
            TryOnNotifier.backgrounds,
            notifier.setBackground,
          ),
          const SizedBox(height: AppConstants.spacing12),
          dropdown('Pose', s.pose, TryOnNotifier.poses, notifier.setPose),
        ],
      ),
    );
  }
}

class _ResultCard extends ConsumerWidget {
  const _ResultCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(tryOnProvider);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;

    if (s.generating) {
      return PaperSurface(
        child: Column(
          children: [
            const SkeletonPulse(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: SkeletonBox(borderRadius: AppConstants.radius8),
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Text(
              'Dressing you up. This takes about half a minute.',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
      );
    }

    if (!s.hasResult) {
      return PaperSurface(
        lift: 0,
        color: tokens.stock.sunk,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacing32,
          horizontal: AppConstants.spacing16,
        ),
        child: Column(
          children: [
            Icon(Icons.image_outlined, size: 32, color: tokens.textMuted),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Your try-on appears here',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
      );
    }

    final bytes = s.resultBytes;
    final Widget image = s.resultUrl != null
        ? AppNetworkImage(
            s.resultUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => bytes != null
                ? Image.memory(bytes, fit: BoxFit.cover)
                : const _BrokenResult(),
          )
        : Image.memory(
            bytes!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const _BrokenResult(),
          );

    return PaperSurface(
      padding: EdgeInsets.zero,
      grain: false,
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            // Apple Guideline 1.2: generated images must be reportable.
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: 'Report image',
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                onPressed: () => showReportContentSheet(
                  contentType: 'AI try-on image',
                  contentId: s.resultUrl ?? 'tryon-result',
                ),
                icon: const Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black87, offset: Offset(0.5, 1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrokenResult extends StatelessWidget {
  const _BrokenResult();

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return ColoredBox(
      color: tokens.stock.sunk,
      child: Icon(
        Icons.broken_image_outlined,
        size: 32,
        color: tokens.textMuted,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.canGenerate,
    required this.generating,
    required this.hasResult,
    required this.onGenerate,
    required this.onSave,
  });

  final bool canGenerate;
  final bool generating;
  final bool hasResult;
  final VoidCallback onGenerate;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return PaperActionBar(
      child: Row(
        children: [
          if (hasResult && !generating) ...[
            TextButton.icon(
              onPressed: onSave,
              style: TextButton.styleFrom(minimumSize: const Size(0, 52)),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text('Save'),
            ),
            const SizedBox(width: AppConstants.spacing8),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: canGenerate ? onGenerate : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                generating
                    ? 'Creating'
                    : hasResult
                    ? 'Try again'
                    : 'Create try-on',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
