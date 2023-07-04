part of game_state;

class ListItemData {
  late final String id;

  TurnsState get turnState => _turnState;
  TurnsState _turnState = TurnsState.notDone;
  setTurnState(_StateModifier stateModifier, TurnsState value) {_turnState = value;}
}
