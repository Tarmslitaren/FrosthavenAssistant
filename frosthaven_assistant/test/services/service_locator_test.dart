import 'package:flutter/material.dart';
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

    testWidgets('setupMoreGetIt registers BuildContext',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              setupMoreGetIt(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
