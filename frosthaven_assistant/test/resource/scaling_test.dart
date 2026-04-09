import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('scaling', () {
    test('setMaxWidth does not throw', () {
      expect(() => setMaxWidth(), returnsNormally);
    });

    testWidgets('getScaleByReference returns positive value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final scale = getScaleByReference(context);
              expect(scale, greaterThan(0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getMainListWidth returns positive value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final width = getMainListWidth(context);
              expect(width, greaterThan(0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('modifiersFitOnBar returns bool',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final result = modifiersFitOnBar(context);
              expect(result, isA<bool>());
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
