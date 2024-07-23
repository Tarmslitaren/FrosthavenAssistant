
import 'dart:developer';

class ServerState {

  int commandIndex = -1;
  List<ServerSaveState> gameSaveStates = [ServerSaveState()];
  final List<Command?> commands = [];
  final List<String> commandDescriptions = [];

  
  String redoState() {
    if (commandIndex < commandDescriptions.length - 1) {
      commandIndex++;
      //gameSaveStates[commandIndex + 1].saveToDisk(this);
      //send last game state if connected
      print('server sends, redo index: $commandIndex, description:${commandDescriptions[commandIndex]}');
      return "Index:${commandIndex}Description:${commandDescriptions[commandIndex]}GameState:${gameSaveStates[commandIndex + 1]!.getState()}";
    }
    return "";
  }

  String undoState() {
    if (commandIndex >= 0) {
      //gameSaveStates[commandIndex].saveToDisk(this);
      //run generic update all function instead, as commands list is not retained

      //send last game state if connected
      print('server sends, undo index: $commandIndex, description:${commandDescriptions[commandIndex]}');
      //should send a special undo message? yes
      commandIndex--;
      if (commandIndex >= 0){
        return "Index:${commandIndex}Description:${commandDescriptions[commandIndex]}GameState:${gameSaveStates[commandIndex]!.getState()}";
      } else {
        commandIndex = 0;
        return "";
      }
    }
    return "";
  }

  void resetState() {
    commandIndex = -1;
    commands.clear();
    commandDescriptions.clear();
    if (gameSaveStates.isNotEmpty){
      gameSaveStates
          .removeRange(0, gameSaveStates.length - 1);
    }
  }

  void save(String data) {
    ServerSaveState state = ServerSaveState();
    state._savedState = data;
    //state.saveToDisk(this);
    gameSaveStates.add(state); //do this from action handler instead
  }

}

class Command {}

class ServerSaveState {
  String _savedState = "";

  String getState(){
    return _savedState;
  }

  void loadFromData(String data, ServerState gameState) {
    //have to call after init or element state overridden
    _savedState = data;
  }

  void save(ServerState gameState) {
    _savedState = gameState.toString();
  }

}
