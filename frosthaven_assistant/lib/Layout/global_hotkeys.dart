import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
import 'package:frosthaven_assistant/Resource/commands/use_element_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_actions.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../services/service_locator.dart';

class GlobalHotkeys extends StatelessWidget {
  const GlobalHotkeys({required this.child, super.key});

  final Widget child;

  void _runIfNoTextInputFocus(VoidCallback action) {
    if (_isTextInputFocused()) return;
    action();
  }

  bool _isTextInputFocused() {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null) {
      return false;
    }

    return focusedContext.widget is EditableText ||
        focusedContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  void _invokeDrawOrNextRound(BuildContext context) {
    final gameState = getIt<GameState>();

    final result = runDrawOrNextRoundAction(gameState);
    final blockedMessage = result.blockedMessage;

    if (blockedMessage != null) {
      showToast(context, blockedMessage);
    }
  }

  void _toggleElement(Elements element) {
    final gameState = getIt<GameState>();
    final elementState = gameState.elementState[element];

    if (elementState == ElementState.half ||
        elementState == ElementState.full) {
      gameState.action(UseElementCommand(element));
      return;
    }

    gameState.action(ImbueElementCommand(element, false));
  }

  void _advanceActivation() {
    final gameState = getIt<GameState>();
    if (gameState.roundState.value != RoundState.playTurns) {
      return;
    }

    for (final item in gameState.currentList) {
      if (item.turnState.value == TurnsState.current) {
        gameState.action(TurnDoneCommand(item.id));
        return;
      }
    }
  }

  void _undoActivation() {
    final gameState = getIt<GameState>();
    final currentCommandIndex = gameState.commandIndex.value;

    if (currentCommandIndex < 0 ||
        currentCommandIndex >= gameState.commands.length) {
      return;
    }

    if (gameState.commands[currentCommandIndex] is TurnDoneCommand) {
      gameState.undo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () =>
            _runIfNoTextInputFocus(() => getIt<GameState>().undo()),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () =>
            _runIfNoTextInputFocus(() => getIt<GameState>().undo()),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () =>
            _runIfNoTextInputFocus(() => getIt<GameState>().redo()),
        const SingleActivator(LogicalKeyboardKey.keyY, meta: true): () =>
            _runIfNoTextInputFocus(() => getIt<GameState>().redo()),
        const SingleActivator(LogicalKeyboardKey.tab): () =>
            _runIfNoTextInputFocus(_advanceActivation),
        const SingleActivator(LogicalKeyboardKey.tab, shift: true): () =>
            _runIfNoTextInputFocus(_undoActivation),
        const SingleActivator(LogicalKeyboardKey.space): () =>
            _runIfNoTextInputFocus(() => _invokeDrawOrNextRound(context)),
        const SingleActivator(LogicalKeyboardKey.digit1): () =>
            _runIfNoTextInputFocus(() => _toggleElement(Elements.fire)),
        const SingleActivator(LogicalKeyboardKey.digit2): () =>
            _runIfNoTextInputFocus(() => _toggleElement(Elements.ice)),
        const SingleActivator(LogicalKeyboardKey.digit3): () =>
            _runIfNoTextInputFocus(() => _toggleElement(Elements.air)),
        const SingleActivator(LogicalKeyboardKey.digit4): () =>
            _runIfNoTextInputFocus(() => _toggleElement(Elements.earth)),
        const SingleActivator(LogicalKeyboardKey.digit5): () =>
            _runIfNoTextInputFocus(() => _toggleElement(Elements.light)),
        const SingleActivator(LogicalKeyboardKey.digit6): () =>
            _runIfNoTextInputFocus(() => _toggleElement(Elements.dark)),
      },
      child: child,
    );
  }
}
