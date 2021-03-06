import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<Settings>(() => Settings());
  getIt.registerLazySingleton<GameState>(() => GameState());

}

void setupGetItPreMade(GameState gameState, Settings settings) {
  getIt.registerLazySingleton<Settings>(() => settings);
  getIt.registerLazySingleton<GameState>(() => gameState);
}