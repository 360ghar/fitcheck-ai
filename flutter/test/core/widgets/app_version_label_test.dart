import 'package:fitcheck_ai/core/services/code_push_service.dart';
import 'package:fitcheck_ai/core/widgets/app_version_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The Profile dialog shipped a hardcoded "Version 1.0.0" for three releases.
/// These tests pin the two properties that stop that recurring: the label always
/// comes from the running bundle, and it never renders a stale or missing value
/// as anything other than a placeholder.
/// A CodePushService whose updater cannot be built, which is exactly the state
/// of a `flutter test` binary. Injecting it keeps the package from probing FFI
/// and printing its "Shorebird Updater is unavailable" banner into the output.
CodePushService _offlineCodePush() =>
    CodePushService(updaterFactory: () => throw StateError('no engine'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget host() => const MaterialApp(home: Scaffold(body: AppVersionLabel()));

  tearDown(Get.reset);

  testWidgets('shows a placeholder before the platform read resolves',
      (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'FitCheck AI',
      packageName: 'com.fitcheckaiapp.fitcheckai',
      version: '1.0.4',
      buildNumber: '9',
      buildSignature: '',
    );

    await tester.pumpWidget(host());
    // First frame only - the FutureBuilder has not completed yet.
    expect(find.text('—'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('renders version and build from the bundle', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'FitCheck AI',
      packageName: 'com.fitcheckaiapp.fitcheckai',
      version: '1.0.4',
      buildNumber: '9',
      buildSignature: '',
    );

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('1.0.4 (9)'), findsOneWidget);
  });

  testWidgets('honours the prefix used by the Profile dialog', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'FitCheck AI',
      packageName: 'com.fitcheckaiapp.fitcheckai',
      version: '1.0.4',
      buildNumber: '9',
      buildSignature: '',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppVersionLabel(prefix: 'Version ')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Version 1.0.4 (9)'), findsOneWidget);
  });

  testWidgets('appends the Shorebird patch number when one is installed',
      (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'FitCheck AI',
      packageName: 'com.fitcheckaiapp.fitcheckai',
      version: '1.0.4',
      buildNumber: '9',
      buildSignature: '',
    );

    // A patch leaves version and build untouched, so this segment is the only
    // in-app evidence that a hotfix landed.
    final service = Get.put(_offlineCodePush());
    service.currentPatchNumber.value = 3;

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('1.0.4 (9)  ·  patch 3'), findsOneWidget);
  });

  testWidgets('omits the patch segment on an unpatched build', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'FitCheck AI',
      packageName: 'com.fitcheckaiapp.fitcheckai',
      version: '1.0.4',
      buildNumber: '9',
      buildSignature: '',
    );

    Get.put(_offlineCodePush());

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('1.0.4 (9)'), findsOneWidget);
  });

  testWidgets('works when CodePushService is not registered', (tester) async {
    // Widget tests and any screen pumped without InitialBinding land here.
    PackageInfo.setMockInitialValues(
      appName: 'FitCheck AI',
      packageName: 'com.fitcheckaiapp.fitcheckai',
      version: '1.0.4',
      buildNumber: '9',
      buildSignature: '',
    );

    expect(Get.isRegistered<CodePushService>(), isFalse);

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('1.0.4 (9)'), findsOneWidget);
  });
}
