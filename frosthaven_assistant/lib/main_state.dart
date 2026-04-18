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
import 'main.dart';

class DataLoadedNotification extends Notification { // ignore: prefer-match-file-name, companion type for MainState in same file
  final CampaignModel data;

  const DataLoadedNotification({required this.data});
}

class MainState extends State<MyHomePage>
    with WindowListener, WidgetsBindingObserver {
  late final Network _network;
  late final Settings _settings;
  late final Client _client;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        //this happens all the time on pc, disable this for pc.
        _network.appInBackground = false;
        log("app in resumed");
        rebuildAllChildren(
            context); //might be a bit performance heavy, but ensures app state visually up to date with server.
        if (_network.clientDisconnectedWhileInBackground ||
            (_settings.connectClientOnStartup
            //todo: reevaluate if this is a good idea: might be good to do an actual check, since this boo might be wrong
            // && _settings.client.value == ClientState.disconnected
            )) {
          log("client was in background so try reconnect");
          _network.clientDisconnectedWhileInBackground = false;
          _client.connect(_settings.lastKnownConnection);
        }
        break;
      case AppLifecycleState.inactive: //goes background but still alive.
        //save client state. if somehow disconnected while in background (wifi strangled etc.), reconnect on resume
        log("app in inactive");
        _network.appInBackground = true;
        break;
      case AppLifecycleState.paused:
        log("app in paused");
        break;
      case AppLifecycleState.detached:
        log("app in detached");
        //means shut down. save client state here. and try connect at startup if so.
        if (_settings.client.value == ClientState.connected) {
          log("client was disconnected in background so try reconnect on restart");
          _network.clientDisconnectedWhileInBackground = true;
          _settings.connectClientOnStartup = true;
          _settings.saveToDisk();
          _network.appInBackground = true;
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
    _network = getIt<Network>();
    _settings = getIt<Settings>();
    _client = getIt<Client>();
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (Platform.isAndroid || Platform.isIOS) {
      KeyboardVisibilityController().onChange.listen((bool visible) {
        if (kDebugMode) {
          print("keyboard visible $visible");
        }
        if (!visible && _settings.fullScreen.value) {
          _settings.setFullscreen(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const OverrideTextScaleFactor(child: MainScaffold());
  }

  @override
  void onWindowFocus() {
    setState(() => null);
  }
}
