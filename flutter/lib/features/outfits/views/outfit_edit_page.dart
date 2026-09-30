import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/season.dart';
import '../../../domain/enums/style.dart';
import '../models/outfit_model.dart';
import '../providers/outfit_providers.dart';

/// Edits one outfit's details and photos.
class OutfitEditPage extends ConsumerWidget {
  const OutfitEditPage({super.key, required this.outfitId});

  final String outfitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(outfitDetailProvider(outfitId));
    final outfit =
        detail.value ?? ref.read(outfitsProvider.notifier).cached(outfitId);

    return PaperStockScope(
      stock: PaperStockId.marigold,
      child: outfit != null
          ? _EditForm(outfit: outfit)
          : Scaffold(
              appBar: AppBar(title: const Text('Edit outfit')),
              body: AppPageBackground(
                child: detail.hasError
                    ? AppErrorState(
                        error: detail.error,
                        onRetry: ref
                            .read(outfitDetailProvider(outfitId).notifier)
                            .refresh,
                      )
                    : const SkeletonListLoaderBox(itemCount: 6),
              ),
            ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.outfit});

  final OutfitModel outfit;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  static const _occasions = [
    'casual', 'formal', 'business', 'sporty', 'date night', //
    'party', 'wedding', 'interview', 'weekend', 'travel',
  ];

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.outfit.name);
  late final _description = TextEditingController(
    text: widget.outfit.description ?? '',
  );
  late final _tags = TextEditingController(
    text: widget.outfit.tags?.join(', ') ?? '',
  );
  late Style? _style = widget.outfit.style;
  late Season? _season = widget.outfit.season;

  /// A value created on the web may not be in [_occasions]; it is kept and
  /// shown as an extra option.
  late String? _occasion = (widget.outfit.occasion?.isEmpty ?? true)
      ? null
      : widget.outfit.occasion;
  late bool _favorite = widget.outfit.isFavorite;
  late bool _draft = widget.outfit.isDraft;
  late bool _public = widget.outfit.isPublic;
  final List<File> _newImages = [];
  final Set<String> _imagesToDelete = {};
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _EditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prev = oldWidget.outfit;
    final next = widget.outfit;
    if (next.id != prev.id) {
      // Never carry one outfit's pending edits into another's form.
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
    sync(_tags, prev.tags?.join(', ') ?? '', next.tags?.join(', ') ?? '');
    if (_style == prev.style) _style = next.style;
    if (_season == prev.season) _season = next.season;
    final prevOccasion = (prev.occasion?.isEmpty ?? true) ? null : prev.occasion;
    final nextOccasion = (next.occasion?.isEmpty ?? true) ? null : next.occasion;
    if (_occasion == prevOccasion) _occasion = nextOccasion;
    if (_favorite == prev.isFavorite) _favorite = next.isFavorite;
    if (_draft == prev.isDraft) _draft = next.isDraft;
    if (_public == prev.isPublic) _public = next.isPublic;
  }

  Future<void> _addPhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() => _newImages.add(File(image.path)));
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final id = widget.outfit.id;
    final repository = ref.read(outfitRepositoryProvider);
    final description = _description.text.trim();
    final tags = [
      for (final t in _tags.text.split(','))
        if (t.trim().isNotEmpty) t.trim(),
    ];
    try {
      await ref
          .read(outfitsProvider.notifier)
          .save(
            id,
            UpdateOutfitRequest(
              name: _name.text.trim(),
              description: description.isEmpty ? null : description,
              style: _style,
              season: _season,
              occasion: _occasion,
              tags: tags.isEmpty ? null : tags,
              isFavorite: _favorite,
              isDraft: _draft,
              isPublic: _public,
            ),
          );
    } catch (_) {
      // `save` showed the error; keep the form open.
      if (mounted) setState(() => _saving = false);
      return;
    }
    if (_imagesToDelete.isNotEmpty || _newImages.isNotEmpty) {
      try {
        for (final imageId in _imagesToDelete) {
          await repository.deleteOutfitImage(id, imageId);
        }
        if (_newImages.isNotEmpty) {
          await repository.uploadImages(id, _newImages);
        }
        ref
            .read(outfitsProvider.notifier)
            .replace(await repository.getOutfit(id));
      } catch (e, stack) {
        ErrorHandler.showError(
          e,
          title: 'Details saved, photos not',
          stackTrace: stack,
        );
        if (mounted) setState(() => _saving = false);
        return;
      }
    }
    if (!mounted) return;
    ErrorHandler.showSuccess('Your changes are saved.', title: 'Saved');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final images = widget.outfit.outfitImages ?? const [];
    final occasions = {..._occasions, ?_occasion}.toList();
    const gap = SizedBox(height: AppConstants.spacing16);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit outfit'),
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
              Row(
                children: [
                  Expanded(child: Text('Photos', style: text.titleSmall)),
                  TextButton.icon(
                    onPressed: _addPhoto,
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 18,
                    ),
                    label: const Text('Add photo'),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing8),
              if (images.isEmpty && _newImages.isEmpty)
                PaperSurface(
                  lift: 0,
                  color: tokens.stock.sunk,
                  child: Text(
                    'No photos yet. The outfit shows its pieces instead.',
                    style: text.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 112,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final image in images)
                        _Thumb(
                          removed: _imagesToDelete.contains(image.id),
                          onAction: () => setState(
                            () => _imagesToDelete.contains(image.id)
                                ? _imagesToDelete.remove(image.id)
                                : _imagesToDelete.add(image.id),
                          ),
                          child: AppImage(
                            imageUrl: image.url,
                            fit: BoxFit.cover,
                            enableZoom: false,
                            memCacheWidth: 300,
                            storagePath: image.storagePath,
                            remintUrl: ref
                                .read(outfitRepositoryProvider)
                                .remintImageUrl,
                          ),
                        ),
                      for (final (i, file) in _newImages.indexed)
                        _Thumb(
                          onAction: () =>
                              setState(() => _newImages.removeAt(i)),
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                          ),
                        ),
                    ],
                  ),
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
              TextFormField(
                controller: _description,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              gap,
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Style>(
                      initialValue: _style,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Style'),
                      items: [
                        for (final s in Style.values)
                          DropdownMenuItem(
                            value: s,
                            child: Text(s.displayName),
                          ),
                      ],
                      onChanged: (v) => setState(() => _style = v),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: DropdownButtonFormField<Season>(
                      initialValue: _season,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Season'),
                      items: [
                        for (final s in Season.values)
                          DropdownMenuItem(
                            value: s,
                            child: Text(s.displayName),
                          ),
                      ],
                      onChanged: (v) => setState(() => _season = v),
                    ),
                  ),
                ],
              ),
              gap,
              DropdownButtonFormField<String?>(
                initialValue: _occasion,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Occasion'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  for (final o in occasions)
                    DropdownMenuItem(
                      value: o,
                      child: Text(o[0].toUpperCase() + o.substring(1)),
                    ),
                ],
                onChanged: (v) => setState(() => _occasion = v),
              ),
              gap,
              TextFormField(
                controller: _tags,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  helperText: 'Separate with commas',
                ),
              ),
              const SizedBox(height: AppConstants.spacing20),
              PaperSurface(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Favourite'),
                      value: _favorite,
                      onChanged: (v) => setState(() => _favorite = v),
                    ),
                    SwitchListTile(
                      title: const Text('Draft'),
                      subtitle: const Text('Hidden from your main list'),
                      value: _draft,
                      onChanged: (v) => setState(() => _draft = v),
                    ),
                    SwitchListTile(
                      title: const Text('Public'),
                      subtitle: const Text('Anyone with the link can see it'),
                      value: _public,
                      onChanged: (v) => setState(() => _public = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              Text(
                'Delete this outfit from its detail page.',
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

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.child,
    required this.onAction,
    this.removed = false,
  });

  final Widget child;
  final VoidCallback onAction;
  final bool removed;

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
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: removed ? 'Keep photo' : 'Remove photo',
                onPressed: onAction,
                style: IconButton.styleFrom(backgroundColor: tokens.stock.card),
                icon: Icon(
                  removed ? Icons.undo_rounded : Icons.close_rounded,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
