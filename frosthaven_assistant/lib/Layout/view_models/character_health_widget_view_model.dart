import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class CharacterHealthWidgetViewModel {
  CharacterHealthWidgetViewModel({Settings? settings})
      : _settings = settings ?? getIt<Settings>();

  final Settings _settings;

  ValueListenable<bool> get enableHealthWheel => _settings.enableHeathWheel;
  bool get frosthavenStyle => GameMethods.isFrosthavenStyle(null);
}
