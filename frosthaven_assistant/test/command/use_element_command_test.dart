import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/use_element_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('UseElementCommand', () {
    test('should set element state to inert', () {
      ImbueElementCommand(Elements.fire, false).execute();
      expect(getIt<GameState>().elementState[Elements.fire],
          ElementState.full);

      UseElementCommand(Elements.fire).execute();

      expect(getIt<GameState>().elementState[Elements.fire],
          ElementState.inert);
      checkSaveState();
    });

    test('should work on any element', () {
      ImbueElementCommand(Elements.ice, false).execute();
      UseElementCommand(Elements.ice).execute();
      expect(getIt<GameState>().elementState[Elements.ice],
          ElementState.inert);
    });

    test('describe should include element name', () {
      final command = UseElementCommand(Elements.earth);
      expect(command.describe(), 'Use Element earth');
    });
  });
}
