import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/paged_state.dart';
import '../../../core/utils/error_handler.dart';
import '../models/body_profile_model.dart';
import '../repositories/body_profile_repository.dart';

final bodyProfileRepositoryProvider = Provider<BodyProfileRepository>(
  (ref) => BodyProfileRepository(),
);

final bodyProfilesProvider =
    AsyncNotifierProvider.autoDispose<
      BodyProfilesNotifier,
      List<BodyProfileModel>
    >(BodyProfilesNotifier.new);

/// Profile ids with a delete or set-default in flight.
final bodyProfileBusyProvider =
    NotifierProvider.autoDispose<BusyIds, Set<String>>(BusyIds.new);

/// The user's body profiles (measurements used for fit and try-on).
class BodyProfilesNotifier extends AsyncNotifier<List<BodyProfileModel>> {
  BodyProfileRepository get _repository =>
      ref.read(bodyProfileRepositoryProvider);

  @override
  Future<List<BodyProfileModel>> build() => _repository.getBodyProfiles();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getBodyProfiles);
  }

  /// Puts [saved] in the list. A new default clears the flag on the others.
  void _upsert(BodyProfileModel saved) {
    final current = state.value ?? const <BodyProfileModel>[];
    final exists = current.any((p) => p.id == saved.id);
    final next = [
      for (final p in current)
        if (p.id == saved.id)
          saved
        else if (saved.isDefault)
          p.copyWith(isDefault: false)
        else
          p,
      if (!exists) saved,
    ];
    state = AsyncData(next);
  }

  Future<bool> create(CreateBodyProfileRequest request) async {
    try {
      final created = await _repository.createBodyProfile(request);
      if (ref.mounted) _upsert(created);
      ErrorHandler.showSuccess('Your body profile is saved.', title: 'Saved');
      return true;
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      return false;
    }
  }

  Future<bool> edit(String id, UpdateBodyProfileRequest request) async {
    try {
      final updated = await _repository.updateBodyProfile(id, request);
      if (ref.mounted) _upsert(updated);
      ErrorHandler.showSuccess('Your changes are saved.', title: 'Saved');
      return true;
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      return false;
    }
  }

  Future<void> setDefault(String id) async {
    await ref.read(bodyProfileBusyProvider.notifier).run(id, () async {
      try {
        final updated = await _repository.updateBodyProfile(
          id,
          const UpdateBodyProfileRequest(isDefault: true),
        );
        if (ref.mounted) _upsert(updated);
        ErrorHandler.showSuccess('Set as your default profile.');
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      }
    });
  }

  Future<void> delete(String id) async {
    await ref.read(bodyProfileBusyProvider.notifier).run(id, () async {
      try {
        await _repository.deleteBodyProfile(id);
        if (ref.mounted) {
          state = AsyncData([
            for (final p in state.value ?? const <BodyProfileModel>[])
              if (p.id != id) p,
          ]);
        }
        ErrorHandler.showSuccess('Body profile deleted.', title: 'Deleted');
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Not deleted', stackTrace: stack);
      }
    });
  }
}
