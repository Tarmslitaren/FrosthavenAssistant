import 'package:flutter/material.dart';

import '../Model/character_class.dart';
import '../Resource/commands.dart';
import '../Resource/game_state.dart';
import '../services/service_locator.dart';

class RemoveCharacterMenu extends StatefulWidget {
  const RemoveCharacterMenu({Key? key}) : super(key: key);

  @override
  _RemoveCharacterMenuState createState() => _RemoveCharacterMenuState();
}

class _RemoveCharacterMenuState extends State<RemoveCharacterMenu> {
  // This holds a list of fiction users
  // You can use data fetched from a database or a server as well
  // This list holds the data for the list view
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all users are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Character> currentCharacters = _gameState.getCurrentCharacters();
    return Card(
        //color: Colors.transparent,
        // shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(20),
        child: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentCharacters.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: Image(
                      height: 30,
                      image: AssetImage(
                          "assets/images/class-icons/${currentCharacters[index].id}.png"),
                    ),
                    iconColor: currentCharacters[index].characterClass.color,
                    title: Text(
                      currentCharacters[index].id,
                    ),
                    onTap: () {
                      _gameState.action(RemoveCharacterCommand(
                          [currentCharacters[index].id])); //
                      //Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
              width: 100,
              right: 2,
              bottom: 2,
              child: TextButton(
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }))
        ]));
  }
}
