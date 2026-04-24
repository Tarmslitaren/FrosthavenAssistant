// ignore_for_file: no-magic-number

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/loot_deck_view_model.dart';
import 'package:frosthaven_assistant/Layout/view_models/modifier_deck_view_model.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/game_event.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
        RoundState.chooseInitiative;
    getIt<Settings>().hideLootDeck.value = false;
  });

  tearDown(() {
    getIt<Settings>().hideLootDeck.value = false;
  });

  // ── LootDeckViewModel ──────────────────────────────────────────────────────

  LootDeckViewModel makeLootVm() => LootDeckViewModel(
        gameState: getIt<GameState>(),
        gameData: getIt<GameData>(),
        settings: getIt<Settings>(),
      );

  group('LootDeckViewModel.shouldHide', () {
    test('false when deck has cards and hideLootDeck is false', () {
      // Testdata campaign loads with loot cards
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      final vm = makeLootVm();
      // If the loot deck has cards, shouldHide should be false.
      final hasDeckCards = !vm.lootDeck.drawPileIsEmpty ||
          !vm.lootDeck.discardPileIsEmpty;
      if (hasDeckCards) {
        expect(vm.shouldHide, isFalse);
      }
      getIt<GameState>().undo();
    });

    test('true when hideLootDeck setting is true', () {
      getIt<Settings>().hideLootDeck.value = true;
      expect(makeLootVm().shouldHide, isTrue);
    });
  });

  group('LootDeckViewModel.currentCharacter', () {
    test('null when no character has current turn', () {
      expect(makeLootVm().currentCharacter, isNull);
    });

    test('non-null when character has current turn', () {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      final gs = getIt<GameState>();
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;
      (character.characterState.initiative as ValueNotifier<int>).value = 50;
      DrawCommand(gameState: gs).execute();
      // First item is now current
      expect(makeLootVm().currentCharacter, isNotNull);
      gs.undo();
      gs.undo();
    });
  });

  group('LootDeckViewModel.currentCharacterColor', () {
    test('transparent when no current character', () {
      expect(makeLootVm().currentCharacterColor, Colors.transparent);
    });
  });

  group('LootDeckViewModel.currentCharacterName', () {
    test('null when no current character', () {
      expect(makeLootVm().currentCharacterName, isNull);
    });
  });

  group('LootDeckViewModel.initAnimationEnabled', () {
    test('false when last event is not LootCardDrawnEvent', () {
      expect(makeLootVm().initAnimationEnabled(), isFalse);
    });

    test('true when last event is LootCardDrawnEvent', () {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      final gs = getIt<GameState>();
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;
      (character.characterState.initiative as ValueNotifier<int>).value = 50;
      DrawCommand(gameState: gs).execute();
      if (!gs.lootDeck.drawPileIsEmpty) {
        gs.action(DrawLootCardCommand(gameState: gs));
        expect(makeLootVm().initAnimationEnabled(), isTrue);
        gs.undo();
      }
      gs.undo();
      gs.undo();
    });
  });

  group('LootDeckViewModel notifiers', () {
    test('userScalingBars listenable is exposed', () {
      expect(makeLootVm().userScalingBars, isNotNull);
    });

    test('commandIndex listenable is exposed', () {
      expect(makeLootVm().commandIndex, isNotNull);
    });

    test('cardCount listenable is exposed', () {
      expect(makeLootVm().cardCount, isNotNull);
    });
  });

  // ── ModifierDeckViewModel ──────────────────────────────────────────────────

  ModifierDeckViewModel makeModifierVm(String name) => ModifierDeckViewModel(
        name,
        gameState: getIt<GameState>(),
        gameData: getIt<GameData>(),
        settings: getIt<Settings>(),
      );

  group('ModifierDeckViewModel.deck', () {
    test('can access the monster modifier deck (returns state.modifierDeck)', () {
      // 'Monster' is not a character id, so getModifierDeck falls back to
      // the main state.modifierDeck (used for monsters).
      final vm = makeModifierVm('Monster');
      expect(vm.deck, isNotNull);
    });

    test('deck for allies returns allies deck', () {
      final vm = makeModifierVm('allies');
      expect(vm.deck, isNotNull);
    });
  });

  group('ModifierDeckViewModel.currentCharacter', () {
    test('null when deck name is Monster (not a character deck)', () {
      final vm = makeModifierVm('Monster');
      expect(vm.currentCharacter, isNull);
    });

    test('null when character deck but that character is not current', () {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      // Blinkblade deck name matches the character id.
      final vm = makeModifierVm('Blinkblade');
      // No current turn set → null
      expect(vm.currentCharacter, isNull);
      getIt<GameState>().undo();
    });
  });

  group('ModifierDeckViewModel.currentCharacterColor', () {
    test('transparent when no current character', () {
      final vm = makeModifierVm('Monster');
      expect(vm.currentCharacterColor, Colors.transparent);
    });
  });

  group('ModifierDeckViewModel.currentCharacterName', () {
    test('null when no current character', () {
      final vm = makeModifierVm('Monster');
      expect(vm.currentCharacterName, isNull);
    });
  });

  group('ModifierDeckViewModel.initAnimationEnabled', () {
    test('false when last event is not ModifierCardDrawnEvent', () {
      final vm = makeModifierVm('Monster');
      expect(vm.initAnimationEnabled(), isFalse);
    });

    test('true after drawing a modifier card for that deck', () {
      final gs = getIt<GameState>();
      gs.action(DrawModifierCardCommand('Monster', gameState: gs));
      final vm = makeModifierVm('Monster');
      expect(vm.initAnimationEnabled(), isTrue);
      gs.undo();
    });

    test('false for different deck name after drawing from Monster deck', () {
      final gs = getIt<GameState>();
      gs.action(DrawModifierCardCommand('Monster', gameState: gs));
      final vm = makeModifierVm('Blinkblade');
      expect(vm.initAnimationEnabled(), isFalse);
      gs.undo();
    });
  });

  group('ModifierDeckViewModel notifiers', () {
    test('userScalingBars listenable is exposed', () {
      expect(makeModifierVm('Monster').userScalingBars, isNotNull);
    });

    test('commandIndex listenable is exposed', () {
      expect(makeModifierVm('Monster').commandIndex, isNotNull);
    });

    test('modelData listenable is exposed', () {
      expect(makeModifierVm('Monster').modelData, isNotNull);
    });
  });
}
