import 'package:flutter/material.dart';
import '../../Resource/commands/add_standee_command.dart';
import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class AddSummonMenu extends StatefulWidget {
  final Character character;

  const AddSummonMenu({Key? key, required this.character}) : super(key: key);

  @override
  AddSummonMenuState createState() => AddSummonMenuState();
}

class AddSummonMenuState extends State<AddSummonMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget buildNrButton(int nr) {
    MonsterType type = MonsterType.summon;
    Color color = Colors.white;
    bool isOut = false;

    String text = nr.toString();
    return SizedBox(
      width: 32,
      height: 32,
      child: Container(
          child: TextButton(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            shadows: const [Shadow(offset: Offset(1, 1), color: Colors.black)],
          ),
        ),
        onPressed: () {
          if (!isOut) {
            //_gameState.action(AddStandeeCommand(nr, widget.monster, type));
          }
        },
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    int nrOfStandees = 4; //widget.character.characterClass.summons[0].standees;
    //4 nr's per row

    double height = 160;
    return Container(
        width: 336,
        height: 210,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage('assets/images/bg/white_bg.png'),
            fit: BoxFit.fitWidth,
          ),
        ),
      child: Container(),
    );
    return Container(
        width: 100, //need to set any width to center content
        height: height,
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.8), BlendMode.dstATop),
                image: AssetImage('assets/images/bg/white_bg.png'),
                fit: BoxFit.fitHeight)),
        child: Container()
        /*ValueListenableBuilder<List<MonsterInstance>>(
                  valueListenable: widget.character.characterState.summonList,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text("Add Standees",
                            style: TextStyle(fontSize: 18)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildNrButton(1),
                            nrOfStandees > 1 ? buildNrButton(2) : Container(),
                            nrOfStandees > 2 ? buildNrButton(3) : Container(),
                            nrOfStandees > 3 ? buildNrButton(4) : Container(),
                          ],
                        ),
                      ],
                    );
                  }),*/
        );
  }
}
