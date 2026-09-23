import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/paper.dart';

/// The five tabs with the bottom bar. [shell] holds one navigator per tab,
/// so each tab keeps its scroll position and state.
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final current = shell.currentIndex;
    return Scaffold(
      body: shell,
      floatingActionButton: PaperStockScope(
        stock: tabStocks[current],
        child: switch (current) {
          2 => FloatingActionButton.extended(
            onPressed: () => context.push(Routes.wardrobeAdd),
            tooltip: 'Add closet item',
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
          3 => FloatingActionButton.extended(
            onPressed: () => context.push(Routes.outfitBuilder),
            tooltip: 'Create new outfit',
            icon: const Icon(Icons.add),
            label: const Text('Create Outfit'),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: current,
        // A tap on the open tab returns it to its first page.
        onTabChanged: (i) => shell.goBranch(i, initialLocation: i == current),
      ),
    );
  }
}
