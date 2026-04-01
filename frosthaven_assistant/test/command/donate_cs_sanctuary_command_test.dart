import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/donate_cs_sanctuary_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_cs_sanctuary_donation_command.dart';
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
    AddCharacterCommand('Blinkblade', 'Frosthaven', '', 1).execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('DonateCSSanctuaryCommand', () {
    test('should add sanctuary cards to character modifier deck', () {
      final deck = character.characterState.modifierDeck;
      final countBefore = deck.cardCount.value;

      DonateCSSanctuaryCommand(character.id).execute();

      expect(deck.hasCSSanctuary(), isTrue);
      expect(deck.cardCount.value, greaterThan(countBefore));
      checkSaveState();
    });

    test('describe includes character id', () {
      final command = DonateCSSanctuaryCommand(character.id);
      expect(command.describe(), '${character.id} donate to sanctuary');
    });
  });

  group('RemoveCSSanctuaryDonationCommand', () {
    test('should remove sanctuary cards from character modifier deck', () {
      DonateCSSanctuaryCommand(character.id).execute();
      final deck = character.characterState.modifierDeck;
      expect(deck.hasCSSanctuary(), isTrue);

      RemoveCSSanctuaryDonationCommand(character.id).execute();

      expect(deck.hasCSSanctuary(), isFalse);
      checkSaveState();
    });

    test('describe includes character id', () {
      final command = RemoveCSSanctuaryDonationCommand(character.id);
      expect(command.describe(), "remove ${character.id}'s donation");
    });
  });
}
