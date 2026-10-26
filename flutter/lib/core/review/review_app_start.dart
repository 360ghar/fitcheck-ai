import 'dart:async';

import 'package:flutter/widgets.dart';

import 'review_prompt.dart';

/// Records that the app was launched, exactly once per process.
///
/// A [NavigatorObserver] rather than a line in `main.dart`: the first route
/// push is "the app started and is about to show something", which is the only
/// fact the review prompt needs. It also keeps the launch counter honest in
/// tests that only read the route table — they never push, so they never touch
/// the preferences plugin.
///
/// The counter is what enforces "never in the first session": the sheet cannot
/// appear until the second launch on a later day, so a user who installs,
/// uploads one photo and closes the app is never asked.
class ReviewAppStartObserver extends NavigatorObserver {
  ReviewAppStartObserver(this._prompt);

  final ReviewPrompt _prompt;
  bool _recorded = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_recorded) return;
    _recorded = true;
    unawaited(_prompt.recordLaunch());
  }
}
