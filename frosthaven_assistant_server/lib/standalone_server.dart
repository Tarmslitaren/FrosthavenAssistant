
import 'dart:developer';
import 'dart:io';

import 'package:frosthaven_assistant_server/connection_health.dart';
import 'package:frosthaven_assistant_server/game_server.dart';
import 'package:frosthaven_assistant_server/server_state.dart';

class StandaloneServer extends GameServer {

  final List<Socket> _clientConnections = List.empty(growable: true);
  final ServerState _state = ServerState();
  final Map<Socket,ConnectionHealth> _connectionHealth = {};
  int pingCount = 0;
  bool _pinging = false; //to not restart this ping sub process, if one is running

  static const String _noEventJson = '{"type":"none"}';

  String _lastSavedState() {
    return _state.gameSaveStates.isNotEmpty
        ? _state.gameSaveStates.last.getState()
        : "{}";
  }


  @override
  void addClientConnection(Socket client) {
    print("Add client connection ${safeGetClientAddress(client)}");
    _connectionHealth[client] = ConnectionHealth();
    _clientConnections.add(client);
  }

  @override
  String currentStateMessage(String commandDescription) {
    return "Index:${_state.commandIndex}Description:${commandDescription}Event:${_noEventJson}GameState:${_lastSavedState()}";
  }

  @override
  Future<String> getConnectToIP() async {
    for (var interface in await NetworkInterface.list(type: InternetAddressType.IPv6)) {
      for (var address in interface.addresses){
        return address.address;
      }
    }
    return "0.0.0.0";
  }

  @override
  void redoState() {
    String message = _state.redoState();
    if (message.isNotEmpty) {
      send(message);
    }
  }

  @override
  void removeAllClientConnections() {
    print("Remove all Client Connections");
    for (var client in _clientConnections) {
      print("Close Connection ${safeGetClientAddress(client)} ${_connectionHealth[client]}");
      try {
        client.close();
      } catch (exception) {
        print("Client already closed");
      }
    }
    _clientConnections.clear();
  }

  @override
  void removeClientConnection(Socket client) {
    print("Remove client connection ${safeGetClientAddress(client)}");
    print("Close Connection ${safeGetClientAddress(client)} ${_connectionHealth[client]}");
    try {
      client.close();
    } catch (exception) {
      print("Client already closed");
    }
    _clientConnections.remove(client);
  }

  @override
  void resetState() {
    _state.commandIndex = -1;
    _state.commands.clear();
    _state.commandDescriptions.clear();
    if (_state.gameSaveStates.isNotEmpty){
      _state.gameSaveStates
          .removeRange(0, _state.gameSaveStates.length - 1);
    }
    _pinging = false;
  }

  @override
  void sendInitResponse(Socket client) {
    String commandDescription = "";
    if (_state.commandIndex > 0 &&
        _state.commandDescriptions.length >
            _state.commandIndex) {
      commandDescription = _state
          .commandDescriptions[_state.commandIndex];
    }
    print(
        'Server sends init response: "S3nD:Index:${_state.commandIndex}Description:$commandDescription');
    sendToOnly(
        "Index:${_state.commandIndex}Description:${commandDescription}Event:${_noEventJson}GameState:${_lastSavedState()}",
        client);
  }

  @override
  void send(String data) {
    final String message = _createMessage(data);
    for(Socket client in _clientConnections){
      _writeToClient(client, message);
    }
  }

  @override
  void sendToOnly(String data, Socket client) {
    final String message = _createMessage(data);
    _writeToClient(client, message);
  }

  @override
  void sendToOthers(String data, Socket client) {
    final String message = _createMessage(data);
    for(Socket clientConnection in _clientConnections){
      try {
        if (client.remoteAddress != clientConnection.remoteAddress || clientConnection.remotePort != client.remotePort){
          _writeToClient(clientConnection, message);
        }
      } catch (exception) {
        print("Attempted to access properties on a closed client $exception");
      }
    }
  }

  void _writeToClient(Socket client, String message) {
    try {
      _connectionHealth[client]?.logMessageSent();
      client.write(message);
    } catch (error) {
      print(error);
    }
  }

  @override
  void setNetworkMessage(String data) {
    print(data);
  }

  @override
  void undoState() {
    String message = _state.undoState();
    if (message.isNotEmpty) {
      send(message);
    } else {
      setNetworkMessage("Unable to undo command");
    }
  }

  @override
  void updateStateFromMessage(StateUpdateMessage message, Socket client) {
    if (message.index > _state.commandDescriptions.length) {
      //invalid: index too high. send correction to clients
      String commandDescription = "";
      if (_state.commandDescriptions.isNotEmpty) {
        commandDescription = _state.commandDescriptions.last;
      }
      send(
          "Index:${_state.commandIndex}Description:${commandDescription}Event:${_noEventJson}GameState:${_lastSavedState()}");
    } else if (message.index > _state.commandIndex) {
      _state.commandIndex = message.index;
      if (message.index >= 0) {
        _state.commandDescriptions
            .insert(_state.commandIndex, message.description);
      }
      _state.save(message.data);
      sendToOthers(
          "Index:${_state.commandIndex}Description:${_state.commandDescriptions.last}Event:${message.eventJson}GameState:${_lastSavedState()}",
          client);
    } else {
      print(
          'Got same or lower index. ignoring: received index: ${message.indexString} current index ${_state.commandIndex}');

      //overwrite client state with current server state.
      sendToOnly(
          "Mismatch:Index:${_state.commandIndex}Description:${_state.commandDescriptions[_state.commandIndex]}Event:${_noEventJson}GameState:${_lastSavedState()}",
          client);
      //ignore if same index from server
    }
  }

  @override
  void sendPing() {
    if (serverSocket != null && serverEnabled && !_pinging) {
      _pinging = true;
      Future.delayed(const Duration(seconds: 5), () {
        if (serverSocket == null || !serverEnabled) {
          _pinging = false;
          return;
        }
        send("ping");
        for(Socket client in _clientConnections){
          _connectionHealth[client]?.logPing();
        }
        pingCount++;
        if (pingCount % 30 == 0){
          printHealthReport();
        }
        _pinging = false;
        sendPing();
      });
    }
  }

  @override
  void handlePongMessage(Socket client){
    super.handlePongMessage(client);
    _connectionHealth[client]?.logPong();
  }

  @override
  void processMessages(String socketMessages, Socket client){
    _connectionHealth[client]?.logMessageReceived();
    super.processMessages(socketMessages, client);
  }

  String _createMessage(String data){
    const beginning = "S3nD:";
    const end = "[EOM]";
    return "$beginning$data$end";
  }

  void printHealthReport(){
    print("=======================================");
    print("|           HEALTH REPORT             |");
    print("=======================================");
    print("ACTIVE CONNNECTIONS: ${_clientConnections.length}");
    for(Socket client in _clientConnections){
      print("Client ${safeGetClientAddress(client)} ${_connectionHealth[client]}");
    }
    print("");
    print("TOTAL CONNECTIONS: ${_connectionHealth.keys.length}");
    print("HEALTH DATA: ");
    for (ConnectionHealth data in _connectionHealth.values){
      print(data);
    }
  }

  String safeGetClientAddress(Socket client){
    try{
      return "Client ${client.remoteAddress}:${client.remotePort}";
    } catch (exception) {
      return "Closed client: ";
    }
  }
  
}
