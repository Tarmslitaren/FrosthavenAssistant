import 'package:flutter/material.dart';

import '../../Resource/ui_utils.dart';
import '../service_locator.dart';
import 'network.dart';

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
    return ValueListenableBuilder<String>(
        valueListenable: getIt<Network>().networkMessage,
        builder: (context, value, child) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if(getIt<Network>().networkMessage.value != "") {
              showToast(context, getIt<Network>().networkMessage.value);
              getIt<Network>().networkMessage.value = "";
            }
          });

          return const SizedBox(
            width: 0.00001,
            height: 0.00001,
          );
        });
  }
}