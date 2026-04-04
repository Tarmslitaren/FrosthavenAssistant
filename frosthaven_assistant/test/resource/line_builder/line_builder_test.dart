import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/line_builder/line_builder.dart';

void main() {
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
}
