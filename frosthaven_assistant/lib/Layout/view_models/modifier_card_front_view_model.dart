import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

const int _kPerkSuffixLength = 2;

class ModifierCardFrontViewModel {
  ModifierCardFrontViewModel({required this.card, required this.name});

  final ModifierCard card;
  final String name;

  bool get _allies => name == "allies";
  bool get _isCharacter => name.isNotEmpty && !_allies;
  bool get _imbue => card.gfx.contains("imbue");
  bool get _imbue2 => card.gfx.contains("imbue2");

  String get gfx {
    String g = card.gfx;

    if (_imbue) {
      g = g.replaceAll("imbue-", "");
      if (_imbue2) {
        g = g.replaceAll("imbue2-", "");
      }
      if (g != "plus1") {
        g = "perks/$g";
      }
    }

    if (card.gfx.startsWith("Demons")) {
      g = g.replaceAll("Demons-", "");
    } else if (card.gfx.startsWith("Merchant-Guild")) {
      g = g.replaceAll("Merchant-Guild-", "");
    } else if (card.gfx.startsWith("Military")) {
      g = g.replaceAll("Military-", "");
    }

    if (g.startsWith("P")) {
      final character = GameMethods.getCharacterByName(name);
      assert(character != null);
      if (character != null) {
        final perks = character.characterState.useFHPerks.value
            ? character.characterClass.perksFH
            : character.characterClass.perks;
        g = g.substring(1);
        if (g.endsWith("-2")) {
          g = g.substring(0, g.length - _kPerkSuffixLength);
          final int? index = int.tryParse(g);
          if (index != null &&
              index >= 0 &&
              index < perks.length &&
              perks[index].add.isNotEmpty) {
            g = perks[index].add.last;
          }
        } else {
          final int? index = int.tryParse(g);
          if (index != null &&
              index >= 0 &&
              index < perks.length &&
              perks[index].add.isNotEmpty) {
            g = perks[index].add.first;
          }
        }
      }
    }

    return "assets/images/attack/$g.png";
  }

  String get extraGfx {
    if (_imbue2) return 'assets/images/attack/advancedImbue.png';
    if (_imbue) return 'assets/images/attack/imbue.png';
    if (_allies) return 'assets/images/attack/allies.png';
    if (card.gfx.startsWith("Demons")) return 'assets/images/demons.png';
    if (card.gfx.startsWith("Merchant-Guild")) return 'assets/images/merchant-guild.png';
    if (card.gfx.startsWith("Military")) return 'assets/images/military.png';
    if (_isCharacter) return 'assets/images/class-icons/$name.png';
    return "";
  }

  bool get hasExtra =>
      card.gfx.startsWith("P") ||
      _allies ||
      _imbue ||
      card.gfx.startsWith("Demons") ||
      card.gfx.startsWith("Merchant-Guild") ||
      card.gfx.startsWith("Military");
}
