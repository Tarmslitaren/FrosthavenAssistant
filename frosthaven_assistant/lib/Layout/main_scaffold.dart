import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_deck_widget.dart';
import 'package:frosthaven_assistant/Layout/section_list.dart';
import 'package:frosthaven_assistant/Layout/top_bar.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/main.dart';

import '../Model/campaign.dart';
import '../Resource/game_data.dart';
import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'bottom_bar.dart';
import 'loot_deck_widget.dart';
import 'main_list.dart';
import 'menus/main_menu.dart';

Widget createMainScaffold(BuildContext context) {
  setupMoreGetIt(context);

  return ValueListenableBuilder<bool>(
      valueListenable: loading,
      builder: (context, value, child) {
        if (kDebugMode) {
          print("loading is: $loading");
        }
        return ValueListenableBuilder<double>(
            valueListenable: getIt<Settings>().userScalingBars,
            builder: (context, value, child) {
              bool modFitsOnBar = modifiersFitOnBar(context);

              double screenWidth = MediaQuery.of(context).size.width;
              return SafeArea(
                  left: false,
                  right: false,
                  maintainBottomViewPadding: true,
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    bottomNavigationBar: createBottomBar(context),
                    appBar: createTopBar(),
                    drawer: createMainMenu(context),
                    body: Stack(
                      children: [
                        const MainList(),
                        ValueListenableBuilder<String>(
                            valueListenable: getIt<GameState>().toastMessage,
                            builder: (context, value, child) {
                              Future.delayed(const Duration(milliseconds: 200), () {
                                if (getIt<GameState>().toastMessage.value != "") {
                                  showToastSticky(context, getIt<GameState>().toastMessage.value);
                                  //getIt<GameState>().toastMessage.value = "";
                                } else {
                                  //ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                }
                              });

                              return const SizedBox(
                                width: 0.0000,
                                height: 0.0000,
                              );
                            }),
                        ValueListenableBuilder<Map<String, CampaignModel>>(
                            valueListenable: getIt<GameData>().modelData,
                            builder: (context, value, child) {
                              return ValueListenableBuilder<int>(
                                  valueListenable: getIt<GameState>().commandIndex,
                                  builder: (context, value, child) {
                                    GameState gameState = getIt<GameState>();
                                    final GameData gameData = getIt<GameData>();
                                    double barScale = getIt<Settings>().userScalingBars.value;

                                    bool hasLootDeck = !getIt<Settings>().hideLootDeck.value;
                                    if (gameState.lootDeck.discardPile.isEmpty &&
                                        gameState.lootDeck.drawPile.isEmpty) {
                                      hasLootDeck = false;
                                    }
                                    double sectionWidth = screenWidth;
                                    if (hasLootDeck) {
                                      sectionWidth -= 94 * barScale; //width of loot deck
                                    }
                                    if ((!modFitsOnBar || GameMethods.shouldShowAlliesDeck()) &&
                                        getIt<Settings>().showAmdDeck.value) {
                                      sectionWidth -= 153 * barScale; //width of amd
                                    }

                                    //move to separate row if it doesn't fit
                                    bool sectionsOnSeparateRow = false;
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
                                    if (getIt<Settings>().showSectionsInMainView.value == false) {
                                      nrOfSections = null;
                                    }
                                    if ((nrOfSections != null &&
                                            nrOfSections > 0 &&
                                            sectionWidth < 58 * barScale) ||
                                        (nrOfSections != null &&
                                            nrOfSections > 2 &&
                                            sectionWidth < 58 * barScale * 2)) {
                                      //in case doesn't fit
                                      sectionsOnSeparateRow = true;
                                      sectionWidth = MediaQuery.of(context).size.width;
                                    }

                                    return Positioned(
                                        width: screenWidth,
                                        bottom: 4 * barScale,
                                        left: 20,
                                        child: Column(children: [
                                          Row(
                                              mainAxisAlignment: ((!sectionsOnSeparateRow &&
                                                          nrOfSections != null) ||
                                                      hasLootDeck)
                                                  ? MainAxisAlignment.spaceBetween
                                                  : MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                if (hasLootDeck) const LootDeckWidget(),
                                                if (!sectionsOnSeparateRow && nrOfSections != null)
                                                  SizedBox(
                                                    width: sectionWidth,
                                                    child: const SectionList(),
                                                  ),
                                                Column(children: [
                                                  if (GameMethods.shouldShowAlliesDeck())
                                                    const ModifierDeckWidget(name: "allies"),
                                                  if (!modFitsOnBar &&
                                                      gameState.currentCampaign.value != "Buttons and Bugs" && //hide amd deck for buttons and bugs
                                                      getIt<Settings>().showAmdDeck.value)
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                          top: 4 * barScale,
                                                        ),
                                                        child: const ModifierDeckWidget(
                                                          name: '',
                                                        ))
                                                ])
                                              ]),
                                          if (sectionsOnSeparateRow && nrOfSections != null)
                                            SizedBox(
                                              width: sectionWidth,
                                              child: const SectionList(),
                                            ),
                                        ]));
                                  });
                            }),
                        if (loading.value)
                          Positioned(
                              left: screenWidth * 0.45,
                              top: MediaQuery.of(context).size.height * 0.4,
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.1,
                              child: const CircularProgressIndicator(
                                strokeWidth: 10,
                              ))
                      ],
                    ),
                  ));
            });
      });
}
