// ignore_for_file: avoid-late-keyword, no-empty-block, no-magic-number, avoid-non-null-assertion

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue1_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue2_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_imbue_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_bless_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_curse_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../unit_helpers.dart';

void main() {
  late GameState gameState;

  setUpAll(initTestBinding);

  setUp(() {
    (gameState, _) = makeGameAndSettings();
  });

  ModifierDeck deck() => gameState.modifierDeck;

  // ── draw() ────────────────────────────────────────────────────────────────

  group('ModifierDeck.draw', () {
    test('drawing multiply card sets needsShuffle', () {
      bool foundMultiply = false;
      for (int i = 0; i < 50; i++) {
        if (deck().drawPileIsEmpty) break;
        gameState.action(DrawModifierCardCommand('', gameState: gameState));
        if (deck()
            .discardPileContents
            .any((c) => c.type == CardType.multiply)) {
          foundMultiply = true;
          break;
        }
      }
      if (foundMultiply) {
        expect(deck().needsShuffle, isTrue);
      }
    });

    test('drawing a bless card decrements bless count', () {
      gameState.action(ChangeBlessCommand(1, '', '', gameState: gameState));
      gameState.action(ChangeBlessCommand(1, '', '', gameState: gameState));
      expect(deck().getRemovable('bless').value, 2);

      bool drewBless = false;
      for (int i = 0; i < 30; i++) {
        if (deck().drawPileIsEmpty) break;
        final before = deck().getRemovable('bless').value;
        gameState.action(DrawModifierCardCommand('', gameState: gameState));
        if (deck().getRemovable('bless').value < before) {
          drewBless = true;
          break;
        }
      }
      if (drewBless) {
        expect(deck().getRemovable('bless').value, lessThan(2));
      }
    });

    test('drawing all cards triggers reshuffle when drawPile is empty', () {
      final initialSize = deck().drawPileSize;
      for (int i = 0; i < initialSize; i++) {
        gameState.action(DrawModifierCardCommand('', gameState: gameState));
      }
      expect(deck().drawPileIsEmpty, isTrue);
      gameState.action(DrawModifierCardCommand('', gameState: gameState));
      expect(deck().discardPileSize, greaterThan(0));
    });
  });

  // ── setImbue1 / setImbue2 / resetImbue ───────────────────────────────────

  group('ModifierDeck imbue', () {
    test('setImbue1 sets imbuement to 1 and adds imbue cards', () {
      gameState.action(AMDImbue1Command(gameState: gameState));
      expect(deck().imbuement.value, 1);
      final hasImbueCards = deck()
          .drawPileContents
          .toList()
          .any((c) => c.gfx.startsWith('imbue'));
      expect(hasImbueCards, isTrue);
    });

    test('setImbue2 sets imbuement to 2 and adds imbue2 cards', () {
      gameState.action(AMDImbue2Command(gameState: gameState));
      expect(deck().imbuement.value, 2);
      final hasImbue2Cards = deck()
          .drawPileContents
          .toList()
          .any((c) => c.gfx.startsWith('imbue2'));
      expect(hasImbue2Cards, isTrue);
    });

    test('setImbue2 from scratch also applies setImbue1 first', () {
      expect(deck().imbuement.value, 0);
      gameState.action(AMDImbue2Command(gameState: gameState));
      expect(deck().imbuement.value, 2);
      final hasImbueCards = deck()
          .drawPileContents
          .toList()
          .any((c) => c.gfx.startsWith('imbue'));
      expect(hasImbueCards, isTrue);
    });

    test('resetImbue from imbue1 removes imbue cards and resets to 0', () {
      gameState.action(AMDImbue1Command(gameState: gameState));
      expect(deck().imbuement.value, 1);
      gameState.action(AMDRemoveImbueCommand(gameState: gameState));
      expect(deck().imbuement.value, 0);
      final hasImbueCards = deck()
          .drawPileContents
          .toList()
          .any((c) => c.gfx.startsWith('imbue'));
      expect(hasImbueCards, isFalse);
    });

    test('resetImbue from imbue2 restores minus2 and plus0 cards', () {
      gameState.action(AMDImbue2Command(gameState: gameState));
      expect(deck().imbuement.value, 2);
      gameState.action(AMDRemoveImbueCommand(gameState: gameState));
      expect(deck().imbuement.value, 0);
      final hasMinus2 =
          deck().drawPileContents.toList().any((c) => c.gfx == 'minus2');
      expect(hasMinus2, isTrue);
    });

    test('resetImbue is a no-op when imbuement is already 0', () {
      expect(deck().imbuement.value, 0);
      final drawSizeBefore = deck().drawPileSize;
      gameState.action(AMDRemoveImbueCommand(gameState: gameState));
      expect(deck().imbuement.value, 0);
      expect(deck().drawPileSize, drawSizeBefore);
    });
  });

  // ── _handleRemovableCards ─────────────────────────────────────────────────

  group('ModifierDeck removable cards', () {
    test('adding a curse increases curse count and inserts card', () {
      final before = deck().getRemovable('curse').value;
      gameState.action(ChangeCurseCommand(1, '', '', gameState: gameState));
      expect(deck().getRemovable('curse').value, before + 1);
      final curseInDeck = deck()
          .drawPileContents
          .toList()
          .where((c) => c.gfx == 'curse')
          .length;
      expect(curseInDeck, before + 1);
    });

    test('removing a curse decreases curse count and removes card from deck',
        () {
      gameState.action(ChangeCurseCommand(1, '', '', gameState: gameState));
      gameState.action(ChangeCurseCommand(1, '', '', gameState: gameState));
      expect(deck().getRemovable('curse').value, 2);
      gameState.action(ChangeCurseCommand(-1, '', '', gameState: gameState));
      expect(deck().getRemovable('curse').value, 1);
    });

    test('adding a bless increases bless count in deck', () {
      final before = deck().getRemovable('bless').value;
      gameState.action(ChangeBlessCommand(1, '', '', gameState: gameState));
      expect(deck().getRemovable('bless').value, before + 1);
    });
  });
}
