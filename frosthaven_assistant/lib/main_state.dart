import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:frosthaven_assistant/services/network/network.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:override_text_scale_factor/override_text_scale_factor.dart';
import 'package:window_manager/window_manager.dart';

import 'Layout/main_scaffold.dart';
import 'Model/campaign.dart';
import 'Resource/state/game_state.dart';
import 'main.dart';

class DataLoadedNotification extends Notification {
  final CampaignModel data;

  const DataLoadedNotification({required this.data});
}

class MainState extends State<MyHomePage> with WindowListener, WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        getIt<Network>().appInBackground = false;
        log("app in resumed");
        rebuildAllChildren(
            context); //might be a bit performance heavy, but ensures app state visually up to date with server.
        if (getIt<Network>().clientDisconnectedWhileInBackground == true ||
            (getIt<Settings>().connectClientOnStartup == true
                //todo: reevaluate if this is a good idea: might be good to do an actual check, since this boo might be wrong
               // && getIt<Settings>().client.value == ClientState.disconnected
            )
        ) {
          log("client was disconnected in background so try reconnect");
          getIt<Network>().clientDisconnectedWhileInBackground = false;
          getIt<Client>().connect(
              getIt<Settings>().lastKnownConnection);
        }
        break;
      case AppLifecycleState.inactive: //goes background but still alive.
        //save client state. if somehow disconnected while in background (wifi strangled etc.), reconnect on resume
        log("app in inactive");
        getIt<Network>().appInBackground = true;
        break;
      case AppLifecycleState.paused:
        log("app in paused");
        break;
      case AppLifecycleState.detached:
        log("app in detached");
        //means shut down. save client state here. and try connect at startup if so.
        if (getIt<Settings>().client.value == ClientState.connected) {
          log("client was disconnected in background so try reconnect on restart");
          getIt<Network>().clientDisconnectedWhileInBackground = true;
          getIt<Settings>().connectClientOnStartup = true;
          getIt<Settings>().saveToDisk();
          getIt<Network>().appInBackground = true;
        }
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case?
        break;
    }
  }

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
    WidgetsBinding.instance.addObserver(this);

    if (Platform.isAndroid || Platform.isIOS) {
      KeyboardVisibilityController().onChange.listen((bool visible) {
        if (kDebugMode) {
          print("keyboard visible $visible");
        }
        if (!visible && getIt<Settings>().fullScreen.value == true) {
          getIt<Settings>().setFullscreen(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: getIt<GameState>().updateForUndo,
        builder: (context, value, child) {
          rebuildAllChildren(
              context); //only way to remake the value listenable builders with broken references
          return OverrideTextScaleFactor(child: createMainScaffold(context));
        });
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
  }
}
