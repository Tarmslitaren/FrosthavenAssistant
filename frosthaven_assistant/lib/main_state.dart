import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:override_text_scale_factor/override_text_scale_factor.dart';
import 'package:window_manager/window_manager.dart';

import 'Layout/main_scaffold.dart';
import 'Model/campaign.dart';
import 'Resource/game_state.dart';
import 'main.dart';



class DataLoadedNotification extends Notification {
  final CampaignModel data;

  const DataLoadedNotification({required this.data});
}

class MainState extends State<MyHomePage> with WindowListener  {

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid || Platform.isIOS) {
      KeyboardVisibilityController().onChange.listen(
              (bool visible) {
            if (kDebugMode) {
              print("keyboard visible $visible");
            }
            if (!visible && getIt<Settings>().fullScreen.value == true) {
              getIt<Settings>().setFullscreen(true);
            }
          }
      );
    }
  }

  MainState() {
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: getIt<GameState>().updateForUndo,
        builder: (context, value, child) {
          rebuildAllChildren(context); //only way to remake the valuelistenable builders with broken references
    return
      OverrideTextScaleFactor(
              // Note that any widget can be used as child - not only Text widgets
              child:

      createMainScaffold(context));
    });
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
  }
}