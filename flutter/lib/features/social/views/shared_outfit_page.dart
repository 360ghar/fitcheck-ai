import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/report_content_sheet.dart';
import '../../outfits/models/outfit_model.dart';
import '../../outfits/repositories/outfit_repository.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/utils/error_handler.dart';

/// Local store of share IDs the user chose to hide (Guideline 1.2 — ability
/// to hide objectionable UGC on-device without a full social block graph).
class HiddenSharedContentStore {
  HiddenSharedContentStore._();

  static const _prefsKey = 'hidden_shared_outfit_ids';

  static PersistenceService get _persistence => PersistenceService.instance;

  static Future<bool> isHidden(String shareId) async {
    final list = (await _persistence.getStringList(_prefsKey)) ?? const [];
    return list.contains(shareId);
  }

  static Future<void> hide(String shareId) async {
    final list = List<String>.from(
      (await _persistence.getStringList(_prefsKey)) ?? const [],
    );
    if (!list.contains(shareId)) {
      list.add(shareId);
      await _persistence.setStringList(_prefsKey, list);
    }
  }
}

/// Public view of a shared outfit, with hide and report (Guideline 1.2).
class SharedOutfitPage extends StatefulWidget {
  final String shareId;

  const SharedOutfitPage({super.key, required this.shareId});

  @override
  State<SharedOutfitPage> createState() => _SharedOutfitPageState();
}

class _SharedOutfitPageState extends State<SharedOutfitPage> {
  late Future<_SharedLoadResult> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<_SharedLoadResult> _load() async {
    if (await HiddenSharedContentStore.isHidden(widget.shareId)) {
      return const _SharedLoadResult.hidden();
    }
    try {
      final outfit = await OutfitRepository().getSharedOutfit(widget.shareId);
      return _SharedLoadResult.ok(outfit);
    } on NotFoundException {
      // A real 404: the outfit was removed or the link is wrong.
      return const _SharedLoadResult.missing();
    } catch (e) {
      // Timeout, no connection or 5xx: transient, so offer a retry.
      return _SharedLoadResult.error(e);
    }
  }

  void _retry() => setState(() => _loadFuture = _load());

  Future<void> _hideContent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hide this outfit?'),
        content: const Text(
          'It stays hidden on this device. You can also report it so our '
          'team can review and remove it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hide'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await HiddenSharedContentStore.hide(widget.shareId);
    if (!mounted) return;
    setState(() {
      _loadFuture = Future.value(const _SharedLoadResult.hidden());
    });
    ErrorHandler.showInfo(
      'This outfit will not show on this device again.',
      title: 'Outfit hidden',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaperStockScope(
      stock: PaperStockId.marigold,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shared outfit'),
          actions: [
            IconButton(
              icon: const Icon(Icons.visibility_off_outlined),
              tooltip: 'Hide this outfit',
              onPressed: _hideContent,
            ),
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Report this outfit',
              onPressed: () => showReportContentSheet(
                contentType: 'shared outfit',
                contentId: widget.shareId,
              ),
            ),
            const SizedBox(width: AppConstants.spacing4),
          ],
        ),
        body: AppPageBackground(
          child: FutureBuilder<_SharedLoadResult>(
            future: _loadFuture,
            builder: (context, snapshot) {
              final result = snapshot.data;
              if (snapshot.connectionState != ConnectionState.done ||
                  result == null) {
                return const SkeletonDetailPage();
              }
              return switch (result.status) {
                _SharedStatus.missing => const AppEmptyState(
                  scene: PaperScenes.oops,
                  title: "This outfit isn't here anymore",
                  message: 'It may have been removed, or the link is wrong.',
                ),
                _SharedStatus.error => AppErrorState(
                  error: result.error,
                  onRetry: _retry,
                ),
                _SharedStatus.hidden => const AppEmptyState(
                  scene: PaperScenes.outfits,
                  title: 'You hid this outfit',
                  message:
                      'If it was objectionable, report it from Privacy and '
                      'terms or email ${AppConstants.supportEmail}.',
                ),
                _SharedStatus.ok => _SharedOutfitView(
                  outfit: result.outfit!,
                  shareId: widget.shareId,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _SharedOutfitView extends StatelessWidget {
  const _SharedOutfitView({required this.outfit, required this.shareId});

  final SharedOutfitModel outfit;
  final String shareId;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final description = outfit.description;
    final images = <String>[
      ...?outfit.outfitImages?.where((u) => u.isNotEmpty),
      ...outfit.itemImages.where((u) => u.isNotEmpty),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        AppConstants.spacing32 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        PaperSurface(
          padding: EdgeInsets.zero,
          grain: images.isEmpty,
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: images.isEmpty
                ? Center(
                    child: Icon(
                      Icons.checkroom_outlined,
                      size: 64,
                      color: tokens.textMuted,
                    ),
                  )
                : AppImage(
                    imageUrl: images.first,
                    fit: BoxFit.contain,
                    enableZoom: true,
                    galleryUrls: images,
                    // Share URLs are short-lived presigned links; a page left
                    // open re-mints instead of showing a broken image.
                    storagePath: outfit.outfitStoragePath,
                    remintUrl: (storagePath) async {
                      try {
                        final fresh = await OutfitRepository().getSharedOutfit(
                          shareId,
                        );
                        return fresh.outfitImages?.firstOrNull;
                      } catch (_) {
                        return null;
                      }
                    },
                  ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing20),
        Text(outfit.name, style: text.displaySmall?.copyWith(fontSize: 32)),
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacing8),
          Text(
            description,
            style: text.bodyLarge?.copyWith(color: tokens.textSecondary),
          ),
        ],
        const SizedBox(height: AppConstants.spacing24),
        PaperSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Like this look?', style: text.headlineSmall),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                'Build outfits like it from your own closet.',
                style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppConstants.spacing16),
              ElevatedButton(
                onPressed: () => context.go(Routes.login),
                child: const Text('Get FitCheck AI'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _SharedStatus { ok, missing, hidden, error }

class _SharedLoadResult {
  final _SharedStatus status;
  final SharedOutfitModel? outfit;
  final Object? error;

  const _SharedLoadResult._(this.status, {this.outfit, this.error});

  const _SharedLoadResult.ok(SharedOutfitModel outfit)
    : this._(_SharedStatus.ok, outfit: outfit);

  const _SharedLoadResult.missing() : this._(_SharedStatus.missing);

  const _SharedLoadResult.hidden() : this._(_SharedStatus.hidden);

  const _SharedLoadResult.error(Object error)
    : this._(_SharedStatus.error, error: error);
}
