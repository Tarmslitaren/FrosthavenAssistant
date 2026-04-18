import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant_server/game_server.dart';

import '../service_locator.dart';
import 'communication.dart';
import 'connection.dart';
import 'network.dart';

class Server extends GameServer {
  final GameState _gameState;
  final Communication _communication;
  final Connection _connection;
  final Settings? _settingsOverride;

  Server(
      {GameState? gameState,
      Communication? communication,
      Connection? connection,
      Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _communication = communication ?? getIt<Communication>(),
        _connection = connection ?? getIt<Connection>(),
        _settingsOverride = settings;

  Settings get _settings => _settingsOverride ?? getIt<Settings>();

  @override
  bool get serverEnabled {
    return _settings.server.value;
  }

  @override
  set serverEnabled(bool value) {
    _settings.server.value = value;
    super.serverEnabled = value;
  }

  @override
  Future<String> getConnectToIP() async {
    String connectTo = InternetAddress.anyIPv6.address; //"0.0.0.0";
    if (getIt<Network>().networkInfo.wifiIPv6.value.isNotEmpty &&
        !getIt<Network>().networkInfo.wifiIPv6.value.contains("Fail")) {
      connectTo = getIt<Network>().networkInfo.wifiIPv6.value;
    } else {
      getIt<Network>().networkInfo.wifiIPv6.value =
          connectTo; //if not on wifi show local ip
    }
    return connectTo;
  }

  @override
  void resetState() {
    _gameState.commandIndex.value = -1;
    _gameState.resetCommandHistory();
    _pinging = false;
  }

  @override
  void undoState() {
    _gameState.undo();
  }

  @override
  void redoState() {
    _gameState.redo();
  }

  static const String _noEventJson = '{"type":"none"}';

  String _lastSavedState() {
    return _gameState.gameSaveStates.isNotEmpty
        ? (_gameState.gameSaveStates.last?.getState() ?? _gameState.toString())
        : _gameState.toString();
  }

  @override
  void updateStateFromMessage(StateUpdateMessage message, Socket client) {
    if (message.index > _gameState.commandDescriptions.length) {
      //invalid: index too high. send correction to clients
      String commandDescription = "";
      if (_gameState.commandDescriptions.isNotEmpty) {
        commandDescription = _gameState.commandDescriptions.last;
      }
      send(StateEnvelope(
        index: _gameState.commandIndex.value,
        description: commandDescription,
        eventJson: _noEventJson,
        state: _lastSavedState(),
      ).encode());
    } else if (message.index > _gameState.commandIndex.value) {
      _gameState.commandIndex.value = message.index;
      if (message.index >= 0) {
        _gameState.insertReceivedDescription(
            _gameState.commandIndex.value, message.description);
      }
      _gameState.loadFromData(message.data);
      _gameState.save();
      _gameState.updateAllUI();
      sendToOthers(
          StateEnvelope(
            index: _gameState.commandIndex.value,
            description: _gameState.commandDescriptions.last,
            eventJson: message.eventJson,
            state: _lastSavedState(),
          ).encode(),
          client);
    } else {
      log('Got same or lower index. ignoring: received index: ${message.indexString} current index ${_gameState.commandIndex.value}');

      //overwrite client state with current server state.
      final idx = _gameState.commandIndex.value;
      final mismatchDesc = (idx >= 0 && idx < _gameState.commandDescriptions.length)
          ? _gameState.commandDescriptions[idx]
          : '';
      sendToOnly(
          "Mismatch:${StateEnvelope(
            index: idx,
            description: mismatchDesc,
            eventJson: _noEventJson,
            state: _lastSavedState(),
          ).encode()}",
          client);
      //ignore if same index from server
    }
  }

  @override
  void setNetworkMessage(String data) {
    getIt<Network>().networkMessage.value = data;
  }

  @override
  String currentStateMessage(String commandDescription) {
    return StateEnvelope(
      index: _gameState.commandIndex.value,
      description: commandDescription,
      eventJson: _noEventJson,
      state: _lastSavedState(),
    ).encode();
  }

  bool _pinging = false; //to not restart this ping sub process, if one is running
  @override
  void sendPing() {
    if (serverSocket != null &&
        _settings.server.value &&
        !_pinging) {
      _pinging = true;
      Future.delayed(const Duration(seconds: 20), () {
        if (serverSocket == null || !_settings.server.value) {
          _pinging = false;
        } else {
          send("ping");
          _pinging = false;
          sendPing();
        }
      });
    }
  }

  @override
  void addClientConnection(Socket client) {
    _connection.add(client);
  }

  @override
  void removeClientConnection(Socket client) {
    _connection.remove(client);
  }

  @override
  void removeAllClientConnections() {
    _connection.removeAll();
  }

  static const int _defaultPort = 4567;

  void startServer() {
    final int port =
        int.tryParse(_settings.lastKnownPort) ?? _defaultPort;
    startServerInternal(InternetAddress.anyIPv6.address, port);
  }

  @override
  void send(String data) {
    _communication.sendToAll(data);
  }

  @override
  void sendToOnly(String data, Socket client) {
    _communication.sendTo(client, data);
  }

  @override
  void sendToOthers(String data, Socket client) {
    _communication.sendToAllExcept(client, data);
  }

  @override
  void sendInitResponse(Socket client) {
    String commandDescription = "";
    if (_gameState.commandIndex.value > 0 &&
        _gameState.commandDescriptions.length > _gameState.commandIndex.value) {
      commandDescription =
          _gameState.commandDescriptions[_gameState.commandIndex.value];
    } else {
      //should not happen
      if (kDebugMode) {
        print("?");
      }
    }
    log('Server sends init response: "S3nD:Index:${_gameState.commandIndex.value}Description:$commandDescription');
    sendToOnly(
        StateEnvelope(
          index: _gameState.commandIndex.value,
          description: commandDescription,
          eventJson: _noEventJson,
          state: _lastSavedState(),
        ).encode(),
        client);
  }
}
