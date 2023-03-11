import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/network/connection.dart';
import 'package:get_it/get_it.dart';

import 'network/communication.dart';
import 'network/network.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<Settings>(() => Settings());
  getIt.registerLazySingleton<GameState>(() => GameState());
  getIt.registerLazySingleton<Communication>(() => Communication());
  getIt.registerLazySingleton<Network>(() => Network());
  getIt.registerLazySingleton<Connection>(() => Connection());
}
