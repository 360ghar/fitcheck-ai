import 'package:flutter/material.dart';

import '../../../core/widgets/paper.dart';
import 'profile_content.dart';

/// Pushed `/profile` route. The shell shows the same content as the More
/// tab; this wrapper adds an app bar with a back button.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: const Text('More')),
        body: const ProfileContent(showHeader: false),
      ),
    );
  }
}
