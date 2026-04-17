// ignore_for_file: avoid-late-keyword

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_cs_party_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_cs_party_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', '', 1,
            gameState: getIt<GameState>())
        .execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('RemoveCSPartyCardCommand', () {
    test('should remove party card from character modifier deck', () {
      AddCSPartyCardCommand(character.id, 1, gameState: getIt<GameState>())
          .execute();
      final deck = character.characterState.modifierDeck;
      expect(deck.hasCard('party/1'), isTrue);

      RemoveCSPartyCardCommand(character.id, gameState: getIt<GameState>())
          .execute();

      expect(deck.hasCard('party/1'), isFalse);
      checkSaveState();
    });

    test('describe includes character id', () {
      final command =
          RemoveCSPartyCardCommand(character.id, gameState: getIt<GameState>());
      expect(command.describe(), '${character.id} remove party card');
    });
  });
}
