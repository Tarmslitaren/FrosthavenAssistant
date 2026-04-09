import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('ImbueElementCommand', () {
    test('should set element to full when half is false', () {
      final command = ImbueElementCommand(Elements.fire, false);
      command.execute();
      expect(getIt<GameState>().elementState[Elements.fire],
          ElementState.full);
      checkSaveState();
    });

    test('should set element to half when half is true', () {
      final command = ImbueElementCommand(Elements.light, true);
      command.execute();
      expect(getIt<GameState>().elementState[Elements.light],
          ElementState.half);
      checkSaveState();
    });

    test('should work on all element types', () {
      for (final element in Elements.values) {
        ImbueElementCommand(element, false).execute();
        expect(getIt<GameState>().elementState[element], ElementState.full);
      }
    });

    test('describe should include element name', () {
      final command = ImbueElementCommand(Elements.dark, false);
      expect(command.describe(), 'Imbue element dark');
    });
  });
}
