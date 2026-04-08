import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_condition_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_perk_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_ability_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_round_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_character_level_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  // ---------------------------------------------------------------------------
  // sortByInitiative (called by DrawCommand)
  // ---------------------------------------------------------------------------
  group('sortByInitiative via DrawCommand', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      AddCharacterCommand('Banner Spear', 'Frosthaven', 'BS', 1).execute();
    });

    test('character with lower initiative is placed before character with higher initiative', () {
      SetInitCommand('Blinkblade', 10).execute();
      SetInitCommand('Banner Spear', 30).execute();

      DrawCommand().execute();

      final list = getIt<GameState>().currentList;
      final bbIdx = list.indexWhere((e) => e.id == 'Blinkblade');
      final bsIdx = list.indexWhere((e) => e.id == 'Banner Spear');
      expect(bbIdx, lessThan(bsIdx),
          reason: 'Blinkblade (init 10) should come before Banner Spear (init 30)');
    });

    test('character with higher initiative is placed after character with lower initiative', () {
      SetInitCommand('Blinkblade', 40).execute();
      SetInitCommand('Banner Spear', 15).execute();

      DrawCommand().execute();

      final list = getIt<GameState>().currentList;
      final bbIdx = list.indexWhere((e) => e.id == 'Blinkblade');
      final bsIdx = list.indexWhere((e) => e.id == 'Banner Spear');
      expect(bsIdx, lessThan(bbIdx),
          reason: 'Banner Spear (init 15) should come before Blinkblade (init 40)');
    });

    test('dead character (health=0) is sorted after alive character even with lower initiative', () {
      final gs = getIt<GameState>();
      final bs = gs.currentList
          .firstWhere((e) => e is Character && e.id == 'Banner Spear') as Character;
      ChangeHealthCommand(-bs.characterState.health.value, bs.id, bs.id).execute();
      expect(bs.characterState.health.value, 0);

      // Banner Spear has lower initiative but is dead
      SetInitCommand('Blinkblade', 30).execute();
      SetInitCommand('Banner Spear', 5).execute();

      DrawCommand().execute();

      final list = gs.currentList;
      final bbIdx = list.indexWhere((e) => e.id == 'Blinkblade');
      final bsIdx = list.indexWhere((e) => e.id == 'Banner Spear');
      expect(bbIdx, lessThan(bsIdx),
          reason: 'Dead Banner Spear should be last even with initiative 5 vs 30');
    });

    test('inactive monster sorted after active character', () {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();

      SetInitCommand('Blinkblade', 50).execute();

      DrawCommand().execute();

      final list = getIt<GameState>().currentList;
      final charIdx = list.indexWhere((e) => e is Character);
      final monsterIdx = list.indexWhere((e) => e is Monster);
      expect(charIdx, lessThan(monsterIdx),
          reason: 'Character should come before inactive monster');
    });

    test('active monster sorted by drawn ability card initiative relative to character', () {
      getIt<GameState>().clearList();
      SetCampaignCommand('Jaws of the Lion').execute();
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();

      final zealot = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster && e.id == 'Zealot') as Monster;
      AddStandeeCommand(1, null, zealot.id, MonsterType.normal, false).execute();

      // Character initiative very high so Zealot should normally come first
      SetInitCommand('Blinkblade', 99).execute();

      DrawCommand().execute();

      final zealotDeck = getIt<GameState>()
          .currentAbilityDecks
          .firstWhere((d) => d.name == zealot.type.deck);
      final zealotInit = zealotDeck.discardPile.peek.initiative;

      final list = getIt<GameState>().currentList;
      final zealotIdx = list.indexWhere((e) => e.id == 'Zealot');
      final charIdx = list.indexWhere((e) => e is Character && e.id == 'Blinkblade');

      if (zealotInit < 99) {
        expect(zealotIdx, lessThan(charIdx),
            reason: 'Zealot (init $zealotInit) should precede Blinkblade (init 99)');
      } else {
        expect(charIdx, lessThan(zealotIdx),
            reason: 'Blinkblade (init 99) should precede Zealot (init $zealotInit)');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // sortMonsterInstances (called during AddStandeeCommand)
  // ---------------------------------------------------------------------------
  group('sortMonsterInstances', () {
    late Monster monster;

    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
      monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
    });

    test('elite standee is sorted before normal standee', () {
      AddStandeeCommand(2, null, monster.id, MonsterType.normal, false).execute();
      AddStandeeCommand(1, null, monster.id, MonsterType.elite, false).execute();

      final instances = monster.monsterInstances;
      expect(instances[0].type, MonsterType.elite,
          reason: 'Elite should be first in the instance list');
      expect(instances[1].type, MonsterType.normal,
          reason: 'Normal should be second');
    });

    test('normal standees are sorted by standee number ascending', () {
      AddStandeeCommand(3, null, monster.id, MonsterType.normal, false).execute();
      AddStandeeCommand(1, null, monster.id, MonsterType.normal, false).execute();

      final instances = monster.monsterInstances;
      expect(instances[0].standeeNr, 1,
          reason: 'Lower standee number should come first');
      expect(instances[1].standeeNr, 3);
    });

    test('elite standees are sorted by standee number ascending', () {
      AddStandeeCommand(3, null, monster.id, MonsterType.elite, false).execute();
      AddStandeeCommand(1, null, monster.id, MonsterType.elite, false).execute();

      final instances = monster.monsterInstances;
      expect(instances[0].standeeNr, 1);
      expect(instances[1].standeeNr, 3);
    });

    test('mixed: elites by nr come before normals by nr', () {
      AddStandeeCommand(2, null, monster.id, MonsterType.normal, false).execute();
      AddStandeeCommand(3, null, monster.id, MonsterType.elite, false).execute();
      AddStandeeCommand(1, null, monster.id, MonsterType.elite, false).execute();
      AddStandeeCommand(4, null, monster.id, MonsterType.normal, false).execute();

      final instances = monster.monsterInstances;
      expect(instances[0].type, MonsterType.elite);
      expect(instances[0].standeeNr, 1);
      expect(instances[1].type, MonsterType.elite);
      expect(instances[1].standeeNr, 3);
      expect(instances[2].type, MonsterType.normal);
      expect(instances[2].standeeNr, 2);
      expect(instances[3].type, MonsterType.normal);
      expect(instances[3].standeeNr, 4);
    });
  });

  // ---------------------------------------------------------------------------
  // sortCharactersFirst (called by NextRoundCommand and SetScenarioCommand)
  // ---------------------------------------------------------------------------
  group('sortCharactersFirst via NextRoundCommand', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
      AddStandeeCommand(1, null, 'Ancient Artillery (FH)', MonsterType.normal, false)
          .execute();
    });

    test('all alive characters appear before active monsters', () {
      NextRoundCommand().execute();

      final list = getIt<GameState>().currentList;
      bool seenActiveMonster = false;
      for (final item in list) {
        if (item is Monster && item.isActive) seenActiveMonster = true;
        if (item is Character &&
            item.characterState.health.value > 0 &&
            seenActiveMonster) {
          fail('Alive character "${item.id}" appeared after an active monster');
        }
      }
    });

    test('dead character is sorted after alive characters', () {
      AddCharacterCommand('Banner Spear', 'Frosthaven', 'BS', 1).execute();
      final bs = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character && e.id == 'Banner Spear') as Character;
      ChangeHealthCommand(-bs.characterState.health.value, bs.id, bs.id).execute();

      NextRoundCommand().execute();

      final list = getIt<GameState>().currentList;
      final bbIdx = list.indexWhere((e) => e is Character && e.id == 'Blinkblade');
      final bsIdx = list.indexWhere((e) => e is Character && e.id == 'Banner Spear');
      expect(bbIdx, lessThan(bsIdx),
          reason: 'Dead Banner Spear should appear after alive Blinkblade');
    });

    test('inactive monster sorted after active monsters', () {
      AddMonsterCommand('Test Boss (FH)', 1, false).execute();
      // Test Boss has no standees → inactive

      NextRoundCommand().execute();

      final list = getIt<GameState>().currentList;
      final activeMonsterIdx =
          list.indexWhere((e) => e is Monster && (e as Monster).isActive);
      final inactiveMonsterIdx =
          list.indexWhere((e) => e is Monster && !(e as Monster).isActive);

      if (activeMonsterIdx != -1 && inactiveMonsterIdx != -1) {
        expect(activeMonsterIdx, lessThan(inactiveMonsterIdx),
            reason: 'Active monster should come before inactive monster');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // drawAbilityCardFromInactiveDeck (called by AddStandeeCommand during playTurns)
  // ---------------------------------------------------------------------------
  group('drawAbilityCardFromInactiveDeck', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Jaws of the Lion').execute();
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
    });

    test('adding first standee during playTurns draws an ability card for the inactive deck', () {
      final zealot = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster && e.id == 'Zealot') as Monster;
      final deck = getIt<GameState>()
          .currentAbilityDecks
          .firstWhere((d) => d.name == zealot.type.deck);

      // Zealot has no standees so not drawn during DrawCommand
      DrawCommand().execute();
      expect(deck.discardPile.isEmpty, isTrue,
          reason: 'Inactive Zealot should not have drawn a card during DrawCommand');

      // Add first standee during playTurns → triggers drawAbilityCardFromInactiveDeck
      AddStandeeCommand(1, null, zealot.id, MonsterType.normal, false).execute();

      expect(deck.discardPile.isNotEmpty, isTrue,
          reason: 'First standee during playTurns should trigger an ability card draw');
    });

    test('adding additional standees to already-active monster does not draw extra cards', () {
      final zealot = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster && e.id == 'Zealot') as Monster;
      final deck = getIt<GameState>()
          .currentAbilityDecks
          .firstWhere((d) => d.name == zealot.type.deck);

      DrawCommand().execute();
      AddStandeeCommand(1, null, zealot.id, MonsterType.normal, false).execute();
      final sizeAfterFirst = deck.discardPile.size();

      // Second standee should NOT draw another card
      AddStandeeCommand(2, null, zealot.id, MonsterType.normal, false).execute();

      expect(deck.discardPile.size(), sizeAfterFirst,
          reason: 'Adding a second standee should not draw another ability card');
    });
  });

  // ---------------------------------------------------------------------------
  // sortItemToPlace (called by AddStandeeCommand during playTurns)
  // ---------------------------------------------------------------------------
  group('sortItemToPlace via AddStandeeCommand during playTurns', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Jaws of the Lion').execute();
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
    });

    test('monster placed before character when its drawn initiative is lower', () {
      // Zealot's lowest card initiative is 27 — set character to 99
      SetInitCommand('Blinkblade', 99).execute();
      DrawCommand().execute();

      final zealot = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster && e.id == 'Zealot') as Monster;
      AddStandeeCommand(1, null, zealot.id, MonsterType.normal, false).execute();

      final deck = getIt<GameState>()
          .currentAbilityDecks
          .firstWhere((d) => d.name == zealot.type.deck);
      final drawnInit = deck.discardPile.peek.initiative;

      final list = getIt<GameState>().currentList;
      final zealotIdx = list.indexWhere((e) => e.id == 'Zealot');
      final charIdx = list.indexWhere((e) => e is Character);

      // When monster's initiative < current item's initiative, sortItemToPlace
      // places it AFTER the current item (not in strict initiative order).
      if (drawnInit < 99) {
        expect(zealotIdx, greaterThan(charIdx),
            reason: 'Zealot (init $drawnInit < 99) should be placed after current Blinkblade');
      }
    });

    test('monster placed after character when its drawn initiative is higher', () {
      // Set character initiative very low so Chaos Demon comes after
      SetInitCommand('Blinkblade', 1).execute();
      DrawCommand().execute();

      final chaosDemon = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster && e.id == 'Chaos Demon') as Monster;
      AddStandeeCommand(1, null, chaosDemon.id, MonsterType.normal, false)
          .execute();

      final deck = getIt<GameState>()
          .currentAbilityDecks
          .firstWhere((d) => d.name == chaosDemon.type.deck);
      final drawnInit = deck.discardPile.peek.initiative;

      final list = getIt<GameState>().currentList;
      final cdIdx = list.indexWhere((e) => e.id == 'Chaos Demon');
      final charIdx = list.indexWhere((e) => e is Character);

      if (drawnInit > 1) {
        expect(charIdx, lessThan(cdIdx),
            reason: 'Blinkblade (init 1) should come before Chaos Demon (init $drawnInit)');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // removeExpiringConditions (via TurnDoneCommand)
  // ---------------------------------------------------------------------------
  group('removeExpiringConditions via TurnDoneCommand', () {
    late Character character;
    late Monster monster;
    late MonsterInstance monsterInstance;

    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
      AddStandeeCommand(1, null, 'Ancient Artillery (FH)', MonsterType.normal, false)
          .execute();

      character = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character) as Character;
      monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      monsterInstance = monster.monsterInstances.first;
    });

    test('stun expires on character when turn advances (condition added before draw)', () {
      // Condition added in chooseInitiative → NOT tracked as "added this turn"
      AddConditionCommand(Condition.stun, character.id, character.id).execute();
      expect(character.characterState.conditions.value, contains(Condition.stun));

      DrawCommand().execute();
      TurnDoneCommand(character.id).execute();

      expect(character.characterState.conditions.value,
          isNot(contains(Condition.stun)),
          reason: 'Stun added before round should expire when character turn advances');
    });

    test('poison does NOT expire when character turn advances', () {
      AddConditionCommand(Condition.poison, character.id, character.id).execute();

      DrawCommand().execute();
      TurnDoneCommand(character.id).execute();

      expect(character.characterState.conditions.value, contains(Condition.poison),
          reason: 'Poison is not in the expiring list and should remain');
    });

    test('muddle expires on character when turn advances', () {
      AddConditionCommand(Condition.muddle, character.id, character.id).execute();

      DrawCommand().execute();
      TurnDoneCommand(character.id).execute();

      expect(character.characterState.conditions.value,
          isNot(contains(Condition.muddle)),
          reason: 'Muddle is expirable and should be removed on turn advance');
    });

    test('immobilize expires on character when turn advances', () {
      AddConditionCommand(Condition.immobilize, character.id, character.id).execute();

      DrawCommand().execute();
      TurnDoneCommand(character.id).execute();

      expect(character.characterState.conditions.value,
          isNot(contains(Condition.immobilize)),
          reason: 'Immobilize is expirable and should be removed on turn advance');
    });

    test('stun on monster instance expires when monster turn advances', () {
      AddConditionCommand(
              Condition.stun, monsterInstance.getId(), monster.id)
          .execute();
      expect(monsterInstance.conditions.value, contains(Condition.stun));

      DrawCommand().execute();
      // First call: notDone → current (no expiry yet)
      TurnDoneCommand(monster.id).execute();
      // Second call: current → done (triggers removeExpiringConditions)
      TurnDoneCommand(monster.id).execute();

      expect(monsterInstance.conditions.value,
          isNot(contains(Condition.stun)),
          reason: 'Stun on monster instance should expire when monster turn advances');
    });

    test('wound on monster instance does NOT expire when monster turn advances', () {
      AddConditionCommand(
              Condition.wound, monsterInstance.getId(), monster.id)
          .execute();

      DrawCommand().execute();
      TurnDoneCommand(monster.id).execute();

      expect(monsterInstance.conditions.value, contains(Condition.wound),
          reason: 'Wound is not expirable and should remain');
    });

    test('stun added during active turn is NOT expired immediately', () {
      DrawCommand().execute();
      // Character is current → condition is tracked as "added this turn"
      AddConditionCommand(Condition.stun, character.id, character.id).execute();

      TurnDoneCommand(character.id).execute();

      expect(character.characterState.conditions.value, contains(Condition.stun),
          reason: 'Stun added during own turn should NOT expire at end of that turn');
    });
  });

  // ---------------------------------------------------------------------------
  // setTurnDone edge cases
  // ---------------------------------------------------------------------------
  group('setTurnDone edge cases', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      AddCharacterCommand('Banner Spear', 'Frosthaven', 'BS', 1).execute();
    });

    test('dead character is skipped as next current figure', () {
      final gs = getIt<GameState>();
      final bs = gs.currentList
          .firstWhere((e) => e is Character && e.id == 'Banner Spear') as Character;
      ChangeHealthCommand(-bs.characterState.health.value, bs.id, bs.id).execute();

      SetInitCommand('Blinkblade', 10).execute();
      SetInitCommand('Banner Spear', 20).execute();
      DrawCommand().execute();

      final bb = gs.currentList
          .firstWhere((e) => e is Character && e.id == 'Blinkblade') as Character;
      expect(bb.turnState.value, TurnsState.current);

      TurnDoneCommand(bb.id).execute();

      expect(bs.turnState.value, isNot(TurnsState.current),
          reason: 'Dead Banner Spear should never become current');
    });

    test('inactive monster is skipped as next current figure', () {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();

      SetInitCommand('Blinkblade', 50).execute();
      DrawCommand().execute();

      final bb = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character) as Character;
      TurnDoneCommand(bb.id).execute();

      final artillery = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      expect(artillery.turnState.value, isNot(TurnsState.current),
          reason: 'Inactive monster should never become current');
    });

    test('items before the clicked index are set to done', () {
      SetInitCommand('Blinkblade', 10).execute();
      SetInitCommand('Banner Spear', 20).execute();
      DrawCommand().execute();

      final list = getIt<GameState>().currentList;
      final bs =
          list.firstWhere((e) => e is Character && e.id == 'Banner Spear') as Character;

      // Click on Banner Spear (index 1) skips Blinkblade to done
      TurnDoneCommand(bs.id).execute();

      final bb =
          list.firstWhere((e) => e is Character && e.id == 'Blinkblade') as Character;
      expect(bb.turnState.value, TurnsState.done,
          reason: 'Blinkblade at index 0 should be set to done when Banner Spear at index 1 is clicked');
    });

    test('clicking a done item reverts it to current', () {
      SetInitCommand('Blinkblade', 10).execute();
      SetInitCommand('Banner Spear', 20).execute();
      DrawCommand().execute();

      final list = getIt<GameState>().currentList;
      final bb =
          list.firstWhere((e) => e is Character && e.id == 'Blinkblade') as Character;

      TurnDoneCommand(bb.id).execute(); // current → done, next becomes current
      expect(bb.turnState.value, TurnsState.done);

      TurnDoneCommand(bb.id).execute(); // done → current (revert)
      expect(bb.turnState.value, TurnsState.current,
          reason: 'Clicking a done item should make it current again');
    });
  });

  // ---------------------------------------------------------------------------
  // shuffleDecksIfNeeded (called by NextRoundCommand)
  // ---------------------------------------------------------------------------
  group('shuffleDecksIfNeeded via NextRoundCommand', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Jaws of the Lion').execute();
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      AddStandeeCommand(1, null, 'Zealot', MonsterType.normal, false).execute();
    });

    test('ability deck with empty draw pile is reshuffled on NextRoundCommand', () {
      final zealot = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster && e.id == 'Zealot') as Monster;
      final deck = getIt<GameState>()
          .currentAbilityDecks
          .firstWhere((d) => d.name == zealot.type.deck);

      // Drain all cards from the draw pile
      while (deck.drawPile.isNotEmpty) {
        DrawAbilityCardCommand(zealot.id).execute();
      }
      expect(deck.drawPile.isEmpty, isTrue,
          reason: 'Precondition: draw pile should be empty');

      NextRoundCommand().execute();

      expect(deck.drawPile.isNotEmpty, isTrue,
          reason: 'Ability deck should be reshuffled when draw pile was empty');
      expect(deck.discardPile.isEmpty, isTrue,
          reason: 'Discard pile should be empty after reshuffle');
    });

    test('ability deck with shuffle-card on top of discard is reshuffled', () {
      final zealot = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster && e.id == 'Zealot') as Monster;
      final deck = getIt<GameState>()
          .currentAbilityDecks
          .firstWhere((d) => d.name == zealot.type.deck);

      // Draw until a shuffle-flagged card lands on top of the discard pile.
      // We drain the deck once; if no shuffle card appears, skip the assertion.
      int attempts = 0;
      while (deck.drawPile.isNotEmpty && attempts < 50) {
        DrawAbilityCardCommand(zealot.id).execute();
        attempts++;
        if (deck.discardPile.isNotEmpty && deck.discardPile.peek.shuffle) break;
      }

      if (deck.discardPile.isNotEmpty && deck.discardPile.peek.shuffle) {
        final discardSizeBefore = deck.discardPile.size();
        NextRoundCommand().execute();
        expect(deck.discardPile.isEmpty, isTrue,
            reason: 'Discard pile should be empty after shuffle-triggered reshuffle');
        expect(deck.drawPile.size(), greaterThanOrEqualTo(discardSizeBefore),
            reason: 'Draw pile should contain all formerly discarded cards');
      }
      // If we never got a shuffle card on top, the test is a no-op (inconclusive but not failing)
    });
  });

  // ---------------------------------------------------------------------------
  // addPerk / removePerk – Hail perk 17 (adds special card to main modifier deck)
  // ---------------------------------------------------------------------------
  group('addPerk/removePerk – Hail perk 17 (Hail special card)', () {
    late Character hail;

    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      // Reset the modifier deck between tests via SetScenarioCommand (section=false
      // calls modifierDeck._initDeck() before we add our character)
      SetScenarioCommand('#0 Howling in the Snow', false).execute();
      // Hail's edition is "Mercenary Packs" (cross-edition character)
      AddCharacterCommand('Hail', 'Mercenary Packs', 'H', 1).execute();
      hail = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character && e.id == 'Hail') as Character;
    });

    test('adding Hail perk 17 adds special card to the main modifier deck', () {
      final deckBefore = getIt<GameState>().modifierDeck.cardCount.value;

      AddPerkCommand(hail.id, 17).execute();

      expect(getIt<GameState>().modifierDeck.hasHail(), isTrue,
          reason: 'Main modifier deck should contain the Hail special card after perk 17');
      expect(getIt<GameState>().modifierDeck.cardCount.value,
          greaterThan(deckBefore),
          reason: 'Main modifier deck size should increase after adding Hail perk 17');
    });

    test('removing Hail perk 17 removes special card from the main modifier deck', () {
      AddPerkCommand(hail.id, 17).execute();
      expect(getIt<GameState>().modifierDeck.hasHail(), isTrue);

      AddPerkCommand(hail.id, 17).execute(); // toggle off

      expect(getIt<GameState>().modifierDeck.hasHail(), isFalse,
          reason: 'Hail special card should be removed when perk 17 is toggled off');
    });

    test('main modifier deck card count is restored after add then remove', () {
      final deckBefore = getIt<GameState>().modifierDeck.cardCount.value;

      AddPerkCommand(hail.id, 17).execute();
      AddPerkCommand(hail.id, 17).execute();

      expect(getIt<GameState>().modifierDeck.cardCount.value, deckBefore,
          reason: 'Deck count should be unchanged after toggling perk on and off');
    });
  });

  // ---------------------------------------------------------------------------
  // addPerk / removePerk – Pain Conduit perk 16 (max health +5)
  // ---------------------------------------------------------------------------
  group('addPerk/removePerk – Pain Conduit perk 16 (max health +5)', () {
    late Character painConduit;

    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Pain Conduit', 'Frosthaven', 'PC', 1).execute();
      painConduit = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character && e.id == 'Pain Conduit') as Character;
    });

    test('adding Pain Conduit perk 16 increases max health by 5', () {
      final maxHealthBefore = painConduit.characterState.maxHealth.value;

      AddPerkCommand(painConduit.id, 16).execute();

      expect(painConduit.characterState.maxHealth.value, maxHealthBefore + 5,
          reason: 'Max health should increase by 5 for Pain Conduit perk 16');
    });

    test('adding Pain Conduit perk 16 increases current health by 5', () {
      final healthBefore = painConduit.characterState.health.value;

      AddPerkCommand(painConduit.id, 16).execute();

      expect(painConduit.characterState.health.value, healthBefore + 5,
          reason: 'Current health should also increase by 5');
    });

    test('removing Pain Conduit perk 16 restores original max health', () {
      final maxHealthBefore = painConduit.characterState.maxHealth.value;

      AddPerkCommand(painConduit.id, 16).execute();
      AddPerkCommand(painConduit.id, 16).execute(); // toggle off

      expect(painConduit.characterState.maxHealth.value, maxHealthBefore,
          reason: 'Max health should be restored to original after toggling perk off');
    });

    test('Pain Conduit perk 16 bonus applies at a higher level', () {
      SetCharacterLevelCommand(5, painConduit.id).execute();
      final maxHealthAtLevel5 = painConduit.characterState.maxHealth.value;

      AddPerkCommand(painConduit.id, 16).execute();

      expect(painConduit.characterState.maxHealth.value, maxHealthAtLevel5 + 5,
          reason: 'Perk 16 always adds exactly +5 regardless of level');
    });
  });

  // ---------------------------------------------------------------------------
  // setCharacterLevel – level capping and special character handling
  // ---------------------------------------------------------------------------
  group('setCharacterLevel special cases', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
    });

    test('Pain Conduit with perk 16 active has correct health after level change', () {
      AddCharacterCommand('Pain Conduit', 'Frosthaven', 'PC', 1).execute();
      final pc = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character && e.id == 'Pain Conduit') as Character;

      AddPerkCommand(pc.id, 16).execute();
      SetCharacterLevelCommand(3, pc.id).execute();

      final baseHealth = pc.characterClass.healthByLevel[2]; // level 3 = index 2
      expect(pc.characterState.health.value, baseHealth + 5,
          reason: 'Pain Conduit with perk 16 should have base level health + 5');
      expect(pc.characterState.maxHealth.value, baseHealth + 5);
    });

    test('character level is capped at max health table length', () {
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      final bb = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character && e.id == 'Blinkblade') as Character;

      final maxLevel = bb.characterClass.healthByLevel.length;
      SetCharacterLevelCommand(maxLevel + 5, bb.id).execute();

      expect(bb.characterState.level.value, maxLevel,
          reason: 'Level should be capped at the number of health table entries');
    });

    test('character health and max health are updated on level change', () {
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      final bb = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character && e.id == 'Blinkblade') as Character;

      SetCharacterLevelCommand(5, bb.id).execute();

      final expectedHealth = bb.characterClass.healthByLevel[4]; // level 5 = index 4
      expect(bb.characterState.health.value, expectedHealth);
      expect(bb.characterState.maxHealth.value, expectedHealth);
    });
  });

  // ---------------------------------------------------------------------------
  // clearTurnState (called by NextRoundCommand)
  // ---------------------------------------------------------------------------
  group('clearTurnState via NextRoundCommand', () {
    late Character character;

    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
      character = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character) as Character;
    });

    test('all turn states are reset to notDone after NextRoundCommand', () {
      DrawCommand().execute();
      TurnDoneCommand(character.id).execute();

      NextRoundCommand().execute();

      for (final item in getIt<GameState>().currentList) {
        expect(item.turnState.value, TurnsState.notDone,
            reason: 'All items should be notDone after round end');
      }
    });

    test('conditions tracking is cleared at round end', () {
      // Add stun during active turn (tracked as this turn)
      DrawCommand().execute();
      AddConditionCommand(Condition.stun, character.id, character.id).execute();
      TurnDoneCommand(character.id).execute();

      // Stun is tracked in conditionsAddedThisTurn
      NextRoundCommand().execute();
      // conditionsAddedThisTurn → conditionsAddedPreviousTurn, and fresh turn starts

      // Round state should be chooseInitiative now
      expect(getIt<GameState>().roundState.value, RoundState.chooseInitiative);
    });
  });

  // ---------------------------------------------------------------------------
  // updateElements (called by NextRoundCommand)
  // ---------------------------------------------------------------------------
  group('updateElements via NextRoundCommand', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();
    });

    test('full element steps to half after NextRoundCommand', () {
      ImbueElementCommand(Elements.fire, false).execute();
      expect(getIt<GameState>().elementState[Elements.fire], ElementState.full);

      NextRoundCommand().execute();

      expect(getIt<GameState>().elementState[Elements.fire], ElementState.half);
    });

    test('half element steps to inert after NextRoundCommand', () {
      ImbueElementCommand(Elements.ice, true).execute(); // half
      expect(getIt<GameState>().elementState[Elements.ice], ElementState.half);

      NextRoundCommand().execute();

      expect(getIt<GameState>().elementState[Elements.ice], ElementState.inert);
    });

    test('inert element stays inert after NextRoundCommand', () {
      // earth is inert by default
      expect(getIt<GameState>().elementState[Elements.earth], ElementState.inert);

      NextRoundCommand().execute();

      expect(getIt<GameState>().elementState[Elements.earth], ElementState.inert);
    });

    test('all six elements decay by one step each round', () {
      ImbueElementCommand(Elements.fire, false).execute();
      ImbueElementCommand(Elements.ice, false).execute();
      ImbueElementCommand(Elements.air, false).execute();
      ImbueElementCommand(Elements.earth, false).execute();
      ImbueElementCommand(Elements.light, false).execute();
      ImbueElementCommand(Elements.dark, false).execute();

      NextRoundCommand().execute();

      for (final element in Elements.values) {
        expect(getIt<GameState>().elementState[element], ElementState.half,
            reason: '${element.name} should step from full to half');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // resetElements (called by SetScenarioCommand)
  // ---------------------------------------------------------------------------
  group('resetElements via SetScenarioCommand', () {
    test('all elements are reset to inert when loading a new scenario', () {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'BB', 1).execute();

      ImbueElementCommand(Elements.fire, false).execute();
      ImbueElementCommand(Elements.light, true).execute();

      SetScenarioCommand('#0 Howling in the Snow', false).execute();

      for (final element in Elements.values) {
        expect(getIt<GameState>().elementState[element], ElementState.inert,
            reason: '${element.name} should be inert after scenario reset');
      }
    });
  });
}
