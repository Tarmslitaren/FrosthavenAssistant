import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Layout/theme.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/main_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

//import 'package:scaled_app/scaled_app.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';

import 'Layout/menus/main_menu.dart';

void main() {
  setupGetIt();

  /*ScaledWidgetsFlutterBinding.ensureInitialized(
    baseWidth: 490,
    applyScaling: (deviceWidth) => deviceWidth > 100 && deviceWidth < 740,
  );*/
  //runAppScaled(const MyApp());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

     //call after keyboard
    if (!kIsWeb) {
      Wakelock.enable();
      //should force app to be in foreground and disable screen lock
    }
    //Screen.keepOn(true);

    getIt<Settings>().init();

    //getIt<Settings>().setFullscreen(true);
    return MaterialApp(
        //debugShowCheckedModeBanner: false,
        //debugShowMaterialGrid: true,
        checkerboardOffscreenLayers: false,
        //showPerformanceOverlay: true,
        title: 'Frosthaven Assistant',
        theme: theme,
        home: const MyHomePage(title: 'Frosthaven Assistant'),
      );

    /*return MaterialApp(
      title: 'Frosthaven Assistant',
      theme: theme,
      home: const MyHomePage(title: 'Frosthaven Assistant'),
    );*/
  }


}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => MainState();
}
