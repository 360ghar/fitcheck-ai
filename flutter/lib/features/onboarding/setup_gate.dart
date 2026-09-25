import '../../core/services/persistence_service.dart';

/// Whether a signed-in account goes through the first-run setup. Same rule
/// as the web (frontend/src/lib/activation.ts `needsSetup`): a new account
/// (younger than 7 days) that has not finished or skipped setup here.
/// The caller also checks that the account has no preferred styles yet.
// ponytail: the done flag is per device; add a backend flag if a second
// device showing setup once becomes a problem.
bool isNewAccountForSetup({
  required DateTime? createdAt,
  required bool done,
  DateTime? now,
}) {
  if (done || createdAt == null) return false;
  return (now ?? DateTime.now()).difference(createdAt) <
      const Duration(days: 7);
}

/// One setup rule shared by web and mobile: a new account (7-day window,
/// setup not done) missing profile data goes through setup once. Each
/// platform passes the profile it already holds: web passes gender, mobile
/// passes styles. A field left null is unknown, never missing, so the rule
/// never traps a user on data the caller did not load.
bool shouldShowSetup({
  required DateTime? createdAt,
  String? gender,
  List<String>? styles,
  required bool done,
  DateTime? now,
}) {
  if (done || createdAt == null) return false;
  if ((now ?? DateTime.now()).difference(createdAt) >=
      const Duration(days: 7)) {
    return false;
  }
  if (gender != null && gender.isEmpty) return true;
  if (styles != null && styles.isEmpty) return true;
  return false;
}

String setupDoneKey(String userId) => 'fitcheck_setup_done_$userId';

/// Reads the per-user setup flag. True on a storage failure: never trap.
Future<bool> isSetupDone(String userId) async {
  try {
    return await PersistenceService.instance.getBool(setupDoneKey(userId)) ??
        false;
  } catch (_) {
    return true;
  }
}

/// Marks setup finished or skipped.
Future<void> markSetupDone(String userId) async {
  try {
    await PersistenceService.instance.setBool(setupDoneKey(userId), true);
  } catch (_) {
    // The 7-day window still ends the prompt.
  }
}
