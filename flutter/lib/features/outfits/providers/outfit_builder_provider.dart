import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_handler.dart';
import '../../../domain/enums/season.dart';
import '../../../domain/enums/style.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/providers/wardrobe_providers.dart';
import '../models/outfit_model.dart';
import '../repositories/outfit_repository.dart';
import 'outfit_providers.dart';

/// Every closet piece for the picker, up to [maxPages] pages of 100. Loaded
/// once per builder session.
final builderPickerItemsProvider = FutureProvider.autoDispose<List<ItemModel>>((
  ref,
) async {
  const maxPages = 10;
  final repository = ref.read(itemRepositoryProvider);
  final items = <ItemModel>[];
  for (var page = 1; page <= maxPages; page++) {
    final response = await repository.getItems(page: page, limit: 100);
    items.addAll(response.items);
    if (!response.hasMore) break;
  }
  return items;
});

@immutable
class OutfitDraft {
  const OutfitDraft({
    this.pieces = const [],
    this.name = '',
    this.description = '',
    this.style = Style.casual,
    this.season = Season.allSeason,
    this.previewUrl,
    this.generating = false,
    this.saving = false,
  });

  final List<ItemModel> pieces;
  final String name;
  final String description;
  final Style style;
  final Season season;

  /// AI preview: a URL, or a `data:image/png;base64,` URI when storage is
  /// unavailable.
  final String? previewUrl;
  final bool generating;
  final bool saving;

  bool contains(String itemId) => pieces.any((p) => p.id == itemId);

  OutfitDraft copyWith({
    List<ItemModel>? pieces,
    String? name,
    String? description,
    Style? style,
    Season? season,
    String? Function()? previewUrl,
    bool? generating,
    bool? saving,
  }) => OutfitDraft(
    pieces: pieces ?? this.pieces,
    name: name ?? this.name,
    description: description ?? this.description,
    style: style ?? this.style,
    season: season ?? this.season,
    previewUrl: previewUrl == null ? this.previewUrl : previewUrl(),
    generating: generating ?? this.generating,
    saving: saving ?? this.saving,
  );
}

final outfitBuilderProvider =
    NotifierProvider.autoDispose<OutfitBuilderNotifier, OutfitDraft>(
      OutfitBuilderNotifier.new,
    );

/// The outfit being built: chosen pieces, details and the AI preview.
class OutfitBuilderNotifier extends Notifier<OutfitDraft> {
  @override
  OutfitDraft build() => const OutfitDraft();

  void toggle(ItemModel item) => state = state.copyWith(
    pieces: state.contains(item.id)
        ? [
            for (final p in state.pieces)
              if (p.id != item.id) p,
          ]
        : [...state.pieces, item],
    // The preview no longer matches the pieces.
    previewUrl: () => null,
  );

  void setName(String value) => state = state.copyWith(name: value);
  void setDescription(String value) =>
      state = state.copyWith(description: value);
  void setStyle(Style value) => state = state.copyWith(
    style: value,
    // The preview no longer matches the style.
    previewUrl: () => null,
  );
  void setSeason(Season value) => state = state.copyWith(season: value);

  Future<void> generatePreview() async {
    if (state.pieces.isEmpty || state.generating) return;
    final inputIds = [for (final p in state.pieces) p.id];
    final inputStyle = state.style;
    state = state.copyWith(generating: true);
    try {
      final result = await ref
          .read(outfitRepositoryProvider)
          .generateOutfitVisualization(
            [
              for (final p in state.pieces)
                {
                  // The backend reads the stored garment photo by id.
                  'item_id': p.id,
                  'name': p.name,
                  'category': p.category.name,
                  // Omit rather than send null: the API requires a list.
                  if (p.colors != null) 'colors': p.colors,
                  'brand': p.brand,
                  'material': p.material,
                  'pattern': p.pattern,
                },
            ],
            style: state.style.name,
            background: 'studio white',
          );
      if (!ref.mounted) return;
      // The draft can change while the request runs (pieces toggled, style
      // switched): a result for the old inputs must not replace a newer
      // preview or re-add a cleared one.
      final currentIds = [for (final p in state.pieces) p.id];
      if (state.style != inputStyle || !listEquals(currentIds, inputIds)) {
        return;
      }
      // On a storage failure the backend sends an EMPTY url plus base64.
      final url = result.imageUrl ?? '';
      state = state.copyWith(
        previewUrl: () => url.isNotEmpty
            ? url
            : 'data:image/png;base64,${result.imageBase64}',
      );
    } catch (e, stack) {
      ErrorHandler.showError(
        e,
        title: 'Preview not created',
        stackTrace: stack,
      );
    } finally {
      if (ref.mounted) state = state.copyWith(generating: false);
    }
  }

  /// Creates the outfit and uploads the preview. Returns the outfit, or null
  /// when validation or the create request fails. A second call while a save
  /// runs does nothing, so a double tap never creates two outfits.
  Future<OutfitModel?> save() async {
    if (state.saving) return null;
    final name = state.name.trim();
    if (name.isEmpty) {
      ErrorHandler.showValidation('Give the outfit a name.', title: 'Name');
      return null;
    }
    if (state.pieces.isEmpty) {
      ErrorHandler.showValidation(
        'Choose at least one piece.',
        title: 'Pieces',
      );
      return null;
    }
    state = state.copyWith(saving: true);
    final repository = ref.read(outfitRepositoryProvider);
    // Snapshot the preview with the create request: edits made while the
    // request runs must not change which image is uploaded.
    final preview = state.previewUrl;
    try {
      final outfit = await repository.createOutfit(
        CreateOutfitRequest(
          name: name,
          description: state.description.trim().isEmpty
              ? null
              : state.description.trim(),
          itemIds: [for (final p in state.pieces) p.id],
          style: state.style,
          season: state.season,
          tags: const [],
        ),
      );
      // The server has the outfit even if this notifier was disposed while
      // awaiting (user left the builder): skip ref work, never report a
      // created outfit as unsaved.
      if (!ref.mounted) return outfit;
      await _uploadPreview(repository, outfit.id, preview);
      if (ref.exists(outfitsProvider)) {
        ref.read(outfitsProvider.notifier).add(outfit);
      }
      ErrorHandler.showSuccess('$name is in your outfits.', title: 'Saved');
      return outfit;
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Outfit not saved', stackTrace: stack);
      return null;
    } finally {
      if (ref.mounted) state = state.copyWith(saving: false);
    }
  }

  /// Uploads [preview] as the outfit's primary image. A data URI uploads
  /// its bytes; a URL is downloaded and re-uploaded. A failure never fails
  /// the save: it is reported, and the outfit keeps its piece images.
  Future<void> _uploadPreview(
    OutfitRepository repository,
    String outfitId,
    String? preview,
  ) async {
    if (preview == null || preview.isEmpty) return;
    OutfitImage? uploaded;
    try {
      uploaded = preview.startsWith('data:image/')
          ? await repository.uploadOutfitImageFromBase64(
              outfitId,
              preview.split(',').last,
              isPrimary: true,
              pose: 'front',
            )
          : await repository.uploadOutfitImageFromUrl(
              outfitId,
              preview,
              isPrimary: true,
              pose: 'front',
            );
    } catch (e, stack) {
      ErrorHandler.reportError(e, 'Outfit preview upload', stackTrace: stack);
    }
    if (uploaded == null) {
      ErrorHandler.reportError(
        StateError('Outfit image upload failed'),
        'Outfit $outfitId was created without its generated preview',
      );
    }
  }
}
