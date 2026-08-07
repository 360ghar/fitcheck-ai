import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/code_push_service.dart';

/// The app's version, read from the running bundle.
///
/// Renders `1.0.4 (9)`, or `1.0.4 (9) · patch 3` once a Shorebird patch is
/// installed. The patch segment matters: a patch ships new Dart code under an
/// UNCHANGED version and build number, so the store version alone cannot tell
/// you (or a user reporting a bug) whether a hotfix actually landed.
///
/// This is the single formatting path for the version - Settings > About and
/// the Profile > About dialog both use it, so they can never disagree, and a
/// hardcoded literal can never go stale again (the Profile dialog said
/// "Version 1.0.0" for three releases).
class AppVersionLabel extends StatefulWidget {
  const AppVersionLabel({super.key, this.style, this.prefix = ''});

  /// Text style; falls back to the ambient default.
  final TextStyle? style;

  /// Optional leading text, e.g. `'Version '` for the Profile dialog.
  final String prefix;

  @override
  State<AppVersionLabel> createState() => _AppVersionLabelState();
}

class _AppVersionLabelState extends State<AppVersionLabel> {
  /// Held in state rather than created in `build` so a rebuild does not restart
  /// the platform read and flash the placeholder.
  late final Future<String?> _version;

  @override
  void initState() {
    super.initState();
    _version = _readVersion();
  }

  static Future<String?> _readVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version} (${info.buildNumber})';
    } catch (e) {
      // Cosmetic only - never let a failed platform read take down the screen.
      debugPrint('AppVersionLabel: failed to read package info: $e');
      return null;
    }
  }

  int? get _patchNumber {
    if (!Get.isRegistered<CodePushService>()) return null;
    return Get.find<CodePushService>().currentPatchNumber.value;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _version,
      builder: (context, snapshot) {
        // An em dash while pending or on failure - never a stale literal, and
        // never a layout jump between the two states.
        final version = snapshot.data ?? '—';
        final patch = snapshot.hasData ? _patchNumber : null;
        final text = patch == null ? version : '$version  ·  patch $patch';

        return Text('${widget.prefix}$text', style: widget.style);
      },
    );
  }
}
