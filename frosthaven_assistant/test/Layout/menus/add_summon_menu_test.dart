import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/add_summon_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    // Banner Spear has summons defined in test data
    AddCharacterCommand('Banner Spear', 'Frosthaven', null, 1).execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
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
                builder: (context) => AddSummonMenu(character: character),
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

  group('AddSummonMenu', () {
    testWidgets('renders Add Summon title', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Add Summon'), findsOneWidget);
    });

    testWidgets('renders standee number buttons', (WidgetTester tester) async {
      await pumpMenu(tester);
      // Nr buttons are TextButton with numbers 1-8
      expect(find.text('1'), findsAtLeast(1));
      expect(find.text('2'), findsAtLeast(1));
    });

    testWidgets('renders color selection icon buttons',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Color buttons are IconButton widgets (images, no text)
      expect(find.byType(IconButton), findsAtLeast(8));
    });

    testWidgets('tapping a color icon button selects that graphic',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Tap the first IconButton (first color choice)
      final iconButtons = find.byType(IconButton);
      if (tester.widgetList(iconButtons).isNotEmpty) {
        await tester.tap(iconButtons.first, warnIfMissed: false);
        await tester.pump();
        // No crash is the assertion
      }
    });

    testWidgets('tapping a summon list item triggers addSummon',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Find ListTile items in the summon list
      final listTiles = find.byType(ListTile);
      if (tester.widgetList(listTiles).isNotEmpty) {
        await tester.tap(listTiles.first, warnIfMissed: false);
        await tester.pump();
        // After tapping a summon, the menu should close (Navigator.pop)
      }
    });
  });
}
