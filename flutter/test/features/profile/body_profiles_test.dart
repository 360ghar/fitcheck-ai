import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/widgets/app_ui.dart';
import 'package:fitcheck_ai/features/profile/models/body_profile_model.dart';
import 'package:fitcheck_ai/features/profile/providers/body_profiles_provider.dart';
import 'package:fitcheck_ai/features/profile/repositories/body_profile_repository.dart';
import 'package:fitcheck_ai/features/profile/views/body_profiles_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

BodyProfileModel _profile(String id, {bool isDefault = false}) =>
    BodyProfileModel(
      id: id,
      userId: 'u',
      name: 'Profile $id',
      heightCm: 170,
      weightKg: 65,
      bodyShape: 'Regular',
      skinTone: 'Medium',
      isDefault: isDefault,
    );

class _Repo extends BodyProfileRepository {
  _Repo({this.profiles = const [], this.fail = false});

  final List<BodyProfileModel> profiles;
  final bool fail;

  @override
  Future<List<BodyProfileModel>> getBodyProfiles() async {
    if (fail) throw Exception('server down');
    return profiles;
  }

  @override
  Future<BodyProfileModel> updateBodyProfile(
    String profileId,
    UpdateBodyProfileRequest request,
  ) async => profiles
      .firstWhere((p) => p.id == profileId)
      .copyWith(isDefault: request.isDefault ?? false);
}

Future<void> _pump(WidgetTester tester, _Repo repo) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: [bodyProfileRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: BodyProfilesPage(),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('a failed load shows an error with retry, not the empty state', (
    tester,
  ) async {
    await _pump(tester, _Repo(fail: true));

    expect(find.byType(AppErrorState), findsOneWidget);
    expect(find.text('No body profiles yet'), findsNothing);
  });

  testWidgets('no profiles shows the empty state with an add action', (
    tester,
  ) async {
    await _pump(tester, _Repo());

    expect(find.text('No body profiles yet'), findsOneWidget);
    expect(find.text('Add a profile'), findsOneWidget);
  });

  test('a new default clears the flag on the others', () async {
    final container = ProviderContainer(
      retry: noRetry,
      overrides: [
        bodyProfileRepositoryProvider.overrideWithValue(
          _Repo(profiles: [_profile('a', isDefault: true), _profile('b')]),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(bodyProfilesProvider, (_, _) {});
    container.listen(bodyProfileBusyProvider, (_, _) {});
    await container.read(bodyProfilesProvider.future);

    await container.read(bodyProfilesProvider.notifier).setDefault('b');

    final profiles = container.read(bodyProfilesProvider).requireValue;
    expect([for (final p in profiles) p.isDefault], [false, true]);
  });
}
