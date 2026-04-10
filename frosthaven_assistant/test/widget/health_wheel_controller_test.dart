import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/health_wheel_controller.dart';
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
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()).execute();
  });

  Future<void> pumpController(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HealthWheelController(
            figureId: 'Blinkblade',
            ownerId: 'Blinkblade',
            child: const SizedBox(
              width: 200,
              height: 100,
              child: Text('child'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('HealthWheelController', () {
    testWidgets('renders its child widget', (WidgetTester tester) async {
      await pumpController(tester);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('wraps child in GestureDetector', (WidgetTester tester) async {
      await pumpController(tester);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('horizontal drag gesture can be performed without error',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await pumpController(tester);

      // Start drag — should open overlay
      final center = tester.getCenter(find.text('child'));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();

      // End drag — should close overlay
      await gesture.up();
      await tester.pump();
      FlutterError.onError = originalOnError;

      // Child should still be present after drag ends
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('disposes without error when widget is removed',
        (WidgetTester tester) async {
      await pumpController(tester);
      // Replace widget tree — should trigger dispose
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      // No exception expected
    });
  });
}
