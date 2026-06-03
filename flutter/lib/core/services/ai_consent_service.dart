import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/ai_consent_sheet.dart';

/// Service that records and gates the user's consent to sharing their photos
/// with third-party AI providers (Google Gemini / OpenAI) for image generation.
///
/// Required for Apple App Store Guideline 5.1.2(i): explicit permission must be
/// obtained before sharing user data with third parties. Consent is captured
/// once at the first AI-feature use and persisted locally via
/// SharedPreferences (modeled on [ThemeService]).
class AiConsentService extends GetxController {
  /// Versioned key so we can re-prompt if the disclosure materially changes.
  static const String _consentKey = 'fitcheck_ai_consent_v1';

  /// Cached in-memory value to avoid repeated disk reads after first check.
  bool _consented = false;

  @override
  void onInit() {
    super.onInit();
    _loadCachedConsent();
  }

  Future<void> _loadCachedConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _consented = prefs.getBool(_consentKey) ?? false;
    } catch (e) {
      debugPrint('Failed to load AI consent: $e');
    }
  }

  /// Returns true if the user has previously granted consent.
  Future<bool> hasConsented() async {
    if (_consented) return true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _consented = prefs.getBool(_consentKey) ?? false;
    } catch (e) {
      debugPrint('Failed to read AI consent: $e');
    }
    return _consented;
  }

  /// Persists that the user has granted consent.
  Future<void> setConsented() async {
    _consented = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_consentKey, true);
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
