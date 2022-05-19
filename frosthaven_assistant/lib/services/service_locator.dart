import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<GameState>(() => GameState());
}