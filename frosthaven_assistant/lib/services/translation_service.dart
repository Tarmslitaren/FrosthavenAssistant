import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class TranslationService extends ChangeNotifier {
  Map<String, String> _translations = {};
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;

  // Returns the translated string, or the English key if no translation exists.
  String t(String key) {
    final translation = _translations[key];
    if (translation != null) return translation;

    final activeLocale = getIt.isRegistered<Settings>()
        ? getIt<Settings>().locale.value
        : _currentLocale;

    if (activeLocale == 'de') {
      if (key == 'Remember to choose your Battle Goals.') {
        return 'Denkt daran eure Kampfziele zu wählen.';
      }
    }
    return key;
  }

  Future<void> load(String locale) async {
    _currentLocale = locale;
    if (locale == 'en') {
      _translations = {};
      notifyListeners();
      getIt<GameState>().updateAllUI();
      return;
    }
    try {
      final jsonString =
          await rootBundle.loadString('assets/i18n/$locale.json');
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;
      final Map<String, String> flat = {};
      for (final entry in data.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          for (final inner in value.entries) {
            if (inner.value is String) {
              flat[inner.key] = inner.value as String;
            }
          }
        } else if (value is String) {
          flat[entry.key] = value;
        }
      }
      _translations = flat;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TranslationService: failed to load locale "$locale": $e');
      }
      _translations = {};
    }
    notifyListeners();
    getIt<GameState>().updateAllUI();
  }
}
