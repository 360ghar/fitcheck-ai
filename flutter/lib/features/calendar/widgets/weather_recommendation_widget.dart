import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Calendar connection widget for Google/Apple calendar OAuth
class CalendarConnectionWidget extends StatelessWidget {
  final bool isConnected;
  final String? connectedEmail;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const CalendarConnectionWidget({
    super.key,
    required this.isConnected,
    this.connectedEmail,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: tokens.brandColor,
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calendar Sync',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (isConnected && connectedEmail != null)
                      Text(
                        connectedEmail!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                  ],
                ),
              ),
              if (isConnected)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          if (isConnected)
            OutlinedButton.icon(
              onPressed: onDisconnect,
              icon: const Icon(Icons.link_off),
              label: const Text('Disconnect'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(36),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _ConnectButton(
                    icon: Icons.public,
                    label: 'Google Calendar',
                    onTap: onConnect,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: _ConnectButton(
                    icon: Icons.phone_iphone,
                    label: 'Apple Calendar',
                    onTap: () => _showAppleComingSoon(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showAppleComingSoon() {
    Get.snackbar(
      'Coming Soon',
      'Apple Calendar integration will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _ConnectButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ConnectButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radius8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing12,
          vertical: AppConstants.spacing12,
        ),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(AppConstants.radius8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: AppConstants.spacing8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
