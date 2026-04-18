import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_round_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class DrawOrNextRoundResult { // ignore: prefer-match-file-name, file contains multiple game action types
  const DrawOrNextRoundResult._({this.blockedMessage});

  final String? blockedMessage;

  bool get isBlocked => blockedMessage != null;

  static const success = DrawOrNextRoundResult._();

  static DrawOrNextRoundResult blocked(String message) {
    return DrawOrNextRoundResult._(blockedMessage: message);
  }
}

DrawOrNextRoundResult runDrawOrNextRoundAction(GameState gameState,
    {GameData? gameData, Settings? settings}) {
  if (gameState.roundState.value == RoundState.chooseInitiative) {
    if (GameMethods.canDraw()) {
      gameState.action(DrawCommand(gameState: gameState));
      return DrawOrNextRoundResult.success;
    }

    if (gameState.currentList.isEmpty) {
      return DrawOrNextRoundResult.blocked(
        'Add characters first from the side menu (tap the hamburger icon to open)',
      );
    }

    return DrawOrNextRoundResult.blocked(
      'Player initiative numbers must be set (tap the character icon or under the initiative marker to the right of it)',
    );
  }

  gameState.action(NextRoundCommand(
      gameState: gameState,
      gameData: gameData ?? getIt<GameData>(),
      settings: settings ?? getIt<Settings>()));
  return DrawOrNextRoundResult.success;
}
