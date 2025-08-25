import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../services/network/client.dart';
import '../services/network/network.dart';
import '../services/service_locator.dart';
import 'commands/load_save_command.dart';
import 'enums.dart';

class Settings {
  final userScalingMainList = ValueNotifier<double>(1.0);
  final userScalingBars = ValueNotifier<double>(
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS) ? 1.6 : 1.0);
  final userScalingMenus = ValueNotifier<double>(1.0);
  final fullScreen = ValueNotifier<bool>(true);
  final darkMode = ValueNotifier<bool>(false);
  final noInit = ValueNotifier<bool>(true);
  final noStandees = ValueNotifier<bool>(false);
  final randomStandees = ValueNotifier<bool>(false);
  final noCalculation = ValueNotifier<bool>(false);
  final expireConditions = ValueNotifier<bool>(true);
  final hideLootDeck = ValueNotifier<bool>(false);
  final shimmer = ValueNotifier<bool>(
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS));
  final showScenarioNames = ValueNotifier<bool>(true);
  final showCustomContent = ValueNotifier<bool>(true);
  final showSectionsInMainView = ValueNotifier<bool>(true);
  final showReminders = ValueNotifier<bool>(true);
  final autoAddStandees = ValueNotifier<bool>(true);
  final autoAddSpawns = ValueNotifier<bool>(true);
  final showAmdDeck = ValueNotifier<bool>(true);
  final showBattleGoalReminder = ValueNotifier<bool>(true);
  final fhHazTerrainCalcInOGGloom = ValueNotifier<bool>(true);
  final showCharacterAMD = ValueNotifier<bool>(
      true); //todo: this should be true on release of this feature

  //used for both initiative and search menus
  final softNumpadInput = ValueNotifier<bool>(false);

  final style = ValueNotifier<Style>(Style.original);

  final saves = ValueNotifier<Map<String, String>>({});

  //network
  final server = ValueNotifier<bool>(false); //not saving these
  final client = ValueNotifier<ClientState>(ClientState.disconnected);
  String lastKnownConnection = "192.168.1.???"; //only these
  String lastKnownPort = "4567";
  String lastKnownHostIP = "";

  bool connectClientOnStartup = false;

  Future<void> init() async {
    await loadFromDisk();
    setFullscreen(fullScreen.value);

    getIt<Network>().networkInfo.initNetworkInfo();
  }

  void loadSave(String saveName) {
    String? save = saves.value[saveName];
    if (save != null) {
      getIt<GameState>().action(LoadSaveCommand(saveName, save));
    }
  }

  void saveState(String saveName) {
    saves.value[saveName] = getIt<GameState>().toString();
    Map<String, String> newMap = {};
    for (String key in saves.value.keys) {
      newMap[key] = saves.value[key]!;
    }
    saves.value = newMap;
    saveToDisk();
  }

  void deleteSave(String saveName) {
    saves.value.remove(saveName);
    Map<String, String> newMap = {};
    for (String key in saves.value.keys) {
      newMap[key] = saves.value[key]!;
    }
    saves.value = newMap;
    saveToDisk();
  }

  Future<void> setFullscreen(bool fullscreen) async {
    fullScreen.value = fullscreen;
    //to set fullscreen on pc - need to add exit button to quit //would be good to exit/enter mode with ctrl+enter
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      WidgetsFlutterBinding.ensureInitialized();
      windowManager.ensureInitialized();

      // Use it only after calling `hiddenWindowAtLaunch`
      windowManager.waitUntilReadyToShow().then((_) async {
        // Hide window title bar
        if (fullscreen) {
          await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
          await windowManager.setFullScreen(true);
          await windowManager.center();
          await windowManager.show();
          await windowManager.setSkipTaskbar(false);
          await windowManager
              .setPosition(const Offset(0, 0)); //weird this was needed
          await windowManager.show();
        } else {
          await windowManager.setTitleBarStyle(TitleBarStyle.normal);
          await windowManager.setFullScreen(false);
          await windowManager.center();
          await windowManager.show();
          await windowManager.setSkipTaskbar(false);
          await windowManager.focus();
          await windowManager.setAlwaysOnTop(false);
        }
      });
    } else {
      //android:
      //to hide ui top and bottom on android
      SystemUiMode nonFullscreen = SystemUiMode.manual;
      if (fullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(nonFullscreen,
            overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
      }
      //to fix issue with system bottom bar on top after keyboard shown on earlier os (24)
      SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) =>
          Future.delayed(const Duration(milliseconds: 1001), () {
            if (fullscreen) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              if (kDebugMode) {
                print("force fullscreen 1 sec");
              }
            } else {
              SystemChrome.setEnabledSystemUIMode(nonFullscreen,
                  overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
            }
            //in case the first went too early?
            Future.delayed(const Duration(milliseconds: 301), () {
              if (fullscreen) {
                SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.immersiveSticky);
                if (kDebugMode) {
                  print("force fullscreen 1.3 sec");
                }
              } else {
                SystemChrome.setEnabledSystemUIMode(nonFullscreen,
                    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
              }
            });
          }));
    }
  }

  Future<void> saveToDisk() async {
    String saveState = toString();

    const sharedPrefsKey = 'settingsState';
    try {
      final prefs = await SharedPreferences.getInstance();
      // save
      await prefs.setString(sharedPrefsKey, saveState);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> loadFromDisk() async {
    //have to call after init or element state overridden

    const sharedPrefsKey = 'settingsState';
    String? state;
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getString(sharedPrefsKey);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
    if (state != null) {
      Map<String, dynamic> data = jsonDecode(state);

      if (data["userScalingMainList"] != null) {
        userScalingMainList.value = data["userScalingMainList"];
        setMaxWidth();
      }
      if (data["userScalingBars"] != null) {
        userScalingBars.value = data["userScalingBars"];
      }
      if (data["userScalingMenus"] != null) {
        userScalingMenus.value = data["userScalingMenus"];
      }
      if (data["fullScreen"] != null) {
        fullScreen.value = data["fullScreen"];
      }
      if (data["softNumpadInput"] != null) {
        softNumpadInput.value = data["softNumpadInput"];
      }
      if (data["darkMode"] != null) {
        darkMode.value = data["darkMode"];
      }
      if (data["noInit"] != null) {
        noInit.value = data["noInit"];
      }
      if (data["noStandees"] != null) {
        noStandees.value = data["noStandees"];
      }
      if (data["randomStandees"] != null) {
        randomStandees.value = data["randomStandees"];
      }
      if (data["noCalculation"] != null) {
        noCalculation.value = data["noCalculation"];
      }
      if (data["hideLootDeck"] != null) {
        hideLootDeck.value = data["hideLootDeck"];
      }
      if (data["style"] != null) {
        style.value = Style.values[data["style"]];
      }
      if (data["expireConditions"] != null) {
        expireConditions.value = data["expireConditions"];
      }
      if (data["lastKnownConnection"] != null) {
        lastKnownConnection = data["lastKnownConnection"];
      }
      if (data["lastKnownPort"] != null) {
        lastKnownPort = data["lastKnownPort"];
      }
      if (data["lastKnownHostIP"] != null) {
        lastKnownHostIP = data["lastKnownHostIP"];
      }

      if (data["shimmer"] != null) {
        shimmer.value = data["shimmer"];
      }
      if (data["showScenarioNames"] != null) {
        showScenarioNames.value = data["showScenarioNames"];
      }
      if (data["showCustomContent"] != null) {
        showCustomContent.value = data["showCustomContent"];
      }

      if (data["showSectionsInMainView"] != null) {
        showSectionsInMainView.value = data["showSectionsInMainView"];
      }

      if (data["showReminders"] != null) {
        showReminders.value = data["showReminders"];
      }

      if (data["autoAddStandees"] != null) {
        autoAddStandees.value = data["autoAddStandees"];
      }

      if (data["autoAddSpawns"] != null) {
        autoAddSpawns.value = data["autoAddSpawns"];
      }

      if (data["showAmdDeck"] != null) {
        showAmdDeck.value = data["showAmdDeck"];
      }

      if (data["showBattleGoalReminder"] != null) {
        showBattleGoalReminder.value = data["showBattleGoalReminder"];
      }

      if (data["fhHazTerrainCalcInOGGloom"] != null) {
        fhHazTerrainCalcInOGGloom.value = data["fhHazTerrainCalcInOGGloom"];
      }

      if (data["showCharacterAMD"] != null && false) {
        //todo: renable on character amd release
        showCharacterAMD.value = data["showCharacterAMD"];
      }

      if (data["saves"] != null) {
        Map<String, dynamic> map = data["saves"];
        for (var key in map.keys) {
          saves.value[key] = map[key];
        }
      }

      if (data["connectClientOnStartup"] != null &&
          data["connectClientOnStartup"] != false) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          getIt<Client>().connect(lastKnownConnection);
        });
      }
    }
  }

  @override
  String toString() {
    return '{'
        '"userScalingMainList": ${userScalingMainList.value}, '
        '"userScalingBars": ${userScalingBars.value}, '
        '"userScalingMenus": ${userScalingMenus.value}, '
        '"fullScreen": ${fullScreen.value}, '
        '"softNumpadInput": ${softNumpadInput.value}, '
        '"noInit": ${noInit.value}, '
        '"noStandees": ${noStandees.value}, '
        '"randomStandees": ${randomStandees.value}, '
        '"noCalculation": ${noCalculation.value}, '
        '"expireConditions": ${expireConditions.value}, '
        '"hideLootDeck": ${hideLootDeck.value}, '
        '"style": ${style.value.index}, '
        '"darkMode": ${darkMode.value}, '
        '"shimmer": ${shimmer.value}, '
        '"showScenarioNames": ${showScenarioNames.value}, '
        '"showCustomContent": ${showCustomContent.value}, '
        '"showSectionsInMainView": ${showSectionsInMainView.value}, '
        '"showReminders": ${showReminders.value}, '
        '"autoAddStandees": ${autoAddStandees.value}, '
        '"autoAddSpawns": ${autoAddSpawns.value}, '
        '"showAmdDeck": ${showAmdDeck.value}, '
        '"showBattleGoalReminder": ${showBattleGoalReminder.value}, '
        '"fhHazTerrainCalcInOGGloom": ${fhHazTerrainCalcInOGGloom.value}, '
        // '"showCharacterAMD": ${showCharacterAMD.value}, ' //todo: uncomment on character amd release
        '"saves": ${jsonEncode(saves.value)}, '
        '"connectClientOnStartup": $connectClientOnStartup, '
        '"lastKnownConnection": "$lastKnownConnection", '
        '"lastKnownPort": "$lastKnownPort", '
        '"lastKnownHostIP": "$lastKnownHostIP" '
        '}';
  }
}
