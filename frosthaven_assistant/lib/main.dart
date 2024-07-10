import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/theme.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/main_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'Resource/game_data.dart';
import 'Resource/theme_switcher.dart';

void _enablePlatformOverrideForDesktop() {
  if (kDebugMode && !kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  setupGetIt();

  _enablePlatformOverrideForDesktop();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('X-haven Assistant');
    if (!Platform.isMacOS) {
      windowManager.setMinimumSize(const Size(400, 600));
    }
    setWindowMinSize(const Size(
        400, 600)); //when updating flutter you may need to re-set these values in main.cpp
    setWindowMaxSize(Size.infinite);
  }

  //if (kReleaseMode) {
    ErrorWidget.builder = ((e) {
      if(!kDebugMode) {
        //to not show the gray boxes, when there are exceptions
        return Container();
      }
      //show the error in debug builds
      return ErrorWidget(e);
    });
  //}


  runApp(ThemeSwitcherWidget(initialTheme: theme, child: const MyApp()));

}

final loading = ValueNotifier<bool>(true);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = false;

    //call after keyboard
    if (Platform.isIOS || Platform.isAndroid) {
      WakelockPlus.enable();
      //should force app to be in foreground and disable screen lock
    }

    try {
      //initialize game
      getIt<GameState>().init();
      getIt<GameData>().loadData("assets/data/")
          .then((value) => getIt<GameState>().load()).then((value) =>
          getIt<Settings>().init()).then((value) => {
            loading.value = false
          }
      );
    } catch (error) {
      loading.value = false;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      checkerboardOffscreenLayers: false,
      showPerformanceOverlay: false,
      title: 'X-haven Assistant',
      theme: ThemeSwitcher.of(context).themeData,
      home: const MyHomePage(title: 'X-haven Assistant'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MainState();
}
