import 'package:fitcheck_ai/core/utils/frame_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('afterBuildPhase', () {
    testWidgets('defers an Rx write made from a sibling subtree mid-build',
        (tester) async {
      final counter = 0.obs;
      SchedulerPhase? phaseAtWrite;
      var ranInsideBuild = false;

      // The Obx and the Builder are siblings, so the Obx is NOT a descendant of
      // the element that is building when the write is requested. That is the
      // exact shape Flutter rejects with "markNeedsBuild called during build".
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Obx(() => Text('count ${counter.value}')),
              Builder(
                builder: (context) {
                  var stillBuilding = true;
                  afterBuildPhase(() {
                    ranInsideBuild = stillBuilding;
                    phaseAtWrite = SchedulerBinding.instance.schedulerPhase;
                    counter.value++;
                  });
                  stillBuilding = false;
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // Proves the deferred path was actually taken rather than the test passing
      // trivially: the action did not run inside the Builder's build().
      expect(ranInsideBuild, isFalse);
      // The invariant the helper exists to enforce: the write never lands while
      // the framework is building/laying out/painting.
      expect(phaseAtWrite, isNotNull);
      expect(phaseAtWrite, isNot(SchedulerPhase.persistentCallbacks));

      await tester.pump();
      expect(find.text('count 1'), findsOneWidget);
    });

    testWidgets('runs synchronously when no frame is in progress',
        (tester) async {
      var ran = false;
      afterBuildPhase(() => ran = true);
      expect(ran, isTrue);
    });
  });

  group('settleBuildPhase', () {
    testWidgets('completes immediately outside a frame', (tester) async {
      expect(await settleBuildPhase(), isTrue);
    });

    testWidgets('reports false when stillAlive is false, but still completes',
        (tester) async {
      bool? alive;
      var completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Deferred path: a frame is in progress here.
              settleBuildPhase(stillAlive: () => false).then((v) {
                alive = v;
                completed = true;
              });
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      // The caller must learn the owner is gone...
      expect(alive, isFalse);
      // ...but the future must not be left pending, or every `finally` above it
      // is stranded and any RefreshIndicator awaiting it spins forever.
      expect(completed, isTrue);
    });

    testWidgets('reports true when the owner survives the frame',
        (tester) async {
      bool? alive;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              settleBuildPhase(stillAlive: () => true).then((v) => alive = v);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pump();
      expect(alive, isTrue);
    });
  });
}
