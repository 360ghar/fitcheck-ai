import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/item_add_provider.dart';
import '../widgets/ai_extraction_widget.dart';
import '../widgets/manual_entry_form.dart';

enum _AddView { start, manual, processing, results, failure }

_AddView _viewOf(ItemAddState s) {
  if (s.manualEntry) return _AddView.manual;
  if (s.image == null) return _AddView.start;
  if (s.processing || s.generating) return _AddView.processing;
  if (s.items.isNotEmpty) return _AddView.results;
  if (s.failure != null) return _AddView.failure;
  return _AddView.start;
}

/// Adds one piece from a photo (scanned by AI) or by hand. Each page owns
/// its own session state.
class ItemAddPage extends ConsumerStatefulWidget {
  const ItemAddPage({super.key});

  @override
  ConsumerState<ItemAddPage> createState() => _ItemAddPageState();
}

class _ItemAddPageState extends ConsumerState<ItemAddPage> {
  final int _session = newItemAddSession();
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    ref.read(itemAddProvider(_session).notifier).processImage(File(image.path));
  }

  @override
  Widget build(BuildContext context) {
    final provider = itemAddProvider(_session);
    final view = ref.watch(provider.select(_viewOf));
    final notifier = ref.read(provider.notifier);

    final body = switch (view) {
      _AddView.start => _StartOptions(
        onCamera: () => _pick(ImageSource.camera),
        onGallery: () => _pick(ImageSource.gallery),
        onManual: notifier.openManualEntry,
      ),
      _AddView.manual => ManualEntryForm(image: ref.read(provider).image),
      _AddView.processing => ExtractionProcessingView(session: _session),
      _AddView.results => ExtractionResultsView(session: _session),
      _AddView.failure => ExtractionFailureView(session: _session),
    };

    return PaperStockScope(
      stock: PaperStockId.moss,
      child: PopScope(
        // Back from the details form returns to the previous step.
        canPop: view != _AddView.manual,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) notifier.closeManualEntry();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(switch (view) {
              _AddView.manual => 'Add details',
              _AddView.processing => 'Scanning',
              _AddView.results => 'Review pieces',
              _ => 'Add a piece',
            }),
          ),
          body: AppPageBackground(child: SafeArea(top: false, child: body)),
        ),
      ),
    );
  }
}

class _StartOptions extends StatelessWidget {
  const _StartOptions({
    required this.onCamera,
    required this.onGallery,
    required this.onManual,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing32,
      ),
      children: [
        PaperSurface(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Snap a piece', style: text.headlineMedium),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'We find every piece in the photo and make a clean studio shot of each.',
                style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppConstants.spacing20),
              ElevatedButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.photo_camera_outlined, size: 20),
                label: const Text('Take a photo'),
              ),
              const SizedBox(height: AppConstants.spacing4),
              TextButton.icon(
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 20),
                label: const Text('Choose from gallery'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing24),
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.spacing4),
          child: Text('Other ways to add', style: text.titleSmall),
        ),
        const SizedBox(height: AppConstants.spacing8),
        _OptionRow(
          icon: Icons.collections_outlined,
          title: 'Add several photos',
          subtitle: 'Up to 50 at once',
          onTap: () => context.push(Routes.wardrobeBatchAdd),
        ),
        _OptionRow(
          icon: Icons.link_rounded,
          title: 'Import from a profile',
          subtitle: 'Instagram or Facebook',
          onTap: () => context.push(Routes.wardrobeBatchAddSocial),
        ),
        _OptionRow(
          icon: Icons.edit_note_rounded,
          title: 'Enter details yourself',
          subtitle: 'No photo needed',
          onTap: onManual,
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
      child: PaperSurface(
        onTap: onTap,
        lift: 0.6,
        semanticLabel: title,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing12,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: tokens.stock.accent),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleSmall),
                  Text(
                    subtitle,
                    style: text.bodySmall?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: tokens.textMuted),
          ],
        ),
      ),
    );
  }
}
