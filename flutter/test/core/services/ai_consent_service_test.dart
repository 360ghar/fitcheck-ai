import 'package:fitcheck_ai/core/services/ai_consent_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('consent belongs to the user who gave it', () async {
    String? uid = 'user-a';
    final service = AiConsentService(userId: () => uid);

    expect(await service.hasConsented(), isFalse);
    await service.setConsented();
    expect(await service.hasConsented(), isTrue);

    uid = 'user-b';
    expect(await service.hasConsented(), isFalse);

    uid = null;
    expect(await service.hasConsented(), isFalse);
    await service.setConsented();

    uid = 'user-a';
    expect(await service.hasConsented(), isTrue);
  });
}
