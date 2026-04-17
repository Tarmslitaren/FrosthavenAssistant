// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/character_tile.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_character_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
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
    AddCharacterCommand('Hatchet', 'Jaws of the Lion', null, 1,
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
                builder: (context) => const RemoveCharacterMenu(),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  group('RemoveCharacterMenu', () {
    testWidgets('renders the "Remove All" option', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Remove All'), findsOneWidget);
    });

    testWidgets('renders the "Close" button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('renders the "Load or Save Characters" button',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Load or Save Characters'), findsOneWidget);
    });

    testWidgets('lists all currently added characters',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Both characters should appear as tiles
      expect(find.text('Blinkblade'), findsOneWidget);
      expect(find.byType(CharacterTile), findsNWidgets(2));
    });

    testWidgets('tapping "Remove All" removes all characters and closes dialog',
        (WidgetTester tester) async {
      await pumpMenu(tester);

      await tester.tap(find.text('Remove All'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveCharacterMenu), findsNothing);
      final characters =
          getIt<GameState>().currentList.whereType<Character>().toList();
      expect(characters, isEmpty);
    });

    testWidgets('tapping a character tile removes only that character',
        (WidgetTester tester) async {
      await pumpMenu(tester);

      await tester.tap(find.text('Blinkblade'));
      await tester.pumpAndSettle();

      final characters =
          getIt<GameState>().currentList.whereType<Character>().toList();
      expect(characters.length, 1);
      expect(characters.first.characterClass.name, 'Hatchet');
    });

    testWidgets('tapping "Close" dismisses the dialog without changes',
        (WidgetTester tester) async {
      await pumpMenu(tester);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveCharacterMenu), findsNothing);
      final characters =
          getIt<GameState>().currentList.whereType<Character>().toList();
      expect(characters.length, 2);
    });
  });
}
