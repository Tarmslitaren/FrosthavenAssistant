import 'package:collection/collection.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class StatusMenuViewModel {
  StatusMenuViewModel({
    required this.figureId,
    this.monsterId,
    this.characterId,
    GameState? gameState,
    Settings? settings,
  })  : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final String figureId;
  final String? monsterId;
  final String? characterId;
  final GameState _gameState;
  final Settings _settings;

  bool get showCustomContent => _settings.showCustomContent.value;

  bool get isMonster => monsterId != null;
  bool get isCharacter => characterId != null;
  bool get isSummon => monsterId == null && characterId != figureId;

  String get ownerId {
    if (monsterId != null) return monsterId!;
    if (characterId != null) return characterId!;
    return "";
  }

  FigureState? get figure => GameMethods.getFigure(ownerId, figureId);

  Monster? get monster {
    if (monsterId == null) return null;
    return _gameState.currentList.firstWhereOrNull(
        (item) => item.id == monsterId) as Monster?;
  }

  Character? get character {
    final match = _gameState.currentList
        .firstWhereOrNull((item) => item.id == characterId);
    return match is Character ? match : null;
  }

  ListItemData? get owner =>
      _gameState.currentList.firstWhereOrNull((item) => item.id == ownerId);

  String get name {
    final fig = figure;
    final mon = monster;
    if (fig is MonsterInstance && mon != null) {
      return "${mon.type.display} ${fig.standeeNr}";
    }
    if (fig is CharacterState && character != null) {
      return character!.characterClass.name;
    }
    if (monsterId != null) return monsterId!;
    if (characterId != null) return characterId!;
    return "";
  }

  List<String> get immunities {
    final fig = figure;
    final mon = monster;
    if (fig is! MonsterInstance || mon == null) return [];
    final monsterData = mon.type.levels[mon.level.value];
    if (fig.type == MonsterType.normal) {
      return monsterData.normal?.immunities ?? [];
    }
    if (fig.type == MonsterType.elite) {
      return monsterData.elite?.immunities ?? [];
    }
    if (fig.type == MonsterType.boss) {
      return monsterData.boss?.immunities ?? [];
    }
    return [];
  }

  bool get isIceWraith => monster?.type.deck == "Ice Wraith";

  bool get isElite {
    final fig = figure;
    return fig is MonsterInstance && fig.type == MonsterType.elite;
  }

  bool get hasShield {
    final mon = monster;
    final fig = figure;
    if (mon == null || fig is! MonsterInstance) return false;
    return GameMethods.hasShield(mon, fig);
  }

  bool get hasRetaliate {
    final mon = monster;
    final fig = figure;
    if (mon == null || fig is! MonsterInstance) return false;
    return GameMethods.hasRetaliate(mon, fig);
  }

  bool get hasMireFoot =>
      showCustomContent &&
      _gameState.currentList.any((item) => item.id == "Mirefoot");

  bool get hasIncarnate =>
      showCustomContent &&
      _gameState.currentList.any((item) => item.id == "Incarnate");

  bool get hasVimthreader =>
      showCustomContent &&
      _gameState.currentList.any((item) => item.id == "Vimthreader");

  bool get hasLifespeaker =>
      showCustomContent &&
      _gameState.currentList.any((item) => item.id == "Lifespeaker");

  bool get hasPlagueHerald => _gameState.currentList.any((item) =>
      item is Character &&
      item.id == "Plagueherald" &&
      item.characterClass.edition == "Gloomhaven 2nd Edition");
}
