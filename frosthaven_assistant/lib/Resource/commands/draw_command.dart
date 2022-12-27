
import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../game_state.dart';

class DrawCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  DrawCommand();

  @override
  void execute() {
    GameMethods.drawAbilityCards();
    GameMethods.sortByInitiative();
    GameMethods.setRoundState(RoundState.playTurns);
    if (_gameState.currentList.isNotEmpty) {
      _gameState.currentList[0].turnState = TurnsState.current;
    }

    _gameState.toastMessage.value = "";
    for(var rule in _gameState.scenarioSpecialRules) {
      if(rule.type == "Timer" && rule.startOfRound == true) {
        for(int round in rule.list) {
          //minus 1 means always
          if(round == _gameState.round.value || round == -1) {
            _gameState.toastMessage.value = rule.note;
          }
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      _gameState.updateList.value++;
      MainList.scrollToTop();
    });
  }

  @override
  void undo() {
    /*GameMethods.unDrawAbilityCards();
    _gameState.round.value--;
    GameMethods.setRoundState(RoundState.chooseInitiative);*/
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Draw";
  }
}