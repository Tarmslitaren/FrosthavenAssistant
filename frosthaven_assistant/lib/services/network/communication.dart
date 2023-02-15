import 'dart:io';

import 'package:format/format.dart';
import 'package:get_it/get_it.dart';

class Communication {
  final _getIt = GetIt.instance;
  static const beggining = "S3nD:";
  static const end = "[EOM]";
  final messageTemplate = "$beggining{}$end";

  void sendTo(Socket socket, String message) {
    socket.write(messageTemplate.format(message));
  }

  String dataFrom(String message) {
    //TODO: Validate message - RS
    var data = message.substring(beggining.length, message.length - end.length);
    return data;
  }
}
