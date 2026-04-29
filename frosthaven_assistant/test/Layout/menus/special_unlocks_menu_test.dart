import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/special_unlocks_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/unlock_special_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
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
                builder: (context) => SpecialUnlocksMenu(),
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

  group('SpecialUnlocksMenu', () {
    testWidgets('renders Special Unlocks title', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Special Unlocks'), findsOneWidget);
    });

    testWidgets('renders checkboxes for special classes',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('Demons is initially unchecked', (WidgetTester tester) async {
      await pumpMenu(tester);
      final tile = tester.widgetList<CheckboxListTile>(
          find.byType(CheckboxListTile)).first;
      expect(tile.value, isFalse);
    });

    testWidgets(
        'checkbox updates reactively after UnlockSpecialCommand via action',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      expect(gameState.unlockedClasses.contains('Demons'), isFalse);

      await pumpMenu(tester);

      // Unlock Demons via command (fires unlockedClassesVersion)
      gameState.action(
          UnlockSpecialCommand('Demons', gameState: gameState));
      await tester.pump();

      expect(gameState.unlockedClasses.contains('Demons'), isTrue);
      // The Demons checkbox should now be checked
      final tile = tester.widgetList<CheckboxListTile>(
          find.byType(CheckboxListTile)).first;
      expect(tile.value, isTrue);

      // Restore
      gameState.action(
          UnlockSpecialCommand('Demons', gameState: gameState));
    });
  });
}
