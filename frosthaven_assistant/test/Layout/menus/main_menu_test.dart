import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/main_menu.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  Future<void> pumpMenu(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const MainMenu(),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    FlutterError.onError = originalOnError;
  }

  group('MainMenu', () {
    testWidgets('renders Undo and Redo buttons', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('Undo'), findsOneWidget);
      expect(find.textContaining('Redo'), findsOneWidget);
    });

    testWidgets('renders Set Scenario button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Set Scenario'), findsOneWidget);
    });

    testWidgets('renders Add Character button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Add Character'), findsOneWidget);
    });

    testWidgets('renders Settings button', (WidgetTester tester) async {
      await pumpMenu(tester);
      // Settings is far down the list — scroll until visible
      await tester.scrollUntilVisible(find.text('Settings'), 300);
      await tester.pump();
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
