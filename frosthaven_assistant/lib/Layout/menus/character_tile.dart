import 'package:flutter/material.dart';

import '../../Model/character_class.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class CharacterTile extends StatelessWidget {
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
    bool characterUnlocked = _gameState.unlockedClasses.contains(character.id);

    return ListTile(
      leading: Image.asset(
        "assets/images/class-icons/${character.name}.png",
        height: 40,
        width: 40,
        cacheHeight: 80,
        fit: BoxFit.contain,
        color: character.hidden && !characterUnlocked ||
                GameMethods.isObjectiveOrEscort(character)
            ? null
            : character.color,
        filterQuality: FilterQuality.medium,
      ),
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
