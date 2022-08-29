
import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';
class DrawModifierCardCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String name;

  DrawModifierCardCommand(this.name);

  @override
  void execute() {
    if(name == "Allies"){
      _gameState.modifierDeckAllies.draw();
    }else {
      _gameState.modifierDeck.draw();
    }
  }

  @override
  void undo() {
  }

  @override
  String toString() {
    if(name == "Allies"){
      return "Draw allies modifier card";
    }
    return "Draw monster modifier card";
  }
}