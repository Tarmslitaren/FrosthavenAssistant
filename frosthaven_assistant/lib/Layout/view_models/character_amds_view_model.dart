import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class CharacterAmdsViewModel {
  CharacterAmdsViewModel({GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final GameState _gameState;
  final Settings _settings;

  bool get showCharacterAmd => _settings.showCharacterAMD.value;

  double get barScale => _settings.userScalingBars.value;

  RoundState get roundState => _gameState.roundState.value;

  List<Character> get charsWithPerks => GameMethods.getCurrentCharacters()
      .where((c) => c.characterClass.perks.isNotEmpty)
      .toList();

  int get characterAmount => charsWithPerks.length;

  Character? get currentCharacter => GameMethods.getCurrentCharacter();

  bool get canShowOneDeck {
    final c = currentCharacter;
    return roundState == RoundState.playTurns &&
        c != null &&
        c.characterClass.perks.isNotEmpty;
  }
}
