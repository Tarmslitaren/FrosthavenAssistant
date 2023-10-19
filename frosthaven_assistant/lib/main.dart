import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/theme.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/main_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'Resource/theme_switcher.dart';

void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
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
    setWindowMinSize(const Size(400,
        600)); //when updating flutter you may need to re-set these values in main.cpp
    setWindowMaxSize(Size.infinite);
  }

  if (kReleaseMode) {
    ErrorWidget.builder = ((e) {
      //to not show the gray boxes, when there are exceptions
      return Container();
    });
  }

  runApp(ThemeSwitcherWidget(initialTheme: theme, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = false;

    //call after keyboard
    if (Platform.isIOS || Platform.isAndroid) {
      Wakelock.enable();
      //should force app to be in foreground and disable screen lock
    }
    //Screen.keepOn(true);

    getIt<Settings>().init();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //debugShowMaterialGrid: true,
      checkerboardOffscreenLayers: false,
      //showPerformanceOverlay: true,
      title: 'X-haven Assistant',
      theme: ThemeSwitcher.of(context).themeData,
      home: const MyHomePage(title: 'X-haven Assistant'),

      /* builder: (context, child) => ResponsiveWrapper.builder(

          const Navigator(
              pages: [
                MaterialPage(child: MyHomePage(title: 'X-haven Assistant')),
              ]
          ),


          defaultScale: true,

          background: Container(color: Colors.deepPurpleAccent)),
      initialRoute: "/",*/

      /*builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //to disable os large font setting
          child: const Navigator(
            pages: [
              MaterialPage(child: MyHomePage(title: 'X-haven Assistant'))
            ]
          )
        );
      },*/
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => MainState();
}
