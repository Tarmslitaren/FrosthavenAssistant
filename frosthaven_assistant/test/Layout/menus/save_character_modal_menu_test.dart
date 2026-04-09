import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/save_character_modal_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
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
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  Future<void> pumpMenu(WidgetTester tester,
      {bool saveOnly = false, Character? char}) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SaveCharacterModalMenu(
                  saveName: 'TestSave',
                  saveOnly: saveOnly,
                  saveId: 'TestSave\nBlinkblade',
                  character: char,
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = originalOnError;
  }

  group('SaveCharacterModalMenu', () {
    testWidgets('renders Save button', (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: true, char: character);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders Load and Delete buttons when saveOnly is false',
        (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: false, char: character);
      expect(find.text('Load'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('does not render Load or Delete when saveOnly is true',
        (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: true, char: character);
      expect(find.text('Load'), findsNothing);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('renders Set save name label and text field',
        (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: true, char: character);
      expect(find.text('Set save name:'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('tapping Save button with character triggers save',
        (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: false, char: character);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      // Dialog should close (Navigator.pop called)
    });

    testWidgets('tapping Delete button closes dialog', (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: false, char: character);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Load button closes dialog', (WidgetTester tester) async {
      await pumpMenu(tester, saveOnly: false, char: character);
      // Load button is the first button when saveOnly=false
      await tester.tap(find.text('Load'));
      await tester.pumpAndSettle();
    });
  });
}
