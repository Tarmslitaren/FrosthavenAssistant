
import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';
class DrawModifierCardCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  DrawModifierCardCommand();

  @override
  void execute() {
    _gameState.modifierDeck.draw();
  }

  @override
  void undo() {
  }

  @override
  String toString() {
    return "Draw modifier card";
  }
}