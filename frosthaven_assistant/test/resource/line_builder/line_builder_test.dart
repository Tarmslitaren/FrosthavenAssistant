import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/line_builder/line_builder.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });
  // ── isElement ─────────────────────────────────────────────────────────────

  group('LineBuilder.isElement', () {
    test('"fire" is an element', () {
      expect(LineBuilder.isElement('fire'), isTrue);
    });

    test('"air" is an element', () {
      expect(LineBuilder.isElement('air'), isTrue);
    });

    test('"earth" is an element', () {
      expect(LineBuilder.isElement('earth'), isTrue);
    });

    test('"ice" is an element', () {
      expect(LineBuilder.isElement('ice'), isTrue);
    });

    test('"dark" is an element', () {
      expect(LineBuilder.isElement('dark'), isTrue);
    });

    test('"light" is an element', () {
      expect(LineBuilder.isElement('light'), isTrue);
    });

    test('"any" is an element', () {
      expect(LineBuilder.isElement('any'), isTrue);
    });

    test('string containing element name returns true', () {
      // e.g. "fire_fh" contains "fire"
      expect(LineBuilder.isElement('fire_fh'), isTrue);
      expect(LineBuilder.isElement('dark_half'), isTrue);
    });

    test('"attack" is not an element', () {
      expect(LineBuilder.isElement('attack'), isFalse);
    });

    test('"move" is not an element', () {
      expect(LineBuilder.isElement('move'), isFalse);
    });

    test('"poison" is not an element', () {
      expect(LineBuilder.isElement('poison'), isFalse);
    });

    test('empty string is not an element', () {
      expect(LineBuilder.isElement(''), isFalse);
    });

    test('"heal" is not an element', () {
      expect(LineBuilder.isElement('heal'), isFalse);
    });
  });

  // ── getTopPaddingForStyle ─────────────────────────────────────────────────

  group('LineBuilder.getTopPaddingForStyle', () {
    test('non-Markazi font with height=0.85 returns fontSize * 0.25', () {
      const style = TextStyle(
          fontFamily: 'Majalla', fontSize: 12.0, height: 0.85);
      expect(LineBuilder.getTopPaddingForStyle(style), closeTo(3.0, 0.001));
    });

    test('Markazi font with height=0.84 returns fontSize * 0.1', () {
      const style = TextStyle(
          fontFamily: 'Markazi', fontSize: 10.0, height: 0.84);
      expect(LineBuilder.getTopPaddingForStyle(style), closeTo(1.0, 0.001));
    });

    test('non-Markazi font with height=0.84 returns 0', () {
      const style = TextStyle(
          fontFamily: 'Majalla', fontSize: 12.0, height: 0.84);
      expect(LineBuilder.getTopPaddingForStyle(style), 0.0);
    });

    test('Markazi font with height=0.85 returns 0', () {
      // Markazi check uses 0.84 specifically; 0.85 does not match
      const style = TextStyle(
          fontFamily: 'Markazi', fontSize: 10.0, height: 0.85);
      expect(LineBuilder.getTopPaddingForStyle(style), 0.0);
    });

    test('non-Markazi font with height=1.0 returns 0', () {
      const style = TextStyle(
          fontFamily: 'Majalla', fontSize: 14.0, height: 1.0);
      expect(LineBuilder.getTopPaddingForStyle(style), 0.0);
    });

    test('padding scales with fontSize', () {
      const small = TextStyle(
          fontFamily: 'Majalla', fontSize: 8.0, height: 0.85);
      const large = TextStyle(
          fontFamily: 'Majalla', fontSize: 16.0, height: 0.85);
      expect(LineBuilder.getTopPaddingForStyle(large),
          greaterThan(LineBuilder.getTopPaddingForStyle(small)));
    });
  });

  // ── createLines ───────────────────────────────────────────────────────────

  group('LineBuilder.createLines', () {
    Future<void> pump(WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: widget)),
      );
    }

    testWidgets('plain text renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['Hello world'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('column tokens [c] and [/c] render without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['[c]', 'Column text', '[/c]', 'After column'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
      expect(find.text('Column text'), findsOneWidget);
    });

    testWidgets('[/c] as last element renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['[c]', 'Inner', '[/c]'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('row tokens [r] and [/r] render without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['[r]', 'Row text', '[/r]'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
      expect(find.text('Row text'), findsOneWidget);
    });

    testWidgets('[/r] as last element renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['[r]', 'text', '[/r]'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('inner row tokens [s] and [/s] render without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['[c]', '[s]', 'inner', '[/s]', '[/c]'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('[subLineEnd] token renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['First line', '[subLineEnd]', 'After'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('image token starting with ¤ renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['¤fire'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('right-join token starting with ! renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['First', '!Joined'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('small-style token starting with * renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['*small text'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('mid-style token starting with ^ renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['^mid text'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('double ^^ mid-squished style renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['^^squished'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('grant token starting with > renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['>granted line'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('icon token %attack% renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['%attack% 3'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('£ elite-style switch renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['Normal£Elite'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('left=true with icon token renders black icon',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['%attack% 2'],
        true,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('alignment start renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['Text'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.start,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('alignment end renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['Text'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.end,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('¤fire image inside column renders without error',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['[c]', '¤fire', '[/c]'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });

    testWidgets('¤fire image as last element returns column',
        (WidgetTester tester) async {
      final widget = LineBuilder.createLines(
        ['¤fire'],
        false,
        false,
        false,
        null,
        CrossAxisAlignment.center,
        1.0,
        false,
      );
      await pump(tester, widget);
    });
  });
}
