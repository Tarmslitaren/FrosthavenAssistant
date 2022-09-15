
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
  ward;

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
  notDone,
  current,
  done
}

enum NetworkMessage {
  init,
  action,
  undo,
  redo
}