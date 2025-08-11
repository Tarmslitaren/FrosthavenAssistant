part of 'game_state.dart';

// ignore_for_file: library_private_types_in_public_api
class ListItemData {
  late final String id;

  ValueListenable<TurnsState> get turnState => _turnState;
  final _turnState = ValueNotifier<TurnsState>(TurnsState.notDone);
  setTurnState(_StateModifier _, TurnsState value) {
    _turnState.value = value;
  }
}
