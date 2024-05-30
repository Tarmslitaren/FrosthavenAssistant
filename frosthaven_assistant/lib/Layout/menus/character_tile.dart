import 'package:flutter/material.dart';

import '../../Model/character_class.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class CharacterTile extends StatelessWidget {
  // Constructor
  CharacterTile(
      {super.key,
      required this.character,
      required this.onSelect,
      this.disabled = false});

  final CharacterClass character;
  final void Function(CharacterClass) onSelect;
  final bool disabled;
  final GameState _gameState = getIt<GameState>();

  void _handleAddCharacter() {
    if (!disabled) {
      onSelect(character);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool characterUnlocked =
        _gameState.unlockedClasses.contains(character.name);
    bool characterIsObjective = character.name == "Objective";
    bool characterIsEscort = character.name == "Escort";

    return ListTile(
      leading: Image(
        height: 40,
        width: 40,
        fit: BoxFit.contain,
        color: character.hidden && !characterUnlocked ||
                characterIsEscort ||
                characterIsObjective
            ? null
            : character.color,
        filterQuality: FilterQuality.medium,
        image: AssetImage("assets/images/class-icons/${character.name}.png"),
      ),
      //iconColor: character.color,
      title: Text(
          character.hidden && !characterUnlocked ? "???" : character.name,
          style: TextStyle(
              fontSize: 18, color: disabled ? Colors.grey : Colors.black)),
      trailing: Text("(${character.edition})",
          style: const TextStyle(fontSize: 14, color: Colors.grey)),
      onTap: _handleAddCharacter,
    );
  }
}
