import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/perks_menu.dart';
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
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()).execute();
  });

  Character _getBlinkblade() {
    return getIt<GameState>()
        .currentList
        .firstWhere((item) => item.id == 'Blinkblade') as Character;
  }

  Future<void> pumpMenu(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    final character = _getBlinkblade();
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => PerksMenu(character: character),
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

  group('PerksMenu', () {
    testWidgets('renders Add Perks button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Add Perks'), findsOneWidget);
    });

    testWidgets('renders perk checkboxes', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
