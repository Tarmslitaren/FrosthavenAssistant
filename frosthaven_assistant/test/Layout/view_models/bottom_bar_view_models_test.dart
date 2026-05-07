// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/bottom_bar_level_widget_view_model.dart';
import 'package:frosthaven_assistant/Layout/view_models/bottom_bar_view_model.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../unit_helpers.dart';

void main() {
  late GameState gameState;
  late Settings settings;

  setUpAll(initTestBinding);

  setUp(() {
    (gameState, settings) = makeGameAndSettings();
  });

  // ── BottomBarViewModel ─────────────────────────────────────────────────────

  group('BottomBarViewModel.isDarkMode', () {
    test('false by default', () {
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.isDarkMode, isFalse);
    });

    test('true when darkMode setting is enabled', () {
      settings.darkMode.value = true;
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.isDarkMode, isTrue);
    });
  });

  group('BottomBarViewModel.backgroundColor', () {
    test('transparent in light mode', () {
      settings.darkMode.value = false;
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.backgroundColor, Colors.transparent);
    });

    test('black in dark mode', () {
      settings.darkMode.value = true;
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.backgroundColor, Colors.black);
    });
  });

  group('BottomBarViewModel.backgroundOpacity', () {
    test('1.0 in light mode', () {
      settings.darkMode.value = false;
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.backgroundOpacity, 1.0);
    });

    test('0.4 in dark mode', () {
      settings.darkMode.value = true;
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.backgroundOpacity, closeTo(0.4, 0.001));
    });
  });

  group('BottomBarViewModel.backgroundImagePath', () {
    test('frosthaven image in light mode', () {
      settings.darkMode.value = false;
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.backgroundImagePath, contains('frosthaven-bar'));
    });

    test('gloomhaven image in dark mode', () {
      settings.darkMode.value = true;
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.backgroundImagePath, contains('gloomhaven-bar'));
    });
  });

  group('BottomBarViewModel notifiers', () {
    test('userScalingBars listenable is exposed', () {
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.userScalingBars, isNotNull);
    });

    test('darkMode listenable is exposed', () {
      final vm = BottomBarViewModel(settings: settings, gameState: gameState);
      expect(vm.darkMode, isNotNull);
    });
  });

  // ── BottomBarLevelWidgetViewModel ──────────────────────────────────────────

  group('BottomBarLevelWidgetViewModel.formattedScenarioName', () {
    test('returns full name for non-solo campaign', () {
      (gameState.currentCampaign as ValueNotifier<String>).value = 'Frosthaven';
      (gameState.scenario as ValueNotifier<String>).value = '#1 Algox Encampment';
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      expect(vm.formattedScenarioName, '#1 Algox Encampment');
    });

    test('strips prefix before colon for Solo campaign with colon', () {
      (gameState.currentCampaign as ValueNotifier<String>).value = 'Solo';
      (gameState.scenario as ValueNotifier<String>).value =
          'Blinkblade:Solo Scenario';
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      expect(vm.formattedScenarioName, 'Solo Scenario');
    });

    test('returns full name for Solo campaign without colon', () {
      (gameState.currentCampaign as ValueNotifier<String>).value = 'Solo';
      (gameState.scenario as ValueNotifier<String>).value = 'NoColonScenario';
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      expect(vm.formattedScenarioName, 'NoColonScenario');
    });

    test('empty scenario name returns empty string', () {
      (gameState.scenario as ValueNotifier<String>).value = '';
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      expect(vm.formattedScenarioName, '');
    });
  });

  group('BottomBarLevelWidgetViewModel.fontHeight', () {
    test('scales with userScalingBars', () {
      settings.userScalingBars.value = 2.0;
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      expect(vm.fontHeight, closeTo(28.0, 0.001)); // 14 * 2.0
    });

    test('14.0 at default scale of 1.0', () {
      settings.userScalingBars.value = 1.0;
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      expect(vm.fontHeight, closeTo(14.0, 0.001));
    });
  });

  group('BottomBarLevelWidgetViewModel.textStyle', () {
    test('uses white text in dark mode', () {
      settings.darkMode.value = true;
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      final style = vm.textStyle(1.0);
      expect(style.color, Colors.white);
    });

    test('uses black text in light mode', () {
      settings.darkMode.value = false;
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      final style = vm.textStyle(1.0);
      expect(style.color, Colors.black);
    });

    test('dark mode has exactly one shadow', () {
      settings.darkMode.value = true;
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      final style = vm.textStyle(1.0);
      expect(style.shadows?.length, 1);
    });

    test('light mode has two white glow shadows', () {
      settings.darkMode.value = false;
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      final style = vm.textStyle(1.0);
      expect(style.shadows?.length, 2);
    });

    test('scales font size with provided scaling', () {
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      final style = vm.textStyle(2.0);
      expect(style.fontSize, closeTo(28.0, 0.001));
    });
  });

  group('BottomBarLevelWidgetViewModel.level', () {
    test('exposes current game level via notifier', () {
      (gameState.level as ValueNotifier<int>).value = 4;
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      expect(vm.level.value, 4);
    });
  });

  group('BottomBarLevelWidgetViewModel notifiers', () {
    test('scenario listenable is exposed', () {
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      expect(vm.scenario, isNotNull);
    });

    test('level listenable is exposed', () {
      final vm = BottomBarLevelWidgetViewModel(
        gameState: gameState,
        settings: settings,
      );
      expect(vm.level, isNotNull);
    });
  });
}
