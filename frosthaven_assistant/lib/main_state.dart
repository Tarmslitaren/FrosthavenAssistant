import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'Layout/main_scaffold.dart';
import 'Model/campaign.dart';
import 'main.dart';



class DataLoadedNotification extends Notification {
  final CampaignModel data;

  const DataLoadedNotification({required this.data});
}

class MainState extends State<MyHomePage>  {

  MainState() {
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return createMainScaffold(context);
  }
}