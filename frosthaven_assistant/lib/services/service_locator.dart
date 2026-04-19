import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:frosthaven_assistant/services/network/connection.dart';
import 'package:get_it/get_it.dart';

import '../Resource/game_data.dart';
import 'network/communication.dart';
import 'network/network.dart';

final getIt = GetIt.instance;

// Loading state notifier for app initialization
final loading = ValueNotifier<bool>(true);

void setupGetIt() {
  getIt.registerLazySingleton<GameData>(() => GameData());
  getIt.registerLazySingleton<Settings>(() => Settings());
  getIt.registerLazySingleton<GameState>(() => GameState(
        communication: getIt<Communication>(),
      ));
  getIt.registerLazySingleton<Communication>(() => Communication());
  getIt.registerLazySingleton<Network>(() => Network());
  getIt.registerLazySingleton<Connection>(() => Connection());
  getIt.registerLazySingleton<Client>(() => Client());
}
