class GiftAllowance {
  const GiftAllowance({
    required this.durationMonths,
    required this.grantedCount,
    required this.usedCount,
    required this.remainingCount,
  });

  final int durationMonths;
  final int grantedCount;
  final int usedCount;
  final int remainingCount;

  factory GiftAllowance.fromJson(Map<String, dynamic> json) {
    return GiftAllowance(
      durationMonths: _asInt(json['duration_months']),
      grantedCount: _asInt(json['granted_count']),
      usedCount: _asInt(json['used_count']),
      remainingCount: _asInt(json['remaining_count']),
    );
  }

  GiftAllowance copyWith({int? remainingCount}) {
    return GiftAllowance(
      durationMonths: durationMonths,
      grantedCount: grantedCount,
      usedCount: usedCount,
      remainingCount: remainingCount ?? this.remainingCount,
    );
  }
}

class GiftVoucher {
  const GiftVoucher({
    required this.id,
    required this.publicId,
    required this.durationMonths,
    required this.retailValueCents,
    required this.currency,
    required this.fromName,
    required this.toName,
    required this.status,
    required this.createdAt,
    required this.artworkVersion,
    required this.ogImageUrl,
    this.message,
    this.expiresAt,
    this.shareUrl,
    this.entitlementStatus,
  });

  final String id;
  final String publicId;
  final int durationMonths;
  final int retailValueCents;
  final String currency;
  final String fromName;
  final String toName;
  final String? message;
  final String status;
  final String createdAt;
  final int artworkVersion;
  final String ogImageUrl;
  final String? expiresAt;
  final String? shareUrl;
  final String? entitlementStatus;

  factory GiftVoucher.fromJson(Map<String, dynamic> json) {
    return GiftVoucher(
      id: _asString(json['id']),
      publicId: _asString(json['public_id']),
      durationMonths: _asInt(json['duration_months']),
      retailValueCents: _asInt(json['retail_value_cents']),
      currency: _asString(json['currency'], fallback: 'USD'),
      fromName: _asString(json['from_name']),
      toName: _asString(json['to_name']),
      message: _nullableString(json['message']),
      status: _asString(json['status']),
      createdAt: _asString(json['created_at']),
      artworkVersion: _asInt(json['artwork_version'], fallback: 1),
      ogImageUrl: _asString(json['og_image_url']),
      expiresAt: _nullableString(json['expires_at']),
      shareUrl: _nullableString(json['share_url']),
      entitlementStatus: _nullableString(json['entitlement_status']),
    );
  }
}

class GiftDashboardSummary {
  const GiftDashboardSummary({
    required this.allowances,
    required this.incoming,
  });

  final List<GiftAllowance> allowances;
  final List<GiftVoucher> incoming;

  factory GiftDashboardSummary.fromJson(Map<String, dynamic> json) {
    return GiftDashboardSummary(
      allowances: _asMapList(
        json['allowances'],
      ).map(GiftAllowance.fromJson).toList(growable: false),
      incoming: _asMapList(
        json['incoming'],
      ).map(GiftVoucher.fromJson).toList(growable: false),
    );
  }
}

class GiftClaimResult {
  const GiftClaimResult({
    required this.voucher,
    required this.entitlementStatus,
    required this.queuedCount,
    required this.queuedMonths,
  });

  final GiftVoucher voucher;
  final String entitlementStatus;
  final int queuedCount;
  final int queuedMonths;

  factory GiftClaimResult.fromJson(Map<String, dynamic> json) {
    return GiftClaimResult(
      voucher: GiftVoucher.fromJson(_asMap(json['voucher'])),
      entitlementStatus: _asString(json['entitlement_status']),
      queuedCount: _asInt(json['queued_count']),
      queuedMonths: _asInt(json['queued_months']),
    );
  }
}

enum GiftDashboardPriority { incoming, complimentary }

/// Navigation intent from the dashboard card into the native gift screen.
class GiftRouteIntent {
  const GiftRouteIntent.create({required this.durationMonths})
    : incomingVoucherId = null;

  const GiftRouteIntent.claim({required this.incomingVoucherId})
    : durationMonths = null;

  final int? durationMonths;
  final String? incomingVoucherId;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _asString(dynamic value, {String fallback = ''}) =>
    value?.toString() ?? fallback;

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, item) => MapEntry(key.toString(), item));
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value.whereType<Map>().map(_asMap).toList(growable: false);
}
