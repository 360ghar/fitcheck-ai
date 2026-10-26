import 'package:fitcheck_ai/core/widgets/report_content_sheet.dart';
import 'package:fitcheck_ai/features/feedback/models/feedback_model.dart';
import 'package:fitcheck_ai/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The report sheet is the app's App Store Review Guideline 1.2 control, so it
/// gets two kinds of test: the ticket it files stays in one triage vocabulary,
/// and the UI around it speaks the user's language.
void main() {
  group('buildReportTicket', () {
    test('uses the English label even when nothing about the ticket is shown', () {
      final ticket = buildReportTicket(
        contentType: ReportContentType.tryOnImage,
        contentId: 'result-42',
        reasonToken: 'Nudity or sexual content',
        details: 'looks wrong',
      );

      expect(ticket.subject, 'Content report: AI try-on image result-42');
      expect(
        ticket.description,
        'Nudity or sexual content\n\nlooks wrong\n\nReported via in-app report.',
      );
      expect(ticket.category, TicketCategory.supportRequest);
    });

    test('every content type maps to a distinct, human-readable label', () {
      final labels = ReportContentType.values
          .map((type) => type.ticketLabel)
          .toList();
      expect(labels, ['AI try-on image', 'shared outfit', 'AI photoshoot image']);
      expect(labels.toSet().length, labels.length);
    });

    test('omitted details leave no stray blank line', () {
      final ticket = buildReportTicket(
        contentType: ReportContentType.sharedOutfit,
        contentId: 'abc',
        reasonToken: 'Other',
        details: '',
      );
      expect(ticket.description, 'Other\n\nReported via in-app report.');
    });

    test('a reported id containing spaces is preserved verbatim', () {
      final ticket = buildReportTicket(
        contentType: ReportContentType.photoshootImage,
        contentId: 'image 7',
        reasonToken: 'Other',
        details: '',
      );
      expect(ticket.subject, 'Content report: AI photoshoot image image 7');
    });
  });

  group('ReportContentSheet rendering', () {
    Future<void> pumpSheet(WidgetTester tester, Locale locale) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(
            body: ReportContentSheet(
              contentType: ReportContentType.tryOnImage,
              contentId: 'result-42',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders the localized title and submit button', (tester) async {
      await pumpSheet(tester, const Locale('fr'));

      final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
      expect(find.text(l10n.reportTitle), findsOneWidget);
      expect(find.text(l10n.reportSubmit), findsOneWidget);
      expect(find.text(l10n.reportReasonNudity), findsOneWidget);
      expect(find.text(l10n.reportDetailsLabel), findsOneWidget);
    });

    testWidgets('shows no hardcoded English where a translation exists', (
      tester,
    ) async {
      await pumpSheet(tester, const Locale('fr'));

      final fr = await AppLocalizations.delegate.load(const Locale('fr'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      // Compare key by key and skip any key whose French value still equals the
      // English source: that is a translation gap, not a hardcoded widget, and
      // failing on it would make this test red for the wrong reason while 24
      // catalogs are still being generated.
      final pairs = <String, String>{
        fr.reportTitle: en.reportTitle,
        fr.reportSubmit: en.reportSubmit,
        fr.reportDetailsLabel: en.reportDetailsLabel,
        fr.reportReasonNudity: en.reportReasonNudity,
        fr.reportReasonImpersonation: en.reportReasonImpersonation,
        fr.reportReasonOther: en.reportReasonOther,
      };
      var checked = 0;
      for (final entry in pairs.entries) {
        if (entry.key == entry.value) continue;
        expect(
          find.text(entry.value),
          findsNothing,
          reason:
              '"${entry.value}" is still hardcoded in the report sheet; the '
              'French catalog says "${entry.key}"',
        );
        checked++;
      }
      expect(
        checked,
        greaterThan(0),
        reason:
            'No French string differs from English, so this test proved '
            'nothing. French catalog is missing.',
      );
    });

    testWidgets('every reason is offered as a radio option', (tester) async {
      await pumpSheet(tester, const Locale('fr'));

      final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
      for (final label in [
        l10n.reportReasonInappropriate,
        l10n.reportReasonNudity,
        l10n.reportReasonHarassment,
        l10n.reportReasonImpersonation,
        l10n.reportReasonOther,
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('lays out right-to-left for Arabic without overflow', (
      tester,
    ) async {
      // ar-SA has no catalog yet, so this asserts the sheet survives an RTL
      // ambient direction rather than a translated sheet. It is the regression
      // guard for the EdgeInsets.only -> EdgeInsetsDirectional change.
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: ReportContentSheet(
                contentType: ReportContentType.sharedOutfit,
                contentId: 'abc',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.reportTitle), findsOneWidget);
    });
  });
}
