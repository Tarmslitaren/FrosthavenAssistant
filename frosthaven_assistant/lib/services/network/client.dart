import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/network/network.dart';

import '../../Resource/game_event.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../service_locator.dart';
import 'connection.dart';

class Client {
  String _leftOverMessage = "";
  bool _serverResponsive = true;
  final GameState _gameState;
  final Communication _communication;
  final Connection _connection;
  final Network _network;
  final Settings _settings;

  Client(
      {GameState? gameState,
      Communication? communication,
      Connection? connection,
      Network? network,
      Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _communication = communication ?? getIt<Communication>(),
        _connection = connection ?? getIt<Connection>(),
        _network = network ?? getIt<Network>(),
        _settings = settings ?? getIt<Settings>();

  Future<void> connect(String address) async {
    _serverResponsive = true;
    try {
      int port = int.parse(_settings.lastKnownPort);
      debugPrint("port nr: ${port.toString()}");
      await _connection.connect(address, port).then((Socket socket) {
        runZonedGuarded(() {
          _settings.client.value = ClientState.connected;
          String info =
              'Client Connected to: ${socket.remoteAddress.address}:${socket.remotePort}';
          debugPrint(info);
          _gameState.clearLocalCommands();
          _network.networkMessage.value = info;
          if (Platform.isAndroid || Platform.isIOS) {
            _settings.connectClientOnStartup = true;
          }
          _settings.saveToDisk();
          _send("init version:${_network.server.serverVersion}");
          _sendPing();
          _listen();
        }, (error, stack) {
          debugPrint('Client zone error: $error\n$stack');
          _network.networkMessage.value = 'Client error: $error';
        });
      });
    } catch (error) {
      debugPrint("client error: $error");
      _network.networkMessage.value = "client error: $error";
      _settings.client.value = ClientState.disconnected;
      _settings.connectClientOnStartup = false;
      _settings.saveToDisk();
    }
  }

  bool _pinging =
      false; //to not restart this ping sub process, if one is running
  void _sendPing() {
    if (_connection.established() &&
        _settings.client.value == ClientState.connected &&
        _pinging == false) {
      _pinging = true;
      Future.delayed(const Duration(seconds: 12), () {
        if (_serverResponsive == true) {
          _communication.sendToAll("ping");
          _serverResponsive = false; //set back to true when get response
          _pinging = false;
          _sendPing();
        } else {
          _pinging = false;
          disconnect("Server unresponsive. Client disconnected.");
        }
      });
    }
  }

  void _listen() {
    // listen for responses from the server
    try {
      _communication.listen(onListenData, onListenError, onListenDone);
    } catch (error) {
      debugPrint(error.toString());
      //_socket?.destroy();
      _network.networkMessage.value =
          'Client listen error: ${error.toString()}';
      //_cleanup();
    }
  }

  void onListenDone() {
    debugPrint('Lost connection to server.');
    if (_serverResponsive != false) {
      _network.networkMessage.value = "Lost connection to server";
    }
    _connection.removeAll();
    _cleanup();
  }

  void onListenError(dynamic error) {
    debugPrint('Client error: ${error.toString()}');
    _network.networkMessage.value = "client error: ${error.toString()}";
  }

  void onListenData(Uint8List data) {
    _leftOverMessage += utf8.decode(data);

    // Use indexOf-based framing so that "S3nD:" inside a payload (e.g. in a
    // JSON game-state string) never creates false message boundaries.
    const String prefix = 'S3nD:';
    const String suffix = '[EOM]';
    while (true) {
      final int start = _leftOverMessage.indexOf(prefix);
      if (start == -1) break;
      final int contentStart = start + prefix.length;
      final int end = _leftOverMessage.indexOf(suffix, contentStart);
      if (end == -1) break;

      final String content = _leftOverMessage.substring(contentStart, end);
      _leftOverMessage = _leftOverMessage.substring(end + suffix.length);
      _serverResponsive = true;
      _handleContent(content);
    }
  }

  void _handleContent(String message) {
    if (message.startsWith("Mismatch:")) {
      message = message.substring("Mismatch:".length);
      _network.networkMessage.value =
          "Your state was not up to date, try again.";
    }

    // Try new JSON envelope format first, fall back to legacy text format.
    final StateEnvelope? envelope = StateEnvelope.tryDecode(message);
    if (envelope != null) {
      final GameEvent event = GameEvent.fromJsonString(envelope.eventJson);
      debugPrint(
          'Client Receive Data, index: ${envelope.index}, event:${event.runtimeType}');
      _gameState.loadFromData(envelope.state);
      // Set event before commandIndex fires so VLB callbacks see it.
      _gameState.lastEvent.value = event;
      _gameState.commandIndex.value = envelope.index;
      _gameState.updateAllUI();
      Future.delayed(
          const Duration(milliseconds: 100), () => _gameState.save());
    } else if (message.startsWith("Index:")) {
      // Legacy text format: "Index:NDescription:textEvent:{...}GameState:state"
      List<String> messageParts1 = message.split("Description:");
      String indexString = messageParts1[0].substring("Index:".length);
      final String afterDescription = messageParts1[1];

      GameEvent event = const NoEvent();
      String data;
      if (afterDescription.contains("Event:")) {
        List<String> messageParts2 = afterDescription.split("Event:");
        List<String> messageParts3 = messageParts2[1].split("GameState:");
        event = GameEvent.fromJsonString(messageParts3.first);
        data = messageParts3[1];
      } else {
        // Backwards-compatible: older server without Event field.
        data = afterDescription.split("GameState:")[1];
      }

      debugPrint(
          'Client Receive Data, index: $indexString, event:${event.runtimeType}');

      _gameState.loadFromData(data);
      int newIndex = int.tryParse(indexString) ?? -1;
      // Set event before commandIndex fires so VLB callbacks see it.
      _gameState.lastEvent.value = event;
      _gameState.commandIndex.value = newIndex;
      _gameState.updateAllUI();
      Future.delayed(
          const Duration(milliseconds: 100), () => _gameState.save());
    } else if (message.startsWith("Error")) {
      _network.networkMessage.value = message;
      disconnect(message);
    } else if (message.startsWith("ping")) {
      _send("pong");
    } else if (message.startsWith("pong")) {
      _serverResponsive = true;
    }
  }

  void _send(String data) {
    _communication.sendToAll(data);
  }

  void disconnect(String? message) {
    message ??= "client disconnected";
    if (_connection.established()) {
      debugPrint(message);
      _network.networkMessage.value = message;
      _connection.removeAll();
      _settings.connectClientOnStartup = false;
      _settings.saveToDisk();
      _cleanup();
    }
  }

  void _cleanup() {
    _settings.client.value = ClientState.disconnected;
    _gameState.commandIndex.value = -1;
    _gameState.resetCommandHistory();
    _leftOverMessage = "";
    _pinging = false;

    if (_network.appInBackground == true) {
      _network.clientDisconnectedWhileInBackground = true;
    }
    _serverResponsive = true;
  }
}
