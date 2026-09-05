import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/gift_controller.dart';
import '../models/gift_models.dart';

class GiftVouchersPage extends StatefulWidget {
  const GiftVouchersPage({super.key});

  @override
  State<GiftVouchersPage> createState() => _GiftVouchersPageState();
}

class _GiftVouchersPageState extends State<GiftVouchersPage> {
  final _formKey = GlobalKey<FormState>();
  final _fromNameController = TextEditingController();
  final _toNameController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _messageController = TextEditingController();
  final _occasionGreetingController = TextEditingController();
  final _random = Random.secure();

  late final GiftController _controller;
  int _durationMonths = 1;
  GiftOccasion? _occasion;
  String? _selectedIncomingId;
  String? _clientRequestId;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<GiftController>();
    final intent = Get.arguments is GiftRouteIntent
        ? Get.arguments as GiftRouteIntent
        : null;
    final durationMonths = intent?.durationMonths;
    if (durationMonths != null) {
      _durationMonths = durationMonths;
    }
    _selectedIncomingId = intent?.incomingVoucherId;
    for (final textController in [
      _fromNameController,
      _toNameController,
      _recipientEmailController,
      _messageController,
      _occasionGreetingController,
    ]) {
      textController.addListener(_handleFormInputChanged);
    }
  }

  void _handleFormInputChanged() {
    // Only invalidate the dedupe key here. The live preview rebuilds itself
    // via ListenableBuilder, so typing must not rebuild the whole page.
    _clientRequestId = null;
  }

  @override
  void dispose() {
    _fromNameController.dispose();
    _toNameController.dispose();
    _recipientEmailController.dispose();
    _messageController.dispose();
    _occasionGreetingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!EnvConfig.giftVouchersEnabled) {
      return const Scaffold(
        body: Center(
          child: Text('Gift invitations are not available in this build.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gift FitCheck Pro')),
      body: AppPageBackground(
        child: Obx(() {
          final summary = _controller.summary.value;
          if (summary == null && _controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            children: [
              if (_controller.error.value.isNotEmpty) ...[
                _ErrorCard(
                  message: _controller.error.value,
                  onRetry: () => _controller.load(),
                ),
                const SizedBox(height: AppConstants.spacing16),
              ],
              if (summary != null && summary.incoming.isNotEmpty) ...[
                _incomingSection(context, summary.incoming),
                const SizedBox(height: AppConstants.spacing24),
              ],
              if (summary != null) _creationSection(context, summary),
            ],
          );
        }),
      ),
    );
  }

  Widget _incomingSection(BuildContext context, List<GiftVoucher> incoming) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            incoming.length == 1
                ? 'A gift is waiting for you'
                : '${incoming.length} gifts are waiting for you',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppConstants.spacing12),
          for (final voucher in incoming) ...[
            _IncomingGiftTile(
              voucher: voucher,
              selected: voucher.id == _selectedIncomingId,
              isClaiming: _controller.claimingVoucherId.value == voucher.id,
              onClaim: () => _claim(voucher),
            ),
            if (voucher != incoming.last)
              const SizedBox(height: AppConstants.spacing8),
          ],
        ],
      ),
    );
  }

  Widget _creationSection(BuildContext context, GiftDashboardSummary summary) {
    final available = summary.allowances
        .where((allowance) => allowance.remainingCount > 0)
        .toList(growable: false);
    if (available.isEmpty) {
      return const AppGlassCard(
        child: Text('No free gift invitations are available right now.'),
      );
    }
    final selectedDuration =
        available.any(
          (allowance) => allowance.durationMonths == _durationMonths,
        )
        ? _durationMonths
        : available.first.durationMonths;

    return Form(
      key: _formKey,
      child: AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a free invitation',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppConstants.spacing4),
            const Text(
              'The recipient must claim the gift with this verified email. We do not send email for you.',
            ),
            const SizedBox(height: AppConstants.spacing16),
            Wrap(
              spacing: AppConstants.spacing8,
              children: available
                  .map(
                    (allowance) => ChoiceChip(
                      label: Text(
                        '${_term(allowance.durationMonths)} · ${allowance.remainingCount} left',
                      ),
                      selected: selectedDuration == allowance.durationMonths,
                      onSelected: (_) => setState(
                        () => _durationMonths = allowance.durationMonths,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: AppConstants.spacing16),
            TextFormField(
              controller: _fromNameController,
              decoration: const InputDecoration(labelText: 'From'),
              textInputAction: TextInputAction.next,
              maxLength: 80,
              validator: _requiredName,
            ),
            TextFormField(
              controller: _toNameController,
              decoration: const InputDecoration(labelText: 'Recipient name'),
              textInputAction: TextInputAction.next,
              maxLength: 80,
              validator: _requiredName,
            ),
            TextFormField(
              controller: _recipientEmailController,
              decoration: const InputDecoration(labelText: 'Recipient email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              maxLength: 320,
              validator: _email,
            ),
            DropdownButtonFormField<String>(
              value: _occasion?.name ?? 'none',
              decoration: const InputDecoration(
                labelText: 'Occasion (optional)',
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('No occasion')),
                DropdownMenuItem(value: 'birthday', child: Text('Birthday')),
                DropdownMenuItem(
                  value: 'anniversary',
                  child: Text('Anniversary'),
                ),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() {
                  _occasion = giftOccasionFromApi(value);
                  if (_occasion != GiftOccasion.other) {
                    _occasionGreetingController.clear();
                  }
                  _clientRequestId = null;
                });
              },
            ),
            if (_occasion == GiftOccasion.other)
              TextFormField(
                controller: _occasionGreetingController,
                decoration: const InputDecoration(
                  labelText: 'Card greeting',
                  helperText: 'This appears on the card exactly as written.',
                ),
                textInputAction: TextInputAction.next,
                maxLength: 80,
                validator: _occasionGreeting,
              ),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Private note (optional)',
              ),
              maxLength: 240,
              minLines: 2,
              maxLines: 4,
            ),
            ListenableBuilder(
              listenable: Listenable.merge([
                _fromNameController,
                _toNameController,
                _messageController,
                _occasionGreetingController,
              ]),
              builder: (context, _) => _GiftPreview(
                fromName: _fromNameController.text,
                toName: _toNameController.text,
                greeting: giftOccasionGreeting(
                  _occasion,
                  _occasionGreetingController.text,
                ),
                message: _messageController.text,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _controller.isCreating.value
                    ? null
                    : () => _create(selectedDuration),
                icon: _controller.isCreating.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.card_giftcard),
                label: const Text('Create free gift'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _create(int durationMonths) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final voucher = await _controller.createComplimentary(
      durationMonths: durationMonths,
      fromName: _fromNameController.text.trim(),
      toName: _toNameController.text.trim(),
      recipientEmail: _recipientEmailController.text.trim().toLowerCase(),
      message: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
      occasion: _occasion,
      occasionGreeting: _occasion == GiftOccasion.other
          ? _occasionGreetingController.text.trim()
          : null,
      clientRequestId: _clientRequestId ??= _newRequestId(),
    );
    if (!mounted || voucher == null) return;
    _clientRequestId = null;
    _toNameController.clear();
    _recipientEmailController.clear();
    _messageController.clear();
    _occasionGreetingController.clear();
    setState(() => _occasion = null);
    await _share(voucher);
  }

  Future<void> _claim(GiftVoucher voucher) async {
    final result = await _controller.claimIncoming(voucher.id);
    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.entitlementStatus == 'active'
              ? 'Your FitCheck Pro gift is active.'
              : 'Your FitCheck Pro gift is queued after your current access.',
        ),
      ),
    );
  }

  Future<void> _share(GiftVoucher voucher) async {
    final link = voucher.shareUrl;
    if (link == null || link.isEmpty) return;
    try {
      final greeting = giftOccasionGreeting(
        voucher.occasion,
        voucher.occasionGreeting,
      );
      await Share.share(
        '${greeting == null ? '' : '$greeting — '}${voucher.fromName} sent you ${_term(voucher.durationMonths)} of FitCheck Pro. $link',
        subject: 'A FitCheck Pro gift for ${voucher.toName}',
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: link));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift link copied to the clipboard.')),
      );
    }
  }

  String _newRequestId() =>
      'gift-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  String? _requiredName(String? value) {
    return value?.trim().isNotEmpty == true ? null : 'Enter a name.';
  }

  String? _email(String? value) {
    final email = value?.trim() ?? '';
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
        ? null
        : 'Enter a valid email address.';
  }

  String? _occasionGreeting(String? value) {
    if (_occasion != GiftOccasion.other) return null;
    final greeting = value?.trim() ?? '';
    if (greeting.isEmpty) return 'Enter the card greeting.';
    if (greeting.length > 80) return 'Use no more than 80 characters.';
    return null;
  }

  String _term(int months) {
    if (months == 1) return '1 month';
    if (months == 12) return '1 year';
    return '$months months';
  }
}

class _IncomingGiftTile extends StatelessWidget {
  const _IncomingGiftTile({
    required this.voucher,
    required this.selected,
    required this.isClaiming,
    required this.onClaim,
  });

  final GiftVoucher voucher;
  final bool selected;
  final bool isClaiming;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final greeting = giftOccasionGreeting(
      voucher.occasion,
      voucher.occasionGreeting,
    );
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(
          color: selected ? tokens.brandColor : tokens.cardBorderColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'From ${voucher.fromName}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text('${_term(voucher.durationMonths)} of FitCheck Pro'),
          if (greeting != null) ...[
            const SizedBox(height: AppConstants.spacing4),
            Text(
              greeting,
              style: TextStyle(
                color: tokens.brandColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacing12),
          FilledButton.icon(
            onPressed: isClaiming ? null : onClaim,
            icon: isClaiming
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.card_giftcard),
            label: const Text('Claim gift'),
          ),
        ],
      ),
    );
  }

  String _term(int months) {
    if (months == 1) return '1 month';
    if (months == 12) return '1 year';
    return '$months months';
  }
}

class _GiftPreview extends StatelessWidget {
  const _GiftPreview({
    required this.fromName,
    required this.toName,
    required this.greeting,
    required this.message,
  });

  final String fromName;
  final String toName;
  final String? greeting;
  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card preview',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          if (greeting != null) ...[
            const SizedBox(height: AppConstants.spacing8),
            Text(
              greeting!,
              style: TextStyle(
                color: tokens.brandColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'For ${toName.trim().isEmpty ? 'your recipient' : toName.trim()}',
          ),
          Text('From ${fromName.trim().isEmpty ? 'you' : fromName.trim()}'),
          if (message.trim().isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacing8),
            Text('“${message.trim()}”'),
          ],
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
