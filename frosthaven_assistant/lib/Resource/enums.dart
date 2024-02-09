import 'package:collection/collection.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

enum Condition {
  stun,
  immobilize,
  disarm,
  wound,
  wound2,
  muddle,
  poison,
  poison2,
  poison3,
  poison4,
  bane,
  brittle,
  chill,
  infect,
  impair,
  rupture,
  strengthen,
  invisible,
  regenerate,
  ward,
  dodge,

  character1,
  character2,
  character3,
  character4;

  String _getCharacterName(int index) {
    List<Character> characters = GameMethods.getCurrentCharacters();
    characters.sortBy((element) => element.characterClass.name);
    if (characters.length > index) {
      return characters[index].characterClass.name;
    }
    return "Escort"; //some basic
  }

  String getName() {
    //get current characters, sort by name and add to this
    if (this == Condition.character1) {
      return _getCharacterName(0);
    } else if (this == Condition.character2) {
      return _getCharacterName(1);
    } else if (this == Condition.character3) {
      return _getCharacterName(2);
    } else if (this == Condition.character4) {
      return _getCharacterName(3);
    }
    return name;
  }

  @override
  String toString() {
    return index.toString();
  }
}

enum ElementState { full, half, inert }

enum Elements { fire, ice, air, earth, light, dark }

enum RoundState {
  chooseInitiative,
  playTurns,
}

enum ListItemState {
  chooseInitiative, //gray
  waitingTurn, //hopeful
  myTurn, //conditions reminder (above in list is gray)
  doneTurn, //gray, expire conditions
}

enum MonsterType {
  normal,
  elite,
  boss,
  summon
}

enum TurnsState {
  notDone, //if got condition while in this state or from earlier round: remove at end of current
  current, //mark conditions added here to not be removed yet
  done //mark conditions added here to not be removed yet
}

enum NetworkMessage { init, action, undo, redo }
