import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/widgets/menu_card.dart';
import 'package:frosthaven_assistant/Resource/commands/unlock_special_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';

import '../../Resource/app_constants.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class SpecialUnlocksMenu extends StatelessWidget {
  SpecialUnlocksMenu({super.key, this.gameState, this.settings});

  final GameState? gameState;
  final Settings? settings;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final gameState = this.gameState ?? getIt<GameState>();
    final settings = this.settings ?? getIt<Settings>();
    List<List<String>> unlocks = [
      ["Demons", "assets/images/demons.png"],
      ["Merchant-Guild", "assets/images/merchant-guild.png"],
      ["Military", "assets/images/military.png"],
      ["Bladeswarm", "assets/images/class-icons/Bladeswarm.png"]
    ];

    if (settings.showCustomContent.value) {
      unlocks.add(["Vanquisher", "assets/images/class-icons/Vanquisher.png"]);
    }

    bool getEnabled(String id) {
      return gameState.unlockedClasses.contains(id);
    }

    return MenuCard(
        cardMargin: const EdgeInsets.all(2),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(AppLocalizations.of(context)!.specialUnlocks,
                  style: getTitleTextStyle(1, forceBlack: true)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Scrollbar(
                  controller: _scrollController,
                  child: ValueListenableBuilder<int>(
                      valueListenable: gameState.unlockedClassesVersion,
                      builder: (context, value, child) {
                        return ListView.builder(
                            controller: _scrollController,
                            itemCount: unlocks.length,
                            itemBuilder: (context, index) =>
                                CheckboxListTile(
                                  secondary: Image.asset(
                                    unlocks[index].last,
                                    height: kButtonSize,
                                    width: kButtonSize,
                                    cacheHeight:
                                        kCharacterIconCacheHeight,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.medium,
                                  ),
                                  title: Text(
                                      getEnabled(unlocks[index].first)
                                          ? unlocks[index].first
                                          : "???",
                                      style: TextStyle(
                                          fontSize: kFontSizeTitle,
                                          color: Colors.black)),
                                  onChanged: (bool? value) {
                                    gameState.action(UnlockSpecialCommand(
                                        unlocks[index].first,
                                        gameState: gameState));
                                  },
                                  value: getEnabled(unlocks[index].first),
                                ));
                      })),
            ),
            const SizedBox(
              height: kMenuCloseButtonSpacing,
            ),
          ],
        ));
  }
}
