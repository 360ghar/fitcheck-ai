import 'dart:io';

import 'package:fitcheck_ai/features/gifts/controllers/gift_controller.dart';
import 'package:fitcheck_ai/features/gifts/models/gift_models.dart';
import 'package:fitcheck_ai/features/gifts/repositories/gift_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

GiftVoucher _voucher({String id = 'gift-1'}) {
  return GiftVoucher(
    id: id,
    publicId: 'public-$id',
    durationMonths: 1,
    retailValueCents: 999,
    currency: 'USD',
    fromName: 'Alex',
    toName: 'Sam',
    status: 'issued',
    createdAt: '2026-08-30T00:00:00Z',
    artworkVersion: 1,
    ogImageUrl: 'https://example.com/gift.png',
  );
}

class FakeGiftRepository extends GiftRepository {
  FakeGiftRepository({required this.summary});

  GiftDashboardSummary summary;
  bool shouldFailSummary = false;
  int? createdDurationMonths;
  String? createdRecipientEmail;
  String? claimedVoucherId;

  @override
  Future<GiftDashboardSummary> getSummary() async {
    if (shouldFailSummary) throw Exception('Gift summary is unavailable.');
    return summary;
  }

  @override
  Future<GiftVoucher> createComplimentary({
    required int durationMonths,
    required String fromName,
    required String toName,
    required String recipientEmail,
    required String clientRequestId,
    String? message,
  }) async {
    createdDurationMonths = durationMonths;
    createdRecipientEmail = recipientEmail;
    return _voucher(id: 'created');
  }

  @override
  Future<GiftClaimResult> claimAssigned(String voucherId) async {
    claimedVoucherId = voucherId;
    return GiftClaimResult(
      voucher: _voucher(id: voucherId),
      entitlementStatus: 'active',
      queuedCount: 0,
      queuedMonths: 0,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(Get.reset);

  testWidgets('incoming gifts take priority over free invitations', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final repository = FakeGiftRepository(
      summary: GiftDashboardSummary(
        allowances: const [
          GiftAllowance(
            durationMonths: 1,
            grantedCount: 1,
            usedCount: 0,
            remainingCount: 1,
          ),
        ],
        incoming: [_voucher()],
      ),
    );
    final controller = GiftController(repository: repository);

    await controller.load();

    expect(controller.priority, GiftDashboardPriority.incoming);
    expect(controller.incomingGift?.id, 'gift-1');

    controller.onClose();
  });

  testWidgets('a free invitation is next when no incoming gift exists', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final repository = FakeGiftRepository(
      summary: const GiftDashboardSummary(
        allowances: [
          GiftAllowance(
            durationMonths: 12,
            grantedCount: 2,
            usedCount: 1,
            remainingCount: 1,
          ),
        ],
        incoming: [],
      ),
    );
    final controller = GiftController(repository: repository);

    await controller.load();

    expect(controller.priority, GiftDashboardPriority.complimentary);
    expect(controller.freeAllowance?.durationMonths, 12);

    controller.onClose();
  });

  testWidgets('free creation sends the required recipient email', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final repository = FakeGiftRepository(
      summary: const GiftDashboardSummary(allowances: [], incoming: []),
    );
    final controller = GiftController(repository: repository);

    final voucher = await controller.createComplimentary(
      durationMonths: 1,
      fromName: 'Alex',
      toName: 'Sam',
      recipientEmail: 'sam@example.com',
      clientRequestId: 'request-1',
    );

    expect(voucher?.id, 'created');
    expect(repository.createdDurationMonths, 1);
    expect(repository.createdRecipientEmail, 'sam@example.com');

    controller.onClose();
  });

  testWidgets('incoming claims use the authenticated assigned claim action', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final repository = FakeGiftRepository(
      summary: const GiftDashboardSummary(allowances: [], incoming: []),
    );
    final controller = GiftController(repository: repository);

    final result = await controller.claimIncoming('gift-claim');

    expect(result?.entitlementStatus, 'active');
    expect(repository.claimedVoucherId, 'gift-claim');

    controller.onClose();
  });

  testWidgets('a failed summary does not leave the dashboard loading', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final repository = FakeGiftRepository(
      summary: const GiftDashboardSummary(allowances: [], incoming: []),
    )..shouldFailSummary = true;
    final controller = GiftController(repository: repository);

    await controller.load();

    expect(controller.hasLoaded.value, isTrue);
    expect(controller.isLoading.value, isFalse);
    expect(controller.priority, isNull);

    controller.onClose();
  });

  testWidgets('a failed refresh clears stale gift priority data', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final repository = FakeGiftRepository(
      summary: GiftDashboardSummary(
        allowances: const [],
        incoming: [_voucher()],
      ),
    );
    final controller = GiftController(repository: repository);

    await controller.load();
    repository.shouldFailSummary = true;
    await controller.load(showLoader: false);

    expect(controller.summary.value, isNull);
    expect(controller.priority, isNull);

    controller.onClose();
  });

  test('native gifts do not contain an external paid checkout path', () {
    const sourceFiles = [
      'lib/features/gifts/views/gift_vouchers_page.dart',
      'lib/features/gifts/repositories/gift_repository.dart',
      'lib/features/gifts/controllers/gift_controller.dart',
    ];
    final source = sourceFiles
        .map((path) => File(path).readAsStringSync().toLowerCase())
        .join('\n');

    expect(source, isNot(contains('stripe')));
    expect(source, isNot(contains('checkout')));
    expect(source, isNot(contains('url_launcher')));
  });
}
