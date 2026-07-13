import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/report_content_sheet.dart';
import '../../outfits/models/outfit_model.dart';
import '../../outfits/repositories/outfit_repository.dart';

/// Local store of share IDs the user chose to hide (Guideline 1.2 — ability
/// to hide objectionable UGC on-device without a full social block graph).
class HiddenSharedContentStore {
  HiddenSharedContentStore._();

  static const _prefsKey = 'hidden_shared_outfit_ids';

  static Future<bool> isHidden(String shareId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? const [];
    return list.contains(shareId);
  }

  static Future<void> hide(String shareId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(prefs.getStringList(_prefsKey) ?? const []);
    if (!list.contains(shareId)) {
      list.add(shareId);
      await prefs.setStringList(_prefsKey, list);
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
    if (await HiddenSharedContentStore.isHidden(widget.shareId)) {
      return const _SharedLoadResult.hidden();
    }
    try {
      final outfit = await OutfitRepository().getSharedOutfit(widget.shareId);
      return _SharedLoadResult.ok(outfit);
    } catch (_) {
      return const _SharedLoadResult.missing();
    }
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
    Get.snackbar(
      'Content hidden',
      'This outfit will no longer be shown on this device.',
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tokens.brandColor.withOpacity(0.1), tokens.cardColor],
          ),
        ),
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
                        expandedHeight: 400,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: images.isNotEmpty
                              ? AppImage(
                                  imageUrl: images.first,
                                  fit: BoxFit.contain,
                                  enableZoom: true,
                                  galleryUrls: images,
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
                                          Get.offAllNamed('/login'),
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
                    color: tokens.cardColor.withOpacity(0.9),
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
                        color: tokens.cardColor.withOpacity(0.9),
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
                        color: tokens.cardColor.withOpacity(0.9),
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
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: tokens.textMuted),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: tokens.textPrimary),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum _SharedStatus { ok, missing, hidden }

class _SharedLoadResult {
  final _SharedStatus status;
  final SharedOutfitModel? outfit;

  const _SharedLoadResult._(this.status, this.outfit);

  const _SharedLoadResult.ok(SharedOutfitModel outfit)
      : this._(_SharedStatus.ok, outfit);

  const _SharedLoadResult.missing() : this._(_SharedStatus.missing, null);

  const _SharedLoadResult.hidden() : this._(_SharedStatus.hidden, null);
}
