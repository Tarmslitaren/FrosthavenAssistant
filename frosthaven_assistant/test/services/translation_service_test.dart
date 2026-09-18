import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:frosthaven_assistant/services/translation_service.dart';

import '../command/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setUpGame();
  });

  tearDownAll(() {
    getIt.reset();
  });

  group('TranslationService Battle Goals', () {
    test('returns English key by default when locale is en', () async {
      final service = getIt<TranslationService>();
      await service.load('en');

      expect(
        service.t('Remember to choose your Battle Goals.'),
        'Remember to choose your Battle Goals.',
      );
    });

    test('returns German translation when locale is de', () async {
      final service = getIt<TranslationService>();
      await service.load('de');

      expect(
        service.t('Remember to choose your Battle Goals.'),
        'Denkt daran eure Kampfziele zu wählen.',
      );
    });

    test('SetScenarioCommand sets translated battle goal reminder toast in German and English',
        () async {
      final settings = getIt<Settings>();
      settings.showBattleGoalReminder.value = true;
      settings.showReminders.value = true;

      // Load German translations
      await getIt<TranslationService>().load('de');

      SetScenarioCommand('#0 Howling in the Snow', false,
              gameState: getIt<GameState>())
          .execute();

      expect(
        getIt<GameState>().toastMessage.value,
        contains('Denkt daran eure Kampfziele zu wählen.'),
      );

      // Switch back to English
      await getIt<TranslationService>().load('en');

      SetScenarioCommand('#0 Howling in the Snow', false,
              gameState: getIt<GameState>())
          .execute();

      expect(
        getIt<GameState>().toastMessage.value,
        contains('Remember to choose your Battle Goals.'),
      );
    });
  });
}
