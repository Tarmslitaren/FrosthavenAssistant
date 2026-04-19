part of 'game_state.dart';

// ignore_for_file: library_private_types_in_public_api
class ListItemData {
  String id = '';
  final _turnState = ValueNotifier<TurnsState>(TurnsState.notDone);
  ValueListenable<TurnsState> get turnState => _turnState;

  void setTurnState(_StateModifier _, TurnsState value) {
    _turnState.value = value;
  }
}
