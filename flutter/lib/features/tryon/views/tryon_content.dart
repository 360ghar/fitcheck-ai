import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/report_content_sheet.dart';
import '../../../core/utils/error_handler.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/repositories/item_repository.dart';
import '../controllers/tryon_controller.dart';

/// The single maintained try-on form, retained inside Studio.
class TryOnContent extends GetView<TryOnController> {
  const TryOnContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppUiTokens.of(context);
    return SingleChildScrollView(
      key: const PageStorageKey('try-on'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Obx(() {
        final busy =
            controller.isGenerating.value || controller.isLoading.value;
        final hasResult =
            controller.generatedImageUrl.isNotEmpty ||
            controller.generatedImageBase64.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Make it a look.', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Your photo. One garment. A fresh combination.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (controller.error.isNotEmpty) ...[
              AppErrorBanner(message: controller.error.value),
              const SizedBox(height: 12),
            ],
            _avatar(context, busy),
            const SizedBox(height: 16),
            _garment(context, busy),
            const SizedBox(height: 16),
            AppGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Set the scene', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _option(
                    'Style',
                    TryOnController.styles,
                    controller.selectedStyle,
                    busy,
                  ),
                  const SizedBox(height: 16),
                  _option(
                    'Background',
                    TryOnController.backgrounds,
                    controller.selectedBackground,
                    busy,
                  ),
                  const SizedBox(height: 16),
                  _option(
                    'Pose',
                    TryOnController.poses,
                    controller.selectedPose,
                    busy,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed:
                  busy ||
                      controller.isUploadingAvatar.value ||
                      !controller.isAvatarReady.value ||
                      controller.clothingImage.value == null
                  ? null
                  : controller.generateTryOn,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: controller.isGenerating.value
                  ? const InlineProcessingStatus(
                      phase: ProcessingPhase.processing,
                    )
                  : const Text('Generate try-on'),
            ),
            if (!controller.isAvatarReady.value ||
                controller.clothingImage.value == null) ...[
              const SizedBox(height: 8),
              Text(
                'Add your photo and one garment to continue.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            ],
            if (hasResult) ...[
              const SizedBox(height: 24),
              Text('Your new look', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              _result(context),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.downloadResult,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Save to photos'),
              ),
              TextButton.icon(
                onPressed: () => showReportContentSheet(
                  contentType: 'AI try-on image',
                  contentId: controller.generatedImageUrl.isNotEmpty
                      ? controller.generatedImageUrl.value
                      : 'tryon-result',
                ),
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Report image'),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _avatar(BuildContext context, bool busy) {
    final theme = Theme.of(context);
    final photo = controller.userAvatarUrl.value;
    final uploading = controller.isUploadingAvatar.value;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Your photo', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Choose a clear full-body photo with your outfit in view.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: busy || uploading ? null : controller.uploadUserAvatar,
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
          label: uploading
              ? const InlineProcessingStatus(phase: ProcessingPhase.uploading)
              : Text(photo.isEmpty ? 'Add photo' : 'Change photo'),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack =
            constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        final preview = ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: stack ? 1.4 : 0.72,
                  child: photo.isEmpty
                      ? Image.asset(
                          'assets/images/studio-example.webp',
                          fit: stack ? BoxFit.contain : BoxFit.cover,
                          semanticLabel:
                              'Example full-body photo, not a generated result',
                        )
                      : photo.startsWith('http')
                      ? AppNetworkImage(
                          photo,
                          fit: BoxFit.contain,
                          errorWidget: (_, _, _) =>
                              const Icon(Icons.person_outline),
                        )
                      : Image.file(
                          File(photo),
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.person_outline),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    photo.isEmpty ? 'Example photo' : 'Your photo',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [preview, const SizedBox(height: 16), content],
          );
        }
        return Row(
          children: [
            SizedBox(
              width: (constraints.maxWidth * 0.42).clamp(132, 240),
              child: preview,
            ),
            const SizedBox(width: 20),
            Expanded(child: content),
          ],
        );
      },
    );
  }

  Widget _garment(BuildContext context, bool busy) {
    final image = controller.clothingImage.value;
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose your garment',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (image != null) ...[
            Semantics(
              label: 'View selected garment',
              button: true,
              child: InkWell(
                onTap: () => _showLocalImage(context, FileImage(image)),
                child: Image.file(
                  image,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 120,
                    child: Center(
                      child: Text('Photo unavailable. Choose another garment.'),
                    ),
                  ),
                ),
              ),
            ),
            if (controller.selectedWardrobeItem.value != null) ...[
              const SizedBox(height: 8),
              Text(controller.selectedWardrobeItem.value!.name),
            ],
            TextButton.icon(
              onPressed: busy ? null : controller.removeCurrentImage,
              icon: const Icon(Icons.close),
              label: const Text('Remove garment'),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: busy ? null : () => _showWardrobePicker(context),
            icon: const Icon(Icons.checkroom_outlined),
            label: const Text('Choose from closet'),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: [
              TextButton.icon(
                onPressed: busy ? null : controller.pickClothingImage,
                icon: const Icon(Icons.photo_library_outlined, size: 20),
                label: const Text('Photos'),
              ),
              TextButton.icon(
                onPressed: busy ? null : controller.pickClothingFromCamera,
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: const Text('Camera'),
              ),
            ],
          ),
          if (controller.isLoading.value) ...[
            const SizedBox(height: 12),
            const InlineProcessingStatus(
              phase: ProcessingPhase.processing,
              processingLabel: 'Preparing garment',
            ),
          ],
        ],
      ),
    );
  }

  Widget _option(
    String label,
    List<String> options,
    RxString selected,
    bool disabled,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label:${selected.value}'),
      initialValue: selected.value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option,
            child: Text('${option[0].toUpperCase()}${option.substring(1)}'),
          ),
      ],
      onChanged: disabled
          ? null
          : (value) {
              if (value != null) selected.value = value;
            },
    );
  }

  Widget _result(BuildContext context) {
    final url = controller.generatedImageUrl.value;
    if (url.isNotEmpty) {
      return AppImage(
        imageUrl: url,
        fit: BoxFit.contain,
        semanticLabel: 'Your generated try-on',
        borderRadius: BorderRadius.circular(16),
      );
    }
    try {
      final image = MemoryImage(
        base64Decode(controller.generatedImageBase64.value.split(',').last),
      );
      return Semantics(
        label: 'View generated try-on',
        button: true,
        child: InkWell(
          onTap: () => _showLocalImage(context, image),
          child: Image(
            image: image,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Text(
              'This result could not be displayed. Generate it again.',
            ),
          ),
        ),
      );
    } on FormatException {
      return const Text(
        'This result could not be displayed. Generate it again.',
      );
    }
  }

  void _showWardrobePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: _WardrobePickerSheet(controller: controller),
        ),
      ),
    );
  }
}

/// Local images use the same native full-screen route for both input and result.
void _showLocalImage(BuildContext context, ImageProvider image) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Photo'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: PhotoView(
            imageProvider: image,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            errorBuilder: (_, _, _) => const Center(
              child: Text(
                'Photo unavailable',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _WardrobePickerSheet extends StatefulWidget {
  const _WardrobePickerSheet({required this.controller});
  final TryOnController controller;

  @override
  State<_WardrobePickerSheet> createState() => _WardrobePickerSheetState();
}

class _WardrobePickerSheetState extends State<_WardrobePickerSheet> {
  final _repository = ItemRepository();
  final _items = <ItemModel>[];
  Timer? _searchTimer;
  String _query = '';
  String _error = '';
  int _page = 1;
  int _request = 0;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadItems({bool refresh = false}) async {
    if (!refresh && (_loading || !_hasMore)) return;
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = '';
      if (refresh) {
        _page = 1;
        _hasMore = true;
        _items.clear();
      }
    });
    try {
      final response = await _repository.getItems(
        page: _page,
        limit: 20,
        search: _query,
      );
      if (!mounted || request != _request) return;
      setState(() {
        _items.addAll(response.items);
        _hasMore = response.hasMore;
        _page++;
      });
    } catch (error) {
      if (mounted && request == _request) {
        setState(() => _error = ErrorHandler.extractMessage(error));
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Future<void> _select(ItemModel item) async {
    final selected = await widget.controller.pickClothingFromWardrobe(item);
    if (!mounted) return;
    if (selected) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = widget.controller.error.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Choose one garment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close closet',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search closet',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _query = value.trim();
                _searchTimer?.cancel();
                _searchTimer = Timer(
                  AppConstants.searchDebounceDuration,
                  () => _loadItems(refresh: true),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => widget.controller.isLoading.value
                ? const LinearProgressIndicator()
                : const SizedBox.shrink(),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(_error),
                  TextButton(
                    onPressed: () => _loadItems(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _loading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? const Center(child: Text('No garments found.'))
                : InfiniteScrollWrapper(
                    onLoadMore: _loadItems,
                    hasMore: _hasMore && _error.isEmpty,
                    isLoadingMore: _loading,
                    child: ListView.builder(
                      itemCount: _items.length + (_loading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _items.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final item = _items[index];
                        final photo = item.itemImages?.firstOrNull;
                        return Obx(
                          () => ListTile(
                            selected:
                                widget
                                    .controller
                                    .selectedWardrobeItem
                                    .value
                                    ?.id ==
                                item.id,
                            enabled: !widget.controller.isLoading.value,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: SizedBox(
                              width: 48,
                              height: 64,
                              child: photo == null
                                  ? const Icon(Icons.checkroom_outlined)
                                  : AppImage(
                                      imageUrl: photo.url,
                                      fallbackUrl: photo.url,
                                      storagePath: photo.storagePath,
                                      remintUrl: _repository.remintImageUrl,
                                      enableZoom: false,
                                    ),
                            ),
                            title: Text(item.name),
                            subtitle: Text(item.category.displayName),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _select(item),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
