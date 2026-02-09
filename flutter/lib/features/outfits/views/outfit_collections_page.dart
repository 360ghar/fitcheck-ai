import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/outfit_list_controller.dart';
import '../repositories/outfit_repository.dart';

/// Outfit collections page
/// Allows users to organize their outfits into collections
class OutfitCollectionsPage extends StatefulWidget {
  const OutfitCollectionsPage({super.key});

  @override
  State<OutfitCollectionsPage> createState() => _OutfitCollectionsPageState();
}

class _OutfitCollectionsPageState extends State<OutfitCollectionsPage> {
  final OutfitRepository _outfitRepository = OutfitRepository();
  final OutfitListController outfitListController = Get.find<OutfitListController>();

  final RxList<Map<String, dynamic>> collections = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxBool isCreating = false.obs;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await _outfitRepository.getCollections();
      collections.value = result;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadCollections,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  sliver: Obx(() {
                    if (isLoading.value) {
                      return _buildLoadingGrid();
                    }

                    if (error.value.isNotEmpty) {
                      return _buildErrorState();
                    }

                    if (collections.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildCollectionsGrid();
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildAppBar() {
    final tokens = AppUiTokens.of(context);

    return SliverAppBar(
      floating: true,
      elevation: 0,
      title: Text(
        'Collections',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadCollections,
        ),
      ],
    );
  }

  Widget _buildLoadingGrid() {
    return ShimmerGridLoader(
      crossAxisCount: 2,
      itemCount: 4,
      childAspectRatio: 1.0,
    );
  }

  Widget _buildErrorState() {
    final tokens = AppUiTokens.of(context);

    return SliverFillRemaining(
      child: Center(
        child: AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: tokens.textMuted,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'Failed to load collections',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                error.value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacing24),
              ElevatedButton.icon(
                onPressed: _loadCollections,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final tokens = AppUiTokens.of(context);

    return SliverFillRemaining(
      child: Center(
        child: AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_outlined,
                size: 64,
                color: tokens.textMuted,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'No collections yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Create collections to organize your outfits',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              ElevatedButton.icon(
                onPressed: _showCreateCollectionDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Collection'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstants.spacing12,
        crossAxisSpacing: AppConstants.spacing12,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final collection = collections[index];
          return _buildCollectionCard(collection);
        },
        childCount: collections.length,
      ),
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> collection) {
    final tokens = AppUiTokens.of(context);
    final id = collection['id']?.toString() ?? '';
    final name = collection['name'] as String? ?? 'Untitled';
    final description = collection['description'] as String?;
    final isFavorite = collection['is_favorite'] as bool? ?? false;
    final outfitIds = collection['outfit_ids'] as List? ?? [];
    final outfitCount = outfitIds.length;

    return GestureDetector(
      onTap: () => _showCollectionDetail(collection),
      onLongPress: () => _showCollectionOptions(collection),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(color: tokens.cardBorderColor),
          boxShadow: [
            BoxShadow(
              color: tokens.cardShadowColor,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Collection icon/placeholder
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tokens.brandColor.withOpacity(0.1),
                      tokens.brandColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radius16),
                ),
                child: Center(
                  child: Icon(
                    Icons.folder,
                    size: 48,
                    color: tokens.brandColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),

            // Favorite indicator
            if (isFavorite)
              Positioned(
                top: AppConstants.spacing8,
                right: AppConstants.spacing8,
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),

            // Collection info at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacing12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppConstants.radius16),
                    bottomRight: Radius.circular(AppConstants.radius16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$outfitCount outfit${outfitCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showCreateCollectionDialog,
      icon: const Icon(Icons.add),
      label: const Text('New Collection'),
    );
  }

  void _showCreateCollectionDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Create Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Collection Name',
                hintText: 'e.g., Summer Outfits',
              ),
              autofocus: true,
            ),
            const SizedBox(height: AppConstants.spacing16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add a description...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a collection name',
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }

              Get.back();
              try {
                await _outfitRepository.createCollection(
                  nameController.text.trim(),
                  [],
                  description: descriptionController.text.trim(),
                );
                Get.snackbar(
                  'Success',
                  'Collection created',
                  snackPosition: SnackPosition.TOP,
                );
                _loadCollections();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  e.toString().replaceAll('Exception: ', ''),
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCollectionDetail(Map<String, dynamic> collection) {
    final tokens = AppUiTokens.of(context);
    final name = collection['name'] as String? ?? 'Untitled';
    final description = collection['description'] as String?;
    final outfitIds = collection['outfit_ids'] as List? ?? [];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
          border: Border.all(color: tokens.cardBorderColor),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
              ),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  description,
                  style: TextStyle(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppConstants.spacing16),
              Text(
                '${outfitIds.length} outfit${outfitIds.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showAddOutfitsDialog(collection);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Outfits'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showDeleteCollectionDialog(collection);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCollectionOptions(Map<String, dynamic> collection) {
    final tokens = AppUiTokens.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
          border: Border.all(color: tokens.cardBorderColor),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View Collection'),
                onTap: () {
                  Get.back();
                  _showCollectionDetail(collection);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Collection'),
                onTap: () {
                  Get.back();
                  _showEditCollectionDialog(collection);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Collection'),
                onTap: () {
                  Get.back();
                  _showDeleteCollectionDialog(collection);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteCollectionDialog(Map<String, dynamic> collection) {
    final name = collection['name'] as String? ?? 'this collection';

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Collection?'),
        content: Text('The collection "$name" will be deleted. Outfits will not be removed from your wardrobe.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _deleteCollection(collection);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to add outfits to collection
  void _showAddOutfitsDialog(Map<String, dynamic> collection) {
    final name = collection['name'] as String? ?? 'Untitled';

    // Show a simple dialog with info
    Get.dialog(
      AlertDialog(
        title: Text('Add Outfits to "$name"'),
        content: const Text(
          'Go to your outfits list and long-press to select multiple outfits, then use the "Add to Collection" option.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to edit collection
  void _showEditCollectionDialog(Map<String, dynamic> collection) {
    final nameController = TextEditingController(text: collection['name'] as String? ?? '');
    final descriptionController = TextEditingController(text: collection['description'] as String? ?? '');

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Collection Name',
                hintText: 'e.g., Summer Outfits',
              ),
              autofocus: true,
            ),
            const SizedBox(height: AppConstants.spacing16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add a description...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a collection name',
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }

              Get.back();
              await _updateCollection(collection, nameController.text.trim(), descriptionController.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Update collection
  Future<void> _updateCollection(
    Map<String, dynamic> collection,
    String name,
    String description,
  ) async {
    final collectionId = collection['id']?.toString() ?? '';
    final outfitIds = collection['outfit_ids'] as List? ?? [];

    try {
      await _outfitRepository.updateCollection(
        collectionId,
        name,
        outfitIds.cast<String>(),
        description: description,
      );
      Get.snackbar(
        'Success',
        'Collection updated',
        snackPosition: SnackPosition.TOP,
      );
      _loadCollections();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Delete collection
  Future<void> _deleteCollection(Map<String, dynamic> collection) async {
    final collectionId = collection['id']?.toString() ?? '';
    final name = collection['name'] as String? ?? 'this collection';

    try {
      await _outfitRepository.deleteCollection(collectionId);
      Get.snackbar(
        'Deleted',
        '"$name" has been deleted',
        snackPosition: SnackPosition.TOP,
      );
      _loadCollections();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
