import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:frosthaven_assistant/services/translation_service.dart';

class SetLevelMenuViewModel {
  const SetLevelMenuViewModel({
    required this.monster,
    required this.figure,
    required this.characterId,
  });

  final Monster? monster;
  final FigureState? figure;
  final String? characterId;

  bool get isSummon => monster == null && figure is MonsterInstance;

  bool get showLegend => figure == null;

  String get name {
    if (monster != null) return getIt<TranslationService>().t(monster!.type.display);
    if (figure is MonsterInstance) return (figure as MonsterInstance).name;
    return "";
  }

  String get ownerId {
    if (monster != null) return monster!.id;
    if (figure is MonsterInstance && characterId != null) return characterId!;
    return "";
  }

  String get figureId {
    if (figure is CharacterState) {
      return (figure as CharacterState).display.value;
    }
    if (figure is MonsterInstance) {
      final instance = figure as MonsterInstance;
      return instance.name + instance.gfx + instance.standeeNr.toString();
    }
    return "";
  }

  int get trapValue => GameMethods.getTrapValue();
  int get hazardValue => GameMethods.getHazardValue();
  int get xpValue => GameMethods.getXPValue();
  int get coinValue => GameMethods.getCoinValue();
}
