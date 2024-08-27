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

class Server extends GameServer{
  final int serverVersion = 191;

  final GameState _gameState = getIt<GameState>();
  final _communication = getIt<Communication>();
  final _connection = getIt<Connection>();

  @override
  bool get serverEnabled {
    return getIt<Settings>().server.value;
  }

  @override
  set serverEnabled(bool value){
    getIt<Settings>().server.value = value;
    super.serverEnabled = value;
  }

  @override
  Future<String> getConnectToIP() async{
    String connectTo = InternetAddress.anyIPv4.address; //"0.0.0.0";
    if (getIt<Network>().networkInfo.wifiIPv4.value.isNotEmpty &&
        !getIt<Network>().networkInfo.wifiIPv4.value.contains("Fail")) {
      connectTo = getIt<Network>().networkInfo.wifiIPv4.value;
    } else {
      getIt<Network>().networkInfo.wifiIPv4.value =
          connectTo; //if not on wifi show local ip
    }
    return connectTo;
  }

  @override
  void resetState(){
    _gameState.commandIndex.value = -1;
    _gameState.commands.clear();
    _gameState.commandDescriptions.clear();
    _gameState.gameSaveStates
        .removeRange(0, _gameState.gameSaveStates.length - 1);
  }

  @override
  void undoState(){
    _gameState.undo();
  }

  @override
  void redoState(){
    _gameState.redo();
  }

  @override
  void updateStateFromMessage(StateUpdateMessage message, Socket client){
    if (message.index > _gameState.commandDescriptions.length) {
      //invalid: index too high. send correction to clients
      String commandDescription = "";
      if (_gameState.commandDescriptions.isNotEmpty) {
        commandDescription = _gameState.commandDescriptions.last;
      }
      send(
          "Index:${_gameState.commandIndex.value}Description:${commandDescription}GameState:${_gameState.gameSaveStates.last!.getState()}");
    } else if (message.index > _gameState.commandIndex.value) {
      _gameState.commandIndex.value = message.index;
      if (message.index >= 0) {
        _gameState.commandDescriptions
            .insert(_gameState.commandIndex.value, message.description);
      }
      _gameState.loadFromData(message.data);
      _gameState.save();
      _gameState.updateAllUI();
      sendToOthers(
          "Index:${_gameState.commandIndex.value}Description:${_gameState.commandDescriptions.last}GameState:${_gameState.gameSaveStates.last!.getState()}",
          client);
    } else {
      log(
          'Got same or lower index. ignoring: received index: ${message.indexString} current index ${_gameState.commandIndex.value}');
      //overwrite client state with current server state.
      sendToOnly(
          "Mismatch:Index:${_gameState.commandIndex.value}Description:${_gameState.commandDescriptions[_gameState.commandIndex.value]}GameState:${_gameState.gameSaveStates.last!.getState()}",
          client);
      //ignore if same index from server
    }
  }

  @override
  void setNetworkMessage(String data){
    getIt<Network>().networkMessage.value = data;
  }

  @override
  String currentStateMessage(String commandDescription){
    return "Index:${_gameState.commandIndex.value}Description:${commandDescription}GameState:${_gameState.gameSaveStates.last!.getState()}";
  }

  @override
  void sendPing() {
    if (serverSocket != null && getIt<Settings>().server.value != false) {
      Future.delayed(const Duration(seconds: 20), () {
        send("ping");
        sendPing();
      });
    }
  }

  @override
  void addClientConnection(Socket client){
    _connection.add(client);
  }

  @override
  void removeClientConnection(Socket client){
    _connection.remove(client);
  }

  @override
  void removeAllClientConnections(){
    _connection.removeAll();
  }

  Future<void> startServer() async {
    startServerInternal(InternetAddress.anyIPv4.address,
              int.parse(getIt<Settings>().lastKnownPort));
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
  void sendInitResponse(Socket client){
    String commandDescription = "";
    if (_gameState.commandIndex.value > 0 &&
        _gameState.commandDescriptions.length >
            _gameState.commandIndex.value) {
      commandDescription = _gameState
          .commandDescriptions[_gameState.commandIndex.value];
    } else {
      //should not happen
      if (kDebugMode) {
        print("?");
      }
    }
    log(
        'Server sends init response: "S3nD:Index:${_gameState.commandIndex.value}Description:$commandDescription');
    sendToOnly(
        "Index:${_gameState.commandIndex.value}Description:${commandDescription}GameState:${_gameState.gameSaveStates.last!.getState()}",
        client);
  }
}
