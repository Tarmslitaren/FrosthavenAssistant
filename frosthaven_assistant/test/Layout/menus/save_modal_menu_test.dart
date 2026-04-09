import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/save_modal_menu.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  Future<void> pumpMenu(WidgetTester tester,
      {String saveName = 'TestSave', bool saveOnly = false}) async {
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
                builder: (context) => SaveModalMenu(
                  saveName: saveName,
                  saveOnly: saveOnly,
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = originalOnError;
  }

  group('SaveModalMenu', () {
    testWidgets('renders Save button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders Load and Delete buttons when saveOnly is false',
        (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: false);
      expect(find.text('Load'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('does not render Load or Delete when saveOnly is true',
        (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: true);
      expect(find.text('Load'), findsNothing);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('renders Set save name label and text field',
        (WidgetTester tester) async {
      await pumpMenu(tester, saveName: 'MySave');
      expect(find.text('Set save name:'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('pre-fills text field with saveName via controller',
        (WidgetTester tester) async {
      await pumpMenu(tester, saveName: 'MySlot');
      final state = tester.state<SaveModalMenuState>(find.byType(SaveModalMenu));
      expect(state.nameController.text, 'MySlot');
    });

    testWidgets('tapping Save button triggers save and closes dialog',
        (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: false, saveName: 'TestSave');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Load button closes dialog', (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: false, saveName: 'TestSave');
      await tester.tap(find.text('Load'));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Delete button closes dialog', (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: false, saveName: 'TestSave');
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
    });
  });
}
