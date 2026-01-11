import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Button style variants for ActionButton
enum ActionButtonStyle { elevated, outlined, text, danger }

/// A button that shows loading state and handles async operations.
/// Automatically disables during loading and shows a progress indicator.
class ActionButton extends StatelessWidget {
  final String label;
  final RxBool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ActionButtonStyle style;
  final Color? color;
  final bool enabled;
  final double? width;

  const ActionButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onPressed,
    this.icon,
    this.style = ActionButtonStyle.elevated,
    this.color,
    this.enabled = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDisabled = isLoading.value || !enabled || onPressed == null;

      final child = isLoading.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : _buildContent();

      final wrappedChild = width != null
          ? SizedBox(width: width, child: Center(child: child))
          : child;

      switch (style) {
        case ActionButtonStyle.elevated:
          return ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: _elevatedStyle(context),
            child: wrappedChild,
          );
        case ActionButtonStyle.outlined:
          return OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            child: wrappedChild,
          );
        case ActionButtonStyle.text:
          return TextButton(
            onPressed: isDisabled ? null : onPressed,
            child: wrappedChild,
          );
        case ActionButtonStyle.danger:
          return ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: wrappedChild,
          );
      }
    });
  }

  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }

  ButtonStyle? _elevatedStyle(BuildContext context) {
    if (color == null) return null;
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
    );
  }
}

/// An icon button variant with loading state
class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final RxBool isLoading;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;

  const ActionIconButton({
    super.key,
    required this.icon,
    required this.isLoading,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      }
      return IconButton(
        icon: Icon(icon, size: size, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
      );
    });
  }
}
