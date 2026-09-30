import 'dart:io';

import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/services/notification_service.dart'
    show scaffoldMessengerKey;
import 'package:fitcheck_ai/features/gifts/models/gift_models.dart';
import 'package:fitcheck_ai/features/gifts/providers/gift_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../gift_fakes.dart';

const _oneFree = GiftAllowance(
  durationMonths: 12,
  grantedCount: 2,
  usedCount: 1,
  remainingCount: 1,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeGiftRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeGiftRepository(
      summary: const GiftDashboardSummary(allowances: [], incoming: []),
    );
    container = ProviderContainer(
      retry: noRetry,
      overrides: [giftRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  Future<GiftDashboardSummary?> load() => container.read(giftProvider.future);

  test('incoming gifts take priority over free invitations', () async {
    repository.summary = GiftDashboardSummary(
      allowances: const [_oneFree],
      incoming: [fakeVoucher()],
    );

    final summary = await load();

    expect(summary?.priority, GiftDashboardPriority.incoming);
    expect(summary?.incomingGift?.id, 'gift-1');
  });

  test('a free invitation is next when no incoming gift exists', () async {
    repository.summary = const GiftDashboardSummary(
      allowances: [_oneFree],
      incoming: [],
    );

    final summary = await load();

    expect(summary?.priority, GiftDashboardPriority.complimentary);
    expect(summary?.freeAllowance?.durationMonths, 12);
  });

  test('free creation sends the recipient email and request id', () async {
    await load();

    final voucher = await container
        .read(giftProvider.notifier)
        .createComplimentary(
          durationMonths: 1,
          fromName: 'Alex',
          toName: 'Sam',
          recipientEmail: 'sam@example.com',
          clientRequestId: 'request-1',
          occasion: GiftOccasion.other,
          occasionGreeting: 'Congratulations!',
        );

    expect(voucher?.id, 'created');
    expect(repository.createdDurationMonths, 1);
    expect(repository.createdRecipientEmail, 'sam@example.com');
    expect(repository.createdClientRequestId, 'request-1');
    expect(repository.createdOccasion, GiftOccasion.other);
    expect(repository.createdOccasionGreeting, 'Congratulations!');
    // The summary is refetched after the write.
    expect(repository.summaryCalls, 2);
    expect(container.read(giftBusyProvider), isEmpty);
  });

  test('a second create tap while one runs sends nothing', () async {
    await load();
    final notifier = container.read(giftProvider.notifier);
    Future<GiftVoucher?> create() => notifier.createComplimentary(
      durationMonths: 1,
      fromName: 'Alex',
      toName: 'Sam',
      recipientEmail: 'sam@example.com',
      clientRequestId: 'request-1',
    );

    final first = create();
    final second = await create();

    expect(second, isNull);
    expect((await first)?.id, 'created');
    expect(repository.createCalls, 1);
  });

  testWidgets('a failed create shows the error and returns null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const Scaffold(),
      ),
    );
    repository.createError = Exception('Recipient email is not verified.');

    final voucher = await container
        .read(giftProvider.notifier)
        .createComplimentary(
          durationMonths: 1,
          fromName: 'Alex',
          toName: 'Sam',
          recipientEmail: 'sam@example.com',
          clientRequestId: 'request-1',
        );
    await tester.pump();

    expect(voucher, isNull);
    expect(find.text('Could not create the gift'), findsOneWidget);
    expect(container.read(giftBusyProvider), isEmpty);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  test('incoming claims use the assigned claim action', () async {
    await load();

    final result = await container
        .read(giftProvider.notifier)
        .claimIncoming('gift-claim');

    expect(result?.entitlementStatus, 'active');
    expect(repository.claimedVoucherId, 'gift-claim');
  });

  test('a failed summary does not leave the dashboard loading', () async {
    repository.shouldFailSummary = true;

    await expectLater(load(), throwsException);

    final state = container.read(giftProvider);
    expect(state.isLoading, isFalse);
    expect(liveGiftSummary(state), isNull);
  });

  test('a failed refresh clears stale gift priority data', () async {
    repository.summary = GiftDashboardSummary(
      allowances: const [],
      incoming: [fakeVoucher()],
    );
    await load();
    repository.shouldFailSummary = true;

    await container.read(giftProvider.notifier).refresh();

    expect(liveGiftSummary(container.read(giftProvider)), isNull);
  });

  test('native gifts do not contain an external paid checkout path', () {
    const sourceFiles = [
      'lib/features/gifts/views/gift_vouchers_page.dart',
      'lib/features/gifts/repositories/gift_repository.dart',
      'lib/features/gifts/providers/gift_providers.dart',
    ];
    final source = sourceFiles
        .map((path) => File(path).readAsStringSync().toLowerCase())
        .join('\n');

    expect(source, isNot(contains('stripe')));
    expect(source, isNot(contains('checkout')));
    expect(source, isNot(contains('url_launcher')));
  });
}
