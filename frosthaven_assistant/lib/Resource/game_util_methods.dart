part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class GameUtilMethods {
  //note: while this changes the game state, it is a state used also by non game related instances.
  static void setToastMessage(String message, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._toastMessage.value = message;
  }
}
