import 'dart:ui' show Locale;

import '../../l10n/app_localizations.dart';
import '../../Resource/settings.dart';
import '../../services/service_locator.dart';

AppLocalizations get commandL10n {
  final code = getIt<Settings>().locale.value;
  try {
    return lookupAppLocalizations(Locale(code));
  } catch (_) {
    return lookupAppLocalizations(const Locale('en'));
  }
}
