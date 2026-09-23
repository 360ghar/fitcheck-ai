import 'dart:io';

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../models/item_model.dart';
import '../providers/wardrobe_providers.dart';

/// Edits one closet piece. Loads the item first when it is not cached (deep
/// link, or edit tapped before the list loaded).
class ItemEditPage extends ConsumerWidget {
  const ItemEditPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(itemDetailProvider(itemId));
    final cached = ref.read(wardrobeProvider.notifier).cached(itemId);
    final item = detail.value ?? cached;

    return PaperStockScope(
      stock: PaperStockId.moss,
      child: item != null
          ? _EditForm(item: item)
          : Scaffold(
              appBar: AppBar(title: const Text('Edit piece')),
              body: AppPageBackground(
                child: detail.hasError
                    ? AppErrorState(
                        error: detail.error,
                        onRetry: ref
                            .read(itemDetailProvider(itemId).notifier)
                            .refresh,
                      )
                    : const SkeletonListLoaderBox(itemCount: 6),
              ),
            ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.item});

  final ItemModel item;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  static const _commonColors = [
    'Black', 'White', 'Gray', 'Red', 'Blue', 'Green', 'Yellow', //
    'Pink', 'Purple', 'Orange', 'Brown', 'Beige', 'Navy', 'Cream',
  ];

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final _name = TextEditingController(text: widget.item.name);
  late final _description = TextEditingController(
    text: widget.item.description ?? '',
  );
  late final _brand = TextEditingController(text: widget.item.brand ?? '');
  late final _size = TextEditingController(text: widget.item.size ?? '');
  late final _material = TextEditingController(
    text: widget.item.material ?? '',
  );
  late final _pattern = TextEditingController(text: widget.item.pattern ?? '');
  late final _price = TextEditingController(
    text: widget.item.price?.toString() ?? '',
  );
  late final _location = TextEditingController(
    text: widget.item.location ?? '',
  );
  final _customUseCase = TextEditingController();

  late Category _category = widget.item.category;
  late domain.Condition _condition = widget.item.condition;
  late final Set<String> _colors = {...?widget.item.colors};
  late final Set<String> _useCases = UseCases.normalizeList(
    widget.item.occasionTags,
  ).toSet();
  final List<File> _newImages = [];
  final Set<String> _imagesToDelete = {};
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _name, _description, _brand, _size, _material, _pattern, _price, //
      _location, _customUseCase,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _EditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prev = oldWidget.item;
    final next = widget.item;
    if (next.id != prev.id) {
      // Never carry one piece's pending edits into another's form.
      _newImages.clear();
      _imagesToDelete.clear();
    }
    // Fresh detail arrives after the cached copy the form started from.
    // Sync only fields the user has not edited, so Save cannot overwrite
    // newer server values with stale ones nor clobber in-progress edits.
    void sync(TextEditingController c, String was, String now) {
      if (c.text == was) c.text = now;
    }

    sync(_name, prev.name, next.name);
    sync(_description, prev.description ?? '', next.description ?? '');
    sync(_brand, prev.brand ?? '', next.brand ?? '');
    sync(_size, prev.size ?? '', next.size ?? '');
    sync(_material, prev.material ?? '', next.material ?? '');
    sync(_pattern, prev.pattern ?? '', next.pattern ?? '');
    sync(_price, prev.price?.toString() ?? '', next.price?.toString() ?? '');
    sync(_location, prev.location ?? '', next.location ?? '');
    if (_category == prev.category) _category = next.category;
    if (_condition == prev.condition) _condition = next.condition;
    if (setEquals(_colors, {...?prev.colors})) {
      _colors
        ..clear()
        ..addAll(next.colors ?? const <String>[]);
    }
    if (setEquals(_useCases, UseCases.normalizeList(prev.occasionTags).toSet())) {
      _useCases
        ..clear()
        ..addAll(UseCases.normalizeList(next.occasionTags));
    }
  }

  String? _text(TextEditingController c) {
    final value = c.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _pickFromGallery() async {
    final images = await _picker.pickMultiImage(imageQuality: 85, limit: 6);
    if (images.isEmpty || !mounted) return;
    setState(() => _newImages.addAll([for (final i in images) File(i.path)]));
  }

  Future<void> _takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() => _newImages.add(File(image.path)));
  }

  void _addCustomUseCase() {
    final value = UseCases.normalize(_customUseCase.text);
    if (value.isEmpty) return;
    setState(() => _useCases.add(value));
    _customUseCase.clear();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repository = ref.read(itemRepositoryProvider);
    final id = widget.item.id;
    try {
      await repository.updateItem(
        id,
        UpdateItemRequest(
          name: _name.text.trim(),
          description: _text(_description),
          // Always sent: the backend applies only fields that are present.
          category: _category,
          colors: _colors.isEmpty ? null : _colors.toList(),
          brand: _text(_brand),
          size: _text(_size),
          material: _text(_material),
          pattern: _text(_pattern),
          condition: _condition,
          price: double.tryParse(_price.text.trim()),
          location: _text(_location),
          occasionTags: _useCases.isEmpty
              ? null
              : UseCases.normalizeList(_useCases),
        ),
      );
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      if (mounted) setState(() => _saving = false);
      return;
    }
    // The edit itself is committed. Anything from here is best-effort: a
    // failure must not report "Not saved" and invite a retry that would
    // re-run the already-applied image deletions.
    try {
      for (final imageId in _imagesToDelete) {
        await repository.deleteItemImage(id, imageId);
      }
      if (_newImages.isNotEmpty) {
        await repository.uploadImages(id, _newImages);
      }
      // One fetch picks up the new fields and fresh image URLs.
      final fresh = await repository.getItem(id);
      if (mounted) {
        ref.read(wardrobeProvider.notifier).replace(fresh);
      }
    } catch (e, stack) {
      if (mounted) {
        ErrorHandler.showError(
          e,
          title: 'Saved — photos may be out of date',
          stackTrace: stack,
        );
        Navigator.pop(context);
      }
      return;
    }
    if (!mounted) return;
    ErrorHandler.showSuccess('Your changes are saved.', title: 'Saved');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    const gap = SizedBox(height: AppConstants.spacing16);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit piece'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacing8),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const InlineProcessingStatus(
                      phase: ProcessingPhase.processing,
                      processingLabel: 'Saving',
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: AppPageBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            children: [
              _PhotoStrip(
                existing: widget.item.itemImages ?? const [],
                toDelete: _imagesToDelete,
                added: _newImages,
                onToggleDelete: (id) => setState(
                  () => _imagesToDelete.contains(id)
                      ? _imagesToDelete.remove(id)
                      : _imagesToDelete.add(id),
                ),
                onRemoveAdded: (i) => setState(() => _newImages.removeAt(i)),
                onGallery: _pickFromGallery,
                onCamera: _takePhoto,
              ),
              const SizedBox(height: AppConstants.spacing24),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              gap,
              DropdownButtonFormField<Category>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in Category.values)
                    DropdownMenuItem(value: c, child: Text(c.displayName)),
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              gap,
              DropdownButtonFormField<domain.Condition>(
                initialValue: _condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: [
                  for (final c in domain.Condition.values)
                    DropdownMenuItem(value: c, child: Text(c.displayName)),
                ],
                onChanged: (v) => setState(() => _condition = v ?? _condition),
              ),
              gap,
              TextFormField(
                controller: _description,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: AppConstants.spacing20),
              Text('Colours', style: text.titleSmall),
              const SizedBox(height: AppConstants.spacing8),
              Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: [
                  for (final color in {..._commonColors, ..._colors})
                    FilterChip(
                      label: Text(color),
                      selected: _colors.contains(color),
                      onSelected: (on) => setState(
                        () => on ? _colors.add(color) : _colors.remove(color),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing20),
              Text('Use cases', style: text.titleSmall),
              const SizedBox(height: AppConstants.spacing8),
              Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: [
                  for (final useCase in {...UseCases.defaults, ..._useCases})
                    FilterChip(
                      label: Text(UseCases.displayLabel(useCase)),
                      selected: _useCases.contains(useCase),
                      onSelected: (on) => setState(
                        () => on
                            ? _useCases.add(useCase)
                            : _useCases.remove(useCase),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing8),
              TextField(
                controller: _customUseCase,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addCustomUseCase(),
                decoration: InputDecoration(
                  labelText: 'Add a use case',
                  hintText: 'For example, brunch',
                  suffixIcon: IconButton(
                    tooltip: 'Add',
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _addCustomUseCase,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brand,
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: TextFormField(
                      controller: _size,
                      decoration: const InputDecoration(labelText: 'Size'),
                    ),
                  ),
                ],
              ),
              gap,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _material,
                      decoration: const InputDecoration(labelText: 'Material'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: TextFormField(
                      controller: _pattern,
                      decoration: const InputDecoration(labelText: 'Pattern'),
                    ),
                  ),
                ],
              ),
              gap,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Price'),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return null;
                        return double.tryParse(value) == null
                            ? 'Enter a number'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: TextFormField(
                      controller: _location,
                      decoration: const InputDecoration(labelText: 'Kept in'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing32),
              Text(
                'Delete this piece from the item page.',
                style: text.bodySmall?.copyWith(color: tokens.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoStrip extends ConsumerWidget {
  const _PhotoStrip({
    required this.existing,
    required this.toDelete,
    required this.added,
    required this.onToggleDelete,
    required this.onRemoveAdded,
    required this.onGallery,
    required this.onCamera,
  });

  final List<ItemImage> existing;
  final Set<String> toDelete;
  final List<File> added;
  final void Function(String id) onToggleDelete;
  final void Function(int index) onRemoveAdded;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final remint = ref.read(itemRepositoryProvider).remintImageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Photos', style: text.titleSmall)),
            TextButton.icon(
              onPressed: onGallery,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Gallery'),
            ),
            TextButton.icon(
              onPressed: onCamera,
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: const Text('Camera'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        if (existing.isEmpty && added.isEmpty)
          PaperSurface(
            lift: 0,
            color: tokens.stock.sunk,
            child: Text(
              'No photos yet. Add one from your gallery or camera.',
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          )
        else
          SizedBox(
            height: 112,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final image in existing)
                  _Thumb(
                    removed: toDelete.contains(image.id),
                    actionTooltip: toDelete.contains(image.id)
                        ? 'Keep photo'
                        : 'Remove photo',
                    actionIcon: toDelete.contains(image.id)
                        ? Icons.undo_rounded
                        : Icons.close_rounded,
                    onAction: () => onToggleDelete(image.id),
                    child: AppImage(
                      imageUrl: image.url,
                      fit: BoxFit.cover,
                      enableZoom: false,
                      memCacheWidth: 300,
                      storagePath: image.storagePath,
                      remintUrl: remint,
                    ),
                  ),
                for (final (i, file) in added.indexed)
                  _Thumb(
                    label: 'New',
                    actionTooltip: 'Remove photo',
                    actionIcon: Icons.close_rounded,
                    onAction: () => onRemoveAdded(i),
                    child: Image.file(file, fit: BoxFit.cover, cacheWidth: 300),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.child,
    required this.actionIcon,
    required this.actionTooltip,
    required this.onAction,
    this.removed = false,
    this.label,
  });

  final Widget child;
  final IconData actionIcon;
  final String actionTooltip;
  final VoidCallback onAction;
  final bool removed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.spacing8),
      child: SizedBox.square(
        dimension: 104,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius8),
              child: ColoredBox(
                color: tokens.stock.sunk,
                child: removed
                    ? Center(
                        child: Text(
                          'Removed',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      )
                    : child,
              ),
            ),
            if (label != null)
              Positioned(
                left: AppConstants.spacing6,
                bottom: AppConstants.spacing6,
                child: Text(
                  label!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    shadows: const [Shadow(blurRadius: 3)],
                  ),
                ),
              ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: actionTooltip,
                onPressed: onAction,
                style: IconButton.styleFrom(
                  backgroundColor: tokens.stock.card,
                  minimumSize: const Size(44, 44),
                ),
                icon: Icon(actionIcon, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
