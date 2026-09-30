import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/paper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/setup_gate.dart';
import '../../settings/providers/settings_provider.dart';

/// The five tabs with the bottom bar. [shell] holds one navigator per tab,
/// so each tab keeps its scroll position and state.
class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  String? _checkedUser;

  @override
  void initState() {
    super.initState();
    // The profile can land after the shell opens (restored session), so
    // check on each user id, once.
    ref.listenManual(
      authProvider.select((s) => (s.user?.id, s.user?.createdAt)),
      (_, user) => _maybeOpenSetup(user.$1, user.$2),
      fireImmediately: true,
    );
  }

  /// Opens the first-run setup for a new account with no style choices.
  /// The disk read gates the network fetch: existing accounts never hit
  /// the network here.
  Future<void> _maybeOpenSetup(String? id, DateTime? createdAt) async {
    if (id == null || id == _checkedUser) return;
    _checkedUser = id;
    try {
      final done = await isSetupDone(id);
      if (!isNewAccountForSetup(createdAt: createdAt, done: done)) return;
      final prefs = await ref.read(settingsRepositoryProvider).getPreferences();
      if (!shouldShowSetup(
        createdAt: createdAt,
        styles: prefs.preferredStyles,
        done: done,
      )) {
        return;
      }
      if (mounted) context.push(Routes.welcome);
    } catch (_) {
      // Offline or a failed read: skip setup this launch.
    }
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
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
