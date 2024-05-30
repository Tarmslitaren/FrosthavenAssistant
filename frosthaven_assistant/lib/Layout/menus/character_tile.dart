import 'package:flutter/material.dart';

import '../../Model/character_class.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class CharacterTile extends StatefulWidget {
  // Constructor
  const CharacterTile(
      {super.key, required this.character, required this.onAddCharacter});

  final CharacterClass character;
  final void Function(CharacterClass) onAddCharacter;

  @override
  State<CharacterTile> createState() => _CharacterTileState();
}

class _CharacterTileState extends State<CharacterTile> {
  final GameState _gameState = getIt<GameState>();
  late bool characterAlreadyAdded;

  @override
  void initState() {
    super.initState();
    characterAlreadyAdded = _characterAlreadyAdded(widget.character.name);
  }

  bool _characterAlreadyAdded(String newCharacter) {
    if (newCharacter == "Escort" || newCharacter == "Objective") {
      return false;
    }
    var characters = GameMethods.getCurrentCharacters();
    for (var character in characters) {
      if (character.characterClass.name == newCharacter) {
        return true;
      }
    }
    return false;
  }

  void _handleAddCharacter() {
    if (!characterAlreadyAdded) {
      widget.onAddCharacter(widget.character);
      setState(() {
        characterAlreadyAdded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool characterUnlocked =
        _gameState.unlockedClasses.contains(widget.character.name);
    bool characterIsObjective = widget.character.name == "Objective";
    bool characterIsEscort = widget.character.name == "Escort";

    return ListTile(
      leading: Image(
        height: 40,
        width: 40,
        fit: BoxFit.contain,
        color: widget.character.hidden && !characterUnlocked ||
                characterIsEscort ||
                characterIsObjective
            ? null
            : widget.character.color,
        filterQuality: FilterQuality.medium,
        image: AssetImage(
            "assets/images/class-icons/${widget.character.name}.png"),
      ),
      //iconColor: character.color,
      title: Text(
          widget.character.hidden && !characterUnlocked
              ? "???"
              : widget.character.name,
          style: TextStyle(
              fontSize: 18,
              color: characterAlreadyAdded ? Colors.grey : Colors.black)),
      trailing: Text("(${widget.character.edition})",
          style: const TextStyle(fontSize: 14, color: Colors.grey)),
      onTap: _handleAddCharacter,
    );
  }
}
