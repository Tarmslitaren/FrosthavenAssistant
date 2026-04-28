// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/element_button.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/use_element_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    getIt<Settings>().darkMode.value = false;
    while (getIt<GameState>().elementState[Elements.fire] != ElementState.inert) {
      getIt<GameState>().undo();
    }
  });

  tearDown(() {
    while (getIt<GameState>().elementState[Elements.fire] != ElementState.inert) {
      getIt<GameState>().undo();
    }
  });

  const fireColor = Color.fromARGB(255, 226, 66, 30);

  Future<void> pumpButton(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElementButton(
            icon: 'assets/images/psd/element-fire.png',
            color: fireColor,
            element: Elements.fire,
            gameState: getIt<GameState>(),
            settings: getIt<Settings>(),
          ),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  AnimatedContainer firstAnimatedContainer(WidgetTester tester) =>
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);

  group('ElementButton', () {
    testWidgets('fill container is transparent when element is inert',
        (WidgetTester tester) async {
      await pumpButton(tester);
      final box =
          firstAnimatedContainer(tester).decoration as BoxDecoration;
      expect(box.color, Colors.transparent);
    });

    testWidgets('fill container shows element color when imbued',
        (WidgetTester tester) async {
      getIt<GameState>().action(ImbueElementCommand(Elements.fire, false));
      await pumpButton(tester);
      final box =
          firstAnimatedContainer(tester).decoration as BoxDecoration;
      expect(box.color, fireColor);
      getIt<GameState>().undo();
    });

    testWidgets('fill container updates when element is imbued after render',
        (WidgetTester tester) async {
      await pumpButton(tester);
      final boxBefore =
          firstAnimatedContainer(tester).decoration as BoxDecoration;
      expect(boxBefore.color, Colors.transparent);

      getIt<GameState>().action(ImbueElementCommand(Elements.fire, false));
      await tester.pump();

      final boxAfter =
          firstAnimatedContainer(tester).decoration as BoxDecoration;
      expect(boxAfter.color, fireColor);
      getIt<GameState>().undo();
    });

    testWidgets('fill container reverts to transparent when element is used after render',
        (WidgetTester tester) async {
      getIt<GameState>().action(ImbueElementCommand(Elements.fire, false));
      await pumpButton(tester);
      final boxBefore =
          firstAnimatedContainer(tester).decoration as BoxDecoration;
      expect(boxBefore.color, fireColor);

      getIt<GameState>().action(UseElementCommand(Elements.fire));
      await tester.pump();

      final boxAfter =
          firstAnimatedContainer(tester).decoration as BoxDecoration;
      expect(boxAfter.color, Colors.transparent);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });
  });
}
