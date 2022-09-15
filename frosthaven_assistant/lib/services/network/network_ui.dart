import 'package:flutter/material.dart';

class NetworkUI extends StatefulWidget {
  const NetworkUI({Key? key}) : super(key: key);

  @override
  NetworkUIState createState() => NetworkUIState();
}

class NetworkUIState extends State<NetworkUI> {
  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //dummy ui to get context to make toasts.
    // better solution: push toast data to a list. listen for changes in bottom bar or wherever, and display from there.
    return Container();
  }
}