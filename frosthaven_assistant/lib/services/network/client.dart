import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/network/network.dart';

import '../../Resource/state/game_state.dart';
import '../../Resource/settings.dart';
import '../service_locator.dart';
import 'dart:convert' show utf8;

import 'connection.dart';

class Client {
  String _leftOverMessage = "";
  bool serveResponsive = true;

  final _gameState = getIt<GameState>();
  final _communication = getIt<Communication>();
  final _connection = getIt<Connection>();
  final _network = getIt<Network>();
  final _settings = getIt<Settings>();

  Future<void> connect(String address) async {
// connect to the socket server
    serveResponsive = true;
    try {
      int port = int.parse(_settings.lastKnownPort);
      debugPrint("port nr: ${port.toString()}");
      await Socket.connect(InternetAddress(address), port)
          .then((Socket socket) {
        runZoned(() {
          _connection.add(socket);
          _settings.client.value = ClientState.connected;
          String info =
              'Client Connected to: ${socket.remoteAddress.address}:${socket.remotePort}';
          debugPrint(info);
          _gameState.commands.clear();
          _network.networkMessage.value = info;
          _settings.connectClientOnStartup = true;
          _settings.saveToDisk();
          _send("init version:${_network.server.serverVersion}");
          _sendPing();
          _listen();
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

  void _sendPing() {
    if (_connection.established() &&
        _settings.client.value == ClientState.connected) {
      Future.delayed(const Duration(seconds: 12), () {
        if (serveResponsive == true) {
          _communication.sendToAll("ping");
          _sendPing();
          serveResponsive = false; //set back to true when get response
        } else {
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
    print('Lost connection to server.');
    if (serveResponsive != false) {
      _network.networkMessage.value = "Lost connection to server";
    }
    _connection.removeAll();
    _cleanup();
  }

  onListenError(error) {
    debugPrint('Client error: ${error.toString()}');
    _network.networkMessage.value = "client error: ${error.toString()}";
    //_socket?.destroy();
    //_cleanup();
  }

  void onListenData(Uint8List data) {
    String message = utf8.decode(data); // String.fromCharCodes(data);
    message = _leftOverMessage + message;
    _leftOverMessage = "";

    List<String> messages = message.split("S3nD:");
    //handle
    for (var message in messages) {
      if (message.endsWith("[EOM]")) {
        message = message.substring(0, message.length - "[EOM]".length);
        if (message.startsWith("Mismatch:")) {
          message = message.substring("Mismatch:".length);
          _network.networkMessage.value =
              "Your state was not up to date, try again.";
        }
        if (message.startsWith("Index:")) {
          List<String> messageParts1 = message.split("Description:");
          String indexString = messageParts1[0].substring("Index:".length);
          List<String> messageParts2 = messageParts1[1].split("GameState:");
          String description = messageParts2[0];
          String data = messageParts2[1];

          debugPrint(
              'Client Receive Data, index: $indexString, description:$description');

          int newIndex = int.parse(indexString);
          //overwrite states if needed
          _gameState.commandIndex.value = newIndex;

          _gameState.loadFromData(data);
          _gameState.updateAllUI();
        } else if (message.startsWith("Error")) {
          throw (message);
        } else if (message.startsWith("ping")) {
          _send("pong");
        } else if (message.startsWith("pong")) {
          serveResponsive = true;
        }
      } else {
        _leftOverMessage = message;
      }
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
    _gameState.commands.clear();
    _gameState.commandDescriptions.clear();
    _gameState.gameSaveStates
        .removeRange(0, _gameState.gameSaveStates.length - 1);
    _leftOverMessage = "";

    if (_network.appInBackground == true) {
      _network.clientDisconnectedWhileInBackground = true;
    }
    serveResponsive = true;
  }
}
