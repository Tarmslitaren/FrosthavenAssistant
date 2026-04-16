import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/global_hotkeys.dart';
import 'package:frosthaven_assistant/Layout/theme.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/main_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:show_fps/show_fps.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'Resource/game_data.dart';
import 'Resource/theme_switcher.dart';

const title = 'X-haven Assistant';

void _enablePlatformOverrideForDesktop() {
  if (kDebugMode && !kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupGetIt();

  _enablePlatformOverrideForDesktop();
  //debugPrintRebuildDirtyWidgets = true;
  //debugProfileBuildsEnabled = true;
  //debugProfileLayoutsEnabled = true;
  //debugRepaintRainbowEnabled = true;

  const minScreenWidth = 400.0;
  const minScreenHeight = 600.0;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle(title);
    if (!Platform.isMacOS) {
      windowManager.setMinimumSize(const Size(minScreenWidth, minScreenHeight));
    }
    setWindowMinSize(const Size(minScreenWidth,
        minScreenHeight)); //when updating flutter you may need to re-set these values in main.cpp
    setWindowMaxSize(Size.infinite);
  }

  FlutterError.onError = (details) {
    if (kReleaseMode) {
      Sentry.captureException(details.exception, stackTrace: details.stack);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode) {
      Sentry.captureException(error, stackTrace: stack);
    }
    return true;
  };

  ErrorWidget.builder = (e) {
    if (kReleaseMode) {
      Sentry.captureException(e.exception, stackTrace: e.stack);
      return Container();
    }
    return ErrorWidget(e);
  };

  await SentryFlutter.init(
    (options) {
      // TODO: should sentry account be secret?
      options.dsn = kReleaseMode
          ? 'https://724e200e79e66374173bda0192f05101@o4511228276703232.ingest.de.sentry.io/4511228279914576'
          : '';
    },
    appRunner: () =>
        runApp(ThemeSwitcherWidget(initialTheme: theme, child: const MyApp())),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    //debugInvertOversizedImages = true;

    //call after keyboard
    WakelockPlus.enable();

    try {
      //initialize game
      getIt<GameState>().init();
      getIt<GameData>()
          .loadData("assets/data/")
          .then((value) => getIt<GameState>().load())
          .then((value) => getIt<Settings>().init())
          .then((_) { loading.value = false; })
          .catchError((Object error, StackTrace stack) {
            Sentry.captureException(error, stackTrace: stack);
            debugPrint('Init failed: $error');
            loading.value = false;
          });
    } catch (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      debugPrint('Init failed: $error');
      loading.value = false;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      checkerboardOffscreenLayers: false,
      showPerformanceOverlay: false,
      title: title,
      theme: ThemeSwitcher.of(context).themeData,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return GlobalHotkeys(child: child);
      },
      home: ShowFPS(
          alignment: Alignment.topRight,
          visible: !kReleaseMode && false,
          showChart: true,
          child: const MyHomePage(title: title)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MainState();
}
