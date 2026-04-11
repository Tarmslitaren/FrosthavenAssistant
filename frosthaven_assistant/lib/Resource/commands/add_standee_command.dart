import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../enums.dart';

class AddStandeeCommand extends Command {
  final int nr;
  final SummonData? summon;
  final MonsterType type;
  final String ownerId;
  final bool addAsSummon;
  final GameState _gameState;

  AddStandeeCommand(this.nr, this.summon, this.ownerId, this.type,
      this.addAsSummon, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    MonsterMethods.executeAddStandee(
        stateAccess, nr, summon, type, ownerId, addAsSummon);

    if (_gameState.roundState.value == RoundState.playTurns) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _gameState.updateList.value++;
      });
    } else {
      _gameState.updateList.value++;
    }
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    final sum = summon;
    String name = sum == null ? ownerId : sum.name;

    return "Add $name $nr";
  }
}

class SummonData {
  int standeeNr;
  String name;
  int health;
  int move;
  int attack;
  int range;
  String gfx;

  SummonData(this.standeeNr, this.name, this.health, this.move, this.attack,
      this.range, this.gfx);
}
