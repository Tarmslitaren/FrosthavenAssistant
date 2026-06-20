// ignore_for_file: avoid-late-keyword, no-empty-block, no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

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
    testWidgets('openDialogOld opens a dialog without throwing',
        (tester) async {
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
      expect(find.text('tap'), findsOneWidget);
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
      expect(find.text('tap'), findsOneWidget);
    });

    testWidgets('defaultBuildDraggableFeedback builds a widget',
        (tester) async {
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
      expect(find.text('tap'), findsOneWidget);
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
      expect(find.text('tap'), findsOneWidget);
    });

    testWidgets(
        'openDialogWithDismissOption with dismissible=false opens dialog',
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

    // Regression test for Sentry crash:
    //   TypeError: Null check operator used on a null value
    //   #0 Navigator.of (navigator.dart:2937)  ← navigator! on null
    //   #1 showDialog
    //   #2 openDialogWithDismissOption (ui_utils.dart:138)
    //   #3 openDialog (ui_utils.dart:124)
    //   #4 CharacterViewModel.openStatusMenu (character_view_model.dart:39)
    //   #5 CharacterWidgetState.build.<fn> (character_widget.dart:113)
    //
    // Root cause: race condition between pointer-down and pointer-up where
    // the CharacterWidget is deactivated mid-gesture.  During deactivation,
    // Flutter sets element._parent = null before calling element.deactivate()
    // but disposes gesture recognizers only later in unmount().  If the
    // pointer-up fires in that window, handleTap runs with a context whose
    // _parent is null, so findAncestorStateOfType<NavigatorState>() returns
    // null immediately, and navigator! crashes.
    //
    // Fix: guard openDialogWithDismissOption with Navigator.maybeOf so that
    // showDialog is never called when no Navigator is reachable.
    //
    // This test covers the simpler case (active context, no Navigator ancestor)
    // which produces the identical null from Navigator.maybeOf.
    testWidgets(
        'openDialog silently no-ops when context has no Navigator ancestor',
        (tester) async {
      BuildContext? capturedContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // Precondition: this context has no Navigator ancestor.
      expect(Navigator.maybeOf(capturedContext!), isNull);

      // Without the fix, showDialog is called and crashes:
      //   - debug mode: FlutterError from debugCheckHasMaterialLocalizations
      //   - release mode: TypeError from navigator! in Navigator.of
      // With the fix, openDialogWithDismissOption returns early — no crash.
      openDialog(capturedContext!, const Text('test'));
    });
  });
}
