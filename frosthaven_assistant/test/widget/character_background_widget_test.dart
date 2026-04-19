// ignore_for_file: prefer-match-file-name

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_background_widget.dart';
import 'package:frosthaven_assistant/Model/character_class.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:mockito/mockito.dart';

// Mocks
class _MockCharacter extends Mock implements Character {
  @override
  final CharacterClass characterClass;

  _MockCharacter(this.characterClass);
}

class _MockCharacterClass extends Mock implements CharacterClass {
  @override
  final String name;
  @override
  final Color color;
  @override
  final Color colorSecondary;

  _MockCharacterClass(this.name, this.color, this.colorSecondary);
}

void main() {
  group('CharacterBackgroundWidget', () {
    testWidgets('shows correct background for Shattersong',
        (WidgetTester tester) async {
      final mockCharacterClass =
          _MockCharacterClass('Shattersong', Colors.blue, Colors.green);
      final mockCharacter = _MockCharacter(mockCharacterClass);

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
          _MockCharacterClass('Rimehearth', Colors.blue, Colors.green);
      final mockCharacter = _MockCharacter(mockCharacterClass);

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
          _MockCharacterClass('Elementalist', Colors.blue, Colors.green);
      final mockCharacter = _MockCharacter(mockCharacterClass);

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
          _MockCharacterClass('Blinkblade', Colors.red, Colors.yellow);
      final mockCharacter = _MockCharacter(mockCharacterClass);

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
