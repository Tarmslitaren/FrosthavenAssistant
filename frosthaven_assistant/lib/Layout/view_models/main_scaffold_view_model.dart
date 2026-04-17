import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../Model/campaign.dart';
import '../../Resource/scaling.dart';

class MainScaffoldViewModel {
  static const double _kLootDeckBarWidth = 94.0;
  static const double _kModDeckBarWidth = 153.0;
  static const double _kSectionButtonWidth = 58.0;
  static const int _kSectionsOverflowThreshold = 2;
  MainScaffoldViewModel(
      {GameState? gameState, Settings? settings, GameData? gameData})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>(),
        _gameData = gameData ?? getIt<GameData>();

  final GameState _gameState;
  final Settings _settings;
  final GameData _gameData;

  // Notifiers the widget subscribes to
  ValueListenable<int> get commandIndex => _gameState.commandIndex;
  ValueListenable<Map<String, CampaignModel>> get modelData =>
      _gameData.modelData;
  ValueListenable<double> get userScalingBars => _settings.userScalingBars;

  // Derived state
  bool get hasLootDeck => GameMethods.hasLootDeck();
  bool get shouldShowAlliesDeck => GameMethods.shouldShowAlliesDeck();
  bool get isButtonsAndBugs =>
      _gameState.currentCampaign.value == "Buttons and Bugs";
  bool get showAmdDeck => _settings.showAmdDeck.value;
  bool get showCharacterAmd => _settings.showCharacterAMD.value;

  /// Number of sections still available for the current scenario,
  /// or null if none should be shown.
  int? get availableSections {
    int? count = _gameData.modelData.value[_gameState.currentCampaign.value]
        ?.scenarios[_gameState.scenario.value]?.sections.length;
    if (count != null && _gameState.scenarioSectionsAdded.length == count) {
      count = null;
    }
    if (!_settings.showSectionsInMainView.value) {
      count = null;
    }
    return count;
  }

  double sectionWidth(BuildContext context) {
    final modFitsOnBar = modifiersFitOnBar(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final barScale = _settings.userScalingBars.value;

    double width = screenWidth;
    if (hasLootDeck) {
      width -= _kLootDeckBarWidth * barScale;
    }

    bool perksAvailable = false;
    if (_settings.showCharacterAMD.value) {
      for (final character in GameMethods.getCurrentCharacters()) {
        if (character.characterClass.perks.isNotEmpty) {
          perksAvailable = true;
          break;
        }
      }
    }

    if (!modFitsOnBar ||
        GameMethods.shouldShowAlliesDeck() ||
        perksAvailable && _settings.showAmdDeck.value) {
      width -= _kModDeckBarWidth * barScale;
    }

    return width;
  }

  /// Whether sections should be placed on a separate row below the main bar
  /// because they don't fit inline.
  bool sectionsOnSeparateRow(BuildContext context) {
    final count = availableSections;
    if (count == null) return false;
    final width = sectionWidth(context);
    final barScale = _settings.userScalingBars.value;
    return (count > 0 && width < _kSectionButtonWidth * barScale) ||
        (count > _kSectionsOverflowThreshold && width < _kSectionButtonWidth * barScale * _kSectionsOverflowThreshold);
  }
}
