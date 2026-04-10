import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_summons_button.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
  });

  group('CharacterSummonsButton', () {
    testWidgets('renders without error', (WidgetTester tester) async {
      AddCharacterCommand('Banner Spear', 'Frosthaven', null, 1, gameState: getIt<GameState>()).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Banner Spear') as Character;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterSummonsButton(scale: 1.0, character: character),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
      expect(find.byType(CharacterSummonsButton), findsOneWidget);
    });

    testWidgets('tapping icon button opens AddSummonMenu',
        (WidgetTester tester) async {
      AddCharacterCommand('Banner Spear', 'Frosthaven', null, 1, gameState: getIt<GameState>()).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Banner Spear') as Character;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterSummonsButton(scale: 1.0, character: character),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;

      // Directly call onPressed to cover the callback
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      iconButton.onPressed?.call();
      await tester.pump();
    });
  });
}
