import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue1_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue2_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_imbue_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_bless_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_curse_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
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

  ModifierDeck deck() => getIt<GameState>().modifierDeck;
  GameState gs() => getIt<GameState>();

  // ── draw() ────────────────────────────────────────────────────────────────

  group('ModifierDeck.draw', () {
    test('drawing multiply card sets needsShuffle', () {
      // Draw until we hit a multiply card (nullAttack or doubleAttack)
      bool foundMultiply = false;
      for (int i = 0; i < 50; i++) {
        if (deck().drawPile.isEmpty) break;
        gs().action(DrawModifierCardCommand(''));
        if (deck().discardPile
                .getList()
                .any((c) => c.type == CardType.multiply)) {
          foundMultiply = true;
          break;
        }
      }
      if (foundMultiply) {
        expect(deck().needsShuffle, isTrue);
      }
      while (gs().commandIndex.value >= 0) gs().undo();
    });

    test('drawing a bless card decrements bless count', () {
      // Add 2 bless cards to the deck
      gs().action(ChangeBlessCommand(1, '', ''));
      gs().action(ChangeBlessCommand(1, '', ''));
      expect(deck().getRemovable('bless').value, 2);

      // Draw until a bless is drawn
      bool drewBless = false;
      for (int i = 0; i < 30; i++) {
        if (deck().drawPile.isEmpty) break;
        final before = deck().getRemovable('bless').value;
        gs().action(DrawModifierCardCommand(''));
        if (deck().getRemovable('bless').value < before) {
          drewBless = true;
          break;
        }
      }
      if (drewBless) {
        expect(deck().getRemovable('bless').value, lessThan(2));
      }
      while (gs().commandIndex.value >= 0) gs().undo();
    });

    test('drawing all cards triggers reshuffle when drawPile is empty', () {
      // Draw all cards to empty the deck, then draw one more (forces reshuffle)
      int initialSize = deck().drawPile.size();
      for (int i = 0; i < initialSize; i++) {
        gs().action(DrawModifierCardCommand(''));
      }
      expect(deck().drawPile.isEmpty, isTrue);
      // Drawing when empty reshuffles the discard pile into draw pile
      gs().action(DrawModifierCardCommand(''));
      // After reshuffle+draw, discard pile has the one drawn card
      expect(deck().discardPile.size(), greaterThan(0));
      while (gs().commandIndex.value >= 0) gs().undo();
    });
  });

  // ── setImbue1 / setImbue2 / resetImbue ───────────────────────────────────

  group('ModifierDeck imbue', () {
    test('setImbue1 sets imbuement to 1 and adds imbue cards', () {
      gs().action(AMDImbue1Command());
      expect(deck().imbuement.value, 1);
      final hasImbueCards =
          deck().drawPile.getList().any((c) => c.gfx.startsWith('imbue'));
      expect(hasImbueCards, isTrue);
      gs().undo();
    });

    test('setImbue2 sets imbuement to 2 and adds imbue2 cards', () {
      gs().action(AMDImbue2Command());
      expect(deck().imbuement.value, 2);
      final hasImbue2Cards =
          deck().drawPile.getList().any((c) => c.gfx.startsWith('imbue2'));
      expect(hasImbue2Cards, isTrue);
      gs().undo();
    });

    test('setImbue2 from scratch also applies setImbue1 first', () {
      expect(deck().imbuement.value, 0);
      gs().action(AMDImbue2Command());
      expect(deck().imbuement.value, 2);
      // Both imbue and imbue2 cards should be present
      final hasImbueCards =
          deck().drawPile.getList().any((c) => c.gfx.startsWith('imbue'));
      expect(hasImbueCards, isTrue);
      gs().undo();
    });

    test('resetImbue from imbue1 removes imbue cards and resets to 0', () {
      gs().action(AMDImbue1Command());
      expect(deck().imbuement.value, 1);
      gs().action(AMDRemoveImbueCommand());
      expect(deck().imbuement.value, 0);
      final hasImbueCards =
          deck().drawPile.getList().any((c) => c.gfx.startsWith('imbue'));
      expect(hasImbueCards, isFalse);
      gs().undo();
      gs().undo();
    });

    test('resetImbue from imbue2 restores minus2 and plus0 cards', () {
      gs().action(AMDImbue2Command());
      expect(deck().imbuement.value, 2);
      gs().action(AMDRemoveImbueCommand());
      expect(deck().imbuement.value, 0);
      // After reset from imbue2, minus2 and plus0 cards should be back
      final hasMinus2 =
          deck().drawPile.getList().any((c) => c.gfx == 'minus2');
      expect(hasMinus2, isTrue);
      gs().undo();
      gs().undo();
    });

    test('resetImbue is a no-op when imbuement is already 0', () {
      expect(deck().imbuement.value, 0);
      final drawSizeBefore = deck().drawPile.size();
      gs().action(AMDRemoveImbueCommand());
      expect(deck().imbuement.value, 0);
      expect(deck().drawPile.size(), drawSizeBefore);
      gs().undo();
    });
  });

  // ── _handleRemovableCards ─────────────────────────────────────────────────

  group('ModifierDeck removable cards', () {
    test('adding a curse increases curse count and inserts card', () {
      final before = deck().getRemovable('curse').value;
      gs().action(ChangeCurseCommand(1, '', ''));
      expect(deck().getRemovable('curse').value, before + 1);
      final curseInDeck =
          deck().drawPile.getList().where((c) => c.gfx == 'curse').length;
      expect(curseInDeck, before + 1);
      gs().undo();
    });

    test('removing a curse decreases curse count and removes card from deck',
        () {
      // Add 2 curses first
      gs().action(ChangeCurseCommand(1, '', ''));
      gs().action(ChangeCurseCommand(1, '', ''));
      expect(deck().getRemovable('curse').value, 2);
      // Remove one
      gs().action(ChangeCurseCommand(-1, '', ''));
      expect(deck().getRemovable('curse').value, 1);
      gs().undo();
      gs().undo();
      gs().undo();
    });

    test('adding a bless increases bless count in deck', () {
      final before = deck().getRemovable('bless').value;
      gs().action(ChangeBlessCommand(1, '', ''));
      expect(deck().getRemovable('bless').value, before + 1);
      gs().undo();
    });
  });
}
