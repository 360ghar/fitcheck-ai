import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import 'widgets/auth_ui.dart';

/// Forgot password page
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = Get.find<AuthController>();

    try {
      await authController.requestPasswordReset(_emailController.text.trim());
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Get.back();
      }
    } catch (e) {
      // Error is already handled by controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final tokens = AuthUiTokens.of(context);
    final screenSize = MediaQuery.of(context).size;
    final titleSize = (screenSize.width * 0.085).clamp(24.0, 36.0);
    final bodySize = (screenSize.width * 0.04).clamp(14.0, 16.0);

    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthHeaderBar(
            textColor: tokens.textColor,
            brandColor: tokens.brandColor,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: tokens.textColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Enter your email and we will send a secure reset link.',
                style: TextStyle(
                  fontSize: bodySize,
                  color: tokens.secondaryTextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              AuthGlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildEmailField(tokens),
                      const SizedBox(height: AppConstants.spacing20),
                      Obx(() => _buildSubmitButton(authController, tokens)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomLinks(tokens),
        ],
      ),
    );
  }

  Widget _buildEmailField(AuthUiTokens tokens) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleResetRequest(),
      style: TextStyle(color: tokens.textColor),
      cursorColor: tokens.brandColor,
      decoration: AuthFormStyles.inputDecoration(
        context: context,
        label: 'Email',
        hint: 'Enter your email',
        icon: Icons.mail,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!GetUtils.isEmail(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(AuthController authController, AuthUiTokens tokens) {
    return ElevatedButton(
      onPressed: authController.isLoading.value ? null : _handleResetRequest,
      style: ElevatedButton.styleFrom(
        backgroundColor: tokens.brandColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
      child: authController.isLoading.value
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Send Reset Link'),
    );
  }

  Widget _buildBottomLinks(AuthUiTokens tokens) {
    return Column(
      children: [
        TextButton(
          onPressed: () => Get.offNamed(Routes.login),
          style: TextButton.styleFrom(
            foregroundColor: tokens.textColor,
          ),
          child: const Text('Back to Sign In'),
        ),
        const SizedBox(height: AppConstants.spacing12),
        AuthFooterText(textColor: tokens.textColor),
      ],
    );
  }
}
