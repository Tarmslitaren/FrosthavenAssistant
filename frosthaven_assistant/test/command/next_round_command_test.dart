// ignore_for_file: no-magic-number

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_round_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinky', 1,
            gameState: getIt<GameState>())
        .execute();
    SetCampaignCommand('Jaws of the Lion').execute();
    SetScenarioCommand('#5 A Deeper Understanding', false,
            gameState: getIt<GameState>())
        .execute();
  });

  group('NextRoundCommand', () {
    test('should increment the round counter', () {
      final roundBefore = getIt<GameState>().round.value;

      NextRoundCommand(
              gameState: getIt<GameState>(),
              gameData: getIt<GameData>(),
              settings: getIt<Settings>())
          .execute();

      expect(getIt<GameState>().round.value, roundBefore + 1);
      checkSaveState();
    });

    test('should step down full elements to half after next round', () {
      ImbueElementCommand(Elements.fire, false).execute();
      expect(getIt<GameState>().elementState[Elements.fire], ElementState.full);

      NextRoundCommand(
              gameState: getIt<GameState>(),
              gameData: getIt<GameData>(),
              settings: getIt<Settings>())
          .execute();

      expect(getIt<GameState>().elementState[Elements.fire], ElementState.half);
    });

    test('should step down half elements to inert after next round', () {
      ImbueElementCommand(Elements.ice, true).execute();
      expect(getIt<GameState>().elementState[Elements.ice], ElementState.half);

      NextRoundCommand(
              gameState: getIt<GameState>(),
              gameData: getIt<GameData>(),
              settings: getIt<Settings>())
          .execute();

      expect(getIt<GameState>().elementState[Elements.ice], ElementState.inert);
    });

    test('describe returns "Next Round"', () {
      expect(
          NextRoundCommand(
                  gameState: getIt<GameState>(),
                  gameData: getIt<GameData>(),
                  settings: getIt<Settings>())
              .describe(),
          'Next Round');
    });

    test('undo does not throw', () {
      final gs = getIt<GameState>();
      gs.action(NextRoundCommand(
          gameState: getIt<GameState>(),
          gameData: getIt<GameData>(),
          settings: getIt<Settings>()));
      expect(() => gs.undo(), returnsNormally);
    });

    test('shuffles monster modifier deck when needsShuffle is true', () {
      // Draw all cards to force needsShuffle
      final gs = getIt<GameState>();
      final deck = gs.modifierDeck;
      // Draw until needsShuffle is set (drawing a multiply/2x or curse usually does it)
      int attempts = 0;
      while (!deck.needsShuffle && attempts < 30) {
        DrawModifierCardCommand('', gameState: getIt<GameState>()).execute();
        attempts++;
      }
      if (deck.needsShuffle) {
        NextRoundCommand(
                gameState: getIt<GameState>(),
                gameData: getIt<GameData>(),
                settings: getIt<Settings>())
            .execute();
        // After next round with needsShuffle, deck should be reshuffled
        expect(deck.drawPileIsNotEmpty, isTrue);
      }
    });

    test('character modifier deck needsShuffle is shuffled on next round', () {
      final gs = getIt<GameState>();
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;
      final deck = character.characterState.modifierDeck;
      int attempts = 0;
      while (!deck.needsShuffle && attempts < 30) {
        DrawModifierCardCommand(character.id, gameState: getIt<GameState>())
            .execute();
        attempts++;
      }
      if (deck.needsShuffle) {
        NextRoundCommand(
                gameState: getIt<GameState>(),
                gameData: getIt<GameData>(),
                settings: getIt<Settings>())
            .execute();
        expect(deck.drawPileIsNotEmpty, isTrue);
      }
    });

    test('modifier deck ally needsShuffle is shuffled on next round', () {
      final gs = getIt<GameState>();
      final deck = gs.modifierDeckAllies;
      int attempts = 0;
      while (!deck.needsShuffle && attempts < 30) {
        DrawModifierCardCommand('allies', gameState: getIt<GameState>())
            .execute();
        attempts++;
      }
      if (deck.needsShuffle) {
        NextRoundCommand(
                gameState: getIt<GameState>(),
                gameData: getIt<GameData>(),
                settings: getIt<Settings>())
            .execute();
        expect(deck.drawPileIsNotEmpty, isTrue);
      }
    });

    test('roundState is reset to chooseInitiative after DrawCommand', () {
      DrawCommand(gameState: getIt<GameState>()).execute();
      expect(getIt<GameState>().roundState.value, RoundState.playTurns);
      NextRoundCommand(
              gameState: getIt<GameState>(),
              gameData: getIt<GameData>(),
              settings: getIt<Settings>())
          .execute();
      expect(getIt<GameState>().roundState.value, RoundState.chooseInitiative);
    });
  });
}
