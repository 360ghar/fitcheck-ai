import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ai_consent_sheet.dart';
import 'persistence_service.dart';
import 'supabase_service.dart';

final aiConsentServiceProvider = Provider<AiConsentService>(
  (ref) => AiConsentService(),
);

/// Service that records and gates the user's consent to sharing their photos
/// with a third-party AI provider (OpenAI) for image generation.
///
/// Required for Apple App Store Guideline 5.1.2(i): explicit permission must be
/// obtained before sharing user data with third parties. Consent is captured
/// once per user at the first AI-feature use and persisted locally via
/// [PersistenceService].
class AiConsentService {
  AiConsentService({String? Function()? userId, PersistenceService? persistence})
    : _userId =
          userId ?? (() => SupabaseService.instance.currentSession?.user.id),
      _persistence = persistence ?? PersistenceService.instance;

  /// Versioned key prefix, so a material disclosure change can re-prompt.
  /// Consent is stored per user: another account that signs in on the same
  /// device must give its own consent (App Store Guideline 5.1.2(i)).
  static const String _consentKeyPrefix = 'fitcheck_ai_consent_v1';

  final String? Function() _userId;

  final PersistenceService _persistence;

  /// In-memory cache for the user in [_cachedFor]. Consent changes only
  /// through [setConsented], so the cache stays correct until the user
  /// changes.
  String? _cachedFor;
  bool _consented = false;

  String _keyFor(String uid) => '$_consentKeyPrefix:$uid';

  /// Returns true if the signed-in user has previously granted consent.
  Future<bool> hasConsented() async {
    final uid = _userId();
    if (uid == null) return false;
    if (uid == _cachedFor) return _consented;
    var consented = false;
    try {
      consented = (await _persistence.getBool(_keyFor(uid))) ?? false;
    } catch (e) {
      debugPrint('Failed to read AI consent: $e');
    }
    _cachedFor = uid;
    _consented = consented;
    return consented;
  }

  /// Persists that the signed-in user has granted consent.
  Future<void> setConsented() async {
    final uid = _userId();
    if (uid == null) return;
    await _setConsentedFor(uid);
  }

  /// Records consent for [uid], the user captured when the consent sheet was
  /// shown. If the account changed while the sheet was open, nothing is
  /// written: one user's acceptance must never be recorded for another.
  Future<void> _setConsentedFor(String uid) async {
    if (_userId() != uid) return;
    _cachedFor = uid;
    _consented = true;
    try {
      await _persistence.setBool(_keyFor(uid), true);
    } catch (e) {
      debugPrint('Failed to persist AI consent: $e');
    }
  }

  /// Ensures consent before an AI feature runs.
  ///
  /// Returns true immediately if already consented. Otherwise shows the
  /// non-dismissible consent sheet; on accept it persists consent and returns
  /// true, on decline it returns false (caller must abort the AI action).
  Future<bool> ensureConsent({required String featureLabel}) async {
    if (await hasConsented()) return true;
    final uid = _userId();
    if (uid == null) return false;

    final accepted = await showAiConsentSheet(featureLabel: featureLabel);
    if (!accepted) return false;
    if (_userId() != uid) return false; // account changed while the sheet ran
    await _setConsentedFor(uid);
    return true;
  }
}
