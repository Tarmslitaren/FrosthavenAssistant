import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

class StatusMenuStatColumnViewModel {
  const StatusMenuStatColumnViewModel({
    required this.figure,
    required this.isMonster,
    required this.isCharacter,
    required this.isSummon,
    required this.characterId,
    required this.monsterId,
    required this.immunities,
    required this.hasVimthreader,
    required this.hasLifespeaker,
    required this.hasIncarnate,
    required this.character,
    required this.gameState,
    required this.settings,
  });

  final FigureState figure;
  final bool isMonster;
  final bool isCharacter;
  final bool isSummon;
  final String? characterId;
  final String? monsterId;
  final List<String> immunities;
  final bool hasVimthreader;
  final bool hasLifespeaker;
  final bool hasIncarnate;
  final Character? character;
  final GameState gameState;
  final Settings settings;

  ModifierDeck get deck {
    ModifierDeck d = gameState.modifierDeck;
    if (isMonster) {
      for (final item in gameState.currentList) {
        if (item.id == monsterId &&
            item is Monster &&
            item.isAlly &&
            (gameState.allyDeckInOGGloom.value ||
                !GameMethods.isOgGloomEdition())) {
          d = gameState.modifierDeckAllies;
        }
      }
    }
    if (isCharacter && !isSummon) {
      for (final item in gameState.currentList) {
        if (item.id == characterId && item is Character) {
          d = item.characterState.modifierDeck;
        }
      }
    }
    final cId = characterId;
    if (isSummon && cId != null) {
      d = GameMethods.getModifierDeck(cId, gameState);
    }
    return d;
  }

  bool get hasXp {
    if (!isCharacter || isSummon) return false;
    for (final item in gameState.currentList) {
      if (item.id == characterId && item is Character) {
        return !GameMethods.isObjectiveOrEscort(item.characterClass);
      }
    }
    return false;
  }

  bool get isObjective {
    if (!isCharacter || isSummon) return false;
    for (final item in gameState.currentList) {
      if (item.id == characterId && item is Character) {
        return GameMethods.isObjectiveOrEscort(item.characterClass);
      }
    }
    return false;
  }

  bool get characterHasAmd {
    if (!isCharacter || isSummon) return false;
    for (final item in gameState.currentList) {
      if (item.id == characterId && item is Character) {
        return item.characterClass.perks.isNotEmpty;
      }
    }
    return false;
  }

  bool get showCharacterAmd =>
      (characterHasAmd && settings.showCharacterAMD.value && isCharacter) ||
      isSummon;

  bool get showMonsterAmd =>
      settings.showAmdDeck.value && (isObjective || (isMonster && !isSummon));

  bool get showAmd => showCharacterAmd || showMonsterAmd;

  bool get isAlly => deck.name == "allies";

  bool get canBeCursed {
    for (final item in immunities) {
      if (item.substring(1, item.length - 1) == "curse") return false;
    }
    return true;
  }

  int get nrOfEnfeebles {
    int n = 0;
    if (hasVimthreader) n++;
    if (hasLifespeaker) n++;
    if (hasIncarnate) n++;
    return n;
  }

  int get nrOfEmpowers {
    int n = 0;
    if (hasVimthreader) n++;
    if (hasIncarnate) n++;
    return n;
  }

  bool get hasMoreThanOneEnfeeble => isMonster && nrOfEnfeebles > 1;

  bool get hasMoreThanOneEmpower =>
      ((isCharacter || isAlly) && nrOfEmpowers > 1) ||
      (isCharacter && character?.id == "Ruinmaw" && nrOfEmpowers > 0);

  ValueListenable<int> get xpNotifier =>
      figure is CharacterState
          ? (figure as CharacterState).xp
          : ValueNotifier<int>(0);
}
