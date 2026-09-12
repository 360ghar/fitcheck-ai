import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  static PersistenceService get _persistence =>
      Get.isRegistered<PersistenceService>()
      ? Get.find<PersistenceService>()
      : PersistenceService();

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

/// Page for viewing shared outfits (public access)
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
    try {
      if (await HiddenSharedContentStore.isHidden(widget.shareId)) {
        return const _SharedLoadResult.hidden();
      }
      final outfit = await OutfitRepository().getSharedOutfit(widget.shareId);
      return _SharedLoadResult.ok(outfit);
    } on NotFoundException {
      // Genuine 404: outfit removed or link invalid. The repository maps
      // Dio 404s to NotFoundException via handleDioException.
      return const _SharedLoadResult.missing();
    } catch (_) {
      // Timeout / no connection / 5xx: transient failure, not a missing
      // outfit. Surface an error card with Retry instead of a permanent
      // "Outfit not found".
      return const _SharedLoadResult.error();
    }
  }

  Future<void> _retry() {
    setState(() {
      _loadFuture = _load();
    });
    return _loadFuture;
  }

  Future<void> _hideContent() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hide this content?'),
        content: const Text(
          'This shared outfit will be hidden on this device. '
          'You can also report it so our team can review and remove it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
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
      'This outfit will no longer be shown on this device.',
      title: 'Content hidden',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: Stack(
            children: [
              FutureBuilder<_SharedLoadResult>(
                future: _loadFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final result = snapshot.data;
                  if (result == null ||
                      result.status == _SharedStatus.missing) {
                    return _messageState(
                      context,
                      tokens,
                      icon: Icons.error_outline,
                      title: 'Outfit not found',
                      body:
                          'This outfit may have been removed or the link is invalid',
                    );
                  }

                  if (result.status == _SharedStatus.error) {
                    return _messageState(
                      context,
                      tokens,
                      icon: Icons.cloud_off_outlined,
                      title: 'Something went wrong',
                      body:
                          'We couldn\'t reach the server. Check your '
                          'connection and try again.',
                      action: ElevatedButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    );
                  }

                  if (result.status == _SharedStatus.hidden) {
                    return _messageState(
                      context,
                      tokens,
                      icon: Icons.visibility_off_outlined,
                      title: 'Content hidden',
                      body:
                          'You hid this shared outfit on this device. '
                          'If it was objectionable, report it via Legal → '
                          'Report a Problem or email ${AppConstants.supportEmail}.',
                    );
                  }

                  final outfit = result.outfit!;
                  final name = outfit.name;
                  final description = outfit.description;
                  final images = <String>[
                    ...?outfit.outfitImages?.where((u) => u.isNotEmpty),
                    ...outfit.itemImages.where((u) => u.isNotEmpty),
                  ];

                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        expandedHeight: 400,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: images.isNotEmpty
                              ? AppImage(
                                  imageUrl: images.first,
                                  semanticLabel: 'Shared outfit: $name',
                                  fit: BoxFit.contain,
                                  enableZoom: true,
                                  galleryUrls: images,
                                  // A10b-10: share URLs are short-lived
                                  // presigned links minted per load; a
                                  // long-open page must re-mint instead of
                                  // showing a permanent error tile.
                                  storagePath: outfit.outfitStoragePath,
                                  remintUrl: (storagePath) async {
                                    try {
                                      final fresh = await OutfitRepository()
                                          .getSharedOutfit(widget.shareId);
                                      return fresh.outfitImages?.firstOrNull;
                                    } catch (_) {
                                      return null;
                                    }
                                  },
                                )
                              : Container(
                                  color: tokens.cardColor,
                                  child: Icon(
                                    Icons.checkroom,
                                    size: 64,
                                    color: tokens.textMuted,
                                  ),
                                ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.spacing24),
                          decoration: BoxDecoration(
                            color: tokens.cardColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppConstants.radius24),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (description != null &&
                                  description.isNotEmpty) ...[
                                const SizedBox(height: AppConstants.spacing8),
                                Text(
                                  description,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: tokens.textMuted),
                                ),
                              ],
                              const SizedBox(height: AppConstants.spacing24),
                              AppGlassCard(
                                padding: const EdgeInsets.all(
                                  AppConstants.spacing16,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Like this look?',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(
                                      height: AppConstants.spacing12,
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          Get.offAllNamed(Routes.login),
                                      icon: const Icon(Icons.checkroom),
                                      label: const Text('Get FitCheck AI'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacing48),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Back button
              Positioned(
                top: AppConstants.spacing8,
                left: AppConstants.spacing8,
                child: Container(
                  decoration: BoxDecoration(
                    color: tokens.cardColor.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              // Report + hide (Apple Guideline 1.2)
              Positioned(
                top: AppConstants.spacing8,
                right: AppConstants.spacing8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: tokens.cardColor.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.visibility_off_outlined),
                        tooltip: 'Hide this content',
                        onPressed: _hideContent,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Container(
                      decoration: BoxDecoration(
                        color: tokens.cardColor.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.flag_outlined),
                        tooltip: 'Report this outfit',
                        onPressed: () => showReportContentSheet(
                          contentType: 'shared outfit',
                          contentId: widget.shareId,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageState(
    BuildContext context,
    AppUiTokens tokens, {
    required IconData icon,
    required String title,
    required String body,
    Widget? action,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: tokens.textMuted),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: tokens.textPrimary),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              body,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppConstants.spacing24),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

enum _SharedStatus { ok, missing, hidden, error }

class _SharedLoadResult {
  final _SharedStatus status;
  final SharedOutfitModel? outfit;

  const _SharedLoadResult._(this.status, this.outfit);

  const _SharedLoadResult.ok(SharedOutfitModel outfit)
    : this._(_SharedStatus.ok, outfit);

  const _SharedLoadResult.missing() : this._(_SharedStatus.missing, null);

  const _SharedLoadResult.hidden() : this._(_SharedStatus.hidden, null);

  const _SharedLoadResult.error() : this._(_SharedStatus.error, null);
}
