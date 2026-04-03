import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/numpad_menu.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  Widget buildNumpad({
    TextEditingController? controller,
    int maxLength = 3,
    Function(String)? onChange,
  }) {
    return MaterialApp(
      home: Material(
        child: NumpadMenu(
          controller: controller ?? TextEditingController(),
          maxLength: maxLength,
          onChange: onChange,
        ),
      ),
    );
  }

  group('NumpadMenu', () {
    testWidgets('renders all digit buttons 0 through 9',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(buildNumpad());

      for (int i = 0; i <= 9; i++) {
        expect(find.text(i.toString()), findsOneWidget,
            reason: 'Digit $i should be present');
      }
    });

    testWidgets('tapping a digit button updates the controller text',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final controller = TextEditingController();
      await tester.pumpWidget(buildNumpad(controller: controller));

      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      expect(controller.text, '5');
    });

    testWidgets('tapping multiple digit buttons accumulates text',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final controller = TextEditingController();
      await tester.pumpWidget(buildNumpad(controller: controller));

      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      expect(controller.text, '123');
    });

    testWidgets('calls onChange callback with current text when digit is tapped',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      String? lastValue;
      await tester.pumpWidget(buildNumpad(
        onChange: (value) => lastValue = value,
      ));

      await tester.tap(find.text('7'));
      await tester.pumpAndSettle();

      expect(lastValue, '7');
    });

    testWidgets('onChange receives accumulated text on subsequent taps',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final List<String> values = [];
      await tester.pumpWidget(buildNumpad(
        onChange: (value) => values.add(value),
      ));

      await tester.tap(find.text('4'));
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      expect(values, ['4', '42']);
    });

    testWidgets('pops navigator when maxLength is reached',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => NumpadMenu(
                    controller: controller,
                    maxLength: 1,
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(NumpadMenu), findsOneWidget);

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      expect(controller.text, '3');
      expect(find.byType(NumpadMenu), findsNothing);
    });
  });
}
