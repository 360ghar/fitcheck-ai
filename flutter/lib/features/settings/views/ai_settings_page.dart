import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/ai_settings_model.dart';
import '../providers/ai_settings_provider.dart';

/// Bring-your-own AI provider settings.
class AiSettingsPage extends ConsumerWidget {
  const AiSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(aiSettingsProvider);
    final notifier = ref.read(aiSettingsProvider.notifier);

    final Widget body;
    if (settings.value case final value?) {
      body = _AiSettingsForm(
        initial: value,
        banner: settings.hasError && !settings.isLoading
            ? AppErrorBanner(error: settings.error, onRetry: notifier.refresh)
            : null,
      );
    } else if (settings.hasError && !settings.isLoading) {
      body = AppErrorState(error: settings.error, onRetry: notifier.refresh);
    } else {
      body = ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: const [
          SkeletonPulse(
            child: Column(
              children: [
                SkeletonBox(height: 120, borderRadius: AppConstants.radius12),
                SizedBox(height: AppConstants.spacing16),
                SkeletonBox(height: 320, borderRadius: AppConstants.radius12),
              ],
            ),
          ),
        ],
      );
    }

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: const Text('AI provider')),
        body: AppPageBackground(child: body),
      ),
    );
  }
}

class _AiSettingsForm extends ConsumerStatefulWidget {
  const _AiSettingsForm({required this.initial, this.banner});

  /// Settings when the form first opens. Later changes (after a save) are
  /// read from the provider.
  final AiSettingsModel initial;
  final Widget? banner;

  @override
  ConsumerState<_AiSettingsForm> createState() => _AiSettingsFormState();
}

class _AiSettingsFormState extends ConsumerState<_AiSettingsForm> {
  final _apiUrl = TextEditingController();
  final _apiKey = TextEditingController();
  final _chatModel = TextEditingController();
  final _visionModel = TextEditingController();
  final _imageModel = TextEditingController();
  late String _provider = widget.initial.defaultProvider.isNotEmpty
      ? widget.initial.defaultProvider
      : 'custom';
  bool _saving = false;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _load(widget.initial);
  }

  @override
  void dispose() {
    for (final c in [_apiUrl, _apiKey, _chatModel, _visionModel, _imageModel]) {
      c.dispose();
    }
    super.dispose();
  }

  void _load(AiSettingsModel settings) {
    final config = settings.providerConfigs[_provider];
    _apiUrl.text = normalizeApiUrl(config?.apiUrl ?? '');
    _chatModel.text = config?.model ?? '';
    _visionModel.text = config?.visionModel ?? '';
    _imageModel.text = config?.imageGenModel ?? '';
    // The saved key is never sent back; the field is for a new key only.
    _apiKey.clear();
  }

  AiSettingsModel get _current =>
      ref.read(aiSettingsProvider).value ?? widget.initial;

  Future<void> _save() async {
    setState(() => _saving = true);
    final saved = await ref
        .read(aiSettingsProvider.notifier)
        .save(
          provider: _provider,
          apiUrl: _apiUrl.text,
          apiKey: _apiKey.text,
          chatModel: _chatModel.text,
          visionModel: _visionModel.text,
          imageModel: _imageModel.text,
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (saved) _load(_current);
    });
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    await ref
        .read(aiSettingsProvider.notifier)
        .test(
          provider: _provider,
          apiUrl: _apiUrl.text,
          apiKey: _apiKey.text,
          chatModel: _chatModel.text,
        );
    if (mounted) setState(() => _testing = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final keySet = _current.providerConfigs[_provider]?.apiKeySet ?? false;
    const gap = SizedBox(height: AppConstants.spacing12);
    final note = text.bodySmall?.copyWith(color: tokens.textMuted);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        AppConstants.spacing32 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        ?widget.banner,
        PaperSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Provider', style: text.headlineSmall),
              const SizedBox(height: AppConstants.spacing12),
              SegmentedButton<String>(
                showSelectedIcon: false,
                // The tint alone barely shows on dark paper; the tonal accent does.
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: PaperTokens.of(context).stock.accent,
                  selectedForegroundColor: PaperTokens.of(
                    context,
                  ).stock.onAccent,
                ),
                segments: const [
                  ButtonSegment(value: 'custom', label: Text('Custom')),
                  ButtonSegment(value: 'openai', label: Text('OpenAI')),
                ],
                selected: {_provider},
                onSelectionChanged: (s) => setState(() {
                  _provider = s.first;
                  _load(_current);
                }),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Use a public URL the server can reach. Localhost does not '
                'work from our servers.',
                style: note,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        PaperSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Connection', style: text.headlineSmall),
              const SizedBox(height: AppConstants.spacing12),
              TextField(
                controller: _apiUrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'API URL',
                  hintText: 'https://your-proxy.example.com/v1',
                ),
              ),
              gap,
              TextField(
                controller: _apiKey,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'API key',
                  hintText: keySet ? 'Saved. Leave blank to keep it.' : null,
                ),
              ),
              gap,
              TextField(
                controller: _chatModel,
                decoration: const InputDecoration(labelText: 'Chat model'),
              ),
              gap,
              TextField(
                controller: _visionModel,
                decoration: const InputDecoration(
                  labelText: 'Vision model (optional)',
                ),
              ),
              gap,
              TextField(
                controller: _imageModel,
                decoration: const InputDecoration(
                  labelText: 'Image model (optional)',
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Image generation needs OpenAI-compatible chat completions '
                'with response_modalities.',
                style: note,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing24),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: _saving ? const _Spinner() : const Text('Save'),
        ),
        const SizedBox(height: AppConstants.spacing8),
        TextButton(
          onPressed: _testing ? null : _test,
          style: TextButton.styleFrom(minimumSize: const Size.fromHeight(44)),
          child: _testing ? const _Spinner() : const Text('Test connection'),
        ),
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
