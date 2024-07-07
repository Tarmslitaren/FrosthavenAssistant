
import 'dart:developer';
import 'dart:io';

import 'package:frosthaven_assistant_server/game_server.dart';
import 'package:frosthaven_assistant_server/server_state.dart';

class StandaloneServer extends GameServer {

  final List<Socket> _clientConnections = List.empty(growable: true);
  final ServerState _state = ServerState();


  @override
  void addClientConnection(Socket client) {
    _clientConnections.add(client);
  }

  @override
  String currentStateMessage(String commandDescription) {
    String state = "{}";
    if (_state.gameSaveStates.isNotEmpty){
      state = _state.gameSaveStates.last!.getState();
    }
    return "Index:${_state.commandIndex}Description:${commandDescription}GameState:$state";
  }

  @override
  Future<String> getConnectToIP() async {
    for (var interface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
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
    for (var client in _clientConnections) {
      client.close();
    }
    _clientConnections.clear();
  }

  @override
  void removeClientConnection(Socket client) {
    client.close();
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
        "Index:${_state.commandIndex}Description:${commandDescription}GameState:${_state.gameSaveStates.last!.getState()}",
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
      if (client.remoteAddress != clientConnection.remoteAddress){
        _writeToClient(clientConnection, message);
      }
    }
  }

  void _writeToClient(Socket client, String message) {
    try {
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
          "Index:${_state.commandIndex}Description:${commandDescription}GameState:${_state.gameSaveStates.last!.getState()}");
    } else if (message.index > _state.commandIndex) {
      _state.commandIndex = message.index;
      if (message.index >= 0) {
        _state.commandDescriptions
            .insert(_state.commandIndex, message.description);
      }
      _state.save(message.data);
      sendToOthers(
          "Index:${_state.commandIndex}Description:${_state.commandDescriptions.last}GameState:${_state.gameSaveStates.last!.getState()}",
          client);
    } else {
      print(
          'Got same or lower index. ignoring: received index: ${message.indexString} current index ${_state.commandIndex}');

      //overwrite client state with current server state.
      sendToOnly(
          "Mismatch:Index:${_state.commandIndex}Description:${_state.commandDescriptions[_state.commandIndex]}GameState:${_state.gameSaveStates.last!.getState()}",
          client);
      //ignore if same index from server
    }
  }

  @override
  void sendPing() {
    if (serverSocket != null && serverEnabled) {
      Future.delayed(const Duration(seconds: 5), () {
        send("ping");
        sendPing();
      });
    }
  }

  String _createMessage(String data){
    const beginning = "S3nD:";
    const end = "[EOM]";
    return "$beginning$data$end";
  }
  
}