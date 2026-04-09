import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/save_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/save_modal_menu.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

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
                builder: (context) => const SaveMenu(),
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

  group('SaveMenu', () {
    testWidgets('renders header text', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Load, Add or Delete save states.'), findsOneWidget);
    });

    testWidgets('renders Add new Save button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Add new Save'), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('tapping Add new Save opens SaveModalMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Add new Save'));
      await tester.pumpAndSettle();
      expect(find.byType(SaveModalMenu), findsOneWidget);
    });

    testWidgets('tapping Close dismisses the menu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(SaveMenu), findsNothing);
    });

    testWidgets('shows existing saves in list', (WidgetTester tester) async {
      final settings = getIt<Settings>();
      // Add a save entry to the settings
      final saves = Map<String, String>.from(settings.saves.value);
      saves['TestSave1'] = 'somedata';
      settings.saves.value = saves;

      await pumpMenu(tester);
      expect(find.text('TestSave1'), findsOneWidget);

      // Tapping a save opens SaveModalMenu
      await tester.tap(find.text('TestSave1'));
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;
      expect(find.byType(SaveModalMenu), findsOneWidget);

      // cleanup
      final cleanSaves = Map<String, String>.from(settings.saves.value);
      cleanSaves.remove('TestSave1');
      settings.saves.value = cleanSaves;
    });
  });
}
