import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/commands/add_loot_card_command.dart';
import '../../services/service_locator.dart';

class AddLootCardMenu extends StatelessWidget {
  static const double _kTopSpacing = 20.0;
  static const double _kMaxWidth = 300.0;
  static const List<String> _kLootCardNames = [
    "hide", "lumber", "metal", "arrowvine", "axenut",
    "corpsecap", "flamefruit", "rockroot", "snowthistle",
  ];

  const AddLootCardMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Card(
        child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
                controller: scrollController,
                child: Stack(children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: _kTopSpacing,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: _kMaxWidth),
                        child: Column(children: [
                          const Text(
                            "Add Extra Loot Card",
                            style: kTitleStyle,
                          ),
                          //TODO: only show what can be added?
                          ...List.generate(
                            _kLootCardNames.length,
                            (i) => LootCardListTile(name: _kLootCardNames[i], index: i),
                          ),
                        ]),
                      ),
                      const SizedBox(
                        height: kMenuCloseButtonSpacing,
                      ),
                    ],
                  ),
                  Positioned(
                      width: kCloseButtonWidth,
                      height: kButtonSize,
                      right: 0,
                      bottom: 0,
                      child: TextButton(
                          child: const Text(
                            'Close',
                            style: kButtonLabelStyle,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }))
                ]))));
  }
}

class LootCardListTile extends StatefulWidget {
  const LootCardListTile({super.key, required this.name, required this.index, this.gameState});

  final String name;
  final int index;
  final GameState? gameState;

  @override
  State<StatefulWidget> createState() => LootCardListTileState();
}

class LootCardListTileState extends State<LootCardListTile> {
  static const double _kIconSize = 30.0;
  static const double _kContentPaddingLeft = 14.0;
  static const double _kHorizontalTitleGap = 6.0;

  late final GameState _gameState;

  @override
  void initState() {
    _gameState = widget.gameState ?? getIt<GameState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          _gameState.action(AddLootCardCommand(widget.name, gameState: _gameState));
        });
      },
      contentPadding: const EdgeInsets.only(left: _kContentPaddingLeft),
      minVerticalPadding: 0,
      minLeadingWidth: 0,
      horizontalTitleGap: _kHorizontalTitleGap,
      leading: Image(
        filterQuality: FilterQuality.medium,
        height: _kIconSize,
        width: _kIconSize,
        fit: BoxFit.contain,
        image: AssetImage("assets/images/loot/${widget.name}_icon.png"),
      ),
      title: Text(
        widget.name,
        overflow: TextOverflow.visible,
        maxLines: 1,
      ),
      trailing: Text(
          "added: ${_gameState.lootDeck.addedCards[widget.index]}   ",
          style: kTitleStyle),
    );
  }
}
