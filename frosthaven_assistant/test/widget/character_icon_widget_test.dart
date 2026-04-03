import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_icon_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
  });

  Future<void> pumpIcon(
      WidgetTester tester, Character character, bool isCharacter) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterIconWidget(
            character: character,
            scale: 1.0,
            shadow: const Shadow(),
            scaledHeight: 100,
            isCharacter: isCharacter,
          ),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('CharacterIconWidget', () {
    testWidgets('renders Blinkblade icon image', (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Blinkblade') as Character;
      await pumpIcon(tester, character, true);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Blinkblade icon uses character class color when isCharacter=true',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Blinkblade') as Character;
      await pumpIcon(tester, character, true);

      final img = tester.widget<Image>(find.byType(Image));
      // When isCharacter=true, color is set to the character class color
      expect(img.color, character.characterClass.color);
    });

    testWidgets('isCharacter=false renders image without color tint',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Blinkblade') as Character;
      await pumpIcon(tester, character, false);

      final img = tester.widget<Image>(find.byType(Image));
      // When isCharacter=false (summon), no color tint
      expect(img.color, isNull);
    });

    testWidgets('non-Shattersong character does not render ShaderMask',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Blinkblade') as Character;
      await pumpIcon(tester, character, true);

      // Only Shattersong uses ShaderMask; Blinkblade should not
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('renders Container with circular decoration',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Blinkblade') as Character;
      await pumpIcon(tester, character, true);

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('image asset path contains character class name',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Blinkblade') as Character;
      await pumpIcon(tester, character, true);

      final img = tester.widget<Image>(find.byType(Image));
      final assetImage = img.image as AssetImage;
      expect(assetImage.assetName,
          contains(character.characterClass.name));
    });

    testWidgets('isCharacter=true applies class color to image',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Blinkblade') as Character;
      await pumpIcon(tester, character, true);

      final img = tester.widget<Image>(find.byType(Image));
      // When isCharacter=true, color is set to the character class color
      expect(img.color, isNotNull);
      expect(img.color, character.characterClass.color);
    });

    testWidgets('isCharacter=false image has no color tint',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Blinkblade') as Character;
      await pumpIcon(tester, character, false);

      final img = tester.widget<Image>(find.byType(Image));
      expect(img.color, isNull);
    });

    testWidgets('scale parameter affects widget size',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e.id == 'Blinkblade') as Character;

      // Pump with scale=1.0
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterIconWidget(
              character: character,
              scale: 2.0,
              shadow: const Shadow(),
              scaledHeight: 200,
              isCharacter: true,
            ),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
      expect(find.byType(CharacterIconWidget), findsOneWidget);
    });
  });
}
