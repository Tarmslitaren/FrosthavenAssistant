// ignore_for_file: no-magic-number

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_widget_internal.dart';
import 'package:frosthaven_assistant/Layout/view_models/initiative_widget_view_model.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/network.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
        RoundState.chooseInitiative;
    getIt<Settings>().server.value = false;
    getIt<Settings>().client.value = ClientState.disconnected;
    CharacterWidgetInternal.localCharacterInitChanges.clear();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
            gameState: getIt<GameState>())
        .execute();
    character = getIt<GameState>()
        .currentList
        .firstWhere((e) => e is Character) as Character;
    (character.characterState.health as ValueNotifier<int>).value = 10;
    (character.characterState.initiative as ValueNotifier<int>).value = 0;
  });

  tearDown(() {
    getIt<Settings>().server.value = false;
    getIt<Settings>().client.value = ClientState.disconnected;
    CharacterWidgetInternal.localCharacterInitChanges.clear();
  });

  InitiativeWidgetViewModel makeVm() => InitiativeWidgetViewModel(
        character,
        gameState: getIt<GameState>(),
        settings: getIt<Settings>(),
      );

  group('InitiativeWidgetViewModel.isChooseInitiative', () {
    test('true when roundState is chooseInitiative', () {
      expect(makeVm().isChooseInitiative, isTrue);
    });

    test('false when roundState is playTurns', () {
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      expect(makeVm().isChooseInitiative, isFalse);
    });
  });

  group('InitiativeWidgetViewModel.isAlive', () {
    test('true when health > 0', () {
      expect(makeVm().isAlive, isTrue);
    });

    test('false when health is 0', () {
      (character.characterState.health as ValueNotifier<int>).value = 0;
      expect(makeVm().isAlive, isFalse);
    });
  });

  group('InitiativeWidgetViewModel.fontFamily', () {
    test('returns GermaniaOne when campaign is Frosthaven', () {
      (getIt<GameState>().currentCampaign as ValueNotifier<String>).value =
          'Frosthaven';
      expect(makeVm().fontFamily, 'GermaniaOne');
    });

    test('returns Pirata when campaign is Gloomhaven (original style)', () {
      (getIt<GameState>().currentCampaign as ValueNotifier<String>).value =
          'Gloomhaven';
      expect(makeVm().fontFamily, 'Pirata');
    });
  });

  group('InitiativeWidgetViewModel.softNumpadInput', () {
    test('false by default', () {
      expect(makeVm().softNumpadInput, isFalse);
    });

    test('true when settings enabled', () {
      getIt<Settings>().softNumpadInput.value = true;
      expect(makeVm().softNumpadInput, isTrue);
      getIt<Settings>().softNumpadInput.value = false;
    });
  });

  group('InitiativeWidgetViewModel.keyboardInputType', () {
    test('number keyboard when softNumpadInput is false', () {
      getIt<Settings>().softNumpadInput.value = false;
      expect(makeVm().keyboardInputType, TextInputType.number);
    });

    test('none keyboard when softNumpadInput is true', () {
      getIt<Settings>().softNumpadInput.value = true;
      expect(makeVm().keyboardInputType, TextInputType.none);
      getIt<Settings>().softNumpadInput.value = false;
    });
  });

  group('InitiativeWidgetViewModel.isSecret', () {
    test('false when not server and not connected client', () {
      expect(makeVm().isSecret, isFalse);
    });

    test('false when server mode and character id is in localChanges', () {
      getIt<Settings>().server.value = true;
      CharacterWidgetInternal.localCharacterInitChanges.add(character.id);
      expect(makeVm().isSecret, isFalse);
      getIt<Settings>().server.value = false;
    });

    test('true when server and character id NOT in localChanges', () {
      getIt<Settings>().server.value = true;
      CharacterWidgetInternal.localCharacterInitChanges.clear();
      expect(makeVm().isSecret, isTrue);
      getIt<Settings>().server.value = false;
    });

    test('true when connected client and character id NOT in localChanges', () {
      getIt<Settings>().client.value = ClientState.connected;
      CharacterWidgetInternal.localCharacterInitChanges.clear();
      expect(makeVm().isSecret, isTrue);
      getIt<Settings>().client.value = ClientState.disconnected;
    });
  });

  group('InitiativeWidgetViewModel.initiativeDisplayText', () {
    test('returns initiative string when alive and initiative > 0', () {
      (character.characterState.health as ValueNotifier<int>).value = 10;
      expect(makeVm().initiativeDisplayText(42), '42');
    });

    test('returns empty string when health is 0', () {
      (character.characterState.health as ValueNotifier<int>).value = 0;
      expect(makeVm().initiativeDisplayText(42), '');
    });

    test('returns empty string when initiative is 0', () {
      (character.characterState.health as ValueNotifier<int>).value = 10;
      expect(makeVm().initiativeDisplayText(0), '');
    });

    test('returns empty string when both health and initiative are 0', () {
      (character.characterState.health as ValueNotifier<int>).value = 0;
      expect(makeVm().initiativeDisplayText(0), '');
    });
  });

  group('InitiativeWidgetViewModel notifier', () {
    test('initiative listenable is exposed', () {
      expect(makeVm().initiative, isNotNull);
    });
  });
}
