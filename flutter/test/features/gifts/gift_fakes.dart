import 'package:fitcheck_ai/features/gifts/models/gift_models.dart';
import 'package:fitcheck_ai/features/gifts/repositories/gift_repository.dart';

GiftVoucher fakeVoucher({String id = 'gift-1', String fromName = 'Alex'}) =>
    GiftVoucher(
      id: id,
      publicId: 'public-$id',
      durationMonths: 1,
      retailValueCents: 999,
      currency: 'USD',
      fromName: fromName,
      toName: 'Sam',
      status: 'issued',
      createdAt: '2026-08-30T00:00:00Z',
      artworkVersion: 1,
      ogImageUrl: 'https://example.com/gift.png',
    );

class FakeGiftRepository extends GiftRepository {
  FakeGiftRepository({required this.summary});

  GiftDashboardSummary summary;
  bool shouldFailSummary = false;
  Object? createError;
  int summaryCalls = 0;
  int createCalls = 0;
  int? createdDurationMonths;
  String? createdRecipientEmail;
  String? createdClientRequestId;
  GiftOccasion? createdOccasion;
  String? createdOccasionGreeting;
  String? claimedVoucherId;

  @override
  Future<GiftDashboardSummary> getSummary() async {
    summaryCalls++;
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
    GiftOccasion? occasion,
    String? occasionGreeting,
  }) async {
    createCalls++;
    createdDurationMonths = durationMonths;
    createdRecipientEmail = recipientEmail;
    createdClientRequestId = clientRequestId;
    createdOccasion = occasion;
    createdOccasionGreeting = occasionGreeting;
    final error = createError;
    if (error != null) throw error;
    return fakeVoucher(id: 'created');
  }

  @override
  Future<GiftClaimResult> claimAssigned(String voucherId) async {
    claimedVoucherId = voucherId;
    return GiftClaimResult(
      voucher: fakeVoucher(id: voucherId),
      entitlementStatus: 'active',
      queuedCount: 0,
      queuedMonths: 0,
    );
  }
}
