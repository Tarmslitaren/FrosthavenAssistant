import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('service_locator', () {
    test('loading notifier is initialized as ValueNotifier<bool>',
        () {
      expect(loading, isA<ValueNotifier<bool>>());
    });
  });
}
