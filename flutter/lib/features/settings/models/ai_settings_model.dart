class AiProviderConfig {
  final String apiUrl;
  final String model;
  final String visionModel;
  final String imageGenModel;
  final bool apiKeySet;

  const AiProviderConfig({
    required this.apiUrl,
    required this.model,
    required this.visionModel,
    required this.imageGenModel,
    required this.apiKeySet,
  });

  factory AiProviderConfig.fromJson(Map<String, dynamic> json) {
    return AiProviderConfig(
      apiUrl: json['api_url']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      visionModel: json['vision_model']?.toString() ?? '',
      imageGenModel: json['image_gen_model']?.toString() ?? '',
      apiKeySet: json['api_key_set'] == true,
    );
  }
}

class AiSettingsModel {
  final String defaultProvider;
  final Map<String, AiProviderConfig> providerConfigs;
  final Map<String, dynamic>? usage;

  const AiSettingsModel({
    required this.defaultProvider,
    required this.providerConfigs,
    this.usage,
  });

  factory AiSettingsModel.fromJson(Map<String, dynamic> json) {
    final configs = <String, AiProviderConfig>{};
    final rawConfigs = json['provider_configs'];
    if (rawConfigs is Map) {
      rawConfigs.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          configs[key.toString()] = AiProviderConfig.fromJson(value);
        }
      });
    }

    return AiSettingsModel(
      defaultProvider: json['default_provider']?.toString() ?? 'custom',
      providerConfigs: configs,
      usage: json['usage'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AiProviderTestResult {
  final bool success;
  final String message;
  final String? model;
  final String? response;

  const AiProviderTestResult({
    required this.success,
    required this.message,
    this.model,
    this.response,
  });

  factory AiProviderTestResult.fromJson(Map<String, dynamic> json) {
    return AiProviderTestResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'Unknown error',
      model: json['model']?.toString(),
      response: json['response']?.toString(),
    );
  }
}
