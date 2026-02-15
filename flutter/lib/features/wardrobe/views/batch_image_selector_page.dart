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
  final bool launchInSocialMode;

  const BatchImageSelectorPage({super.key, this.launchInSocialMode = false});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    if (launchInSocialMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initializeSocialMode();
      });
    }

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

    // State-based UI rendering for better UX
    if (job == null) {
      // No job started - show input form directly on page
      return _buildSocialInputForm(context, tokens);
    }

    if (controller.isSocialAuthRequired) {
      // Auth required - show inline auth options
      return _buildSocialAuthForm(context, tokens, job);
    }

    if (job.status == SocialImportJobStatus.discovering) {
      // Discovering photos
      return _buildSocialDiscoveringState(context, tokens, job);
    }

    // Processing/Review state or other states
    return _buildSocialProcessingState(context, tokens, job);
  }

  // New UI Components for improved UX

  Widget _buildSocialInputForm(BuildContext context, AppUiTokens tokens) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Icon(Icons.camera_alt_outlined, size: 48, color: tokens.brandColor),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'Import from Social',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'Enter a public Instagram or Facebook profile URL to import photos automatically.',
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppConstants.spacing24),

          // URL Input Field
          Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile URL',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                TextField(
                  controller: controller.socialUrlController,
                  onChanged: controller.validateSocialUrl,
                  decoration: InputDecoration(
                    hintText: 'https://instagram.com/username',
                    hintStyle: TextStyle(color: tokens.textMuted),
                    prefixIcon: Icon(
                      Icons.link_outlined,
                      color: tokens.textMuted,
                    ),
                    suffixIcon: controller.socialUrlInput.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: tokens.textMuted,
                              size: 20,
                            ),
                            onPressed: controller.clearSocialUrl,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                      borderSide: BorderSide(color: tokens.cardBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                      borderSide: BorderSide(color: tokens.cardBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                      borderSide: BorderSide(
                        color: tokens.brandColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    errorText: controller.socialUrlError.value.isNotEmpty
                        ? controller.socialUrlError.value
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing16,
                      vertical: AppConstants.spacing16,
                    ),
                    filled: true,
                    fillColor: tokens.cardColor,
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
              ],
            );
          }),

          const SizedBox(height: AppConstants.spacing24),

          // Start Import Button
          Obx(() {
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed:
                    controller.socialIsLoading.value ||
                        !controller.isValidSocialUrl.value
                    ? null
                    : () => controller.startSocialImport(
                        controller.socialUrlInput.value,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: tokens.textMuted.withValues(
                    alpha: 0.3,
                  ),
                  disabledForegroundColor: tokens.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                  elevation: 0,
                ),
                icon: controller.socialIsLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(Icons.download_outlined),
                label: Text(
                  controller.socialIsLoading.value
                      ? 'Starting...'
                      : 'Start Import',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }),

          if (controller.hasSocialError) ...[
            const SizedBox(height: AppConstants.spacing16),
            _buildErrorCard(tokens, controller.socialError.value),
          ],

          const SizedBox(height: AppConstants.spacing24),

          // Info cards
          _buildInfoCard(
            tokens,
            icon: Icons.info_outline,
            title: 'How it works',
            description:
                'We\'ll scan the profile and import photos. You can review each item before adding it to your wardrobe.',
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildInfoCard(
            tokens,
            icon: Icons.lock_outline,
            title: 'Private accounts',
            description:
                'For private profiles, connect with OAuth. Manual credentials are supported for Instagram.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    AppUiTokens tokens, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tokens.brandColor, size: 20),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAuthForm(
    BuildContext context,
    AppUiTokens tokens,
    SocialImportJobData job,
  ) {
    final allowManualLogin = job.platform == SocialPlatform.instagram;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button to reset
          Row(
            children: [
              IconButton(
                onPressed: controller.resetSocialImportState,
                icon: Icon(Icons.arrow_back, color: tokens.textMuted),
              ),
              Expanded(
                child: Text(
                  'Authentication Required',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing24),

          // Icon and message
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: tokens.brandColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 40,
                color: tokens.brandColor,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing24),

          Text(
            'This profile requires authentication',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'The Instagram profile may be private or requires login to access photos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          if (controller.hasSocialError) ...[
            const SizedBox(height: AppConstants.spacing16),
            _buildErrorCard(tokens, controller.socialError.value),
          ],

          const SizedBox(height: AppConstants.spacing32),

          // Auth options
          if (!controller.waitingForOtp.value) ...[
            // Primary: OAuth Connect
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: controller.socialIsLoading.value
                    ? null
                    : controller.startSocialOAuthConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.open_in_browser),
                label: Text(
                  'Connect with ${job.platform.label}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacing16),

            if (allowManualLogin) ...[
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: tokens.cardBorderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                    ),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: tokens.cardBorderColor)),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),
              // Secondary: Manual login
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: controller.socialIsLoading.value
                      ? null
                      : () => _showManualAuthDialog(context, tokens),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.textPrimary,
                    side: BorderSide(color: tokens.cardBorderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.login),
                  label: Text(
                    'Enter Username & Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing12),
            ],

            // Tertiary: Already connected
            Center(
              child: TextButton(
                onPressed: controller.socialIsLoading.value
                    ? null
                    : controller.refreshSocialStatus,
                child: Text(
                  'I already connected in browser',
                  style: TextStyle(color: tokens.textMuted),
                ),
              ),
            ),
          ] else ...[
            // 2FA State - Inline OTP UI
            Row(
              children: [
                Icon(
                  Icons.security_outlined,
                  color: tokens.brandColor,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing8),
                Expanded(
                  child: Text(
                    'Two-Factor Authentication',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing12),
            Text(
              'Your ${job.platform.label} account has 2FA enabled. Please enter the 6-digit code from your authenticator app.',
              style: TextStyle(color: tokens.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppConstants.spacing12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.socialIsLoading.value
                    ? null
                    : () => _showOtpDialog(context, tokens),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enter 2FA Code'),
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.socialIsLoading.value
                    ? null
                    : () {
                        // Allow user to go back and try different method
                        controller.waitingForOtp.value = false;
                        controller.lastUsername.value = '';
                        controller.lastPassword.value = '';
                      },
                child: const Text('Try Different Method'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialDiscoveringState(
    BuildContext context,
    AppUiTokens tokens,
    SocialImportJobData job,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated progress indicator
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      tokens.brandColor,
                    ),
                  ),
                  Icon(Icons.search, size: 40, color: tokens.brandColor),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing32),

            Text(
              'Discovering photos...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),

            Obx(() {
              final isConnected = controller.socialIsConnected.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: isConnected ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Live connection' : 'Connecting...',
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: AppConstants.spacing24),

            // Stats
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              decoration: BoxDecoration(
                color: tokens.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.radius12),
                border: Border.all(color: tokens.cardBorderColor),
              ),
              child: Column(
                children: [
                  _buildDiscoveringStat(
                    tokens,
                    'Photos Found',
                    '${job.discoveredPhotos}',
                  ),
                  Divider(color: tokens.cardBorderColor, height: 24),
                  _buildDiscoveringStat(
                    tokens,
                    'URL',
                    job.normalizedUrl,
                    isUrl: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing32),

            // Cancel button
            OutlinedButton.icon(
              onPressed: controller.socialIsLoading.value
                  ? null
                  : controller.cancelSocialImportJob,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing24,
                  vertical: AppConstants.spacing12,
                ),
              ),
              icon: Icon(Icons.cancel_outlined),
              label: Text('Cancel Import'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveringStat(
    AppUiTokens tokens,
    String label,
    String value, {
    bool isUrl = false,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(color: tokens.textSecondary, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: isUrl ? 1 : null,
            overflow: isUrl ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialProcessingState(
    BuildContext context,
    AppUiTokens tokens,
    SocialImportJobData job,
  ) {
    final awaitingPhoto = controller.socialAwaitingPhoto;
    final bufferedPhoto = controller.socialBufferedPhoto;
    final processingPhoto = controller.socialProcessingPhoto;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Processing Photos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.processedPhotos} of ${job.totalPhotos} processed',
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Connection status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: controller.socialIsConnected.value
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: controller.socialIsConnected.value
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.socialIsConnected.value ? 'Live' : 'Offline',
                      style: TextStyle(
                        color: controller.socialIsConnected.value
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing16),

          // Progress bar
          LinearProgressIndicator(
            value: job.totalPhotos > 0
                ? job.processedPhotos / job.totalPhotos
                : 0,
            minHeight: 8,
            backgroundColor: tokens.textMuted.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(tokens.brandColor),
            borderRadius: BorderRadius.circular(4),
          ),

          const SizedBox(height: AppConstants.spacing8),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProcessingStat(
                tokens,
                'Approved',
                job.approvedPhotos,
                Colors.green,
              ),
              _buildProcessingStat(
                tokens,
                'Queued',
                job.queuedCount,
                tokens.brandColor,
              ),
              _buildProcessingStat(
                tokens,
                'Rejected',
                job.rejectedPhotos,
                Colors.red,
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing24),

          // Current photo review or queue status
          if (awaitingPhoto != null) ...[
            _buildPhotoReviewCard(context, tokens, awaitingPhoto),
          ] else if (processingPhoto != null) ...[
            _buildProcessingCard(tokens, processingPhoto),
          ] else ...[
            _buildWaitingCard(tokens),
          ],

          if (bufferedPhoto != null) ...[
            const SizedBox(height: AppConstants.spacing16),
            _buildBufferedCard(tokens, bufferedPhoto),
          ],

          const SizedBox(height: AppConstants.spacing24),

          // Cancel button
          Center(
            child: OutlinedButton.icon(
              onPressed: controller.socialIsLoading.value
                  ? null
                  : controller.cancelSocialImportJob,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
              ),
              icon: Icon(Icons.cancel_outlined),
              label: Text('Cancel Import'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStat(
    AppUiTokens tokens,
    String label,
    int value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: tokens.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPhotoReviewCard(
    BuildContext context,
    AppUiTokens tokens,
    SocialImportPhoto photo,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.reviews_outlined, color: tokens.brandColor, size: 20),
              const SizedBox(width: AppConstants.spacing8),
              Expanded(
                child: Text(
                  'Review Photo #${photo.ordinal}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Photo preview
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            child: Image.network(
              photo.sourceThumbUrl ?? photo.sourcePhotoUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined, size: 40),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacing16),

          // Items list
          if (photo.items.isNotEmpty) ...[
            Text(
              'Detected Items (${photo.items.length})',
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            ...photo.items.map(
              (item) => _buildSocialItemTile(
                context,
                tokens,
                photoId: photo.id,
                item: item,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.socialIsLoading.value
                      ? null
                      : controller.rejectAwaitingSocialPhoto,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacing12,
                    ),
                  ),
                  icon: Icon(Icons.close, size: 18),
                  label: Text('Reject'),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.socialIsLoading.value
                      ? null
                      : controller.approveAwaitingSocialPhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacing12,
                    ),
                  ),
                  icon: Icon(Icons.check, size: 18),
                  label: Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingCard(AppUiTokens tokens, SocialImportPhoto photo) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      child: Column(
        children: [
          CircularProgressIndicator(color: tokens.brandColor),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'Processing Photo #${photo.ordinal}',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is analyzing this photo...',
            style: TextStyle(color: tokens.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingCard(AppUiTokens tokens) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      child: Column(
        children: [
          Icon(Icons.hourglass_empty, size: 48, color: tokens.textMuted),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'Waiting for next photo...',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Photos are being processed in the background',
            style: TextStyle(color: tokens.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBufferedCard(AppUiTokens tokens, SocialImportPhoto photo) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: Image.network(
              photo.sourceThumbUrl ?? photo.sourcePhotoUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.black12,
                child: const Icon(Icons.broken_image_outlined, size: 20),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next in Queue',
                  style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Photo #${photo.ordinal}',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: tokens.brandColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radius8),
            ),
            child: Text(
              'Ready',
              style: TextStyle(
                color: tokens.brandColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
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
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.lock_outline, size: 20),
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            TextField(
              controller: otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: '2FA Code (if enabled)',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.security_outlined, size: 20),
                counterText: '',
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'If you have two-factor authentication enabled, enter the 6-digit code from your authenticator app.',
              style: TextStyle(color: tokens.textMuted, fontSize: 12),
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
              final otpCode = otp.text.trim();
              Navigator.pop(context);
              if (user.isNotEmpty && pass.isNotEmpty) {
                // Store credentials for potential 2FA retry
                controller.lastUsername.value = user;
                controller.lastPassword.value = pass;

                controller.submitSocialScraperAuth(
                  username: user,
                  password: pass,
                  otpCode: otpCode.isNotEmpty ? otpCode : null,
                );
              }
            },
            child: Text('Continue', style: TextStyle(color: tokens.brandColor)),
          ),
        ],
      ),
    );
  }

  void _showOtpDialog(BuildContext context, AppUiTokens tokens) {
    final otp = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Force user to respond
      builder: (context) => AlertDialog(
        backgroundColor: tokens.cardColor,
        title: Row(
          children: [
            Icon(Icons.security_outlined, color: tokens.brandColor, size: 24),
            const SizedBox(width: AppConstants.spacing8),
            Text(
              'Two-Factor Authentication',
              style: TextStyle(color: tokens.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the 6-digit code from your authenticator app',
              style: TextStyle(color: tokens.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing16),
            TextField(
              controller: otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                letterSpacing: 12,
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(
                  fontSize: 28,
                  letterSpacing: 12,
                  color: tokens.textMuted.withOpacity(0.5),
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacing16,
                  horizontal: AppConstants.spacing12,
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'The code expires quickly. If it fails, wait for a new code to be generated.',
              style: TextStyle(color: tokens.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: tokens.textMuted)),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: otp,
            builder: (_, value, __) {
              final isValid = value.text.trim().length == 6;
              return TextButton(
                onPressed: isValid
                    ? () {
                        final code = value.text.trim();
                        Navigator.pop(context);
                        controller.submitSocialScraperAuth(
                          username: controller.lastUsername.value,
                          password: controller.lastPassword.value,
                          otpCode: code,
                        );
                      }
                    : null,
                child: Text(
                  'Verify',
                  style: TextStyle(
                    color: isValid ? tokens.brandColor : tokens.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).whenComplete(otp.dispose);
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
