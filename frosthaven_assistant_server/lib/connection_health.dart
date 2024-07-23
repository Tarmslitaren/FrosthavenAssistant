class ConnectionHealth{
  DateTime creation = DateTime.now();
  int pingsSent = 0;
  int pongsReceived = 0;
  DateTime? lastMessageSent;
  DateTime? lastMessageReceived;
  int messageSent = 0;
  int messageRecieved = 0;

  logPing(){
    pingsSent ++;
    lastMessageSent = DateTime.now();
  }

  logPong(){
    pongsReceived ++;
    lastMessageReceived = DateTime.now();
  }

  logMessageSent(){
    messageSent ++;
    lastMessageSent = DateTime.now();
  }

  logMessageReceived(){
    messageRecieved ++;
    lastMessageReceived = DateTime.now();
  }

  @override
  String toString() {
    return "Created: $creation Sent: $lastMessageSent Recieved: $lastMessageReceived pings $pongsReceived/$pingsSent messages $messageSent | $messageRecieved";
  }
}