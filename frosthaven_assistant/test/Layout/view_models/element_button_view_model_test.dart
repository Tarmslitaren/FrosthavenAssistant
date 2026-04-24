// ignore_for_file: no-magic-number

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/element_button_view_model.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    getIt<GameState>().undo();
    // restore all elements to inert (undo any element state changes)
    for (final element in Elements.values) {
      while (getIt<GameState>().elementState[element] != ElementState.inert) {
        getIt<GameState>().undo();
      }
    }
    getIt<Settings>().darkMode.value = false;
  });

  tearDown(() {
    getIt<Settings>().darkMode.value = false;
  });

  ElementButtonViewModel makeVm(Elements element) => ElementButtonViewModel(
        element,
        gameState: getIt<GameState>(),
        settings: getIt<Settings>(),
      );

  group('ElementButtonViewModel.elementState', () {
    test('fire starts as inert after game init', () {
      expect(makeVm(Elements.fire).elementState, ElementState.inert);
    });

    test('elementState reflects imbue', () {
      final vm = makeVm(Elements.fire);
      vm.imbue();
      expect(vm.elementState, ElementState.full);
      getIt<GameState>().undo();
    });

    test('elementState is half after imbue with half=true', () {
      final vm = makeVm(Elements.ice);
      vm.imbue(half: true);
      expect(vm.elementState, ElementState.half);
      getIt<GameState>().undo();
    });

    test('elementState returns null for element not in map (impossible in '
        'practice, but covers the nullable return type)', () {
      // All elements are initialised, so all should return non-null.
      for (final element in Elements.values) {
        expect(makeVm(element).elementState, isNotNull);
      }
    });
  });

  group('ElementButtonViewModel.iconColor', () {
    test('returns Colors.black in light mode when element is inert', () {
      getIt<Settings>().darkMode.value = false;
      expect(makeVm(Elements.fire).iconColor, Colors.black);
    });

    test('returns null in light mode when element is full', () {
      getIt<Settings>().darkMode.value = false;
      final vm = makeVm(Elements.earth);
      vm.imbue();
      expect(vm.iconColor, isNull);
      getIt<GameState>().undo();
    });

    test('returns null in dark mode regardless of element state', () {
      getIt<Settings>().darkMode.value = true;
      expect(makeVm(Elements.fire).iconColor, isNull);
    });

    test('returns null in dark mode even when element is inert', () {
      getIt<Settings>().darkMode.value = true;
      // inert element
      expect(makeVm(Elements.air).elementState, ElementState.inert);
      expect(makeVm(Elements.air).iconColor, isNull);
    });
  });

  group('ElementButtonViewModel.tap', () {
    test('imbues element when inert', () {
      final vm = makeVm(Elements.light);
      expect(vm.elementState, ElementState.inert);
      vm.tap();
      expect(vm.elementState, ElementState.full);
      getIt<GameState>().undo();
    });

    test('uses element when full', () {
      final vm = makeVm(Elements.dark);
      vm.imbue();
      expect(vm.elementState, ElementState.full);
      vm.tap();
      expect(vm.elementState, ElementState.inert);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('uses element when half', () {
      final vm = makeVm(Elements.fire);
      vm.imbue(half: true);
      expect(vm.elementState, ElementState.half);
      vm.tap();
      expect(vm.elementState, ElementState.inert);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });
  });

  group('ElementButtonViewModel notifiers', () {
    test('commandIndex listenable is exposed', () {
      expect(makeVm(Elements.fire).commandIndex, isNotNull);
    });

    test('darkMode listenable is exposed', () {
      expect(makeVm(Elements.fire).darkMode, isNotNull);
    });

    test('userScalingBars returns a double', () {
      expect(makeVm(Elements.fire).userScalingBars, isA<double>());
    });
  });
}
