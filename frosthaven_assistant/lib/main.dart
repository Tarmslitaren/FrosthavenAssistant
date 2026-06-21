import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/global_hotkeys.dart';
import 'package:frosthaven_assistant/Layout/theme.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/main_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'Resource/game_data.dart';
import 'Resource/theme_switcher.dart';

// SocketExceptions caused by normal TCP connection lifecycle events (client
// disconnects, network changes, timeouts). These are handled gracefully in
// the networking layer and should not consume the Sentry error quota.
const _benignSocketErrno = <int>{
  9,     // EBADF          – bad file descriptor (socket already closed)
  32,    // EPIPE          – broken pipe (client disconnected mid-write)
  54,    // ECONNRESET     – connection reset by peer (macOS/iOS)
  60,    // ETIMEDOUT      – operation timed out (macOS/iOS)
  64,    // EHOSTDOWN      – host is down (macOS/BSD)
  103,   // ECONNABORTED   – software caused connection abort (Android/Linux)
  104,   // ECONNRESET     – connection reset by peer (Linux/Android)
  107,   // ENOTCONN       – transport endpoint not connected
  110,   // ETIMEDOUT      – operation timed out (Linux)
  113,   // EHOSTUNREACH   – no route to host
  121,   // ERROR_SEM_TIMEOUT – semaphore timeout (Windows)
  10053, // WSAECONNABORTED – connection aborted by local software (Windows)
  10054, // WSAECONNRESET  – connection forcibly closed by remote host (Windows)
};

bool _isBenignNetworkError(Object error) {
  if (error is! SocketException) return false;
  final errno = error.osError?.errorCode;
  return errno != null && _benignSocketErrno.contains(errno);
}

const title = 'X-haven Assistant';
String appVersion = '';

void _enablePlatformOverrideForDesktop() {
  if (kDebugMode && !kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupGetIt();
  appVersion = (await PackageInfo.fromPlatform()).version;

  _enablePlatformOverrideForDesktop();
  //debugPrintRebuildDirtyWidgets = true;
  //debugProfileBuildsEnabled = true;
  //debugProfileLayoutsEnabled = true;
  //debugRepaintRainbowEnabled = true;

  const minScreenWidth = 400.0;
  const minScreenHeight = 600.0;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    windowManager.setTitle(title);
    windowManager.setMinimumSize(const Size(minScreenWidth, minScreenHeight));
    windowManager.setMaximumSize(Size.infinite);
  }

  FlutterError.onError = (details) {
    if (kReleaseMode) {
      if (!_isBenignNetworkError(details.exception)) {
        Sentry.captureException(details.exception, stackTrace: details.stack);
      }
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode && !_isBenignNetworkError(error)) {
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
      options.dsn = kReleaseMode
          ? const String.fromEnvironment('SENTRY_DSN')
          : '';
    },
    appRunner: () =>
        runApp(ThemeSwitcherWidget(initialTheme: theme, child: const MyApp())),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static Future<void> _initializeApp() async {
    try {
      await getIt<GameData>().loadData("assets/data/");
      getIt<GameState>().load();
      await getIt<Settings>().init();
      loading.value = false;
    } catch (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      debugPrint('Init failed: $error');
      loading.value = false;
    }
  }

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    //debugInvertOversizedImages = true;

    try {
      //initialize game
      getIt<GameState>().init();
      unawaited(_initializeApp());
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
        return ExcludeSemantics(child: GlobalHotkeys(child: child));
      },
      home: const MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MainState();
}
