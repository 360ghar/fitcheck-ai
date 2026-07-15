import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import 'app_ui.dart';

/// Reusable bottom sheet that requests explicit consent before sharing user
/// photos with third-party AI providers (Apple Guideline 5.1.2(i)).
///
/// Shown via [showAiConsentSheet] which returns `true` when the user agrees,
/// `false` (or `null`, treated as false) otherwise. The sheet is intentionally
/// non-dismissible so the user must make an explicit choice.
Future<bool> showAiConsentSheet({required String featureLabel}) async {
  final result = await Get.bottomSheet<bool>(
    _AiConsentSheet(featureLabel: featureLabel),
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
  );
  return result ?? false;
}

class _AiConsentSheet extends StatelessWidget {
  final String featureLabel;

  const _AiConsentSheet({required this.featureLabel});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radius24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: tokens.brandColor),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Image Generation — Data Sharing Notice',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: tokens.textPrimary,
                              ),
                        ),
                        Text(
                          featureLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'To create your try-on and photoshoot images, FitCheck AI sends '
                'the photos you provide (including images of your face and body) '
                'to a trusted third-party AI provider (OpenAI) for processing. '
                'They generate your images and do not use them to train their '
                'models under our terms. Photos are transmitted securely and '
                'never shared for advertising.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'By continuing, you give explicit permission to share your '
                'photos with these AI providers for image generation.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _openPrivacyPolicy,
                  child: const Text('View Privacy Policy'),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('I Agree & Continue'),
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Not Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
