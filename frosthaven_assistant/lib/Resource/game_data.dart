import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../Model/campaign.dart';
import '../Model/room.dart';
import '../Model/summon.dart';

class GameData {
  late final BuiltList<String> editions;
  final modelData = ValueNotifier<Map<String, CampaignModel>>({}); //todo: make map immutable
  late final BuiltList<SummonModel> itemSummonData;

  Future<void> loadData(String root) async {
    rootBundle.evict('${root}summon.json');
    //cache false to make hot restart apply changes to base file. Does not work with hot reload...
    final String response = await rootBundle.loadString('${root}summons.json', cache: false);
    final data = await json.decode(response);

    //load loose summons
    if (data.containsKey('summons')) {
      final summons = data['summons'] as Map<dynamic, dynamic>;
      List<SummonModel> summonModels = [];
      for (String key in summons.keys) {
        summonModels.add(SummonModel.fromJson(summons[key], key));
      }
      itemSummonData = BuiltList.of(summonModels);
    }

    Map<String, CampaignModel> map = {};

    final String editions =
        await rootBundle.loadString('${root}editions/editions.json', cache: false);
    final Map<String, dynamic> editionData = await json.decode(editions);
    List<String> editionList = [];
    for (String item in editionData["editions"]) {
      editionList.add(item);

      List<RoomsModel> roomData = [];
      await fetchRoomData(item, root).then((value) {
        if (value != null) roomData.addAll(value.roomData);
      });

      await fetchCampaignData(item, root, map, roomData);
    }
    this.editions = BuiltList.of(editionList);

    modelData.value = map;
  }

  Future<EditionRoomsModel?> fetchRoomData(String campaign, String root) async {
    try {
      final String response = await rootBundle.loadString('${root}rooms/$campaign.json');
      final data = await json.decode(response);
      return EditionRoomsModel.fromJson(data);
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      return null;
    }
  }

  fetchCampaignData(String campaign, String root, Map<String, CampaignModel> map,
      List<RoomsModel> roomsData) async {
    rootBundle.evict('${root}editions/$campaign.json');
    final String response =
        await rootBundle.loadString('${root}editions/$campaign.json', cache: false);
    final data = await json.decode(response);
    map[campaign] = CampaignModel.fromJson(data, roomsData);
  }
}
