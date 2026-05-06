import 'package:frosthaven_assistant/Model/character_class.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

const int _kDigit1 = 1;
const int _kDigit2 = 2;
const int _kDigit3 = 3;
const int _kDigit4 = 4;

class PerkListTileViewModel {
  const PerkListTileViewModel({
    required this.character,
    required this.index,
    required this.perk,
  });

  final Character character;
  final int index;
  final PerkModel perk;

  bool get added => character.characterState.perkList[index];

  bool get enabled =>
      (added && GameMethods.canRemovePerk(character, index)) ||
      (!added && GameMethods.canAddPerk(character, index));

  String get description {
    final text = perk.text;
    if (text.isNotEmpty) return text;

    final adds = perk.add;
    final removes = perk.remove;
    final removeAmount = removes.length;
    final addsAmount = adds.length;

    if (adds.isNotEmpty && removes.isEmpty) {
      String d = "Add ";
      d += _nrTextFromDigit(addsAmount);
      d += "${_cardText(adds.first)} card";
      if (addsAmount > 1) d += "s";
      return d;
    } else if (adds.isEmpty && removes.isNotEmpty) {
      String d = "Remove ";
      d += _nrTextFromDigit(removeAmount);
      d += "${_cardText(removes.first)} card";
      if (removeAmount > 1) d += "s";
      return d;
    } else if (adds.isNotEmpty && removes.isNotEmpty) {
      String d = "Replace ";
      d += _nrTextFromDigit(removes.length);
      d += "${_cardText(removes.first)} card";
      if (adds.length > 1) d += "s";
      d += " with ";
      final addsAmount2 = adds.length;
      d += _nrTextFromDigit(addsAmount2);
      d += "${_cardText(adds.first)} card";
      if (addsAmount2 > 1) d += "s";
      return d;
    }
    return "";
  }

  static String _nrTextFromDigit(int digit) {
    if (digit == _kDigit1) return "one ";
    if (digit == _kDigit2) return "two ";
    if (digit == _kDigit3) return "three ";
    if (digit == _kDigit4) return "four ";
    return "";
  }

  static String _cardText(String gfx) {
    if (gfx.startsWith("perks/")) {
      gfx = gfx.substring("perks/".length);
    }
    bool negative = gfx.startsWith("minus");
    String retVal = "+";
    if (negative) {
      retVal = "-";
      gfx = gfx.substring("minus".length);
    } else {
      gfx = gfx.substring("plus".length);
    }
    retVal += gfx[0];
    if (gfx.length > 1) {
      gfx = gfx.substring(1);
      String flip = "";
      String range = "";
      String target = "";
      if (gfx.endsWith("flip")) {
        flip = "%flip%";
        gfx = gfx.substring(0, gfx.length - "flip".length);
      }
      if (gfx.contains("range")) {
        range = " %range% ${gfx.substring(gfx.length - 1)}";
        gfx = gfx.substring(0, gfx.length - "range".length - 1);
      }
      String ally = "";
      if (gfx.contains("ally")) {
        ally = ", %target%1 ally";
        gfx = gfx.substring(0, gfx.length - "ally".length);
      }
      if (gfx.contains("target")) {
        target = " %target% ${gfx.substring(gfx.length - 1)}";
        gfx = gfx.substring(0, gfx.length - "target".length - 1);
      }
      String mainMod = "";
      String maybeNr = "";
      if (gfx.length > 1) {
        maybeNr = gfx.substring(gfx.length - 1);
        int? nr = int.tryParse(maybeNr);
        if (nr == null) {
          maybeNr = "";
        } else {
          gfx = gfx.substring(0, gfx.length - 1);
        }
        mainMod = "%$gfx%";
      }

      bool positiveMod = gfx == "invisible" ||
          gfx == "heal" ||
          gfx == "strengthen" ||
          gfx == "regenerate" ||
          gfx == "bless" ||
          gfx == "ward" ||
          gfx == "safeguard" ||
          gfx == "dodge";
      if (ally.isEmpty && positiveMod && range.isEmpty) {
        ally = ", self";
      }

      String quotes = "";
      String initialQuoteSpace = "";
      if (mainMod.isNotEmpty &&
          (ally.isNotEmpty || maybeNr.isNotEmpty || range.isNotEmpty)) {
        quotes = "\"";
        initialQuoteSpace = " ";
      }

      if (mainMod.isEmpty && target.isNotEmpty) {
        target =
            "+ ${target.substring(target.length - 1, target.length)}%target%";
      }

      return "$retVal$initialQuoteSpace$quotes$mainMod$maybeNr$range$target$ally$quotes$flip";
    }
    return retVal;
  }
}
