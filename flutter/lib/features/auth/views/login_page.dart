import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import 'widgets/auth_ui.dart';

/// Login page with email/password and Google OAuth
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isPasswordVisible = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = Get.find<AuthController>();

    try {
      await authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      // Error is already handled by controller
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authController = Get.find<AuthController>();

    try {
      await authController.signInWithGoogle();
    } catch (e) {
      // Error is already handled by controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final tokens = AuthUiTokens.of(context);
    final screenSize = MediaQuery.of(context).size;
    final titleSize = (screenSize.width * 0.09).clamp(26.0, 40.0);
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
                'Welcome Back',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: tokens.textColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Sign in to access your AI-powered virtual closet.',
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
                      const SizedBox(height: AppConstants.spacing16),
                      _buildPasswordField(tokens),
                      const SizedBox(height: AppConstants.spacing8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed(Routes.forgotPassword),
                          style: TextButton.styleFrom(
                            foregroundColor: tokens.textColor.withOpacity(0.85),
                          ),
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Obx(() => _buildLoginButton(authController, tokens)),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildDivider(tokens),
                      const SizedBox(height: AppConstants.spacing16),
                      Obx(() => _buildGoogleSignInButton(authController, tokens)),
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
      textInputAction: TextInputAction.next,
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

  Widget _buildPasswordField(AuthUiTokens tokens) {
    return Obx(() => TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible.value,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          style: TextStyle(color: tokens.textColor),
          cursorColor: tokens.brandColor,
          decoration: AuthFormStyles.inputDecoration(
            context: context,
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: tokens.fieldIconColor,
              ),
              onPressed: () {
                _isPasswordVisible.value = !_isPasswordVisible.value;
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ));
  }

  Widget _buildLoginButton(AuthController authController, AuthUiTokens tokens) {
    return ElevatedButton(
      onPressed: authController.isLoading.value ? null : _handleLogin,
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
          : const Text('Sign In'),
    );
  }

  Widget _buildDivider(AuthUiTokens tokens) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: tokens.textColor.withOpacity(0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
          child: Text(
            'OR',
            style: TextStyle(
              color: tokens.textColor.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: tokens.textColor.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(AuthController authController, AuthUiTokens tokens) {
    final isLoading = authController.isGoogleSigningIn.value;
    return OutlinedButton.icon(
      onPressed: isLoading ? null : _handleGoogleSignIn,
      icon: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.login),
      label: Text(isLoading ? 'Signing in...' : 'Continue with Google'),
      style: OutlinedButton.styleFrom(
        foregroundColor: tokens.textColor,
        side: BorderSide(color: tokens.textColor.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius16),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildBottomLinks(AuthUiTokens tokens) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: tokens.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(Routes.register),
              style: TextButton.styleFrom(
                foregroundColor: tokens.textColor,
              ),
              child: const Text('Sign Up'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing12),
        AuthFooterText(textColor: tokens.textColor),
      ],
    );
  }
}
