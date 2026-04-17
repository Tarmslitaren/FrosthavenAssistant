// ignore_for_file: avoid-non-null-assertion

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/background.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  Future<void> pumpBackground(WidgetTester tester, Widget child) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: BackGround(child: child),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('BackGround', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await pumpBackground(tester, const Text('hello'));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('renders Container with decoration',
        (WidgetTester tester) async {
      await pumpBackground(tester, const SizedBox());
      expect(find.byType(Container), findsAtLeast(1));
    });

    testWidgets('uses dark bg image in dark mode', (WidgetTester tester) async {
      getIt<Settings>().darkMode.value = true;
      await pumpBackground(tester, const SizedBox());
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).image != null,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      final image = decoration.image!.image as ResizeImage;
      expect((image.imageProvider as AssetImage).assetName, contains('bg.png'));
    });

    testWidgets('uses frosthaven bg image in light mode',
        (WidgetTester tester) async {
      getIt<Settings>().darkMode.value = false;
      await pumpBackground(tester, const SizedBox());
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).image != null,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      final image = decoration.image!.image as ResizeImage;
      expect((image.imageProvider as AssetImage).assetName,
          contains('frosthaven-bg.png'));
    });

    testWidgets('dark mode sets black background color',
        (WidgetTester tester) async {
      getIt<Settings>().darkMode.value = true;
      await pumpBackground(tester, const SizedBox());
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).image != null,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.black);
    });

    testWidgets('light mode sets grey background color',
        (WidgetTester tester) async {
      getIt<Settings>().darkMode.value = false;
      await pumpBackground(tester, const SizedBox());
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).image != null,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.grey);
    });
  });
}
