import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/request_id.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../models/item_model.dart';
import '../providers/wardrobe_providers.dart';

/// Use-case tags: the defaults plus any custom ones, and a field to add one.
class UseCasePicker extends StatefulWidget {
  const UseCasePicker({
    super.key,
    required this.selected,
    required this.onToggle,
    this.helper,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final String? helper;

  @override
  State<UseCasePicker> createState() => _UseCasePickerState();
}

class _UseCasePickerState extends State<UseCasePicker> {
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _add() {
    final value = UseCases.normalize(_custom.text);
    if (value.isEmpty) return;
    if (!widget.selected.contains(value)) widget.onToggle(value);
    _custom.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Use cases', style: text.titleSmall),
        if (widget.helper != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.helper!,
            style: text.bodySmall?.copyWith(color: tokens.textSecondary),
          ),
        ],
        const SizedBox(height: AppConstants.spacing8),
        Wrap(
          spacing: AppConstants.spacing8,
          runSpacing: AppConstants.spacing8,
          children: [
            for (final useCase in {...UseCases.defaults, ...widget.selected})
              FilterChip(
                label: Text(UseCases.displayLabel(useCase)),
                selected: widget.selected.contains(useCase),
                onSelected: (_) => widget.onToggle(useCase),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        TextField(
          controller: _custom,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _add(),
          decoration: InputDecoration(
            labelText: 'Add a use case',
            hintText: 'For example, brunch',
            suffixIcon: IconButton(
              tooltip: 'Add use case',
              icon: const Icon(Icons.add_rounded),
              onPressed: _add,
            ),
          ),
        ),
      ],
    );
  }
}

/// The add-details form, shown in the add page body. With [image] (a photo
/// from the add session) the piece is saved with it; more photos can be
/// added. Closes the add page after a save.
class ManualEntryForm extends ConsumerStatefulWidget {
  const ManualEntryForm({super.key, this.image});

  final File? image;

  @override
  ConsumerState<ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends ConsumerState<ManualEntryForm> {
  static const _commonColors = [
    'Black', 'White', 'Gray', 'Red', 'Blue', 'Green', 'Yellow', //
    'Pink', 'Purple', 'Orange', 'Brown', 'Beige', 'Navy', 'Cream',
  ];
  static const _imageExtensions = {
    'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif', 'bmp', 'tif', 'tiff', //
  };

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _brand = TextEditingController();
  final _size = TextEditingController();
  final _material = TextEditingController();
  final _pattern = TextEditingController();
  final _price = TextEditingController();
  final _location = TextEditingController();

  Category _category = Category.tops;
  domain.Condition _condition = domain.Condition.clean;
  final Set<String> _colors = {};
  final Set<String> _useCases = {};
  final List<File> _extraImages = [];
  bool _saving = false;

  /// Idempotency key for this form's create (TD-109): reused by every retry
  /// of the same draft, minted again when the draft changes.
  String? _requestId;
  String? _requestPayload;

  @override
  void dispose() {
    for (final c in [
      _name, _description, _brand, _size, _material, _pattern, _price, //
      _location,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _text(TextEditingController c) {
    final value = c.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _addPhotos() async {
    final picked = await _picker.pickMultipleMedia(imageQuality: 85);
    if (!mounted) return;
    final images = [
      for (final f in picked)
        if (_imageExtensions.contains(f.path.split('.').last.toLowerCase()))
          File(f.path),
    ];
    if (images.isNotEmpty) setState(() => _extraImages.addAll(images));
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repository = ref.read(itemRepositoryProvider);
    // Captured before the awaits: backing out of this form disposes its ref,
    // and a post-await ref access would throw after the item was created.
    final wardrobe = ref.exists(wardrobeProvider)
        ? ref.read(wardrobeProvider.notifier)
        : null;
    final main = widget.image ?? _extraImages.firstOrNull;
    final request = CreateItemRequest(
      name: _name.text.trim(),
      description: _text(_description),
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
    );
    final payload = request.toJson().toString();
    if (_requestId == null || _requestPayload != payload) {
      _requestId = newRequestId('item');
      _requestPayload = payload;
    }
    try {
      // A piece without a photo is allowed: the backend supports it.
      final created = main == null
          ? await repository.createItem(request, clientRequestId: _requestId)
          : await repository.createItemWithImage(
              image: main,
              request: request,
              clientRequestId: _requestId,
            );
      final extra = widget.image == null ? _extraImages.skip(1) : _extraImages;
      for (final image in extra) {
        try {
          await repository.uploadImages(created.id, [image]);
        } catch (e, stack) {
          ErrorHandler.reportError(
            e,
            'Extra photo upload failed',
            stackTrace: stack,
          );
        }
      }
      wardrobe?.addItems([created]);
      _requestId = null;
      _requestPayload = null;
      ErrorHandler.showSuccess(
        '${created.name} is in your closet.',
        title: 'Saved',
      );
      if (mounted) Navigator.pop(context);
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const gap = SizedBox(height: AppConstants.spacing16);
    final photos = [?widget.image, ..._extraImages];

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing16,
                AppConstants.spacing8,
                AppConstants.spacing16,
                AppConstants.spacing24,
              ),
              children: [
                Text(
                  'Only a name is needed. Add the rest now or later.',
                  style: text.bodyMedium?.copyWith(
                    color: PaperTokens.of(context).textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing20),
                _Photos(
                  photos: photos,
                  fixedCount: widget.image == null ? 0 : 1,
                  onAdd: _addPhotos,
                  onRemove: (i) => setState(() => _extraImages.removeAt(i)),
                ),
                const SizedBox(height: AppConstants.spacing24),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'For example, blue cotton tee',
                  ),
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
                  onChanged: (v) =>
                      setState(() => _condition = v ?? _condition),
                ),
                gap,
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: AppConstants.spacing20),
                Text('Colours', style: text.titleSmall),
                const SizedBox(height: AppConstants.spacing8),
                Wrap(
                  spacing: AppConstants.spacing8,
                  runSpacing: AppConstants.spacing8,
                  children: [
                    for (final color in _commonColors)
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
                UseCasePicker(
                  selected: _useCases,
                  onToggle: (value) => setState(
                    () => _useCases.contains(value)
                        ? _useCases.remove(value)
                        : _useCases.add(value),
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
                        decoration: const InputDecoration(
                          labelText: 'Material',
                        ),
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
              ],
            ),
          ),
          _BottomAction(
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving' : 'Save piece'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Photos extends StatelessWidget {
  const _Photos({
    required this.photos,
    required this.fixedCount,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> photos;

  /// Leading photos that cannot be removed here (the add-session photo).
  final int fixedCount;
  final VoidCallback onAdd;

  /// Index into the removable photos.
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Photos', style: text.titleSmall)),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
              label: const Text('Add photos'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        if (photos.isEmpty)
          PaperSurface(
            lift: 0,
            color: tokens.stock.sunk,
            child: Text(
              'No photo yet. You can save without one.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          )
        else
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppConstants.spacing8),
              itemBuilder: (context, i) => SizedBox.square(
                dimension: 104,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                      child: ColoredBox(
                        color: tokens.stock.sunk,
                        child: Image.file(
                          photos[i],
                          fit: BoxFit.cover,
                          cacheWidth: 312,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.image_not_supported_outlined,
                            color: tokens.textMuted,
                          ),
                        ),
                      ),
                    ),
                    if (i >= fixedCount)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          tooltip: 'Remove photo',
                          onPressed: () => onRemove(i - fixedCount),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A full-width action pinned under a scrolling page body.
class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => PaperActionBar(
    child: SizedBox(width: double.infinity, child: child),
  );
}
