import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../models/product.dart';

class AppLauncher {
  static Future<void> launchUntappd(Product product) async {
    var untappdInstalled = await LaunchApp.isAppInstalled(
      iosUrlScheme: 'untappd://',
      androidPackageName: 'com.untappdllc.app',
    );
    if (untappdInstalled == true || untappdInstalled == 1) {
      launch('untappd://beer/${product.untappdId}');
    } else {
      launch(product.untappdUrl!);
    }
  }

  static Future<void> launchFacebook() async {
    var facebookInstalled = await LaunchApp.isAppInstalled(
      iosUrlScheme: 'fb://',
      androidPackageName: 'com.facebook.katana',
    );
    if (facebookInstalled == true || facebookInstalled == 1) {
      if (Platform.isAndroid) {
        launch('fb://page/151737917033944');
      }
      if (Platform.isIOS) {
        launch('fb://profile/151737917033944');
      }
    } else {
      launch('https://www.facebook.com/BeermonopolyNO');
    }
  }
}
