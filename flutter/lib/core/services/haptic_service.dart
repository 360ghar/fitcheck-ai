import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Service for providing haptic feedback throughout the app
/// Enhances user experience with tactile feedback for interactions
class HapticService extends GetxService {
  HapticService._internal();
  static final HapticService _instance = HapticService._internal();
  static HapticService get instance => _instance;

  /// Light haptic feedback for subtle interactions
  /// Use for: selection, focus changes, light taps
  static void lightImpact() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {
      // Haptics may not be available on all devices
    }
  }

  /// Medium haptic feedback for standard interactions
  /// Use for: button presses, confirmation actions
  static void mediumImpact() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {
      // Haptics may not be available on all devices
    }
  }

  /// Heavy haptic feedback for important interactions
  /// Use for: success completions, deletions, major actions
  static void heavyImpact() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {
      // Haptics may not be available on all devices
    }
  }

  /// Selection click feedback
  /// Use for: selecting items, toggle switches
  static void selectionClick() {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {
      // Haptics may not be available on all devices
    }
  }

  /// Vibrate for a specific duration
  /// Use for: notifications, alerts
  static void vibrate() {
    try {
      HapticFeedback.vibrate();
    } catch (_) {
      // Haptics may not be available on all devices
    }
  }

  /// Convenience method for favorite action
  static void favorite() => lightImpact();

  /// Convenience method for delete action
  static void delete() => mediumImpact();

  /// Convenience method for success action
  static void success() => heavyImpact();

  /// Convenience method for error action
  static void error() => vibrate();
}
