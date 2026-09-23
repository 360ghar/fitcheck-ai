import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/social_import_models.dart';
import '../providers/batch_extraction_provider.dart';
import '../widgets/batch_image_tile.dart';
import '../widgets/extraction_progress_card.dart' show PaperProgressTrack;

/// Step one of a batch add: choose up to 50 photos, or import from a
/// public profile.
class BatchImageSelectorPage extends ConsumerStatefulWidget {
  const BatchImageSelectorPage({super.key, this.launchInSocialMode = false});

  final bool launchInSocialMode;

  @override
  ConsumerState<BatchImageSelectorPage> createState() =>
      _BatchImageSelectorPageState();
}

class _BatchImageSelectorPageState
    extends ConsumerState<BatchImageSelectorPage> {
  final _picker = ImagePicker();

  BatchExtractionNotifier get _notifier =>
      ref.read(batchExtractionProvider.notifier);

  @override
  void initState() {
    super.initState();
    if (widget.launchInSocialMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notifier.setInputMode(BatchInputMode.social);
      });
    }
  }

  static bool _denied(PlatformException e) =>
      e.code.toLowerCase().contains('denied');

  Future<void> _addFiles(List<XFile> picked) async {
    if (picked.isEmpty || !mounted) return;
    final rejected = await _notifier.addImages([
      for (final f in picked) File(f.path),
    ]);
    if (rejected != null) {
      ErrorHandler.showValidation(rejected, title: 'Some photos skipped');
    }
  }

  Future<void> _pickGallery() async {
    if (!await PermissionHelper.confirmPhotoRationale()) return;
    try {
      await _addFiles(
        await _picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        ),
      );
    } on PlatformException catch (e) {
      if (_denied(e)) {
        await PermissionHelper.showDeniedRecovery(permissionName: 'Photos');
      } else {
        ErrorHandler.showError(e, title: 'Photos not added');
      }
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Photos not added', stackTrace: stack);
    }
  }

  Future<void> _pickCamera() async {
    if (ref.read(batchExtractionProvider).remainingSlots <= 0) {
      ErrorHandler.showValidation(
        'You can add up to ${BatchExtractionNotifier.maxImages} photos.',
        title: 'No room',
      );
      return;
    }
    if (!await PermissionHelper.confirmCameraRationale()) return;
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      await _addFiles([?photo]);
    } on PlatformException catch (e) {
      if (_denied(e)) {
        await PermissionHelper.showDeniedRecovery(permissionName: 'Camera');
      } else {
        ErrorHandler.showError(e, title: 'Photo not added');
      }
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Photo not added', stackTrace: stack);
    }
  }

  void _addSheet() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(context);
              _pickCamera();
            },
          ),
          const SizedBox(height: AppConstants.spacing8),
        ],
      ),
    ),
  );

  Future<void> _start() async {
    await _notifier.startExtraction();
    if (!mounted) return;
    final s = ref.read(batchExtractionProvider);
    if (s.isFailed) {
      ErrorHandler.showError(s.error, title: 'Not started');
      return;
    }
    // No job id: consent was declined or another start is running.
    if (s.jobId.isEmpty) return;
    context.push(Routes.wardrobeBatchProgress);
  }

  @override
  Widget build(BuildContext context) {
    final (social, count, hasSocialJob, busy) = ref.watch(
      batchExtractionProvider.select(
        (s) => (
          s.isSocialMode,
          s.images.length,
          s.socialJobId.isNotEmpty,
          s.isProcessing,
        ),
      ),
    );

    return PaperStockScope(
      stock: PaperStockId.moss,
      child: Scaffold(
        appBar: AppBar(
          title: Text(social ? 'Import from a profile' : 'Add several photos'),
          actions: [
            if (!social && count > 0)
              Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacing8),
                child: TextButton(
                  onPressed: busy ? null : _notifier.clearAllImages,
                  child: const Text('Clear'),
                ),
              ),
            if (social && hasSocialJob)
              IconButton(
                tooltip: 'Refresh',
                onPressed: _notifier.refreshSocialStatus,
                icon: const Icon(Icons.refresh_rounded),
              ),
          ],
        ),
        body: AppPageBackground(
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacing16,
                    AppConstants.spacing8,
                    AppConstants.spacing16,
                    AppConstants.spacing8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<BatchInputMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: BatchInputMode.upload,
                          label: Text('Photos'),
                          icon: Icon(Icons.collections_outlined),
                        ),
                        ButtonSegment(
                          value: BatchInputMode.social,
                          label: Text('Profile link'),
                          icon: Icon(Icons.link_rounded),
                        ),
                      ],
                      selected: {
                        social ? BatchInputMode.social : BatchInputMode.upload,
                      },
                      onSelectionChanged: busy
                          ? null
                          : (value) => _notifier.setInputMode(value.first),
                    ),
                  ),
                ),
                Expanded(
                  child: social
                      ? const _SocialBody()
                      : count == 0
                      ? SingleChildScrollView(
                          child: AppEmptyState(
                            scene: PaperScenes.closet,
                            title: 'No photos yet',
                            message:
                                'Pick up to ${BatchExtractionNotifier.maxImages} photos. We find the pieces.',
                            actionLabel: 'Choose photos',
                            actionIcon: Icons.photo_library_outlined,
                            onAction: _pickGallery,
                            secondary: TextButton.icon(
                              onPressed: _pickCamera,
                              icon: const Icon(
                                Icons.photo_camera_outlined,
                                size: 20,
                              ),
                              label: const Text('Take a photo'),
                            ),
                          ),
                        )
                      : _PhotoGrid(onAdd: _addSheet),
                ),
                if (!social && count > 0) _ExtractBar(onStart: _start),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoGrid extends ConsumerWidget {
  const _PhotoGrid({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (images, busy) = ref.watch(
      batchExtractionProvider.select((s) => (s.images, s.isUploading)),
    );
    final notifier = ref.read(batchExtractionProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final canAdd = !busy && images.length < BatchExtractionNotifier.maxImages;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacing20,
            AppConstants.spacing8,
            AppConstants.spacing20,
            AppConstants.spacing12,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              '${images.length} of ${BatchExtractionNotifier.maxImages} photos',
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacing16,
            0,
            AppConstants.spacing16,
            AppConstants.spacing16,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              crossAxisSpacing: AppConstants.spacing8,
              mainAxisSpacing: AppConstants.spacing8,
            ),
            itemCount: images.length + (canAdd ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == images.length) {
                return PaperSurface(
                  lift: 0,
                  color: tokens.stock.sunk,
                  padding: EdgeInsets.zero,
                  borderRadius: AppConstants.radius8,
                  onTap: onAdd,
                  semanticLabel: 'Add photos',
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: tokens.stock.accent,
                          size: 28,
                        ),
                        const SizedBox(height: AppConstants.spacing4),
                        Text('Add', style: text.labelMedium),
                      ],
                    ),
                  ),
                );
              }
              final image = images[i];
              return BatchImageTile(
                image: image,
                showStatus: busy,
                onRemove: busy ? null : () => notifier.removeImage(image.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ExtractBar extends ConsumerWidget {
  const _ExtractBar({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (count, uploading, progress, busy) = ref.watch(
      batchExtractionProvider.select(
        (s) =>
            (s.images.length, s.isUploading, s.uploadProgress, s.isProcessing),
      ),
    );
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final done = (progress * count).round();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing16,
          AppConstants.spacing8,
          AppConstants.spacing16,
          AppConstants.spacing12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (uploading) ...[
              PaperProgressTrack(
                value: progress,
                semanticLabel: 'Preparing photos',
              ),
              const SizedBox(height: AppConstants.spacing8),
            ] else ...[
              Text(
                'We find each piece and make a studio photo of it.',
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppConstants.spacing8),
            ],
            ElevatedButton(
              // Disabled while photos are prepared: a second tap would start
              // a second paid job.
              onPressed: busy ? null : onStart,
              child: Text(
                uploading
                    ? 'Preparing photo ${done.clamp(1, count)} of $count'
                    : count == 1
                    ? 'Find pieces in 1 photo'
                    : 'Find pieces in $count photos',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Social import.

class _SocialBody extends ConsumerWidget {
  const _SocialBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (job, authRequired) = ref.watch(
      batchExtractionProvider.select(
        (s) => (s.socialJob, s.isSocialAuthRequired),
      ),
    );
    if (job == null) return const _SocialInputForm();
    if (authRequired) return _SocialAuth(job: job);
    if (job.status == SocialImportJobStatus.discovering) {
      return _SocialDiscovering(job: job);
    }
    // Terminal states need closure; they must not fall through to the
    // processing view with a cancel button for a job that already ended.
    if (job.isTerminal) return _SocialEnded(job: job);
    return _SocialProcessing(job: job);
  }
}

class _Padded extends StatelessWidget {
  const _Padded({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(
      AppConstants.spacing16,
      AppConstants.spacing8,
      AppConstants.spacing16,
      AppConstants.spacing32,
    ),
    children: children,
  );
}

class _SocialError extends ConsumerWidget {
  const _SocialError();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(
      batchExtractionProvider.select((s) => s.socialError),
    );
    if (error.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacing12),
      child: _Notice(
        icon: Icons.error_outline_rounded,
        color: PaperTokens.of(context).error,
        text: error,
      ),
    );
  }
}

/// A short message with a bare leading icon on a flat tinted sheet.
class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return PaperSurface(
      lift: 0,
      grain: false,
      color: tokens.stock.tint,
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? tokens.textSecondary),
          const SizedBox(width: AppConstants.spacing8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color ?? tokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialInputForm extends ConsumerStatefulWidget {
  const _SocialInputForm();

  @override
  ConsumerState<_SocialInputForm> createState() => _SocialInputFormState();
}

class _SocialInputFormState extends ConsumerState<_SocialInputForm> {
  late final _url = TextEditingController(
    text: ref.read(batchExtractionProvider).socialUrl,
  );

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (urlError, valid, loading) = ref.watch(
      batchExtractionProvider.select(
        (s) => (s.socialUrlError, s.validSocialUrl, s.socialLoading),
      ),
    );
    final notifier = ref.read(batchExtractionProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;

    return _Padded(
      children: [
        PaperSurface(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Paste a profile link', style: text.headlineSmall),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'A public Instagram or Facebook profile. We scan its photos, and you choose what goes in your closet.',
                style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppConstants.spacing20),
              TextField(
                controller: _url,
                onChanged: notifier.validateSocialUrl,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Profile link',
                  hintText: 'https://instagram.com/username',
                  errorText: urlError.isEmpty ? null : urlError,
                  suffixIcon: ValueListenableBuilder(
                    valueListenable: _url,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: 'Clear link',
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _url.clear();
                              notifier.validateSocialUrl('');
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              ElevatedButton(
                onPressed: loading || !valid
                    ? null
                    : () => notifier.startSocialImport(_url.text),
                child: Text(loading ? 'Starting' : 'Start import'),
              ),
              const _SocialError(),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        _HowItWorks(
          icon: Icons.fact_check_outlined,
          title: 'You review every photo',
          body: 'Nothing is added until you approve it.',
        ),
        _HowItWorks(
          icon: Icons.lock_outline_rounded,
          title: 'Private profiles',
          body:
              'Connect your account. Instagram also takes a username and password.',
        ),
      ],
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing8,
        vertical: AppConstants.spacing8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: tokens.stock.accent),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                Text(
                  body,
                  style: text.bodySmall?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialAuth extends ConsumerWidget {
  const _SocialAuth({required this.job});

  final SocialImportJobData job;

  Future<void> _manualLogin(BuildContext context, WidgetRef ref) async {
    final login = await showDialog<({String user, String pass, String otp})>(
      context: context,
      builder: (_) => const _ManualLoginDialog(),
    );
    if (login == null || login.user.isEmpty || login.pass.isEmpty) return;
    await ref
        .read(batchExtractionProvider.notifier)
        .submitSocialScraperAuth(
          username: login.user,
          password: login.pass,
          otpCode: login.otp.isEmpty ? null : login.otp,
        );
  }

  Future<void> _otp(BuildContext context, WidgetRef ref) async {
    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _OtpDialog(),
    );
    if (code == null) return;
    await ref.read(batchExtractionProvider.notifier).submitSocialOtp(code);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (otp, loading) = ref.watch(
      batchExtractionProvider.select((s) => (s.waitingForOtp, s.socialLoading)),
    );
    final notifier = ref.read(batchExtractionProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final platform = job.platform.label;

    return _Padded(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: notifier.resetSocialImportState,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: const Text('Use another link'),
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        PaperSurface(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 32,
                color: tokens.stock.accent,
              ),
              const SizedBox(height: AppConstants.spacing12),
              Text(
                otp ? 'Enter your code' : 'Sign-in needed',
                style: text.headlineSmall,
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                otp
                    ? 'Your $platform account uses two-step sign-in. Enter the 6-digit code from your authenticator app.'
                    : 'This $platform profile is private or needs a sign-in to show its photos.',
                style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
              const _SocialError(),
              const SizedBox(height: AppConstants.spacing20),
              if (!otp) ...[
                ElevatedButton.icon(
                  onPressed: loading ? null : notifier.startSocialOAuthConnect,
                  icon: const Icon(Icons.open_in_new_rounded, size: 20),
                  label: Text('Connect with $platform'),
                ),
                if (job.platform == SocialPlatform.instagram)
                  TextButton(
                    onPressed: loading
                        ? null
                        : () => _manualLogin(context, ref),
                    child: const Text('Use username and password'),
                  ),
                TextButton(
                  onPressed: loading ? null : notifier.refreshSocialStatus,
                  child: const Text('I already connected in the browser'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: loading ? null : () => _otp(context, ref),
                  child: const Text('Enter code'),
                ),
                TextButton(
                  onPressed: loading ? null : notifier.cancelSocialOtp,
                  child: const Text('Try another way'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnectionLine extends ConsumerWidget {
  const _ConnectionLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(
      batchExtractionProvider.select((s) => s.socialConnected),
    );
    final tokens = PaperTokens.of(context);
    final color = live ? tokens.success : tokens.warning;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          live ? Icons.wifi_rounded : Icons.wifi_off_rounded,
          size: 16,
          color: color,
        ),
        const SizedBox(width: AppConstants.spacing4),
        Text(
          live ? 'Live' : 'Reconnecting',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _CancelImport extends ConsumerWidget {
  const _CancelImport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(
      batchExtractionProvider.select((s) => s.socialLoading),
    );
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: PaperTokens.of(context).error,
        ),
        onPressed: loading
            ? null
            : ref.read(batchExtractionProvider.notifier).cancelSocialImportJob,
        child: const Text('Cancel import'),
      ),
    );
  }
}

class _SocialDiscovering extends StatelessWidget {
  const _SocialDiscovering({required this.job});

  final SocialImportJobData job;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return _Padded(
      children: [
        PaperSurface(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Finding photos', style: text.headlineSmall),
                  ),
                  const _ConnectionLine(),
                ],
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                job.discoveredPhotos == 1
                    ? '1 photo found so far'
                    : '${job.discoveredPhotos} photos found so far',
                style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                job.normalizedUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: tokens.textMuted),
              ),
              const SizedBox(height: AppConstants.spacing16),
              LinearProgressIndicator(
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
                color: tokens.stock.accent,
                backgroundColor: tokens.stock.sunk,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        const _CancelImport(),
      ],
    );
  }
}

class _SocialProcessing extends ConsumerWidget {
  const _SocialProcessing({required this.job});

  final SocialImportJobData job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(
      batchExtractionProvider.select((s) => s.socialError),
    );
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    // A rate-limit pause resumes on its own: it reads as a pause, not a
    // failure, even though both carry a message.
    final paused = job.status == SocialImportJobStatus.pausedRateLimited;
    final awaiting = job.awaitingReviewPhoto;
    final processing = job.processingPhoto;
    final buffered = job.bufferedPhoto;

    return _Padded(
      children: [
        PaperSurface(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      paused ? 'Import paused' : 'Processing photos',
                      style: text.headlineSmall,
                    ),
                  ),
                  const _ConnectionLine(),
                ],
              ),
              const SizedBox(height: AppConstants.spacing12),
              PaperProgressTrack(
                value: job.totalPhotos > 0
                    ? job.processedPhotos / job.totalPhotos
                    : 0,
                semanticLabel: 'Photos processed',
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                '${job.processedPhotos} of ${job.totalPhotos} processed · '
                '${job.approvedPhotos} added · ${job.queuedCount} waiting · '
                '${job.rejectedPhotos} skipped',
                style: text.bodySmall?.copyWith(color: tokens.textSecondary),
              ),
              if (error.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing12),
                paused
                    ? _Notice(icon: Icons.hourglass_top_rounded, text: error)
                    : _Notice(
                        icon: Icons.error_outline_rounded,
                        text: error,
                        color: tokens.error,
                      ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        if (awaiting != null)
          _PhotoReview(photo: awaiting)
        else
          PaperSurface(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Row(
              children: [
                if (processing != null)
                  SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tokens.stock.accent,
                      strokeCap: StrokeCap.round,
                    ),
                  )
                else
                  Icon(Icons.schedule_rounded, color: tokens.textMuted),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: Text(
                    processing != null
                        ? 'Scanning photo ${processing.ordinal}'
                        : 'Waiting for the next photo',
                    style: text.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        if (buffered != null) ...[
          const SizedBox(height: AppConstants.spacing12),
          PaperSurface(
            lift: 0.6,
            padding: const EdgeInsets.all(AppConstants.spacing8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                  child: AppNetworkImage(
                    buffered.sourceThumbUrl ?? buffered.sourcePhotoUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    cacheWidth: 168,
                    errorWidget: (_, _, _) => SizedBox.square(
                      dimension: 56,
                      child: ColoredBox(color: tokens.stock.sunk),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: Text(
                    'Photo ${buffered.ordinal} is next',
                    style: text.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppConstants.spacing16),
        const _CancelImport(),
      ],
    );
  }
}

class _PhotoReview extends ConsumerWidget {
  const _PhotoReview({required this.photo});

  final SocialImportPhoto photo;

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    SocialImportItem item,
  ) async {
    final updates = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditSocialItemDialog(item: item),
    );
    if (updates == null) return;
    await ref
        .read(batchExtractionProvider.notifier)
        .patchSocialItem(photoId: photo.id, itemId: item.id, updates: updates);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(
      batchExtractionProvider.select((s) => s.socialLoading),
    );
    final notifier = ref.read(batchExtractionProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;

    return PaperSurface(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: AppNetworkImage(
              photo.sourceThumbUrl ?? photo.sourcePhotoUrl,
              fit: BoxFit.cover,
              cacheWidth: 1080,
              errorWidget: (_, _, _) => ColoredBox(
                color: tokens.stock.sunk,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: tokens.textMuted,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Photo ${photo.ordinal}', style: text.titleLarge),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  photo.items.isEmpty
                      ? 'No pieces found in this photo.'
                      : photo.items.length == 1
                      ? '1 piece found'
                      : '${photo.items.length} pieces found',
                  style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
                for (final item in photo.items)
                  Padding(
                    padding: const EdgeInsets.only(top: AppConstants.spacing8),
                    child: Row(
                      children: [
                        if ((item.generatedImageUrl ?? '').isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radius8,
                            ),
                            child: AppNetworkImage(
                              item.generatedImageUrl!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              cacheWidth: 168,
                              errorWidget: (_, _, _) => SizedBox.square(
                                dimension: 56,
                                child: ColoredBox(color: tokens.stock.sunk),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacing12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name ??
                                    item.subCategory ??
                                    item.category.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleSmall,
                              ),
                              Text(
                                [
                                  item.category.displayName,
                                  if (item.colors.isNotEmpty)
                                    item.colors.join(', '),
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodySmall?.copyWith(
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit piece',
                          onPressed: () => _edit(context, ref, item),
                          icon: Icon(
                            Icons.edit_outlined,
                            color: tokens.stock.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppConstants.spacing16),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : notifier.approveAwaitingSocialPhoto,
                  child: const Text('Add to closet'),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : notifier.rejectAwaitingSocialPhoto,
                  child: const Text('Skip this photo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialEnded extends ConsumerWidget {
  const _SocialEnded({required this.job});

  final SocialImportJobData job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(batchExtractionProvider.notifier);
    final completed = job.status == SocialImportJobStatus.completed;
    final failed = job.status == SocialImportJobStatus.failed;
    final message = (job.errorMessage ?? '').trim();

    return SingleChildScrollView(
      child: AppEmptyState(
        scene: completed ? PaperScenes.closet : PaperScenes.oops,
        title: completed
            ? 'Import complete'
            : failed
            ? 'Import failed'
            : 'Import cancelled',
        message: completed
            ? (job.approvedPhotos == 1
                  ? '1 photo was added to your closet.'
                  : '${job.approvedPhotos} photos were added to your closet.')
            : failed
            ? (message.isNotEmpty
                  ? message
                  : 'Something went wrong while importing.')
            : 'Nothing more is imported from this profile.',
        actionLabel: completed ? 'View closet' : 'Start over',
        onAction: completed
            ? () {
                notifier.resetSocialImportState();
                context.go(Routes.wardrobe);
              }
            : notifier.resetSocialImportState,
      ),
    );
  }
}

// Dialogs. Each owns its text controllers, so they are disposed with the
// dialog route, after its exit animation.

class _ManualLoginDialog extends StatefulWidget {
  const _ManualLoginDialog();

  @override
  State<_ManualLoginDialog> createState() => _ManualLoginDialogState();
}

class _ManualLoginDialogState extends State<_ManualLoginDialog> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _otp = TextEditingController();

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Sign in to Instagram'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _user,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _pass,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _otp,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Code, if you use two-step sign-in',
              counterText: '',
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, (
          user: _user.text.trim(),
          pass: _pass.text,
          otp: _otp.text.trim(),
        )),
        child: const Text('Sign in'),
      ),
    ],
  );
}

class _OtpDialog extends StatefulWidget {
  const _OtpDialog();

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Enter your code'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Use the 6-digit code from your authenticator app. Codes change quickly.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: PaperTokens.of(context).textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        TextField(
          controller: _code,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(letterSpacing: 8),
          decoration: const InputDecoration(
            counterText: '',
            hintText: '000000',
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ValueListenableBuilder(
        valueListenable: _code,
        builder: (context, value, _) => TextButton(
          onPressed: value.text.trim().length == 6
              ? () => Navigator.pop(context, value.text.trim())
              : null,
          child: const Text('Verify'),
        ),
      ),
    ],
  );
}

class _EditSocialItemDialog extends StatefulWidget {
  const _EditSocialItemDialog({required this.item});

  final SocialImportItem item;

  @override
  State<_EditSocialItemDialog> createState() => _EditSocialItemDialogState();
}

class _EditSocialItemDialogState extends State<_EditSocialItemDialog> {
  late final _name = TextEditingController(text: widget.item.name ?? '');
  late final _category = TextEditingController(
    text: widget.item.category.value,
  );
  late final _colors = TextEditingController(
    text: widget.item.colors.join(', '),
  );
  late final _material = TextEditingController(
    text: widget.item.material ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _colors.dispose();
    _material.dispose();
    super.dispose();
  }

  String? _value(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit piece'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _category,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _colors,
            decoration: const InputDecoration(
              labelText: 'Colours, separated by commas',
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _material,
            decoration: const InputDecoration(labelText: 'Material'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, <String, dynamic>{
          'name': _value(_name),
          'category': _value(_category),
          'colors': [
            for (final c in _colors.text.split(','))
              if (c.trim().isNotEmpty) c.trim(),
          ],
          'material': _value(_material),
        }),
        child: const Text('Save'),
      ),
    ],
  );
}
