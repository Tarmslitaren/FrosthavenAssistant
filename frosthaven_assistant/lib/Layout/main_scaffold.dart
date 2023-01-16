import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_deck_widget.dart';
import 'package:frosthaven_assistant/Layout/top_bar.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Model/campaign.dart';
import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'bottom_bar.dart';
import 'loot_deck_widget.dart';
import 'main_list.dart';
import 'menus/main_menu.dart';

Widget createMainScaffold(BuildContext context) {
  return ValueListenableBuilder<double>(
      valueListenable: getIt<Settings>().userScalingBars,
      builder: (context, value, child) {
        bool modFitsOnBar = modifiersFitOnBar(context);
        return SafeArea(
            left: false,
            right: false,
            maintainBottomViewPadding: true,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              //drawerScrimColor: Colors.yellow,
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
                            showToastSticky(
                                context, getIt<GameState>().toastMessage.value);
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
                      valueListenable: getIt<GameState>().modelData,
                      builder: (context, value, child) {
                        return ValueListenableBuilder<int>(
                            valueListenable: getIt<GameState>().commandIndex,
                            builder: (context, value, child) {
                              return GameMethods.hasAllies()
                                  ? Positioned(
                                      bottom: modFitsOnBar
                                          ? 4
                                          : 40 *
                                                  getIt<Settings>()
                                                      .userScalingBars
                                                      .value +
                                              8,
                                      right: 0,
                                      child: const ModifierDeckWidget(
                                          name: 'Allies'))
                                  : Container();
                            });
                      }),
                  modFitsOnBar
                      ? Container()
                      : const Positioned(
                          bottom: 4,
                          right: 0,
                          child: ModifierDeckWidget(
                            name: '',
                          )),
                  Positioned(
                      bottom:  4 *
                          getIt<Settings>()
                              .userScalingBars
                              .value,
                      left: 20,
                      child: const LootDeckWidget())

                ],
              ),
              //floatingActionButton: const ModifierDeckWidget()
            ));
      });
}
