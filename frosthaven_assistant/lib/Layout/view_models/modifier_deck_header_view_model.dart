import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

const int _kHailPerkIndex = 17;
const int _kCassandraPerkIndex = 15;

class ModifierDeckHeaderViewModel {
  const ModifierDeckHeaderViewModel({
    required this.deck,
    required this.gameState,
    required this.settings,
    required this.name,
  });

  final ModifierDeck deck;
  final GameState gameState;
  final Settings settings;
  final String name;

  bool get isCharacter => name.isNotEmpty && name != "allies";

  bool get monsterDeck => name.isEmpty;

  Character? get character =>
      isCharacter ? GameMethods.getCharacterByName(name) : null;

  bool get hasDiviner => gameState.currentList.any(
    (item) => item is Character && item.characterClass.name == "Diviner",
  );

  Character? get characterHail => GameMethods.getCharacterByName("Hail");

  bool get hasHailPerk =>
      characterHail?.characterState.perkList[_kHailPerkIndex] ?? false;

  Character? get characterCassandra =>
      GameMethods.getCharacterByName("Cassandra");

  bool get hasCassandraPerk =>
      characterCassandra?.characterState.perkList[_kCassandraPerkIndex] ??
      false;

  bool get hasIncarnate =>
      GameMethods.getFigure("Incarnate", "Incarnate") != null;

  bool get hasVimthreader =>
      GameMethods.getFigure("Vimthreader", "Vimthreader") != null;

  bool get hasLifespeaker =>
      GameMethods.getFigure("Lifespeaker", "Lifespeaker") != null;

  bool get hasCassandra =>
      GameMethods.getFigure("Cassandra", "Cassandra") != null;

  bool get isCSCampaign {
    final campaign = gameState.currentCampaign.value;
    return campaign == "Crimson Scales" || campaign == "Trail of Ashes";
  }

  bool get donatedCS => isCharacter && deck.hasCSSanctuary();

  bool get addedPartyCard => isCharacter && deck.hasPartyCard();

  bool get hasPlus0Card => deck.hasCard("plus0");

  int get nrOfEnfeebles {
    int n = 0;
    if (hasVimthreader) n++;
    if (hasLifespeaker) n++;
    if (hasIncarnate) n++;
    return n;
  }

  int get nrOfEmpowers {
    int n = 0;
    if (hasVimthreader) n++;
    if (hasIncarnate) n++;
    return n;
  }

  bool get hasMoreThanOneEnfeeble => monsterDeck && nrOfEnfeebles > 1;

  bool get hasMoreThanOneEmpower =>
      ((isCharacter || name == "allies") && nrOfEmpowers > 1) ||
      (isCharacter && character?.id == "Ruinmaw" && nrOfEmpowers > 0);
}
