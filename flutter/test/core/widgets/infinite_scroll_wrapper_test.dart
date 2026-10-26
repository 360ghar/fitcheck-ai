import 'package:fitcheck_ai/core/widgets/infinite_scroll_wrapper.dart';
import 'package:fitcheck_ai/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a first page shorter than the screen still loads more', (
    tester,
  ) async {
    var loads = 0;
    var canLoad = true;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: InfiniteScrollWrapper(
          canLoadMore: () => canLoad,
          onLoadMore: () {
            loads++;
            canLoad = false; // The notifier marks itself busy.
          },
          child: CustomScrollView(
            slivers: [
              SliverList.builder(
                itemCount: 2,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('$i')),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(loads, 1);
  });
}
