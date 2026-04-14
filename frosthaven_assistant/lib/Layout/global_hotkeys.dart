import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import 'view_models/global_hotkeys_view_model.dart';

class GlobalHotkeys extends StatelessWidget {
  const GlobalHotkeys({required this.child, super.key, this.gameState});

  final Widget child;
  final GameState? gameState;

  bool _isTextInputFocused() {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null) return false;
    return focusedContext.widget is EditableText ||
        focusedContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  void _runIfNoTextInputFocus(VoidCallback action) {
    if (_isTextInputFocused()) return;
    action();
  }

  @override
  Widget build(BuildContext context) {
    final vm = GlobalHotkeysViewModel(gameState: gameState);
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () =>
            _runIfNoTextInputFocus(vm.undo),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () =>
            _runIfNoTextInputFocus(vm.undo),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () =>
            _runIfNoTextInputFocus(vm.redo),
        const SingleActivator(LogicalKeyboardKey.keyY, meta: true): () =>
            _runIfNoTextInputFocus(vm.redo),
        const SingleActivator(LogicalKeyboardKey.tab): () =>
            _runIfNoTextInputFocus(vm.advanceActivation),
        const SingleActivator(LogicalKeyboardKey.tab, shift: true): () =>
            _runIfNoTextInputFocus(vm.undoActivation),
        const SingleActivator(LogicalKeyboardKey.space): () =>
            _runIfNoTextInputFocus(() {
              final msg = vm.invokeDrawOrNextRound();
              if (msg != null) showToast(context, msg);
            }),
        const SingleActivator(LogicalKeyboardKey.digit1): () =>
            _runIfNoTextInputFocus(() => vm.toggleElement(Elements.fire)),
        const SingleActivator(LogicalKeyboardKey.digit2): () =>
            _runIfNoTextInputFocus(() => vm.toggleElement(Elements.ice)),
        const SingleActivator(LogicalKeyboardKey.digit3): () =>
            _runIfNoTextInputFocus(() => vm.toggleElement(Elements.air)),
        const SingleActivator(LogicalKeyboardKey.digit4): () =>
            _runIfNoTextInputFocus(() => vm.toggleElement(Elements.earth)),
        const SingleActivator(LogicalKeyboardKey.digit5): () =>
            _runIfNoTextInputFocus(() => vm.toggleElement(Elements.light)),
        const SingleActivator(LogicalKeyboardKey.digit6): () =>
            _runIfNoTextInputFocus(() => vm.toggleElement(Elements.dark)),
      },
      child: child,
    );
  }
}
