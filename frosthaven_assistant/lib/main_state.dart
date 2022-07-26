import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'Layout/main_scaffold.dart';
import 'Model/campaign.dart';
import 'Resource/game_state.dart';
import 'main.dart';



class DataLoadedNotification extends Notification {
  final CampaignModel data;

  const DataLoadedNotification({required this.data});
}

class MainState extends State<MyHomePage>  {

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  MainState() {
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: getIt<GameState>().updateForUndo,
        builder: (context, value, child) {
          rebuildAllChildren(context); //only way to remake the valuelistenable builders with broken references
    return createMainScaffold(context);
    });
  }
}