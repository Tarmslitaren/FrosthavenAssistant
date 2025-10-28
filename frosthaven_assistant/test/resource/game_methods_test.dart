import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/set_level_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../command/test_helpers.dart';

void main() async {
  await setUpGame();

  group('GameMethods', () {
    group('getTrapValue', () {
      test('should return 2 + game level when level is 4', () {
        // Act: Call the method we are testing.
        SetLevelCommand(4, null).execute();
        final result = GameMethods.getTrapValue();

        // Assert: Check if the result is what we expect.
        expect(result, 6);
      });

      test('should return 2 when game level is 0', () {
        SetLevelCommand(0, null).execute();
        // Act
        final result = GameMethods.getTrapValue();

        // Assert
        expect(result, 2);
      });

      test('should return 9 when game level is 7', () {
        SetLevelCommand(7, null).execute();
        // Act
        final result = GameMethods.getTrapValue();

        // Assert
        expect(result, 9);
      });

      test('should bork when game level is out of bounds', () {
        expect(() => SetLevelCommand(77, null).execute(), throwsAssertionError);
      });

      test('should bork when game level is out of bounds low', () {
        expect(
            () => SetLevelCommand(-77, null).execute(), throwsAssertionError);
      });
    });
  });
}
