import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_handler.dart';
import '../models/ai_settings_model.dart';
import '../repositories/ai_settings_repository.dart';

final aiSettingsRepositoryProvider = Provider<AiSettingsRepository>(
  (ref) => AiSettingsRepository(),
);

final aiSettingsProvider =
    AsyncNotifierProvider.autoDispose<AiSettingsNotifier, AiSettingsModel>(
      AiSettingsNotifier.new,
    );

/// Adds a scheme to a bare host: http for localhost, https otherwise.
String normalizeApiUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  if (trimmed.startsWith('localhost') || trimmed.startsWith('127.0.0.1')) {
    return 'http://$trimmed';
  }
  return 'https://$trimmed';
}

/// The user's AI provider settings.
class AiSettingsNotifier extends AsyncNotifier<AiSettingsModel> {
  AiSettingsRepository get _repository =>
      ref.read(aiSettingsRepositoryProvider);

  @override
  Future<AiSettingsModel> build() => _repository.getSettings();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getSettings);
  }

  /// Saves one provider's config. Returns true on success. Validation and
  /// results are shown as messages.
  Future<bool> save({
    required String provider,
    required String apiUrl,
    required String apiKey,
    required String chatModel,
    required String visionModel,
    required String imageModel,
  }) async {
    final url = normalizeApiUrl(apiUrl);
    final key = apiKey.trim();
    final keySet = state.value?.providerConfigs[provider]?.apiKeySet ?? false;
    if (provider.isEmpty) {
      ErrorHandler.showValidation(
        ErrorHandler.l10n?.settingsAiChooseProviderBody ?? 'Choose a provider.',
        title: ErrorHandler.l10n?.settingsNotSavedTitle ?? 'Not saved',
      );
      return false;
    }
    if (provider == 'custom' && url.isEmpty) {
      ErrorHandler.showValidation(
        ErrorHandler.l10n?.settingsAiCustomUrlRequiredBody ??
            'A custom provider needs an API URL.',
        title: ErrorHandler.l10n?.settingsNotSavedTitle ?? 'Not saved',
      );
      return false;
    }
    if (!keySet && key.isEmpty) {
      ErrorHandler.showValidation(
        ErrorHandler.l10n?.settingsAiKeyRequiredBody ?? 'Enter an API key.',
        title: ErrorHandler.l10n?.settingsNotSavedTitle ?? 'Not saved',
      );
      return false;
    }
    final payload = <String, dynamic>{
      if (url.isNotEmpty) 'api_url': url,
      if (key.isNotEmpty) 'api_key': key,
      if (chatModel.trim().isNotEmpty) 'model': chatModel.trim(),
      if (visionModel.trim().isNotEmpty) 'vision_model': visionModel.trim(),
      if (imageModel.trim().isNotEmpty) 'image_gen_model': imageModel.trim(),
    };
    try {
      final updated = await _repository.updateSettings(
        defaultProvider: provider,
        providerConfigs: {provider: payload},
      );
      if (ref.mounted) state = AsyncData(updated);
      ErrorHandler.showSuccess(
        ErrorHandler.l10n?.settingsAiSavedBody ?? 'Your AI settings are saved.',
        title: ErrorHandler.l10n?.settingsSavedTitle ?? 'Saved',
      );
      return true;
    } catch (e, stack) {
      ErrorHandler.showError(
        e,
        title: ErrorHandler.l10n?.settingsNotSavedTitle ?? 'Not saved',
        stackTrace: stack,
      );
      return false;
    }
  }

  /// Sends a test prompt. The saved key is never returned by the server,
  /// so a test needs the key typed in.
  Future<void> test({
    required String provider,
    required String apiUrl,
    required String apiKey,
    required String chatModel,
  }) async {
    final url = normalizeApiUrl(apiUrl);
    final key = apiKey.trim();
    final model = chatModel.trim();
    if (url.isEmpty || model.isEmpty) {
      ErrorHandler.showInfo(
        ErrorHandler.l10n?.settingsAiUrlAndModelRequiredBody ??
            'Enter an API URL and a chat model to test.',
        title:
            ErrorHandler.l10n?.settingsAiMissingDetailsTitle ?? 'Missing details',
      );
      return;
    }
    if (key.isEmpty) {
      final keySet = state.value?.providerConfigs[provider]?.apiKeySet ?? false;
      ErrorHandler.showInfo(
        keySet
            ? (ErrorHandler.l10n?.settingsAiKeyToTestPrivateBody ??
                  'Enter your API key to test. Your saved key stays private.')
            : (ErrorHandler.l10n?.settingsAiKeyToTestBody ??
                  'Enter your API key to test.'),
        title: ErrorHandler.l10n?.settingsAiKeyNeededTitle ?? 'API key needed',
      );
      return;
    }
    try {
      final result = await _repository.testProvider(
        apiUrl: url,
        apiKey: key,
        model: model,
      );
      if (result.success) {
        ErrorHandler.showSuccess(
          ErrorHandler.l10n?.settingsAiConnectedBody ?? 'The connection works.',
          title: ErrorHandler.l10n?.settingsAiConnectedTitle ?? 'Connected',
        );
      } else {
        ErrorHandler.showValidation(
          result.message,
          title: ErrorHandler.l10n?.settingsAiTestFailedTitle ?? 'Test failed',
        );
      }
    } catch (e, stack) {
      ErrorHandler.showError(
        e,
        title: ErrorHandler.l10n?.settingsAiTestFailedTitle ?? 'Test failed',
        stackTrace: stack,
      );
    }
  }
}
