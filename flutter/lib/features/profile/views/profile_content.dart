import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/app_version_label.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../settings/widgets/paper_group.dart';

/// The "More" hub: who you are, your totals, and every secondary screen.
///
/// The shell shows it as the More tab (stone stock); [ProfilePage] pushes
/// it with an app bar and [showHeader] off.
class ProfileContent extends ConsumerWidget {
  const ProfileContent({super.key, this.showHeader = true});

  final bool showHeader;

  Future<void> _refresh(WidgetRef ref) => Future.wait([
    ref.read(dashboardProvider.notifier).refresh(),
    ref.read(authProvider.notifier).refreshUser(),
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const gap = SizedBox(height: AppConstants.spacing24);
    final tokens = PaperTokens.of(context);

    return AppPageBackground(
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (showHeader)
              const SliverToBoxAdapter(child: AppTabHeader(title: 'More')),
            SliverSafeArea(
              top: !showHeader,
              sliver: SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacing16,
                  AppConstants.spacing4,
                  AppConstants.spacing16,
                  AppConstants.spacing32,
                ),
                sliver: SliverList.list(
                  children: [
                    const _IdentityCard(),
                    const SizedBox(height: AppConstants.spacing12),
                    const _Stats(),
                    gap,
                    PaperGroup(
                      title: 'Explore',
                      children: [
                        PaperNavRow(
                          icon: Icons.accessibility_new_rounded,
                          title: 'Try-on',
                          onTap: () => context.push(Routes.tryOn),
                        ),
                        PaperNavRow(
                          icon: Icons.explore_outlined,
                          title: 'For you',
                          onTap: () => context.push(Routes.recommendations),
                        ),
                        PaperNavRow(
                          icon: Icons.calendar_month_outlined,
                          title: 'Calendar',
                          onTap: () => context.push(Routes.calendar),
                        ),
                        PaperNavRow(
                          icon: Icons.emoji_events_outlined,
                          title: 'Rewards',
                          onTap: () => context.push(Routes.gamification),
                        ),
                      ],
                    ),
                    gap,
                    PaperGroup(
                      title: 'Account',
                      children: [
                        PaperNavRow(
                          icon: Icons.straighten_rounded,
                          title: 'Body profiles',
                          onTap: () => context.push(Routes.bodyProfiles),
                        ),
                        PaperNavRow(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Plan and billing',
                          onTap: () => context.push(Routes.subscription),
                        ),
                        PaperNavRow(
                          icon: Icons.card_giftcard_outlined,
                          title: 'Invite friends',
                          onTap: () => context.push(Routes.referral),
                        ),
                        PaperNavRow(
                          icon: Icons.tune_rounded,
                          title: 'Settings',
                          onTap: () => context.push(Routes.settings),
                        ),
                      ],
                    ),
                    gap,
                    PaperGroup(
                      title: 'Support',
                      children: [
                        PaperNavRow(
                          icon: Icons.help_outline_rounded,
                          title: 'Help',
                          onTap: () => context.push(Routes.help),
                        ),
                        PaperNavRow(
                          icon: Icons.rate_review_outlined,
                          title: 'Send feedback',
                          onTap: () => context.push(Routes.feedback),
                        ),
                        PaperNavRow(
                          icon: Icons.shield_outlined,
                          title: 'Privacy and terms',
                          onTap: () => context.push(Routes.legal),
                        ),
                        PaperNavRow(
                          icon: Icons.info_outline_rounded,
                          title: 'About',
                          onTap: () => _showAbout(context),
                        ),
                      ],
                    ),
                    gap,
                    PaperGroup(
                      children: [
                        PaperNavRow(
                          icon: Icons.logout_rounded,
                          title: 'Sign out',
                          color: tokens.error,
                          trailing: const SizedBox.shrink(),
                          onTap: () => _confirmSignOut(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final tokens = PaperTokens.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('FitCheck AI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your closet, outfits and plans in one place.'),
            const SizedBox(height: AppConstants.spacing12),
            AppVersionLabel(
              prefix: 'Version ',
              style: TextStyle(color: tokens.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final signingOut = ref.watch(
            authProvider.select((s) => s.busy == AuthBusy.logout),
          );
          return AlertDialog(
            title: const Text('Sign out?'),
            content: const Text('You can sign back in at any time.'),
            actions: [
              TextButton(
                onPressed: signingOut
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: signingOut
                    ? null
                    : () => ref.read(authProvider.notifier).logout(),
                style: TextButton.styleFrom(
                  foregroundColor: PaperTokens.of(context).error,
                ),
                child: signingOut
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign out'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Avatar, name and email. The whole card opens Edit profile.
class _IdentityCard extends ConsumerWidget {
  const _IdentityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final user = ref.watch(authProvider.select((s) => s.user));
    final name = (user?.fullName?.trim().isNotEmpty ?? false)
        ? user!.fullName!.trim()
        : null;

    return PaperSurface(
      semanticLabel: 'Edit profile',
      onTap: () => context.push(Routes.profileEdit),
      // Right inset matches ListTile's, so every chevron shares one axis.
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing24,
        AppConstants.spacing16,
      ),
      child: Row(
        children: [
          ProfileAvatar(user: user, radius: 28),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'Your profile',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user?.email.isNotEmpty ?? false)
                  Text(
                    user!.email,
                    style: text.bodyMedium?.copyWith(color: tokens.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: tokens.textMuted),
        ],
      ),
    );
  }
}

/// A round avatar: the photo, or the first letter on the stock's tint.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.user, this.radius = 24});

  final UserModel? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final source = (user?.fullName?.trim().isNotEmpty ?? false)
        ? user!.fullName!.trim()
        : user?.email ?? '';
    final initial = Text(
      source.isEmpty ? '?' : source.substring(0, 1).toUpperCase(),
      style: TextStyle(
        color: tokens.stock.accent,
        fontWeight: FontWeight.w700,
        fontSize: radius * 0.8,
        height: 1,
      ),
    );
    final url = user?.avatarUrl;
    final size = radius * 2;
    return CircleAvatar(
      radius: radius,
      backgroundColor: tokens.stock.tint,
      child: url != null && url.isNotEmpty
          ? ClipOval(
              child: AppNetworkImage(
                url,
                width: size,
                height: size,
                cacheWidth: (size * 3).round(),
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Center(child: initial),
              ),
            )
          : initial,
    );
  }
}

/// Pieces, outfits and streak as large figures.
class _Stats extends ConsumerWidget {
  const _Stats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final snapshot = dashboard.value;
    void retry() => ref.read(dashboardProvider.notifier).refresh();

    if (snapshot == null) {
      if (dashboard.hasError && !dashboard.isLoading) {
        return AppErrorBanner(error: dashboard.error, onRetry: retry);
      }
      return const SkeletonPulse(
        child: SkeletonBox(height: 104, borderRadius: AppConstants.radius12),
      );
    }

    final stats = snapshot.data.statistics;
    final streak = snapshot.streak;
    final tokens = PaperTokens.of(context);
    final worn = stats.mostWornItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (dashboard.hasError && !dashboard.isLoading) ...[
          AppErrorBanner(error: dashboard.error, onRetry: retry),
          const SizedBox(height: AppConstants.spacing8),
        ],
        PaperSurface(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing8,
            vertical: AppConstants.spacing12,
          ),
          // The figures draw their ink on this sheet.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Figure(
                      value: stats.totalItems,
                      label: stats.totalItems == 1 ? 'piece' : 'pieces',
                      onTap: () => context.push(Routes.wardrobeStats),
                    ),
                    _Figure(
                      value: stats.totalOutfits,
                      label: stats.totalOutfits == 1 ? 'outfit' : 'outfits',
                      onTap: () => context.push(Routes.outfitCollections),
                    ),
                    _Figure(
                      value: streak?.currentStreak,
                      label: 'day streak',
                      onTap: () => context.push(Routes.gamification),
                    ),
                  ],
                ),
                if (worn != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spacing8,
                      AppConstants.spacing8,
                      AppConstants.spacing8,
                      0,
                    ),
                    child: Text(
                      'Most worn: ${worn.name}, ${worn.timesWorn} times',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final int? value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Semantics(
        button: true,
        label: '${value ?? 'No'} $label',
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing8,
              vertical: AppConstants.spacing4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value?.toString() ?? '–',
                  style: text.displaySmall?.copyWith(fontSize: 34),
                  maxLines: 1,
                ),
                Text(
                  label,
                  style: text.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
