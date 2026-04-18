import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/commands/hide_ally_deck_command.dart';
import 'package:frosthaven_assistant/Resource/commands/show_ally_deck_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:frosthaven_assistant/services/network/network.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class MainMenuViewModel {
  MainMenuViewModel(
      {GameState? gameState,
      Settings? settings,
      Client? client,
      Network? network})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>(),
        _client = client ?? getIt<Client>(),
        _network = network ?? getIt<Network>();

  final GameState _gameState;
  final Settings _settings;
  final Client _client;
  final Network _network;

  // Notifiers the widget subscribes to
  ValueListenable<int> get commandIndex => _gameState.commandIndex;
  ValueListenable<ClientState> get clientState => _settings.client;
  ValueListenable<bool> get serverState => _settings.server;
  ValueListenable<String> get wifiIPv6 => _network.networkInfo.wifiIPv6;

  // Derived state
  bool get undoEnabled {
    final index = _gameState.commandIndex.value;
    if (_settings.client.value == ClientState.connected) return true;
    if (_settings.server.value) {
      return index >= 0 &&
          index < _gameState.commandDescriptions.length &&
          (index == 0 ||
              _gameState.commandDescriptions[index - 1] != "");
    }
    return index >= 0 &&
        index < _gameState.commands.length &&
        (index == 0 || _gameState.commands[index - 1] != null);
  }

  bool get redoEnabled {
    if (_settings.client.value == ClientState.connected) return true;
    if (_settings.server.value) {
      return _gameState.commandDescriptions.isNotEmpty &&
          _gameState.gameSaveStates.length >=
              _gameState.commandDescriptions.length &&
          _gameState.commandIndex.value <
              _gameState.commandDescriptions.length - 1;
    }
    return _gameState.commandIndex.value <
        _gameState.commandDescriptions.length - 1;
  }

  String get undoText {
    final clientState = _settings.client.value;
    final index = _gameState.commandIndex.value;
    final descriptions = _gameState.commandDescriptions;
    String text = "Undo";
    if (clientState != ClientState.connected &&
        index >= 0 &&
        descriptions.length > index) {
      text += ": ${descriptions[index]}";
    }
    return text;
  }

  String get redoText {
    final clientState = _settings.client.value;
    final index = _gameState.commandIndex.value;
    final descriptions = _gameState.commandDescriptions;
    String text = "Redo";
    if (clientState != ClientState.connected &&
        index < descriptions.length - 1) {
      text += ": ${descriptions[index + 1]}";
    }
    return text;
  }

  String get addSectionText =>
      _gameState.scenario.value == "#Random Dungeon"
          ? 'Add Random Dungeon Card'
          : 'Add Section';

  bool get showLootDeckMenu =>
      _gameState.currentCampaign.value == "Frosthaven";

  bool get showShowAllyDeck =>
      !_gameState.showAllyDeck.value &&
      !GameMethods.shouldShowAlliesDeck() &&
      _settings.showAmdDeck.value;

  bool get showHideAllyDeck =>
      _gameState.showAllyDeck.value && _settings.showAmdDeck.value;

  bool get showClientTile =>
      !_settings.lastKnownConnection.endsWith('?');

  bool get isConnected =>
      _settings.client.value == ClientState.connected;

  bool get isConnecting =>
      _settings.client.value == ClientState.connecting;

  String connectionText(String ip) {
    if (isConnected) return "Connected as Client";
    if (isConnecting) return "Connecting...";
    return "Connect as Client ($ip)";
  }

  String get lastKnownConnection => _settings.lastKnownConnection;

  bool get isServer => _settings.server.value;

  // Actions
  void undo() => _gameState.undo();
  void redo() => _gameState.redo();

  void showAllyDeck() {
    _gameState.action(ShowAllyDeckCommand());
    _gameState.updateAllUI();
  }

  void hideAllyDeck() {
    _gameState.action(HideAllyDeckCommand());
    _gameState.updateAllUI();
  }

  Future<void> toggleClientConnection() async {
    if (_settings.client.value != ClientState.connected) {
      _settings.client.value = ClientState.connecting;
      await _client.connect(_settings.lastKnownConnection);
      _settings.saveToDisk();
    } else {
      _client.disconnect(null);
    }
  }

  void toggleServer() {
    _settings.lastKnownHostIP =
        "(${_network.networkInfo.wifiIPv6.value})";
    _settings.saveToDisk();
    if (!_settings.server.value) {
      _network.server.startServer();
    } else {
      _network.server.stopServer(null);
    }
  }

  void save() => _gameState.save();
}
