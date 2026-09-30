import 'package:flutter/material.dart';

import '../../../core/widgets/app_ui.dart';
import '../widgets/astrology_tab.dart';
import '../widgets/complete_look_tab.dart';
import '../widgets/find_matches_tab.dart';
import '../widgets/shopping_tab.dart';
import '../widgets/weather_based_tab.dart';

/// Recommendations: find matches, complete a look, dress for the weather,
/// lucky colours and pieces to buy. Each tab keeps its own results.
class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return PaperStockScope(
      stock: PaperStockId.ink,
      child: DefaultTabController(
        length: 5,
        initialIndex: initialTab,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('For you'),
            bottom: const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Matches'),
                Tab(text: 'Complete'),
                Tab(text: 'Weather'),
                Tab(text: 'Colours'),
                Tab(text: 'Shop'),
              ],
            ),
          ),
          body: const AppPageBackground(
            child: TabBarView(
              children: [
                FindMatchesTab(),
                CompleteLookTab(),
                WeatherBasedTab(),
                AstrologyTab(),
                ShoppingTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
