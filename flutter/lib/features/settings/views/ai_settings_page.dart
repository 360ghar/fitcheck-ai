import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/ai_settings_controller.dart';

class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  late final AiSettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AiSettingsController>();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                sliver: Obx(() => _buildContent(context)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return SliverAppBar(
      floating: true,
      elevation: 0,
      title: Text(
        'AI Settings',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (controller.isLoading.value && controller.settings.value == null) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildProviderSection(context),
        const SizedBox(height: AppConstants.spacing24),
        _buildConfigSection(context),
        const SizedBox(height: AppConstants.spacing24),
        _buildActionsSection(),
      ]),
    );
  }

  Widget _buildProviderSection(BuildContext context) {
    return _buildSection(
      title: 'Provider',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: controller.selectedProvider.value,
            decoration: const InputDecoration(
              labelText: 'Default Provider',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'custom', child: Text('Custom')),
              DropdownMenuItem(value: 'gemini', child: Text('Gemini')),
              DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.selectProvider(value);
              }
            },
          ),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            'Use a public URL reachable from the backend. Localhost URLs will not work for deployed servers.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppUiTokens.of(context).textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final keyHint = controller.apiKeySet
        ? 'API key already set (leave blank to keep)'
        : 'Enter API key';

    return _buildSection(
      title: 'Configuration',
      child: Column(
        children: [
          TextField(
            controller: controller.apiUrlController,
            decoration: const InputDecoration(
              labelText: 'API URL',
              hintText: 'https://your-proxy.example.com/v1',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: controller.apiKeyController,
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: keyHint,
              border: const OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: controller.chatModelController,
            decoration: const InputDecoration(
              labelText: 'Chat Model',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: controller.visionModelController,
            decoration: const InputDecoration(
              labelText: 'Vision Model (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: controller.imageModelController,
            decoration: const InputDecoration(
              labelText: 'Image Model (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'For image generation, your provider must support OpenAI-compatible chat completions with response_modalities.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return _buildSection(
      title: 'Actions',
      child: Column(
        children: [
          Obx(() {
            return ElevatedButton(
              onPressed: controller.isTesting.value
                  ? null
                  : () => controller.testProvider(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: controller.isTesting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Connection'),
            );
          }),
          const SizedBox(height: AppConstants.spacing12),
          Obx(() {
            return OutlinedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () => controller.saveSettings(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Settings'),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: AppConstants.spacing8),
        AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: child,
        ),
      ],
    );
  }
}
