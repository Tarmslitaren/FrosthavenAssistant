import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/game_data.dart';
import '../background.dart';
import '../view_models/main_list_view_model.dart';
import 'game_list.dart';

class MainList extends StatefulWidget {
  const MainList({
    super.key,
    this.gameState,
    this.gameData,
    this.settings,
  });

  static void scrollToTop() {
    MainListState.scrollToTop();
  }

  final GameState? gameState;
  final GameData? gameData;
  final Settings? settings;

  @override
  MainListState createState() => MainListState();
}

class MainListState extends State<MainList> {
  static const int _kTwoColumns = 2;

  static void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  static void scrollToPosition(int _) {
    //TODO: implement
  }

  MainListViewModel? _vmInstance;
  MainListViewModel get _vm => _vmInstance ??= MainListViewModel(
        gameState: widget.gameState,
        gameData: widget.gameData,
        settings: widget.settings,
      );

  static final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _vm.darkMode,
        builder: (context, value, child) {
          return BackGround(
              child: ValueListenableBuilder<Map<String, CampaignModel>>(
                  valueListenable: _vm.modelData,
                  builder: (context, value, child) {
                    return ValueListenableBuilder<double>(
                        valueListenable: _vm.userScalingMainList,
                        builder: (context, value, child) {
                          return buildList();
                        });
                  }));
        });
  }

  Widget buildList() {
    final screenSize = MediaQuery.of(context).size;
    double width = getMainListWidth(context);
    bool canFit2Columns = screenSize.width >= width * _kTwoColumns;
    if (canFit2Columns) {
      width *= _kTwoColumns;
    }

    return Container(
        alignment: Alignment.topCenter,
        child: RepaintBoundary(
            child: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                        alignment: Alignment.center,
                        width: screenSize.width,
                        child: RepaintBoundary(
                          child: GameList(vm: _vm),
                        ))))));
  }
}
