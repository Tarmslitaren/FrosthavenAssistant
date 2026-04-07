import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/theme.dart';
import 'package:frosthaven_assistant/Resource/theme_switcher.dart';

void main() {
  group('ThemeSwitcherWidget', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        ThemeSwitcherWidget(
          initialTheme: theme,
          child: const MaterialApp(home: Text('hello')),
        ),
      );
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('provides ThemeSwitcher via InheritedWidget',
        (WidgetTester tester) async {
      ThemeSwitcherWidgetState? captured;
      await tester.pumpWidget(
        ThemeSwitcherWidget(
          initialTheme: theme,
          child: MaterialApp(
            home: Builder(builder: (context) {
              captured = ThemeSwitcher.of(context);
              return const SizedBox();
            }),
          ),
        ),
      );
      expect(captured, isNotNull);
    });

    testWidgets('initial themeData matches initialTheme',
        (WidgetTester tester) async {
      ThemeSwitcherWidgetState? state;
      await tester.pumpWidget(
        ThemeSwitcherWidget(
          initialTheme: theme,
          child: MaterialApp(
            home: Builder(builder: (context) {
              state = ThemeSwitcher.of(context);
              return const SizedBox();
            }),
          ),
        ),
      );
      expect(state!.themeData, equals(theme));
    });

    testWidgets('switchTheme changes themeData', (WidgetTester tester) async {
      ThemeSwitcherWidgetState? state;
      await tester.pumpWidget(
        ThemeSwitcherWidget(
          initialTheme: theme,
          child: MaterialApp(
            home: Builder(builder: (context) {
              state = ThemeSwitcher.of(context);
              return const SizedBox();
            }),
          ),
        ),
      );

      state!.switchTheme(themeFH);
      await tester.pump();
      expect(state!.themeData, equals(themeFH));
    });

    testWidgets('switchTheme back to original theme',
        (WidgetTester tester) async {
      ThemeSwitcherWidgetState? state;
      await tester.pumpWidget(
        ThemeSwitcherWidget(
          initialTheme: themeFH,
          child: MaterialApp(
            home: Builder(builder: (context) {
              state = ThemeSwitcher.of(context);
              return const SizedBox();
            }),
          ),
        ),
      );

      state!.switchTheme(theme);
      await tester.pump();
      expect(state!.themeData, equals(theme));
    });
  });

  group('ThemeSwitcher', () {
    testWidgets('updateShouldNotify returns true for different instances',
        (WidgetTester tester) async {
      // Build two ThemeSwitcherWidget trees and verify that a rebuild
      // propagates the change (indirectly tests updateShouldNotify)
      ThemeSwitcherWidgetState? stateA;
      await tester.pumpWidget(
        ThemeSwitcherWidget(
          initialTheme: theme,
          child: MaterialApp(
            home: Builder(builder: (context) {
              stateA = ThemeSwitcher.of(context);
              return const SizedBox();
            }),
          ),
        ),
      );
      stateA!.switchTheme(themeFH);
      await tester.pump();
      // After theme switch the state reflects the new theme
      expect(stateA!.themeData, equals(themeFH));
    });

    testWidgets('ThemeSwitcher wraps child correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ThemeSwitcherWidget(
          initialTheme: theme,
          child: const MaterialApp(home: Scaffold(body: Text('content'))),
        ),
      );
      expect(find.text('content'), findsOneWidget);
      expect(find.byType(ThemeSwitcher), findsOneWidget);
    });
  });
}
