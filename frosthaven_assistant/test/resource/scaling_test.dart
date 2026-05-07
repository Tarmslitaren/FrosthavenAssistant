import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    getIt.registerLazySingleton<Settings>(() => Settings());
  });

  tearDownAll(getIt.reset);

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
