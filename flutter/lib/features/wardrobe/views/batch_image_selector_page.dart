import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/batch_extraction_controller.dart';
import '../models/social_import_models.dart';
import '../widgets/batch_image_tile.dart';

/// Page for selecting multiple images for batch extraction
class BatchImageSelectorPage extends GetView<BatchExtractionController> {
  const BatchImageSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isSocialMode
                ? 'Import from Social'
                : 'Select Images (${controller.selectedImages.length}/${BatchExtractionController.maxImages})',
          ),
        ),
        elevation: 0,
        actions: [
          Obx(() {
            if (!controller.isSocialMode &&
                controller.selectedImages.isNotEmpty) {
              return TextButton(
                onPressed: controller.clearAllImages,
                child: Text(
                  'Clear All',
                  style: TextStyle(color: tokens.textMuted),
                ),
              );
            }

            if (controller.isSocialMode && controller.hasActiveSocialJob) {
              return IconButton(
                onPressed: controller.refreshSocialStatus,
                icon: const Icon(Icons.refresh),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildModeSwitcher(context, tokens),
              Expanded(
                child: Obx(
                  () => controller.isSocialMode
                      ? _buildSocialBody(context, tokens)
                      : (controller.selectedImages.isEmpty
                            ? _buildEmptyState(context, tokens)
                            : _buildImageGrid(context, tokens)),
                ),
              ),
              Obx(
                () => controller.isSocialMode
                    ? const SizedBox.shrink()
                    : _buildBottomBar(context, tokens),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitcher(BuildContext context, AppUiTokens tokens) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        AppConstants.spacing8,
      ),
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: tokens.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            border: Border.all(color: tokens.cardBorderColor),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _modeButton(
                  context,
                  tokens,
                  label: 'Upload Photos',
                  active: !controller.isSocialMode,
                  onTap: () => controller.setInputMode(BatchInputMode.upload),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _modeButton(
                  context,
                  tokens,
                  label: 'Import URL',
                  active: controller.isSocialMode,
                  onTap: () => controller.setInputMode(BatchInputMode.social),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(
    BuildContext context,
    AppUiTokens tokens, {
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing8,
          vertical: AppConstants.spacing12,
        ),
        decoration: BoxDecoration(
          color: active ? tokens.brandColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radius12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: active ? Colors.white : tokens.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBody(BuildContext context, AppUiTokens tokens) {
    final job = controller.socialJob.value;
    final awaitingPhoto = controller.socialAwaitingPhoto;
    final bufferedPhoto = controller.socialBufferedPhoto;
    final processingPhoto = controller.socialProcessingPhoto;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: tokens.brandColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppConstants.radius12),
              border: Border.all(color: tokens.brandColor.withOpacity(0.25)),
            ),
            child: Text(
              'Connect Instagram or Facebook profile URL and import photos automatically.',
              style: TextStyle(color: tokens.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.socialIsLoading.value
                  ? null
                  : () => _showStartSocialDialog(context, tokens),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandColor,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.link_outlined, size: 18),
              label: Text(job == null ? 'Start Import' : 'Start New Import'),
            ),
          ),
          if (controller.socialIsLoading.value) ...[
            const SizedBox(height: AppConstants.spacing12),
            LinearProgressIndicator(
              minHeight: 4,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.brandColor),
            ),
          ],
          if (controller.hasSocialError) ...[
            const SizedBox(height: AppConstants.spacing12),
            _buildErrorCard(tokens, controller.socialError.value),
          ],
          if (job != null) ...[
            const SizedBox(height: AppConstants.spacing12),
            _buildSocialProgressCard(context, tokens, job),
          ],
          if (job != null && controller.isSocialAuthRequired) ...[
            const SizedBox(height: AppConstants.spacing12),
            _buildSocialAuthCard(context, tokens, job.platform),
          ],
          if (job != null &&
              !controller.isSocialAuthRequired &&
              (awaitingPhoto != null ||
                  bufferedPhoto != null ||
                  processingPhoto != null)) ...[
            const SizedBox(height: AppConstants.spacing12),
            _buildSocialQueueCard(
              context,
              tokens,
              awaiting: awaitingPhoto,
              buffered: bufferedPhoto,
              processing: processingPhoto,
            ),
          ],
          if (job != null) ...[
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.socialIsLoading.value
                        ? null
                        : controller.cancelSocialImportJob,
                    child: const Text('Cancel Job'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.socialIsLoading.value
                        ? null
                        : controller.resetSocialImportState,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.brandColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showStartSocialDialog(BuildContext context, AppUiTokens tokens) {
    final input = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.cardColor,
        title: Text(
          'Import Profile URL',
          style: TextStyle(color: tokens.textPrimary),
        ),
        content: TextField(
          controller: input,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://www.instagram.com/username/',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: tokens.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final value = input.text.trim();
              Navigator.pop(context);
              if (value.isNotEmpty) {
                controller.startSocialImport(value);
              }
            },
            child: Text('Start', style: TextStyle(color: tokens.brandColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(AppUiTokens tokens, String message) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: Colors.red.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: AppConstants.spacing8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialProgressCard(
    BuildContext context,
    AppUiTokens tokens,
    SocialImportJobData job,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${job.platform.label} - ${job.status.value}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.circle,
                size: 10,
                color: controller.socialIsConnected.value
                    ? Colors.green
                    : tokens.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                controller.socialIsConnected.value ? 'Live' : 'Offline',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          LinearProgressIndicator(
            value: controller.socialProgress,
            minHeight: 8,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.brandColor),
            backgroundColor: tokens.textMuted.withOpacity(0.2),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Wrap(
            spacing: AppConstants.spacing8,
            runSpacing: AppConstants.spacing8,
            children: [
              _buildStatChip(tokens, 'Discovered', '${job.discoveredPhotos}'),
              _buildStatChip(tokens, 'Processed', '${job.processedPhotos}'),
              _buildStatChip(tokens, 'Approved', '${job.approvedPhotos}'),
              _buildStatChip(tokens, 'Queued', '${job.queuedCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(AppUiTokens tokens, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tokens.navBackground,
        borderRadius: BorderRadius.circular(AppConstants.radius8),
        border: Border.all(color: tokens.navBorder),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: tokens.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSocialAuthCard(
    BuildContext context,
    AppUiTokens tokens,
    SocialPlatform platform,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Login required for ${platform.label}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.socialIsLoading.value
                  ? null
                  : controller.startSocialOAuthConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Connect ${platform.label}'),
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: controller.socialIsLoading.value
                  ? null
                  : controller.refreshSocialStatus,
              child: const Text('I Completed Browser Login'),
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: controller.socialIsLoading.value
                  ? null
                  : () => _showManualAuthDialog(context, tokens),
              child: const Text('Manual Login Fallback'),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualAuthDialog(BuildContext context, AppUiTokens tokens) {
    final username = TextEditingController();
    final password = TextEditingController();
    final otp = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.cardColor,
        title: Text(
          'Manual Login',
          style: TextStyle(color: tokens.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: username,
              decoration: const InputDecoration(
                hintText: 'Username',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            TextField(
              controller: otp,
              decoration: const InputDecoration(
                hintText: 'OTP (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: tokens.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final user = username.text.trim();
              final pass = password.text;
              Navigator.pop(context);
              if (user.isNotEmpty && pass.isNotEmpty) {
                controller.submitSocialScraperAuth(
                  username: user,
                  password: pass,
                  otpCode: otp.text.trim(),
                );
              }
            },
            child: Text('Continue', style: TextStyle(color: tokens.brandColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialQueueCard(
    BuildContext context,
    AppUiTokens tokens, {
    required SocialImportPhoto? awaiting,
    required SocialImportPhoto? buffered,
    required SocialImportPhoto? processing,
  }) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            awaiting != null
                ? 'Awaiting review: Photo #${awaiting.ordinal}'
                : 'No photo awaiting review yet',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (awaiting != null) ...[
            const SizedBox(height: AppConstants.spacing12),
            _buildImagePreview(
              awaiting.sourceThumbUrl ?? awaiting.sourcePhotoUrl,
            ),
            const SizedBox(height: AppConstants.spacing12),
            ...awaiting.items.map(
              (item) => _buildSocialItemTile(
                context,
                tokens,
                photoId: awaiting.id,
                item: item,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.socialIsLoading.value
                        ? null
                        : controller.rejectAwaitingSocialPhoto,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.socialIsLoading.value
                        ? null
                        : controller.approveAwaitingSocialPhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.brandColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve & Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing12),
            Divider(color: tokens.navBorder),
          ],
          if (buffered != null) ...[
            Text(
              'Next ready: Photo #${buffered.ordinal}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: AppConstants.spacing8),
            _buildImagePreview(
              buffered.sourceThumbUrl ?? buffered.sourcePhotoUrl,
              height: 120,
            ),
          ] else if (processing != null) ...[
            Text(
              'Processing next photo #${processing.ordinal}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialItemTile(
    BuildContext context,
    AppUiTokens tokens, {
    required String photoId,
    required SocialImportItem item,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
      padding: const EdgeInsets.all(AppConstants.spacing8),
      decoration: BoxDecoration(
        color: tokens.navBackground,
        borderRadius: BorderRadius.circular(AppConstants.radius8),
        border: Border.all(color: tokens.navBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((item.generatedImageUrl ?? '').isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item.generatedImageUrl!,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined, size: 18),
                ),
              ),
            ),
          if ((item.generatedImageUrl ?? '').isNotEmpty)
            const SizedBox(width: AppConstants.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? item.subCategory ?? item.category.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category.displayName} - ${item.colors.join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditSocialItemDialog(
              context,
              tokens,
              photoId: photoId,
              item: item,
            ),
            icon: Icon(Icons.edit_outlined, color: tokens.brandColor, size: 18),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSocialItemDialog(
    BuildContext context,
    AppUiTokens tokens, {
    required String photoId,
    required SocialImportItem item,
  }) async {
    final name = TextEditingController(text: item.name ?? '');
    final category = TextEditingController(text: item.category.value);
    final colors = TextEditingController(text: item.colors.join(', '));
    final material = TextEditingController(text: item.material ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.cardColor,
        title: Text('Edit Item', style: TextStyle(color: tokens.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              TextField(
                controller: category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              TextField(
                controller: colors,
                decoration: const InputDecoration(
                  labelText: 'Colors (comma-separated)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              TextField(
                controller: material,
                decoration: const InputDecoration(
                  labelText: 'Material',
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: tokens.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final colorValues = colors.text
                  .split(',')
                  .map((value) => value.trim())
                  .where((value) => value.isNotEmpty)
                  .toList();

              await controller.patchSocialItem(
                photoId: photoId,
                itemId: item.id,
                updates: {
                  'name': name.text.trim().isEmpty ? null : name.text.trim(),
                  'category': category.text.trim().isEmpty
                      ? null
                      : category.text.trim(),
                  'colors': colorValues,
                  'material': material.text.trim().isEmpty
                      ? null
                      : material.text.trim(),
                },
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text('Save', style: TextStyle(color: tokens.brandColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String url, {double height = 180}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Image.network(
        url,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: height,
          color: Colors.black12,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppUiTokens tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: tokens.brandColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.collections_outlined,
                size: 40,
                color: tokens.brandColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'No Images Selected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Select up to ${BatchExtractionController.maxImages} images to extract clothing items',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAddButton(
                  context,
                  tokens,
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: controller.pickFromGallery,
                ),
                const SizedBox(width: AppConstants.spacing16),
                _buildAddButton(
                  context,
                  tokens,
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: controller.pickFromCamera,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    AppUiTokens tokens, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing20,
          vertical: AppConstants.spacing16,
        ),
        decoration: BoxDecoration(
          color: tokens.brandColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          border: Border.all(color: tokens.brandColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: tokens.brandColor, size: 28),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: TextStyle(
                color: tokens.brandColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, AppUiTokens tokens) {
    return Obx(
      () => GridView.builder(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: AppConstants.spacing8,
          mainAxisSpacing: AppConstants.spacing8,
        ),
        itemCount: controller.selectedImages.length + 1, // +1 for add button
        itemBuilder: (context, index) {
          // Last item is the add button
          if (index == controller.selectedImages.length) {
            return _buildAddMoreTile(context, tokens);
          }

          final image = controller.selectedImages[index];
          return BatchImageTile(
            image: image,
            onRemove: () => controller.removeImage(image.id),
            showStatus: false,
          );
        },
      ),
    );
  }

  Widget _buildAddMoreTile(BuildContext context, AppUiTokens tokens) {
    return Obx(() {
      if (controller.remainingSlots.value <= 0) {
        return const SizedBox.shrink();
      }

      return InkWell(
        onTap: () => _showAddImageOptions(context, tokens),
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        child: Container(
          decoration: BoxDecoration(
            color: tokens.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            border: Border.all(
              color: tokens.cardBorderColor,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: tokens.textMuted,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Add',
                style: TextStyle(color: tokens.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showAddImageOptions(BuildContext context, AppUiTokens tokens) {
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radius16),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppConstants.spacing16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: tokens.brandColor,
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(color: tokens.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.pickFromGallery();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: tokens.brandColor,
              ),
              title: Text(
                'Take Photo',
                style: TextStyle(color: tokens.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.pickFromCamera();
              },
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppUiTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: tokens.navBackground,
        border: Border(top: BorderSide(color: tokens.navBorder)),
      ),
      child: Obx(() {
        final hasImages = controller.selectedImages.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info text
            if (hasImages)
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: tokens.textMuted),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(
                      child: Text(
                        'AI will detect clothing items from each image',
                        style: TextStyle(color: tokens.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasImages ? _startExtraction : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacing16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                ),
                child: Text(
                  hasImages
                      ? 'Extract Items (${controller.selectedImages.length} ${controller.selectedImages.length == 1 ? 'image' : 'images'})'
                      : 'Select Images to Continue',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _startExtraction() {
    controller.startExtraction();
    Get.toNamed(Routes.wardrobeBatchProgress);
  }
}
