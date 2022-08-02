import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_deck_widget.dart';
import 'package:frosthaven_assistant/Layout/top_bar.dart';

import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../services/service_locator.dart';
import 'bottom_bar.dart';
import 'main_list.dart';
import 'menus/main_menu.dart';

Widget createMainScaffold(BuildContext context) {
  return ValueListenableBuilder<double>(
      valueListenable: getIt<Settings>().userScalingBars,
  builder: (context, value, child) {
  return SafeArea(
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
        modifiersFitOnBar(context)? Container():
        const Positioned(
          bottom: 4,
            right: 0,
            child: ModifierDeckWidget())
      ],
    )
    ,
    //floatingActionButton: const ModifierDeckWidget()
  ));});
}
