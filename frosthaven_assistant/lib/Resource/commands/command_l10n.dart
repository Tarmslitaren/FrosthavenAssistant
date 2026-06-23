import 'dart:ui' show Locale;

import '../../l10n/app_localizations.dart';
import '../../Resource/settings.dart';
import '../../services/service_locator.dart';

Locale _parseLocale(String code) {
  final parts = code.split('_');
  return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
}

AppLocalizations get commandL10n {
  try {
    final code = getIt<Settings>().locale.value;
    return lookupAppLocalizations(_parseLocale(code));
  } catch (_) {
    return lookupAppLocalizations(const Locale('en'));
  }
}
