import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';

/// Quick Actions grid section for dashboard
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Quick Actions',
          subtitle: 'Jump back into your wardrobe',
        ),
        const SizedBox(height: AppConstants.spacing12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 680
                    ? 3
                    : 2;
            final cardWidth = (constraints.maxWidth -
                    (columns - 1) * AppConstants.spacing12) /
                columns;

            return Wrap(
              spacing: AppConstants.spacing12,
              runSpacing: AppConstants.spacing12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _ActionCard(
                    title: 'Add Item',
                    subtitle: 'Capture new pieces',
                    icon: Icons.add,
                    gradient: LinearGradient(
                      colors: [
                        tokens.brandColor,
                        tokens.brandColor.withOpacity(0.7),
                      ],
                    ),
                    onTap: () => Get.toNamed(Routes.wardrobeAdd),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _ActionCard(
                    title: 'Create Outfit',
                    subtitle: 'Mix and match looks',
                    icon: Icons.auto_awesome,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF111827),
                        tokens.cardColor,
                      ],
                    ),
                    onTap: () => Get.toNamed(Routes.outfits),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _ActionCard(
                    title: 'For You',
                    subtitle: 'Personalized picks',
                    icon: Icons.explore,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0EA5E9),
                        Color(0xFF14B8A6),
                      ],
                    ),
                    onTap: () => Get.toNamed(Routes.recommendations),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _ActionCard(
                    title: 'Plan Calendar',
                    subtitle: 'Outfits ahead of time',
                    icon: Icons.calendar_today,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0F172A),
                        tokens.cardColor.withOpacity(0.8),
                      ],
                    ),
                    onTap: () => Get.toNamed(Routes.calendar),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
