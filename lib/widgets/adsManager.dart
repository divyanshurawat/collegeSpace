import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class AdManager {
  static Future<void>launchURLUpdate(uri) async {
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw '$uri';
    }
  }
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2547447950247820~2671319278";
    } else if (Platform.isIOS) {
      return "";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-394025";
    } else if (Platform.isIOS) {
      return "ca-app-pub-0";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2547447950247820/2096604206";
      //return "ca-app-pub-3940256099942544/1033173712";
    } else if (Platform.isIOS) {
      //return "ca-app-pub-9942544/3964253750";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-70";
    } else if (Platform.isIOS) {
     // return "ca-app552160883";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}