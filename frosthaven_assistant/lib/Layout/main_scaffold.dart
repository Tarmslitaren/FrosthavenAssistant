import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/background.dart';
import 'package:frosthaven_assistant/Layout/modifier_deck_widget.dart';
import 'package:frosthaven_assistant/Layout/section_list.dart';
import 'package:frosthaven_assistant/Layout/top_bar.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Model/campaign.dart';
import '../Resource/game_data.dart';
import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'bottom_bar.dart';
import 'character_amds_widget.dart';
import 'loot_deck_widget.dart';
import 'main_list.dart';
import 'menus/main_menu.dart';
import 'view_models/main_scaffold_view_model.dart';

class MainScaffold extends StatelessWidget {
  static const double _kAppBarHeight = 40.0;

  const MainScaffold({super.key, this.settings});

  // injected for testing
  final Settings? settings;

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
                      preferredSize: Size(
                          double.infinity, _kAppBarHeight * settings.userScalingBars.value),
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
  static const double _kBarBottom = 4.0;
  static const double _kBarLeft = 5.0;
  static const double _kDeckMargin = 4.0;
  const MainScaffoldBody(
      {super.key, this.gameState, this.settings, this.gameData});

  // injected for testing
  final GameState? gameState;
  final Settings? settings;
  final GameData? gameData;

  @override
  Widget build(BuildContext context) {
    final vm = MainScaffoldViewModel(
        gameState: gameState, settings: settings, gameData: gameData);
    final Size screenSize = MediaQuery.of(context).size;

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
                  valueListenable: vm.modelData,
                  builder: (context, value, child) {
                    return ValueListenableBuilder<int>(
                        valueListenable: vm.commandIndex,
                        builder: (context, value, child) {
                          return ValueListenableBuilder<double>(
                              valueListenable: vm.userScalingBars,
                              builder: (context, value, child) {
                                final barScale = vm.userScalingBars.value;
                                final bool hasLootDeck = vm.hasLootDeck;
                                final bool modFitsOnBar =
                                    modifiersFitOnBar(context);
                                final int? nrOfSections = vm.availableSections;
                                final bool separateRow =
                                    vm.sectionsOnSeparateRow(context);
                                final double width = separateRow
                                    ? screenSize.width
                                    : vm.sectionWidth(context);

                                return Positioned(
                                    width: screenSize.width,
                                    bottom: barScale * _kBarBottom,
                                    left: barScale * _kBarLeft,
                                    child: Column(children: [
                                      Row(
                                          mainAxisAlignment: ((!separateRow &&
                                                      nrOfSections != null) ||
                                                  hasLootDeck)
                                              ? MainAxisAlignment.spaceBetween
                                              : MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            if (hasLootDeck)
                                              const LootDeckWidget(),
                                            if (!separateRow &&
                                                nrOfSections != null)
                                              SizedBox(
                                                width: width,
                                                child: const SectionList(),
                                              ),
                                            Column(children: [
                                              RepaintBoundary(
                                                  child: CharacterAmdsWidget()),
                                              if (vm.shouldShowAlliesDeck)
                                                Container(
                                                    margin: EdgeInsets.only(
                                                      top: _kDeckMargin * barScale,
                                                    ),
                                                    child:
                                                        const ModifierDeckWidget(
                                                      name: 'allies',
                                                    )),
                                              if (!modFitsOnBar &&
                                                  !vm.isButtonsAndBugs &&
                                                  vm.showAmdDeck)
                                                Container(
                                                    margin: EdgeInsets.only(
                                                      top: _kDeckMargin * barScale,
                                                    ),
                                                    child:
                                                        const ModifierDeckWidget(
                                                      name: '',
                                                    ))
                                            ])
                                          ]),
                                      if (separateRow && nrOfSections != null)
                                        SizedBox(
                                          width: width,
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
