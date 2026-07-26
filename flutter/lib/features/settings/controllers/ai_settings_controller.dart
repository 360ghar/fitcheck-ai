import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ai_settings_model.dart';
import '../repositories/ai_settings_repository.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

class AiSettingsController extends GetxController {
  final AiSettingsRepository _repository = AiSettingsRepository();

  final Rx<AiSettingsModel?> settings = Rx<AiSettingsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isTesting = false.obs;
  final RxString error = ''.obs;

  final RxString selectedProvider = 'custom'.obs;

  final TextEditingController apiUrlController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController chatModelController = TextEditingController();
  final TextEditingController visionModelController = TextEditingController();
  final TextEditingController imageModelController = TextEditingController();

  bool get apiKeySet {
    final config = settings.value?.providerConfigs[selectedProvider.value];
    return config?.apiKeySet ?? false;
  }

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    apiUrlController.dispose();
    apiKeyController.dispose();
    chatModelController.dispose();
    visionModelController.dispose();
    imageModelController.dispose();
    super.onClose();
  }

  Future<void> fetchSettings() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      isLoading.value = true;
      error.value = '';
      final fetched = await _repository.getSettings();
      settings.value = fetched;
      selectedProvider.value = fetched.defaultProvider.isNotEmpty
          ? fetched.defaultProvider
          : 'custom';
      _loadProviderConfig(selectedProvider.value);
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  void selectProvider(String provider) {
    selectedProvider.value = provider;
    _loadProviderConfig(provider);
  }

  void _loadProviderConfig(String provider) {
    final config = settings.value?.providerConfigs[provider];
    apiUrlController.text = _normalizeApiUrl(config?.apiUrl ?? '');
    chatModelController.text = config?.model ?? '';
    visionModelController.text = config?.visionModel ?? '';
    imageModelController.text = config?.imageGenModel ?? '';
    apiKeyController.text = '';
  }

  Future<void> saveSettings() async {
    final provider = selectedProvider.value;
    final apiUrl = _normalizeApiUrl(apiUrlController.text);
    final apiKey = apiKeyController.text.trim();
    final chatModel = chatModelController.text.trim();
    final visionModel = visionModelController.text.trim();
    final imageModel = imageModelController.text.trim();

    if (provider.isEmpty) {
      ErrorHandler.showValidation('Please select a provider', title: 'Error');
      return;
    }

    if (provider == 'custom' && apiUrl.isEmpty) {
      ErrorHandler.showValidation('API URL is required for custom providers', title: 'Error');
      return;
    }

    if (!apiKeySet && apiKey.isEmpty) {
      ErrorHandler.showValidation('API key is required', title: 'Error');
      return;
    }

    final providerPayload = <String, dynamic>{};
    if (apiUrl.isNotEmpty) providerPayload['api_url'] = apiUrl;
    if (apiKey.isNotEmpty) providerPayload['api_key'] = apiKey;
    if (chatModel.isNotEmpty) providerPayload['model'] = chatModel;
    if (visionModel.isNotEmpty) providerPayload['vision_model'] = visionModel;
    if (imageModel.isNotEmpty) providerPayload['image_gen_model'] = imageModel;

    try {
      isSaving.value = true;
      error.value = '';
      final updated = await _repository.updateSettings(
        defaultProvider: provider,
        providerConfigs: {
          provider: providerPayload,
        },
      );
      settings.value = updated;
      apiUrlController.text = apiUrl;
      _loadProviderConfig(provider);
      ErrorHandler.showSuccess('AI settings updated', title: 'Saved');
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Error');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> testProvider() async {
    final apiUrl = _normalizeApiUrl(apiUrlController.text);
    final apiKey = apiKeyController.text.trim();
    final chatModel = chatModelController.text.trim();

    if (apiUrl.isEmpty || apiKey.isEmpty || chatModel.isEmpty) {
      ErrorHandler.showInfo('API URL, key, and chat model are required to test', title: 'Missing Info');
      return;
    }

    try {
      isTesting.value = true;
      final result = await _repository.testProvider(
        apiUrl: apiUrl,
        apiKey: apiKey,
        model: chatModel,
      );
      apiUrlController.text = apiUrl;
      if (result.success) {
        ErrorHandler.showSuccess('Connection successful', title: 'Success');
      } else {
        ErrorHandler.showError(result.message, title: 'Test Failed');
      }
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Test Failed');
    } finally {
      isTesting.value = false;
    }
  }

  String _normalizeApiUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('localhost') || trimmed.startsWith('127.0.0.1')) {
      return 'http://$trimmed';
    }
    return 'https://$trimmed';
  }
}
