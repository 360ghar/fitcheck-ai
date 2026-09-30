import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/request_id.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/gift_models.dart';
import '../providers/gift_providers.dart';

/// Incoming gifts to claim, and the form for a free named invitation.
class GiftVouchersPage extends ConsumerStatefulWidget {
  const GiftVouchersPage({super.key, this.intent});

  /// What the page opens for (for example a voucher to redeem).
  final GiftRouteIntent? intent;

  @override
  ConsumerState<GiftVouchersPage> createState() => _GiftVouchersPageState();
}

class _GiftVouchersPageState extends ConsumerState<GiftVouchersPage> {
  final _formKey = GlobalKey<FormState>();
  final _fromNameController = TextEditingController();
  final _toNameController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _messageController = TextEditingController();
  final _occasionGreetingController = TextEditingController();

  int _durationMonths = 1;
  GiftOccasion? _occasion;
  String? _selectedIncomingId;

  /// Idempotency key for the current form contents. Kept across retries of
  /// the same gift, cleared when the form changes or the gift is created.
  String? _clientRequestId;

  bool get _creating =>
      ref.read(giftBusyProvider).contains(GiftNotifier.createKey);

  @override
  void initState() {
    super.initState();
    final intent = widget.intent;
    _durationMonths = intent?.durationMonths ?? _durationMonths;
    _selectedIncomingId = intent?.incomingVoucherId;
    for (final c in [
      _fromNameController,
      _toNameController,
      _recipientEmailController,
      _messageController,
      _occasionGreetingController,
    ]) {
      c.addListener(_handleFormInputChanged);
    }
    // The summary may be minutes old (loaded for the home banner). Refresh
    // on entry, unless its first load is still running.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !EnvConfig.giftVouchersEnabled) return;
      if (!ref.read(giftProvider).isLoading) {
        ref.read(giftProvider.notifier).refresh();
      }
    });
  }

  void _handleFormInputChanged() {
    // A changed form is a different gift, so it needs a new key. The fields
    // are disabled while creating, so the key survives a retry after a lost
    // response.
    if (!_creating) _clientRequestId = null;
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
    final Widget body;
    if (!EnvConfig.giftVouchersEnabled) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing24),
          child: Text(
            'Gift invitations are not available in this build.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      final gift = ref.watch(giftProvider);
      final summary = ref.watch(liveGiftSummaryProvider);
      final bottom = MediaQuery.paddingOf(context).bottom;
      final padding = EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing32 + bottom,
      );
      if (gift.hasError) {
        // No stale summary: it could offer a gift already claimed elsewhere.
        body = AppErrorState(
          error: gift.error,
          onRetry: () => ref.read(giftProvider.notifier).refresh(),
        );
      } else if (summary == null) {
        body = ListView(
          padding: padding,
          children: const [
            SkeletonPulse(
              child: Column(
                children: [
                  SkeletonBox(height: 150, borderRadius: AppConstants.radius12),
                  SizedBox(height: AppConstants.spacing20),
                  SkeletonBox(height: 420, borderRadius: AppConstants.radius12),
                ],
              ),
            ),
          ],
        );
      } else {
        body = RefreshIndicator(
          onRefresh: () => ref.read(giftProvider.notifier).refresh(),
          child: ListView(
            padding: padding,
            children: [
              if (summary.incoming.isNotEmpty) ...[
                _incomingSection(summary.incoming),
                const SizedBox(height: AppConstants.spacing20),
              ],
              _creationSection(summary),
            ],
          ),
        );
      }
    }

    return PaperStockScope(
      stock: PaperStockId.marigold,
      child: Scaffold(
        appBar: AppBar(title: const Text('Gift FitCheck Pro')),
        body: AppPageBackground(child: body),
      ),
    );
  }

  Widget _incomingSection(List<GiftVoucher> incoming) {
    final busy = ref.watch(giftBusyProvider);
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            incoming.length == 1
                ? 'A gift for you'
                : '${incoming.length} gifts for you',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          for (final voucher in incoming) ...[
            const SizedBox(height: AppConstants.spacing12),
            _IncomingGiftTile(
              voucher: voucher,
              selected: voucher.id == _selectedIncomingId,
              isClaiming: busy.contains(voucher.id),
              onClaim: () => _claim(voucher),
            ),
          ],
        ],
      ),
    );
  }

  Widget _creationSection(GiftDashboardSummary summary) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final available = summary.allowances
        .where((allowance) => allowance.remainingCount > 0)
        .toList(growable: false);
    if (available.isEmpty) {
      return PaperSurface(
        child: Text(
          'No free gift invitations are available right now.',
          style: text.bodyMedium,
        ),
      );
    }
    final selectedDuration =
        available.any((a) => a.durationMonths == _durationMonths)
        ? _durationMonths
        : available.first.durationMonths;
    // Freeze the form while the request runs so the idempotency key cannot
    // change mid-request.
    final creating = ref
        .watch(giftBusyProvider)
        .contains(GiftNotifier.createKey);

    return Form(
      key: _formKey,
      child: PaperSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Send a free invitation', style: text.headlineSmall),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              'Your recipient claims the gift with this verified email. We '
              "don't send the email for you.",
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Wrap(
              spacing: AppConstants.spacing8,
              runSpacing: AppConstants.spacing8,
              children: [
                for (final allowance in available)
                  ChoiceChip(
                    label: Text(
                      '${_term(allowance.durationMonths)}, '
                      '${allowance.remainingCount} left',
                    ),
                    selected: selectedDuration == allowance.durationMonths,
                    onSelected: creating
                        ? null
                        : (_) => setState(
                            () => _durationMonths = allowance.durationMonths,
                          ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            TextFormField(
              controller: _fromNameController,
              // Short fields keep the limit but hide the counter.
              decoration: const InputDecoration(
                labelText: 'From',
                counterText: '',
              ),
              textInputAction: TextInputAction.next,
              maxLength: 80,
              enabled: !creating,
              validator: _requiredName,
            ),
            TextFormField(
              controller: _toNameController,
              decoration: const InputDecoration(
                labelText: 'Recipient name',
                counterText: '',
              ),
              textInputAction: TextInputAction.next,
              maxLength: 80,
              enabled: !creating,
              validator: _requiredName,
            ),
            TextFormField(
              controller: _recipientEmailController,
              decoration: const InputDecoration(
                labelText: 'Recipient email',
                counterText: '',
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              maxLength: 320,
              enabled: !creating,
              validator: _email,
            ),
            DropdownButtonFormField<String>(
              // Rebuilt when the form resets the occasion after a gift.
              key: ValueKey(_occasion),
              initialValue: _occasion?.name ?? 'none',
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
              onChanged: creating
                  ? null
                  : (value) => setState(() {
                      _occasion = giftOccasionFromApi(value);
                      if (_occasion != GiftOccasion.other) {
                        _occasionGreetingController.clear();
                      }
                      _clientRequestId = null;
                    }),
            ),
            const SizedBox(height: AppConstants.spacing16),
            if (_occasion == GiftOccasion.other)
              TextFormField(
                controller: _occasionGreetingController,
                decoration: const InputDecoration(
                  labelText: 'Card greeting',
                  helperText: 'This appears on the card exactly as written.',
                ),
                textInputAction: TextInputAction.next,
                maxLength: 80,
                enabled: !creating,
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
              enabled: !creating,
            ),
            const SizedBox(height: AppConstants.spacing8),
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
            const SizedBox(height: AppConstants.spacing16),
            ElevatedButton.icon(
              onPressed: creating ? null : () => _create(selectedDuration),
              icon: creating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.card_giftcard_outlined, size: 20),
              label: const Text('Create free gift'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _create(int durationMonths) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final message = _messageController.text.trim();
    final voucher = await ref
        .read(giftProvider.notifier)
        .createComplimentary(
          durationMonths: durationMonths,
          fromName: _fromNameController.text.trim(),
          toName: _toNameController.text.trim(),
          recipientEmail: _recipientEmailController.text.trim().toLowerCase(),
          message: message.isEmpty ? null : message,
          occasion: _occasion,
          occasionGreeting: _occasion == GiftOccasion.other
              ? _occasionGreetingController.text.trim()
              : null,
          clientRequestId: _clientRequestId ??= newRequestId('gift'),
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
    final result = await ref
        .read(giftProvider.notifier)
        .claimIncoming(voucher.id);
    if (!mounted || result == null) return;
    ErrorHandler.showSuccess(
      result.entitlementStatus == 'active'
          ? 'Your FitCheck Pro gift is active.'
          : 'Your FitCheck Pro gift starts after your current access.',
      title: 'Gift claimed',
    );
  }

  Future<void> _share(GiftVoucher voucher) async {
    final link = voucher.shareUrl;
    if (link == null || link.isEmpty) return;
    // iPad presents the share popover from an anchor: the form.
    Rect? origin;
    final box = _formKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.attached && box.hasSize) {
      origin = box.localToGlobal(Offset.zero) & box.size;
    }
    try {
      final greeting = giftOccasionGreeting(
        voucher.occasion,
        voucher.occasionGreeting,
      );
      await Share.share(
        '${greeting == null ? '' : '$greeting. '}${voucher.fromName} sent you '
        '${_term(voucher.durationMonths)} of FitCheck Pro. $link',
        subject: 'A FitCheck Pro gift for ${voucher.toName}',
        sharePositionOrigin: origin,
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: link));
      ErrorHandler.showInfo('Gift link copied to the clipboard.');
    }
  }

  String? _requiredName(String? value) =>
      value?.trim().isNotEmpty == true ? null : 'Enter a name.';

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
}

String _term(int months) {
  if (months == 1) return '1 month';
  if (months == 12) return '1 year';
  return '$months months';
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
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final greeting = giftOccasionGreeting(
      voucher.occasion,
      voucher.occasionGreeting,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.stock.page,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(
          color: selected ? tokens.stock.accent : tokens.stock.edge,
          width: selected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (greeting != null)
              Text(
                greeting,
                style: text.titleMedium?.copyWith(
                  color: tokens.stock.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(
              'From ${voucher.fromName}',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${_term(voucher.durationMonths)} of FitCheck Pro',
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppConstants.spacing12),
            ElevatedButton(
              onPressed: isClaiming ? null : onClaim,
              child: isClaiming
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Claim gift'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A live preview of the card the recipient sees.
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
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final to = toName.trim().isEmpty ? 'your recipient' : toName.trim();
    final from = fromName.trim().isEmpty ? 'you' : fromName.trim();
    return PaperSurface(
      color: tokens.stock.tint,
      deckle: PaperEdge.bottom,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing12,
        AppConstants.spacing16,
        AppConstants.spacing20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card preview',
            style: text.bodySmall?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(greeting ?? 'A gift for you', style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing8),
          Text('For $to', style: text.bodyMedium),
          Text('From $from', style: text.bodyMedium),
          if (message.trim().isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacing8),
            Text(
              message.trim(),
              style: text.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: tokens.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
