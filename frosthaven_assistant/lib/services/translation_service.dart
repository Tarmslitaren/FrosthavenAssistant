import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TranslationService extends ChangeNotifier {
  Map<String, String> _translations = {};

  // Returns the translated string, or the English key if no translation exists.
  String t(String key) => _translations[key] ?? key;

  Future<void> load(String locale) async {
    if (locale == 'en') {
      _translations = {};
      notifyListeners();
      return;
    }
    try {
      final jsonString =
          await rootBundle.loadString('assets/i18n/$locale.json');
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;
      _translations = data.cast<String, String>();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TranslationService: failed to load locale "$locale": $e');
      }
      _translations = {};
    }
    notifyListeners();
  }
}
