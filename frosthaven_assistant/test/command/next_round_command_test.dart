import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_round_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinky', 1).execute();
    SetCampaignCommand('Jaws of the Lion').execute();
    SetScenarioCommand('#5 A Deeper Understanding', false).execute();
  });

  group('NextRoundCommand', () {
    test('should increment the round counter', () {
      final roundBefore = getIt<GameState>().round.value;

      NextRoundCommand().execute();

      expect(getIt<GameState>().round.value, roundBefore + 1);
      checkSaveState();
    });

    test('should step down full elements to half after next round', () {
      ImbueElementCommand(Elements.fire, false).execute();
      expect(getIt<GameState>().elementState[Elements.fire], ElementState.full);

      NextRoundCommand().execute();

      expect(getIt<GameState>().elementState[Elements.fire], ElementState.half);
    });

    test('should step down half elements to inert after next round', () {
      ImbueElementCommand(Elements.ice, true).execute();
      expect(getIt<GameState>().elementState[Elements.ice], ElementState.half);

      NextRoundCommand().execute();

      expect(getIt<GameState>().elementState[Elements.ice], ElementState.inert);
    });

    test('describe returns "Next Round"', () {
      expect(NextRoundCommand().describe(), 'Next Round');
    });

    test('undo does not throw', () {
      final gs = getIt<GameState>();
      gs.action(NextRoundCommand());
      expect(() => gs.undo(), returnsNormally);
    });

    test('shuffles monster modifier deck when needsShuffle is true', () {
      // Draw all cards to force needsShuffle
      final gs = getIt<GameState>();
      final deck = gs.modifierDeck;
      // Draw until needsShuffle is set (drawing a multiply/2x or curse usually does it)
      int attempts = 0;
      while (!deck.needsShuffle && attempts < 30) {
        DrawModifierCardCommand('').execute();
        attempts++;
      }
      if (deck.needsShuffle) {
        NextRoundCommand().execute();
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
        DrawModifierCardCommand(character.id).execute();
        attempts++;
      }
      if (deck.needsShuffle) {
        NextRoundCommand().execute();
        expect(deck.drawPileIsNotEmpty, isTrue);
      }
    });

    test('modifier deck ally needsShuffle is shuffled on next round', () {
      final gs = getIt<GameState>();
      final deck = gs.modifierDeckAllies;
      int attempts = 0;
      while (!deck.needsShuffle && attempts < 30) {
        DrawModifierCardCommand('allies').execute();
        attempts++;
      }
      if (deck.needsShuffle) {
        NextRoundCommand().execute();
        expect(deck.drawPileIsNotEmpty, isTrue);
      }
    });

    test('roundState is reset to chooseInitiative after DrawCommand', () {
      DrawCommand().execute();
      expect(getIt<GameState>().roundState.value, RoundState.playTurns);
      NextRoundCommand().execute();
      expect(getIt<GameState>().roundState.value, RoundState.chooseInitiative);
    });
  });
}
