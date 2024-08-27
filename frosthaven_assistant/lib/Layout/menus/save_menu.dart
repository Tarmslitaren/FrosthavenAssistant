import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/save_modal_menu.dart';

import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class SaveMenu extends StatefulWidget {
  const SaveMenu({super.key});

  @override
  SaveMenuState createState() => SaveMenuState();
}

class SaveMenuState extends State<SaveMenu> {
  // This list holds the data for the list view
  final List<String> _saves = [];
  final Settings _settings = getIt<Settings>();
  final GameState _gameState = getIt<GameState>();
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    //fill list with all saved states
    for (String save in _settings.saves.value.keys) {
      _saves.add(save);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //edge insets if width not too small
    return Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
            margin: const EdgeInsets.all(2),
            child: Stack(children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                              'Load, Add or Delete save states.',
                       style: getTitleTextStyle(1)
                    )

                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: const Text(
                        'Please note that the app automatically saves your progress after every action. These are for backups or multiple campaigns.',
                      )
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                      onPressed: () {
                        openDialog(
                            context,
                            SaveModalMenu(
                                saveName:
                                    "${_gameState.currentCampaign.value}${_saves.length + 1}", saveOnly: true));
                      },
                      child: const Text("Add new Save")),
                  Expanded(
                    child: Scrollbar(
                        controller: _scrollController,
                        child: ValueListenableBuilder<Map<String, String>>(
                            valueListenable: _settings.saves,
                            builder: (context, value, child) {
                              _saves.clear();
                              for (String save in _settings.saves.value.keys) {
                                _saves.add(save);
                              }
                              return ListView.builder(
                                controller: _scrollController,
                                itemCount: _saves.length,
                                itemBuilder: (context, index) => ListTile(
                                  title: Text(_saves[index], style: const TextStyle(fontSize: 18)),
                                  onTap: () {
                                    openDialog(context, SaveModalMenu(saveName: _saves[index], saveOnly: false));
                                  },
                                ),
                              );
                            })),
                  ),
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
                      }))
            ])));
  }
}
