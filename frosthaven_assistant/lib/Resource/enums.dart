
enum Condition{
  stun,
  immobilize,
  disarm,
  wound,
  wound2,
  muddle,
  poison,
  poison2,
  poison3,
  poison4,
  bane,
  brittle,
  chill,
  infect,
  impair,
  rupture,
  strengthen,
  invisible,
  regenerate,
  ward,
  dodge;

  @override
  String toString() {
    return index.toString();
  }

}

enum ElementState{
  full,
  half,
  inert

}

enum Elements{
  fire,
  ice,
  air,
  earth,
  light,
  dark
}

enum RoundState{
  chooseInitiative,
  playTurns,
}

enum ListItemState {
  chooseInitiative, //gray
  waitingTurn, //hopeful
  myTurn, //conditions reminder (above in list is gray)
  doneTurn, //gray, expire conditions
}

enum MonsterType {
  normal,
  elite,
  boss,
  //named?
  summon
}

enum TurnsState {
  notDone, //if got condition while in this state or from earlier round: remove at end of current
  current, //mark conditions added here to not be removed yet
  done //mark conditions added here to not be removed yet
}

enum NetworkMessage {
  init,
  action,
  undo,
  redo
}