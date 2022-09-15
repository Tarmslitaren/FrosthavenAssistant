import 'dart:io';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:developer' as developer;

import 'dart:async';


class NetworkInformation {
  static final NetworkInfo networkInfo = NetworkInfo();

  static String? wifiName,
      wifiBSSID,
      wifiIPv4,
      outgoingIPv4; //
      //wifiIPv6,
      //wifiGatewayIP,
      //wifiBroadcast,
      //wifiSubmask;


  static Future<void> initNetworkInfo() async {
    outgoingIPv4 = await Ipify.ipv4();

    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiName = await networkInfo.getWifiName();
        } else {
          wifiName = await networkInfo.getWifiName();
        }
      } else {
        wifiName = await networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      wifiName = 'Failed to get Wifi Name';
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiBSSID = await networkInfo.getWifiBSSID();
        } else {
          wifiBSSID = await networkInfo.getWifiBSSID();
        }
      } else {
        wifiBSSID = await networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi BSSID', error: e);
      wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      wifiIPv4 = await networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    /*try {
      wifiIPv6 = await networkInfo.getWifiIPv6();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
      wifiIPv6 = 'Failed to get Wifi IPv6';
    }*/

    /*try {
      wifiSubmask = await networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      wifiSubmask = 'Failed to get Wifi submask address';
    }*/

    /*try {
      wifiBroadcast = await networkInfo.getWifiBroadcast();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi broadcast', error: e);
      wifiBroadcast = 'Failed to get Wifi broadcast';
    }*/

    /*try {
      wifiGatewayIP = await networkInfo.getWifiGatewayIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }*/

    /*try {
      wifiSubmask = await networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask', error: e);
      wifiSubmask = 'Failed to get Wifi submask';
    }*/

    developer.log('Wifi Name: $wifiName\n'
          'Wifi BSSID: $wifiBSSID\n'
          'Wifi IPv4: $wifiIPv4\n'
          'Outgoing IPv4: $outgoingIPv4\n'
          //'Wifi Broadcast: $wifiBroadcast\n'
          //'Wifi Gateway: $wifiGatewayIP\n'
          //'Wifi Submask: $wifiSubmask\n'
    );

  }
}