import 'package:flutter/material.dart';
import '../../shell/views/main_shell_page.dart';

/// Compatibility entry point for the profile destination.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => const MainShellPage(initialTab: 4);
}
