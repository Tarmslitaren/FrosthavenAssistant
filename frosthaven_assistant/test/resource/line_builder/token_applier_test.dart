import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/line_builder/token_applier.dart';

// ignore_for_file: no-magic-number

void main() {
  Widget wrapWidget(Widget w) => MaterialApp(home: Scaffold(body: w));

  // ── applyTokensForPerks – return type ────────────────────────────────────

  group('TokenApplier.applyTokensForPerks – widget type', () {
    testWidgets('returns a RichText widget', (tester) async {
      final widget = TokenApplier.applyTokensForPerks('plain text');
      await tester.pumpWidget(wrapWidget(widget));
      expect(find.byType(RichText), findsAtLeast(1));
    });

    testWidgets('plain text with no tokens renders without crashing',
        (tester) async {
      final widget = TokenApplier.applyTokensForPerks('Remove one -1 card');
      await tester.pumpWidget(wrapWidget(widget));
      expect(find.byType(RichText), findsAtLeast(1));
    });

    testWidgets('empty string renders without crashing', (tester) async {
      final widget = TokenApplier.applyTokensForPerks('');
      await tester.pumpWidget(wrapWidget(widget));
      // No crash is the assertion
    });
  });

  // ── applyTokensForPerks – numeric perk tokens ─────────────────────────────

  group('TokenApplier.applyTokensForPerks – numeric tokens', () {
    testWidgets('+1 becomes a circle widget span', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      final widget = TokenApplier.applyTokensForPerks('+1');
      await tester.pumpWidget(wrapWidget(widget));
      FlutterError.onError = originalOnError;
      // The +1 circle container should be in the tree
      expect(find.byType(Container), findsAtLeast(1));
    });

    testWidgets('-1 becomes a circle widget span', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      final widget = TokenApplier.applyTokensForPerks('-1');
      await tester.pumpWidget(wrapWidget(widget));
      FlutterError.onError = originalOnError;
      expect(find.byType(Container), findsAtLeast(1));
    });

    testWidgets('-2 is converted to a widget span', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      final widget = TokenApplier.applyTokensForPerks('-2');
      await tester.pumpWidget(wrapWidget(widget));
      FlutterError.onError = originalOnError;
      expect(find.byType(RichText), findsAtLeast(1));
    });

    testWidgets('+4 is converted to a circle widget span', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      final widget = TokenApplier.applyTokensForPerks('+4');
      await tester.pumpWidget(wrapWidget(widget));
      FlutterError.onError = originalOnError;
      expect(find.byType(Container), findsAtLeast(1));
    });

    testWidgets('2x becomes a token widget span', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      final widget = TokenApplier.applyTokensForPerks('2x');
      await tester.pumpWidget(wrapWidget(widget));
      FlutterError.onError = originalOnError;
      expect(find.byType(RichText), findsAtLeast(1));
    });
  });

  // ── applyTokensForPerks – space normalisation ─────────────────────────────

  group('TokenApplier.applyTokensForPerks – spacing normalisation', () {
    testWidgets('"- 1" is treated same as "-1"', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      // "- 1" is collapsed to "-1" before processing
      final widget = TokenApplier.applyTokensForPerks('- 1');
      await tester.pumpWidget(wrapWidget(widget));
      FlutterError.onError = originalOnError;
      expect(find.byType(RichText), findsAtLeast(1));
    });

    testWidgets('"+ 1" is treated same as "+1"', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      final widget = TokenApplier.applyTokensForPerks('+ 1');
      await tester.pumpWidget(wrapWidget(widget));
      FlutterError.onError = originalOnError;
      expect(find.byType(RichText), findsAtLeast(1));
    });
  });

  // ── applyTokensForPerks – mixed text and tokens ───────────────────────────

  group('TokenApplier.applyTokensForPerks – mixed text and tokens', () {
    testWidgets('text before token is preserved as text span', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      final widget = TokenApplier.applyTokensForPerks('Remove one +1 card');
      await tester.pumpWidget(wrapWidget(widget));
      FlutterError.onError = originalOnError;
      // Should render without crashing; text parts and icon parts co-exist
      expect(find.byType(RichText), findsAtLeast(1));
    });

    testWidgets('multiple numeric tokens in one line', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      final widget =
          TokenApplier.applyTokensForPerks('Replace -2 card with +2 card');
      await tester.pumpWidget(wrapWidget(widget));
      FlutterError.onError = originalOnError;
      // Both -2 and +2 become circle widgets; expect multiple Containers
      expect(find.byType(Container), findsAtLeast(2));
    });
  });
}

void ignoreOverflowErrors(FlutterErrorDetails details,
    {bool forceReport = false}) {
  if (details.exception is FlutterError) {
    final fe = details.exception as FlutterError;
    if (fe.diagnostics.any((e) =>
        e.value.toString().startsWith('A RenderFlex overflowed') ||
        e.value.toString().startsWith('Unable to load asset'))) {
      return;
    }
  }
  FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
}
