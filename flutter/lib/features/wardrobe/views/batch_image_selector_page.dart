import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/directional_icon.dart';
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
      ErrorHandler.showValidation(
        rejected,
        title: ErrorHandler.l10n?.wardrobeSomePhotosSkipped ?? 'Some photos skipped',
      );
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
        ErrorHandler.showError(
          e,
          title: ErrorHandler.l10n?.wardrobePhotosNotAdded ?? 'Photos not added',
        );
      }
    } catch (e, stack) {
      ErrorHandler.showError(
        e,
        title: ErrorHandler.l10n?.wardrobePhotosNotAdded ?? 'Photos not added',
        stackTrace: stack,
      );
    }
  }

  Future<void> _pickCamera() async {
    if (ref.read(batchExtractionProvider).remainingSlots <= 0) {
      ErrorHandler.showValidation(
        ErrorHandler.l10n?.photoshootPhotoLimit(
              BatchExtractionNotifier.maxImages,
            ) ??
            'You can add up to ${BatchExtractionNotifier.maxImages} photos.',
        title: ErrorHandler.l10n?.wardrobeNoRoomTitle ?? 'No room',
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
        ErrorHandler.showError(
          e,
          title: ErrorHandler.l10n?.wardrobePhotoNotAdded ?? 'Photo not added',
        );
      }
    } catch (e, stack) {
      ErrorHandler.showError(
        e,
        title: ErrorHandler.l10n?.wardrobePhotoNotAdded ?? 'Photo not added',
        stackTrace: stack,
      );
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
            title: Text(context.l10n.itemAddGallery),
            onTap: () {
              Navigator.pop(context);
              _pickGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(context.l10n.itemAddCamera),
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
      ErrorHandler.showError(
        s.error,
        title: ErrorHandler.l10n?.wardrobeNotStartedTitle ?? 'Not started',
      );
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
          title: Text(
            social
                ? context.l10n.wardrobeImportFromProfileTitle
                : context.l10n.wardrobeAddSeveralPhotosTitle,
          ),
          actions: [
            if (!social && count > 0)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: AppConstants.spacing8),
                child: TextButton(
                  onPressed: busy ? null : _notifier.clearAllImages,
                  child: Text(context.l10n.wardrobeClearAction),
                ),
              ),
            if (social && hasSocialJob)
              IconButton(
                tooltip: context.l10n.wardrobeRefreshTooltip,
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
                      segments: [
                        ButtonSegment(
                          value: BatchInputMode.upload,
                          label: Text(context.l10n.itemPhotos),
                          icon: const Icon(Icons.collections_outlined),
                        ),
                        ButtonSegment(
                          value: BatchInputMode.social,
                          label: Text(context.l10n.batchProfileLinkLabel),
                          icon: const Icon(Icons.link_rounded),
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
                            title: context.l10n.batchNoPhotosYetTitle,
                            message:
                                context.l10n.batchPickUpToBody(
                                  BatchExtractionNotifier.maxImages,
                                ),
                            actionLabel: context.l10n.batchChoosePhotosAction,
                            actionIcon: Icons.photo_library_outlined,
                            onAction: _pickGallery,
                            secondary: TextButton.icon(
                              onPressed: _pickCamera,
                              icon: const Icon(
                                Icons.photo_camera_outlined,
                                size: 20,
                              ),
                              label: Text(context.l10n.itemAddCamera),
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
              context.l10n.batchPhotoCounter(
                images.length,
                BatchExtractionNotifier.maxImages,
              ),
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
                  semanticLabel: context.l10n.wardrobeAddPhotosSemantic,
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
                        Text(
                          context.l10n.batchAddTileLabel,
                          style: text.labelMedium,
                        ),
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
                semanticLabel: context.l10n.batchPreparingPhotosSemantic,
              ),
              const SizedBox(height: AppConstants.spacing8),
            ] else ...[
              Text(
                context.l10n.batchWeFindEachPieceBody,
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
                    ? context.l10n.batchPreparingPhotoBody(
                        done.clamp(1, count),
                        count,
                      )
                    : context.l10n.batchFindPiecesInPhotos(count),
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
              Text(
                context.l10n.batchPasteProfileLinkTitle,
                style: text.headlineSmall,
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                context.l10n.batchPasteProfileLinkBody,
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
                  labelText: context.l10n.batchProfileLinkLabel,
                  hintText: 'https://instagram.com/username',
                  errorText: urlError.isEmpty ? null : urlError,
                  suffixIcon: ValueListenableBuilder(
                    valueListenable: _url,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: context.l10n.batchClearLinkTooltip,
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
                child: Text(
                  loading
                      ? context.l10n.batchStartingButton
                      : context.l10n.batchStartImportAction,
                ),
              ),
              const _SocialError(),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        _HowItWorks(
          icon: Icons.fact_check_outlined,
          title: context.l10n.batchReviewEveryPhotoTitle,
          body: context.l10n.batchReviewEveryPhotoBody,
        ),
        _HowItWorks(
          icon: Icons.lock_outline_rounded,
          title: context.l10n.batchPrivateProfilesTitle,
          body: context.l10n.batchPrivateProfilesBody,
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
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: notifier.resetSocialImportState,
            icon: const DirectionalIcon(Icons.arrow_back_rounded, size: 20),
            label: Text(context.l10n.batchUseAnotherLinkAction),
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
                otp
                    ? context.l10n.batchEnterYourCodeTitle
                    : context.l10n.batchSignInNeededTitle,
                style: text.headlineSmall,
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                otp
                    ? context.l10n.batchTwoStepSignInBody(platform)
                    : context.l10n.batchPrivateProfileBody(platform),
                style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
              const _SocialError(),
              const SizedBox(height: AppConstants.spacing20),
              if (!otp) ...[
                ElevatedButton.icon(
                  onPressed: loading ? null : notifier.startSocialOAuthConnect,
                  icon: const Icon(Icons.open_in_new_rounded, size: 20),
                  label: Text(context.l10n.batchConnectWithPlatform(platform)),
                ),
                if (job.platform == SocialPlatform.instagram)
                  TextButton(
                    onPressed: loading
                        ? null
                        : () => _manualLogin(context, ref),
                    child: Text(
                      context.l10n.batchUseUsernamePasswordAction,
                    ),
                  ),
                TextButton(
                  onPressed: loading ? null : notifier.refreshSocialStatus,
                  child: Text(context.l10n.batchAlreadyConnectedAction),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: loading ? null : () => _otp(context, ref),
                  child: Text(context.l10n.batchEnterCodeAction),
                ),
                TextButton(
                  onPressed: loading ? null : notifier.cancelSocialOtp,
                  child: Text(context.l10n.batchTryAnotherWayAction),
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
          live
              ? context.l10n.batchLiveStatus
              : context.l10n.batchReconnectingStatus,
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
        child: Text(context.l10n.batchCancelImportAction),
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
                    child: Text(
                      context.l10n.batchFindingPhotosTitle,
                      style: text.headlineSmall,
                    ),
                  ),
                  const _ConnectionLine(),
                ],
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                context.l10n.batchPhotosFoundSoFar(job.discoveredPhotos),
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
                      paused
                          ? context.l10n.batchImportPausedTitle
                          : context.l10n.batchProcessingPhotosTitle,
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
                semanticLabel: context.l10n.batchPhotosProcessedSemantic,
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                context.l10n.batchImportStatusLine(
                  job.processedPhotos,
                  job.totalPhotos,
                  job.approvedPhotos,
                  job.queuedCount,
                  job.rejectedPhotos,
                ),
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
                        ? context.l10n.batchScanningPhoto(processing.ordinal)
                        : context.l10n.batchWaitingNextPhoto,
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
                    context.l10n.batchPhotoIsNext(buffered.ordinal),
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
                Text(
                  context.l10n.batchPhotoLabel(photo.ordinal),
                  style: text.titleLarge,
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  photo.items.isEmpty
                      ? context.l10n.batchNoPiecesInPhotoBody
                      : context.l10n.batchPiecesFound(photo.items.length),
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
                          tooltip: context.l10n.itemEditPieceTitle,
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
                  child: Text(context.l10n.batchAddToClosetAction),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : notifier.rejectAwaitingSocialPhoto,
                  child: Text(context.l10n.batchSkipPhotoAction),
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
            ? context.l10n.batchImportCompleteTitle
            : failed
            ? context.l10n.batchImportFailedTitle
            : context.l10n.batchImportCancelledTitle,
        message: completed
            ? context.l10n.batchPhotosAddedBody(job.approvedPhotos)
            : failed
            ? (message.isNotEmpty
                  ? message
                  : context.l10n.batchImportErrorBody)
            : context.l10n.batchNothingMoreImportedBody,
        actionLabel: completed
            ? context.l10n.batchViewClosetAction
            : context.l10n.batchStartOverAction,
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
    title: Text(context.l10n.batchSignInToInstagramTitle),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _user,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: context.l10n.batchUsernameLabel,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _pass,
            obscureText: true,
            decoration: InputDecoration(
              labelText: context.l10n.authPassword,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _otp,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: context.l10n.batchCodeIfTwoStepLabel,
              counterText: '',
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.actionCancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, (
          user: _user.text.trim(),
          pass: _pass.text,
          otp: _otp.text.trim(),
        )),
        child: Text(context.l10n.authSignIn),
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
    title: Text(context.l10n.batchEnterYourCodeTitle),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.batchAuthenticatorCodeBody,
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
        child: Text(context.l10n.actionCancel),
      ),
      ValueListenableBuilder(
        valueListenable: _code,
        builder: (context, value, _) => TextButton(
          onPressed: value.text.trim().length == 6
              ? () => Navigator.pop(context, value.text.trim())
              : null,
          child: Text(context.l10n.batchVerifyAction),
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
    title: Text(context.l10n.itemEditPieceTitle),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: context.l10n.authName,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _category,
            decoration: InputDecoration(
              labelText: context.l10n.closetCategoryLabel,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _colors,
            decoration: InputDecoration(
              labelText: context.l10n.batchEditPieceColoursLabel,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _material,
            decoration: InputDecoration(
              labelText: context.l10n.itemMaterial,
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.actionCancel),
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
        child: Text(context.l10n.actionSave),
      ),
    ],
  );
}
