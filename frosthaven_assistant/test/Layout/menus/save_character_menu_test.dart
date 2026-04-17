import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/save_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/save_character_modal_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
            gameState: getIt<GameState>())
        .execute();
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
                builder: (context) => const SaveCharacterMenu(),
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

  group('SaveCharacterMenu', () {
    testWidgets('renders header text', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('Load, Save or Delete Characters'),
          findsOneWidget);
    });

    testWidgets('renders Add new Save label', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Add new Save:'), findsOneWidget);
    });

    testWidgets('renders Load Character label', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Load Character:'), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('renders character icon button for current characters',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Blinkblade character icon button should be shown
      expect(find.byType(IconButton), findsAtLeast(1));
    });

    testWidgets('tapping character icon opens SaveCharacterModalMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsAtLeast(1));
      await tester.tap(iconButtons.first);
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;
      expect(find.byType(SaveCharacterModalMenu), findsOneWidget);
    });

    testWidgets('shows saved characters in list', (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = Map<String, String>.of(settings.characterSaves.value);
      // Add a save entry
      final saves = Map<String, String>.of(settings.characterSaves.value);
      saves['BlinkbladeSave\nBlinkblade'] = 'somedata';
      settings.characterSaves.value = saves;

      await pumpMenu(tester);
      expect(find.text('BlinkbladeSave'), findsOneWidget);

      // Tapping a save opens SaveCharacterModalMenu
      await tester.tap(find.text('BlinkbladeSave'));
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;
      expect(find.byType(SaveCharacterModalMenu), findsOneWidget);

      // cleanup
      settings.characterSaves.value = before;
    });

    testWidgets('tapping Close dismisses the menu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(SaveCharacterMenu), findsNothing);
    });
  });
}
