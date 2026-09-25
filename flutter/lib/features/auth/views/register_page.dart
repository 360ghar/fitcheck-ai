import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_ui.dart';

/// Account creation with an optional referral code.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _referralController = TextEditingController();
  bool _passwordVisible = false;
  Timer? _referralDebounce;

  /// Null while unchecked; the code the result belongs to is kept so a
  /// late response for an older code is dropped.
  ({String code, bool valid, String? referrer})? _referral;

  AuthNotifier get _auth => ref.read(authProvider.notifier);
  String get _referralCode => _referralController.text.trim();

  @override
  void dispose() {
    _referralDebounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _onReferralChanged(String value) {
    _referralDebounce?.cancel();
    if (_referral != null) setState(() => _referral = null);
    final code = value.trim();
    if (code.length < 3) return;
    _referralDebounce = Timer(const Duration(milliseconds: 500), () async {
      bool valid;
      String? referrer;
      try {
        final result = await SubscriptionRepository().validateReferralCode(code);
        valid = result.valid;
        referrer = result.referrerName;
      } catch (_) {
        valid = false;
      }
      if (!mounted || code != _referralCode) return;
      setState(() => _referral = (code: code, valid: valid, referrer: referrer));
    });
  }

  Future<void> _submit() async {
    if (ref.read(authProvider).busy != AuthBusy.none) return;
    if (!_formKey.currentState!.validate()) return;
    await _auth.register(
      _emailController.text.trim(),
      _passwordController.text,
      fullName: _nameController.text.trim(),
      referralCode: _referralCode,
    );
  }

  /// Keeps the referral code across the OAuth round trip.
  Future<void> _social(Future<void> Function() signIn) async {
    if (_referralCode.isNotEmpty) {
      await _auth.setPendingReferralCode(_referralCode);
    }
    await signIn();
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authProvider.select((s) => s.busy));
    final tokens = PaperTokens.of(context);
    final referral = _referral;

    return AuthScaffold(
      showBack: true,
      sceneFraction: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeading(
            title: 'Create your closet',
            subtitle: 'It takes a minute. Your first items are free.',
          ),
          const SizedBox(height: AppConstants.spacing20),
          AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    decoration: AuthFormStyles.inputDecoration(
                      label: 'Name',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
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
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
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
                      if (v == null || v.isEmpty) return 'Choose a password';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: !_passwordVisible,
                    textInputAction: TextInputAction.next,
                    decoration: AuthFormStyles.inputDecoration(
                      label: 'Confirm password',
                      icon: Icons.lock_outline_rounded,
                    ),
                    validator: (v) => v != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  TextFormField(
                    controller: _referralController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: _onReferralChanged,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: AuthFormStyles.inputDecoration(
                      label: 'Referral code (optional)',
                      icon: Icons.redeem_outlined,
                      suffixIcon: referral == null
                          ? null
                          : Icon(
                              referral.valid
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline_rounded,
                              color: referral.valid
                                  ? tokens.success
                                  : tokens.error,
                              semanticLabel: referral.valid
                                  ? 'Code accepted'
                                  : 'Code not found',
                            ),
                    ).copyWith(
                      helperText: referral == null
                          ? null
                          : referral.valid && referral.referrer != null
                          ? 'From ${referral.referrer}. You both get a month free.'
                          : referral.valid
                          ? null
                          : 'We could not find this code.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing20),
          AuthPrimaryButton(
            label: 'Create account',
            isLoading: busy == AuthBusy.email,
            onPressed: _submit,
          ),
          const SizedBox(height: AppConstants.spacing20),
          const AuthDivider(),
          const SizedBox(height: AppConstants.spacing20),
          if (!kIsWeb && Platform.isIOS) ...[
            AppleSignInButton(
              isLoading: busy == AuthBusy.apple,
              onPressed: busy == AuthBusy.none
                  ? () => _social(_auth.signInWithApple)
                  : () {},
            ),
            const SizedBox(height: AppConstants.spacing12),
          ],
          GoogleSignInButton(
            isLoading: busy == AuthBusy.google,
            onPressed: () => _social(_auth.signInWithGoogle),
          ),
          const Spacer(),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Have an account?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () => context.pushReplacement(Routes.login),
                child: const Text('Sign in'),
              ),
            ],
          ),
          const AuthFooterText(),
        ],
      ),
    );
  }
}
