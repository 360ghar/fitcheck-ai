import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import 'widgets/auth_ui.dart';

/// Register page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _isPasswordVisible = false.obs;
  final _isConfirmPasswordVisible = false.obs;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = Get.find<AuthController>();

    try {
      await authController.register(
        _emailController.text.trim(),
        _passwordController.text,
        fullName: _nameController.text.trim(),
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
    final titleSize = (screenSize.width * 0.085).clamp(26.0, 38.0);
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
                'Create Account',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: tokens.textColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Start building your AI-powered wardrobe in minutes.',
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
                      _buildNameField(tokens),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildEmailField(tokens),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildPasswordField(tokens),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildConfirmPasswordField(tokens),
                      const SizedBox(height: AppConstants.spacing24),
                      Obx(() => _buildRegisterButton(authController, tokens)),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildDivider(tokens),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildGoogleSignInButton(tokens),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildLoginLink(tokens),
        ],
      ),
    );
  }

  Widget _buildNameField(AuthUiTokens tokens) {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      style: TextStyle(color: tokens.textColor),
      cursorColor: tokens.brandColor,
      decoration: AuthFormStyles.inputDecoration(
        context: context,
        label: 'Full Name',
        hint: 'Enter your name',
        icon: Icons.person,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
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
          textInputAction: TextInputAction.next,
          style: TextStyle(color: tokens.textColor),
          cursorColor: tokens.brandColor,
          decoration: AuthFormStyles.inputDecoration(
            context: context,
            label: 'Password',
            hint: 'Create a password',
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
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ));
  }

  Widget _buildConfirmPasswordField(AuthUiTokens tokens) {
    return Obx(() => TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible.value,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleRegister(),
          style: TextStyle(color: tokens.textColor),
          cursorColor: tokens.brandColor,
          decoration: AuthFormStyles.inputDecoration(
            context: context,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            icon: Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: tokens.fieldIconColor,
              ),
              onPressed: () {
                _isConfirmPasswordVisible.value =
                    !_isConfirmPasswordVisible.value;
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ));
  }

  Widget _buildRegisterButton(AuthController authController, AuthUiTokens tokens) {
    return ElevatedButton(
      onPressed: authController.isLoading.value ? null : _handleRegister,
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
          : const Text('Create Account'),
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

  Widget _buildGoogleSignInButton(AuthUiTokens tokens) {
    return OutlinedButton.icon(
      onPressed: _handleGoogleSignIn,
      icon: const Icon(Icons.login),
      label: const Text('Continue with Google'),
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

  Widget _buildLoginLink(AuthUiTokens tokens) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
                color: tokens.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () => Get.offNamed(Routes.login),
              style: TextButton.styleFrom(
                foregroundColor: tokens.textColor,
              ),
              child: const Text('Log In'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing12),
        AuthFooterText(textColor: tokens.textColor),
      ],
    );
  }
}
