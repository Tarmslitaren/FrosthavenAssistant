import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/background.dart';
import 'package:frosthaven_assistant/Layout/modifier_deck_widget.dart';
import 'package:frosthaven_assistant/Layout/section_list.dart';
import 'package:frosthaven_assistant/Layout/top_bar.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Model/campaign.dart';
import '../Resource/game_data.dart';
import '../Resource/game_methods.dart';
import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'bottom_bar.dart';
import 'character_amds_widget.dart';
import 'loot_deck_widget.dart';
import 'main_list.dart';
import 'menus/main_menu.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, this.settings});

  // injected for testing
  final Settings? settings;

  /// Detects if the current device is an iPad.
  /// iPad has a shortestSide >= 600 and runs iOS.
  static bool _isIPad(BuildContext context) {
    // Check if it's iOS first
    if (!Platform.isIOS) return false;

    // Check if it's a tablet-sized device (iPad)
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final settings = this.settings ?? getIt<Settings>();
    setupMoreGetIt(context);

    return ValueListenableBuilder<double>(
        valueListenable: settings.userScalingBars,
        builder: (context, value, child) {
          return SafeArea(
              left: false,
              right: false,
              maintainBottomViewPadding: true,
              child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  bottomNavigationBar: RepaintBoundary(child: BottomBar()),
                  appBar: PreferredSize(
                      preferredSize: Size(double.infinity,
                          40 * settings.userScalingBars.value),
                      child: const RepaintBoundary(child: TopBar())),
                  drawer: MainMenu(),
                  body: const RepaintBoundary(child: MainScaffoldBody())));
        });
  }
}

class ToastNotifier extends StatelessWidget {
  const ToastNotifier({super.key, this.gameState});

  // injected for testing
  final GameState? gameState;

  @override
  Widget build(BuildContext context) {
    final gameState = this.gameState ?? getIt<GameState>();
    return ValueListenableBuilder<String>(
        valueListenable: gameState.toastMessage,
        builder: (context, value, child) {
          Future.delayed(const Duration(milliseconds: 200), () {
            String message = gameState.toastMessage.value;
            if (message != "") {
              if (context.mounted) {
                showToastSticky(context, message);
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
              }
            }
          });

          return const SizedBox(
            width: 0,
            height: 0,
          );
        });
  }
}

class MainScaffoldBody extends StatelessWidget {
  const MainScaffoldBody({super.key, this.gameState, this.settings, this.gameData});

  // injected for testing
  final GameState? gameState;
  final Settings? settings;
  final GameData? gameData;

  double getSectionWidth(BuildContext context, Settings settings) {
    bool modFitsOnBar = modifiersFitOnBar(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double barScale = settings.userScalingBars.value;

    bool hasLootDeck = GameMethods.hasLootDeck();
    double sectionWidth = screenWidth;
    if (hasLootDeck) {
      sectionWidth -= 94 * barScale; //width of loot deck
    }

    final chars = GameMethods.getCurrentCharacters();
    bool perksAvailable = false;
    if (settings.showCharacterAMD.value) {
      for (final character in chars) {
        if (character.characterClass.perks.isNotEmpty) {
          perksAvailable = true;
          break;
        }
      }
    }

    if (!modFitsOnBar ||
        GameMethods.shouldShowAlliesDeck() ||
        perksAvailable && settings.showAmdDeck.value) {
      sectionWidth -= 153 * barScale; //width of amd
    }

    return sectionWidth;
  }

  int? getNrOfSections(
      {required GameData gameData,
      required GameState gameState,
      required Settings settings}) {
    int? nrOfSections = gameData
        .modelData
        .value[gameState.currentCampaign.value]
        ?.scenarios[gameState.scenario.value]
        ?.sections
        .length;
    if (nrOfSections != null &&
        gameState.scenarioSectionsAdded.length == nrOfSections) {
      nrOfSections = null;
    }
    if (!settings.showSectionsInMainView.value) {
      nrOfSections = null;
    }

    return nrOfSections;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = this.gameState ?? getIt<GameState>();
    final settings = this.settings ?? getIt<Settings>();
    final gameData = this.gameData ?? getIt<GameData>();
    Size screenSize = MediaQuery.of(context).size;

    return ValueListenableBuilder<bool>(
        valueListenable: loading,
        builder: (context, isLoading, child) {
          return Stack(
            children: [
              if (!isLoading) const MainList(),
              if (isLoading)
                BackGround(
                    child: const Center(
                  child: CircularProgressIndicator(),
                )),
              const ToastNotifier(),
              ValueListenableBuilder<Map<String, CampaignModel>>(
                  valueListenable: gameData.modelData,
                  builder: (context, value, child) {
                    return ValueListenableBuilder<int>(
                        valueListenable: gameState.commandIndex,
                        builder: (context, value, child) {
                          return ValueListenableBuilder<double>(
                              valueListenable: settings.userScalingBars,
                              builder: (context, value, child) {
                                double barScale =
                                    settings.userScalingBars.value;
                                bool hasLootDeck = GameMethods.hasLootDeck();
                                bool modFitsOnBar = modifiersFitOnBar(context);

                                var sectionWidth = getSectionWidth(context, settings);

                                //move to separate row if it doesn't fit
                                bool sectionsOnSeparateRow = false;
                                int? nrOfSections = getNrOfSections(
                                    gameData: gameData,
                                    gameState: gameState,
                                    settings: settings);
                                if ((nrOfSections != null &&
                                        nrOfSections > 0 &&
                                        sectionWidth < 58 * barScale) ||
                                    (nrOfSections != null &&
                                        nrOfSections > 2 &&
                                        sectionWidth < 58 * barScale * 2)) {
                                  //in case doesn't fit
                                  sectionsOnSeparateRow = true;
                                  sectionWidth =
                                      MediaQuery.of(context).size.width;
                                }

                                return Positioned(
                                    width: screenSize.width,
                                    bottom: barScale * 4,
                                    left: barScale * 5,
                                    child: Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              ((!sectionsOnSeparateRow &&
                                                          nrOfSections !=
                                                              null) ||
                                                      hasLootDeck)
                                                  ? MainAxisAlignment
                                                      .spaceBetween
                                                  : MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            if (hasLootDeck)
                                              const LootDeckWidget(),
                                            if (!sectionsOnSeparateRow &&
                                                nrOfSections != null)
                                              SizedBox(
                                                width: sectionWidth,
                                                child: const SectionList(),
                                              ),
                                            Column(children: [
                                              RepaintBoundary(
                                                  child: CharacterAmdsWidget()),
                                              if (GameMethods
                                                  .shouldShowAlliesDeck())
                                                Container(
                                                    margin: EdgeInsets.only(
                                                      top: 4 * barScale,
                                                    ),
                                                    child:
                                                        const ModifierDeckWidget(
                                                      name: 'allies',
                                                    )),
                                              if (!modFitsOnBar &&
                                                  gameState.currentCampaign
                                                          .value !=
                                                      "Buttons and Bugs" && //hide amd deck for buttons and bugs
                                                  settings.showAmdDeck.value)
                                                Container(
                                                    margin: EdgeInsets.only(
                                                      top: 4 * barScale,
                                                    ),
                                                    child:
                                                        const ModifierDeckWidget(
                                                      name: '',
                                                    ))
                                            ])
                                          ]),
                                      if (sectionsOnSeparateRow &&
                                          nrOfSections != null)
                                        SizedBox(
                                          width: sectionWidth,
                                          child: const RepaintBoundary(
                                              child: SectionList()),
                                        ),
                                    ]));
                              });
                        });
                  })
            ],
          );
        });
  }
}
