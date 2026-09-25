import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_ui.dart';

/// Sends a password reset link.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _sentTo;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(authProvider).busy != AuthBusy.none) return;
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final sent = await ref
        .read(authProvider.notifier)
        .requestPasswordReset(email);
    if (sent && mounted) setState(() => _sentTo = email);
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authProvider.select((s) => s.busy));
    final tokens = PaperTokens.of(context);
    final sentTo = _sentTo;

    return AuthScaffold(
      showBack: true,
      sceneFraction: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeading(
            title: 'Reset your password',
            subtitle: 'We will email you a link to choose a new one.',
          ),
          const SizedBox(height: AppConstants.spacing20),
          if (sentTo == null) ...[
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => _submit(),
                decoration: AuthFormStyles.inputDecoration(
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                  if (!isValidEmail(v.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            AuthPrimaryButton(
              label: 'Send reset link',
              isLoading: busy == AuthBusy.reset,
              onPressed: _submit,
            ),
          ] else
            PaperSurface(
              color: tokens.stock.tint,
              lift: 0,
              child: Row(
                children: [
                  Icon(Icons.mark_email_read_outlined, color: tokens.success),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Text(
                      'Sent to $sentTo. Open the link on this phone.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          const SizedBox(height: AppConstants.spacing16),
          TextButton(
            onPressed: () => Navigator.maybePop(context),
            child: const Text('Back to sign in'),
          ),
          const AuthFooterText(),
        ],
      ),
    );
  }
}
