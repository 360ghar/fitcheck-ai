import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/ai_consent_sheet.dart';
import 'persistence_service.dart';

/// Service that records and gates the user's consent to sharing their photos
/// with a third-party AI provider (OpenAI) for image generation.
///
/// Required for Apple App Store Guideline 5.1.2(i): explicit permission must be
/// obtained before sharing user data with third parties. Consent is captured
/// once at the first AI-feature use and persisted locally via
/// [PersistenceService] (modeled on [ThemeService]).
class AiConsentService extends GetxController {
  /// Versioned key so we can re-prompt if the disclosure materially changes.
  /// Restored from the pre-DI-refactor value (`fitcheck_ai_consent_v1`) so
  /// users who granted consent before that change keep it (a mangled key
  /// silently re-prompted them and, worse, re-consented under a garbage key).
  static const String _consentKey = 'fitcheck_ai_consent_v1';

  PersistenceService get _persistence => Get.find<PersistenceService>();

  /// Cached in-memory value to avoid repeated disk reads. `false` is cached
  /// too: consent can only change in-process via [setConsented] (which updates
  /// the cache), so a cached false is authoritative and re-reading disk on
  /// every call while the user hasn't consented yet buys nothing.
  bool _consented = false;

  @override
  void onInit() {
    super.onInit();
    _loadCachedConsent();
  }

  Future<void> _loadCachedConsent() async {
    try {
      _consented = (await _persistence.getBool(_consentKey)) ?? false;
    } catch (e) {
      debugPrint('Failed to load AI consent: $e');
    }
  }

  /// Returns true if the user has previously granted consent.
  Future<bool> hasConsented() async {
    if (_consented) return true;
    // First call only: seed the cache from disk, then answer from memory until
    // a mutation changes it.
    try {
      final stored = await _persistence.getBool(_consentKey);
      if (stored != null) {
        _consented = stored;
        return _consented;
      }
    } catch (e) {
      debugPrint('Failed to read AI consent: $e');
    }
    // Key absent (or read failed): treat as not-consented and remember it so
    // subsequent calls skip the disk entirely.
    return _consented;
  }

  /// Persists that the user has granted consent.
  Future<void> setConsented() async {
    _consented = true;
    try {
      await _persistence.setBool(_consentKey, true);
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

    final accepted = await showAiConsentSheet(featureLabel: featureLabel);
    if (accepted) {
      await setConsented();
    }
    return accepted;
  }
}
