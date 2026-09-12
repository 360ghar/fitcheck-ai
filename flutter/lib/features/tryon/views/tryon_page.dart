import 'package:flutter/material.dart';
import '../../shell/views/main_shell_page.dart';

/// Existing try-on links open the maintained tool inside Studio.
class TryOnPage extends StatelessWidget {
  const TryOnPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const MainShellPage(initialTab: 3, initialStudioTool: 1);
}
