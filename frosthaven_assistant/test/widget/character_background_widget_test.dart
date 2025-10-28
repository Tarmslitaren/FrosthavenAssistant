import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_background_widget.dart';
import 'package:frosthaven_assistant/Model/character_class.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:mockito/mockito.dart';

// Mocks
class MockCharacter extends Mock implements Character {
  @override
  final CharacterClass characterClass;

  MockCharacter(this.characterClass);
}

class MockCharacterClass extends Mock implements CharacterClass {
  @override
  final String name;
  @override
  final Color color;
  @override
  final Color colorSecondary;

  MockCharacterClass(this.name, this.color, this.colorSecondary);
}

void main() {
  group('CharacterBackgroundWidget', () {
    testWidgets('shows correct background for Shattersong',
        (WidgetTester tester) async {
      final mockCharacterClass =
          MockCharacterClass('Shattersong', Colors.blue, Colors.green);
      final mockCharacter = MockCharacter(mockCharacterClass);

      await tester.pumpWidget(
        MaterialApp(
          home: CharacterBackgroundWidget(
            character: mockCharacter,
            scale: 1.0,
            shadow: const Shadow(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).last);
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isA<SweepGradient>());
    });

    testWidgets('shows correct background for Rimehearth',
        (WidgetTester tester) async {
      final mockCharacterClass =
          MockCharacterClass('Rimehearth', Colors.blue, Colors.green);
      final mockCharacter = MockCharacter(mockCharacterClass);

      await tester.pumpWidget(
        MaterialApp(
          home: CharacterBackgroundWidget(
            character: mockCharacter,
            scale: 1.0,
            shadow: const Shadow(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).last);
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isA<SweepGradient>());
    });

    testWidgets('shows correct background for Elementalist',
        (WidgetTester tester) async {
      final mockCharacterClass =
          MockCharacterClass('Elementalist', Colors.blue, Colors.green);
      final mockCharacter = MockCharacter(mockCharacterClass);

      await tester.pumpWidget(
        MaterialApp(
          home: CharacterBackgroundWidget(
            character: mockCharacter,
            scale: 1.0,
            shadow: const Shadow(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).last);
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isA<SweepGradient>());
    });

    testWidgets('shows correct background for other characters',
        (WidgetTester tester) async {
      final mockCharacterClass =
          MockCharacterClass('Blinkblade', Colors.red, Colors.yellow);
      final mockCharacter = MockCharacter(mockCharacterClass);

      await tester.pumpWidget(
        MaterialApp(
          home: CharacterBackgroundWidget(
            character: mockCharacter,
            scale: 1.0,
            shadow: const Shadow(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).last);
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isNull);
    });
  });
}
