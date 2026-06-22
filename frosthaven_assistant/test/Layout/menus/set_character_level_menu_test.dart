// ignore_for_file: no-magic-number, avoid-late-keyword

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_character_level_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
    character =
        getIt<GameState>().currentList.firstWhere((e) => e is Character)
            as Character;
  });

  Future<void> pumpMenu(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    SetCharacterLevelMenu(character: character),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    // Use pump instead of pumpAndSettle: the TextField cursor blinks
    // indefinitely and pumpAndSettle would never return.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = originalOnError;
  }

  group('SetCharacterLevelMenu', () {
    testWidgets('renders the character name in the title', (
      WidgetTester tester,
    ) async {
      await pumpMenu(tester);
      expect(
        find.textContaining(character.characterState.display.value),
        findsOneWidget,
      );
    });

    testWidgets('renders level buttons 1 through 9', (
      WidgetTester tester,
    ) async {
      await pumpMenu(tester);
      for (int i = 1; i <= 9; i++) {
        // Use findsAtLeast(1): some numbers may also appear in the health
        // counter (e.g. Blinkblade starts with 8 max health).
        expect(
          find.text(i.toString()),
          findsAtLeast(1),
          reason: 'Level button $i should be visible',
        );
      }
    });

    testWidgets('renders "Change name:" label and text field', (
      WidgetTester tester,
    ) async {
      await pumpMenu(tester);
      expect(find.text('Change name:'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('tapping a level button updates the character level', (
      WidgetTester tester,
    ) async {
      await pumpMenu(tester);
      final targetLevel = character.characterState.level.value == 1 ? 2 : 1;

      await tester.tap(find.text(targetLevel.toString()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(character.characterState.level.value, targetLevel);
    });

    testWidgets(
      'level button selection updates reactively when level changes via command',
      (WidgetTester tester) async {
        await pumpMenu(tester);
        expect(character.characterState.level.value, 1);

        // Change level externally (not through the button tap)
        getIt<GameState>().action(SetCharacterLevelCommand(5, character.id));
        await tester.pump();

        // State updated
        expect(character.characterState.level.value, 5);
        // Buttons 1..9 still all rendered — widget rebuilt without crash
        for (int i = 1; i <= 9; i++) {
          expect(
            find.text(i.toString()),
            findsAtLeast(1),
            reason:
                'Level button $i should still be visible after reactive update',
          );
        }
        // Level 5 button is now selected, so tapping level 1 should work (isCurrentlySelected=false)
        await tester.tap(find.text('1').first);
        await tester.pump();
        expect(character.characterState.level.value, 1);
      },
    );

    testWidgets('entering a name in the text field triggers name change', (
      WidgetTester tester,
    ) async {
      await pumpMenu(tester);

      // The TextField is off-screen due to overflow so pointer events cannot
      // reach it. Set the controller text and invoke onSubmitted directly.
      final menuState = tester.state<SetCharacterLevelMenuState>(
        find.byType(SetCharacterLevelMenu),
      );
      menuState.nameController.text = 'HeroName';
      final tf = tester.widget<TextField>(find.byType(TextField));
      tf.onSubmitted?.call('HeroName');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(character.characterState.display.value, 'HeroName');
    });
  });
}
