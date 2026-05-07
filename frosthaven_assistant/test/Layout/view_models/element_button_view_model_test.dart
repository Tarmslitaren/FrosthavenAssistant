// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/element_button_view_model.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
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

  ElementButtonViewModel makeVm(Elements element) => ElementButtonViewModel(
        element,
        gameState: gameState,
        settings: settings,
      );

  group('ElementButtonViewModel.elementState', () {
    test('fire starts as inert after game init', () {
      expect(makeVm(Elements.fire).elementState, ElementState.inert);
    });

    test('elementState reflects imbue', () {
      final vm = makeVm(Elements.fire);
      vm.imbue();
      expect(vm.elementState, ElementState.full);
    });

    test('elementState is half after imbue with half=true', () {
      final vm = makeVm(Elements.ice);
      vm.imbue(half: true);
      expect(vm.elementState, ElementState.half);
    });

    test('elementState returns non-null for all elements', () {
      for (final element in Elements.values) {
        expect(makeVm(element).elementState, isNotNull);
      }
    });
  });

  group('ElementButtonViewModel.iconColor', () {
    test('returns Colors.black in light mode when element is inert', () {
      settings.darkMode.value = false;
      expect(makeVm(Elements.fire).iconColor, Colors.black);
    });

    test('returns null in light mode when element is full', () {
      settings.darkMode.value = false;
      final vm = makeVm(Elements.earth);
      vm.imbue();
      expect(vm.iconColor, isNull);
    });

    test('returns null in dark mode regardless of element state', () {
      settings.darkMode.value = true;
      expect(makeVm(Elements.fire).iconColor, isNull);
    });

    test('returns null in dark mode even when element is inert', () {
      settings.darkMode.value = true;
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
    });

    test('uses element when full', () {
      final vm = makeVm(Elements.dark);
      vm.imbue();
      expect(vm.elementState, ElementState.full);
      vm.tap();
      expect(vm.elementState, ElementState.inert);
    });

    test('uses element when half', () {
      final vm = makeVm(Elements.fire);
      vm.imbue(half: true);
      expect(vm.elementState, ElementState.half);
      vm.tap();
      expect(vm.elementState, ElementState.inert);
    });
  });

  group('ElementButtonViewModel notifiers', () {
    test('elementStateNotifier listenable is exposed', () {
      expect(makeVm(Elements.fire).elementStateNotifier, isNotNull);
    });

    test('darkMode listenable is exposed', () {
      expect(makeVm(Elements.fire).darkMode, isNotNull);
    });

    test('userScalingBars returns a double', () {
      expect(makeVm(Elements.fire).userScalingBars, isA<double>());
    });
  });
}
