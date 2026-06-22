import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/widgets/menu_card.dart';
import 'package:frosthaven_assistant/Layout/menus/save_modal_menu.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';

import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class SaveMenu extends StatefulWidget {
  const SaveMenu({
    super.key,
    this.settings,
    this.gameState,
  });

  final Settings? settings;
  final GameState? gameState;

  @override
  SaveMenuState createState() => SaveMenuState();
}

class SaveMenuState extends State<SaveMenu> {
  static const double _kMaxWidth = 400;
  static const double _kTitleHeight = 40;

  // This list holds the data for the list view
  final List<String> _saves = [];
  Settings get _settings => widget.settings ?? getIt<Settings>();
  GameState get _gameState => widget.gameState ?? getIt<GameState>();
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    //fill list with all saved states
    for (String save in _settings.saves.value.keys) {
      _saves.add(save);
    }

    super.initState();
  }

  String getSuggestedSaveName() {
    final String campaign = _gameState.currentCampaign.value;
    int nr = _saves.length + 1;
    while (_saves.contains(campaign + nr.toString())) {
      nr++;
    }
    return campaign + nr.toString();
  }

  @override
  Widget build(BuildContext context) {
    //edge insets if width not too small
    return MenuCard(
        maxWidth: _kMaxWidth,
        cardMargin: const EdgeInsets.all(2),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
                height: _kTitleHeight,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(AppLocalizations.of(context)!.loadAddDeleteSaves,
                    style: getTitleTextStyle(1, forceBlack: true))),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(AppLocalizations.of(context)!.saveStateNote)),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  openDialog(
                      context,
                      SaveModalMenu(
                          saveName: getSuggestedSaveName(), saveOnly: true));
                },
                child: Text(AppLocalizations.of(context)!.addNewSave)),
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
                            title: Text(_saves[index], style: kTitleStyle),
                            onTap: () {
                              openDialog(
                                  context,
                                  SaveModalMenu(
                                      saveName: _saves[index],
                                      saveOnly: false));
                            },
                          ),
                        );
                      })),
            ),
            const SizedBox(
              height: kMenuCloseButtonSpacing,
            ),
          ],
        ));
  }
}
