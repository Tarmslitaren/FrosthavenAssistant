import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/adjustable_scroll_controller.dart';
import 'package:frosthaven_assistant/Resource/commands/track_standees_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../../Resource/scaling.dart';
import '../../Resource/settings.dart';
import '../../services/network/network.dart';
import '../../services/service_locator.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  SettingsMenuState createState() => SettingsMenuState();
}

final networkInfo = NetworkInfo();

class SettingsMenuState extends State<SettingsMenu> {
  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
    getIt<Network>().networkInfo.initNetworkInfo();
  }

  final TextEditingController _serverTextController = TextEditingController();
  final TextEditingController _portTextController = TextEditingController();

  final AdjustableScrollController scrollController =
      AdjustableScrollController();

  @override
  Widget build(BuildContext context) {
    Settings settings = getIt<Settings>();

    double screenWidth = MediaQuery.of(context).size.width;
    double referenceMinBarWidth = 40 * 6.5;
    double maxBarScale = screenWidth / referenceMinBarWidth;
    _serverTextController.text = settings.lastKnownConnection;
    _portTextController.text = settings.lastKnownPort;

    return Card(
        child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
                controller: scrollController,
                child: Stack(children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Settings",
                                style: TextStyle(fontSize: 18),
                              ),
                              CheckboxListTile(
                                  title: const Text("Dark mode"),
                                  value: settings.darkMode.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.darkMode.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Soft numpad for input"),
                                  value: settings.softNumpadInput.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.softNumpadInput.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Don't ask for initiative"),
                                  value: settings.noInit.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.noInit.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Expire Conditions"),
                                  value: settings.expireConditions.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.expireConditions.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Don't track Standees"),
                                  value: settings.noStandees.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      getIt<GameState>().action(
                                          TrackStandeesCommand(!value!));
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Auto Add Standees"),
                                  value: settings.autoAddStandees.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.autoAddStandees.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateList.value++;
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Auto Add Timed Spawns"),
                                  value: settings.autoAddSpawns.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.autoAddSpawns.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateList.value++;
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Random Standees"),
                                  value: settings.randomStandees.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.randomStandees.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("No Calculations"),
                                  value: settings.noCalculation.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.noCalculation.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateList.value++;
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Hide Loot Deck"),
                                  value: settings.hideLootDeck.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.hideLootDeck.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Stat card text shimmers"),
                                  value: settings.shimmer.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.shimmer.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title:
                                      const Text("Show Scenario names in list"),
                                  value: settings.showScenarioNames.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showScenarioNames.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title:
                                  const Text("Show Custom Content"),
                                  value: settings.showCustomContent.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showCustomContent.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title:
                                  const Text("Show Sections in Main Screen"),
                                  value: settings.showSectionsInMainView.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showSectionsInMainView.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title:
                                  const Text("Show Round Special Rule Reminders"),
                                  value: settings.showReminders.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showReminders.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              if (!Platform.isIOS)
                                CheckboxListTile(
                                    title: const Text("Fullscreen"),
                                    value: settings.fullScreen.value,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        settings.setFullscreen(value!);
                                        settings.saveToDisk();
                                      });
                                    }),
                              Container(
                                constraints: const BoxConstraints(
                                    minWidth: double.infinity),
                                padding:
                                    const EdgeInsets.only(left: 16, top: 10),
                                alignment: Alignment.bottomLeft,
                                child: const Text("Main List Scaling:"),
                              ),
                              Slider(
                                min: 0.2,
                                max: 3.0,
                                //divisions: 1,
                                value: settings.userScalingMainList.value,
                                onChanged: (value) {
                                  setState(() {
                                    settings.userScalingMainList.value = value;
                                    setMaxWidth();
                                    settings.saveToDisk();
                                  });
                                },
                              ),
                              Container(
                                constraints: const BoxConstraints(
                                    minWidth: double.infinity),
                                padding:
                                    const EdgeInsets.only(left: 16, top: 10),
                                alignment: Alignment.bottomLeft,
                                child: const Text("App Bar Scaling:"),
                              ),
                              Slider(
                                min: min(0.8, maxBarScale),
                                max: min(maxBarScale, 3.0),
                                //divisions: 1,
                                value: settings.userScalingBars.value,
                                onChanged: (value) {
                                  setState(() {
                                    settings.userScalingBars.value = value;
                                    settings.saveToDisk();
                                  });
                                },
                              ),
                              const Text(
                                "Style:",
                                style: TextStyle(fontSize: 18),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      Radio(
                                          value: Style.frosthaven,
                                          groupValue: settings.style.value,
                                          onChanged: (index) {
                                            setState(() {
                                              settings.style.value =
                                                  Style.frosthaven;
                                              settings.saveToDisk();
                                              //ThemeSwitcher.of(context).switchTheme(themeFH);
                                              getIt<GameState>()
                                                  .updateList
                                                  .value++;
                                            });
                                          }),
                                      const Text('Frosthaven')
                                    ],
                                  ),
                                  /*Row(
                      children: [
                        Radio(value: Style.gloomhaven, groupValue: settings.style.value, onChanged: (index) {
                          setState(() {
                            settings.style.value = Style.gloomhaven;
                            settings.saveToDisk();
                            //ThemeSwitcher.of(context).switchTheme(theme);
                            getIt<GameState>().updateList.value++;
                          });
                        }),
                        const Text('Gloomhaven')
                      ],
                    ),*/
                                  Row(
                                    children: [
                                      Radio(
                                          value: Style.original,
                                          groupValue: settings.style.value,
                                          onChanged: (index) {
                                            setState(() {
                                              settings.style.value =
                                                  Style.original;
                                              settings.saveToDisk();
                                              if (getIt<GameState>()
                                                      .currentCampaign
                                                      .value ==
                                                  "Frosthaven") {
                                                //ThemeSwitcher.of(context).switchTheme(themeFH);
                                              } else {
                                                //ThemeSwitcher.of(context).switchTheme(theme);
                                              }
                                              getIt<GameState>()
                                                  .updateList
                                                  .value++;
                                            });
                                          }),
                                      const Text('Original')
                                    ],
                                  ),
                                ],
                              ),
                              ListTile(
                                  title:
                                      const Text("Clear unlocked characters"),
                                  onTap: () {
                                    setState(() {
                                      GameMethods.clearUnlockedClasses();
                                    });
                                  }),
                              const Text("Connect devices on local wifi:"),
                              ValueListenableBuilder<ClientState>(
                                  valueListenable: settings.client,
                                  builder: (context, value, child) {
                                    bool connected = false;
                                    String connectionText = "Connect as Client";
                                    if (settings.client.value == ClientState.connected) {
                                      connected = true;
                                      connectionText = "Connected as Client";
                                    }
                                    if (settings.client.value == ClientState.connecting) {
                                      connectionText = "Connecting...";
                                    }
                                    return CheckboxListTile(
                                        enabled: settings.server.value == false && settings.client.value != ClientState.connecting,
                                        title: Text(connectionText),
                                        value: connected,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (settings.client.value != ClientState.connected) {
                                              settings.client.value = ClientState.connecting;
                                              settings.lastKnownPort =
                                                  _portTextController.text;
                                              getIt<Network>()
                                                  .client
                                                  .connect(_serverTextController
                                                      .text)
                                                  .then((value) => null);
                                              settings.lastKnownConnection =
                                                  _serverTextController.text;
                                              settings.saveToDisk();
                                            } else {
                                              getIt<Network>()
                                                  .client
                                                  .disconnect(null);
                                            }
                                          });
                                        });
                                  }),

                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: 200,
                                height: 40,
                                child: TextField(
                                    controller: _serverTextController,
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      helperText: "server ip address",
                                    ),
                                    maxLength: 20),
                              ),

                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                width: 200,
                                height: 40,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _portTextController,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    helperText: "port",
                                  ),
                                  maxLength: 6,
                                ),
                              ),
                              ValueListenableBuilder<bool>(
                                  valueListenable: settings.server,
                                  builder: (context, value, child) {
                                    return CheckboxListTile(
                                        title: Text(settings.server.value
                                            ? "Stop Server"
                                            : "Start Host Server"),
                                        value: settings.server.value,
                                        onChanged: (bool? value) {
                                          if (!settings.server.value) {
                                            settings.lastKnownPort =
                                                _portTextController.text;
                                            settings.lastKnownHostIP =
                                                "(${getIt<Network>()
                                                  .networkInfo
                                                  .wifiIPv4
                                                  .value})";
                                            settings.saveToDisk();
                                            getIt<Network>()
                                                .server
                                                .startServer();
                                            getIt<Network>()
                                                .webServer
                                                .startServer();
                                          } else {
                                            //close server
                                            getIt<Network>()
                                                .server
                                                .stopServer(null);
                                            getIt<Network>()
                                                .webServer
                                                .stopServer(null);
                                          }
                                        });
                                  }),
                              ValueListenableBuilder<String>(
                                  valueListenable:
                                      getIt<Network>().networkInfo.wifiIPv4,
                                  builder: (context, value, child) {
                                    return SizedBox(
                                        width: 200,
                                        height: 20,
                                        child: Text(getIt<Network>()
                                            .networkInfo
                                            .wifiIPv4
                                            .value));
                                  }),
                              ValueListenableBuilder<String>(
                                  valueListenable:
                                      getIt<Network>().networkInfo.outgoingIPv4,
                                  builder: (context, value, child) {
                                    return SizedBox(
                                        width: 200,
                                        height: 20,
                                        child: Text(getIt<Network>()
                                            .networkInfo
                                            .outgoingIPv4
                                            .value));
                                  }),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                width: 200,
                                height: 40,
                                child: TextField(
                                  controller: _portTextController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    helperText: "port",
                                  ),
                                  maxLength: 6,
                                ),
                              )
                              //checkbox client + host + port
                              //checkbox server - show ip, port
                            ],
                          )),
                      const SizedBox(
                        height: 34,
                      ),
                    ],
                  ),
                  Positioned(
                      width: 100,
                      height: 40,
                      right: 0,
                      bottom: 0,
                      child: TextButton(
                          child: const Text(
                            'Close',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            settings.saveToDisk();
                          }))
                ]))));
  }
}
