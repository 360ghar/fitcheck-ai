import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Page for viewing shared outfits (public access)
class SharedOutfitPage extends StatelessWidget {
  final String shareId;

  const SharedOutfitPage({
    super.key,
    required this.shareId,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tokens.brandColor.withOpacity(0.1),
              tokens.cardColor,
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder(
            future: _fetchSharedOutfit(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: tokens.textMuted,
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        'Outfit not found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: tokens.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        'This outfit may have been removed or the link is invalid',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textMuted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final outfit = snapshot.data as Map<String, dynamic>;
              final name = outfit['name']?.toString() ?? 'Shared Outfit';
              final description = outfit['description']?.toString();
              final images = outfit['outfit_images'] as List? ?? [];

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 400,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: images.first.toString(),
                              fit: BoxFit.cover,
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
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (description != null) ...[
                            const SizedBox(height: AppConstants.spacing8),
                            Text(
                              description!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: tokens.textMuted,
                                  ),
                            ),
                          ],
                          const SizedBox(height: AppConstants.spacing24),
                          AppGlassCard(
                            padding: const EdgeInsets.all(AppConstants.spacing16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Like this look?',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: AppConstants.spacing12),
                                ElevatedButton.icon(
                                  onPressed: () => Get.offAllNamed('/login'),
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
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchSharedOutfit() async {
    try {
      // Would fetch from API
      // For now, return mock data
      return {
        'name': 'Summer Casual Outfit',
        'description': 'A perfect summer look for casual outings',
        'outfit_images': [''],
      };
    } catch (e) {
      return null;
    }
  }
}
