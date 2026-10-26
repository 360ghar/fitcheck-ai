import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
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
            title: Text(context.l10n.quickForYou),
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: context.l10n.recommendTabMatches),
                Tab(text: context.l10n.recommendTabComplete),
                Tab(text: context.l10n.recommendTabWeather),
                Tab(text: context.l10n.recommendTabColours),
                Tab(text: context.l10n.recommendTabShop),
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
