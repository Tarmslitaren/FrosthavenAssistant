import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/network/network.dart';
import 'package:frosthaven_assistant_server/game_server.dart';

import '../../Resource/game_event.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../l10n/app_localizations.dart';
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

  AppLocalizations get _l10n {
    final code = _settings.locale.value;
    try {
      return lookupAppLocalizations(Locale(code));
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }

  Client({
    GameState? gameState,
    Communication? communication,
    Connection? connection,
    Network? network,
    Settings? settings,
  }) : _gameState = gameState ?? getIt<GameState>(),
       _communication = communication ?? getIt<Communication>(),
       _connection = connection ?? getIt<Connection>(),
       _network = network ?? getIt<Network>(),
       _settings = settings ?? getIt<Settings>();

  void _setNetworkMessage(String msg, {bool isError = false}) {
    _network.networkMessageIsError.value = isError;
    _network.networkMessage.value = msg;
  }

  Future<void> connect(String address) async {
    _serverResponsive = true;
    try {
      int port = int.parse(_settings.lastKnownPort);
      debugPrint("port nr: ${port.toString()}");
      final socket = await _connection.connect(address, port);
      runZonedGuarded(
        () {
          _settings.client.value = ClientState.connected;
          String info = _l10n.clientConnectedTo(
              '${socket.remoteAddress.address}:${socket.remotePort}');
          debugPrint(info);
          _gameState.clearLocalCommands();
          _setNetworkMessage(info);
          if (Platform.isAndroid || Platform.isIOS) {
            _settings.connectClientOnStartup = true;
          }
          _settings.saveToDisk();
          _send("init protocolVersion:${GameServer.protocolVersion}");
          _sendPing();
          _listen();
        },
        (error, stack) {
          debugPrint('Client zone error: $error\n$stack');
          _setNetworkMessage(_l10n.clientError(error.toString()), isError: true);
        },
      );
    } catch (error) {
      debugPrint("client error: $error");
      _setNetworkMessage(_l10n.clientError(error.toString()), isError: true);
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
        !_pinging) {
      _pinging = true;
      Future.delayed(const Duration(seconds: 12), () {
        if (_serverResponsive) {
          _communication.sendToAll("ping");
          _serverResponsive = false; //set back to true when get response
          _pinging = false;
          _sendPing();
        } else {
          _pinging = false;
          disconnect(_l10n.serverUnresponsive);
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
      _setNetworkMessage(_l10n.clientListenError(error.toString()), isError: true);
      //_cleanup();
    }
  }

  void onListenDone() {
    debugPrint('Lost connection to server.');
    if (_serverResponsive) {
      _setNetworkMessage(
          '${_network.networkMessage.value} ${_l10n.lostConnectionToServer}',
          isError: true);
    }
    _connection.removeAll();
    _cleanup();
  }

  void onListenError(Object error) {
    debugPrint('Client error: ${error.toString()}');
    _setNetworkMessage(_l10n.clientError(error.toString()), isError: true);
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
      _setNetworkMessage(_l10n.stateMismatch);
    }

    final StateEnvelope? envelope = StateEnvelope.tryDecode(message);
    if (envelope != null) {
      final GameEvent event = GameEvent.fromJsonString(envelope.eventJson);
      debugPrint(
        'Client Receive Data, index: ${envelope.index}, event:${event.runtimeType}',
      );
      _gameState.loadFromData(envelope.state);
      // Set event before commandIndex fires so VLB callbacks see it.
      _gameState.lastEvent.value = event;
      _gameState.commandIndex.value = envelope.index;
      _gameState.updateAllUI();
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _gameState.save(),
      );
    } else if (message.startsWith("Error")) {
      _setNetworkMessage(message, isError: true);
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
    message ??= _l10n.clientDisconnected;
    if (_connection.established()) {
      debugPrint(message);
      _setNetworkMessage(message, isError: true);
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

    if (_network.appInBackground) {
      _network.clientDisconnectedWhileInBackground = true;
    }
    _serverResponsive = true;
  }
}
