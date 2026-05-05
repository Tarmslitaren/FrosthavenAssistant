import '../../enums.dart';
import '../../game_methods.dart';
import '../../state/game_state.dart';

abstract class ChangeStatCommand extends Command {
  final String? ownerId;
  int change;
  final String figureId;
  // Public so subclasses in other files can access it
  final GameState gameState;

  ChangeStatCommand(this.change, this.figureId, this.ownerId,
      {required this.gameState});

  void setChange(int change) {
    this.change = change;
  }

  void handleDeath() {
    for (final item in gameState.currentList) {
      if (item is Monster) {
        _handleMonsterDeath(item);
      } else if (item is Character) {
        _handleCharacterDeath(item);
      }
    }
  }

  void _handleMonsterDeath(Monster monster) {
    final instances = monster.monsterInstances;
    final deadIndex = instances.indexWhere((i) => i.health.value == 0);
    if (deadIndex == -1) return;

    final newList = List<MonsterInstance>.from(instances)..removeAt(deadIndex);
    monster.setMonsterInstances(stateAccess, newList);
    Future.delayed(const Duration(milliseconds: 600), () {
      monster.notifyMonsterInstances(stateAccess);
    });

    if (monster.monsterInstances.isEmpty) {
      monster.setActive(stateAccess, false);
      if (gameState.roundState.value == RoundState.chooseInitiative) {
        RoundMethods.sortCharactersFirst(stateAccess);
      }
      _notifyUpdateList();
    }
  }

  void _handleCharacterDeath(Character character) {
    if (character.characterState.health.value <= 0) {
      gameState.updateList.notify();
    }
    _handleSummonDeath(character);
  }

  void _handleSummonDeath(Character character) {
    for (final instance in character.characterState.summonList) {
      if (instance.health.value == 0 &&
          !GameMethods.summonDoesNotDie(character.id, instance.name)) {
        character.characterState.removeSummon(stateAccess, instance);
        Future.delayed(const Duration(milliseconds: 600), () {
          character.characterState.notifySummonList(stateAccess);
        });
        if (character.characterState.summonList.isEmpty) {
          _notifyUpdateList();
        } else {
          gameState.updateList.notify();
        }
        break;
      }
    }
  }

  void _notifyUpdateList() {
    if (gameState.roundState.value == RoundState.playTurns) {
      Future.delayed(const Duration(milliseconds: 600), () {
        gameState.updateList.notify();
      });
    } else {
      gameState.updateList.notify();
    }
  }

  @override
  String describe() {
    return "change stat";
  }
}
