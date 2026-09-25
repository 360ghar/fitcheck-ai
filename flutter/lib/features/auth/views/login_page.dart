import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_ui.dart';

/// Email, Apple and Google sign-in.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  AuthNotifier get _auth => ref.read(authProvider.notifier);

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_auth.clearEmailVerificationError);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Keyboard submit skips the disabled button, so guard here too.
    if (ref.read(authProvider).busy != AuthBusy.none) return;
    if (!_formKey.currentState!.validate()) return;
    await _auth.login(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authProvider.select((s) => s.busy));
    final unverified = ref.watch(authProvider.select((s) => s.unverifiedEmail));
    final tokens = PaperTokens.of(context);

    return AuthScaffold(
      showBack: true,
      sceneFraction: 0.26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeading(
            title: 'Welcome back',
            subtitle: 'Sign in to open your closet.',
          ),
          const SizedBox(height: AppConstants.spacing20),
          AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: AuthFormStyles.inputDecoration(
                      label: 'Email',
                      icon: Icons.mail_outline_rounded,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your email';
                      if (!isValidEmail(v.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    decoration: AuthFormStyles.inputDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        tooltip: _passwordVisible
                            ? 'Hide password'
                            : 'Show password',
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your password';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(Routes.forgotPassword),
              child: const Text('Forgot password?'),
            ),
          ),
          if (unverified != null) ...[
            _VerifyEmailPanel(
              email: unverified,
              sending: busy == AuthBusy.resend,
              onResend: _auth.resendVerificationEmail,
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],
          AuthPrimaryButton(
            label: 'Sign in',
            isLoading: busy == AuthBusy.email,
            onPressed: _submit,
          ),
          const SizedBox(height: AppConstants.spacing20),
          const AuthDivider(),
          const SizedBox(height: AppConstants.spacing20),
          if (!kIsWeb && Platform.isIOS) ...[
            AppleSignInButton(
              isLoading: busy == AuthBusy.apple,
              onPressed: busy == AuthBusy.none ? _auth.signInWithApple : () {},
            ),
            const SizedBox(height: AppConstants.spacing12),
          ],
          GoogleSignInButton(
            isLoading: busy == AuthBusy.google,
            onPressed: _auth.signInWithGoogle,
          ),
          const Spacer(),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New here?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () => context.pushReplacement(Routes.register),
                child: const Text('Create an account'),
              ),
            ],
          ),
          const AuthFooterText(),
        ],
      ),
    );
  }
}

class _VerifyEmailPanel extends StatelessWidget {
  const _VerifyEmailPanel({
    required this.email,
    required this.sending,
    required this.onResend,
  });

  final String email;
  final bool sending;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return PaperSurface(
      color: tokens.stock.tint,
      lift: 0,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing12,
        AppConstants.spacing8,
        AppConstants.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.mark_email_unread_outlined, color: tokens.warning),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Text(
                  'Confirm $email before you sign in. Check your inbox.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: sending ? null : onResend,
              child: Text(sending ? 'Sending…' : 'Send it again'),
            ),
          ),
        ],
      ),
    );
  }
}
