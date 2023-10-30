part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api
class ListItemData {
  late final String id;

  TurnsState get turnState => _turnState;
  TurnsState _turnState = TurnsState.notDone;
  setTurnState(_StateModifier stateModifier, TurnsState value) {_turnState = value;}
}
