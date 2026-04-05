import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  // ── hasGHVersion ─────────────────────────────────────────────────────────

  group('hasGHVersion', () {
    test('"attack" is in the GH version set', () {
      expect(hasGHVersion('attack'), isTrue);
    });

    test('"move" is in the GH version set', () {
      expect(hasGHVersion('move'), isTrue);
    });

    test('"poison" is in the GH version set', () {
      expect(hasGHVersion('poison'), isTrue);
    });

    test('"shield" is in the GH version set', () {
      expect(hasGHVersion('shield'), isTrue);
    });

    test('"heal" is in the GH version set', () {
      expect(hasGHVersion('heal'), isTrue);
    });

    test('"wound" is in the GH version set', () {
      expect(hasGHVersion('wound'), isTrue);
    });

    test('"stun" is in the GH version set', () {
      expect(hasGHVersion('stun'), isTrue);
    });

    test('"pierce" is in the GH version set', () {
      expect(hasGHVersion('pierce'), isTrue);
    });

    test('"push" is in the GH version set', () {
      expect(hasGHVersion('push'), isTrue);
    });

    test('"pull" is in the GH version set', () {
      expect(hasGHVersion('pull'), isTrue);
    });

    test('"fire" is NOT in the GH version set', () {
      expect(hasGHVersion('fire'), isFalse);
    });

    test('empty string is NOT in the GH version set', () {
      expect(hasGHVersion(''), isFalse);
    });

    test('"brittle" is NOT in the GH version set', () {
      expect(hasGHVersion('brittle'), isFalse);
    });
  });

  // ── getTitleTextStyle / getSmallTextStyle / getButtonTextStyle ────────────

  group('text style helpers', () {
    test('getTitleTextStyle returns TextStyle with correct fontSize', () {
      final style = getTitleTextStyle(1.0);
      expect(style.fontSize, 18.0);
    });

    test('getTitleTextStyle scales with scale factor', () {
      final style = getTitleTextStyle(2.0);
      expect(style.fontSize, 36.0);
    });

    test('getSmallTextStyle returns TextStyle with correct fontSize', () {
      final style = getSmallTextStyle(1.0);
      expect(style.fontSize, 14.0);
    });

    test('getButtonTextStyle returns blue TextStyle', () {
      final style = getButtonTextStyle(1.0);
      expect(style.color, Colors.blue);
    });
  });

  // ── openDialogOld / openDialog / createToastContent ──────────────────────

  group('dialog and toast widget functions', () {
    testWidgets('openDialogOld opens a dialog without throwing', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => openDialogOld(context, const Text('old dialog')),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pumpAndSettle();
      expect(find.text('old dialog'), findsOneWidget);
    });

    testWidgets('createToastContent returns a GestureDetector', (tester) async {
      late Widget toast;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            toast = createToastContent(context, 'some toast text');
            return const SizedBox();
          },
        ),
      ));
      expect(toast, isA<GestureDetector>());
    });

    testWidgets('showToast does not throw when context is mounted',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showToast(context, 'test toast'),
              child: const Text('tap'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      // No crash is the assertion
    });

    testWidgets('rebuildAllChildren does not throw', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => rebuildAllChildren(context),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
    });

    testWidgets('defaultBuildDraggableFeedback builds a widget', (tester) async {
      late Widget feedback;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            feedback = defaultBuildDraggableFeedback(
              context,
              const BoxConstraints(),
              const Text('child'),
            );
            return const SizedBox();
          },
        ),
      ));
      expect(feedback, isNotNull);
    });

    testWidgets('showToastSticky does not throw when context is mounted',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showToastSticky(context, 'sticky toast'),
              child: const Text('tap'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
    });

    testWidgets('showErrorToastStickyWithRetry does not throw', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showErrorToastStickyWithRetry(context, 'error msg', () {}),
              child: const Text('tap'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
    });

    testWidgets('openDialogWithDismissOption with dismissible=false opens dialog',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => openDialogWithDismissOption(
                context, const Text('non-dismissible'), false),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pumpAndSettle();
      expect(find.text('non-dismissible'), findsOneWidget);
    });
  });
}
